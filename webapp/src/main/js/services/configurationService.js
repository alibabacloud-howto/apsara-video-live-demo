import Configuration from '../models/Configuration';

/**
 * WebRTC support.
 *
 * @author Alibaba Cloud
 */
export default {
    /**
     * Get the configuration of the WebRTC gateway and TURN/STUN server.
     *
     * @return {Promise.<Configuration>}
     */
    getConfiguration() {
        return new Promise((resolve, reject) => {
            fetch('/configuration')
                .then(result => result.json())
                .then(
                    result => resolve(new Configuration(result)),
                    error => reject('Unable to get the configuration: ' + JSON.stringify(error))
                );
        });
    }
};