export default (cb) => {
  //cb(success, wallet)
  let provider = window.ethereum;

  if (typeof provider === 'undefined') {
    cb(false);
    return;
  }

  provider.request({ method: 'eth_requestAccounts' })
    .then((accounts) => cb(true, accounts[0]))
    .catch((err) => {
      console.log(err);
      cb(false);
    });

  provider.on('accountsChanged', (accounts) => cb(true, accounts[0]));
};