// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface ILPinterface {
    function recoverToken(address token) external;
    function getPrice() external view returns(uint256);
    function addLiquidity(address from, uint256 amount)external;
    function releaseToken(uint256 amount, address receiver)external;
}

interface GORAinterface is IERC20 {
    function mint(address reciver,uint256 amount) external;
    function burn(uint256 amount) external;

}

struct User {
    address userWallet;
    uint256 totalInvestment;
    uint256 currentInvestment;
    uint256 lastBuyPrice;
    uint256 totalTokenAllocated;
    uint256 totalSellVolume;
}