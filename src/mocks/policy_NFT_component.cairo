#[starknet::contract]
pub mod MockSafehaven {
    use PolicyNFTComponent::INFTInternal;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::security::ReentrancyGuardComponent;
    use openzeppelin::security::pausable::PausableComponent;
    use openzeppelin::token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin::upgrades::{UpgradeableComponent, interface::IUpgradeable};
    use safe_haven::policy_NFT_component;
    use safe_haven::policy_NFT_component::PolicyNFTComponent;
    use safe_haven::price_converter_component::PriceConverterComponent;
    use starknet::{ClassHash, get_caller_address};

    component!(path: PriceConverterComponent, storage: converter, event: converterEvent);
    component!(path: PolicyNFTComponent, storage: policyNFT, event: policyNFTEvent);
    component!(path: PausableComponent, storage: pausable, event: PausableEvent);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ReentrancyGuardComponent, storage: reentrancy_guard, event: ReentrancyGuardEvent);

    #[abi(embed_v0)]
    impl ConverterImpl = PriceConverterComponent::ConverterImpl<ContractState>;

    // for the initializer
    impl InternalPriceConverterImpl = PriceConverterComponent::InternalPriceConverterImpl<ContractState>;

    #[abi(embed_v0)]
    impl NFTImpl = PolicyNFTComponent::NFTImpl<ContractState>;

    // for the initializer
    impl NFTInternal = PolicyNFTComponent::NFTInternal<ContractState>;

    #[abi(embed_v0)]
    impl PausableImpl = PausableComponent::PausableImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;

    impl PausableInternalImpl = PausableComponent::InternalImpl<ContractState>;
    impl InternalImpl = ReentrancyGuardComponent::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;


    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        converter: PriceConverterComponent::Storage,
        #[substorage(v0)]
        policyNFT: PolicyNFTComponent::Storage,
        #[substorage(v0)]
        pausable: PausableComponent::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        reentrancy_guard: ReentrancyGuardComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat] //  The first key in the event log is the component ID. Flattening the component event removes it, leaving the event ID as the first key.
        converterEvent: PriceConverterComponent::Event,
        #[flat] //  The first key in the event log is the component ID. Flattening the component event removes it, leaving the event ID as the first key.
        policyNFTEvent: PolicyNFTComponent::Event,
        #[flat]
        PausableEvent: PausableComponent::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ReentrancyGuardEvent: ReentrancyGuardComponent::Event,
    }
}
