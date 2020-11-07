pragma solidity <=0.7.3;

import "./router.sol";

interface IMaster{
    function fetchRewards() external view returns(uint256);
}

contract Math {
    
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


contract Master is Math{
    
    UniswapV2Router02 public uniswap;
    address public pair;
    address public work;
    address public potato;
    address public auctionContract;
    address public stakingContract;
    uint256 public current = Math.safeMul(20000000,10**18);
    uint256 public reward;
    uint256 public lastClaim;
    address public deployer;
    
    constructor(address owner,address _pair,address wrk,address potat) public{
        deployer = msg.sender;
        pair = _pair;
        work = wrk;
        potato = potat;
        uniswap = UniswapV2Router02(payable(owner));
        IUniswapV2Pair(pair).approve(owner,20000000*10**18);
        lastClaim = block.timestamp - 1 days;
    }
    
    function updateContract(address auction,address staking) public{
        //require(msg.sender == deployer,'Not enough access'); Uncomment while launch in mainnet
        auctionContract = auction;
        stakingContract = staking;  
    }
    
    function claim() public {
            require(block.timestamp > lastClaim + 1 days,'In Locked Period');
            uint256 a = Math.safeMul(current,8);
            uint256 b = Math.safeDiv(a,125);
            uint256 c = Math.safeMul(current,2);
            uint256 d = Math.safeDiv(c,125);
            uint256 e = Math.safeDiv(a,100);
            current = Math.safeSub(current,e);
            reward = b;
            lastClaim = block.timestamp;
            uniswap.removeLiquidity(work,potato,b,b,b,auctionContract,block.timestamp + 1 days);
            uniswap.removeLiquidity(work,potato,d,d,d,stakingContract,block.timestamp + 1 days);
        }
    
    function fetchRewards() external view returns(uint256){
        return reward;
    }
}
