const TNS = artifacts.require('./TNSRegistry');
const BaseRegistrar = artifacts.require('./BaseRegistrarImplementation');

contract('TRXNS', function(accounts) {

  let tns;
  let registrar;

  before(async () => {
		tns = await TNS.new();

		const now = (await web3.eth.getBlock('latest')).timestamp;
		registrar = await BaseRegistrar.new(ens.address, interimRegistrar.address, namehash.hash('eth'), now + 365 * DAYS, {from: ownerAccount});
		await registrar.addController(controllerAccount, {from: ownerAccount});
		await ens.setSubnodeOwner('0x0', sha3('eth'), registrar.address);
	});

  
  it("", async function() {
    try {

    } catch (err) {
      console.log(err);
    }
  })

})