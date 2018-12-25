package com.alibaba.intl.livevideotranscoder.controllers;

import com.alibaba.intl.livevideotranscoder.exceptions.TranscodingException;
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
     * Start transcoding a video stream from RTP to Apsara Video Live.
     *
     * @param id  Unique ID for this stream.
     * @param sdp Descriptor for the source stream in RTP format.
     * @return Success or error message.
     */
    @RequestMapping(value = "/rtp-to-avl-transcodings/{id}/start", method = RequestMethod.POST)
    public ResponseEntity<String> startTranscodingRtpToAvl(@PathVariable String id, @RequestBody String sdp) {
        LOGGER.info("Handle transcoding request (id = {}): {}", id, sdp);

        try {
            transcodingService.startTranscodingRtpToAvl(id, sdp);
            return ResponseEntity.ok("Transcoding started.");
        } catch (TranscodingException e) {
            LOGGER.error("Unable to start transcoding.", e);
            return ResponseEntity.badRequest().body("Unable to start transcoding: " + e.getMessage());
        }
    }

    @RequestMapping("/rtp-to-avl-transcodings")
    public List<String> getRunningTranscodingIds() {
        return transcodingService.getRunningTranscodingIds();
    }
}
