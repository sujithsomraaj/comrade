pragma solidity <=0.7.3;

import './main.sol';
import './potat.sol';
import './work.sol';

contract StakingV1 is WorkMath{
    
    uint256 public OverallStakes;
    
    Master public master;
    POTATO public potato;
    WORK public work;   
    address public pair;
    uint256 public lastClaim;

    
    constructor(address potat,address master_contract,address wrk,address p_air) public{
        potato = POTATO(potat);
        work = WORK(wrk);
        master = Master(master_contract);
        pair = p_air;
    }
    
    struct Stake {
        uint256 stakingAmount;
        bool active;
    }
    
    mapping(address => Stake) public stake;
    
    function stakeWorkLP(uint256 _amount) public{
        require(IUniswapV2Pair(pair).balanceOf(msg.sender)>=_amount,'Insufficient Funds');
        Stake memory s = stake[msg.sender];
        require(s.active == false,'Already active stake');
        s.stakingAmount = _amount;
        OverallStakes = OverallStakes + _amount; 
        IUniswapV2Pair(pair).transferFrom(msg.sender,address(this),_amount);
    }
    
    function claimOnePercent() public {
       require(msg.sender != address(0),'Only address can claim');
       require(block.timestamp > lastClaim + 1 days,'Recently Claimed');
       uint256 amount = WorkMath.safeDiv(work.balanceOf(address(this)),100);
       uint256 bAmount = WorkMath.safeMul(amount,96);
       lastClaim = block.timestamp;
       work.transfer(msg.sender,amount);
       work.burn(bAmount);
    }
    
    function claimStakingLP() public{
        Stake memory s = stake[msg.sender];
        require(s.active == true,'No Active Stake');
        uint256 a = WorkMath.safeMul(s.stakingAmount,10**18);
        uint256 b = WorkMath.safeDiv(a,OverallStakes);
        uint256 c = WorkMath.safeMul(b,work.balanceOf(address(this)));
        uint256 d = WorkMath.safeMul(c,3);
        uint256 e = WorkMath.safeDiv(d,10**20);
        IUniswapV2Pair(pair).transfer(msg.sender,s.stakingAmount);
        work.transfer(msg.sender,e);
    }
    
}