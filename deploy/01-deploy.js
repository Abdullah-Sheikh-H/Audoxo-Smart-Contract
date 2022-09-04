const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { ethers, network } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()

  let args = [1, false, false, false, false]

  const AudoxoMarketplace = await deploy("AudoxoMarketplace", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  })

  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    log("Verifying...")
    await verify(AudoxoMarketplace.address, args)
  }

  log("--------------------------------------------")
}
module.exports.tags = ["all", "AudoxoMarketplace"]
