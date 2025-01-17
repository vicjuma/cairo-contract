use starknet::{ContractAddress, contract_address_const};

#[starknet::interface]
trait INFT<TContractState> {
    fn burn(ref self: TContractState, token_id: felt252);
    fn safe_mint(ref self: TContractState, recipient: ContractAddress, token_id: felt252, data: Span<felt252>);
    fn safeMint(ref self: TContractState, recipient: ContractAddress, tokenId: felt252, data: Span<felt252>);
    fn purchase_policy(ref self: TContractState, coverage_type: CoverageType, amount: u256, data: Span<felt252>, descrption: ByteArray) -> felt252;
    fn get_policy(self: @TContractState, policy_id: felt252) -> Policy;
    fn calculate_premium(ref self: TContractState, coverage: CoverageType) -> u256;
    fn file_claim(ref self: TContractState, policy_id: felt252, claim_description: ByteArray) -> felt252;
    fn dispute_asserted_claim(ref self: TContractState, assertion_id: felt252) -> felt252;
    fn resolve_dispute(ref self: TContractState, assertion_id: felt252) -> bool;
    fn get_assertion(self: @TContractState, policy_id: felt252) -> felt252;
    fn dollar_to_wei(ref self: TContractState, assertion_fee: u128) -> u128;
    fn approve_tokens(ref self: TContractState, token_address: ContractAddress, spender: ContractAddress, amount: u256) -> bool;
    fn push_price(ref self: TContractState, assertion_id: felt252, price: u256);
}

#[derive(Clone, Drop, Serde, starknet::Store)]
struct Policy { 
    policy_id: felt252,
    potential_outcome: ByteArray,
    assertedClaimId: felt252,
    policyHolder: ContractAddress,
    coverageAmount: u32,
    coverageType: CoverageType,
    startDate: felt252,
    endDate: felt252,
    isClaimed: bool,
    description: ByteArray,
}

#[derive(Drop, starknet::Store, Serde)]
struct AssertedPolicy {
    assertion_id: felt252,
    policy_id: felt252,
    asserter: ContractAddress,
}

