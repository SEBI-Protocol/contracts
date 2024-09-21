// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseTestHooks} from "@uniswap/v4-core/src/test/BaseTestHooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {SwapMath} from "@uniswap/v4-core/src/libraries/SwapMath.sol";

contract Hook is BaseTestHooks {
    using PoolIdLibrary for PoolKey;

    IPoolManager public immutable poolManager;

    // Maximum allowed price impact (15%)
    uint256 constant MAX_PRICE_IMPACT = 150000; // 15% with 6 decimal places

    constructor(IPoolManager _poolManager) {
        poolManager = _poolManager;
    }

    function getHookPermissions() public pure returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            noOp: false,
            accessLock: false
        });
    }

    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external
        override
        returns (bytes4)
    {
        // Get the current price (sqrt price X96)
        (uint160 sqrtPriceX96, , ) = poolManager.getSlot0(key.toId());

        // Calculate the price after the swap
        uint128 liquidityDelta = 0; // Assuming no liquidity changes during the swap
        (uint160 sqrtPriceAfterX96, , , ) = SwapMath.computeSwapStep(
            sqrtPriceX96,
            params.sqrtPriceLimitX96 == 0
                ? (params.zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                : params.sqrtPriceLimitX96,
            liquidityDelta,
            params.amountSpecified,
            key.fee
        );

        // Calculate price impact
        uint256 priceImpact;
        if (params.zeroForOne) {
            priceImpact = ((sqrtPriceX96 - sqrtPriceAfterX96) * 1e6) / sqrtPriceX96;
        } else {
            priceImpact = ((sqrtPriceAfterX96 - sqrtPriceX96) * 1e6) / sqrtPriceX96;
        }

        // Revert if price impact is too high
        require(priceImpact <= MAX_PRICE_IMPACT, "Price impact too high");

        return BaseTestHooks.beforeSwap.selector;
    }
}