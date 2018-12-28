package com.alibaba.intl.livevideo.controllers;

import com.alibaba.intl.livevideo.models.Configuration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Provide some configuration for the frontend-side.
 *
 * @author Alibaba Cloud
 */
@RestController
public class ConfigurationController {

    private final String janusHostname;
    private final String janusHttpPort;
    private final String janusHttpsPort;
    private final String janusHttpPath;
    private final String turnServerUrl;
    private final String turnServerUsername;
    private final String turnServerPassword;

    public ConfigurationController(@Value("${janus.hostname}") String janusHostname,
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

    @RequestMapping("/configuration")
    Configuration getConfiguration() {
        return new Configuration(
                janusHostname,
                janusHttpPort,
                janusHttpsPort,
                janusHttpPath,
                turnServerUrl,
                turnServerUsername,
                turnServerPassword);
    }
}
