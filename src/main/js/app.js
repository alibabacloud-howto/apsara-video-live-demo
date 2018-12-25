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
        this.state = {errorMessage: ''};
    }

    render() {
        return (
            <div>
                <Navbar/>
                <ErrorPanel message={this.state.errorMessage}/>
                <HomePage onError={message => this.showErrorMessage(message)}/>
                <BroadcastPage/>
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
}

ReactDOM.render(<App/>, document.getElementById('react'));