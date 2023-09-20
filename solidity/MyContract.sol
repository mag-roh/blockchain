pragma solidity ^0.8.19;

contract MyContract {
    string value; //global variable, the value given to the varible will get stored in the blockchain

constructor() {
    value = "myValue";
}
    function get() public view returns(string memory){ //expicit data location needs to be given in solidity since version 0.5.0, thats why memory is writen after string, since no value is changed thats why the function is set to view
        return value;
    }

    function set(string memory _value) public {
        value = _value;
    }

//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.2;

contract MyContract {
    //State variable
    int256 public myInt = 1;
    int8 public myInt8 = 1;
    uint public myUint = 1;//is writen on the blockchain, can be updated
    uint256 public myUint256 = 1;
    uint8 public myUint8 = 1;

    string public myString = "Hello, World!";
    bytes32 public myBytes32 = "Hello, World!";

    address public myAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    struct MyStruct {
        uint256 myUint256;
        string myString;
    }

    MyStruct public mystruct = MyStruct(1, "Hello, World!");
    //Local variable
    function getValue() public pure returns(uint) {
        uint value = 1;
        return value;
    //Arrays
    uint[] public uintArray = [1, 2, 3];
    string[] public stringArray = ["Hello", "World"];
    string[] public values;
    uint256[][] public array2d = [[1 ,2 ,3], [4, 5, 6]];

    function addValue(string memory _value) public {
        values.push(_value);
    }

    function valueCount() public view returns(uint) {
        return values.length;
    }

    //Mapings
    mapping(uint => string) public names;
    mapping(uint => Books) public books;// Library of Books
    mapping(address => mapping(uint => Books)) public myBooks;//The books which are with the person who has a particular address

    struct Books {
        string title;
        string author;
    }
    constructor() {
        names[1] = "Adam";
        names[2] = "Bruce";
        names[3] = "Carl";
    }

    function addBook(uint _id, string memory _title, string memory _author) public {
        books[_id] = Books(_title, _author);

    }

    function addMyBook(uint _id, string memory _title, string memory _author) public {
        myBooks[msg.sender][_id] = Books(_title, _author);
    }
    //Conditionals
    //Loops
    uint[] public numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    address public owner;

    /*constructor() {
        owner = msg.sender;
    }*/
    function countEvenNumbers() public view returns(uint)
    {
        uint count = 0;
        for(uint i = 0; i < numbers.length; i++)
        {
            if(isEvenNumber(numbers[i]))
            count++;
        }
        return count;
    }
    function isEvenNumber(uint _number) public view returns(bool)
    {
        if(_number%2 == 0)
        {
            return true;
        }
        else {
            return false;
        }
    }
    
    function isOwner() public view returns(bool) {
        return(msg.sender == owner);
    }
}
