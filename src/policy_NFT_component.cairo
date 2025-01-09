use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
trait INFT<TContractState> {
    fn pause(ref self: TContractState);
    fn unpause(ref self: TContractState);
    fn burn(ref self: TContractState, token_id: u256);
    fn safe_mint(ref self: TContractState, recipient: ContractAddress, token_id: u256, data: Span<felt252>);
    fn safeMint(ref self: TContractState, recipient: ContractAddress, tokenId: u256, data: Span<felt252>);
    fn upgrade(ref self:TContractState, new_class_hash: ClassHash);
    fn setAapprovalForAll(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn purchase_policy(ref self: TContractState, coverage_type: CoverageType, amount: u256, data: Span<felt252>) -> u256;
    fn get_policy(self: @TContractState, policy_id: u256) -> Policy;
    fn finalize_policy(ref self: TContractState, policy_id: u256);
    fn calculate_premium(ref self: TContractState, coverage: CoverageType) -> u256;
}

#[derive(Copy, Drop, Serde, starknet::Store)]
struct Policy { 
    policy_id: u256,
    policyHolder: ContractAddress,
    coverageAmount: u32,
    coverageType: CoverageType,
    startDate: felt252,
    endDate: felt252,
    isClaimed: bool,
}

#[derive(Copy, Drop, Serde, starknet::Store)] // must have the default variant
enum CoverageType {
    BusinessInterruptions,
    EventCancellations,
    #[default]
    IndividualCoverage,
}

#[starknet::component]
pub mod PolicyNFTComponent {
    use super::{ContractAddress, ClassHash, CoverageType, Policy, INFT};
    use core::num::traits::Pow;
    use starknet::storage::{Map, StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Vec, MutableVecTrait};
    use starknet::{get_caller_address, get_contract_address};
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::security::{pausable::PausableComponent, ReentrancyGuardComponent};
    use openzeppelin::token::{erc721::{ERC721Component, ERC721HooksEmptyImpl, interface::ERC721ABI}, erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait}};
    use openzeppelin::upgrades::UpgradeableComponent;
    use ERC721Component::{InternalTrait as ERC721InternalTrait};
    use OwnableComponent::InternalTrait as OwnableInternalTrait;
    use PausableComponent::InternalTrait as PausableInternalTrait;
    use UpgradeableComponent::InternalImpl as UpgradeableInternalTrait;
    use ReentrancyGuardComponent::InternalTrait as ReentrancyInternalTrait;
    use safe_haven::price_converter_component::PriceConverterComponent;
    use PriceConverterComponent::ConverterImpl;
    use core::num::traits::Zero;
    use core::traits::Into;

    pub mod Errors {
        pub const UNSUCCESSFUL_PAYMENT: felt252 = 'Payment Was Not Successful!';
    }

    #[storage]
    pub struct Storage {
        policies: Map::<u256, Policy>,
        policyholder_policies: Map::<ContractAddress, Vec<u256>>,
        policy_counter: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        PolicyCreated: PolicyCreated,
        PolicyFinalized: PolicyFinalized,
    }

    #[derive(Drop, starknet::Event)]
    struct PolicyCreated {
        #[key]
        policy_id: u256,
        policyholder: ContractAddress,
        coverage_type: CoverageType,
    }

    #[derive(Drop, starknet::Event)]
    struct PolicyFinalized {
        #[key]
        policy_id: u256,
        policyholder: ContractAddress,
    }

    #[embeddable_as(NFTImpl)]
    impl NFT<TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl Pause: PausableComponent::HasComponent<TContractState>,
        impl Upgrade: UpgradeableComponent::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl Reentrancy: ReentrancyGuardComponent::HasComponent<TContractState>,
        impl converter: PriceConverterComponent::HasComponent<TContractState>> of INFT<ComponentState<TContractState>> {

        fn pause(ref self: ComponentState<TContractState>) {
            let (mut ownable, mut pausable) = self.get_components();
            ownable.assert_only_owner();
            pausable.pause();
        }

        fn unpause(ref self: ComponentState<TContractState>) {
            let (mut ownable, mut pausable) = self.get_components();
            ownable.assert_only_owner();
            pausable.unpause();
        }

        fn burn(ref self: ComponentState<TContractState>, token_id: u256) {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            erc721.update(Zero::zero(), token_id, get_caller_address());
        }

        fn safe_mint(ref self: ComponentState<TContractState>, recipient: ContractAddress, token_id: u256, data: Span<felt252>) {
            let mut ownable = get_dep_component_mut!(ref self, Ownable);
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            ownable.assert_only_owner();
            erc721.safe_mint(recipient, token_id, data);
        }

        fn safeMint(ref self: ComponentState<TContractState>, recipient: ContractAddress, tokenId: u256, data: Span<felt252>) {
            self.safe_mint(recipient, tokenId, data);
        }

        fn upgrade(ref self: ComponentState<TContractState>, new_class_hash: ClassHash) {
            let mut upgradeable = get_dep_component_mut!(ref self, Upgrade);
            let mut ownable = get_dep_component_mut!(ref self, Ownable);
            ownable.assert_only_owner();
            upgradeable.upgrade(new_class_hash);
        }

