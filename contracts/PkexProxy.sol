// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract PkexProxy is Context, TransparentUpgradeableProxy {
    constructor(address _logic)
        payable
        TransparentUpgradeableProxy(_logic, _msgSender(), bytes(""))
    {}
}
