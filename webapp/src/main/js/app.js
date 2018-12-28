import 'bootstrap';
import React from 'react';
import ReactDOM from 'react-dom';
import Navbar from './components/Navbar';
import ErrorPanel from './components/ErrorPanel';
import HomePage from './components/HomePage';
import BroadcastPage from './components/BroadcastPage';

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
            currentPage: 'home'
        };
    }

    render() {
        let pageElem;
        switch (this.state.currentPage) {
            case 'broadcast':
                pageElem = <BroadcastPage onError={message => this.showErrorMessage(message)}/>;
                break;
            case 'home':
            default:
                pageElem = <HomePage
                    onError={message => this.showErrorMessage(message)}
                    onBroadcast={() => this.setCurrentPage('broadcast')}
                    onStreamSelected={streamName => console.log('TODO watch stream: ' + streamName)}/>;
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
}

ReactDOM.render(<App/>, document.getElementById('react'));