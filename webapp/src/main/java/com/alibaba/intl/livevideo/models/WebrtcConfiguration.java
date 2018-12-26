package com.alibaba.intl.livevideo.models;

/**
 * Configuration of the WebRTC gateway and TURN/STUN server.
 *
 * @author Alibaba Cloud
 */
public class WebrtcConfiguration {
    private String janusHostname;
    private String janusHttpPort;
    private String janusHttpsPort;
    private String janusHttpPath;
    private String turnServerUrl;
    private String turnServerUsername;
    private String turnServerPassword;

    public WebrtcConfiguration() {
    }

    public WebrtcConfiguration(String janusHostname, String janusHttpPort, String janusHttpsPort, String janusHttpPath,
                               String turnServerUrl, String turnServerUsername, String turnServerPassword) {
        this.janusHostname = janusHostname;
        this.janusHttpPort = janusHttpPort;
        this.janusHttpsPort = janusHttpsPort;
        this.janusHttpPath = janusHttpPath;
        this.turnServerUrl = turnServerUrl;
        this.turnServerUsername = turnServerUsername;
        this.turnServerPassword = turnServerPassword;
    }

    public String getJanusHostname() {
        return janusHostname;
    }

    public void setJanusHostname(String janusHostname) {
        this.janusHostname = janusHostname;
    }

    public String getJanusHttpPort() {
        return janusHttpPort;
    }

    public void setJanusHttpPort(String janusHttpPort) {
        this.janusHttpPort = janusHttpPort;
    }

    public String getJanusHttpsPort() {
        return janusHttpsPort;
    }

    public void setJanusHttpsPort(String janusHttpsPort) {
        this.janusHttpsPort = janusHttpsPort;
    }

    public String getJanusHttpPath() {
        return janusHttpPath;
    }

    public void setJanusHttpPath(String janusHttpPath) {
        this.janusHttpPath = janusHttpPath;
    }

    public String getTurnServerUrl() {
        return turnServerUrl;
    }

    public void setTurnServerUrl(String turnServerUrl) {
        this.turnServerUrl = turnServerUrl;
    }

    public String getTurnServerUsername() {
        return turnServerUsername;
    }

    public void setTurnServerUsername(String turnServerUsername) {
        this.turnServerUsername = turnServerUsername;
    }

    public String getTurnServerPassword() {
        return turnServerPassword;
    }

    public void setTurnServerPassword(String turnServerPassword) {
        this.turnServerPassword = turnServerPassword;
    }

    @Override
    public String toString() {
        return "WebrtcConfiguration{" +
                "janusHostname='" + janusHostname + '\'' +
                ", janusHttpPort='" + janusHttpPort + '\'' +
                ", janusHttpsPort='" + janusHttpsPort + '\'' +
                ", janusHttpPath='" + janusHttpPath + '\'' +
                ", turnServerUrl='" + turnServerUrl + '\'' +
                ", turnServerUsername='" + turnServerUsername + '\'' +
                ", turnServerPassword='" + turnServerPassword + '\'' +
                '}';
    }
}
