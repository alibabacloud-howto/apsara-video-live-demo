package com.alibaba.intl.livevideotranscoder.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST controller for transcoding operations.
 *
 * @author Alibaba Cloud
 */
@RestController
public class TranscodingController {

    @RequestMapping(value = "/transcoding/start", method = RequestMethod.POST)
    public HttpStatus start() {
        // TODO
        return HttpStatus.OK;
    }

}
