Here is a well-formatted version of the provided content for your `SCRIPTS.md` file:

```markdown
# Safehaven Project - SCRIPTS.md

## Keystore
-----------
To retrieve the Starkli signer keystore, use the following command:

```bash
starkli signer keystore from-key farmers_haven_keystore.json
```

## Account
--------
To fetch the account associated with the address `0x002f0f1c15bc9a31a34b0bb4e6f9baed350593e447ef5877c43875b9b2a9bd72`, use the command below:

```bash
starkli account fetch 0x002f0f1c15bc9a31a34b0bb4e6f9baed350593e447ef5877c43875b9b2a9bd72 --rpc https://free-rpc.nethermind.io/sepolia-juno --output farmers_haven_account.json
```

## Declare
---------
To declare the contract for Safehaven Price Feed (USDT/ETH Converter), execute the following:

```bash
starkli declare target/dev/safehaven_PriceFeedSafeHavenUSDETHConverter.contract_class.json --rpc https://free-rpc.nethermind.io/sepolia-juno --account safehaven_account.json --keystore safehaven_keystore.json
```

## Deploy
----------
To deploy the contract using the specified address, run this command:

```bash
starkli deploy 0x04bf52d91eea1c8d7b4ec5159dbef1095a0ea2d9abefe7c5d86fe27b064b1d93 --rpc https://free-rpc.nethermind.io/sepolia-juno --account safehaven_account.json --keystore safehaven_keystore.json
```

## Interaction
------------
To interact with the deployed contract and call the `get_asset_price` function, use the following `sncast` command:

```bash
sncast call \
  --url https://free-rpc.nethermind.io/sepolia-juno \
  --contract-address 0x01d118d916bf130744b98a1be3b27bc687d1dc40b0b5c16d462f8a42a75587e2 \
  --function "get_asset_price"
```

### Contract Information:
- **class_hash**: `0x033b3cabdd872c158240a4a1edcfc06d1034034e995a789c208a40e6ae01e904`
- **deployment_address**: `0x027baa43f38aed919f448ea0d13ff69ed5fdf38d4a983d19cdf177aa74387c0f`
```