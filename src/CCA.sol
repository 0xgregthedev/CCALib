// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract CCA {
    /// @param data the abi encoded return data from the CCA
    /// @dev use to return data for CCA
    function returnData(bytes memory data) internal pure {
        assembly {
            return(add(data, 0x20), mload(data))
        }
    }

    /// @param target the address of the contract to call
    /// @param data the abi encoded call data for the target contract
    /// @return bool call success
    /// @return bytes memory the abi encoded return data
    /// @dev use to call a contract from the CCA, avoids calling EOA
    function safeCall(address target, bytes memory data) internal returns (bool, bytes memory) {
        if (isEOA(target)) {
            return (false, "");
        }

        return target.call(data);
    }

    /// @param target the address of the contract to call
    /// @param data the abi encoded call data for the target contract
    /// @return bool call success
    /// @return bytes memory the abi encoded return data
    /// @dev use to call a contract from the CCA, avoids calling EOA
    function safeStaticCall(address target, bytes memory data) internal view returns (bool, bytes memory) {
        if (isEOA(target)) {
            return (false, "");
        }

        return target.staticcall(data);
    }

    /// @param addr the address to check
    /// @return result true if the address is an EOA
    /// @dev use to check if an address has code
    function isEOA(address addr) internal view returns (bool result) {
        assembly {
            result := iszero(extcodesize(addr))
        }
    }
}
