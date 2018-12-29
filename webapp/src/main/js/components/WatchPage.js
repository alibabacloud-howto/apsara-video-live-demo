import React from 'react';
import flvjs from 'flv.js';
import streamService from '../services/streamService';

/**
 * Allow the user to watch a stream.
 *
 * @author Alibaba Cloud
 */
export default class WatchPage extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            isLoading: true
        };
        this.videoRef = React.createRef();
    }

    render() {
        return (
            <div className="container">
                <div className="row">
                    <div className="col-md-12">
                        <h2 className="mt-3">
                            Watching the stream: {streamService.simplifyStreamName(this.props.streamName)}
                        </h2>
                        <p style={{display: this.props.isLoading ? 'block' : 'none'}}>
                            Loading...
                        </p>
                    </div>
                </div>
                <div className="row justify-content-md-center">
                    <div className="col-md-12">
                        <video id="liveVideo" className="m-auto" controls ref={this.videoRef}/>
                    </div>
                </div>
                <div className="row">
                    <div className="col-md-12">
                        <div className="alert alert-warning mt-3" role="alert">
                            Note: if it doesn't work, please try to open this page in
                            <a href="https://www.mozilla.org/en-US/firefox/"> Firefox </a> or
                            <a href="https://www.google.com/chrome/"> Chrome</a>.
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    showStream(streamPullUrl) {
        if (!flvjs.isSupported()) {
            this.props.onError('FLV.js is not supported on the browser.');
            return;
        }

        this.setState({isLoading: false});
        this.videoRef.current.style.display = 'block';
        const flvPlayer = flvjs.createPlayer({
            type: 'flv',
            url: streamPullUrl
        });
        flvPlayer.attachMediaElement(this.videoRef.current);
        flvPlayer.load();
        flvPlayer.play();
    }
}