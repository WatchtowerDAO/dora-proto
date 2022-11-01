// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../interfaces/IERC721.sol";

/// @title DoraAuction.sol
/// @author witwiki (@gritty_69)
/// @notice Contract that runs the auction tournaments for determining Pc 
/// @dev Unlike a trad Auction contract, it requires a confidence parameter during a bid
abstract contract DoraAuction is IERC721 {

    // Events
    event HighestBidIncreased(address indexed bidder, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event AuctionStarted();
    event EndAuction(address indexed winner, uint256 amount);

    // State variables (Static)
    address payable public owner;
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


    /// @dev Basic Constructor with startingBid and nftId
    /// @param _nft address of the NFT contract
    /// @param _nftId id of the NFT 
    /// @param _startingBid starting bid for the auction
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

    /// @notice Starts the auction
    function startAuction()  external {
        require(msg.sender == owner, "Only owner can start the auction");
        require(!auctionStarted, "Auction already started");

        wtrNft.safeTransferFrom(owner, address(this), wtrNftId);
        auctionStarted = true;
        endTime = block.timestamp + 8 days; // typical Time of Closest Approach (TCA) of a Conjunction
        
        emit AuctionStarted();
    }

    /// @notice Ends the auction
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
    
    /// @notice Data Scientists place their bids
    /// @dev Bidders will be required to provide a confidence parameter
    function bidPc() external payable {
        require(auctionStarted, "Auction not started");
        require(block.timestamp < endTime, "Auction ended");
        require(msg.value > highestBid, "Bid too low");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        } 
            
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// @notice Withdraws the bid amount from contract to the owner
    function withdraw() external {
        uint amount = bids[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        
        emit Withdraw(msg.sender, bids[msg.sender]);
    }


    function createTournament (uint256 _tournamentId) returns (bool) {
        var tournament = 
    }



}