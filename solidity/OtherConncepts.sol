//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.2;

contract Ownable { 
    address owner;

    modifier onlyOwner{
        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor(){
        owner = msg.sender;
    }
}

contract SecretVault {
    string secret;
    constructor(string memory _secret){
        secret = _secret;
    }

     function getSecret() public view returns(string memory){
        return secret;
    }
}
contract MyContract is Ownable { //MyContract inherits from Ownable
    //address owner;
    //string secret;

   /* modifier onlyOwner{
        require(msg.sender == owner, "Must be owner");
        _;
    }*/

    /*constructor(string memory _secret){
        secret = _secret;
        super;
    }

    function getSecret() public view onlyOwner returns(string memory){
        return secret;
    } */
    address secretVault;
    constructor(string memory _secret){
        SecretVault _secretVault = new SecretVault(_secret);
        secretVault = address(_secretVault);
        super;
    }
    function getSecret() public view onlyOwner returns(string memory){
        return SecretVault(secretVault).getSecret();//Getting the secret which was given by the user with address secretVault
    }
}