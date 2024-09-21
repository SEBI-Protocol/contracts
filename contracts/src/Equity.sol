// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ModifiedERC20 is ERC20, Ownable {
    mapping(address => bool) private _whitelistedSpenders;
    uint256 private _range;

    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    // Disable transfer function
    function transfer(address, uint256) public virtual override returns (bool) {
        revert("Transfer function is disabled");
    }

    // Disable transferFrom function
    function transferFrom(address, address, uint256) public virtual override returns (bool) {
        revert("TransferFrom function is disabled");
    }

    // Override approve function to only allow whitelisted spenders
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        require(_whitelistedSpenders[spender], "Spender is not whitelisted");
        return super.approve(spender, amount);
    }

    // Disable _burn function
    function _burn(address, uint256) internal virtual override {
        revert("Burning tokens is disabled");
    }

    // Function to add a whitelisted spender (only owner can call)
    function addWhitelistedSpender(address spender) public onlyOwner {
        _whitelistedSpenders[spender] = true;
    }

    // Function to remove a whitelisted spender (only owner can call)
    function removeWhitelistedSpender(address spender) public onlyOwner {
        _whitelistedSpenders[spender] = false;
    }

    // Function to set range (only owner can call)
    function setRange(uint256 newRange) public onlyOwner {
        require(newRange > 0, "Range must be greater than zero");
        _range = newRange;
    }

    // Getter for range
    function getRange() public view returns (uint256) {
        return _range;
    }
}