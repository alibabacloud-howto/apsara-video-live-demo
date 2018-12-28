package com.alibaba.intl.livevideo;

/**
 * Exception thrown in case an error occurs when trying to transcode a stream.
 *
 * @author Alibaba Cloud
 */
public class TranscodeStreamException extends Exception {

    public TranscodeStreamException(String message) {
        super(message);
    }

    public TranscodeStreamException(String message, Throwable cause) {
        super(message, cause);
    }
}
