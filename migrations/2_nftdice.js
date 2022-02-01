const NftDice = artifacts.require("NFTDice");

module.exports = async function(deployer) {
    await deployer.deploy(NftDice, "DefiDicePlay Dice", "DICE");
 //   let tokenInstance = await NftDice.deployed();
  //  await tokenInstance.mint();
};