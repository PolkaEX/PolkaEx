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
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

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