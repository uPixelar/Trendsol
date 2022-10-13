import React from 'react';

class Register extends React.Component {
    constructor(props){
        super(props);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    async handleSubmit(event) {
        event.preventDefault();
        let tradeName = event.target[0].value;
        let contactNumber = event.target[1].value;
        this.props.web3Data.contract.methods.register(tradeName, contactNumber).send();
    }

    render() {
        return (
            <form style={{"padding": "15px", "fontSize": "1.3em"}} onSubmit={this.handleSubmit}>
                <label>
                    Trade Name:
                    <input type="text" />
                </label><br />
                <label>
                    Contact Number:
                    <input type="text" />
                </label><br />
                <input type="submit" value="Submit" />
            </form>
        );
    }
}


export default Register;
