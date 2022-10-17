// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


contract DoraAuction {

    // Events
    event Bid(address indexed bidder, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event AuctionStarted();
    event EndAuction(address indexed winner, uint256 amount);

    // State variables (Static)
    address public owner;
    uint public startTime;
    uint public endTime;
    string public stringHash;
    uint public bidIncrement;   // may not be needed

    // State variables (Dynamic)
    bool public auctionStarted;
    bool public auctionEnded;
    address public highestBidder;
    uint public highestBid;
    mapping (address => uint) bids;

    constructor() {
        
    }

    /// @dev Start the auction
    function startAuction()  external {
        
        emit AuctionStarted();
    }

    /// @dev End the auction
    function endAuction() external {
        
        emit EndAuction(highestBidder, highestBid);
    }
    
    /// @dev Place a bid    
    function bidPc() external payable {
        
        emit Bid(msg.sender, msg.value);
    }

    /// @dev Withdraw a bid
    function withdraw() external {
        
        emit Withdraw(msg.sender, bids[msg.sender]);
    }




}