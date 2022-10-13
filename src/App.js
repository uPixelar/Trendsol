import React from 'react';
import './App.css';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Navbar, Sellers, Home, Register, AddProduct} from "./components/All";

import Web3 from "web3";

const abi = require("./Trendsol.json").abi;
const address = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
const web3 = new Web3("ws://localhost:8545")
const contract = new web3.eth.Contract(abi, address)

class App extends React.Component {
  state = {
    web3Data: {
      initialized: false,
      wallet: undefined,
      contract: contract
    },
  }

  async componentDidMount() {
    let provider = window.ethereum;
    if (typeof provider === "undefined") this.setState({
      web3Data: {
        initialized: true,
        wallet: undefined
      }
    });
    else {
      provider.request({ method: "eth_requestAccounts" })
        .then(accounts => {
          let wallet = accounts[0];
          contract.options.from = wallet;
          this.setState({
            web3Data: {
              initialized: true,
              wallet: wallet,
              contract: contract
            }
          })
        });

      provider.on('accountsChanged', accounts => {
        let wallet = accounts[0];
        contract.options.from = wallet;
        this.setState({
          web3Data: {
            initialized: true,
            wallet: wallet,
            contract: contract
          }
        })
      });
    }
  }

  render() {
    if (typeof this.state.web3Data.wallet === "undefined")
        return (<h2>Waiting for wallet, please get a wallet extension or supported browser.</h2>);

    return (
      <Router>
        <Navbar />
        <Routes>
          <Route path='/' exact element={<Home web3Data={this.state.web3Data} />} />
          <Route path='/sellers' element={<Sellers web3Data={this.state.web3Data} />} />
          <Route path='/register' element={<Register web3Data={this.state.web3Data} />} />
          <Route path='/add-product' element={<AddProduct web3Data={this.state.web3Data} />} />
        </Routes>
      </Router>
    )
  }
}

export default App;