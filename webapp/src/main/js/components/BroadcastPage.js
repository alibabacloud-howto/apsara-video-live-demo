import React from "react";
import streamService from "../services/streamService";

/**
 * Broadcast page.
 *
 * @author Alibaba Cloud
 */
export default class BroadcastPage extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            streamName: '',
            streamNameReady: false
        };
        this.videoRef = React.createRef();
    }

    render() {
        return (
            <div className="container">
                <div className="row">
                    <div className="col-md-12">
                        <h2 className="mt-3">Create your own stream</h2>
                        <p>
                            Please enter the name of your stream:
                        </p>

                        <form action="#" onSubmit={() => this.createStream()}>
                            <div className="form-group row mb-0">
                                <label htmlFor="streamName" className="col-md-1 col-form-label">Name</label>
                                <div className="col-md-3">
                                    <input type="text" className="form-control"
                                           onChange={event => this.handleStreamNameChange(event.target.value)}
                                           value={this.state.streamName}
                                           disabled={this.state.streamNameReady}
                                    />
                                </div>
                                <button type="submit" className="btn btn-primary col-md-1"
                                        disabled={this.state.streamNameReady}>
                                    Start
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                <div className="row">
                    <div className="col-md-12 mt-3">
                        <video id="broadcastedVideo" className="m-auto" autoPlay="autoplay" ref={this.videoRef}/>
                    </div>
                </div>
                <div className="row">
                    <div className="col-md-12">
                        <div className="alert alert-warning mt-3" role="alert">
                            Note: if it doesn't work, please try to open this page in
                            <a href="https://www.mozilla.org/en-US/firefox/"> Firefox </a> or
                            <a href="https://www.google.com/chrome/"> Chrome </a>.
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    /**
     * Reformat the given stream name by removing all characters different from [a-z0-9_].
     *
     * @param {string} name
     */
    handleStreamNameChange(name) {
        const sanitizedName = name.toLowerCase().replace(/[^a-z0-9_]/g, '_');
        this.setState({streamName: sanitizedName});
    }

    /**
     * Create a stream when the user click on the start button.
     */
    createStream() {
        // Check the stream name
        const streamName = this.state.streamName;
        if (streamName === '') {
            this.props.onError('Please enter a stream name.');
            return;
        } else {
            this.props.onError('');
        }

        // Create the stream
        if (this.state.streamNameReady) {
            return;
        }
        this.setState({streamNameReady: true});

        streamService.create(
            streamName,
            localMediaStream => {
                this.videoRef.current.style.display = 'block';
                this.videoRef.current.srcObject = localMediaStream;
            },
            error => this.props.onError(error));
    }
}