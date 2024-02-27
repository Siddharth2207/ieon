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

    uint256 constant FORK_BLOCK_NUMBER = 54013718;
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

    function getSellOrderContext(uint256 orderHash) internal view returns (uint256[][] memory context) {
        // Sell Order Context
        context = new uint256[][](5);
        {
            {
                uint256[] memory baseContext = new uint256[](2);
                context[0] = baseContext;
            }
            {
                uint256[] memory callingContext = new uint256[](3);
                // order hash
                callingContext[0] = orderHash;
                // owner
                callingContext[1] = uint256(uint160(address(ORDER_OWNER)));
                // counterparty
                callingContext[2] = uint256(uint160(address(ORDERBOOK)));
                context[1] = callingContext;
            }
            {
                uint256[] memory calculationsContext = new uint256[](0);
                context[2] = calculationsContext;
            }
            {
                uint256[] memory inputsContext = new uint256[](CONTEXT_VAULT_IO_ROWS);
                inputsContext[0] = uint256(uint160(address(WETH_TOKEN)));
                inputsContext[1] = 18;
                context[3] = inputsContext;
            }
            {
                uint256[] memory outputsContext = new uint256[](CONTEXT_VAULT_IO_ROWS);
                outputsContext[0] = uint256(uint160(address(IEON_TOKEN)));
                outputsContext[1] = 18;
                context[4] = outputsContext;
            }
        }
    }

    function getBuyOrderContext(uint256 orderHash) internal view returns (uint256[][] memory context) {
        // Buy Order Context
        context = new uint256[][](5);
        {
            {
                uint256[] memory baseContext = new uint256[](2);
                context[0] = baseContext;
            }
            {
                uint256[] memory callingContext = new uint256[](3);
                // order hash
                callingContext[0] = orderHash;
                // owner
                callingContext[1] = uint256(uint160(address(ORDERBOOK)));
                // counterparty
                callingContext[2] = uint256(uint160(address(ARB_INSTANCE)));
                context[1] = callingContext;
            }
            {
                uint256[] memory calculationsContext = new uint256[](0);
                context[2] = calculationsContext;
            }
            {
                uint256[] memory inputsContext = new uint256[](CONTEXT_VAULT_IO_ROWS);
                inputsContext[0] = uint256(uint160(address(IEON_TOKEN)));
                inputsContext[1] = 18;
                context[3] = inputsContext;
            }
            {
                uint256[] memory outputsContext = new uint256[](CONTEXT_VAULT_IO_ROWS);
                outputsContext[0] = uint256(uint160(address(WETH_TOKEN)));
                outputsContext[1] = 18;
                context[4] = outputsContext;
            }
        }
    }

    function eval(bytes memory rainlang, uint256[][] memory context) public returns (uint256[] memory) {
        (bytes memory bytecode, uint256[] memory constants) = PARSER.parse(rainlang);
        (,, address expression,) = EXPRESSION_DEPLOYER.deployExpression2(bytecode, constants);
        return evalDeployedExpression(expression, ORDER_HASH, context);
    }

    function evalDeployedExpression(address expression, bytes32 orderHash, uint256[][] memory context) public view returns (uint256[] memory) {

        FullyQualifiedNamespace namespace =
            LibNamespace.qualifyNamespace(StateNamespace.wrap(uint256(uint160(ORDER_OWNER))), address(ORDERBOOK));

        (uint256[] memory stack,) = IInterpreterV2(INTERPRETER).eval2(
            IInterpreterStoreV1(address(STORE)),
            namespace,
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), type(uint16).max),
            context,
            new uint256[](0)
        );
        return stack;
    }

}