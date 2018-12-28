package com.alibaba.intl.livevideo.controllers;

import com.alibaba.intl.livevideo.TranscodeStreamException;
import com.alibaba.intl.livevideo.models.RtpForwardingDestination;
import com.alibaba.intl.livevideo.services.StreamService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Allow the frontend to find existing streams and to create new ones.
 *
 * @author Alibaba Cloud
 */
@RestController
public class StreamController {

    private final StreamService streamService;

    public StreamController(StreamService streamService) {
        this.streamService = streamService;
    }

    /**
     * @return Stream names managed by Apsara Video Live.
     */
    @RequestMapping("/streams")
    public List<String> findAllStreamNames() {
        return streamService.findAllStreamNames();
    }

    /**
     * Provide the destination where Janus can forward the RTP data.
     *
     * @param name Stream name.
     * @return Destination information.
     */
    @RequestMapping("/streams/{name}/forwarding-destination")
    public RtpForwardingDestination getRtpForwardingDestination(@PathVariable String name) {
        return streamService.getRtpForwardingDestination(name);
    }

    /**
     * Start transcoding the RTP data from Janus to Apsara Video Live via RTMP.
     *
     * @param name                  Stream name.
     * @param webrtcSdp             SDP file that describes the RTP stream between the web browser and Janus.
     * @param forwardingDestination Destination where Janus send its RTP data.
     * @return Success or error message.
     */
    @RequestMapping(value = "/streams/{name}/transcode", method = RequestMethod.POST)
    public ResponseEntity<String> transcodeStream(
            @PathVariable String name,
            @RequestPart("webrtcSdp") String webrtcSdp,
            @RequestPart("forwardingDestination") RtpForwardingDestination forwardingDestination) {
        try {
            streamService.transcodeStream(name, webrtcSdp, forwardingDestination);
        } catch (TranscodeStreamException e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Unable to transcode the stream " + name + ": " + e.getMessage());
        }
        return ResponseEntity.ok("Success");
    }
}
