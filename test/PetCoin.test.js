const tryCatch = require('./helpers/exceptions').tryCatch;
const errorTypes = require('./helpers/exceptions').errTypes;
const timeTravel = require('./helpers/timeTravel');

var PetCoin = artifacts.require('../contracts/PetCoin.sol');

contract('PetCoin', async (accounts) => {

    it("preset wallet balances should be correct", async() => {
        let instance = await PetCoin.deployed();
        let decimals = await instance.decimals();

        let oneBillion = (10**9)*(10**decimals);
        let oneHundredMillion = (10**8)*(10**decimals);
        let fourtyMillion = 4*(10**7)*(10**decimals);

        let appWallet = await instance.appWallet();
        let appWalletBalance = await instance.balanceOf.call(appWallet);
        assert.equal(appWalletBalance.valueOf(), oneBillion);

        let genWallet = await instance.genWallet();
        let genWalletBalance = await instance.balanceOf.call(genWallet);
        assert.equal(genWalletBalance.valueOf(), oneBillion);

        let ceoWallet = await instance.ceoWallet();
        let ceoWalletBalance = await instance.balanceOf.call(ceoWallet);
        assert.equal(ceoWalletBalance.valueOf(), oneHundredMillion);

        let cooWallet = await instance.cooWallet();
        let cooWalletBalance = await instance.balanceOf.call(cooWallet);
        assert.equal(cooWalletBalance.valueOf(), oneHundredMillion);

        let devWallet = await instance.devWallet();
        let devWalletBalance = await instance.balanceOf.call(devWallet);
        assert.equal(devWalletBalance.valueOf(), oneHundredMillion);

        let poolWallet = await instance.poolWallet();
        let poolWalletBalance = await instance.balanceOf.call(poolWallet);
        assert.equal(poolWalletBalance.valueOf(), fourtyMillion);

        let owner = await instance.owner();
        let ownerBalance = await instance.balanceOf.call(owner);
        assert.equal(ownerBalance.valueOf(), 111*(10**5)*(10**decimals));
    });

    it("mint should be called only from 2019 and only by owner", async() => {
        let instance = await PetCoin.deployed();
        await tryCatch(instance.mint.call(accounts[1]), errorTypes.revert);
        let YEAR_IN_SECONDS = 31536000;
        await timeTravel(YEAR_IN_SECONDS);
        await tryCatch(instance.mint.call(accounts[1], {from: accounts[1]}), errorTypes.revert);
        let result = await instance.mint.call(accounts[1]);
        assert.equal(result, true)
    })

})