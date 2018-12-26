import Janus from '@techteamer/janus-api';

/**
 * Wrap the Janus WebRTC Gateway client.
 *
 * @author Alibaba Cloud
 */
export default {

    /**
     * Open a connection with Janus (the WebRTC gateway) and handle communication with the video room plugin.
     *
     * @param {{
     *     onVideoRoomPluginAttached: function(videoRoomPluginHandle: {send: function(message: object)}),
     *     onLocalMediaStreamAvailable: function(localMediaStream: MediaStream),
     *     onAnswerReceived: function(sdp: string),
     *     onRoomJoined: function(publisherId: number, room: number),
     *     onRoomDestroyed: function(),
     *     onRoomError: function(code: number, message: string),
     *     onGatewayError: function(error: string),
     *     onGatewayDisconnected: function()
     * }} eventHandler
     * @private
     */
    _connectToWebrtcGateway(eventHandler) {
        Janus.init({
            debug: 'all',
            callback: () => {
                if (!Janus.isWebrtcSupported()) {
                    return eventHandler.onGatewayError('WebRTC is not supported by your web browser.');
                }
            }
        });
    }

}