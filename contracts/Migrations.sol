// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Migrations{
    address public owner;
    uint256 public recent_completed_migration;

    modifier restricted(){
        if(msg.sender == owner) _;
    }

    constructor(){
        owner = msg.sender;
    }

    function setCompleted(uint256 completed)  public restricted {
        recent_completed_migration = completed;
    }
}