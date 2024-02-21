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

/// @dev https://polygonscan.com/address/0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32
address constant UNI_V2_FACTORY = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;

/// @dev https://polygonscan.com/address/0xd0e9c8f5Fae381459cf07Ec506C1d2896E8b5df6
IERC20 constant IEON_TOKEN = IERC20(0xd0e9c8f5Fae381459cf07Ec506C1d2896E8b5df6);

/// @dev https://polygonscan.com/address/0xc2132D05D31c914a87C6611C10748AEb04B58e8F
IERC20 constant USDT_TOKEN = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);

/// @dev https://polygonscan.com/address/0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270
IERC20 constant WETH_TOKEN = IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);

/// @dev https://docs.sushi.com/docs/Products/Classic%20AMM/Deployment%20Addresses
address constant POLYGON_SUSHI_V2_ROUTER = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

function polygonIeonIo() pure returns (IO memory) {
    return IO(address(IEON_TOKEN), 18, VAULT_ID);
}

function polygonWethIo() pure returns (IO memory) {
    return IO(address(WETH_TOKEN), 18, VAULT_ID);
}

function uint2str(uint256 _i) pure returns (string memory _uintAsString) {
    if (_i == 0) {
        return "0";
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len;
    while (_i != 0) {
        k = k - 1;
        uint8 temp = (48 + uint8(_i - _i / 10 * 10));
        bytes1 b1 = bytes1(temp);
        bstr[k] = b1;
        _i /= 10;
    }
    return string(bstr);
}

library LibTrancheSpreadOrders {
    using Strings for address;

    function getTrancheSpreadBuyOrder(Vm vm, address orderBookSubparser, address uniswapWords)
        internal
        returns (bytes memory trancheRefill)
    {
        string[] memory ffi = new string[](29);
        ffi[0] = "rain";
        ffi[1] = "dotrain";
        ffi[2] = "compose";
        ffi[3] = "-i";
        ffi[4] = "lib/h20.pubstrats/src/tranche-spread.rain";
        ffi[5] = "--entrypoint";
        ffi[6] = "calculate-io";
        ffi[7] = "--entrypoint";
        ffi[8] = "handle-io";
        ffi[9] = "--bind";
        ffi[10] = "distribution-token=0xd0e9c8f5Fae381459cf07Ec506C1d2896E8b5df6";
        ffi[11] = "--bind";
        ffi[12] = "reserve-token=0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270";
        ffi[13] = "--bind";
        ffi[14] = string.concat("tranche-reserve-amount-base=", uint2str(1e18));
        ffi[15] = "--bind";
        ffi[16] = string.concat("tranche-reserve-io-ratio-base=", uint2str(111e16));
        ffi[17] = "--bind";
        ffi[18] = string.concat("spread-ratio=", uint2str(101e16));
        ffi[19] = "--bind";
        ffi[20] = string.concat("tranche-space-edge-guard-threshold=", uint2str(1e16));
        ffi[21] = "--bind";
        ffi[22] = "get-tranche-space='get-real-tranche-space";
        ffi[23] = "--bind";
        ffi[24] = "set-tranche-space='set-real-tranche-space";
        ffi[25] = "--bind";
        ffi[26] = "tranche-reserve-amount-growth='tranche-reserve-amount-growth-constant";
        ffi[27] = "--bind";
        ffi[28] = "tranche-reserve-io-ratio-growth='tranche-reserve-io-ratio-linear";
        trancheRefill = bytes.concat(getSubparserPrelude(orderBookSubparser, uniswapWords), vm.ffi(ffi));
    }

    function getSubparserPrelude(address obSubparser, address uniswapWords) internal pure returns (bytes memory) {
        bytes memory RAINSTRING_OB_SUBPARSER =
            bytes(string.concat("using-words-from ", obSubparser.toHexString(), " ", uniswapWords.toHexString(), " "));
        return RAINSTRING_OB_SUBPARSER;
    }
}

