package com.alibaba.intl.livevideo.exceptions;

/**
 * Exception thrown when it is not possible to get a forwarding destination.
 *
 * @author Alibaba Cloud
 */
public class RtpForwardingDestinationException extends Exception {

    public RtpForwardingDestinationException(String message) {
        super(message);
    }

    public RtpForwardingDestinationException(String message, Throwable cause) {
        super(message, cause);
    }
}
