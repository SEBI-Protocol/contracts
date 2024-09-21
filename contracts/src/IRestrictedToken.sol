// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRestrictedToken is IERC20 {
    // Events
    event WhitelistedSpenderAdded(address spender);
    event WhitelistedSpenderRemoved(address spender);
    event BoundsSet(uint256 lowerBound, uint256 upperBound);

    // Functions to manage whitelisted spenders
    function addWhitelistedSpender(address spender) external;
    function removeWhitelistedSpender(address spender) external;
    function isWhitelistedSpender(address spender) external view returns (bool);

    // Getter functions for bounds
    function getLowerBound() external view returns (uint256);
    function getUpperBound() external view returns (uint256);

    // Function to set bounds
    function setBounds(uint256 _lowerBound, uint256 _upperBound) external;

    // Override ERC20 functions
    function transfer(address recipient, uint256 amount) external override returns (bool);
    function approve(address spender, uint256 amount) external override returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool);

    // Disable burn function
    function burn(uint256 amount) external pure;
}