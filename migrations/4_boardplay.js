const boardplay = artifacts.require("Boardplay");

module.exports = async function(deployer) {
    await deployer.deploy(boardplay);
 //   let tokenInstance = await boardplay.deployed();

};