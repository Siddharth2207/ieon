// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Vm} from "forge-std/Vm.sol";
import {console2, Test} from "forge-std/Test.sol";
import "test/util/TrancheMirrorUtils.sol";
import "src/TrancheMirror.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract TrancheMirrorTest is TrancheMirrorUtils {
    using Strings for uint256;

    function test_trancheModelling() public {
        string memory file = "./test/csvs/tranche-space.csv";
        if (vm.exists(file)) vm.removeFile(file);

        FullyQualifiedNamespace namespace =
            LibNamespace.qualifyNamespace(StateNamespace.wrap(uint256(uint160(ORDER_OWNER))), address(ORDERBOOK));

        uint256[][] memory buyOrderContext = getBuyOrderContext(11223344);


        for (uint256 i = 0; i < 200; i++) {
            uint256 trancheSpace = uint256(1e17 * i); 
            
            address expression;
            {
                (bytes memory bytecode, uint256[] memory constants) = PARSER.parse(
                    LibTrancheSpreadOrders.getTrancheTestSpreadOrder(
                        vm, 
                        address(ORDERBOOK_SUPARSER),
                        trancheSpace,
                        101e16
                    )
                );
                (,, expression,) = EXPRESSION_DEPLOYER.deployExpression2(bytecode, constants); 
            }

            (uint256[] memory buyStack,) = IInterpreterV2(INTERPRETER).eval2(
                IInterpreterStoreV1(address(STORE)),
                namespace,
                LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), type(uint32).max),
                buyOrderContext,
                new uint256[](0)
            );

            string memory line = string.concat(trancheSpace.toString(), ",", buyStack[1].toString(), ",", buyStack[0].toString());

            vm.writeLine(file, line);

        }
    }
}

