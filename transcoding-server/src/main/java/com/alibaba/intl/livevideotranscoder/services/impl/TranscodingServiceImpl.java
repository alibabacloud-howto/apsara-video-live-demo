package com.alibaba.intl.livevideotranscoder.services.impl;

import com.alibaba.intl.livevideotranscoder.exceptions.TranscodingException;
import com.alibaba.intl.livevideotranscoder.services.TranscodingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.task.TaskExecutor;
import org.springframework.stereotype.Service;

import java.io.*;
import java.util.List;
import java.util.Set;
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
    private final Set<String> transcodingIds = ConcurrentHashMap.newKeySet();
    private final String ffmpegSdpFileFolderPath;
    private final boolean apsaraVideoUseEdgeStreaming;
    private final String apsaraVideoEdgeStreamingPushDomainName;
    private final String apsaraVideoCentralServerDomainName;
    private final String apsaraVideoCentralStreamingDomainName;
    private final String apsaraVideoAppName;
    private final String ffmpegPath;

    public TranscodingServiceImpl(
            TaskExecutor ffmpegLauncherThreadPoolTaskExecutor,
            @Value("${transcoding.ffmpegSdpFileFolderPath}") String ffmpegSdpFileFolderPath,
            @Value("${transcoding.apsaraVideoUseEdgeStreaming}") boolean apsaraVideoUseEdgeStreaming,
            @Value("${transcoding.apsaraVideoEdgeStreamingPushDomainName}") String apsaraVideoEdgeStreamingPushDomainName,
            @Value("${transcoding.apsaraVideoCentralServerDomainName}") String apsaraVideoCentralServerDomainName,
            @Value("${transcoding.apsaraVideoCentralStreamingDomainName}") String apsaraVideoCentralStreamingDomainName,
            @Value("${transcoding.apsaraVideoAppName}") String apsaraVideoAppName,
            @Value("${transcoding.ffmpegPath}") String ffmpegPath) {
        this.taskExecutor = ffmpegLauncherThreadPoolTaskExecutor;
        this.ffmpegSdpFileFolderPath = ffmpegSdpFileFolderPath;
        this.apsaraVideoUseEdgeStreaming = apsaraVideoUseEdgeStreaming;
        this.apsaraVideoEdgeStreamingPushDomainName = apsaraVideoEdgeStreamingPushDomainName;
        this.apsaraVideoCentralServerDomainName = apsaraVideoCentralServerDomainName;
        this.apsaraVideoCentralStreamingDomainName = apsaraVideoCentralStreamingDomainName;
        this.apsaraVideoAppName = apsaraVideoAppName;
        this.ffmpegPath = ffmpegPath;
    }

    @Override
    public void startTranscodingRtpToAvl(String id, String sdp) throws TranscodingException {
        // Save the SDP into a file
        String sdpFilePath = ffmpegSdpFileFolderPath + "/" + id + ".sdp";
        LOGGER.info("Copy the SDP data into the file: {}", sdpFilePath);
        try (FileOutputStream outputStream = new FileOutputStream(sdpFilePath)) {
            outputStream.write(sdp.getBytes());
        } catch (IOException e) {
            throw new TranscodingException("Unable to create the file " + sdpFilePath + ".", e);
        }

        // Prepare the destination URL
        String rtmpUrl;
        if (apsaraVideoUseEdgeStreaming) {
            rtmpUrl = "rtmp://" + apsaraVideoEdgeStreamingPushDomainName + "/" + apsaraVideoAppName + "/" + id;
        } else {
            rtmpUrl = "rtmp://" + apsaraVideoCentralServerDomainName + "/" + apsaraVideoAppName + "/" + id +
                    "?vhost=" + apsaraVideoCentralStreamingDomainName;
        }
        LOGGER.info("Send the video stream to: {}", rtmpUrl);

        // Start FFMPEG
        taskExecutor.execute(() -> {
            LOGGER.info("Execute FFMPEG (id = {}).", id);
            transcodingIds.add(id);

            try {
                Process process = new ProcessBuilder(
                        ffmpegPath,
                        "-protocol_whitelist \"file,udp,rtp\"",
                        "-i " + sdpFilePath,
                        "-vcodec libx264",
                        "-preset veryfast",
                        "-profile:v baseline -level 3.0",
                        "-max_muxing_queue_size 2048",
                        "-f flv").start();

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

            transcodingIds.remove(id);
            LOGGER.info("FFMPEG process terminated (id = {}).", id);
        });
    }

    @Override
    public List<String> getRunningTranscodingIds() {
        return transcodingIds.stream()
                .sorted()
                .collect(Collectors.toList());
    }
}
