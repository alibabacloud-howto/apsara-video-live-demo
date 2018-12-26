/**
 * Contain all details about a live stream.
 *
 * @author Alibaba Cloud
 */
export default class Stream {

    /**
     * @param {{id: string?, name: string?, domainName: string?, appName: string?}?} params
     */
    constructor(params) {
        const p = params || {};

        /** @type {string} */
        this.id = p.id || '';

        /** @type {string} */
        this.name = p.name || '';

        /** @type {string} */
        this.domainName = p.domainName || '';

        /** @type {string} */
        this.appName = p.appName || '';
    }
}