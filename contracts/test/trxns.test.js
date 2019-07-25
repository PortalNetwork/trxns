const TNS = artifacts.require('./TNSRegistry');
const BaseRegistrar = artifacts.require('./BaseRegistrarImplementation');

const namehash = require('eth-ens-namehash');
const sha3 = require('web3-utils').sha3;

contract('TRXNS', function(accounts) {

  let tns;
  let registrar;

  const ownerAccount = accounts[0];
  const controllerAccount = accounts[1];

  before(async () => {
		tns = await TNS.new();

		registrar = await BaseRegistrar.deployed(tns.address, namehash.hash('trx'), {from: ownerAccount});
		await registrar.addController(controllerAccount, {from: ownerAccount});
		await tns.setSubnodeOwner('0x0', sha3('trx'), registrar.address);
	});

  
  it("", async function() {
    try {

    } catch (err) {
      console.log(err);
    }
  })

})