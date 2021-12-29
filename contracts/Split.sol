// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/finance/PaymentSplitterUpgradeable.sol";
import "./MetaObscuraReceiver.sol";

contract Split is
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable,
    PaymentSplitterUpgradeable
{
    modifier onlyStakeHolder() {
        require(shares(_msgSender()) != 0, "must be stakeholder");
        _;
    }

    function init(address[] memory _payees, uint256[] memory _shares)
        public
        initializer
    {
        __Context_init();
        __Ownable_init();
        __PaymentSplitter_init(_payees, _shares);
    }

    function pullFunds(address _escrow, address _currencyAddress)
        public
        onlyStakeHolder
    {
        (bool success, bytes memory data) = _escrow.call(
            abi.encodeWithSelector(
                MetaObscuraReceiver.withdraw.selector,
                _currencyAddress
            )
        );

        require(success, string(data));
    }
}
