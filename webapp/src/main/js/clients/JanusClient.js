import Janus
    from 'imports-loader?adapter2=webrtc-adapter,adapter=>adapter2.default!exports-loader?Janus!janus-gateway/html/janus.nojquery.js';

/**
 * Wrap the Janus WebRTC Gateway client.
 *
 * @author Alibaba Cloud
 */
export default class JanusClient {

    /**
     * @param {string} id
     *     Unique ID (can be a stream name for example).
     * @param {Configuration} config
     */
    constructor(id, config) {
        const isHttp = location.protocol !== 'https:';
        const janusProtocol = isHttp ? 'http://' : 'https://';
        const janusHostname = config.janusHostname === 'localhost' ? window.location.hostname : config.janusHostname;
        const janusPort = isHttp ? config.janusHttpPort : config.janusHttpsPort;

        /** @type {string} */
        this._id = id;

        /** @type {string} */
        this._janusServerUrl = janusProtocol + janusHostname + ':' + janusPort + config.janusHttpPath;

        /** @type {{urls: string, credential: string, username: string}} */
        this._iceServerConfig = {
            urls: config.turnServerUrl,
            username: config.turnServerUsername,
            credential: config.turnServerPassword
        };

        /**
         * @type {{
         *     onError: function(string),
         *     onLocalMediaStreamAvailable: function(MediaStream),
         *     onConnectionEstablished: function(sdp: string)
         * }}
         */
        this._eventHandler = {
            onError: error => console.log(error),
            onLocalMediaStreamAvailable: mediaStream => console.log('mediaStream available', mediaStream),
            onConnectionEstablished: sdp => console.log('connection established', sdp)
        };

        /** @type {{send: function(*)}} */
        this._videoRoomPluginHandle = {
            send(message) {
            }
        };

        /** @type {number} */
        this._videoRoomPublisherId = 0;

        /** @type {number} */
        this._videoRoomNumber = 0;
    }

    /**
     * Open a connection with Janus and stream video data.
     *
     * @param {{
     *     onError: function(string),
     *     onLocalMediaStreamAvailable: function(MediaStream),
     *     onConnectionEstablished: function(sdp: string)
     * }} eventHandler
     */
    connect(eventHandler) {
        this._eventHandler = eventHandler;

        this._preInitJanus();
    }

    /**
     * Ask Janus to forward the video stream to the given destination via the RTP protocol.
     *
     * @param {string} destIpAddress
     *     Destination IP address.
     * @param {number} destAudioPort
     *     Destination port for the audio signal.
     * @param {number} destVideoPort
     *     Destination port for the video signal.
     * @return {Promise}
     */
    forwardRtpStream(destIpAddress, destAudioPort, destVideoPort) {
        console.log(`Forward stream via RTP (destination IP address: ` +
            `${destIpAddress}, audio port: ${destAudioPort}, video port: ${destVideoPort}).`);

        return new Promise(resolve => {
            this._videoRoomPluginHandle.send({
                message: {
                    request: 'rtp_forward',
                    publisher_id: this._videoRoomPublisherId,
                    room: this._videoRoomNumber,
                    audiopt: 111,
                    videopt: 96,
                    host: destIpAddress,
                    audio_port: destAudioPort,
                    video_port: destVideoPort
                },
                success() {
                    console.log(`Successfully forward stream via RTP (destination IP address: ` +
                        `${destIpAddress}, audio port: ${destAudioPort}, video port: ${destVideoPort}).`);
                    resolve();
                }
            });
        });
    }

    /**
     * @private
     */
    _preInitJanus() {
        // TODO
        navigator.getUserMedia = navigator.mediaDevices.getUserMedia;

        Janus.init({
            debug: 'all',
            callback: () => this._onJanusPreInitialized()
        });
    }

