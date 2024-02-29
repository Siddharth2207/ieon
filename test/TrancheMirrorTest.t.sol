// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Vm} from "forge-std/Vm.sol";
import {console2, Test} from "forge-std/Test.sol";
import "test/util/TrancheMirrorUtils.sol";
import "src/TrancheMirror.sol";

interface IEONStatsTracker{
    function setStatsTracker(address statsTracker) external;
}

contract TrancheMirrorTest is TrancheMirrorUtils { 
    using LibFixedPointDecimalArithmeticOpenZeppelin for uint256;
    using LibFixedPointDecimalScale for uint256;

    using SafeERC20 for IERC20; 

    function testSellBuyOrderHappyFork() public { 
        
        // Deposit Tokens
        {
            uint256 depositAmount = 400000e18;
            giveTestAccountsTokens(IEON_TOKEN, POLYGON_IEON_HOLDER, ORDER_OWNER, depositAmount);
            depositTokens(ORDER_OWNER, IEON_TOKEN, VAULT_ID, depositAmount);
        }
        OrderV2 memory trancheOrder;
        uint256 distributorTokenOut;
        uint256 distributorTokenIn;
        // Add Order to OrderBook
        {   
            
            IO[] memory tokenVaults = new IO[](2);
            tokenVaults[0] = polygonIeonIo();   
            tokenVaults[1] = polygonWethIo();

            (bytes memory bytecode, uint256[] memory constants) = PARSER.parse(
                    LibTrancheSpreadOrders.getTrancheSpreadOrder(
                        vm, 
                        address(ORDERBOOK_SUPARSER)
                    )
            ); 
            trancheOrder = placeOrder(ORDER_OWNER, bytecode, constants, tokenVaults, tokenVaults);
        }
        // Take Order
        {       
            // Move external market so the order clears
            moveExternalPrice(
                address(WETH_TOKEN),
                address(IEON_TOKEN),
                POLYGON_WETH_HOLDER,
                1000e18,
                BUY_ROUTE
            );
            vm.recordLogs();
            takeOrder(trancheOrder, SELL_ROUTE,1,0);

            Vm.Log[] memory entries = vm.getRecordedLogs();
            (,distributorTokenOut) = getContextInputOutput(entries);
        }
    }

    function giveTestAccountsTokens(IERC20 token, address from, address to, uint256 amount) internal {
        vm.startPrank(from);
        token.safeTransfer(to, amount);
        assertEq(token.balanceOf(to), amount);
        vm.stopPrank();
    }

    function depositTokens(address depositor, IERC20 token, uint256 vaultId, uint256 amount) internal {
        vm.startPrank(depositor);
        token.safeApprove(address(ORDERBOOK), amount);
        ORDERBOOK.deposit(address(token), vaultId, amount);
        vm.stopPrank();
    }

    function placeOrder(
        address orderOwner,
        bytes memory bytecode,
        uint256[] memory constants,
        IO[] memory inputs,
        IO[] memory outputs
    ) internal returns (OrderV2 memory order) {
        
        EvaluableConfigV3 memory evaluableConfig = EvaluableConfigV3(EXPRESSION_DEPLOYER, bytecode, constants);

        OrderConfigV2 memory orderConfig = OrderConfigV2(inputs, outputs, evaluableConfig, "");

        vm.startPrank(orderOwner);
        vm.recordLogs();

        (bool stateChanged) = ORDERBOOK.addOrder(orderConfig);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 3);
        (,, order,) = abi.decode(entries[2].data, (address, address, OrderV2, bytes32));
        assertEq(order.owner, orderOwner);
        assertEq(order.handleIO, true);
        assertEq(address(order.evaluable.interpreter), address(INTERPRETER));
        assertEq(address(order.evaluable.store), address(STORE));
        assertEq(stateChanged, true);
    }

    function takeOrder(OrderV2 memory order, bytes memory route, uint256 inputIOIndex, uint256 outputIOIndex) internal {
        vm.startPrank(APPROVED_EOA);

        TakeOrderConfigV2[] memory innerConfigs = new TakeOrderConfigV2[](1);

        innerConfigs[0] = TakeOrderConfigV2(order, inputIOIndex, outputIOIndex, new SignedContextV1[](0));
        TakeOrdersConfigV2 memory takeOrdersConfig =
            TakeOrdersConfigV2(0, type(uint256).max, type(uint256).max, innerConfigs, route);
        ARB_INSTANCE.arb(takeOrdersConfig, 0);
        vm.stopPrank();
    }

    function moveExternalPrice(
        address inputToken,
        address outputToken,
        address tokenHolder,
        uint256 amountIn,
        bytes memory encodedRoute
    ) public {
        // An External Account
        address EXTERNAL_EOA = address(0x654FEf5Fb8A1C91ad47Ba192F7AA81dd3C821427);
        {
            giveTestAccountsTokens(IERC20(inputToken), tokenHolder, EXTERNAL_EOA, amountIn);
        }
        vm.startPrank(EXTERNAL_EOA);

        IERC20(inputToken).safeApprove(address(ROUTE_PROCESSOR), amountIn);

        bytes memory decodedRoute = abi.decode(encodedRoute, (bytes));

        ROUTE_PROCESSOR.processRoute(inputToken, amountIn, outputToken, 0, EXTERNAL_EOA, decodedRoute);
        vm.stopPrank();
    } 

    function getContextInputOutput(Vm.Log[] memory entries) public returns(uint256 input, uint256 output){
        for (uint256 j = 0; j < entries.length; j++) {
            if (entries[j].topics[0] == keccak256("Context(address,uint256[][])")) {
                (, uint256[][] memory context) = abi.decode(entries[j].data, (address, uint256[][]));
                input = context[3][4];
                output = context[4][4];
            }
        }
    }
}
