import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, genericTx, SPECULOS_ADDRESS, RANDOM_ADDRESS, txFromEtherscan } from './test.fixture';
import { ethers } from "ethers";
import { parseEther, parseUnits } from "ethers/lib/utils";

const contractAddr = "0x1305f6b6df9dc47159d12eb7ac2804d4a33173c2";
const pluginName = "ricochet";
const abi_path = `../${pluginName}/abis/` + contractAddr + '.json';
const abi = require(abi_path);
const label = "nanos_ricochet";
const steps = 10;
const transactionUploadDelay = 5000;

test('[Nano S] Upgrade', zemu("nanos", async (sim, eth) => {
    const contract = new ethers.Contract(contractAddr, abi);

    // Constants used to create the transaction
    const amount = "0.995801827876000103";

    const { data } = await contract.populateTransaction['upgrade(uint256)'](amount);

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
}))