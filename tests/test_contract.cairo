use safe_haven::mocks::policy_NFT_component::MockSafehaven;
use safe_haven::{
    policy_NFT_component::{
        INFT,
        PolicyNFTComponent,
        PolicyNFTComponent::{DisputeResolved, INFTInternal, NFTImpl, PolicyAsserted, PolicyCreated, PolicyDisputed},
    },
    constants::constants::OWNER,
};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpy, declare, spy_events, start_cheat_caller_address, test_address,
};
use starknet::ContractAddress;
use openzeppelin_testing::events::EventSpyExt;

// setup

type ComponentState = PolicyNFTComponent::ComponentState<MockSafehaven::ContractState>;

fn CONTRACT_STATE() -> MockSafehaven::ContractState {
    MockSafehaven::contract_state_for_testing()
}

fn COMPONENT_STATE() -> ComponentState {
    PolicyNFTComponent::component_state_for_testing()
}

fn setup() -> ComponentState {
    let mut state = COMPONENT_STATE();
    state
}

// initializer

#[test]
fn test_initializer() {
    let mut state = COMPONENT_STATE();
    state.initializer(OWNER.try_into().unwrap());
}