const DummyOracle = artifacts.require('./DummyOracle');
const StablePriceOracle = artifacts.require('./StablePriceOracle');

const BigNumber = require('bignumber.js');

contract('StablePriceOracle', function (accounts) {

  it('should return correct prices', async () => {
    var dummyOracle = await DummyOracle.new(10);
    // 4 attousd per second for 3 character names, 2 attousd per second for 4 character names,
    // 1 attousd per second for longer names.
    var priceOracle = await StablePriceOracle.new(dummyOracle.address, [0, 0, 4, 2, 1]);

    console.log('***', priceOracle.address);

    var stablePriceOracle = await tronWeb.contract().at(priceOracle.address);

    assert.equal(new BigNumber((await stablePriceOracle.price("foo", 0, 3600).call())._hex, 16).toFixed(), 1440000000000000000000);
    assert.equal(new BigNumber((await stablePriceOracle.price("quux", 0, 3600).call())._hex, 16).toFixed(), 720000000000000000000);
    assert.equal(new BigNumber((await stablePriceOracle.price("foo12", 0, 3600).call())._hex, 16).toFixed(), 360000000000000000000);
    assert.equal(new BigNumber((await stablePriceOracle.price("foo123", 0, 3600).call())._hex, 16).toFixed(), 360000000000000000000);
  });

});