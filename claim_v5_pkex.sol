/**
 *Submitted for verification at Etherscan.io on 2021-04-29
*/

/**

██████╗  ██████╗ ██╗     ██╗  ██╗ █████╗ ███████╗██╗  ██╗
██╔══██╗██╔═══██╗██║     ██║ ██╔╝██╔══██╗██╔════╝╚██╗██╔╝
██████╔╝██║   ██║██║     █████╔╝ ███████║█████╗   ╚███╔╝
██╔═══╝ ██║   ██║██║     ██╔═██╗ ██╔══██║██╔══╝   ██╔██╗
██║     ╚██████╔╝███████╗██║  ██╗██║  ██║███████╗██╔╝ ██╗
╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

                     www.polkaex.io

*/

pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {
        return payable(address(uint160(account)));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// File: contracts/pkexTokenVesting.sol

/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract PkexTokenClaim is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private pkexToken;
    uint256 private tokensToVest = 0;
    uint256 private vestingId = 0;
    uint256 public Tokenamount = 0;

    string private constant INSUFFICIENT_BALANCE = "Insufficient balance";
    string private constant INVALID_VESTING_ID = "Invalid vesting id";
    string private constant VESTING_ALREADY_RELEASED = "Vesting already released";
    string private constant INVALID_BENEFICIARY = "Invalid beneficiary address";
    string private constant NOT_VESTED = "Tokens have not vested yet";

    struct Vesting {
        uint256 vestingId;
        uint256 releaseTime;
        uint256 amount;
        // address beneficiary;
        bool released;
    }
    mapping(address => Vesting[]) public vestings;

    event TokenVestingReleased(uint256 indexed vestingId, address indexed beneficiary, uint256 amount);
    event TokenVestingAdded(uint256 indexed vestingId, address indexed beneficiary, uint256 amount);
    event TokenVestingRemoved(uint256 indexed vestingId, address indexed beneficiary, uint256 amount);

    constructor(IERC20 _token) {
        require(address(_token) != address(0x0), "Invalid PKEX token address");
        pkexToken = _token;
    }

    function token() external view returns (IERC20) {
        return pkexToken;
    }

    function myVestings() external view returns  (Vesting[] memory) {
        return vestings[msg.sender];
    }
    function myTokens() public view  returns(uint256 total, uint256 claimed, uint256 available, uint256 unclaimed){
        Vesting[] memory _vestings = vestings[msg.sender];
        for(uint256 i=0; i<_vestings.length; i++){
            total = total.add(_vestings[i].amount);
            if(_vestings[i].released)
                claimed = claimed.add(_vestings[i].amount);
            else {
                if(_vestings[i].releaseTime <= block.timestamp)
                    available = available.add(_vestings[i].amount);
                
                unclaimed = unclaimed.add(_vestings[i].amount);
            }
        }
    }
    
    function releaseAll() external {
        Vesting[] storage _vestings  = vestings[msg.sender];
        (,,uint256 available,) = myTokens();
        require(available > 0,  'No token available to claim');
        
        for(uint256  i  = 0; i < _vestings.length; i++){
            if(!_vestings[i].released && _vestings[i].releaseTime <= block.timestamp){
                _vestings[i].released  = true;
            }
        } 
        
        require(pkexToken.balanceOf(address(this)) >= available, INSUFFICIENT_BALANCE);
        pkexToken.safeTransfer(msg.sender, available);
        emit TokenVestingReleased(0, msg.sender, available);
    }
    
    function myNextRelease()  external view returns(Vesting memory vesting){
        Vesting[] memory _vestings = vestings[msg.sender];
        uint256 nextRelease = 0;
        uint256 index = 0;
        for(uint256 i=0; i<_vestings.length; i++){
           if(!_vestings[i].released && (nextRelease == 0 || _vestings[i].releaseTime < nextRelease) && _vestings[i].releaseTime >= block.timestamp){
               nextRelease = _vestings[i].releaseTime;
               index =  i;
           }
        }
        
        if(nextRelease > 0 ) vesting =  _vestings[index];
    }

    function removeVesting(uint256 _vestingId) external onlyOwner {
        Vesting[] storage _vestings  = vestings[msg.sender];
        uint256 index = 0;
      
        for(uint256  i  = 0; i < _vestings.length; i++){
            if(_vestings[i].vestingId  == _vestingId){
                index = i;
                break;
            }
        }
        
        Vesting storage vesting = _vestings[index];
        
        // Vesting storage vesting = vestings[_vestingId];
        // require(vesting.beneficiary != address(0x0), INVALID_VESTING_ID);
        require(!vesting.released , VESTING_ALREADY_RELEASED);
        vesting.released = true;
        tokensToVest = tokensToVest.sub(vesting.amount);
        emit TokenVestingRemoved(_vestingId, msg.sender, vesting.amount);
    }
    
    function addVesting(address _beneficiary, uint256 _releaseTime, uint256 _amount) external onlyOwner{
        _addVesting( _beneficiary,  _releaseTime, _amount, true);
        Tokenamount = Tokenamount.add(_amount);
    }

    function _addVesting(address _beneficiary, uint256 _releaseTime, uint256 _amount, bool requireTransfer) private onlyOwner{
        require(_beneficiary != address(0x0), INVALID_BENEFICIARY);
        //Diff
        
        if(requireTransfer){
            pkexToken.safeTransferFrom(msg.sender,address(this),_amount);
        }
            
        tokensToVest = tokensToVest.add(_amount);
        vestingId = vestingId.add(1);
        vestings[_beneficiary].push( Vesting({
            vestingId: vestingId,
            // beneficiary: _beneficiary,
            releaseTime: _releaseTime,
            amount: _amount,
            released: false
        }));
        emit TokenVestingAdded(vestingId, _beneficiary, _amount);
    }

    //Multi Function
    //    [address1],[time1,time2,time3],[amount1,amount2,amount3]
    //    [address2],[time1,time2,time3],[amount1,amount2,amount3]
    //    [address3],[time1,time2,time3],[amount1,amount2,amount3]

    function addMultiVestingInOneAddress(address _beneficiary, uint256[] memory _releaseTimes, uint256[] memory  _amounts) external onlyOwner {
        require(_releaseTimes.length > 0 && _releaseTimes.length == _amounts.length, 'Invalid parameter: releaseTimes');

        uint256 _total = 0;
        for (uint256 index = 0; index < _releaseTimes.length; index++) {
            _addVesting(_beneficiary,_releaseTimes[index],_amounts[index], false);
            _total = _total.add(_amounts[index]);
            Tokenamount = Tokenamount.add(_amounts[index]);
        
        }
        if(_total > 0){
            pkexToken.safeTransferFrom(msg.sender,address(this),_total);
        }
    }
    
    
   // [address1,address2,address3,address1,address2,address3,address1,address2,address3],[time1,time1,time1,time2,time2,time2,time3,time3,time3],[amount1,amount1,amount1,amount2,amount2,amount2,amount3,amount3,amount3]
    function addMultiVestingInMultiAddress(address[] memory  _beneficiaries, uint256[] memory _releaseTimes, uint256[] memory _amounts) external onlyOwner {
        require(_beneficiaries.length == _releaseTimes.length && _beneficiaries.length == _amounts.length, 'Invalid parameter: array length must be the same.');

        uint256 _total = 0;
        for (uint256 index = 0; index < _beneficiaries.length; index++) {
            _addVesting(_beneficiaries[index],_releaseTimes[index],_amounts[index], false);
            _total = _total.add(_amounts[index]);
            Tokenamount = Tokenamount.add(_amounts[index]);
        }
        
        if(_total > 0){
            pkexToken.safeTransferFrom(msg.sender,address(this),_total);
        }        
    }

    function release(uint256 _vestingId) public {
        Vesting[] storage _vestings  = vestings[msg.sender];
        uint256 index = 0;
      
        for(uint256  i  = 0; i < _vestings.length; i++){
            if(_vestings[i].vestingId  == _vestingId){
                index = i;
                break;
            }
        }
        
        Vesting storage vesting = _vestings[index];

        if(vesting.amount == 0){
            return;
        }
        // require(vesting.beneficiary != address(0x0), INVALID_VESTING_ID);
        require(!vesting.released , VESTING_ALREADY_RELEASED);
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= vesting.releaseTime, NOT_VESTED);

        require(pkexToken.balanceOf(address(this)) >= vesting.amount, INSUFFICIENT_BALANCE);
        vesting.released = true;
        tokensToVest = tokensToVest.sub(vesting.amount);
        pkexToken.safeTransfer(msg.sender, vesting.amount);
        emit TokenVestingReleased(_vestingId, msg.sender, vesting.amount);
    }

    function multiRelease(uint256[] memory _vestingIds ) external {
        for (uint256 index = 0; index < _vestingIds.length; index++) {
            release(_vestingIds[index]);
        }
    }

    function retrieveExcessTokens(uint256 _amount) external onlyOwner {
        require(_amount <= pkexToken.balanceOf(address(this)).sub(tokensToVest), INSUFFICIENT_BALANCE);
        pkexToken.safeTransfer(owner(), _amount);
    }
}