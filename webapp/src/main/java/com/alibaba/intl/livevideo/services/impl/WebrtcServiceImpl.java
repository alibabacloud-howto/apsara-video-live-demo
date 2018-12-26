package com.alibaba.intl.livevideo.services.impl;

import com.alibaba.intl.livevideo.models.WebrtcConfiguration;
import com.alibaba.intl.livevideo.services.WebrtcService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Default implementation of {@link WebrtcService}.
 *
 * @author Alibaba Cloud
 */
@Service
public class WebrtcServiceImpl implements WebrtcService {

    private final String janusHostname;
    private final String janusHttpPort;
    private final String janusHttpsPort;
    private final String janusHttpPath;
    private final String turnServerUrl;
    private final String turnServerUsername;
    private final String turnServerPassword;

    public WebrtcServiceImpl(@Value("${janus.hostname}") String janusHostname,
                             @Value("${janus.httpPort}") String janusHttpPort,
                             @Value("${janus.httpsPort}") String janusHttpsPort,
                             @Value("${janus.httpPath}") String janusHttpPath,
                             @Value("${turnServer.url}") String turnServerUrl,
                             @Value("${turnServer.username}") String turnServerUsername,
                             @Value("${turnServer.password}") String turnServerPassword) {
        this.janusHostname = janusHostname;
        this.janusHttpPort = janusHttpPort;
        this.janusHttpsPort = janusHttpsPort;
        this.janusHttpPath = janusHttpPath;
        this.turnServerUrl = turnServerUrl;
        this.turnServerUsername = turnServerUsername;
        this.turnServerPassword = turnServerPassword;
    }

    @Override
    public WebrtcConfiguration getConfiguration() {
        return new WebrtcConfiguration(
                janusHostname,
                janusHttpPort,
                janusHttpsPort,
                janusHttpPath,
                turnServerUrl,
                turnServerUsername,
                turnServerPassword);
    }
}
