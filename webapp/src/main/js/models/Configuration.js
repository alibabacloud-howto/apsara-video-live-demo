/**
 * Configuration of the WebRTC gateway and TURN/STUN server.
 *
 * @author Alibaba Cloud
 */
export default class Configuration {

    /**
     * @param {{
     *     janusHostname: string?,
     *     janusHttpPort: number?,
     *     janusHttpsPort: number?,
     *     janusHttpPath: string?,
     *     turnServerUrl: string?,
     *     turnServerUsername: string?,
     *     turnServerPassword: string}?
     * } params
     */
    constructor(params) {
        const p = params || {};

        /** @type {string} */
        this.janusHostname = p.janusHostname || '';

        /** @type {number} */
        this.janusHttpPort = p.janusHttpPort || 0;

        /** @type {number} */
        this.janusHttpsPort = p.janusHttpsPort || 0;

        /** @type {string} */
        this.janusHttpPath = p.janusHttpPath || '';

        /** @type {string} */
        this.turnServerUrl = p.turnServerUrl || '';

        /** @type {string} */
        this.turnServerUsername = p.turnServerUsername || '';

        /** @type {string} */
        this.turnServerPassword = p.turnServerPassword || '';
    }
}