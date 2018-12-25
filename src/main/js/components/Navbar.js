import React from 'react';

/**
 * Top navigation bar.
 *
 * @author Alibaba Cloud
 */
export default class Navbar extends React.Component {

    constructor(props) {
        super(props);
        this.state = {};
    }

    render() {
        return (
            <nav className="navbar navbar-expand-lg navbar-dark bg-dark">
                <div className="container">
                    <div className="navbar-brand">Apsara Live Video Demo</div>

                    <button className="navbar-toggler" type="button" data-toggle="collapse"
                            data-target="#navigation_bar_items" aria-controls="navigation_bar_items"
                            aria-expanded="false" aria-label="Toggle navigation">
                        <span className="navbar-toggler-icon"/>
                    </button>

                    <div className="collapse navbar-collapse" id="navigation_bar_items">
                        <ul className="navbar-nav mr-auto">
                            <li className="nav-item">
                                <a className="nav-link" href="/">Home</a>
                            </li>
                            <li className="nav-item">
                                <a className="nav-link" href="/">Broadcast</a>
                            </li>
                            <li className="nav-item">
                                <a className="nav-link" href="/">Watch</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        );
    }
}