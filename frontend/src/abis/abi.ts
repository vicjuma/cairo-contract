export const ABI = [
  {
    type: "impl",
    name: "UpgradeableImpl",
    interface_name: "openzeppelin_upgrades::interface::IUpgradeable",
  },
  {
    type: "interface",
    name: "openzeppelin_upgrades::interface::IUpgradeable",
    items: [
      {
        type: "function",
        name: "upgrade",
        inputs: [
          {
            name: "new_class_hash",
            type: "core::starknet::class_hash::ClassHash",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
    ],
  },
  {
    type: "impl",
    name: "ConverterImpl",
    interface_name:
      "safe_haven::price_converter_component::PriceConverterComponent::IPriceConverter",
  },
  {
    type: "interface",
    name: "safe_haven::price_converter_component::PriceConverterComponent::IPriceConverter",
    items: [
      {
        type: "function",
        name: "get_eth_to_usd",
        inputs: [],
        outputs: [
          {
            type: "core::integer::u128",
          },
        ],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "get_strk_to_usd",
        inputs: [],
        outputs: [
          {
            type: "core::integer::u128",
          },
        ],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "get_decimals_eth",
        inputs: [],
        outputs: [
          {
            type: "core::integer::u32",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "get_decimals_strk",
        inputs: [],
        outputs: [
          {
            type: "core::integer::u32",
          },
        ],
        state_mutability: "view",
      },
    ],
  },
  {
    type: "impl",
    name: "NFTImpl",
    interface_name: "safe_haven::policy_NFT_component::INFT",
  },
  {
    type: "struct",
    name: "core::array::Span::<core::felt252>",
    members: [
      {
        name: "snapshot",
        type: "@core::array::Array::<core::felt252>",
      },
    ],
  },
  {
    type: "enum",
    name: "safe_haven::policy_NFT_component::CoverageType",
    variants: [
      {
        name: "BusinessInterruptions",
        type: "()",
      },
      {
        name: "EventCancellations",
        type: "()",
      },
      {
        name: "IndividualCoverage",
        type: "()",
      },
    ],
  },
  {
    type: "struct",
    name: "core::integer::u256",
    members: [
      {
        name: "low",
        type: "core::integer::u128",
      },
      {
        name: "high",
        type: "core::integer::u128",
      },
    ],
  },
  {
    type: "struct",
    name: "core::byte_array::ByteArray",
    members: [
      {
        name: "data",
        type: "core::array::Array::<core::bytes_31::bytes31>",
      },
      {
        name: "pending_word",
        type: "core::felt252",
      },
      {
        name: "pending_word_len",
        type: "core::integer::u32",
      },
    ],
  },
  {
    type: "enum",
    name: "core::bool",
    variants: [
      {
        name: "False",
        type: "()",
      },
      {
        name: "True",
        type: "()",
      },
    ],
  },
  {
    type: "struct",
    name: "safe_haven::policy_NFT_component::Policy",
    members: [
      {
        name: "policy_id",
        type: "core::felt252",
      },
      {
        name: "potential_outcome",
        type: "core::byte_array::ByteArray",
      },
      {
        name: "assertedClaimId",
        type: "core::felt252",
      },
      {
        name: "policyHolder",
        type: "core::starknet::contract_address::ContractAddress",
      },
      {
        name: "coverageAmount",
        type: "core::integer::u32",
      },
      {
        name: "coverageType",
        type: "safe_haven::policy_NFT_component::CoverageType",
      },
      {
        name: "startDate",
        type: "core::felt252",
      },
      {
        name: "endDate",
        type: "core::felt252",
      },
      {
        name: "isClaimed",
        type: "core::bool",
      },
      {
        name: "description",
        type: "core::byte_array::ByteArray",
      },
    ],
  },
  {
    type: "interface",
    name: "safe_haven::policy_NFT_component::INFT",
    items: [
      {
        type: "function",
        name: "burn",
        inputs: [
          {
            name: "token_id",
            type: "core::felt252",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "safe_mint",
        inputs: [
          {
            name: "recipient",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "token_id",
            type: "core::felt252",
          },
          {
            name: "data",
            type: "core::array::Span::<core::felt252>",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "safeMint",
        inputs: [
          {
            name: "recipient",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "tokenId",
            type: "core::felt252",
          },
          {
            name: "data",
            type: "core::array::Span::<core::felt252>",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "purchase_policy",
        inputs: [
          {
            name: "coverage_type",
            type: "safe_haven::policy_NFT_component::CoverageType",
          },
          {
            name: "amount",
            type: "core::integer::u256",
          },
          {
            name: "data",
            type: "core::array::Span::<core::felt252>",
          },
          {
            name: "descrption",
            type: "core::byte_array::ByteArray",
          },
        ],
        outputs: [
          {
            type: "core::felt252",
          },
        ],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "get_policy",
        inputs: [
          {
            name: "policy_id",
            type: "core::felt252",
          },
        ],
        outputs: [
          {
            type: "safe_haven::policy_NFT_component::Policy",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "calculate_premium",
        inputs: [
          {
            name: "coverage",
            type: "safe_haven::policy_NFT_component::CoverageType",
          },
        ],
        outputs: [
          {
            type: "core::integer::u256",
          },
        ],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "file_claim",
        inputs: [
          {
            name: "policy_id",
            type: "core::felt252",
          },
          {
            name: "claim_description",
            type: "core::byte_array::ByteArray",
          },
        ],
        outputs: [
          {
            type: "core::felt252",
          },
        ],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "dispute_asserted_claim",
        inputs: [
          {
            name: "assertion_id",
            type: "core::felt252",
          },
        ],
        outputs: [
          {
            type: "core::felt252",
          },
        ],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "resolve_dispute",
        inputs: [
          {
            name: "assertion_id",
            type: "core::felt252",
          },
        ],
        outputs: [
          {
            type: "core::bool",
          },
        ],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "get_assertion",
        inputs: [
          {
            name: "policy_id",
            type: "core::felt252",
          },
        ],
        outputs: [
          {
            type: "core::felt252",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "dollar_to_wei",
        inputs: [
          {
            name: "assertion_fee",
            type: "core::integer::u128",
          },
        ],
        outputs: [
          {
            type: "core::integer::u128",
          },
        ],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "approve_tokens",
        inputs: [
          {
            name: "token_address",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "spender",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "amount",
            type: "core::integer::u256",
          },
        ],
        outputs: [
          {
            type: "core::bool",
          },
        ],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "push_price",
        inputs: [
          {
            name: "assertion_id",
            type: "core::felt252",
          },
          {
            name: "price",
            type: "core::integer::u256",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
    ],
  },
  {
    type: "impl",
    name: "PausableImpl",
    interface_name: "openzeppelin_security::interface::IPausable",
  },
  {
    type: "interface",
    name: "openzeppelin_security::interface::IPausable",
    items: [
      {
        type: "function",
        name: "is_paused",
        inputs: [],
        outputs: [
          {
            type: "core::bool",
          },
        ],
        state_mutability: "view",
      },
    ],
  },
  {
    type: "impl",
    name: "OwnableMixinImpl",
    interface_name: "openzeppelin_access::ownable::interface::OwnableABI",
  },
  {
    type: "interface",
    name: "openzeppelin_access::ownable::interface::OwnableABI",
    items: [
      {
        type: "function",
        name: "owner",
        inputs: [],
        outputs: [
          {
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "transfer_ownership",
        inputs: [
          {
            name: "new_owner",
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "renounce_ownership",
        inputs: [],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "transferOwnership",
        inputs: [
          {
            name: "newOwner",
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "renounceOwnership",
        inputs: [],
        outputs: [],
        state_mutability: "external",
      },
    ],
  },
  {
    type: "impl",
    name: "ERC721MixinImpl",
    interface_name: "openzeppelin_token::erc721::interface::ERC721ABI",
  },
  {
    type: "interface",
    name: "openzeppelin_token::erc721::interface::ERC721ABI",
    items: [
      {
        type: "function",
        name: "balance_of",
        inputs: [
          {
            name: "account",
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        outputs: [
          {
            type: "core::integer::u256",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "owner_of",
        inputs: [
          {
            name: "token_id",
            type: "core::integer::u256",
          },
        ],
        outputs: [
          {
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "safe_transfer_from",
        inputs: [
          {
            name: "from",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "to",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "token_id",
            type: "core::integer::u256",
          },
          {
            name: "data",
            type: "core::array::Span::<core::felt252>",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "transfer_from",
        inputs: [
          {
            name: "from",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "to",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "token_id",
            type: "core::integer::u256",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "approve",
        inputs: [
          {
            name: "to",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "token_id",
            type: "core::integer::u256",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "set_approval_for_all",
        inputs: [
          {
            name: "operator",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "approved",
            type: "core::bool",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "get_approved",
        inputs: [
          {
            name: "token_id",
            type: "core::integer::u256",
          },
        ],
        outputs: [
          {
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "is_approved_for_all",
        inputs: [
          {
            name: "owner",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "operator",
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        outputs: [
          {
            type: "core::bool",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "supports_interface",
        inputs: [
          {
            name: "interface_id",
            type: "core::felt252",
          },
        ],
        outputs: [
          {
            type: "core::bool",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "name",
        inputs: [],
        outputs: [
          {
            type: "core::byte_array::ByteArray",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "symbol",
        inputs: [],
        outputs: [
          {
            type: "core::byte_array::ByteArray",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "token_uri",
        inputs: [
          {
            name: "token_id",
            type: "core::integer::u256",
          },
        ],
        outputs: [
          {
            type: "core::byte_array::ByteArray",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "balanceOf",
        inputs: [
          {
            name: "account",
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        outputs: [
          {
            type: "core::integer::u256",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "ownerOf",
        inputs: [
          {
            name: "tokenId",
            type: "core::integer::u256",
          },
        ],
        outputs: [
          {
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "safeTransferFrom",
        inputs: [
          {
            name: "from",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "to",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "tokenId",
            type: "core::integer::u256",
          },
          {
            name: "data",
            type: "core::array::Span::<core::felt252>",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "transferFrom",
        inputs: [
          {
            name: "from",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "to",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "tokenId",
            type: "core::integer::u256",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "setApprovalForAll",
        inputs: [
          {
            name: "operator",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "approved",
            type: "core::bool",
          },
        ],
        outputs: [],
        state_mutability: "external",
      },
      {
        type: "function",
        name: "getApproved",
        inputs: [
          {
            name: "tokenId",
            type: "core::integer::u256",
          },
        ],
        outputs: [
          {
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "isApprovedForAll",
        inputs: [
          {
            name: "owner",
            type: "core::starknet::contract_address::ContractAddress",
          },
          {
            name: "operator",
            type: "core::starknet::contract_address::ContractAddress",
          },
        ],
        outputs: [
          {
            type: "core::bool",
          },
        ],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "tokenURI",
        inputs: [
          {
            name: "tokenId",
            type: "core::integer::u256",
          },
        ],
        outputs: [
          {
            type: "core::byte_array::ByteArray",
          },
        ],
        state_mutability: "view",
      },
    ],
  },
  {
    type: "constructor",
    name: "constructor",
    inputs: [],
  },
  {
    type: "event",
    name: "openzeppelin_token::erc721::erc721::ERC721Component::Transfer",
    kind: "struct",
    members: [
      {
        name: "from",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
      {
        name: "to",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
      {
        name: "token_id",
        type: "core::integer::u256",
        kind: "key",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_token::erc721::erc721::ERC721Component::Approval",
    kind: "struct",
    members: [
      {
        name: "owner",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
      {
        name: "approved",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
      {
        name: "token_id",
        type: "core::integer::u256",
        kind: "key",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_token::erc721::erc721::ERC721Component::ApprovalForAll",
    kind: "struct",
    members: [
      {
        name: "owner",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
      {
        name: "operator",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
      {
        name: "approved",
        type: "core::bool",
        kind: "data",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_token::erc721::erc721::ERC721Component::Event",
    kind: "enum",
    variants: [
      {
        name: "Transfer",
        type: "openzeppelin_token::erc721::erc721::ERC721Component::Transfer",
        kind: "nested",
      },
      {
        name: "Approval",
        type: "openzeppelin_token::erc721::erc721::ERC721Component::Approval",
        kind: "nested",
      },
      {
        name: "ApprovalForAll",
        type: "openzeppelin_token::erc721::erc721::ERC721Component::ApprovalForAll",
        kind: "nested",
      },
    ],
  },
  {
    type: "event",
    name: "safe_haven::price_converter_component::PriceConverterComponent::TokenConverted",
    kind: "struct",
    members: [
      {
        name: "token_type",
        type: "core::felt252",
        kind: "data",
      },
    ],
  },
  {
    type: "event",
    name: "safe_haven::price_converter_component::PriceConverterComponent::Event",
    kind: "enum",
    variants: [
      {
        name: "TokenConverted",
        type: "safe_haven::price_converter_component::PriceConverterComponent::TokenConverted",
        kind: "nested",
      },
    ],
  },
  {
    type: "event",
    name: "safe_haven::policy_NFT_component::PolicyNFTComponent::PolicyCreated",
    kind: "struct",
    members: [
      {
        name: "policy_id",
        type: "core::felt252",
        kind: "key",
      },
      {
        name: "policyholder",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "data",
      },
      {
        name: "coverage_type",
        type: "safe_haven::policy_NFT_component::CoverageType",
        kind: "data",
      },
    ],
  },
  {
    type: "event",
    name: "safe_haven::policy_NFT_component::PolicyNFTComponent::DisputeResolved",
    kind: "struct",
    members: [
      {
        name: "assertion_id",
        type: "core::felt252",
        kind: "key",
      },
      {
        name: "result",
        type: "core::bool",
        kind: "data",
      },
    ],
  },
  {
    type: "event",
    name: "safe_haven::policy_NFT_component::PolicyNFTComponent::PolicyAsserted",
    kind: "struct",
    members: [
      {
        name: "policy_id",
        type: "core::felt252",
        kind: "data",
      },
      {
        name: "claim_description",
        type: "core::byte_array::ByteArray",
        kind: "data",
      },
      {
        name: "assertion_id",
        type: "core::felt252",
        kind: "key",
      },
      {
        name: "asserter",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "data",
      },
    ],
  },
  {
    type: "event",
    name: "safe_haven::policy_NFT_component::PolicyNFTComponent::PolicyDisputed",
    kind: "struct",
    members: [
      {
        name: "dispute_id",
        type: "core::felt252",
        kind: "data",
      },
      {
        name: "policy_id",
        type: "core::felt252",
        kind: "data",
      },
      {
        name: "assertion_id",
        type: "core::felt252",
        kind: "key",
      },
      {
        name: "disputer",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "data",
      },
    ],
  },
  {
    type: "event",
    name: "safe_haven::policy_NFT_component::PolicyNFTComponent::Event",
    kind: "enum",
    variants: [
      {
        name: "PolicyCreated",
        type: "safe_haven::policy_NFT_component::PolicyNFTComponent::PolicyCreated",
        kind: "nested",
      },
      {
        name: "DisputeResolved",
        type: "safe_haven::policy_NFT_component::PolicyNFTComponent::DisputeResolved",
        kind: "nested",
      },
      {
        name: "PolicyAsserted",
        type: "safe_haven::policy_NFT_component::PolicyNFTComponent::PolicyAsserted",
        kind: "nested",
      },
      {
        name: "PolicyDisputed",
        type: "safe_haven::policy_NFT_component::PolicyNFTComponent::PolicyDisputed",
        kind: "nested",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_security::pausable::PausableComponent::Paused",
    kind: "struct",
    members: [
      {
        name: "account",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "data",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_security::pausable::PausableComponent::Unpaused",
    kind: "struct",
    members: [
      {
        name: "account",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "data",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_security::pausable::PausableComponent::Event",
    kind: "enum",
    variants: [
      {
        name: "Paused",
        type: "openzeppelin_security::pausable::PausableComponent::Paused",
        kind: "nested",
      },
      {
        name: "Unpaused",
        type: "openzeppelin_security::pausable::PausableComponent::Unpaused",
        kind: "nested",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferred",
    kind: "struct",
    members: [
      {
        name: "previous_owner",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
      {
        name: "new_owner",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferStarted",
    kind: "struct",
    members: [
      {
        name: "previous_owner",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
      {
        name: "new_owner",
        type: "core::starknet::contract_address::ContractAddress",
        kind: "key",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_access::ownable::ownable::OwnableComponent::Event",
    kind: "enum",
    variants: [
      {
        name: "OwnershipTransferred",
        type: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferred",
        kind: "nested",
      },
      {
        name: "OwnershipTransferStarted",
        type: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferStarted",
        kind: "nested",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_upgrades::upgradeable::UpgradeableComponent::Upgraded",
    kind: "struct",
    members: [
      {
        name: "class_hash",
        type: "core::starknet::class_hash::ClassHash",
        kind: "data",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_upgrades::upgradeable::UpgradeableComponent::Event",
    kind: "enum",
    variants: [
      {
        name: "Upgraded",
        type: "openzeppelin_upgrades::upgradeable::UpgradeableComponent::Upgraded",
        kind: "nested",
      },
    ],
  },
  {
    type: "event",
    name: "openzeppelin_introspection::src5::SRC5Component::Event",
    kind: "enum",
    variants: [],
  },
  {
    type: "event",
    name: "openzeppelin_security::reentrancyguard::ReentrancyGuardComponent::Event",
    kind: "enum",
    variants: [],
  },
  {
    type: "event",
    name: "safe_haven::safehaven::SafeHaven::Event",
    kind: "enum",
    variants: [
      {
        name: "ERC721Event",
        type: "openzeppelin_token::erc721::erc721::ERC721Component::Event",
        kind: "flat",
      },
      {
        name: "converterEvent",
        type: "safe_haven::price_converter_component::PriceConverterComponent::Event",
        kind: "flat",
      },
      {
        name: "policyNFTEvent",
        type: "safe_haven::policy_NFT_component::PolicyNFTComponent::Event",
        kind: "flat",
      },
      {
        name: "PausableEvent",
        type: "openzeppelin_security::pausable::PausableComponent::Event",
        kind: "flat",
      },
      {
        name: "OwnableEvent",
        type: "openzeppelin_access::ownable::ownable::OwnableComponent::Event",
        kind: "flat",
      },
      {
        name: "UpgradeableEvent",
        type: "openzeppelin_upgrades::upgradeable::UpgradeableComponent::Event",
        kind: "flat",
      },
      {
        name: "SRC5Event",
        type: "openzeppelin_introspection::src5::SRC5Component::Event",
        kind: "flat",
      },
      {
        name: "ReentrancyGuardEvent",
        type: "openzeppelin_security::reentrancyguard::ReentrancyGuardComponent::Event",
        kind: "flat",
      },
    ],
  },
] as const;
