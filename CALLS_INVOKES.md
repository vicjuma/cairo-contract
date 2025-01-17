# CALLS & INVOKES

## Purchase Policy

```cairo
starkli declare target/dev/safe_haven_SafeHaven.contract_class.json --rpc  https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --account safe_haven_account.json --keystore safe_haven.json

starkli deploy 0x066e91d5e8e96677a2859949c561f29a51e2bf6d14e9005544abe8eb520df8ef --rpc https://free-rpc.nethermind.io/sepolia-juno --account safe_haven_account.json --keystore safe_haven.json

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function upgrade --arguments '0x03e243e0b797fe3168e123a5735fadd02c3d44eddfd717a595a86e5817672a30'

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "approve_tokens" --arguments '0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d, 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56, 
30000000000000'

sncast invoke --url https://free-rpc.nethermind.io/sepolia-juno/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "purchase_policy" --calldata 2 1000000000000000000 0 0 0 1755947824 5

sncast call --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function get_policy --calldata 0x1f37a66c75d2e704ef7ecb60ca858b5f9ed7a36bd5ebcb435c37fe0c75a1ff

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function file_claim --arguments '0x1f37a66c75d2e704ef7ecb60ca858b5f9ed7a36bd5ebcb435c37fe0c75a1ff, "Myself or anyone close to me experienced a financial or personal loss or health deterioration due to the pandemic."'

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "dispute_asserted_claim" --arguments '0x069b670387e66029de242633521be1c6cba496fcf2b1d9f40acebd6a6c6f9420'

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "resolve_dispute" --arguments '0x069b670387e66029de242633521be1c6cba496fcf2b1d9f40acebd6a6c6f9420'

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "push_price" --arguments '0x065fc1ac1809f9050bc9ef419bf2cfdb786413a0e10c019efd41533b4c1a6bbf, 0'
```

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 --function transfer --arguments '0x002f0f1c15bc9a31a34b0bb4e6f9baed350593e447ef5877c43875b9b2a9bd72, 3000000000000'

<!-- 0x05e7d808dbd2e1f5958bb51c3fc919b19525e5675dfbee0a35f4bfd0c4ae7533 -->
https://starknet-sepolia.public.blastapi.io/rpc/v0_7

sncast invoke --url https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --contract-address 0x06f8cb0ad5c3e9c19b383141a90bf423272b295725d73148244bbb904df0ac56 --function "push_price" --arguments '0x03b683b34e5d3ac29a37de12bd38bf8dd08a70822cdac577a619dec567f7354d, 0'