import WebrtcConfiguration from '../models/WebrtcConfiguration';

/**
 * WebRTC support.
 *
 * @author Alibaba Cloud
 */
export default {
    /**
     * Get the configuration of the WebRTC gateway and TURN/STUN server.
     *
     * @return {Promise.<WebrtcConfiguration>}
     */
    getConfiguration() {
        return new Promise((resolve, reject) => {
            fetch('/webrtc-configuration')
                .then(result => result.json())
                .then(
                    result => resolve(new WebrtcConfiguration(result)),
                    error => reject('Unable to get the WebRTC configuration: ' + JSON.stringify(error))
                );
        });
    }
};