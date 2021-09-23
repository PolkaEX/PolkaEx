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

pragma solidity 0.5.2;
pragma experimental ABIEncoderV2;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
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

    constructor(IERC20 _token) public {
        require(address(_token) != address(0x0), "Matic token address is not valid");
        pkexToken = _token;
    }

    function token() public view returns (IERC20) {
        return pkexToken;
    }

    function myVestings() public view returns  (Vesting[] memory) {
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
    
    function releaseAll() public {
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
    
    function myNextRelease()  public view returns(Vesting memory){
        Vesting[] memory _vestings = vestings[msg.sender];
        uint256 nextRelease = 0;
        uint256 index = 0;
        for(uint256 i=0; i<_vestings.length; i++){
           if(!_vestings[i].released && (nextRelease == 0 || _vestings[i].releaseTime < nextRelease) && _vestings[i].releaseTime >= block.timestamp){
               nextRelease = _vestings[i].releaseTime;
               index =  i;
           }
        }
        
        if(nextRelease > 0 ) return _vestings[index];
    }

    function removeVesting(uint256 _vestingId) public onlyOwner {
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
    
    function addVesting(address _beneficiary, uint256 _releaseTime, uint256 _amount) private onlyOwner{
        _addVesting( _beneficiary,  _releaseTime, _amount, true);
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

    //Muti Function
    //    [address1],[time1,time2,time3],[amount1,amount2,amount3]
    //    [address2],[time1,time2,time3],[amount1,amount2,amount3]
    //    [address3],[time1,time2,time3],[amount1,amount2,amount3]

    function addMutiVestingInOneAddress(address _beneficiary, uint256[] memory _releaseTimes, uint256[] memory  _amounts) public onlyOwner {
        require(_releaseTimes.length > 0 && _releaseTimes.length == _amounts.length, 'invalid parameters.');

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
    function addMutiVestingInMutiAddress(address[] memory  _beneficiaries, uint256[] memory _releaseTimes, uint256[] memory _amounts) public onlyOwner {
        require(_beneficiaries.length == _releaseTimes.length && _beneficiaries.length == _amounts.length);

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

    function mutiRelease(uint256[] memory _vestingIds ) public {
        for (uint256 index = 0; index < _vestingIds.length; index++) {
            release(_vestingIds[index]);
        }
    }

    function retrieveExcessTokens(uint256 _amount) public onlyOwner {
        require(_amount <= pkexToken.balanceOf(address(this)).sub(tokensToVest), INSUFFICIENT_BALANCE);
        pkexToken.safeTransfer(owner(), _amount);
    }
}