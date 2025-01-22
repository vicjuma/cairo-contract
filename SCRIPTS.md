Here is a well-formatted version of the provided content for your `SCRIPTS.md` file:

````markdown
# Safehaven Project - SCRIPTS.md

## Keystore

---

To retrieve the Starkli signer keystore, use the following command:

```bash
starkli signer keystore from-key safe_haven.json
```
````

## Account

---

To fetch the account associated with the address `0x05fb10d2d3db05a1e8b32945b2639dce6b7e99fc7b27ab7964f5fd267f8f3a95`, use the command below:

```bash
starkli account fetch 0x02f02356893365D8fC0F91663A0DaE38a3f2690B616026BC52D1D4c126E008E7 --rpc https://free-rpc.nethermind.io/sepolia-juno --output safe_haven_account.json
```

## Declare

---

To declare the contract for Safehaven Price Feed (USDT/ETH Converter), execute the following:

```bash
starkli declare target/dev/safe_haven_SafeHaven.contract_class.json --rpc https://free-rpc.nethermind.io/sepolia-juno --account safe_haven_account.json --keystore safe_haven.json
```

## Deploy

---

To deploy the contract using the specified address, run this command:

```bash
starkli deploy 0x0129129d1a9220c3e0491841da510336ffbc0c640451cc0b7578fecbd677f201 --rpc https://free-rpc.nethermind.io/sepolia-juno --account safe_haven_account.json --keystore safe_haven.json
```

## Interaction

---

To interact with the deployed contract and call the `get_asset_price` function, use the following `sncast` command:

```bash
sncast call --url https://free-rpc.nethermind.io/sepolia-juno/v0_7 --contract-address 0x044a926d28b18f4ebad3c428f6c5160657a4f6f657793d76675111710795e677 --function "get_asset_price"
```

### Contract Information:

- **class_hash**: `0x043651531d47ba88f34a0e193ec2105c4736ab813eb7af4327f500a57ff1a5ac`
- **deployment_address**: `0x044a926d28b18f4ebad3c428f6c5160657a4f6f657793d76675111710795e677`

````

sncast call --contract-address 0x044a926d28b18f4ebad3c428f6c5160657a4f6f657793d76675111710795e677 --function get_strk_to_usd


sncast invoke --url https://free-rpc.nethermind.io/sepolia-juno/v0_7 --contract-address 0x044a926d28b18f4ebad3c428f6c5160657a4f6f657793d76675111710795e677 --function purchase_policy --calldata "CoverageType::BusinessInterruptions"

sncast invoke --url https://free-rpc.nethermind.io/sepolia-juno/v0_7 --contract-address 0x044a926d28b18f4ebad3c428f6c5160657a4f6f657793d76675111710795e677 --function "purchase_policy" --calldata 0 1000000000000000000 0 0 0 1755947824 5

```cairo
Let's break down the ByteArray representation:

0: This is the number of full words (31 bytes each) in the ByteArray 12.
1755947824: This is the felt252 representation of "hello" (0x68656C6C6F) 12.
5: This is the length of the pending word in bytes 12.
This representation follows the ByteArray structure as described in the Cairo documentation 12:

The first value (0) indicates that there are no full 31-byte words in the data array.
The second value (1755947824) is the pending word containing the bytes of "hello".
The third value (5) is the length of the pending word in bytes.
````

sncast call \
 --contract-address 0x044a926d28b18f4ebad3c428f6c5160657a4f6f657793d76675111710795e677 \
 --function "file_claim" \
 --calldata 1415349616906916461044052163151347278866057270674505684654440229520932359639 0x5468652070616E64656D696320746861742 0x06F63637572726564206166666563746564 0x206275736965737365730000000000000000
