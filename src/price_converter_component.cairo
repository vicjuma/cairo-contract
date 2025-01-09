#[starknet::component]
pub mod PriceConverterComponent {
    // use starknet::{ContractAddress, contract_address_const};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use pragma_lib::{abi::{IPragmaABIDispatcher, IPragmaABIDispatcherTrait}, types::{DataType, PragmaPricesResponse}};

    #[storage]
    pub struct Storage {
        asset_id_eth: felt252,
        asset_id_strk: felt252,
        pragma_contract_address: felt252,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        TokenConverted: TokenConverted
    }

    #[derive(Drop, starknet::Event)]
    struct TokenConverted {
        token_type: felt252
    }

    #[starknet::interface]
    trait IPriceConverter<TContractState> {
        fn get_eth_to_usd(ref self: TContractState) -> u128;
        fn get_strk_to_usd(ref self: TContractState) -> u128;
        fn get_decimals_eth(self: @TContractState) -> u32;
        fn get_decimals_strk(self: @TContractState) -> u32;
    }

    #[embeddable_as(ConverterImpl)]
    impl Converter<TContractState, +HasComponent<TContractState>> of IPriceConverter<ComponentState<TContractState>> {

        fn get_decimals_eth(self: @ComponentState<TContractState>) -> u32 {
            let (_, decimals) = self.convertion_util('ETH');
            decimals
        }

        fn get_decimals_strk(self: @ComponentState<TContractState>) -> u32 {
            let (_, decimals) = self.convertion_util('STRK');
            decimals
        }

        fn get_eth_to_usd(ref self: ComponentState<TContractState>) -> u128 {
            let (price_in_usd, _) = self.convertion_util('ETH');
            self.emit(TokenConverted {token_type: 'ETH'});
            price_in_usd
        }

        fn get_strk_to_usd(ref self: ComponentState<TContractState>) -> u128 {
            let (price_in_usd, _) = self.convertion_util('STRK');
            self.emit(TokenConverted {token_type: 'STRK'});
            price_in_usd
        }
        
    }

    #[generate_trait]
    pub impl InternalPriceConverterImpl<TContractState, +HasComponent<TContractState>> of IInternalPriceConverterFunctions<TContractState> {

        fn initializer(ref self: ComponentState<TContractState>, asset_id_eth: felt252, asset_id_strk: felt252, address: felt252) {
            self.asset_id_eth.write(asset_id_eth);
            self.asset_id_strk.write(asset_id_strk);
            self.pragma_contract_address.write(address);
        }

        // gets the prices based on the asset ID passed, between STRK and ETH and returns a tuple
        fn convertion_util(self: @ComponentState<TContractState>, asset_id: felt252) -> (u128, u32) {
            let pragma_dispatcher = IPragmaABIDispatcher {
                contract_address: self.pragma_contract_address.read().try_into().unwrap()
            };

            let id = if asset_id == 'ETH' {
                self.asset_id_eth.read()
            } else {
                self.asset_id_strk.read()
            };

            let data_output: PragmaPricesResponse = pragma_dispatcher.get_data_median(DataType::SpotEntry(id));
            let price_in_usd = data_output.price;
            let decimals = data_output.decimals;
            (price_in_usd, decimals)
        }
    }
}