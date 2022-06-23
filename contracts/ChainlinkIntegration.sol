// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

interface IERC20 {
  function transfer(address, uint) external;
}

contract ChainlinkIntegration is VRFConsumerBaseV2 {
  VRFCoordinatorV2Interface COORDINATOR;


  uint64 s_subscriptionId;

  address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

  bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

  uint32 callbackGasLimit = 100000;
  uint16 requestConfirmations = 3;

  uint32 numWords =  2;

  uint256[] public s_randomWords;
  uint256 public s_requestId;
  address s_owner;
  uint rewards=100;
  uint maybe=0;
  event NoLuck(string message);
  event Luck(string message);


  mapping(address=>uint) public winners;

  

  constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    s_subscriptionId = subscriptionId;

  }

  function requestRandomWords() external enoughRewards{
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );if(s_randomWords.length>0){
        
        if(s_randomWords[s_randomWords.length-1]%2==0){
        rewards-=5;
         winners[msg.sender]+=5;
        emit Luck("Here are 5 Rewards! :D");
        }else{
        emit NoLuck("No rewards for you :(");
        }
    }

  }
  
  function fulfillRandomWords( uint256, uint256[] memory randomWords) internal override {
    s_randomWords = randomWords;
  }

  function checkLuck() external enoughRewards{
    if(maybe>0){
      rewards-=3;
      winners[msg.sender]+=3;
      emit Luck("Here are 3 Rewards!");
      maybe--;
    }else{
      emit NoLuck("Sorry it's not your day!");
    }

  }

  function setLuck() external onlyOwner{
    maybe=2;
  }

  function moreRewards() external onlyOwner{
      rewards=100;
  }

  function withdraw(uint amount) external onlyOwner{
    IERC20(0x01BE23585060835E02B77ef475b0Cc51aA1e0709).transfer(s_owner, amount);
  }

  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }
  modifier enoughRewards(){
      require(rewards>0, "No more rewards!");
      _;
  }
}
