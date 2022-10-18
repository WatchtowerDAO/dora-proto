// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../interfaces/IERC721.sol";

abstract contract DoraAuction is IERC721 {

    // Events
    event Bid(address indexed bidder, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event AuctionStarted();
    event EndAuction(address indexed winner, uint256 amount);

    // State variables (Static)
    address payable public owner;
    uint public startTime;
    uint public endTime;
    string public stringHash;
    uint public bidIncrement;   // may not be needed

    IERC721 public wtrNft;
    uint public wtrNftId;

    // State variables (Dynamic)
    bool public auctionStarted;
    bool public auctionEnded;
    address public highestBidder;
    uint public highestBid;
    mapping (address => uint) bids;

    constructor(
        address _nft,
        uint _nftId,
        uint _startingBid
    ) {
        wtrNft = IERC721(_nft);
        wtrNftId = _nftId;

        owner = payable(msg.sender);
        highestBid = _startingBid;
        
    }

    /// @dev Start the auction
    function startAuction()  external {
        require(msg.sender == owner, "Only owner can start the auction");
        require(!auctionStarted, "Auction already started");

        wtrNft.safeTransferFrom(owner, address(this), wtrNftId);
        auctionStarted = true;
        endTime = block.timestamp + 8 days; // typical Time of Closest Approach (TCA) of a Conjunction
        
        emit AuctionStarted();
    }

    /// @dev End the auction
    function endAuction() external {
        require(msg.sender == owner, "Only owner can end the auction");
        require(auctionStarted, "Auction not started");
        require(!auctionEnded, "Auction already ended");
        require(block.timestamp >= endTime, "Auction not ended");
        
        auctionEnded = true;
        if (highestBidder != address(0)) {
            wtrNft.safeTransferFrom(address(this), highestBidder, wtrNftId);
            owner.transfer(highestBid);
        } else {
            wtrNft.safeTransferFrom(address(this), owner, wtrNftId);
        }
            
        emit EndAuction(highestBidder, highestBid);
    }
    
    /// @dev Place a bid    
    function bidPc() external payable {
        require(auctionStarted, "Auction not started");
        require(block.timestamp < endTime, "Auction ended");
        require(msg.value > highestBid, "Bid too low");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        } 
            
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit Bid(msg.sender, msg.value);
    }

    /// @dev Withdraw a bid
    function withdraw() external {
        uint amount = bids[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        
        emit Withdraw(msg.sender, bids[msg.sender]);
    }




}