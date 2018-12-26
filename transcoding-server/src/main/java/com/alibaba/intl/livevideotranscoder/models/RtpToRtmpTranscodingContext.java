package com.alibaba.intl.livevideotranscoder.models;

/**
 * Information necessary for a transcoding operation from RTP to RTMP.
 *
 * @author Alibaba Cloud
 */
public class RtpToRtmpTranscodingContext {

    /**
     * Unique ID for this context.
     */
    private String id;

    /**
     * Session Description Protocol that contains the information about the source RTP stream.
     */
    private String sdp;

    /**
     * URL where to send the RTMP stream.
     */
    private String rtmpUrl;

    public RtpToRtmpTranscodingContext() {
    }

    public RtpToRtmpTranscodingContext(String id, String sdp, String rtmpUrl) {
        this.id = id;
        this.sdp = sdp;
        this.rtmpUrl = rtmpUrl;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSdp() {
        return sdp;
    }

    public void setSdp(String sdp) {
        this.sdp = sdp;
    }

    public String getRtmpUrl() {
        return rtmpUrl;
    }

    public void setRtmpUrl(String rtmpUrl) {
        this.rtmpUrl = rtmpUrl;
    }

    @Override
    public String toString() {
        return "RtpToRtmpTranscodingContext{" +
                "id='" + id + '\'' +
                ", sdp='" + sdp + '\'' +
                ", rtmpUrl='" + rtmpUrl + '\'' +
                '}';
    }
}
