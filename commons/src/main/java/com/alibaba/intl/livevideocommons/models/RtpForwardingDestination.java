package com.alibaba.intl.livevideocommons.models;

/**
 * IP address and ports where to send audio and video data via RTP. This is useful for the WebRTC gateway
 * so that it "knows" where to send the stream to be transcoded.
 *
 * @author Alibaba Cloud
 */
public class RtpForwardingDestination {

    /**
     * Unique ID for the transcoding context. It has no technical use, it is just there to correlate messages.
     */
    private String id;

    /**
     * IP address of the server where to send the audio and video data.
     */
    private String ipAddress;

    /**
     * Port where to send audio data.
     */
    private int audioPort;

    /**
     * Port where to send video data.
     */
    private int videoPort;

    public RtpForwardingDestination() {
    }

    public RtpForwardingDestination(String id, String ipAddress, int audioPort, int videoPort) {
        this.id = id;
        this.ipAddress = ipAddress;
        this.audioPort = audioPort;
        this.videoPort = videoPort;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
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
                "id='" + id + '\'' +
                ", ipAddress='" + ipAddress + '\'' +
                ", audioPort=" + audioPort +
                ", videoPort=" + videoPort +
                '}';
    }
}
