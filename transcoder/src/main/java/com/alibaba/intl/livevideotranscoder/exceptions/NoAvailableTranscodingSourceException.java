package com.alibaba.intl.livevideotranscoder.exceptions;

/**
 * Exception thrown when there is no available port for RTP data or when the IP address cannot be found.
 *
 * @author Alibaba Cloud
 */
public class NoAvailableTranscodingSourceException extends Exception {

    public NoAvailableTranscodingSourceException(String message) {
        super(message);
    }

    public NoAvailableTranscodingSourceException(String message, Throwable cause) {
        super(message, cause);
    }
}
