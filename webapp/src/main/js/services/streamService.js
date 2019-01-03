import configurationService from './configurationService';
import JanusClient from '../clients/JanusClient';
import RtpForwardingDestination from '../models/RtpForwardingDestination';

/**
 * Allow users to handle streams.
 *
 * @author Alibaba Cloud
 */
export default {
    /**
     * Find all the stream names managed by Apsara Video Live.
     *
     * @return {Promise.<Array.<string>>}
     */
    findAllStreamNames() {
        return new Promise((resolve, reject) => {
            fetch('/streams')
                .then(result => result.json())
                .then(
                    result => resolve(result),
                    error => reject('Unable to find all the streams: ' + JSON.stringify(error))
                );
        });
    },

    /**
     * Create a stream with the given name.
     *
     * @param {string} name
     *     String name.
     * @param {function(localMediaStream: MediaStream)} onLocalMediaStreamAvailable
     *     Function called when the {@link MediaStream} is available for the VIDEO element.
     * @param {function(error: string)} onError
     *     Function called when an error has occurred.
     */
    create(name, onLocalMediaStreamAvailable, onError) {
        const uniqueName = name + '_' + this._generateUuid();

        // Load the WebRTC configuration
        configurationService.getConfiguration()
            .catch(error => onError('Unable to get the WebRTC configuration: ' + error))
            .then(config => {

                // Open a connection to Janus
                const janusClient = new JanusClient(uniqueName, config);
                janusClient.connect({
                    onError: onError,
                    onLocalMediaStreamAvailable: onLocalMediaStreamAvailable,
                    onConnectionEstablished: sdp => {

                        // Forward the video data from Janus to Apsara Video Live
                        this.getRtpForwardingDestination(uniqueName)
                            .catch(error => onError('Unable to get the destination to forward the video data: ' + error))
                            .then(dest => {
                                janusClient.forwardRtpStream(dest.ipAddress, dest.audioPort, dest.videoPort).then(() => {
                                    this.transcodeStream(uniqueName, sdp, dest)
                                        .catch(error => onError('Unable to transcode the stream: ' + error))
                                        .then(() => {
                                            console.log('Stream transcoding');
                                        });
                                })
                            });
                    }
                });
            });
    },

    /**
     * Provide the destination where Janus can forward the RTP data.
     *
     * @param {string} name
     *     Stream name.
     * @return {Promise.<RtpForwardingDestination>}
     *     Destination information.
     */
    getRtpForwardingDestination(name) {
        return new Promise((resolve, reject) => {
            fetch(`/streams/${name}/forwarding-destination`)
                .then(result => result.json())
                .then(
                    result => resolve(new RtpForwardingDestination(result)),
                    error => reject('Unable to find all the streams: ' + JSON.stringify(error))
                );
        });
    },

    /**
     * Start transcoding the RTP data from Janus to Apsara Video Live via RTMP.
     *
     * @param {string} name
     *     Stream name.
     * @param {string} webrtcSdp
     *     SDP file that describes the RTP stream between the web browser and Janus.
     * @param {RtpForwardingDestination} forwardingDestination
     *     Destination where Janus send its RTP data.
     * @return {Promise.<string>}
     *     Success or error message.
     */
    transcodeStream(name, webrtcSdp, forwardingDestination) {
        return new Promise((resolve, reject) => {
            let formData = new FormData();
            formData.append('webrtcSdp', new Blob([webrtcSdp], {type: 'text/plain'}));
            formData.append('forwardingDestination',
                new Blob([JSON.stringify(forwardingDestination)], {type: 'application/json'}));

            fetch(`/streams/${name}/transcode`, {method: 'POST', body: formData})
                .then(result => result.text())
                .then(
                    result => resolve(result),
                    error => reject(error)
                );
        });
    },

    /**
     * @param {string} name
     *     Stream name.
     * @return {string}
     *     Stream name without the trailing UUID.
     */
    simplifyStreamName(name) {
        return name.substring(0, name.lastIndexOf('_'));
    },

    /**
     * Get the URL where users can play the stream.
     *
     * @param {string} name
     *     Stream name.
     * @return {Promise.<string>}
     *     URL where users can play the stream.
     */
    getStreamPullUrl(name) {
        return new Promise((resolve, reject) => {
            fetch(`/streams/${name}/pull-url`)
                .then(result => result.text())
                .then(
                    result => resolve(result),
                    error => reject('Unable to get the stream pull URL: ' + JSON.stringify(error))
                );
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