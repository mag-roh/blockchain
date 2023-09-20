//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.2;

contract HotelRoom {

    enum Statuses {Vacant, Occupied}
    Statuses public currentStatus;

    event Occupy (address _occupant, uint _value);

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
        currentStatus = Statuses.Vacant;
    }
    modifier onlyWhileVacant {
        require(currentStatus == Statuses.Vacant, "Currently Occupied!");
        _;
    }
    modifier costs(uint _amount) {
        require(msg.value >= _amount, "Not enough ether provided");
        _;
    }
    function book() public payable onlyWhileVacant costs(2 ether){
        //Check Price
        //require(msg.value >=2, "Not enough ether provided");
        //check availability
        //require(currentStatus == Statuses.Vacant, "Currently Occupied!");
        currentStatus = Statuses.Occupied;
        //owner.transfer(msg.value);
        (bool sent, bytes memory data) = owner.call{value: msg.value}("");//to check whether the customer has paid or not
        require(true);

        emit Occupy(msg.sender, msg.value); 
    }
}