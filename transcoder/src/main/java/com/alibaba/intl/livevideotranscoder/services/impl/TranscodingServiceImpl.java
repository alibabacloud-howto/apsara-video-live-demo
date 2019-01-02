package com.alibaba.intl.livevideotranscoder.services.impl;

import com.alibaba.intl.livevideocommons.models.RtpForwardingDestination;
import com.alibaba.intl.livevideocommons.models.RtpToRtmpTranscodingContext;
import com.alibaba.intl.livevideotranscoder.exceptions.NoAvailableTranscodingSourceException;
import com.alibaba.intl.livevideotranscoder.exceptions.TranscodingException;
import com.alibaba.intl.livevideotranscoder.models.PortReservation;
import com.alibaba.intl.livevideotranscoder.services.TranscodingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.task.TaskExecutor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.*;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.time.Duration;
import java.time.Instant;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Default implementation of {@link TranscodingService}.
 *
 * @author Alibaba Cloud
 */
@Service
public class TranscodingServiceImpl implements TranscodingService {

    private static final Logger LOGGER = LoggerFactory.getLogger(TranscodingServiceImpl.class);
    private final TaskExecutor taskExecutor;
    private final String ffmpegSdpFileFolderPath;
    private final String ffmpegExecutablePath;
    private final int rtpPortRangeStart;
    private final int rtpPortRangeEnd;
    private final long unusedPortTimeoutMillis;
    private int nextAvailablePort;
    private Map<Integer, PortReservation> reservationByPort = new HashMap<>();
    private final Map<String, RtpToRtmpTranscodingContext> transcodingContextById = new ConcurrentHashMap<>();

    public TranscodingServiceImpl(
            TaskExecutor ffmpegLauncherThreadPoolTaskExecutor,
            @Value("${transcoding.ffmpegSdpFileFolderPath}") String ffmpegSdpFileFolderPath,
            @Value("${transcoding.ffmpegExecutablePath}") String ffmpegExecutablePath,
            @Value("${transcoding.rtpPortRangeStart}") int rtpPortRangeStart,
            @Value("${transcoding.rtpPortRangeEnd}") int rtpPortRangeEnd,
            @Value("${transcoding.unusedPortTimeoutMillis}") long unusedPortTimeoutMillis) {
        this.taskExecutor = ffmpegLauncherThreadPoolTaskExecutor;
        this.ffmpegSdpFileFolderPath = ffmpegSdpFileFolderPath;
        this.ffmpegExecutablePath = ffmpegExecutablePath;
        this.rtpPortRangeStart = rtpPortRangeStart;
        this.rtpPortRangeEnd = rtpPortRangeEnd;
        this.unusedPortTimeoutMillis = unusedPortTimeoutMillis;

        nextAvailablePort = rtpPortRangeStart;
    }

    @Override
    public RtpForwardingDestination getNewRtpForwardingDestination(String id) throws NoAvailableTranscodingSourceException {
        int audioPort = reserveNextAvailablePortPair(id);
        if (audioPort == -1) {
            throw new NoAvailableTranscodingSourceException("No port available for audio.");
        }

        int videoPort = reserveNextAvailablePortPair(id);
        if (videoPort == -1) {
            throw new NoAvailableTranscodingSourceException("No port available for video.");
        }

        String ipAddress;
        try {
            InetAddress inetAddress = InetAddress.getLocalHost();
            ipAddress = inetAddress.getHostAddress();
        } catch (UnknownHostException e) {
            throw new NoAvailableTranscodingSourceException("Unable to get the local IP address.", e);
        }

        return new RtpForwardingDestination(id, ipAddress, audioPort, videoPort);
    }

