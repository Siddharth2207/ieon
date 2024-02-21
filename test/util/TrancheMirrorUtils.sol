// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {console2, Test} from "forge-std/Test.sol";
import {
    StateNamespace,
    LibNamespace,
    FullyQualifiedNamespace
} from "rain.orderbook/lib/rain.interpreter/src/lib/ns/LibNamespace.sol";
import {LibEncodedDispatch} from "rain.orderbook/lib/rain.interpreter/src/lib/caller/LibEncodedDispatch.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import "rain.orderbook/lib/rain.math.fixedpoint/src/lib/LibFixedPointDecimalArithmeticOpenZeppelin.sol";
import "rain.orderbook/lib/rain.math.fixedpoint/src/lib/LibFixedPointDecimalScale.sol";
import "src/abstract/RainContracts.sol";
import "src/TrancheMirror.sol";

contract TrancheMirrorUtils is RainContracts, Test {
    using SafeERC20 for IERC20;
    using Strings for address;

    using LibFixedPointDecimalArithmeticOpenZeppelin for uint256;
    using LibFixedPointDecimalScale for uint256;

    uint256 constant FORK_BLOCK_NUMBER = 53784754;
    uint256 constant CONTEXT_VAULT_IO_ROWS = 5;

    function selectPolygonFork() internal {
        uint256 fork = vm.createFork(vm.envString("RPC_URL_POLYGON"));
        vm.selectFork(fork);
        vm.rollFork(FORK_BLOCK_NUMBER);
    }

    bytes32 constant ORDER_HASH = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
    address constant ORDER_OWNER = address(0x19f95a84aa1C48A2c6a7B2d5de164331c86D030C);
    address constant APPROVED_EOA = 0x669845c29D9B1A64FFF66a55aA13EB4adB889a88;
    address constant INPUT_ADDRESS = address(IEON_TOKEN);
    address constant OUTPUT_ADDRESS = address(USDT_TOKEN);

    

    function setUp() public {
        selectPolygonFork();

        deployParser();
        deployStore();
        deployInterpreter();

        deployExpressionDeployer(vm, address(INTERPRETER), address(STORE), address(PARSER));
        deployOrderBookSubparser();
        deployUniswapWords(vm); 
        
        // PARSER = IParserV1(0xc2D7890077F3EA75c2798D8624E1E0E6ef8C41e6);
        // INTERPRETER = IInterpreterV2(0xB7d691B7E3676cb70dB0cDae95797F24Eab6980D);
        // STORE = IInterpreterStoreV2(0x0b5a2b0aCFc5B52bf341FAD638B63C9A6f82dcb9);
        // EXPRESSION_DEPLOYER = IExpressionDeployerV3(0xE1E250a234aF6F343062873bf89c9D1a0a659c0b);
        // ORDERBOOK_SUPARSER = ISubParserV2(0x8A99456dD0E1CaA187CF6B779cA42EFE94E9C42b);
        // UNISWAP_WORDS = ISubParserV2(0xd97e8e581393055521F813D6889CfcCEDF7847C6); 

        ORDERBOOK = IOrderBookV3(0xDE5aBE2837bc042397D80E37fb7b2C850a8d5a6C);
        ARB_IMPLEMENTATION = IOrderBookV3ArbOrderTaker(0x8F29083140559bd1771eDBfB73656A9f676c00Fd);
        ARB_INSTANCE = IOrderBookV3ArbOrderTaker(0x0D7896d70FE84e88CC8e8BaDcB14D612Eee4Bbe0);
        CLONE_FACTORY = ICloneableFactoryV2(0x6d0c39093C21dA1230aCDD911420BBfA353A3FBA);
    }

}