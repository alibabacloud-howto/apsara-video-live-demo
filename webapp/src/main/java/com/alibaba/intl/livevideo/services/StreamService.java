package com.alibaba.intl.livevideo.services;

import com.alibaba.intl.livevideo.exceptions.RtpForwardingDestinationException;
import com.alibaba.intl.livevideo.exceptions.TranscodeStreamException;
import com.alibaba.intl.livevideocommons.models.RtpForwardingDestination;

import java.util.List;

/**
 * Handle communication with Apsara Video Live SDK and the transcoder.
 *
 * @author Alibaba Cloud
 */
public interface StreamService {

    /**
     * @return Existing stream names currently managed by Apsara Video Live.
     */
    List<String> findAllStreamNames();

    /**
     * @return Destination where Janus can forward the RTP data.
     */
    RtpForwardingDestination getRtpForwardingDestination(String streamName) throws RtpForwardingDestinationException;

    /**
     * Start transcoding the RTP data from Janus to Apsara Video Live via RTMP.
     *
     * @param webrtcSdp             SDP file that describes the RTP stream between the web browser and Janus.
     * @param forwardingDestination Destination where Janus send its RTP data.
     */
    void transcodeStream(String webrtcSdp, RtpForwardingDestination forwardingDestination)
            throws TranscodeStreamException;

    /**
     * @return URL where users can play the stream.
     */
    String getStreamPullUrl(String streamName);
}
