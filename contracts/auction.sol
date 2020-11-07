pragma solidity <=0.7.0;

import './main.sol';
import './potat.sol';
import './work.sol';

contract AuctionContractV1{
    
    Master public master;
    POTATO public potato;
    WORK public work;
    
    uint256 auctionId = 100;

    struct Auction {
        uint256 startTime;
        uint256 endTime;
        address highestBidder;
        uint256 bid;
        uint256 reward;
        bool active;
        bool distributed;
    }
    
    mapping(uint256 => Auction) auction;
    
    constructor(address potat,address master_contract,address wrk) public{
        potato = POTATO(potat);
        work = WORK(wrk);
        master = Master(master_contract);
    }

   function placeBid(uint256 bid_amount) public{
      Auction storage a = auction[auctionId];
      require(a.distributed != true,'Already Ended');
      if(a.active == false){
          require(potato.balanceOf(msg.sender)>=bid_amount,'Insufficient Balance');
          a.active == true;
          a.bid = bid_amount;
          a.startTime = block.timestamp;
          a.endTime = block.timestamp + 1 days;
          a.highestBidder = msg.sender;
          a.reward = master.fetchRewards();
      }
      else{
          require(a.bid < bid_amount,'Bid higher to claim');
          require(potato.balanceOf(msg.sender)>=bid_amount,'Insufficient Balance');
          require(block.timestamp < a.endTime,'Bidding Ended');
          a.bid = bid_amount;
          a.highestBidder = msg.sender;
      }
   }
   
   function claim(uint256 _auctionId) public returns(bool){
       Auction storage a = auction[_auctionId];
       require(a.endTime < block.timestamp,'Not Yet Ended');
       require(a.highestBidder == msg.sender,'Only winner can claim');
       require(a.distributed == false,'Already distributed');
       a.distributed = true;
       auctionId = auctionId + 1;
       work.transfer(a.highestBidder,a.reward);
       potato.transfer(a.highestBidder,a.reward);
       return(true);
   }
   
   function fetchAuction(uint256 _auctionId) public view returns(uint256 sTime,uint256 eTime, address hBidder,uint256 hBid, uint256 rEward,bool active,bool distributed){
        Auction storage a = auction[_auctionId];
        return(a.startTime,a.endTime,a.highestBidder,a.bid,a.reward,a.active,a.distributed);
   }
   
   function fetchWinner(uint256 _auctionId) public view returns(address){
      Auction storage a = auction[_auctionId];
      require(block.timestamp > a.endTime,'Not Yet Ended');
      return(a.highestBidder);
   }
   
}