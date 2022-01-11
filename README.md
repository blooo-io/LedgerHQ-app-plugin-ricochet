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
|:---------------|:----------------|--|:------|
|DAIx	|0x1305F6B6Df9Dc47159D12Eb7aC2804d4A33173c2|	downgrade(amount)| upgrade(amount)|
|WETHx	|0x27e1e4E6BC79D93032abef01025811B7E4727e85|	downgrade(amount)| upgrade(amount)|
|USDCx	|0xCAa7349CEA390F89641fe306D93591f87595dc1F|	downgrade(amount)| upgrade(amount)|
|WBTCx	|0x4086eBf75233e8492F1BCDa41C7f2A8288c2fB92|	downgrade(amount)|  upgrade(amount)|
|MKRx	|0x2c530aF1f088B836FA0dCa23c7Ea50E669508C4C|	downgrade(amount)|  upgrade(amount)|
|MATICx	|0x3aD736904E9e65189c3000c7DD2c8AC8bB7cD4e3|	downgradeToETH(amount)| upgrade(amount)|
|SUSHIx	|0xDaB943C03f9e84795DC7BF51DdC71DaF0033382b|	downgrade(amount)|  upgrade(amount)|
|IDLEx	|0xB63E38D21B31719e6dF314D3d2c351dF0D4a9162|	downgrade(amount)|  upgrade(amount)|

|Tokens|Contract Address	|Methods|
|:---------------|:----------------|--|:------|
|`DAI>>WETH	`|`0x27C7D067A0C143990EC6ed2772E7136Cfcfaecd6`	|`distribute()`|
|`WETH>>DAI	`|`0x5786D3754443C0D3D1DdEA5bB550ccc476FdF11D`	|`distribute()`|
|`USDC>>WBTC`|`0xe0A0ec8dee2f73943A6b731a2e11484916f45D44`	|`distribute()`|
|`WBTC>>USDC`|`0x71f649EB05AA48cF8d92328D1C486B7d9fDbfF6b`	|`distribute()`|
|`USDC>>WETH`|`0x8082Ab2f4E220dAd92689F3682F3e7a42b206B42`	|`distribute()`|
|`WETH>>USDC`|`0x3941e2E89f7047E0AC7B9CcE18fBe90927a32100`	|`distribute()`|
|`USDC>>MATIC`|`0xE093D8A4269CE5C91cD9389A0646bAdAB2c8D9A3`	|`distribute()`|
|`MATIC>>USDC`|`0x93D2d0812C9856141B080e9Ef6E97c7A7b342d7F`	|`distribute()`|
|`DAI>>MATIC`|`0xA152715dF800dB5926598917A6eF3702308bcB7e`	|`distribute()`|
|`MATIC>>DAI`|`0x250efbB94De68dD165bD6c98e804E08153Eb91c6`	|`distribute()`|
|`USDC>>MKR`|`0xC89583Fa7B84d81FE54c1339ce3fEb10De8B4C96`	|`distribute()`|
|`MKR>>USDC`|`0xdc19ed26aD3a544e729B72B50b518a231cBAD9Ab`	|`distribute()`|
|`DAI>>MKR`|`0x47de4Fd666373Ca4A793e2E0e7F995Ea7D3c9A29`	|`distribute()`|
|`MKR>>DAI`|`0x94e5b18309066dd1E5aE97628afC9d4d7EB58161`	|`distribute()`|
|`USDC>>IDLE`|`0xBe79a6fd39a8E8b0ff7E1af1Ea6E264699680584`	|`distribute()`|	






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


## RDP tests execution

You can test the plugin using a remote development host, if you deal with an unsupported CPU architecture (Ex.: Apple M1). Your server must have a GUI Desktop installed.

1. Install first xrdp on remote linux VM (Ex: Ubuntu 20.04.1)
```
sudo apt install xrdp
````

2. Set access control to none :
```
xhost +
```
> ```access control disabled, clients can connect from any host```


3. Connect to the VM using Remote Desktop Client using port forwarding through ssh connection on port 3389. This will keep the security at maximum and avoid exposing the VM to the web on RDP port.

```
ssh -i PRIVATEKEY USERNAME@PUBLICIP -L 3389:localhost:3389
```

4. Identify the Display index:
```
echo $DISPLAY
```
>```:10.0```

5. In the terminal where are executed the tests set Display to the RDP previous value, here ``:10.0``:

```
export DISPLAY=:10.0
```

6. After this setup you could run ``yarn test`` and see the emulator in the RDP display going through the test sequence.
