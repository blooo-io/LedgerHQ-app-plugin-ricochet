# LedgerHQ-app-plugin-ricochet
Plugin App for Ricochet Exchange integration in Ledger Live

## Prerequisite

Be sure to have your environment correctly set up (see [Getting Started](https://ledger.readthedocs.io/en/latest/userspace/getting_started.html)) and [ledgerblue](https://pypi.org/project/ledgerblue/) and installed.

If you want to benefit from [vscode](https://code.visualstudio.com/) integration, it's recommended to move the toolchain in `/opt` and set `BOLOS_ENV` environment variable as follows

```
BOLOS_ENV=/opt/bolos-devenv
```

and do the same with `BOLOS_SDK` environment variable

```
BOLOS_SDK=/opt/nanos-secure-sdk
```

## Documentation

Need more information about the interface, the architecture, or general stuff about ethereum plugins? You can find more about them in the [ethereum-app documentation](https://github.com/LedgerHQ/app-ethereum/blob/master/doc/ethapp_plugins.asc).

## Smart Contracts

Smart contracts covered by this plugin are:

|Token	|Token Address|	Methods Downgrade	| Methods Upgrade	|
|---------------|---------|---------|------|
|`DAIx`	|`0x1305F6B6Df9Dc47159D12Eb7aC2804d4A33173c2`|	  `downgrade(amount)`| `upgrade(amount)`|
|`WETHx`	|`0x27e1e4E6BC79D93032abef01025811B7E4727e85`|	`downgrade(amount)`| `upgrade(amount)`|
|`USDCx`	|`0xCAa7349CEA390F89641fe306D93591f87595dc1F`|	`downgrade(amount)`| `upgrade(amount)`|
|`WBTCx`	|`0x4086eBf75233e8492F1BCDa41C7f2A8288c2fB92`|	`downgrade(amount)`|  `upgrade(amount)`|
|`MKRx`	|`0x2c530aF1f088B836FA0dCa23c7Ea50E669508C4C`|	  `downgrade(amount)`|  `upgrade(amount)`|
|`MATICx`	|`0x3aD736904E9e65189c3000c7DD2c8AC8bB7cD4e3`|	`downgradeToETH(amount)`| `upgrade(amount)`|
|`SUSHIx`	|`0xDaB943C03f9e84795DC7BF51DdC71DaF0033382b`|	`downgrade(amount)`|  `upgrade(amount)`|
|`IDLEx`	|`0xB63E38D21B31719e6dF314D3d2c351dF0D4a9162`|	`downgrade(amount)`|  `upgrade(amount)`|


Start/Stop/Edit Smart Contracts

|Contract Address	|Proxy Methods|
|:---------------|:------------------|
|`0x3e14dc1b13c488a8d5d310918780c983bd5982e7`|`callAgreement()`|
|`0x3e14dc1b13c488a8d5d310918780c983bd5982e7`|`batchCall()`|




## Compilation

```
make DEBUG=1  # compile optionally with PRINTF
make load     # load the app on the Nano using ledgerblue
```

This plugin uses the [ethereum-plugin-sdk](https://github.com/LedgerHQ/ethereum-plugin-sdk/). If there's an error while building, try running `git pull --recurse-submodules` in order to update the sdk. If this fixes your bug, please file an issue or create a PR to add the new sdk version :)

If you need to update the sdk, you will need to do it locally and create a PR on the [ethereum-plugin-sdk repo](https://github.com/LedgerHQ/ethereum-plugin-sdk/).

## Tests & Continuous Integration

The flow processed in [GitHub Actions](https://github.com/features/actions) is the following:

- Code formatting with [clang-format](http://clang.llvm.org/docs/ClangFormat.html)
- Compilation of the application for Ledger Nano S in [ledger-app-builder](https://github.com/LedgerHQ/ledger-app-builder)


## Remote VM tests execution

You can test the plugin using a remote development host, if you deal with an unsupported CPU architecture (Ex.: Apple M1). Your server must have a GUI Desktop installed.

Zemu does not support anymore X11 so all screenshots are generated in the `snapshot-tmp` folder.

Once you replicated the required plugin setup on the remote VM, install the dependencies 

```
cd tests
yarn
````
Then execute tests:
```
yarn test
```
