// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract USDT is ERC20,AccessControl{

    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    address public Admin; 
    

    constructor(address adminAddress)ERC20("GORA","GORA"){ 
        _grantRole(ADMIN_ROLE,adminAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, adminAddress);
        Admin = adminAddress;
        _mint(adminAddress, 100000000*1e18);
    }
    
}



