// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {CCA} from "src/CCA.sol";

abstract contract CCATest is Test {
    bytes internal args;

    function bytecode() internal pure virtual returns (bytes memory) {}

    function deployCCA() internal returns (address addr) {
        bytes memory initCode = abi.encodePacked(bytecode(), args);
        assembly {
            addr := create(0, add(initCode, 0x20), mload(initCode))
        }
    }

    function queryCCA() internal returns (bytes memory retData) {
        address cca = deployCCA();
        assembly {
            let size := extcodesize(cca)
            retData := mload(0x40)
            mstore(0x40, add(retData, add(0x20, size)))
            mstore(retData, size)
            extcodecopy(cca, add(retData, 0x20), 0, size)
        }
    }
}
