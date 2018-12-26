package com.alibaba.intl.livevideo.services;

import com.alibaba.intl.livevideo.models.WebrtcConfiguration;

/**
 * WebRTC support.
 *
 * @author Alibaba Cloud
 */
public interface WebrtcService {

    /**
     * @return Configuration for the client to establish a WebRTC connection.
     */
    WebrtcConfiguration getConfiguration();

}
