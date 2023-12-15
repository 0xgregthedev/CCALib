// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Erc20BalancesCCA, IERC20} from "examples/Erc20Balances.sol";
import {CCATest, console} from "test/CCATest.sol";
import {MockERC20} from "solady/test/utils/mocks/MockERC20.sol";

contract Erc20BalancesCCATest is CCATest {
    function bytecode() internal pure override returns (bytes memory) {
        return type(Erc20BalancesCCA).creationCode;
    }

    function test() public {
        address user = address(0x123);
        address[] memory tokens = new address[](1);
        tokens[0] = address(new MockERC20("Mock", "MCK", 18));
        MockERC20(tokens[0]).mint(user, 100);

        args = abi.encode(tokens, user);
        uint256[] memory balances = abi.decode(queryCCA(), (uint256[]));
        assertEq(balances[0], 100);
    }

    function testFuzz(address[] memory tokens, uint256 validTokens, uint256[] memory balances, address user) public {
        validTokens = bound(validTokens, 0, tokens.length);
        user = address(uint160(bound(uint256(uint160(user)), uint256(15), uint256(type(uint160).max))));

        for (uint256 i = 0; i < validTokens; i++) {
            MockERC20 token = new MockERC20("Mock", "MCK", 18);
            tokens[i] = address(token);
            if (i < balances.length) {
                token.mint(user, balances[i]);
            }
        }

        uint256[] memory expectedBalances = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == address(vm)) {
                tokens[i] = address(0);
            }

            (bool success, bytes memory data) =
                safeCall(tokens[i], abi.encodeWithSelector(IERC20.balanceOf.selector, user));

            if (success) {
                expectedBalances[i] = abi.decode(data, (uint256));
            }
        }

        args = abi.encode(tokens, user);
        uint256[] memory actualBalances = abi.decode(queryCCA(), (uint256[]));

        assertEq(actualBalances.length, tokens.length, "length mismatch");
        for (uint256 i = 0; i < actualBalances.length; i++) {
            assertEq(actualBalances[i], expectedBalances[i], "token balance mismatch");
        }
    }
}
