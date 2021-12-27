import { processTest } from "./test.fixture";

const contractName = "PoapDelegatedMint";
// From : https://etherscan.io/tx/0x1c926a7d245bca1384527db34bfd31eb63b4177bb48097504fcbd2f340a05593
const rawTxHex = "0x02f90172010684625900808518ae17a40083055d16946f2235864cf897078fcdcc2854b76c482cd1687480b901043da5b8f0000000000000000000000000000000000000000000000000000000000000377300000000000000000000000000000000000000000000000000000000002a0c4c0000000000000000000000002fe50deacdb83eb8beababc73ac8d78cf478675f00000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000041b9273bc96569b576e0dd193b51f0d06f9014a46bd49c528c224e58c7589862ae6df7f62f39a46f4f3d67d6d9a9adb0467631b53dbf999df94c139c380fe9ee2e1c00000000000000000000000000000000000000000000000000000000000000c080a0f9fd00402d510a7c89d81dbea9c93da5add1c923eaddeb8fcd20070c51768ff3a07bdf6784281b97b9edadcbec055ca24d8989d5496b336e264001af3df8c9d195";

const testLabel = "Mint Token"; // <= Name of the test
const testDirSuffix = "mint_token"; // <= directory to compare device snapshots to
const signedPlugin = true
const devices = [
  {
    name: "nanos",
    label: "Nano S",
    steps: 7, // <= Define the number of steps for this test case and this device
  },
  // {
  //   name: "nanox",
  //   label: "Nano X",
  //   steps: 5, // <= Define the number of steps for this test case and this device
  // },
];

devices.forEach((device) =>
  processTest(device, contractName, testLabel, testDirSuffix, rawTxHex, signedPlugin)
);