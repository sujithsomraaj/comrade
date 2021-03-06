// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.25 <0.7.2;

/* SafeMath functions */

contract WorkMath {
    
  function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  } 

}

interface IWORK {
    
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    
    /**
     * @dev burns 'amount' tokens from the total supply & from his address
     * 
     */
    
    function burn(uint256 amount) external returns (bool);
    
}

contract WORK is WorkMath,IWORK {
    
    string public constant name = "Worker";
    string public constant symbol = "WORK";
    uint256 public constant decimals = 18;
    uint256 public override totalSupply;
    address public owner;

    constructor() public{
        uint256 initalSupply = WorkMath.safeMul(20000000,10**18);
        owner = msg.sender;
        balanceOf[msg.sender]=initalSupply;
        totalSupply+=initalSupply;
        emit Transfer(address(0), owner, initalSupply);
     }


    mapping (address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed from, uint256 value);

    
    function transfer(address _reciever, uint256 _value) public override returns (bool){
         require(balanceOf[msg.sender]>_value);
         balanceOf[msg.sender] = WorkMath.safeSub(balanceOf[msg.sender],_value);
         balanceOf[_reciever] = WorkMath.safeAdd(balanceOf[_reciever],_value);
         emit Transfer(msg.sender,_reciever,_value);
         return true;
    }
    
     function transferFrom( address _from, address _to, uint256 _amount )public override returns (bool) {
     require( _to != address(0));
     require(balanceOf[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
     balanceOf[_from] = WorkMath.safeSub(balanceOf[_from],_amount);
     allowed[_from][msg.sender] = WorkMath.safeSub(allowed[_from][msg.sender],_amount);
     balanceOf[_to] = WorkMath.safeAdd(balanceOf[_to],_amount);
     emit Transfer(_from, _to, _amount);
     return true;
     }
     
     function burn(uint256 _value) public override returns(bool){
         require(balanceOf[msg.sender]>_value);
         balanceOf[msg.sender] = WorkMath.safeSub(balanceOf[msg.sender],_value);
         totalSupply = WorkMath.safeSub(totalSupply,_value);
         emit Burn(msg.sender,_value);
         return true;
    }
     
    function approve(address _spender, uint256 _amount) public override returns (bool) {
         require( _spender != address(0));
         allowed[msg.sender][_spender] = _amount;
         emit  Approval(msg.sender, _spender, _amount);
         return true;
     }
     
     function reverseApprove(address _spender, uint256 _amount) public returns (bool){
        require( _spender != address(0));
        if(WorkMath.safeSub(allowed[msg.sender][_spender],_amount) >= 0){
        allowed[msg.sender][_spender] = WorkMath.safeSub(allowed[msg.sender][_spender],_amount);
        emit  Approval(msg.sender, _spender, WorkMath.safeSub(allowed[msg.sender][_spender],_amount));
        return true;
        }
        return false;
     }
     
     
     function allowance(address _owner, address _spender)public view override returns (uint256 remaining) {
         require( _owner != address(0) && _spender != address(0));
         return allowed[_owner][_spender];
     }
     
}