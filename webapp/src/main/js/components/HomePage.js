import React from 'react';
import streamService from '../services/streamService';

/**
 * Home page.
 *
 * @author Alibaba Cloud
 */
export default class HomePage extends React.Component {

    constructor(props) {
        super(props);
        this.state = {streams: []};
    }

    componentDidMount() {
        streamService.findAll()
            .then(streams => {
                this.setState({streams: streams});
            })
            .catch(error => {
                this.props.onError(error);
            });
    }

    render() {
        let streamElems = [];
        if (this.state.streams.length > 0) {
            streamElems = this.state.streams.map(stream =>
                <li key={stream.id}>
                    <a href="#" onClick={() => this.props.onStreamSelected(stream)}>{stream.name}</a>
                </li>
            );
        } else {
            streamElems = [<li key="no-stream">No stream for the moment.</li>];
        }

        return (
            <div className="container">
                <div className="row">
                    <div className="col-md-12">
                        <div className="jumbotron mt-3 pt-5 pb-5">
                            <h1 className="display-4">Welcome to our live video broadcast demo!</h1>
                            <p className="lead">
                                Broadcast your own webcam video stream on internet or watch the ones from other users.
                            </p>
                        </div>

                        <h2>Create your own stream</h2>
                        <p>
                            Please make sure that your web browser
                            <a href="https://caniuse.com/#search=webrtc"> is compatible with WebRTC </a>
                            and then click on the following button:
                        </p>
                    </div>
                </div>
                <div className="row justify-content-md-center">
                    <div className="col-md-3">
                        <a href="#" className="btn btn-primary w-100" onClick={() => this.props.onBroadcast()}>
                            Broadcast my video
                        </a>
                    </div>
                </div>
                <div className="row">
                    <div className="col-md-12">
                        <h2 className="mt-3">Watch live streams from other users</h2>
                        <p>
                            Please click on the stream you want to watch:
                        </p>
                        <ul>
                            {streamElems}
                        </ul>
                    </div>
                </div>
                <div className="alert alert-warning" role="alert">
                    Note: video stream stability and quality strongly depends on users location and their internet
                    connection. If the current quality is not satisfying, it is possible for the administrator to
                    change the streaming server (in China or outside) or add CDN nodes close to the users.
                </div>
            </div>
        );
    }
}