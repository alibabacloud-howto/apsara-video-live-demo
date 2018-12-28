package com.alibaba.intl.livevideo.models;

/**
 * Wrap a "Session Description Protocol" file.
 *
 * @author Alibaba Cloud
 */
public class Sdp {

    private String rawSdp;

    private Sdp(String rawSdp) {
        this.rawSdp = rawSdp;
    }

    public static Sdp fromRawSdp(String rawSdp) {
        return new Sdp(rawSdp);
    }

    public String toRawSdp() {
        return rawSdp;
    }

    public int getAudioPort() {
        return parsePort("audio");
    }

    public void setAudioPort(int audioPort) {
        setPort("audio", audioPort);
    }

    public int getVideoPort() {
        return parsePort("video");
    }

    public void setVideoPort(int videoPort) {
        setPort("video", videoPort);
    }

    private int parsePort(String name) {
        PortIndexes portIndexes = findPortIndexes(name);
        if (portIndexes == null) {
            return -1;
        }

        String audioPortAsString = rawSdp.substring(portIndexes.start, portIndexes.end);
        return Integer.parseInt(audioPortAsString);
    }

    private void setPort(String name, int value) {
        PortIndexes portIndexes = findPortIndexes(name);
        if (portIndexes == null) {
            return;
        }

        rawSdp = rawSdp.substring(0, portIndexes.start) + String.valueOf(value) + rawSdp.substring(portIndexes.end);
    }

    private PortIndexes findPortIndexes(String name) {
        String statement = "m=" + name + " ";
        int lineIndex = rawSdp.indexOf(statement);
        if (lineIndex < 0) {
            return null;
        }

        var portIndexes = new PortIndexes();
        portIndexes.start = lineIndex + statement.length();
        portIndexes.end = rawSdp.indexOf(" ", portIndexes.start + 1);
        return portIndexes;
    }

    @Override
    public String toString() {
        return "Sdp{" +
                "rawSdp='" + rawSdp + '\'' +
                '}';
    }

    private static class PortIndexes {
        private int start;
        private int end;
    }
}
