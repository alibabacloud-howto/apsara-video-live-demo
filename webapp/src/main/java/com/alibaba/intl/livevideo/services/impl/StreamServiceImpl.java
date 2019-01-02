package com.alibaba.intl.livevideo.services.impl;

import com.alibaba.intl.livevideo.exceptions.RtpForwardingDestinationException;
import com.alibaba.intl.livevideo.exceptions.TranscodeStreamException;
import com.alibaba.intl.livevideo.models.Sdp;
import com.alibaba.intl.livevideo.services.StreamService;
import com.alibaba.intl.livevideocommons.models.RtpForwardingDestination;
import com.alibaba.intl.livevideocommons.models.RtpToRtmpTranscodingContext;
import com.aliyuncs.DefaultAcsClient;
import com.aliyuncs.exceptions.ClientException;
import com.aliyuncs.live.model.v20161101.DescribeLiveStreamsOnlineListRequest;
import com.aliyuncs.live.model.v20161101.DescribeLiveStreamsOnlineListResponse;
import com.aliyuncs.profile.DefaultProfile;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.xml.bind.DatatypeConverter;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Default implementation of {@link StreamService}.
 *
 * @author Alibaba Cloud
 */
@Service
public class StreamServiceImpl implements StreamService {

    private static final Logger LOGGER = LoggerFactory.getLogger(StreamServiceImpl.class);

    private final String avlAccessKeyId;
    private final String avlAccessKeySecret;
    private final String avlRegionId;
    private final String avlPullDomainName;
    private final String avlPushDomainName;
    private final String avlAppName;
    private final String avlPushAuthPrimaryKey;
    private final long avlPushAuthValidityPeriod;
    private final String avlPullAuthPrimaryKey;
    private final long avlPullAuthValidityPeriod;

    private final String transcoderHostname;
    private final int transcoderHttpPort;

    public StreamServiceImpl(
            @Value("${apsaraVideoLive.accessKeyId}") String avlAccessKeyId,
            @Value("${apsaraVideoLive.accessKeySecret}") String avlAccessKeySecret,
            @Value("${apsaraVideoLive.regionId}") String avlRegionId,
            @Value("${apsaraVideoLive.pullDomainName}") String avlPullDomainName,
            @Value("${apsaraVideoLive.pushDomainName}") String avlPushDomainName,
            @Value("${apsaraVideoLive.appName}") String avlAppName,
            @Value("${apsaraVideoLive.pushAuthPrimaryKey}") String avlPushAuthPrimaryKey,
            @Value("${apsaraVideoLive.pushAuthValidityPeriod}") long avlPushAuthValidityPeriod,
            @Value("${apsaraVideoLive.pullAuthPrimaryKey}") String avlPullAuthPrimaryKey,
            @Value("${apsaraVideoLive.pullAuthValidityPeriod}") long avlPullAuthValidityPeriod,
            @Value("${transcoder.hostname}") String transcoderHostname,
            @Value("${transcoder.httpPort}") int transcoderHttpPort) {
        this.avlAccessKeyId = avlAccessKeyId;
        this.avlAccessKeySecret = avlAccessKeySecret;
        this.avlRegionId = avlRegionId;
        this.avlPullDomainName = avlPullDomainName;
        this.avlPushDomainName = avlPushDomainName;
        this.avlAppName = avlAppName;
        this.avlPushAuthPrimaryKey = avlPushAuthPrimaryKey;
        this.avlPushAuthValidityPeriod = avlPushAuthValidityPeriod;
        this.avlPullAuthPrimaryKey = avlPullAuthPrimaryKey;
        this.avlPullAuthValidityPeriod = avlPullAuthValidityPeriod;

        this.transcoderHostname = transcoderHostname;
        this.transcoderHttpPort = transcoderHttpPort;
    }

    @Override
    public List<String> findAllStreamNames() {
        var profile = DefaultProfile.getProfile(avlRegionId, avlAccessKeyId, avlAccessKeySecret);
        var client = new DefaultAcsClient(profile);

        var request = new DescribeLiveStreamsOnlineListRequest();
        request.setDomainName(avlPullDomainName);
        request.setPageSize(50);
        try {
            var response = client.getAcsResponse(request);
            return response.getOnlineInfo().stream()
                    .map(DescribeLiveStreamsOnlineListResponse.LiveStreamOnlineInfo::getStreamName)
                    .collect(Collectors.toList());
        } catch (ClientException e) {
            throw new IllegalStateException("Unable to describe streams on Apsara Video Live.", e);
        }
    }

