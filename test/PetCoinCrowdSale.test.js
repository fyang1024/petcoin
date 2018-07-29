const tryCatch = require('./helpers/exceptions').tryCatch;
const errorTypes = require('./helpers/exceptions').errTypes;
const PetCoin = artifacts.require('../contracts/PetCoin.sol');
const PetCoinCrowdSale = artifacts.require("../Contract/PetCoinCrowdSale.sol");


contract('PetCoinCrowdSale', async(accounts) => {
    it('should be accounts[0] as owner', async () => {
        let petcoin = await PetCoin.deployed();
        let crowdsale = await PetCoinCrowdSale.new(petcoin.address, accounts[1]);
        let owner = await crowdsale.owner();
        assert.equal(owner, accounts[0]);
    });

    it('can be kickoff only by owner', async () => {
        let petcoin = await PetCoin.deployed();
        let crowdsale = await PetCoinCrowdSale.new(petcoin.address, accounts[1]);
        await tryCatch(crowdsale.kickoff.call({from: accounts[1]}), errorTypes.revert);
        await crowdsale.kickoff();
    });

    it('should not accept contribution until kickoff', async () => {
        let petcoin = await PetCoin.deployed();
        let crowdsale = await PetCoinCrowdSale.new(petcoin.address, accounts[1]);
        await tryCatch(crowdsale.send(10, {from: accounts[2]}), errorTypes.revert);
    });
})