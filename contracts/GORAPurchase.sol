// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "./interface/ILPinterface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract Purchase is AccessControl, ReentrancyGuard {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    address public ADMIN;
    address public LPAddress;

    address immutable public USDT;
    address immutable public GORA;

    uint256 MIN_PURCHASE = 100 * 1e18;
    uint256 MAX_PURCHASE = 1000 * 1e18;

    uint256 TOKENALLOCATION_PERMILE = 300;
    uint256 ADMIN_USDT_PERMILE = 500;
    uint256 LP_USDT_PERMILE = 500;

    mapping(address => User) internal userDetails;

    uint256 public totalSaleVolume;

    event LPAdressChanged(address prevAddress, address newAddress);
    event OwnershipChanged(address prevAdmin, address newAdmin);
    event LiquidityAdded(address from, uint256 amount);
    event AdminFeeAdded(uint256 amount);
    event ETHReceived(address from, uint256 received);

    
    constructor(address _admin, address _lpaddress, address _usdt, address _gora)  {
        ADMIN = _admin;
        LPAddress = _lpaddress;
        GORA = _gora;
        USDT = _usdt;
        _grantRole(ADMIN_ROLE, ADMIN);
    }

    //getUserDetails
    function getUserDetails(address user) public view returns(User memory) {
        return(userDetails[user]);
    }

    //changesOwnership
    function changesOwnership(address newAdmin)public onlyRole(ADMIN_ROLE) nonReentrant() {
         address _temp = ADMIN;
        _revokeRole(ADMIN_ROLE, ADMIN);
        _grantRole(ADMIN_ROLE, newAdmin);
        ADMIN = newAdmin;
        emit OwnershipChanged(_temp, ADMIN);
    }

    function withdrawShare() public onlyRole(ADMIN_ROLE) nonReentrant() {
        uint256 amount = IERC20(USDT).balanceOf(address(this));
        require(amount > 0, "Invalid amount");
        SafeERC20.safeTransfer(IERC20(USDT), ADMIN, amount);
    }


    function recoverTokenFromLP(address token) public onlyRole(ADMIN_ROLE) nonReentrant() {
        ILPinterface(LPAddress).recoverToken(token);
    }

    function recoverToken(address token) public onlyRole(ADMIN_ROLE) nonReentrant() {
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(amount > 0, "Invalid amount");
        SafeERC20.safeTransfer(IERC20(token), ADMIN, amount);
    }

    function recoverBNB() public onlyRole(ADMIN_ROLE) nonReentrant() returns (bool sent) {
        uint256 amount = address(this).balance;
        if(amount > 0) {
            (sent, ) = payable(msg.sender).call{value: amount}("");        
        }
        return sent;
    }

    //changeLP address
    function changeLPAddress(address newAddress)public onlyRole(ADMIN_ROLE) nonReentrant() {
        address _temp = LPAddress;
        LPAddress = newAddress; 
        emit LPAdressChanged(_temp, LPAddress);
    }


    //AddLiquidity

    function addLiquidity(uint256 amount) public onlyRole(ADMIN_ROLE) nonReentrant() {
        if(amount > 0) {
            SafeERC20.safeTransferFrom(IERC20(USDT), msg.sender, LPAddress, amount);
        }
        emit LiquidityAdded(ADMIN, amount);
    }

    //Buy 

    function Buy(uint256 amount) external nonReentrant() {
        require(amount >= MIN_PURCHASE, "Buy: minimum purchase limit is 100 USDT");
        require(amount <= MAX_PURCHASE, "Buy: Maximum purchase limit exceeded");
        uint256 lpfee = (amount * LP_USDT_PERMILE)/1000;
        uint256 adminfee = (amount * ADMIN_USDT_PERMILE)/1000;
        uint256 userAllocation = (amount * TOKENALLOCATION_PERMILE)/1000;
        if(totalSaleVolume < 10000 * 1e18) {
            userAllocation = (amount * 500)/1000;
        }
       uint256 tokenAmount = getTokenAmount(userAllocation);
        userDetails[msg.sender] = User(
            msg.sender,
            amount * 2,
            amount * 2,
            ILPinterface(LPAddress).getPrice(),
            tokenAmount,
            0
        );
        totalSaleVolume += amount; 
       if(lpfee > 0) {
            SafeERC20.safeTransferFrom(IERC20(USDT), msg.sender, LPAddress, lpfee);
            emit LiquidityAdded(msg.sender, lpfee);
       }
        if(adminfee > 0) {
            SafeERC20.safeTransferFrom(IERC20(USDT), msg.sender, address(this), adminfee);
            emit AdminFeeAdded(adminfee);
       }
       GORAinterface(GORA).mint(msg.sender,tokenAmount);
    }

   //rebuy 

    function reBuy(uint256 amount) external nonReentrant() {
        require(amount >= MIN_PURCHASE, "Buy: minimum purchase limit is 100 USDT");
        require(amount <= MAX_PURCHASE, "Buy: Maximum purchase limit exceeded");
        uint256 lpfee = (amount * LP_USDT_PERMILE)/1000;
        uint256 adminfee = (amount * ADMIN_USDT_PERMILE)/1000;
        uint256 userAllocation = (amount * TOKENALLOCATION_PERMILE)/1000;
        if(totalSaleVolume < 10000 * 1e18) {
            userAllocation = (amount * 500)/1000;
        }        
        uint256 tokenAmount = getTokenAmount(userAllocation);
        userDetails[msg.sender].totalInvestment +=  amount * 2;
        userDetails[msg.sender].totalTokenAllocated += tokenAmount;
        userDetails[msg.sender].currentInvestment += amount * 2;
        
        totalSaleVolume += amount; 
       if(lpfee > 0) {
            SafeERC20.safeTransferFrom(IERC20(USDT), msg.sender, LPAddress, lpfee);
            emit LiquidityAdded(msg.sender, lpfee);
       }
        if(adminfee > 0) {
            SafeERC20.safeTransferFrom(IERC20(USDT), msg.sender, address(this), adminfee);
            emit AdminFeeAdded(adminfee);
       }
        GORAinterface(GORA).mint(msg.sender,tokenAmount);

    }


    //sell 

    function sell(uint256 amount ) external nonReentrant() {
        require(amount > 0, "purchase: Invalid value");
        uint256 sellAmount = getSellTokenAmount(amount);
        User storage user = userDetails[msg.sender];
        require(user.totalInvestment >= sellAmount, "exceeded the limit");
        require(user.totalTokenAllocated  >= amount, "Sell amount exceeded the allocated volume"); 
        ILPinterface(LPAddress).releaseToken(sellAmount, msg.sender);
        user.totalTokenAllocated -= amount;
        user.currentInvestment -= sellAmount;
        user.totalInvestment -= sellAmount;
        user.totalSellVolume += sellAmount;

        if(sellAmount > 0) {
            SafeERC20.safeTransferFrom(IERC20(GORA), msg.sender, address(this), amount);
            emit AdminFeeAdded(sellAmount);
        }
        GORAinterface(GORA).burn(amount);
    }

     function getSellTokenAmount(uint256 amount) public view returns(uint256 tokenAmount) {
        uint256 tokenPrice = ILPinterface(LPAddress).getPrice();
        uint256 adjustedPrice = (tokenPrice * 82) / 100;
        tokenAmount = (amount * adjustedPrice) / 1e18;
        return tokenAmount;
    }

    function getTokenAmount(uint256 amount) public view  returns(uint256 tokenAmount) {
        uint256 tokenPrice = ILPinterface(LPAddress).getPrice();
        tokenAmount = (amount / tokenPrice) * 1e18;
        return tokenAmount;
    }

    receive() payable external  {
        emit ETHReceived(msg.sender, msg.value);
    }

    fallback() payable external  {
        emit ETHReceived(msg.sender, msg.value);
    }


}
