package com.alibaba.intl.livevideotranscoder.models;

import java.time.Instant;

/**
 * Port that have been reserved for a transcoding operation.
 *
 * @author Alibaba Cloud
 */
public class PortReservation {

    /**
     * Unique ID for the transcoding context.
     */
    private String id;

    /**
     * Reserved port number.
     */
    private int port;

    /**
     * Time when the port has been reserved.
     */
    private Instant reservationInstant;

    public PortReservation() {
    }

    public PortReservation(String id, int port, Instant reservationInstant) {
        this.id = id;
        this.port = port;
        this.reservationInstant = reservationInstant;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public int getPort() {
        return port;
    }

    public void setPort(int port) {
        this.port = port;
    }

    public Instant getReservationInstant() {
        return reservationInstant;
    }

    public void setReservationInstant(Instant reservationInstant) {
        this.reservationInstant = reservationInstant;
    }

    @Override
    public String toString() {
        return "PortReservation{" +
                "id='" + id + '\'' +
                ", port=" + port +
                ", reservationInstant=" + reservationInstant +
                '}';
    }
}
