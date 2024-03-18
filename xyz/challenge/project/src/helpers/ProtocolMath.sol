// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Math} from "openzeppelin/utils/math/Math.sol";

library ProtocolMath {
    uint256 internal constant ONE = 1e18;
    uint256 internal constant MINUTES_1000_YEARS = 525_600_000;

    function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b) / ONE;
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * ONE) / b;
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            return (((a * ONE) - 1) / b) + 1;
        }
    }

    function _decMul(uint256 x, uint256 y) internal pure returns (uint256 decProd) {
        decProd = (x * y + ONE / 2) / ONE;
    }

    function _decPow(uint256 base, uint256 exponent) internal pure returns (uint256) {
        if (exponent == 0) {
            return ONE;
        }

        uint256 y = ONE;
        uint256 x = base;
        uint256 n = Math.min(exponent, MINUTES_1000_YEARS);

        while (n > 1) {
            if (n % 2 != 0) {
                y = _decMul(x, y);
            }
            x = _decMul(x, x);
            n /= 2;
        }

        return _decMul(x, y);
    }

    function _computeHealth(uint256 collateral, uint256 debt, uint256 price) internal pure returns (uint256) {
        return debt > 0 ? collateral * price / debt : type(uint256).max;
    }
}
