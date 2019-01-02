/**
 * Destination where Janus can forward RTP data.
 *
 * @author Alibaba Cloud
 */
export default class RtpForwardingDestination {

    /**
     * @param {{
     *     id: string?,
     *     ipAddress: string?,
     *     audioPort: number?,
     *     videoPort: number?}?
     * } params
     */
    constructor(params) {
        const p = params || {};

        /** @type {string} */
        this.id = p.id || '';

        /** @type {string} */
        this.ipAddress = p.ipAddress || '';

        /** @type {number} */
        this.audioPort = p.audioPort || 0;

        /** @type {number} */
        this.videoPort = p.videoPort || 0;
    }

}