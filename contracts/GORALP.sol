// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract GORALP is AccessControl, ReentrancyGuard {

    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    address public Admin;

    address public Controller;


    address immutable public USDT;
    address immutable public GORA;

    uint256 InitialPrice;


    event TransferUSDT(address from, address to, uint256 amount);
    event ETHReceived(address from, uint256 received);
    event OwnershipChanged(address prevAdmin, address newAdmin);

    constructor (address USDTAddress,address GORAAddress,address adminAddress) {
        _grantRole(ADMIN_ROLE,adminAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, adminAddress);
        Admin = adminAddress;
        USDT =  USDTAddress;
        GORA = GORAAddress;
        InitialPrice = 0.01 * 1e18;
    }
 
    function changeOwnership(address newAdmin) public onlyRole(ADMIN_ROLE) nonReentrant(){
        address _temp = Admin;
        _revokeRole(ADMIN_ROLE, Admin);
        _grantRole(ADMIN_ROLE, newAdmin);
        Admin = newAdmin;
        emit OwnershipChanged(_temp, Admin);
    }

    function setController(address _controller) external onlyRole(ADMIN_ROLE) nonReentrant() {
        _grantRole(CONTROLLER_ROLE, _controller);
        Controller = _controller;
    }

    function getPrice() public view returns(uint256) {
        uint256 reservedA = IERC20(USDT).balanceOf(address(this));   //decimal 18
        if(reservedA == 0) {
            return InitialPrice;
        }
        uint256 reservedB = IERC20(GORA).totalSupply(); //decimal 18 AAB
        uint256 price = (reservedA * 1e18)/reservedB;
        if(price == 0) {
            return InitialPrice;
        }
        return price;
    }

    function releaseToken(uint256 amount, address receiver) public nonReentrant() onlyRole(CONTROLLER_ROLE) {
        require(amount > 0, "Invalid amount");
        require(msg.sender == Controller, "controller only can call");
        SafeERC20.safeTransfer(IERC20(USDT), receiver,amount);
        emit TransferUSDT(address(this), receiver, amount);
    }

}