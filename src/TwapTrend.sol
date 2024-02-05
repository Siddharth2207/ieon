// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "src/interface/IOrderBookV3ArbOrderTaker.sol";
import {RainterpreterExpressionDeployerNPE2} from
    "rain.interpreter/src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {RainterpreterParserNPE2} from "rain.interpreter/src/concrete/RainterpreterParserNPE2.sol";
import {
    SourceIndexV2,
    IInterpreterV2,
    IInterpreterStoreV1
} from "rain.interpreter/src/interface/unstable/IInterpreterV2.sol";
import {EvaluableConfigV3} from "rain.interpreter/src/interface/IInterpreterCallerV2.sol";
import {IRouteProcessor} from "src/interface/IRouteProcessor.sol";
import {SafeERC20, IERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/// @dev https://polygonscan.com/address/0x0a6e511Fe663827b9cA7e2D2542b20B37fC217A6
IRouteProcessor constant ROUTE_PROCESSOR = IRouteProcessor(address(0x0a6e511Fe663827b9cA7e2D2542b20B37fC217A6));

uint256 constant VAULT_ID = uint256(keccak256("vault"));

// TRADE token holder.
address constant POLYGON_TRADE_HOLDER = 0xD6216fC19DB775Df9774a6E33526131dA7D19a2c;
// USDT token holder.
address constant POLYGON_USDT_HOLDER = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

/// @dev https://docs.sushi.com/docs/Products/Classic%20AMM/Deployment%20Addresses
/// @dev https://polygonscan.com/address/0xc35DADB65012eC5796536bD9864eD8773aBc74C4
address constant POLYGON_SUSHI_V2_FACTORY = 0xc35DADB65012eC5796536bD9864eD8773aBc74C4;

/// @dev https://docs.sushi.com/docs/Products/Classic%20AMM/Deployment%20Addresses
address constant POLYGON_SUSHI_V2_ROUTER = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

/// @dev https://polygonscan.com/address/0x692AC1e363ae34b6B489148152b12e2785a3d8d6
IERC20 constant POLYGON_TRADE_TOKEN_ADDRESS = IERC20(0x692AC1e363ae34b6B489148152b12e2785a3d8d6);

/// @dev https://polygonscan.com/address/0xc2132D05D31c914a87C6611C10748AEb04B58e8F
IERC20 constant POLYGON_USDT_TOKEN_ADDRESS = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);

IOrderBookV3ArbOrderTaker constant POLYGON_ARB_CONTRACT =
    IOrderBookV3ArbOrderTaker(0x0D7896d70FE84e88CC8e8BaDcB14D612Eee4Bbe0);

address constant APPROVED_EOA = 0x669845c29D9B1A64FFF66a55aA13EB4adB889a88;
address constant APPROVED_COUNTERPARTY = address(POLYGON_ARB_CONTRACT);

RainterpreterExpressionDeployerNPE2 constant POLYGON_DEPLOYER_NPE2 =
    RainterpreterExpressionDeployerNPE2(0xE1E250a234aF6F343062873bf89c9D1a0a659c0b);

RainterpreterParserNPE2 constant POLYGON_PARSER_NPE2 =
    RainterpreterParserNPE2(0xc2D7890077F3EA75c2798D8624E1E0E6ef8C41e6);

address constant POLYGON_INTERPRETER_NPE2 = 0xB7d691B7E3676cb70dB0cDae95797F24Eab6980D;
address constant POLYGON_STORE_NPE2 = 0x0b5a2b0aCFc5B52bf341FAD638B63C9A6f82dcb9;
IOrderBookV3 constant POLYGON_ORDERBOOK = IOrderBookV3(0xDE5aBE2837bc042397D80E37fb7b2C850a8d5a6C);
address constant POLYGON_ORDERBOOKSUBPARSER = 0x8A99456dD0E1CaA187CF6B779cA42EFE94E9C42b;
address constant UNISWAP_WORDS = 0xd97e8e581393055521F813D6889CfcCEDF7847C6;

