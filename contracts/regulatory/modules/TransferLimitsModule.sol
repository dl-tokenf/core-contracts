// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import {AbstractRegulatoryModule} from "./AbstractRegulatoryModule.sol";
import {TokenF} from "../../TokenF.sol";

abstract contract TransferLimitsModule is AbstractRegulatoryModule {
    uint256 public constant MAX_TRANSFER_LIMIT = type(uint256).max;

    uint256 private _minTransferLimit;
    uint256 private _maxTransferLimit;

    function __TransferLimitsModule_init(
        uint256 minTransferValue_,
        uint256 maxTransferValue_
    ) internal onlyInitializing {
        _minTransferLimit = minTransferValue_;
        _maxTransferLimit = maxTransferValue_;
    }

    function setMinTransferLimit(
        uint256 minTransferLimit_
    ) public virtual onlyRole(_regulatoryModuleRole()) {
        _minTransferLimit = minTransferLimit_;
    }

    function setMaxTransferLimit(
        uint256 maxTransferLimit_
    ) public virtual onlyRole(_regulatoryModuleRole()) {
        _maxTransferLimit = maxTransferLimit_;
    }

    function transferred(
        bytes4,
        address,
        address,
        uint256,
        address,
        bytes memory
    ) public virtual override {}

    function canTransfer(
        bytes4 selector_,
        address,
        address,
        uint256 amount_,
        address,
        bytes memory
    ) public view virtual override returns (bool) {
        TokenF tokenF_ = TokenF(payable(getTokenF()));

        if (
            selector_ == tokenF_.BURN_SELECTOR() ||
            selector_ == tokenF_.FORCED_TRANSFER_SELECTOR() ||
            selector_ == tokenF_.RECOVERY_SELECTOR()
        ) {
            return true;
        }

        return _canTransfer(amount_);
    }

    function getTransferLimits()
        public
        view
        virtual
        returns (uint256 minTransferLimit_, uint256 maxTransferLimit_)
    {
        return (_minTransferLimit, _maxTransferLimit);
    }

    function _canTransfer(uint256 amount_) internal view virtual returns (bool) {
        return _minTransferLimit <= amount_ && amount_ <= _maxTransferLimit;
    }

    uint256[48] private _gap;
}
