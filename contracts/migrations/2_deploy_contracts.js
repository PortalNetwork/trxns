// var MyContract = artifacts.require("./MyContract.sol");
const TNSRegistry = artifacts.require("./TNSRegistry");
const BaseRegistrarImplementation = artifacts.require("./BaseRegistrarImplementation");
const namehash = require('eth-ens-namehash');

module.exports = function(deployer) {

  deployer.deploy(TNSRegistry).then(function(registry) {
    console.log(registry.address);
    console.log(namehash.hash('trx'));
    deployer.deploy(BaseRegistrarImplementation, registry.address, namehash.hash('trx')).then(function(baseRegistrar) {

    })
  });
  
  
};
