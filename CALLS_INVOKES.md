# CALLS & INVOKES

## Purchase Policy

```cairo
starkli declare target/dev/safe_haven_SafeHaven.contract_class.json --rpc  https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --account safe_haven_account.json --keystore safe_haven.json

starkli deploy 0x066e91d5e8e96677a2859949c561f29a51e2bf6d14e9005544abe8eb520df8ef --rpc https://free-rpc.nethermind.io/sepolia-juno --account safe_haven_account.json --keystore safe_haven.json

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function upgrade --arguments '0x075441257e59a73f2d457ede32ba03585653975be49162456494ca82035d87a5'

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "approve_tokens" --arguments '0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d, 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56, 
30000000000000'

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "purchase_policy" --calldata 2 0 0 1755947824 5

sncast call --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function get_policy --calldata 0x014c9aa846aedd9031d336871883e0e287b38b8f137aac955f64082736185c28

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function file_claim --arguments '0x03ea354d406581f2c233cb8c2518f0b1a526bfc086909ff9d5f20513f70d09a5, "Myself or anyone close to me experienced a financial or personal loss or health deterioration due to the pandemic."'

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "dispute_asserted_claim" --arguments '0x05b93b12b625a9771f3a8a0092c74ce874d167680a884e036e76b7af0bbc78de'

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "resolve_dispute" --arguments '0x05b93b12b625a9771f3a8a0092c74ce874d167680a884e036e76b7af0bbc78de'

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "push_price" --arguments '0x065fc1ac1809f9050bc9ef419bf2cfdb786413a0e10c019efd41533b4c1a6bbf, 0'
```

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 --function transfer --arguments '0x002f0f1c15bc9a31a34b0bb4e6f9baed350593e447ef5877c43875b9b2a9bd72, 3000000000000'

<!-- 0x05e7d808dbd2e1f5958bb51c3fc919b19525e5675dfbee0a35f4bfd0c4ae7533 -->
https://starknet-sepolia.public.blastapi.io/rpc/v0_7

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "push_price" --arguments '0x05b93b12b625a9771f3a8a0092c74ce874d167680a884e036e76b7af0bbc78de, 0'