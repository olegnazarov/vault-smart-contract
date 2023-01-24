// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface DepositableERC20 is IERC20 {
    function deposit() external payable;
}

contract Vault {
    address public wethAddress = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address public owner;

    using SafeERC20 for DepositableERC20;
    DepositableERC20 wethToken = DepositableERC20(wethAddress);

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor() {
        owner = msg.sender;
    }

    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }

    function deposit() external payable{
        uint shares;
        uint wethDeposit = msg.value;
        if (totalSupply == 0) {
            shares = wethDeposit;
        } else {
            shares = (wethDeposit * totalSupply) / wethToken.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        wethToken.deposit{ value: wethDeposit }();
    }

    function withdraw(uint _shares) external payable{
        uint amount = (_shares * wethToken.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        wethToken.transfer(msg.sender, amount);
    }
    
    function getWethBalance() public view returns(uint) {
        return wethToken.balanceOf(address(this));
  }
}