#[derive(Drop, starknet::Store, Serde)]
struct DisputedClaim {
    dispute_id: felt252,
    policy_id: felt252,
    asserter: ContractAddress,
    disputer: ContractAddress,
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
    use super::{ContractAddress, CoverageType, Policy, INFT, AssertedPolicy, contract_address_const, DisputedClaim};
    use core::num::traits::Pow;
    use starknet::storage::{Map, StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Vec, MutableVecTrait};
    use starknet::{get_caller_address, get_contract_address, get_block_timestamp, SyscallResultTrait, syscalls};
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::security::{ReentrancyGuardComponent};
    use openzeppelin::token::{erc721::{ERC721Component, ERC721HooksEmptyImpl}, erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait}};
    use ERC721Component::{InternalTrait as ERC721InternalTrait};
    use OwnableComponent::InternalTrait as OwnableInternalTrait;
    use ReentrancyGuardComponent::InternalTrait as ReentrancyInternalTrait;
    use safe_haven::price_converter_component::PriceConverterComponent;
    use PriceConverterComponent::ConverterImpl;
    use core::num::traits::Zero;
    use core::traits::Into;
    use core::{poseidon::{PoseidonTrait}, hash::{HashStateTrait}};
    use pragma_lib::{abi::{IOptimisticOracleDispatcher, IOptimisticOracleDispatcherTrait}};

    pub mod Errors {
        pub const UNSUCCESSFUL_PAYMENT: felt252 = 'Payment Was Not Successful!';
        pub const CANNOT_DISPUTE_YOUR_CLAIM: felt252 = 'NOT Authorized to Dispute'; // should be not authorized to dispute
        pub const NO_SUCH_ASSERTION: felt252 = 'No Such Assertion';
        pub const POLICY_DOES_NOT_EXIST: felt252 = 'Policy Doesn\'t Exist';
        pub const POLICY_ALREDY_CLAIMED: felt252 = 'Policy Already Claimed';
        pub const INVALID_BUSINESS_COVERAGE: felt252 = 'Invalid Business Coverage';
        pub const INVALID_INDIVIDUAL_COVERAGE: felt252 = 'Invalid Individual Coverage';
        pub const INVALID_EVENT_COVERAGE: felt252 = 'Invalid Event Coverage';
        pub const BOND_TRANSFER_FAILD: felt252 = 'Bond Transfer Failer';
        pub const BOND_APPROVAL_FAILD: felt252 = 'Bond Approval Failed';
    }

    pub const ASSERTION_LIVENESS: u64 = 7200;

    #[storage]
    pub struct Storage {
        policies: Map::<felt252, Policy>,
        policyholder_policies: Map::<ContractAddress, Vec<felt252>>,
        asserted_policies: Map::<felt252, AssertedPolicy>,
        disputed_policies: Map::<felt252, DisputedClaim>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        PolicyCreated: PolicyCreated,
        DisputeResolved: DisputeResolved,
        PolicyAsserted: PolicyAsserted,
        PolicyDisputed: PolicyDisputed,
    }

    #[derive(Drop, starknet::Event)]
    struct PolicyCreated {
        #[key]
        policy_id: felt252,
        policyholder: ContractAddress,
        coverage_type: CoverageType,
    }

    #[derive(Drop, starknet::Event)]
    struct DisputeResolved {
        #[key]
        assertion_id: felt252,
        result: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct PolicyAsserted {
        policy_id: felt252,
        claim_description: ByteArray,
        #[key]
        assertion_id: felt252,
        asserter: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct PolicyDisputed {
        dispute_id: felt252,
        policy_id: felt252,
        #[key]
        assertion_id: felt252,
        disputer: ContractAddress,
    }

    #[embeddable_as(NFTImpl)]
    impl NFT<TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl Reentrancy: ReentrancyGuardComponent::HasComponent<TContractState>,
        impl converter: PriceConverterComponent::HasComponent<TContractState>> of INFT<ComponentState<TContractState>> {

        fn burn(ref self: ComponentState<TContractState>, token_id: felt252) {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            let int_token_id: u256 = token_id.try_into().unwrap();
            erc721.update(Zero::zero(), int_token_id, get_caller_address());
        }

        fn safe_mint(ref self: ComponentState<TContractState>, recipient: ContractAddress, token_id: felt252, data: Span<felt252>) {
            // let mut ownable = get_dep_component_mut!(ref self, Ownable);
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            let int_token_id: u256 = token_id.try_into().unwrap();
            // ownable.assert_only_owner();
            erc721.safe_mint(recipient, int_token_id, data);
        }

        fn safeMint(ref self: ComponentState<TContractState>, recipient: ContractAddress, tokenId: felt252, data: Span<felt252>) {
            self.safe_mint(recipient, tokenId, data);
        }

        fn purchase_policy(ref self: ComponentState<TContractState>, coverage_type: CoverageType, amount: u256, data: Span<felt252>, descrption: ByteArray) -> felt252 {
            let mut reentracy = get_dep_component_mut!(ref self, Reentrancy);
            reentracy.start();
            let erc20 = ERC20ABIDispatcher {contract_address: 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7.try_into().unwrap()};
            let policyholder = get_caller_address();
            let policy_id = self.generate_unique_id(policyholder.try_into().unwrap(), get_block_timestamp().try_into().unwrap());
            
            let policy : Policy = match coverage_type {
                CoverageType::BusinessInterruptions => Policy {
                    policy_id: policy_id,
                    potential_outcome: "Business operations was fully or partially interrupted for a specified period due to the pandemic causing loss of income",
                    assertedClaimId: 0,
                    description: descrption,
                    policyHolder: policyholder,
                    coverageAmount: 1000000, // Higher coverage for business
                    coverageType: CoverageType::BusinessInterruptions,
                    startDate: 1633046400, // Example: Oct 1, 2021
                    endDate: 1664582400, // Example: Oct 1, 2022
                    isClaimed: false,
                },
                CoverageType::IndividualCoverage => Policy {
                    policy_id: policy_id,
                    potential_outcome: "Myself or anyone close to me experienced a financial or personal loss or health deterioration due to the pandemic.",
                    assertedClaimId: 0,
                    description: descrption,
                    policyHolder: policyholder,
                    coverageAmount: 500000, // Medium coverage for personal
                    coverageType: CoverageType::IndividualCoverage,
                    startDate: 1633046400, // Example: Oct 1, 2021
                    endDate: 1664582400, // Example: Oct 1, 2022
                    isClaimed: false,
                },
                CoverageType::EventCancellations => Policy {
                    policy_id: policy_id,
                    potential_outcome: "The scheduled event was fully or partially canceled due to the pandemic causing loss of income",
                    assertedClaimId: 0,
                    description: descrption,
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
            let _premium = self.dollar_to_wei(100000000);
            let isSuccess = erc20.transfer_from(get_caller_address(), get_contract_address(), 0);
            assert(isSuccess, Errors::UNSUCCESSFUL_PAYMENT);
            self.safeMint(get_caller_address(), policy_id, data);
            self.emit(PolicyCreated {policy_id, policyholder, coverage_type});
            reentracy.end();
            policy_id
        }

        fn file_claim(ref self: ComponentState<TContractState>, policy_id: felt252, claim_description: ByteArray) -> felt252 {
            let erc20 = ERC20ABIDispatcher {contract_address: 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7.try_into().unwrap()};
            let policy = self.policies.entry(policy_id).read();
            let policy_clone = policy.clone();
            let asserter: ContractAddress = get_caller_address();
            let oo = IOptimisticOracleDispatcher {contract_address: 0x44ac84b04789b0a2afcdd2eb914f0f9b767a77a95a019ebaadc28d6cacbaeeb.try_into().unwrap()};
            assert(policy.coverageAmount > 0, Errors::POLICY_DOES_NOT_EXIST);
            assert(!policy.isClaimed, Errors::POLICY_ALREDY_CLAIMED);
            let asserted_claim_id = self.generate_claim_id(@policy);
            let updated_policy = Policy {
                policy_id: policy.policy_id,
                potential_outcome: policy.potential_outcome,
                assertedClaimId: asserted_claim_id,
                policyHolder: policy.policyHolder,
                description: policy.description,
                coverageAmount: policy.coverageAmount,
                coverageType: policy.coverageType,
                startDate: policy.startDate,
                endDate: policy.endDate,
                isClaimed: true,
            };
            self.policies.entry(policy_id).write(updated_policy);
            let businessArr: ByteArray = "Business operations was fully or partially interrupted for a specified period due to the pandemic causing loss of income";
            let individualArr: ByteArray = "Myself or anyone close to me experienced a financial or personal loss or health deterioration due to the pandemic.";
            let eventArr: ByteArray = "The scheduled event was fully or partially canceled due to the pandemic causing loss of income";
            let claims_array = array![self.hash_byte_array(@businessArr), self.hash_byte_array(@individualArr), self.hash_byte_array(@eventArr)];
            let business = *claims_array.get(0).unwrap().unbox();
            let individual = *claims_array.get(1).unwrap().unbox();
            let event = *claims_array.get(2).unwrap().unbox();

            match policy_clone.coverageType {
                CoverageType::BusinessInterruptions => assert(self.hash_byte_array(@claim_description) == business, Errors::INVALID_BUSINESS_COVERAGE),
                CoverageType::IndividualCoverage => assert(self.hash_byte_array(@claim_description) == individual, Errors::INVALID_INDIVIDUAL_COVERAGE),
                CoverageType::EventCancellations => assert(self.hash_byte_array(@claim_description) == event, Errors::INVALID_EVENT_COVERAGE),
                _ => assert(false, Errors::POLICY_DOES_NOT_EXIST)
            }
            
            let bond = oo.get_minimum_bond(erc20.contract_address);
            let claim = self.compose_claim(claim_description.clone(), policy_clone.coverageType, policy_clone.description);
            // let success = erc20.transfer_from(asserter, get_contract_address(), bond);
            // assert(success, Errors::BOND_TRANSFER_FAILD);
            erc20.approve(oo.contract_address, self.dollar_to_wei(100000000).try_into().unwrap());
            let assertion_id = oo.assert_truth(claim, asserter, contract_address_const::<0>(), contract_address_const::<0>(), ASSERTION_LIVENESS, erc20, bond, 'ASSERT_TRUTH', 0);
            self.emit(PolicyAsserted {policy_id, claim_description, assertion_id, asserter});
            self.asserted_policies.entry(assertion_id).write(AssertedPolicy {assertion_id: assertion_id, policy_id: policy_id, asserter: asserter});
            assertion_id
        }

        fn dispute_asserted_claim(ref self: ComponentState<TContractState>, assertion_id: felt252) -> felt252{
            let oo = IOptimisticOracleDispatcher {
                contract_address: 0x44ac84b04789b0a2afcdd2eb914f0f9b767a77a95a019ebaadc28d6cacbaeeb.try_into().unwrap()
            };
            let erc20 = ERC20ABIDispatcher {
                contract_address: 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7.try_into().unwrap()
            };
            let bond = oo.get_minimum_bond(erc20.contract_address);
            let asserted_policy = self.asserted_policies.entry(assertion_id).read();
            let policy_id = asserted_policy.policy_id;
            let disputer = get_caller_address();
            let asserter = asserted_policy.asserter;
            assert(asserted_policy.asserter != contract_address_const::<0>(), Errors::NO_SUCH_ASSERTION);
            assert(disputer != asserted_policy.asserter, Errors::CANNOT_DISPUTE_YOUR_CLAIM);
            let success = erc20.transfer_from(disputer, get_contract_address(), bond);
            assert(success, Errors::BOND_TRANSFER_FAILD);
            let is_bond_approved = erc20.approve(oo.contract_address, bond);
            let dispute_id: felt252 = PoseidonTrait::new().update(assertion_id).update(disputer.try_into().unwrap()).finalize();
            assert(is_bond_approved, Errors::BOND_APPROVAL_FAILD);
            oo.dispute_assertion(assertion_id, disputer);
            self.disputed_policies.entry(assertion_id).write(DisputedClaim {dispute_id, policy_id, asserter, disputer});
            self.emit(PolicyDisputed {dispute_id, policy_id, assertion_id, disputer});
            dispute_id
        }

        fn resolve_dispute(ref self: ComponentState<TContractState>, assertion_id: felt252) -> bool {
            let oo = IOptimisticOracleDispatcher {
                contract_address: 0x44ac84b04789b0a2afcdd2eb914f0f9b767a77a95a019ebaadc28d6cacbaeeb.try_into().unwrap()
            };
            let erc20 = ERC20ABIDispatcher {
                contract_address: 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7.try_into().unwrap()
            };
            let asserted_policy = self.asserted_policies.entry(assertion_id).read();
            let disputed_policy = self.disputed_policies.entry(assertion_id).read();
            let policy = self.policies.entry(disputed_policy.policy_id).read();
            assert(asserted_policy.asserter != contract_address_const::<0>(), Errors::NO_SUCH_ASSERTION);
            oo.settle_assertion(assertion_id);
            let bond = oo.get_minimum_bond(erc20.contract_address);
            let result = oo.get_assertion_result(assertion_id);
            let is_disputed = if disputed_policy.disputer != contract_address_const::<0>() {
                true
            } else {
                false
            };

            if !is_disputed || result {
                erc20.transfer(asserted_policy.asserter, bond+policy.coverageAmount.try_into().unwrap());
                self.emit(DisputeResolved { assertion_id, result: true });
                self.burn(policy.policy_id);
                true
            } else {
                erc20.transfer(disputed_policy.disputer, bond);
                // self.emit(DisputeResolved { assertion_id, result: false });
                false
            }
        }

        fn push_price(ref self: ComponentState<TContractState>, assertion_id: felt252, price: u256) {
            let contract_address: ContractAddress = 0xb7940968024a3f9963968226e07904343ba95f2773dadc2fb98863430f1187.try_into().unwrap();
            let mut call_data: Array<felt252> = array![];
            Serde::serialize(@assertion_id, ref call_data);
            Serde::serialize(@price, ref call_data);
            let _res = syscalls::call_contract_syscall(
                contract_address,
                selector!("push_price_by_request_id"),
                call_data.span()
            ).unwrap_syscall();
        }

        fn calculate_premium(ref self: ComponentState<TContractState>, coverage: CoverageType) -> u256 {
            let mut conv = get_dep_component_mut!(ref self, converter);
            match coverage {
                CoverageType::BusinessInterruptions => (2400 * self.calculate_amount(10, 8)) / conv.get_eth_to_usd().try_into().unwrap(),
                CoverageType::EventCancellations => (6000 * self.calculate_amount(10, 8)) / conv.get_eth_to_usd().try_into().unwrap(),
                CoverageType::IndividualCoverage => (600 * self.calculate_amount(10, 8)) / conv.get_eth_to_usd().try_into().unwrap(),
            }
        }

        fn get_policy(self: @ComponentState<TContractState>, policy_id: felt252) -> Policy {
            let policy = self.policies.entry(policy_id).read();
            assert(policy.policyHolder != contract_address_const::<0>(), Errors::POLICY_DOES_NOT_EXIST);
            policy
        }

        fn get_assertion(self: @ComponentState<TContractState>, policy_id: felt252) -> felt252 {
            let assertion = self.asserted_policies.entry(policy_id).read();
            assertion.assertion_id
        }

        fn dollar_to_wei(ref self: ComponentState<TContractState>, assertion_fee: u128) -> u128 {
            let mut conv = get_dep_component_mut!(ref self, converter);
            let price_in_usd = conv.get_eth_to_usd();
            (assertion_fee * self.calculate_amount(10, conv.get_decimals_eth()).try_into().unwrap() * 1000000000000000000) / (price_in_usd * self.calculate_amount(10, conv.get_decimals_eth()).try_into().unwrap())
        }

        fn approve_tokens(
            ref self: ComponentState<TContractState>,
            token_address: ContractAddress,
            spender: ContractAddress,
            amount: u256
        ) -> bool {
            let mut call_data: Array<felt252> = array![];
            Serde::serialize(@spender, ref call_data);
            Serde::serialize(@amount, ref call_data);
        
            let mut res = syscalls::call_contract_syscall(
                token_address,
                selector!("approve"),
                call_data.span()
            ).unwrap_syscall();
        
            Serde::<bool>::deserialize(ref res).unwrap()
        }
    }
    

    #[generate_trait]
    pub impl NFTInternal<TContractState,
        +Drop<TContractState>,
        +HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl converter: PriceConverterComponent::HasComponent<TContractState>
    > of INFTInternal<TContractState> {
        fn initializer(ref self: ComponentState<TContractState>, owner: ContractAddress){
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            let mut ownable = get_dep_component_mut!(ref self, Ownable);
            erc721.initializer("SafeHaven", "FH", "https://aquamarine-holy-mosquito-124.mypinata.cloud/files/bafybeifke37iyx2ozevnqmck3uhpnocij4nsltjq4og7utioh55mhdnuvu?X-Algorithm=PINATA1&X-Date=1736404721&X-Expires=30&X-Method=GET&X-Signature=26e433ef5af65b140719afcb8bdbda825a4085e577d6fcd531af891c9097cd7b");
            ownable.initializer(owner);
        }

        fn calculate_amount(ref self: ComponentState<TContractState>, base: u256, exponent: u32) -> u256 {
            base.pow(exponent.into())
        }

        fn generate_unique_id(ref self: ComponentState<TContractState>, user_address: felt252, timestamp: felt252) -> felt252 {
            let hash = PoseidonTrait::new()
                .update(user_address)
                .update(timestamp)
                .finalize();
            hash
        }

        fn generate_claim_id(ref self: ComponentState<TContractState>, policy: @Policy) -> felt252 {
            PoseidonTrait::new()
            .update(*policy.policy_id)
            .update((*policy.policyHolder).into())
            .update((*policy.coverageAmount).into())
            .update(*policy.startDate)
            .update(*policy.endDate)
            .update(get_block_timestamp().into())
            .finalize()
        }

        fn hash_byte_array(ref self: ComponentState<TContractState>, byte_array: @ByteArray) -> felt252 {
            let mut state = PoseidonTrait::new();
            let mut i: usize = 0;
            loop {
                match byte_array.at(i) {
                    Option::Some(byte) => {
                        state = state.update(byte.into());
                        i += 1;
                    },
                    Option::None => { break; },
                };
            };
            state.finalize()
        }

        fn compose_claim(ref self: ComponentState<TContractState>, outcome: ByteArray, coverage_type: CoverageType, description: ByteArray) -> ByteArray {
            let mut claim: ByteArray = Default::default();

            let coverageTypeStr: ByteArray = match coverage_type {
                CoverageType::BusinessInterruptions => "Business Interruption",
                CoverageType::EventCancellations => "Event Cancellation",
                CoverageType::IndividualCoverage => "Individual Health Coverage",
            };
  
            // Phrases to structure the claim
            let p1: ByteArray = "As of assertion timestamp ";
            let p2: ByteArray = ", the asserted insurance claim outcome is: ";
            let p3: ByteArray = ". The coverage type is: ";
            let p4: ByteArray = ". Additional description: ";
        
            // Get the current block timestamp
            let mut block_timestamp: ByteArray = Default::default();
            block_timestamp.append_word(starknet::get_block_timestamp().into(), 8);
        
            // Construct the full claim string
            claim = ByteArrayTrait::concat(@claim, @p1);             // "As of assertion timestamp "
            claim = ByteArrayTrait::concat(@claim, @block_timestamp); // Add the timestamp
            claim = ByteArrayTrait::concat(@claim, @p2);             // ", the asserted insurance claim outcome is: "
            claim = ByteArrayTrait::concat(@claim, @outcome);        // Add the outcome
            claim = ByteArrayTrait::concat(@claim, @p3);             // ". The coverage type is: "
            claim = ByteArrayTrait::concat(@claim, @coverageTypeStr);  // Add the coverage type
            claim = ByteArrayTrait::concat(@claim, @p4);             // ". Additional description: "
            claim = ByteArrayTrait::concat(@claim, @description);    // Add the description
        
            // Return the composed claim
            claim
        }

        // fn dollar_to_wei(ref self: ComponentState<TContractState>, assertion_fee: u128) -> u128 {
        //     let mut conv = get_dep_component_mut!(ref self, converter);
        //     let price_in_usd = conv.get_eth_to_usd();
        //     (assertion_fee * self.calculate_amount(10, conv.get_decimals_eth()).try_into().unwrap() * 1000000000000000000) / (price_in_usd * self.calculate_amount(10, conv.get_decimals_eth()).try_into().unwrap())
        // }
        
    }
}