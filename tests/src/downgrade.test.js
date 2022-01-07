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
    "DAIx": "0x8f3cf7ad23cd3cadbd9735aff958023239c6a063",
    "USDCx": "0x2791bca1f2de4661ed88a30c99a7a9449aa84174",
    "WBTCx": "0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6",
    "MKRx": "0x6f7c932e7684666c9fd1d44527765433e01ff61d",
    "SUSHIx": "0x0b3f868e0be5597d5db7feb59e1cadbb0fdda50a",

    //"IDLEx": "0xc25351811983818c9fe6d8c580531819c8ade90f",
    //"WETHx": "0x7ceb23fd6bc0add59e62ac25578270cff1b9f619",

    //"MATICx": "0x3ad736904e9e65189c3000c7dd2c8ac8bb7cd4e3",

    // "exSLP(ETH-USDC)": "0x9d5753d8eb0bc849c695461f866a851f13947cb3",
    // "rexSLP(IDLE-ETH)": "0xf256f2ddd563f372333546bdd3662454cbbcb22a",
    // "RIC": "0x263026e7e53dbfdce5ae55ade22493f828922965",
};


for (var key in contractAddrs) {
    devices.forEach((device) =>
        processDowngradeTest(device, pluginName, transactionUploadDelay, key, contractAddrs, signedPlugin)
    );
};