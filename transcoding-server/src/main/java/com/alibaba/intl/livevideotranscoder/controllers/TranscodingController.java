package com.alibaba.intl.livevideotranscoder.controllers;

import com.alibaba.intl.livevideotranscoder.exceptions.TranscodingException;
import com.alibaba.intl.livevideotranscoder.models.RtpToRtmpTranscodingContext;
import com.alibaba.intl.livevideotranscoder.services.TranscodingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for transcoding operations.
 *
 * @author Alibaba Cloud
 */
@RestController
public class TranscodingController {

    private static final Logger LOGGER = LoggerFactory.getLogger(TranscodingController.class);
    private final TranscodingService transcodingService;

    public TranscodingController(TranscodingService transcodingService) {
        this.transcodingService = transcodingService;
    }

    /**
     * Start transcoding a video stream from RTP to RTMP.
     *
     * @return Success or error message.
     */
    @RequestMapping(value = "/transcodings/{id}", method = RequestMethod.PUT)
    public ResponseEntity<String> startTranscodingRtpToRtmp(@PathVariable String id, @RequestBody RtpToRtmpTranscodingContext context) {
        context.setId(id);
        LOGGER.info("Handle transcoding request: {}", context);

        try {
            transcodingService.startTranscoding(context);
            return ResponseEntity.ok("Transcoding started.");
        } catch (TranscodingException e) {
            LOGGER.error("Unable to start transcoding.", e);
            return ResponseEntity.badRequest().body("Unable to start transcoding: " + e.getMessage());
        }
    }

    /**
     * @return IDs of running transcoding processes.
     */
    @RequestMapping("/rtp-to-rtmp-transcodings")
    public List<RtpToRtmpTranscodingContext> getRunningTranscodingContexts() {
        return transcodingService.getRunningTranscodingContexts();
    }
}
