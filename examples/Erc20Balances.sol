// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "src/CCA.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract Erc20BalancesCCA is CCA {
    constructor(address[] memory tokens, address user) payable {
        returnData(abi.encode(cca(tokens, user)));
    }

    /// @param tokens the tokens to get the balances of
    /// @param user the user to get the balances for
    /// @return balances the balances of the tokens for the user
    function cca(address[] memory tokens, address user) public view returns (uint256[] memory balances) {
        balances = new uint[](tokens.length);
        for (uint256 i = 0; i < tokens.length;) {
            (bool success, bytes memory data) =
                safeStaticCall(tokens[i], abi.encodeWithSelector(IERC20.balanceOf.selector, user));
            if (success) {
                balances[i] = abi.decode(data, (uint256));
            }
            unchecked {
                ++i;
            }
        }
    }
}
