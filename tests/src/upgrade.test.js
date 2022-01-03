import { processUpgradeTest } from './test.fixture';

const pluginName = "ricochet";
const transactionUploadDelay = 5000;
const signedPlugin = false;

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
    "DAIx": "0x1305f6b6df9dc47159d12eb7ac2804d4a33173c2",
};

devices.forEach((device) =>
    processUpgradeTest(device, pluginName, transactionUploadDelay, contractAddrs, signedPlugin)
);
