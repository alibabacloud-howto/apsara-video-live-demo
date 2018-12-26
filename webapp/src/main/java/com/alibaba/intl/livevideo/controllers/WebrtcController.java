package com.alibaba.intl.livevideo.controllers;

import com.alibaba.intl.livevideo.models.WebrtcConfiguration;
import com.alibaba.intl.livevideo.services.WebrtcService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * WebRTC support.
 *
 * @author Alibaba Cloud
 */
@RestController
public class WebrtcController {

    private final WebrtcService webrtcService;

    public WebrtcController(WebrtcService webrtcService) {
        this.webrtcService = webrtcService;
    }

    @RequestMapping("/webrtc-configuration")
    WebrtcConfiguration getConfiguration() {
        return webrtcService.getConfiguration();
    }
}