        fn setAapprovalForAll(ref self: ComponentState<TContractState>, operator: ContractAddress, approved: bool) {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            erc721.set_approval_for_all(operator, approved);
        }

        fn purchase_policy(ref self: ComponentState<TContractState>, coverage_type: CoverageType, amount: u256, data: Span<felt252>) -> u256 {
            let mut reentracy = get_dep_component_mut!(ref self, Reentrancy);
            reentracy.start();
            let erc20 = ERC20ABIDispatcher {contract_address: 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7.try_into().unwrap()};
            let policy_id = self.policy_counter.read();
            let policyholder = get_caller_address();
            
            let policy : Policy = match coverage_type {
                CoverageType::BusinessInterruptions => Policy {
                    policy_id: policy_id,
                    policyHolder: policyholder,
                    coverageAmount: 1000000, // Higher coverage for business
                    coverageType: CoverageType::BusinessInterruptions,
                    startDate: 1633046400, // Example: Oct 1, 2021
                    endDate: 1664582400, // Example: Oct 1, 2022
                    isClaimed: false,
                },
                CoverageType::IndividualCoverage => Policy {
                    policy_id: policy_id,
                    policyHolder: policyholder,
                    coverageAmount: 500000, // Medium coverage for personal
                    coverageType: CoverageType::IndividualCoverage,
                    startDate: 1633046400, // Example: Oct 1, 2021
                    endDate: 1664582400, // Example: Oct 1, 2022
                    isClaimed: false,
                },
                CoverageType::EventCancellations => Policy {
                    policy_id: policy_id,
                    policyHolder: policyholder,
                    coverageAmount: 250000, // Lower coverage for event
                    coverageType: CoverageType::EventCancellations,
                    startDate: 1633046400, // Example: Oct 1, 2021
                    endDate: 1635724800, // Example: Nov 1, 2021 (shorter duration for event)
                    isClaimed: false,
                },
            };



            self.policies.entry(policy_id).write(policy);
            let mut policyholder_policies = self.policyholder_policies.entry(policyholder); // returns a pointer thus no need to read()
            policyholder_policies.append().write(policy_id);
            let premium = self.calculate_premium(coverage_type);
            let isSuccess = erc20.transfer_from(get_caller_address(), get_contract_address(), premium);
            assert(isSuccess, Errors::UNSUCCESSFUL_PAYMENT);
            self.safeMint(get_caller_address(), policy_id, data);
            self.policy_counter.write(self.policy_counter.read() + 1);
            self.emit(PolicyCreated {policy_id, policyholder, coverage_type});
            reentracy.end();
            policy_id
        }

        fn calculate_premium(ref self: ComponentState<TContractState>, coverage: CoverageType) -> u256 {
            let mut conv = get_dep_component_mut!(ref self, converter);
            match coverage {
                CoverageType::BusinessInterruptions => (2400 * self.calculate_amount(10, 8)) / conv.get_eth_to_usd().try_into().unwrap(),
                CoverageType::EventCancellations => (6000 * self.calculate_amount(10, 8)) / conv.get_eth_to_usd().try_into().unwrap(),
                CoverageType::IndividualCoverage => (600 * self.calculate_amount(10, 8)) / conv.get_eth_to_usd().try_into().unwrap(),
            }
        }

        fn get_policy(self: @ComponentState<TContractState>, policy_id: u256) -> Policy {
            let policy = self.policies.entry(policy_id).read();
            policy
        }
        fn finalize_policy(ref self: ComponentState<TContractState>, policy_id: u256) {
            let mut policy = self.policies.entry(policy_id).read();
            policy.isClaimed = true;
            self.emit(PolicyFinalized { policy_id, policyholder: policy.policyHolder });
        }
    }
    

    #[generate_trait]
    pub impl NFTInternal<TContractState,
        +Drop<TContractState>,
        +HasComponent<TContractState>,
        impl Pauseable: PausableComponent::HasComponent<TContractState>,
        impl Upgrade: UpgradeableComponent::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>
    > of INFTInternal<TContractState> {
        fn initializer(ref self: ComponentState<TContractState>, owner: ContractAddress){
            self.policy_counter.write(0);
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            let mut ownable = get_dep_component_mut!(ref self, Ownable);
            erc721.initializer("SafeHaven", "FH", "https://aquamarine-holy-mosquito-124.mypinata.cloud/files/bafybeifke37iyx2ozevnqmck3uhpnocij4nsltjq4og7utioh55mhdnuvu?X-Algorithm=PINATA1&X-Date=1736404721&X-Expires=30&X-Method=GET&X-Signature=26e433ef5af65b140719afcb8bdbda825a4085e577d6fcd531af891c9097cd7b");
            ownable.initializer(owner);
        }

        fn get_components(ref self: ComponentState<TContractState>) -> (OwnableComponent::ComponentState<TContractState>, PausableComponent::ComponentState<TContractState>) {
            let mut ownable = get_dep_component_mut!(ref self, Ownable);
            let mut pausable = get_dep_component_mut!(ref self, Pauseable);
            (ownable, pausable)
        }

        fn calculate_amount(ref self: ComponentState<TContractState>, base: u256, exponent: u32) -> u256 {
            base.pow(exponent.into())
        }
    }
}