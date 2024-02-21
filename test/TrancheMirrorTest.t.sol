// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Vm} from "forge-std/Vm.sol";
import {console2, Test} from "forge-std/Test.sol";
import "test/util/TrancheMirrorUtils.sol";
import "src/TrancheMirror.sol";

contract TrancheMirrorTest is TrancheMirrorUtils {
    
    function testParseOrder() public {
        PARSER.parse(
            LibTrancheSpreadOrders.getTrancheSpreadBuyOrder(
                vm,
                address(ORDERBOOK_SUPARSER),
                address(UNISWAP_WORDS)
            )
        );
    }
}

