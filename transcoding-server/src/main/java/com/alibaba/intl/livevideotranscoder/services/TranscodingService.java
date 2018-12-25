package com.alibaba.intl.livevideotranscoder.services;

import com.alibaba.intl.livevideotranscoder.exceptions.TranscodingException;

import java.util.List;

/**
 * Handle transcoding operations.
 *
 * @author Alibaba Cloud
 */
public interface TranscodingService {

    /**
     * Start transcoding a video stream from RTP to Apsara Video Live.
     *
     * @param id  Unique ID for this stream.
     * @param sdp Descriptor for the source stream in RTP format.
     */
    void startTranscodingRtpToAvl(String id, String sdp) throws TranscodingException;

    /**
     * @return IDs of running transcoding processes.
     */
    List<String> getRunningTranscodingIds();
}
