import { processUpgradeTest } from './test.fixture';

const pluginName = "ricochet";
const transactionUploadDelay = 10000;
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
    "DAI": "0x1305f6b6df9dc47159d12eb7ac2804d4a33173c2",
    "ETH": "0x27e1e4e6bc79d93032abef01025811b7e4727e85",
    "USDC": "0xcaa7349cea390f89641fe306d93591f87595dc1f",
    "WBTC": "0x4086ebf75233e8492f1bcda41c7f2a8288c2fb92",
    "MKR": "0x2c530af1f088b836fa0dca23c7ea50e669508c4c",
    "SUSHI": "0xdab943c03f9e84795dc7bf51ddc71daf0033382b",
    "IDLE": "0xb63e38d21b31719e6df314d3d2c351df0d4a9162",
};

for (var key in contractAddrs) {
    devices.forEach((device) =>
        processUpgradeTest(device, pluginName, transactionUploadDelay, key, contractAddrs, signedPlugin)
    );
};