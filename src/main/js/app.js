import 'bootstrap';
import React from 'react';
import ReactDOM from 'react-dom';
import Navbar from './components/Navbar';
import HomePage from './components/HomePage';

import '../resources/static/scss/app.scss';

function App() {
    return <div>
        <Navbar/>
        <HomePage/>
    </div>;
}

ReactDOM.render(<App/>, document.getElementById('react'));