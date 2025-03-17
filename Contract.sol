// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract EnergyTrading {
    address public owner;
    uint256 public tokenPrice = 0.01 ether;
    
    struct EnergyProducer {
        uint256 energyAvailable;
        uint256 balance;
    }
    
    mapping(address => EnergyProducer) public producers;
    mapping(address => uint256) public consumers;
    
    event EnergySold(address indexed producer, address indexed consumer, uint256 amount);
    event EnergyProduced(address indexed producer, uint256 amount);
    event EnergyPurchased(address indexed consumer, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function produceEnergy(uint256 _amount) external {
        producers[msg.sender].energyAvailable += _amount;
        emit EnergyProduced(msg.sender, _amount);
    }
    
    function purchaseEnergy(address _producer, uint256 _amount) external payable {
        require(msg.value >= _amount * tokenPrice, "Insufficient Ether sent");
        require(producers[_producer].energyAvailable >= _amount, "Not enough energy available");
        
        producers[_producer].energyAvailable -= _amount;
        producers[_producer].balance += msg.value;
        consumers[msg.sender] += _amount;
        
        emit EnergyPurchased(msg.sender, _amount);
        emit EnergySold(_producer, msg.sender, _amount);
    }
    
    function withdrawBalance() external {
        uint256 amount = producers[msg.sender].balance;
        require(amount > 0, "No balance to withdraw");
        producers[msg.sender].balance = 0;
        payable(msg.sender).transfer(amount);
    }
    
    function setTokenPrice(uint256 _price) external onlyOwner {
        tokenPrice = _price;
    }
}

