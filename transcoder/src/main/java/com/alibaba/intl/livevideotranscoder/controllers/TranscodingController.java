package com.alibaba.intl.livevideotranscoder.controllers;

import com.alibaba.intl.livevideocommons.models.RtpForwardingDestination;
import com.alibaba.intl.livevideocommons.models.RtpToRtmpTranscodingContext;
import com.alibaba.intl.livevideotranscoder.exceptions.NoAvailableTranscodingSourceException;
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
     * Provide an IP address and ports where to send audio and video data via RTP. This method should be called before
     * {@link #startTranscodingRtpToRtmp(RtpToRtmpTranscodingContext)}.
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
     *           {@link #startTranscodingRtpToRtmp(RtpToRtmpTranscodingContext)} function.
     * @return Destination where the WebRTC gateway can send RTP data, or an error code if no port is available.
     */
    @RequestMapping("/transcodings/{id}/new-rtp-forwarding-destination")
    public ResponseEntity<RtpForwardingDestination> getNewRtpForwardingDestination(@PathVariable String id) {
        try {
            RtpForwardingDestination source = transcodingService.getNewRtpForwardingDestination(id);
            return ResponseEntity.ok(source);
        } catch (NoAvailableTranscodingSourceException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    /**
     * Start transcoding a video stream from RTP to RTMP.
     *
     * @return Success or error message.
     */
    @RequestMapping(value = "/transcodings", method = RequestMethod.POST)
    public ResponseEntity<String> startTranscodingRtpToRtmp(@RequestBody RtpToRtmpTranscodingContext context) {
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
    @RequestMapping("/transcodings")
    public List<RtpToRtmpTranscodingContext> getRunningTranscodingContexts() {
        return transcodingService.getRunningTranscodingContexts();
    }
}
