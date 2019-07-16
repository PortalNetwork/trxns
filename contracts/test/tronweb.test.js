/*const TronWeb = require('tronweb');
const tronWeb = new TronWeb({
  //fullHost: 'https://api.trongrid.io',
  fullHost: '127.0.0.1:9090',
  privateKey: process.env.PRIVATE_KEY_SHASTA
})*/

contract('TRXNS', function(accounts) {
  it("should verify that there are at least three available accounts", async function () {
    console.log(accounts.length);
    if(accounts.length < 3) {
      //console.log(chalk.blue('\nYOUR ATTENTION, PLEASE.]\nTo test MetaCoin you should use Tron Quickstart (https://github.com/tronprotocol/docker-tron-quickstart) as your private network.\nAlternatively, you must set your own accounts in the "before" statement in "test/metacoin.js".\n'))
    }
    console.log(accounts[0]);
    const userBalance = await tronWeb.trx.getBalance(accounts[0]);
    console.log(userBalance);
    assert.isTrue(accounts.length >= 3)
  })

})