    /**
     * @private
     */
    _onJanusPreInitialized() {
        if (!Janus.isWebrtcSupported()) {
            return this._eventHandler.onError('WebRTC is not supported by your web browser.');
        }

        const janus = new Janus({
            server: this._janusServerUrl,
            iceServers: [this._iceServerConfig],
            error: (error) => this._eventHandler.onError(error),
            destroyed: () => this._eventHandler.onError('WebRTC gateway disconnected.'),
            success: () => this._onJanusCreated(janus)
        });
    }

    /**
     * @param {Janus} janus
     * @private
     */
    _onJanusCreated(janus) {
        // Attach Janus to the "video room" plugin
        janus.attach({
            plugin: 'janus.plugin.videoroom',
            opaque_id: 'videoroom-lvbd-' + Janus.randomString(12),
            error: error => this._eventHandler.onError(error),
            mediaState: (medium, on) => {
                Janus.log(`Janus ${on ? 'started' : 'stopped'} receiving our ${medium}`);
            },
            webrtcState: on => {
                Janus.log(`Janus says our WebRTC PeerConnection is ${on ? 'up' : 'down'} now`);
            },
            consentDialog: on => {
                // Can be used to make the web browser permission dialog more visible (ignored in this demo)
            },
            success: pluginHandle => {
                Janus.log(`Plugin attached! (${pluginHandle.getPlugin()}, id=${pluginHandle.getId()})`);
                this._videoRoomPluginHandle = pluginHandle;
                this._onVideoRoomPluginAttached(pluginHandle);
            },
            onlocalstream: localStream => this._eventHandler.onLocalMediaStreamAvailable(localStream),
            onmessage: (msg, jsep) => {
                // Handle jsep messages (related to WebRTC)
                if (jsep) {
                    this._videoRoomPluginHandle.handleRemoteJsep({jsep: jsep});

                    if (jsep.type === 'answer') {
                        this._eventHandler.onConnectionEstablished(jsep.sdp);
                    }
                }

                // Handle the message
                const event = msg['videoroom'];
                if (event) {
                    switch (event) {
                        case 'joined':
                            const publishedId = msg['id'];
                            const room = msg['room'];
                            this._onRoomJoined(publishedId, room);
                            break;
                        case 'destroyed':
                            this._eventHandler.onError('The video room has been destroyed.');
                            break;
                        case 'event':
                            if (msg['error']) {
                                this._eventHandler.onError(`An error occurred the the video room (error code: ${msg['error_code']}): ${msg['error']}`);
                            }
                            break;
                    }
                }
            }
        });
    }

    /**
     * @param {{send: function(*)}} pluginHandle
     * @private
     */
    _onVideoRoomPluginAttached(pluginHandle) {
        this._videoRoomPluginHandle = pluginHandle;

        // Create a new video room
        console.log('Video room plugin attached. Create a new room...');
        this._videoRoomPluginHandle.send({
            message: {
                request: 'create',
                permanent: false,
                description: this._id + '_room',
                is_private: false,
                bitrate: 128000,
                fir_freq: 10
            },
            success: response => {
                const room = response.room;
                console.log(`New room ${room} created with success.`);

                // Join the video room
                console.log(`Join the room ${room}...`);
                this._videoRoomPluginHandle.send({
                    message: {
                        request: 'join',
                        ptype: 'publisher',
                        room: room,
                        display: this._id + '_publisher'
                    }
                });
            }
        });
    }

    /**
     * @param {number} publisherId
     * @param {number} room
     * @private
     */
    _onRoomJoined(publisherId, room) {
        console.log(`Room ${room} joined with success (publishedId: ${publisherId}).`);
        this._videoRoomPublisherId = publisherId;
        this._videoRoomNumber = room;

        // Create the WebRTC offer
        this._videoRoomPluginHandle.createOffer({
            media: {
                audioRecv: false,
                videoRecv: false,
                audioSend: true,
                videoSend: true
            },
            success: jsep => {
                this._videoRoomPluginHandle.send({
                    message: {
                        request: 'configure',
                        audio: true,
                        video: true
                    },
                    jsep: jsep
                });
            },
            error: error => {
                this._eventHandler.onError('WebRTC error: ' + JSON.stringify(error));
            }
        });
    }
}