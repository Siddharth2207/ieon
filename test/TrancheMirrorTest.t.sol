// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Vm} from "forge-std/Vm.sol";
import {console2, Test} from "forge-std/Test.sol";
import "test/util/TrancheMirrorUtils.sol";
import "src/TrancheMirror.sol";

contract TrancheMirrorTest is TrancheMirrorUtils { 

    using SafeERC20 for IERC20;

    function testBuyOrderHappyFork() public {
        {
            uint256 depositAmount = 1e10;
            giveTestAccountsTokens(WETH_TOKEN, POLYGON_WETH_HOLDER, ORDER_OWNER, depositAmount);
            depositTokens(ORDER_OWNER, WETH_TOKEN, VAULT_ID, depositAmount);
        }
        OrderV2 memory buyOrder;
        {
            (bytes memory bytecode, uint256[] memory constants) = PARSER.parse(
                    LibTrancheSpreadOrders.getTrancheSpreadOrder(
                        vm, 
                        address(ORDERBOOK_SUPARSER)
                    )
            ); 
            buyOrder = placeOrder(ORDER_OWNER, bytecode, constants, polygonIeonIo(), polygonWethIo());
        }
        takeOrder(buyOrder, BUY_ROUTE);
    }

    function testSellOrderHappyFork() public {
        {
            uint256 depositAmount = 100e18;
            giveTestAccountsTokens(IEON_TOKEN, POLYGON_IEON_HOLDER, ORDER_OWNER, depositAmount);
            depositTokens(ORDER_OWNER, IEON_TOKEN, VAULT_ID, depositAmount);
        }
        OrderV2 memory sellOrder;
        {
            (bytes memory bytecode, uint256[] memory constants) = PARSER.parse(
                    LibTrancheSpreadOrders.getTrancheSpreadOrder(
                        vm, 
                        address(ORDERBOOK_SUPARSER)
                    )
            ); 
            sellOrder = placeOrder(ORDER_OWNER, bytecode, constants, polygonWethIo(), polygonIeonIo());
        }
        takeOrder(sellOrder, SELL_ROUTE);
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
        IO memory input,
        IO memory output
    ) internal returns (OrderV2 memory order) {
        IO[] memory inputs = new IO[](1);
        inputs[0] = input;

        IO[] memory outputs = new IO[](1);
        outputs[0] = output;

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

    function takeOrder(OrderV2 memory order, bytes memory route) internal {
        vm.startPrank(APPROVED_EOA);

        uint256 inputIOIndex = 0;
        uint256 outputIOIndex = 0;

        TakeOrderConfigV2[] memory innerConfigs = new TakeOrderConfigV2[](1);

        innerConfigs[0] = TakeOrderConfigV2(order, inputIOIndex, outputIOIndex, new SignedContextV1[](0));
        TakeOrdersConfigV2 memory takeOrdersConfig =
            TakeOrdersConfigV2(0, type(uint256).max, type(uint256).max, innerConfigs, route);
        ARB_INSTANCE.arb(takeOrdersConfig, 0);
        vm.stopPrank();
    }
}

