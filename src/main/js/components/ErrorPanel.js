import React from "react";

/**
 * Display an error message.
 *
 * @author Alibaba Cloud
 */
export default class ErrorPanel extends React.Component {

    constructor(props) {
        super(props);
    }

    render() {
        if (this.props.message) {
            return (
                <div className="container mt-3">
                    <div className="row">
                        <div className="col-md-12">
                            <div className="alert alert-danger" role="alert">{this.props.message}</div>
                        </div>
                    </div>
                </div>
            );
        } else {
            return (
                <div/>
            );
        }
    }
}