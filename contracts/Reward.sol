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

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./libs/RewardDistributionRecipient.sol";

// NOTE: V2 allows setting of rewardsDuration in constructor
contract StakingRewardsV2 is RewardsDistributionRecipient, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public unstakingPeriod = 5 days;
    uint256 public rewardIndex = 0;
    uint256 private _poolId = 0;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public unstakeTime;
    mapping(uint256 => PoolInfo) public pools;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _lockedBalances;
    mapping(address => uint256) private _lastUpdateTime;

    struct PoolInfo {
        uint256 from;
        uint256 to;
        uint256 totalStaked;
        uint256 totalAddresses;
        uint256 totalRewards;
        uint256 rewardRate;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken,
        uint256 _rewardsDuration
    ) {
        require(
            _rewardsDistribution != address(0),
            "Invalid distribution address"
        );
        require(_rewardsToken != address(0), "Invalid rewards token address");
        require(_stakingToken != address(0), "Invalid staking token address");
        require(_rewardsDuration > 1 minutes, "Invalid rewards duration");
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        rewardsDistribution = _rewardsDistribution;
        rewardsDuration = _rewardsDuration;
    }

    /* ========== VIEWS ========== */

    function myStakeInfo()
        external
        view
        returns (
            uint256 _staked,
            uint256 _earned,
            uint256 _locked
        )
    {
        _staked = _balances[msg.sender];
        _earned = earned(msg.sender);
        _locked = _lockedBalances[msg.sender];
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() private view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(_totalSupply)
            );
    }

    function earned(address account) private view returns (uint256) {
        return
            _balances[account]
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount)
        external
        nonReentrant
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);

        // update info
        PoolInfo storage pool = pools[_poolId];
        pool.totalStaked = pool.totalStaked.add(amount);

        if (_balances[msg.sender] == 0)
            pool.totalAddresses = pool.totalAddresses.add(1);

        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    function getTotalRewarded() external view returns (uint256 totalRewarded) {
        for (uint256 i = 1; i <= _poolId; i = i.add(1)) {
            PoolInfo memory pool = pools[i];
            if (pool.from > block.timestamp) break;
            if (pool.to <= block.timestamp) {
                totalRewarded = totalRewarded.add(pool.totalRewards);
                continue;
            }

            uint256 _rewards = pool.rewardRate.mul(
                block.timestamp.sub(pool.from)
            );
            totalRewarded = totalRewarded.add(_rewards);
        }
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() external nonReentrant {
        uint256 totalBalance = _balances[msg.sender].add(
            _lockedBalances[msg.sender]
        );
        stakingToken.safeTransfer(msg.sender, totalBalance);
        emit EmergencyWithdraw(msg.sender, totalBalance);
        _balances[msg.sender] = 0;
        _lockedBalances[msg.sender] = 0;
        rewards[msg.sender] = 0;
        _lastUpdateTime[msg.sender] = block.timestamp;
    }

    function unstake(uint256 amount)
        public
        nonReentrant
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _lockedBalances[msg.sender] = _lockedBalances[msg.sender].add(amount);
        _lastUpdateTime[msg.sender] = block.timestamp;
        unstakeTime[msg.sender] = _lastUpdateTime[msg.sender].add(
            unstakingPeriod
        );

        PoolInfo storage pool = pools[_poolId];
        if (pool.totalStaked > amount)
            pool.totalStaked = pool.totalStaked.sub(amount);
        if (_balances[msg.sender] == 0 && pool.totalAddresses > 0)
            pool.totalAddresses = pool.totalAddresses.sub(1);

        emit Unstaked(msg.sender, amount);
    }

    function claim() external nonReentrant updateReward(msg.sender) {
        require(_lockedBalances[msg.sender] > 0, "have no token to claim");
        require(
            block.timestamp.sub(_lastUpdateTime[msg.sender]) > unstakingPeriod,
            "have no token to claim"
        );
        safeTransferToken(
            stakingToken,
            address(this),
            msg.sender,
            _lockedBalances[msg.sender]
        );
        _lockedBalances[msg.sender] = 0;
        getReward();
    }

    function getReward() private {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function unstakeAll() external {
        unstake(_balances[msg.sender]);
        // getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 reward)
        external
        override
        onlyRewardsDistribution
        updateReward(address(0))
    {
        uint256 totalRewards = reward;
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            totalRewards = totalRewards.add(leftover);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        if (balance < totalRewards) {
            rewardsToken.safeTransferFrom(
                rewardsDistribution,
                address(this),
                totalRewards.sub(balance)
            );
            balance = rewardsToken.balanceOf(address(this));
        }
        require(
            rewardRate <= balance.div(rewardsDuration),
            "Provided reward too high"
        );

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);

        _poolId = _poolId.add(1);
        rewardIndex = _poolId;
        // Add to pools
        PoolInfo memory prev = pools[_poolId.sub(1)];
        uint256 from = prev.to == 0 ? block.timestamp : prev.to;
        pools[_poolId] = PoolInfo({
            from: from,
            to: periodFinish,
            totalRewards: totalRewards,
            totalAddresses: prev.totalAddresses,
            totalStaked: prev.totalStaked,
            rewardRate: rewardRate
        });

        emit RewardAdded(reward);
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(
        address tokenAddress,
        address to,
        uint256 tokenAmount
    ) external onlyRewardsDistribution {
        require(tokenAddress != address(0), "Invalid token address");
        require(
            tokenAddress != address(stakingToken),
            "Cannot withdraw the staking token"
        );
        require(
            tokenAddress != address(rewardsToken),
            "Cannot withdraw the rewards token"
        );

        IERC20(tokenAddress).safeTransfer(to, tokenAmount);
        emit Recovered(tokenAddress, to, tokenAmount);
    }

    function setUnstakePeriod(uint256 _period)
        external
        onlyRewardsDistribution
    {
        uint256 prevPeriod = unstakingPeriod;
        unstakingPeriod = _period;
        emit UnstakePeriodUpdated(prevPeriod, _period);
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

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event Recovered(
        address indexed tokenAddress,
        address indexed to,
        uint256 amount
    );
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event UnstakePeriodUpdated(uint256 oldValue, uint256 newValue);
}

/// @title A StakingRewards contract for earning PKEX with staked PKEX/USDC LP tokens
/// @author PKEX Staking
/// @notice deposited LP tokens will earn PKEX over time at a linearly decreasing rate
contract PkexStakingRewards is StakingRewardsV2 {
    constructor(
        address _distributor,
        address _pkex,
        address _pkexUsdcLp,
        uint256 _duration
    ) StakingRewardsV2(_distributor, _pkex, _pkexUsdcLp, _duration) {}
}
