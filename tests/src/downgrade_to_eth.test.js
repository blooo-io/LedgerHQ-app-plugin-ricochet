import { processDowngradeByETHTest } from './test.fixture';

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
var contractAddr = "0x0000000000000000000000000000000000001010"

devices.forEach((device) =>
    processDowngradeByETHTest(device, pluginName, transactionUploadDelay, contractAddr, signedPlugin)
);