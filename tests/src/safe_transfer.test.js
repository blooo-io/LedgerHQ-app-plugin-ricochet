import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, genericTx, SPECULOS_ADDRESS, RANDOM_ADDRESS, txFromEtherscan } from './test.fixture';
import { ethers } from "ethers";
import { parseEther, parseUnits } from "ethers/lib/utils";

const contractAddr = "0x6f2235864cf897078fcdcc2854b76c482cd16874";
const pluginName = "poap";
const abi_path = `../${pluginName}/abis/` + contractAddr + '.json';
const abi = require(abi_path);
const label = "nanos_safe_transfer";
const steps = 10;
const transactionUploadDelay = 5000;

test('[Nano S] Safe Transfer', zemu("nanos", async (sim, eth) => {
    const contract = new ethers.Contract(contractAddr, abi);

    // Constants used to create the transaction
    const from = "0x6f2235864cf897078fcdcc2854b76c482cd16874";
    const to = "0x15557c8b7246C38EE71eA6dc69e4347F5DAc2104";
    const tokenId = "3553424";

    const { data } = await contract.populateTransaction['safeTransferFrom(address,address,uint256)'](from, to, tokenId);

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