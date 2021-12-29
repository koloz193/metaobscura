// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TestToken is Initializable, ERC20Upgradeable {
    function initialize() public initializer {
        __ERC20_init("TestToken", "TEST");

        _mint(msg.sender, 100000 * 10**decimals());
    }
}
