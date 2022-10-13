import React from 'react';

const FormInput = (props) => (
    <label>
        {props.label}
        <input type="text" />
    </label>
)

const FormCheck = (props) => (
    <label>
        {props.label}
        <input type="checkbox" />
    </label>
)

class Register extends React.Component {
    constructor(props){
        super(props);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    async handleSubmit(event) {
        event.preventDefault();
        let par = event.target;
        console.log(par[4].checked);
        this.props.web3Data.contract.methods.addProduct(par[0].value, par[1].value, par[2].value, par[3].value, par[4].checked).send();
    }

    render() {
        return (
            <form style={{"padding": "15px", "fontSize": "1.3em"}} onSubmit={this.handleSubmit}>
                <FormInput label="Product Name: " /><br />
                <FormInput label="Details: " /><br />
                <FormInput label="Price: " /><br />
                <FormInput label="Initial Stock: " /><br />
                <FormCheck label="On sale?: " /><br />
                <input type="submit" value="Submit" />
            </form>
        );
    }
}


export default Register;
