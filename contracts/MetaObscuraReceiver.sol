// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/// @title MetaObscuraReceiver
/// @author koloz
/// @notice This contract act as the receiver and claiming interface for MetaObscura.
/// @dev For erc20s sent here we don't keep track explicitly and they're all sent out on withdraw.
contract MetaObscuraReceiver is
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMathUpgradeable for uint256;

    address public metaObscuraCreator;

    address public metaObscuraContract;
    uint256 public cameraTokenId;

    uint256 public creatorCut;
    uint256 public cameraOwnerCut;

    /// The total amount of eth received.
    uint256 public totalReceived;
    uint256 public totalCreatorWithdrawn;
    uint256 public totalCameraOwnerWithdrawn;

    event Withdraw(
        address indexed _receiver,
        address indexed _tokenContract,
        uint256 _amount
    );

    modifier onlyStakeHolder() {
        IERC721Upgradeable erc721 = IERC721Upgradeable(metaObscuraContract);
        require(
            _msgSender() == erc721.ownerOf(cameraTokenId) ||
                _msgSender() == metaObscuraCreator,
            "must be stakeholder"
        );
        _;
    }

    function init(
        address _metaObscuraCreator,
        uint256 _creatorCut,
        address _metaObscuraContract,
        uint256 _cameraTokenId,
        uint256 _cameraOwnerCut
    ) public initializer {
        require(_creatorCut.add(_cameraOwnerCut) == 100);
        require(_metaObscuraCreator != address(0));
        require(_metaObscuraContract != address(0));

        metaObscuraCreator = _metaObscuraCreator;
        metaObscuraContract = _metaObscuraContract;

        cameraTokenId = _cameraTokenId;

        creatorCut = _creatorCut;

        cameraOwnerCut = _cameraOwnerCut;

        __Context_init();
        __Ownable_init();
    }

    function withdraw(address _tokenContract)
        public
        onlyStakeHolder
        nonReentrant
    {
        if (_tokenContract == address(0)) {
            address receiver;
            uint256 amount;

            if (_msgSender() == metaObscuraCreator) {
                receiver = metaObscuraCreator;

                amount = ((totalReceived.mul(creatorCut)).div(100)).sub(
                    totalCreatorWithdrawn
                );

                totalCreatorWithdrawn = totalCreatorWithdrawn.add(amount);
            } else {
                IERC721Upgradeable erc721 = IERC721Upgradeable(
                    metaObscuraContract
                );
                receiver = erc721.ownerOf(cameraTokenId);

                amount = ((totalReceived.mul(cameraOwnerCut)).div(100)).sub(
                    totalCameraOwnerWithdrawn
                );

                totalCameraOwnerWithdrawn = totalCameraOwnerWithdrawn.add(
                    amount
                );
            }

            require(amount != 0, "cant withdraw zero");

            (bool success, bytes memory data) = receiver.call{value: amount}(
                ""
            );

            require(success, string(data));
            emit Withdraw(receiver, _tokenContract, amount);
        } else {
            IERC721Upgradeable erc721 = IERC721Upgradeable(metaObscuraContract);
            IERC20Upgradeable erc20 = IERC20Upgradeable(_tokenContract);
            uint256 total = erc20.balanceOf(address(this));
            uint256 creatorAmount = total.mul(creatorCut).div(100);
            uint256 cameraOwnerAmount = total.mul(cameraOwnerCut).div(100);

            erc20.transfer(metaObscuraCreator, creatorAmount);
            erc20.transfer(erc721.ownerOf(cameraTokenId), cameraOwnerAmount);
            emit Withdraw(metaObscuraCreator, _tokenContract, creatorAmount);
            emit Withdraw(
                erc721.ownerOf(cameraTokenId),
                _tokenContract,
                cameraOwnerAmount
            );
        }
    }

    receive() external payable {
        totalReceived = totalReceived.add(msg.value);
    }
}
