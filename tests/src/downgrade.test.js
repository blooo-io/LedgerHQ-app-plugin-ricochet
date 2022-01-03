import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, genericTx, SPECULOS_ADDRESS, RANDOM_ADDRESS, txFromEtherscan } from './test.fixture';
import { ethers } from "ethers";
import { parseEther, parseUnits } from "ethers/lib/utils";

const pluginName = "ricochet";
const steps = 7;
const transactionUploadDelay = 5000;

var contractAddrs = {
    "DAIx": "0x1305f6b6df9dc47159d12eb7ac2804d4a33173c2",
    "WETHx": "0x27e1e4e6bc79d93032abef01025811b7e4727e85",
    "USDCx": "0xcaa7349cea390f89641fe306d93591f87595dc1f",
    "WBTCx": "0x4086ebf75233e8492f1bcda41c7f2a8288c2fb92",
    "MKRx": "0x2c530af1f088b836fa0dca23c7ea50e669508c4c",
    "MATICx": "0x3ad736904e9e65189c3000c7dd2c8ac8bb7cd4e3",
    "SUSHIx": "0xdab943c03f9e84795dc7bf51ddc71daf0033382b",
    "IDLEx": "0xb63e38d21b31719e6df314d3d2c351df0d4a9162",
    "exSLP(ETH-USDC)": "0x9d5753d8eb0bc849c695461f866a851f13947cb3",
    "rexSLP(IDLE-ETH)": "0xf256f2ddd563f372333546bdd3662454cbbcb22a",
    "RIC": "0x263026e7e53dbfdce5ae55ade22493f828922965",
};

test('[Nano S] Downgrade', zemu("nanos", async (sim, eth) => {
    for (var key in contractAddrs) {
        const label = "nanos_downgrade_" + key + "";
        const abi_path = `../${pluginName}/abis/` + contractAddrs[key] + '.json';
        const abi = require(abi_path);
        const contract = new ethers.Contract(contractAddrs[key], abi);

        // Constants used to create the transaction
        const amount = 10;

        const { data } = await contract.populateTransaction['upgrade(uint256)'](amount);

        // Get the generic transaction template
        let unsignedTx = genericTx;
        // Modify `to` to make it interact with the contract
        unsignedTx.to = contractAddrs[key];
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
    }
}))