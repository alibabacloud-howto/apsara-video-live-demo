package com.alibaba.intl.livevideotranscoder.services.impl;

import com.alibaba.intl.livevideotranscoder.exceptions.TranscodingException;
import com.alibaba.intl.livevideotranscoder.models.RtpToRtmpTranscodingContext;
import com.alibaba.intl.livevideotranscoder.services.TranscodingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.task.TaskExecutor;
import org.springframework.stereotype.Service;

import java.io.*;
import java.util.Comparator;
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
    private final Map<String, RtpToRtmpTranscodingContext> transcodingContextById = new ConcurrentHashMap<>();
    private final String ffmpegSdpFileFolderPath;
    private final String ffmpegExecutablePath;

    public TranscodingServiceImpl(
            TaskExecutor ffmpegLauncherThreadPoolTaskExecutor,
            @Value("${transcoding.ffmpegSdpFileFolderPath}") String ffmpegSdpFileFolderPath,
            @Value("${transcoding.ffmpegExecutablePath}") String ffmpegExecutablePath) {
        this.taskExecutor = ffmpegLauncherThreadPoolTaskExecutor;
        this.ffmpegSdpFileFolderPath = ffmpegSdpFileFolderPath;
        this.ffmpegExecutablePath = ffmpegExecutablePath;
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
                        "-protocol_whitelist \"file,udp,rtp\"",
                        "-i " + sdpFilePath,
                        "-vcodec libx264",
                        "-preset veryfast",
                        "-profile:v baseline -level 3.0",
                        "-max_muxing_queue_size 2048",
                        "-f flv",
                        context.getRtmpUrl()).start();

                try (InputStream inputStream = process.getInputStream();
                     InputStream errorStream = process.getErrorStream();
                     InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                     InputStreamReader errorStreamReader = new InputStreamReader(errorStream);
                     BufferedReader inputReader = new BufferedReader(inputStreamReader);
                     BufferedReader errorReader = new BufferedReader(errorStreamReader)) {

                    String inputLine;
                    String errorLine = null;

                    while ((inputLine = inputReader.readLine()) != null || (errorLine = errorReader.readLine()) != null) {
                        if (inputLine != null) {
                            LOGGER.info("ffmpeg[info ]: " + inputLine);
                        }
                        if (errorLine != null) {
                            LOGGER.info("ffmpeg[error]: " + errorLine);
                        }
                    }
                }
            } catch (Throwable t) {
                LOGGER.error("An error occurred when executing FFMPEG.", t);
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
}
