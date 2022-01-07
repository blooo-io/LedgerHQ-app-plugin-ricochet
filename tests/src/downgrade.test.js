import { processDowngradeTest } from './test.fixture';

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
    "DAIx": "0x8f3cf7ad23cd3cadbd9735aff958023239c6a063"
    // "DAIx": "0x1305f6b6df9dc47159d12eb7ac2804d4a33173c2",
    // "WETHx": "0x27e1e4e6bc79d93032abef01025811b7e4727e85",
    // "USDCx": "0xcaa7349cea390f89641fe306d93591f87595dc1f",
    // "WBTCx": "0x4086ebf75233e8492f1bcda41c7f2a8288c2fb92",
    // "MKRx": "0x2c530af1f088b836fa0dca23c7ea50e669508c4c",
    // "MATICx": "0x3ad736904e9e65189c3000c7dd2c8ac8bb7cd4e3",
    // "SUSHIx": "0xdab943c03f9e84795dc7bf51ddc71daf0033382b",
    // "IDLEx": "0xb63e38d21b31719e6df314d3d2c351df0d4a9162",
    // "exSLP(ETH-USDC)": "0x9d5753d8eb0bc849c695461f866a851f13947cb3",
    // "rexSLP(IDLE-ETH)": "0xf256f2ddd563f372333546bdd3662454cbbcb22a",
    // "RIC": "0x263026e7e53dbfdce5ae55ade22493f828922965",
};

devices.forEach((device) =>
    processDowngradeTest(device, pluginName, transactionUploadDelay, contractAddrs, signedPlugin)
);