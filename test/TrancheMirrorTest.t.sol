// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Vm} from "forge-std/Vm.sol";
import {console2, Test} from "forge-std/Test.sol";
import "test/util/TrancheMirrorUtils.sol";
import "src/TrancheMirror.sol";

contract TrancheMirrorTest is TrancheMirrorUtils {
    
    function testParseOrder() public {
        console2.log("PARSER : ",address(PARSER));
        console2.log("INTERPRETER : ",address(INTERPRETER));
        console2.log("STORE : ",address(STORE));
        console2.log("EXPRESSION_DEPLOYER : ",address(EXPRESSION_DEPLOYER));
        console2.log("ORDERBOOK_SUPARSER : ",address(ORDERBOOK_SUPARSER)); 


        PARSER.parse(
            LibTrancheSpreadOrders.getTrancheSpreadBuyOrder(
                vm,
                address(ORDERBOOK_SUPARSER)
            )
        );
    }

    function testParseOrderRainlang() public {
        console2.log("PARSER : ",address(PARSER));
        console2.log("INTERPRETER : ",address(INTERPRETER));
        console2.log("STORE : ",address(STORE));
        console2.log("EXPRESSION_DEPLOYER : ",address(EXPRESSION_DEPLOYER));
        console2.log("ORDERBOOK_SUPARSER : ",address(ORDERBOOK_SUPARSER)); 

        bytes memory rainlang = "_: decimal18-saturating-sub(2 2);";
        PARSER.parse(
            rainlang
        );
    }
}

