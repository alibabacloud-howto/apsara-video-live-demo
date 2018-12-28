package com.alibaba.intl.livevideotranscoder.exceptions;

/**
 * Exception thrown if there is a problem during transcoding.
 *
 * @author Alibaba Cloud
 */
public class TranscodingException extends Exception {

    public TranscodingException(String message) {
        super(message);
    }

    public TranscodingException(String message, Throwable cause) {
        super(message, cause);
    }
}
