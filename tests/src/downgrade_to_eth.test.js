import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, genericTx, SPECULOS_ADDRESS, RANDOM_ADDRESS, txFromEtherscan } from './test.fixture';
import { ethers } from "ethers";
import { parseEther, parseUnits } from "ethers/lib/utils";

var contractAddr = "0x0000000000000000000000000000000000001010";
const steps = 6;
const pluginName = "ricochet";
const transactionUploadDelay = 5000;

test('[Nano S] Downgrade', zemu("nanos", async (sim, eth) => {
    //for (var key in contractAddrs) {
    const label = "nanos_downgrade_to_eth";
    const abi_path = `../${pluginName}/abis/` + contractAddr + '.json';
    const abi = require(abi_path);
    const contract = new ethers.Contract(contractAddr, abi);
    // URL 

    // Constants used to create the transaction
    const amount = 10;

    const { data } = await contract.populateTransaction['downgradeToETH(uint256)'](amount);

    // Get the generic transaction template
    let unsignedTx = genericTx;
    // Modify `to` to make it interact with the contract
    unsignedTx.to = contractAddr;
    // Modify the attached data
    unsignedTx.data = data;
    // Modify the number of ETH sent
    unsignedTx.value = parseEther("0.1");

    // Create serializedTx and remove the "0x" prefix
    const serializedTx = ethers.utils.serializeTransaction(unsignedTx).slice(2);

    const tx = eth.signTransaction(
        "44'/60'/0'/0/0",
        serializedTx
    );

    await sim.waitUntilScreenIsNot(
        sim.getMainMenuSnapshot(),
        transactionUploadDelay
    );
    await sim.navigateAndCompareSnapshots(".", label, [steps, 0]);

    await tx;
}));