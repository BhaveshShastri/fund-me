//Set funds from users
//Withdraw funds
//Set a minimum  funding value in USD/INR

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

//custom error for gas optimization
error NotOwner();

contract FundMe{
    using PriceConverter for uint256;

    //constant keyword helps to save gas cost
    //declaration convention : MINIMUM_USD
    uint public constant MINIMUM_USD = 50 * 10 ** 18;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    //immutable helps save gas cost
    //declaration convention : i_owner
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable{

        //setting a transaction lower limit of at least 1 eth
        require(msg.value.getConversionRate() > MINIMUM_USD, "Didn't send enough!");  //error message
        //1 eth = 1 * 10 ** 18 wei// require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);


    }

    //run via direct import of AggregatorV3Interface package from chainLink github repo via npm
    function getVersion() public view returns(uint){
        //address source : "https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1"
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }    

    //owner of the wallet
    function withdraw() public onlyOwner{
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //initialize funders wallet address
        funders = new address[](0);

        //to initiate transactions
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call(conventionally most used technique)
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    //extension applicable on top of any function
    modifier onlyOwner {
        // // require(msg.sender == owner);
        // require(msg.sender == msg.sender, "Blasphemy!");
        //to save gas :
        if(msg.sender != msg.sender){ revert NotOwner();}

        //depicts that after 1st line all other lines of targeted function will be executed
        _;
    }

    //if user sends transaction directly via wallet without using fund me function
    //then, recieve/fallback will automatically explicitly call the fund function
    receive() external payable { 
        fund();
    }

    fallback() external payable { 
        fund();
    }
}