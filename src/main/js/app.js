import 'bootstrap';
import React from 'react';
import ReactDOM from 'react-dom';
import Navbar from './components/Navbar';

import '../resources/static/scss/app.scss';

function App() {
    return <Navbar/>;
}

ReactDOM.render(<App/>, document.getElementById('react'));