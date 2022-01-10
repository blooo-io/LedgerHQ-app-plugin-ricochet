import { processDistributeTest } from './test.fixture';

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
    "DAI>>WETH": "0x27c7d067a0c143990ec6ed2772e7136cfcfaecd6",
    "WETH>>DAI": "0x5786d3754443c0d3d1ddea5bb550ccc476fdf11d",
    "USDC>>WBTC": "0xe0a0ec8dee2f73943a6b731a2e11484916f45d44",
    "WBTC>>USDC": "0x71f649eb05aa48cf8d92328d1c486b7d9fdbff6b",

    // "USDC>>WETH": "0x8082ab2f4e220dad92689f3682f3e7a42b206b42",
    // "WETH>>USDC": "0x3941e2e89f7047e0ac7b9cce18fbe90927a32100",
    // "USDC>>MATIC": "0xe093d8a4269ce5c91cd9389a0646badab2c8d9a3",
    // "MATIC>>USDC": "0x93d2d0812c9856141b080e9ef6e97c7a7b342d7f",
    // "DAI>>MATIC": "0xa152715df800db5926598917a6ef3702308bcb7e",
    // "MATIC>>DAI": "0x250efbb94de68dd165bd6c98e804e08153eb91c6",
    // "USDC>>MKR": "0xc89583fa7b84d81fe54c1339ce3feb10de8b4c96",
    // "MKR>>USDC": "0xdc19ed26ad3a544e729b72b50b518a231cbad9ab",
    // "DAI>>MKR": "0x47de4fd666373ca4a793e2e0e7f995ea7d3c9a29",
    // "MKR>>DAI": "0x94e5b18309066dd1e5ae97628afc9d4d7eb58161",
    // "USDC>>IDLE": "0xbe79a6fd39a8e8b0ff7e1af1ea6e264699680584"
};


for (var key in contractAddrs) {
    devices.forEach((device) =>
        processDistributeTest(device, pluginName, transactionUploadDelay, key, contractAddrs, signedPlugin)
    );
};