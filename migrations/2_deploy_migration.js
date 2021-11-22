//** Initial Migrate Script */
require("dotenv").config();


const MelioraInfo = artifacts.require("MelioraInfo");
module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(MelioraInfo, { from: accounts[0] });
  const melioraInfo = await MelioraInfo.deployed();
  console.log('melioraInfo', melioraInfo.address);
};
