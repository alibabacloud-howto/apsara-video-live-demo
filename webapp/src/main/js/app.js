import 'bootstrap';
import React from 'react';
import ReactDOM from 'react-dom';
import Navbar from './components/Navbar';
import ErrorPanel from './components/ErrorPanel';
import HomePage from './components/HomePage';
import BroadcastPage from './components/BroadcastPage';
import WatchPage from './components/WatchPage';
import streamService from './services/streamService';

import '../resources/static/scss/app.scss';

/**
 * Application main component.
 *
 * @author Alibaba Cloud
 */
class App extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            errorMessage: '',
            currentPage: 'home',
            selectedStreamName: ''
        };
        this._watchPage = {
            showStream(url) {
            }
        };
    }

    render() {
        let pageElem;
        switch (this.state.currentPage) {
            case 'broadcast':
                pageElem = <BroadcastPage onError={message => this.showErrorMessage(message)}/>;
                break;
            case 'watch':
                pageElem = <WatchPage onError={message => this.showErrorMessage(message)}
                                      streamName={this.state.selectedStreamName}
                                      ref={watchPage => this._watchPage = watchPage}/>;
                break;
            case 'home':
            default:
                pageElem = <HomePage
                    onError={message => this.showErrorMessage(message)}
                    onBroadcast={() => this.setCurrentPage('broadcast')}
                    onStreamSelected={streamName => this._onStreamSelected(streamName)}/>;
                break;
        }

        return (
            <div>
                <Navbar currentPage={this.state.currentPage} onItemSelected={page => this.setCurrentPage(page)}/>
                <ErrorPanel message={this.state.errorMessage}/>
                {pageElem}
            </div>
        );
    }

    /**
     * Show an error message into the corresponding panel. Note that an empty error message hides the error panel.
     *
     * @param {string} message
     */
    showErrorMessage(message) {
        this.setState({errorMessage: message});
    }

    /**
     * Show the given page.
     *
     * @param {string} currentPage
     */
    setCurrentPage(currentPage) {
        this.setState({currentPage: currentPage});
    }

    /**
     * @param {string} streamName
     * @private
     */
    _onStreamSelected(streamName) {
        this.setState({selectedStreamName: streamName});
        this.setCurrentPage('watch');
        streamService.getStreamPullUrl(streamName)
            .catch(error => this.showErrorMessage(error))
            .then(url => {
                this._watchPage.showStream(url);
            });
    }
}

ReactDOM.render(<App/>, document.getElementById('react'));