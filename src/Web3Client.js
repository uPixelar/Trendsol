const web3Client = {
    initialized: false,
    active: false,
    wallet: undefined,
    contract: undefined,

    init: function(){

        let provider = window.ethereum;
        if (typeof provider === 'undefined') return;

        provider.request({ method: "eth_requestAccounts" })
            .then(accounts => {
                this.wallet = accounts[0]
                this.active = true;
            })
            .catch(console.log);

        provider.on('accountsChanged', accounts => this.wallet = accounts[0]);
    },
}


export default () => {
    web3Client.init();
    return web3Client;
};