// RohCoins ico

// version of solidity
pragma solidity ^0.8.13;

contract rohcoin_ico {

    // intoducing the total number of coins available for sale
    uint public max_rohcoins = 1000000;

    // introducing the usd to coin conversion rate
    uint public usd_to_rohcoins = 1000;

    // introducing the total number of coins bought by the investors
    uint public total_rohcoins_bought = 0;

    // mapping from the investors address to its equity in coins and usd
    mapping(address => uint) equity_rohcoins;
    mapping(address => uint) equity_usd;

    //checking if the investor can buy coins
    modifier can_buy_rohcoins(uint usd_invested) {
        require (usd_invested * usd_to_rohcoins + total_rohcoins_bought <= max_rohcoins);   //the function will run only if this condition is true
        _;
    }

    //getting the equity in coins of an investor
    function equity_in_rohcoins(address investor) external returns (uint) {
        return equity_rohcoins[investor];
    }

    //getting the equity in usd of an investor
    function equity_in_usd(address investor) external returns (uint) {
        return equity_usd[investor];
    }

    // buying coins
    function buy_rohcoins(address investor, uint usd_invested) external
    can_buy_rohcoins(usd_invested) {
       uint rohcoins_bought = usd_invested * usd_to_rohcoins;
        equity_rohcoins[investor] += rohcoins_bought;
        equity_usd[investor] = equity_rohcoins[investor] / 1000;
        total_rohcoins_bought += rohcoins_bought;
    }

    // selling coins
    function sell_rohcoins(address investor, uint rohcoins_sold) external {
        equity_rohcoins[investor] -= rohcoins_sold;
        equity_usd[investor] = equity_rohcoins[investor] / 1000;
        total_rohcoins_bought -= rohcoins_sold;
    }
}