    @Override
    public RtpForwardingDestination getRtpForwardingDestination(String streamName) throws RtpForwardingDestinationException {
        String transcoderUrl = "http://" + transcoderHostname + ":" + transcoderHttpPort + "/transcodings/" +
                streamName + "/new-rtp-forwarding-destination";
        var restTemplate = new RestTemplate();
        var responseEntity = restTemplate.getForEntity(transcoderUrl, RtpForwardingDestination.class);

        if (responseEntity.getStatusCode() != HttpStatus.OK) {
            throw new RtpForwardingDestinationException(
                    "Unable to find a forwarding destination for the stream " + streamName + ".");
        }

        RtpForwardingDestination destination = responseEntity.getBody();
        LOGGER.info("Provide the following forwarding destination (stream name = {}): {}", streamName, destination);
        return destination;
    }

    @Override
    public void transcodeStream(String webrtcSdp, RtpForwardingDestination forwardingDestination)
            throws TranscodeStreamException {
        // Build the source SDP based on the one used for WebRTC
        Sdp sourceSdp = Sdp.fromRawSdp(webrtcSdp);
        sourceSdp.setAudioPort(forwardingDestination.getAudioPort());
        sourceSdp.setVideoPort(forwardingDestination.getVideoPort());

        // Build the RTMP URL
        String urlPath = "/" + avlAppName + "/" + forwardingDestination.getId();
        String authKey = generateAuthKey(urlPath, avlPushAuthPrimaryKey, avlPushAuthValidityPeriod);
        String rtmpUrl = "rtmp://" + avlPushDomainName + urlPath + "?auth_key=" + authKey;

        // Send the request to the transcoder server
        LOGGER.info("Transcode the stream {} from {} to {}.", forwardingDestination.getId(), forwardingDestination, rtmpUrl);
        var restTemplate = new RestTemplate();
        String transcoderUrl = "http://" + forwardingDestination.getIpAddress() + ":" + transcoderHttpPort + "/transcodings";
        var context = new RtpToRtmpTranscodingContext(forwardingDestination.getId(), sourceSdp.toRawSdp(), rtmpUrl);
        var responseEntity = restTemplate.postForEntity(transcoderUrl, context, String.class);
        if (responseEntity.getStatusCode() != HttpStatus.OK) {
            throw new TranscodeStreamException(responseEntity.getBody());
        }
    }

    @Override
    public String getStreamPullUrl(String streamName) {
        String urlPath = "/" + avlAppName + "/" + streamName + ".flv";
        String authKey = generateAuthKey(urlPath, avlPullAuthPrimaryKey, avlPullAuthValidityPeriod);
        return "http://" + avlPullDomainName + urlPath + "?auth_key=" + authKey;
    }

    /**
     * Generate an "auth_key" according to this document: https://www.alibabacloud.com/help/doc-detail/85018.htm
     *
     * @param urlPath        Part of the URL after the domain name (e.g. "/appName/streamName").
     * @param primaryKey     URL authentication primary key (found in the access control menu in the Apsara Video Live console).
     * @param validityPeriod URL validity in seconds (found in the access control menu in the Apsara Video Live console).
     * @return Generated "auth_key".
     */
    private String generateAuthKey(String urlPath, String primaryKey, long validityPeriod) {
        long validtyTimestamp = System.currentTimeMillis() / 1000 + validityPeriod;
        String authKeyHashSource = urlPath + "-" + validtyTimestamp + "-0-0-" + primaryKey;
        String authKeyHash = DatatypeConverter.printHexBinary(getMd5Digest(authKeyHashSource)).toLowerCase();
        return validtyTimestamp + "-0-0-" + authKeyHash;
    }

    private byte[] getMd5Digest(String value) {
        MessageDigest messageDigest;
        try {
            messageDigest = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("Unable to find the MD5 hash algorithm.", e);
        }

        messageDigest.update(value.getBytes());
        return messageDigest.digest();
    }
}
