// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20{

    address public cryptoDevTokenAddress;

    constructor(address _cryptoDevTOkenAddress) ERC20("CryptoDev LP Token","CDLP"){
        require(_cryptoDevTOkenAddress != address(0), "Token address passed is a null address");
        cryptoDevTokenAddress = _cryptoDevTOkenAddress;
    }


    function getReserves() public view returns(uint256){
        return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
    }


    function addLiquidity(uint _amount) public payable returns(uint256){
        uint256 liquidity;
        uint256 ethBalance = address(this).balance;
        uint256 cryptoDevTokenReserves = getReserves();
        ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);

        // if reserves are empty then 
        // transfer cryptpDevToken from user to this contract 
        if(cryptoDevTokenReserves == 0){
            cryptoDevToken.transferFrom(msg.sender, address(this), _amount);

            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        }
        // if reserves are not empty then
        else{
            uint256 ethReserves = ethBalance - msg.value;
            // Ratio should always be maintained so that there are no major price impacts when adding liquidity
            // Ratio here is -> (cryptoDevTokenAmount user can add/cryptoDevTokenReserve in the contract) = (Eth Sent by the user/Eth Reserve in the contract);
            // So doing some maths, (cryptoDevTokenAmount user can add) = (Eth Sent by the user * cryptoDevTokenReserve /Eth Reserve);
            uint256 cryptoDevTokenAmount = (msg.value * cryptoDevTokenReserves) / ethReserves;
            require(_amount >= cryptoDevTokenAmount, "Amount of token sent is less then the minimum tokens required");

            cryptoDevToken.transferFrom(msg.sender, address(this), cryptoDevTokenAmount);

            liquidity = (totalSupply() * msg.value) / ethReserves;
            _mint(msg.sender, liquidity);
        }

        return liquidity;
    }

    function removeLiquidity(uint256 _amount) public returns(uint256, uint256){
        require(_amount > 0, "_amount should be greater than zero");
        uint256 ethReserves = address(this).balance;
        uint256 _totalSupply = totalSupply();

       // The amount of Eth that would be sent back to the user is based on a ratio
       // Ratio is -> (Eth sent back to the user) / (current Eth reserve) = (amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
       // Then by some maths -> (Eth sent back to the user) = (current Eth reserve * amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
        uint256 ethAmount = (ethReserves * _amount) / _totalSupply;

       // The amount of Crypto Dev token that would be sent back to the user is based on a ratio
       // Ratio is -> (Crypto Dev token sent back to the user) / (current Crypto Dev token reserve) = (amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
       // Then by some maths -> (Crypto Dev token sent back to the user) = (current Crypto Dev token reserve * amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
       
       uint256 cryptoDevTokenAmount = (getReserves() * _amount) / _totalSupply; 

        _burn(msg.sender, _amount);

        payable(msg.sender).transfer(ethAmount);

        ERC20(cryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);

        return(ethAmount, cryptoDevTokenAmount);
    }
}