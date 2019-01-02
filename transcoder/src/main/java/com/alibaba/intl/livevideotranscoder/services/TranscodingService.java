package com.alibaba.intl.livevideotranscoder.services;

import com.alibaba.intl.livevideocommons.models.RtpForwardingDestination;
import com.alibaba.intl.livevideocommons.models.RtpToRtmpTranscodingContext;
import com.alibaba.intl.livevideotranscoder.exceptions.NoAvailableTranscodingSourceException;
import com.alibaba.intl.livevideotranscoder.exceptions.TranscodingException;

import java.util.List;

/**
 * Handle transcoding operations.
 *
 * @author Alibaba Cloud
 */
public interface TranscodingService {

    /**
     * Provide an IP address and ports where to send audio and video data via RTP. This method should be called before
     * {@link #startTranscoding(RtpToRtmpTranscodingContext)}.
     * <p>
     * Please note that the provided ports are calculated within specific ranges configured in the
     * "application.properties" file.
     * </p>
     * <p>
     * The ports are also "reserved" for a certain period of time, so another call to this method will receive new ports.
     * </p>
     * <p>
     * Finally ports in use will also be not available.
     * </p>
     *
     * @param id Unique ID for the context. This ID must be the same as the one provided to the
     *           {@link #startTranscoding(RtpToRtmpTranscodingContext)} function.
     * @return Destination where the WebRTC gateway can send RTP data, or an error code if no port is available.
     * @throws NoAvailableTranscodingSourceException Exception thrown when there is no available port for transcoding.
     */
    RtpForwardingDestination getNewRtpForwardingDestination(String id) throws NoAvailableTranscodingSourceException;

    /**
     * Start transcoding a video stream from RTP to RTMP.
     */
    void startTranscoding(RtpToRtmpTranscodingContext context) throws TranscodingException;

    /**
     * @return Contexts of running transcoding processes.
     */
    List<RtpToRtmpTranscodingContext> getRunningTranscodingContexts();
}
