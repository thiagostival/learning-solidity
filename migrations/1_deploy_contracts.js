// Variavel que guarda as informacoes da compilacao do smart contract
var TaskManager = artifacts.require("TaskManager");

// O parametro deployer é do proprio truffle
module.exports = function (deployer) {
  deployer.deploy(TaskManager);
};
