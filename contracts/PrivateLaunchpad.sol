/**

██████╗  ██████╗ ██╗     ██╗  ██╗ █████╗ ███████╗██╗  ██╗
██╔══██╗██╔═══██╗██║     ██║ ██╔╝██╔══██╗██╔════╝╚██╗██╔╝
██████╔╝██║   ██║██║     █████╔╝ ███████║█████╗   ╚███╔╝
██╔═══╝ ██║   ██║██║     ██╔═██╗ ██╔══██║██╔══╝   ██╔██╗
██║     ╚██████╔╝███████╗██║  ██╗██║  ██║███████╗██╔╝ ██╗
╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

                     www.polkaex.io

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./libs/WhitelistedRole.sol";

contract PrivateLaunchpad is Ownable, Pausable, WhitelistedRole {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    //Whether to whitelist
    bool public constant isWhite = true;

    uint256 public constant rate = 350; //1000
    uint256 public constant lockRate = 500; // 1000
    uint256 public constant USDCap = 175000 * 10**6; // 175000 USDC
    uint256 public constant TokenCap = 500000 * 10**18;
    uint256 public constant maxGasPrice = 1000000000000; // 1000 Gwei;
    uint256 public constant personCap = 350 * 10**6; // Max 350 USDC
    uint256 public constant personMinCap = 100 * 10**6; // Min 100 USDC

    //Time
    uint256 public startTime;
    uint256 public endTime;
    uint256 public lockTime = 14 days;
    uint256 public lockEndTime;

    IERC20 public immutable USDC;
    IERC20 public immutable Token;

    uint256 public tokenBought;
    uint256 public tokenLocked;

    address public fundWallet;
    address public tokenWallet;

    mapping(address => uint256) public userBought;
    mapping(address => uint256) public userTotalToken;
    mapping(address => uint256) public userLocked;
    mapping(address => uint256) public userUnLocked;

    // 1. Here we need to record the time of a buyToken

    //Total USD Raised
    uint256 public totalUSDRaised;
    //Total Token Raised
    uint256 public totalTokenRaised;

    constructor(
        IERC20 _USDC,
        IERC20 _Token,
        address _fundWallet,
        address _tokenWallet,
        uint256 _startTime,
        uint256 _endTime
    ) {
        require(address(_USDC) != address(0), "Invalid USDC token address");
        require(address(_Token) != address(0), "Invalid token address");
        require(
            address(_fundWallet) != address(0),
            "Invalid fund wallet address"
        );
        require(
            address(_tokenWallet) != address(0),
            "Invalid token wallet address"
        );
        require(
            _startTime > block.timestamp,
            "Start time must be in the future"
        );
        require(
            _endTime > _startTime,
            "Start time must be greater than start time"
        );

        USDC = _USDC;
        Token = _Token;
        fundWallet = _fundWallet;
        tokenWallet = _tokenWallet;
        startTime = _startTime;
        endTime = _endTime;
        lockEndTime = endTime.add(lockTime);
    }

    event tokenTotal(
        uint256 indexed totalUSDRaised,
        uint256 indexed totalTokenRaised
    );

    function buyToken(uint256 amount) external whenNotPaused returns (bool) {
        // Verify the user whitelist
        require(isWhitelisted(msg.sender), "Must be Whitelisted");
        require(startTime <= block.timestamp, "not Open yet.");
        require(block.timestamp <= endTime, "Finished.");
        require(
            userBought[msg.sender].add(amount) <= personCap,
            "Personal Cap"
        );
        require(totalUSDRaised.add(amount) <= USDCap, "Total USD Cap");
        require(
            amount.add(userBought[msg.sender]) >= personMinCap,
            "Min buy cap"
        );
        require(
            tx.gasprice <= maxGasPrice,
            "Crowdsale: beneficiary's max Gas Price exceeded"
        );

        USDC.transferFrom(msg.sender, fundWallet, amount);

        tokenBought = amount.mul(1000).mul(10**18).div(rate).div(10**6); // Token
        tokenLocked = tokenBought.mul(lockRate).mul(10**18).div(1000).div(10**18);

        userLocked[msg.sender] = userLocked[msg.sender].add(tokenLocked);
        userUnLocked[msg.sender] = userUnLocked[msg.sender]
            .add(tokenBought)
            .sub(tokenLocked);
        userTotalToken[msg.sender] = userUnLocked[msg.sender].add(
            userLocked[msg.sender]
        );

        totalUSDRaised = totalUSDRaised.add(amount);
        totalTokenRaised = totalTokenRaised.add(tokenBought);

        require(totalTokenRaised <= TokenCap, "Total Token Cap");
        userBought[msg.sender] = userBought[msg.sender].add(amount);

        emit tokenTotal(totalUSDRaised, totalTokenRaised);
        return true;
    }

    function withdraw() external whenNotPaused returns (bool) {
        if (block.timestamp >= lockEndTime) {
            require(userLocked[msg.sender] > 0, "Has Lock Token");
            uint256 tokenAmount = userUnLocked[msg.sender].add(
                userLocked[msg.sender]
            );
            userUnLocked[msg.sender] = userLocked[msg.sender] = 0;
            safeTransferToken(Token, tokenWallet, msg.sender, tokenAmount);
        } else {
            require(userUnLocked[msg.sender] > 0, "Nothing to receive");
            uint256 tokenAmount = userUnLocked[msg.sender];
            userUnLocked[msg.sender] = 0;
            safeTransferToken(Token, tokenWallet, msg.sender, tokenAmount);
        }
        return true;
    }

    function addMultiWhitelist(address[] memory addresses)
        external
        onlyOwner
        returns (bool)
    {
        for (uint256 index = 0; index < addresses.length; index++) {
            _addWhitelisted(addresses[index]);
        }
        return true;
    }

    function safeTransferToken(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = token.balanceOf(from);
        if (balance >= amount) token.safeTransferFrom(from, to, amount);
        else token.safeTransferFrom(from, to, balance);
    }
}
