import { processUpgradeByEthTest } from './test.fixture';

const pluginName = "ricochet";
const transactionUploadDelay = 10000;
const signedPlugin = false;
const testNetwork = "polygon"; 

const devices = [
    {
        name: "nanos",
        label: "Nano S",
        steps: 6, // <= Define the number of steps for this test case and this device
    },
    // {
    //   name: "nanox",
    //   label: "Nano X",
    //   steps: 5, // <= Define the number of steps for this test case and this device
    // },
];
var contractAddrs = {
    "MATIC": "0x3ad736904e9e65189c3000c7dd2c8ac8bb7cd4e3",
};

for (var key in contractAddrs) {
    devices.forEach((device) =>
        processUpgradeByEthTest(device, pluginName, transactionUploadDelay, key, contractAddrs, signedPlugin,testNetwork)
    );
};