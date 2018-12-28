package com.alibaba.intl.livevideo.models;

/**
 * Destination where Janus can forward RTP data.
 *
 * @author Alibaba Cloud
 */
public class RtpForwardingDestination {

    private String hostname;
    private int audioPort;
    private int videoPort;

    public RtpForwardingDestination() {
    }

    public RtpForwardingDestination(String hostname, int audioPort, int videoPort) {
        this.hostname = hostname;
        this.audioPort = audioPort;
        this.videoPort = videoPort;
    }

    public String getHostname() {
        return hostname;
    }

    public void setHostname(String hostname) {
        this.hostname = hostname;
    }

    public int getAudioPort() {
        return audioPort;
    }

    public void setAudioPort(int audioPort) {
        this.audioPort = audioPort;
    }

    public int getVideoPort() {
        return videoPort;
    }

    public void setVideoPort(int videoPort) {
        this.videoPort = videoPort;
    }

    @Override
    public String toString() {
        return "RtpForwardingDestination{" +
                "hostname='" + hostname + '\'' +
                ", audioPort=" + audioPort +
                ", videoPort=" + videoPort +
                '}';
    }
}
