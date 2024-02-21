// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Vm} from "forge-std/Vm.sol";
import {IRouteProcessor} from "src/interface/IRouteProcessor.sol"; 
import {SafeERC20, IERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {
    IOrderBookV3,
    IO,
    OrderV2,
    OrderConfigV2,
    TakeOrderConfigV2,
    TakeOrdersConfigV2
} from "rain.orderbook/src/interface/unstable/IOrderBookV3.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol"; 

/// @dev https://polygonscan.com/address/0x0a6e511Fe663827b9cA7e2D2542b20B37fC217A6
IRouteProcessor constant ROUTE_PROCESSOR = IRouteProcessor(address(0x0a6e511Fe663827b9cA7e2D2542b20B37fC217A6));

uint256 constant VAULT_ID = uint256(keccak256("vault"));

// IEON token holder.
address constant POLYGON_IEON_HOLDER = 0xd6756f5aF54486Abda6bd9b1eee4aB0dBa7C3ef2;
// USDT token holder.
address constant POLYGON_USDT_HOLDER = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

/// @dev https://docs.sushi.com/docs/Products/Classic%20AMM/Deployment%20Addresses
/// @dev https://polygonscan.com/address/0xc35DADB65012eC5796536bD9864eD8773aBc74C4
address constant POLYGON_SUSHI_V2_FACTORY = 0xc35DADB65012eC5796536bD9864eD8773aBc74C4;

/// @dev https://polygonscan.com/address/0xd0e9c8f5Fae381459cf07Ec506C1d2896E8b5df6
IERC20 constant IEON_TOKEN = IERC20(0xd0e9c8f5Fae381459cf07Ec506C1d2896E8b5df6);

/// @dev https://polygonscan.com/address/0xc2132D05D31c914a87C6611C10748AEb04B58e8F
IERC20 constant USDT_TOKEN = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);

/// @dev https://docs.sushi.com/docs/Products/Classic%20AMM/Deployment%20Addresses
address constant POLYGON_SUSHI_V2_ROUTER = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

function polygonIeonIo() pure returns (IO memory) {
    return IO(address(IEON_TOKEN), 18, VAULT_ID);
}

function polygonUsdtIo() pure returns (IO memory) {
    return IO(address(USDT_TOKEN), 6, VAULT_ID);
}

