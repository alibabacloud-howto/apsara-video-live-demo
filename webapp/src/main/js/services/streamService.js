import Stream from '../models/Stream';
import webrtcService from './webrtcService';

/**
 * Allow users to handle streams.
 *
 * @author Alibaba Cloud
 */
export default {
    /**
     * Find all existing streams.
     *
     * @return {Promise.<Array.<Stream>>}
     */
    findAll() {
        return new Promise((resolve, reject) => {
            // TODO
            const streams = [
                new Stream({
                    id: 'id0',
                    name: 'Stream 0',
                    domainName: 'domain.com',
                    appName: 'app name 0'
                }),
                new Stream({
                    id: 'id1',
                    name: 'Stream 1',
                    domainName: 'domain.com',
                    appName: 'app name 1'
                })
            ];
            resolve(streams);
        });
    },

    /**
     * Create a stream with the given name.
     *
     * @param {string} streamName
     * @param {{
     *     onLocalMediaStreamAvailable: function(localMediaStream: MediaStream),
     *     onStreamCreated: function(stream: Stream),
     *     onError(error: string)
     * }} eventHandler
     */
    createByName(streamName, eventHandler) {
        const stream = new Stream({
            id: this._generateUuid(),
            name: streamName
        });

        webrtcService.getConfiguration()
            .then(configuration => {
                // TODO
                console.log(configuration);
            })
            .catch(error => {
                eventHandler.onError('Unable to get the WebRTC configuration: ' + error);
            });
    },

    /**
     * Generate a random-based UUID v4.
     * Thanks to https://stackoverflow.com/a/2117523
     *
     * @private
     * @returns {string}
     */
    _generateUuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
            let r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
};