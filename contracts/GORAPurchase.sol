// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "./interface/ILPinterface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";



contract Purchase is AccessControl, ReentrancyGuard {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    address public ADMIN;
    address public LPAddress;

    address immutable public BUSD;
    address immutable public GORA;

    uint256 MIN_PURCHASE = 100 * 1e18;
    uint256 MAX_PURCHASE = 1000 * 1e18;

    uint256 TOKENALLOCATION_PERMILE = 300;
    uint256 ADMIN_BUSD_PERMILE = 500;
    uint256 LP_BUSD_PERMILE = 500;

    mapping(address => User) internal userDetails;

    uint256 public totalSaleVolume;

    event LPAdressChanged(address prevAddress, address newAddress);
    event OwnershipChanged(address prevAdmin, address newAdmin);
    event LiquidityAdded(address from, uint256 amount);
    event AdminFeeAdded(uint256 amount);
    event ETHReceived(address from, uint256 received);

    
    constructor(address _admin, address _lpaddress, address _BUSD, address _gora)  {
        ADMIN = _admin;
        LPAddress = _lpaddress;
        GORA = _gora;
        BUSD = _BUSD;
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

    //changeLP address
    function changeLPAddress(address newAddress)public onlyRole(ADMIN_ROLE) nonReentrant() {
        address _temp = LPAddress;
        LPAddress = newAddress; 
        emit LPAdressChanged(_temp, LPAddress);
    }


    //AddLiquidity

    function addLiquidity(uint256 amount) public onlyRole(ADMIN_ROLE) nonReentrant() {
        if(amount > 0) {
            SafeERC20.safeTransferFrom(IERC20(BUSD), msg.sender, LPAddress, amount);
        }
        emit LiquidityAdded(ADMIN, amount);
    }

    //Buy 

    function Buy(uint256 amount) external nonReentrant {
        require(amount >= MIN_PURCHASE, "Buy: minimum purchase limit is 100 BUSD");
        require(amount <= MAX_PURCHASE, "Buy: Maximum purchase limit exceeded");

        address BUSD = BUSD;
        address lpAddr = LPAddress;
        address gora = GORA;

        uint256 totalVolume = totalSaleVolume;
        uint256 lpfee = (amount * LP_BUSD_PERMILE) / 1000;
        uint256 adminfee = (amount * ADMIN_BUSD_PERMILE) / 1000;

        uint256 userAllocation = (totalVolume < 10_000 * 1e18)
            ? (amount * 500) / 1000
            : (amount * TOKENALLOCATION_PERMILE) / 1000;

        uint256 tokenAmount = getTokenAmount(userAllocation);
        uint256 doubledAmount = amount * 2;
        uint256 lpPrice = ILPinterface(lpAddr).getPrice();


        User storage u = userDetails[msg.sender];

        try IERC20(BUSD).transferFrom(msg.sender, lpAddr, lpfee) {
            emit LiquidityAdded(msg.sender, lpfee);
        } catch {
            revert("Buy: LP fee transfer failed");
        }
        try IERC20(BUSD).transferFrom(msg.sender, ADMIN, adminfee) {
            emit AdminFeeAdded(adminfee);
        } catch {
            revert("Buy: Admin fee transfer failed");
        }
        try GORAinterface(gora).mint(msg.sender, tokenAmount) {
        } catch {
            totalSaleVolume -= amount;
            delete userDetails[msg.sender];
            revert("Buy: Token mint failed, refunded");
        }

        if (u.totalSellVolume == 0 && u.totalInvestment == 0) {
            // First-time buyer
            u.userWallet = msg.sender;
            u.totalInvestment = doubledAmount;
            u.currentInvestment = doubledAmount;
            u.lastBuyPrice = lpPrice;
            u.totalTokenAllocated = tokenAmount;
            u.totalSellVolume = 0;
        } else {
            // Repeat buyer (reBuy)
            u.totalInvestment += doubledAmount;
            u.currentInvestment += doubledAmount;
            u.totalTokenAllocated += tokenAmount;
            u.lastBuyPrice = lpPrice;
        }

        unchecked {
            totalSaleVolume = totalVolume + amount;
        }
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
        require(tokenPrice > 0, "Purchase: Invalid price");
        uint256 adjustedPrice = (tokenPrice * 82) / 100;
        tokenAmount = (amount * adjustedPrice) / 1e18;
        return tokenAmount;
    }

    function getTokenAmount(uint256 amount) public view  returns(uint256 tokenAmount) {
        uint256 tokenPrice = ILPinterface(LPAddress).getPrice();
        require(tokenPrice > 0, "Purchase: Invalid price");
        tokenAmount = (amount * 1e18) / tokenPrice;
        return tokenAmount;
    }


}
