const NftCups = artifacts.require("NFTCups");

module.exports = async function(deployer) {
    await deployer.deploy(NftCups, "DefiDicePlay Cups", "CUPS");
 //   let tokenInstance = await NftCups.deployed();

 //   await tokenInstance.mint();
 //   console.log(await tokenInstance.boardplay(0));
};