    @Override
    public void startTranscoding(RtpToRtmpTranscodingContext context) throws TranscodingException {
        // Save the SDP into a file
        String sdpFilePath = ffmpegSdpFileFolderPath + "/" + context.getId() + ".sdp";
        LOGGER.info("Copy the SDP data into the file: {}", sdpFilePath);
        try (FileOutputStream outputStream = new FileOutputStream(sdpFilePath)) {
            outputStream.write(context.getSdp().getBytes());
        } catch (IOException e) {
            throw new TranscodingException("Unable to create the file " + sdpFilePath + ".", e);
        }

        // Start FFMPEG
        taskExecutor.execute(() -> {
            LOGGER.info("Execute FFMPEG (id = {}).", context.getId());
            transcodingContextById.put(context.getId(), context);

            try {
                Process process = new ProcessBuilder(
                        ffmpegExecutablePath,
                        "-protocol_whitelist", "file,udp,rtp",
                        "-i", sdpFilePath,
                        "-vcodec", "libx264",
                        "-preset", "veryfast",
                        "-profile:v", "baseline",
                        "-level", "3.0",
                        "-max_muxing_queue_size", "2048",
                        "-f", "flv",
                        context.getRtmpUrl()).start();

                taskExecutor.execute(new ProcessStreamPrinter(process.getInputStream(), "ffmpeg[" + context.getId() + "]"));
                taskExecutor.execute(new ProcessStreamPrinter(process.getErrorStream(), "ffmpeg[" + context.getId() + "]"));
                process.waitFor();
            } catch (Throwable t) {
                LOGGER.warn("An error occurred when executing FFMPEG.", t);
            }

            transcodingContextById.remove(context.getId());
            LOGGER.info("FFMPEG process terminated (id = {}).", context.getId());
        });
    }

    @Override
    public List<RtpToRtmpTranscodingContext> getRunningTranscodingContexts() {
        return transcodingContextById.entrySet().stream()
                .sorted(Comparator.comparing(Map.Entry::getKey))
                .map(Map.Entry::getValue)
                .collect(Collectors.toList());
    }

    @Scheduled(fixedRate = 500)
    public void unreservePortsIfNecessary() {
        int nbReservationsRemoved = unreservePortsAfterTimeout();
        if (nbReservationsRemoved > 0) {
            LOGGER.info("{} port(s) have been removed from the reservations.", nbReservationsRemoved);
        }
    }

    /**
     * Reserve two consecutive unused ports.
     *
     * @param id Unique ID for the transcoding context.
     * @return First reserved port (just add +1 to get the second port). -1 if no port is available.
     */
    private synchronized int reserveNextAvailablePortPair(String id) {
        int pairRange = (rtpPortRangeEnd - rtpPortRangeStart) / 2;
        for (int i = 0; i < pairRange; i++) {
            int candidatePort = nextAvailablePort;
            nextAvailablePort = (((nextAvailablePort - rtpPortRangeStart) / 2 + 1) % pairRange) * 2 + rtpPortRangeStart;

            if (!reservationByPort.containsKey(candidatePort)) {
                reservationByPort.put(candidatePort, new PortReservation(id, candidatePort, Instant.now()));
                return candidatePort;
            }
        }
        return -1;
    }

    /**
     * Remove the port reservations when they haven't been used for a long time.
     *
     * @return Number of unreserved ports.
     */
    private synchronized int unreservePortsAfterTimeout() {
        int nbReservationsBefore = reservationByPort.size();

        reservationByPort.entrySet().removeIf(entry -> {
            PortReservation reservation = entry.getValue();
            if (transcodingContextById.containsKey(reservation.getId())) {
                return false;
            }
            Duration duration = Duration.between(reservation.getReservationInstant(), Instant.now());
            return duration.toMillis() > unusedPortTimeoutMillis;
        });

        int nbReservationsAfter = reservationByPort.size();

        return nbReservationsBefore - nbReservationsAfter;
    }

    private static class ProcessStreamPrinter implements Runnable {

        private final InputStream inputStream;
        private final String name;

        private ProcessStreamPrinter(InputStream inputStream, String name) {
            this.inputStream = inputStream;
            this.name = name;
        }

        @Override
        public void run() {
            try (inputStream;
                 InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                 BufferedReader inputReader = new BufferedReader(inputStreamReader)) {

                String inputLine;

                while ((inputLine = inputReader.readLine()) != null) {
                    LOGGER.info("{}: {}", name, inputLine);
                }
            } catch (IOException e) {
                LOGGER.warn(name + ": Unable to read the process stream: " + e.getMessage(), e);
            }
        }
    }
}
