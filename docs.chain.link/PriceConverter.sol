//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//directly imported from github
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//for more details : "https://docs.chain.link/data-feeds/api-reference#aggregatorv3interface"

//library used so that it can be used in other contract
library PriceConverter{
    //from chainlink data feed feature
    function getPrice() internal view returns(uint256){
        /**to interact we need : 
        * address of the test link wallet
        * ABI
        */
        /**
        * Network: Sepolia
        * Data Feed: ETH/USD
        * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        */
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int answer,,,) = priceFeed.latestRoundData();  //ETH to USD
        //returns in 3000.00000000 format
        return uint256(answer * 1e10);  //type formatting(wei)
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint) {
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        uint ethPrice = getPrice();
        uint ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}