import Stream from '../model/Stream';

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
    }
};