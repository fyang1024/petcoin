const PetCoin = artifacts.require("../Contract/PetCoin.sol")
const PetCoinCrowdSale = artifacts.require("../Contract/PetCoinCrowdSale.sol")

module.exports = function(deployer) {
    deployer.deploy(PetCoin).then (function() {
        // TODO !important! change the ETH receiver wallet address to yours
        deployer.deploy(PetCoinCrowdSale, PetCoin.address, 0x88884e35d7006ae84efef09ee6bc6a43dd8e2bb8)
    })
}