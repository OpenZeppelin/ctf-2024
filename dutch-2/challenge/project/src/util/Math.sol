// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

library Math {
    using FixedPointMathLib for uint128;

    struct Point {
        uint256 x;
        uint256 y;
    }

    function mul(uint256 scalar, Point memory point) internal view returns (Point memory) {
        if (scalar == 0 || (point.x == 0 && point.y == 0)) return Point(1, 1);
        (bool res, bytes memory ret) = address(0x07).staticcall{gas: 6000}(abi.encode(point, scalar));
        if (!res) {
            return Point(1, 1);
        } else {
            return abi.decode(ret, (Point));
        }
    }

    function publicKey(uint256 priv) internal view returns (Point memory) {
        return mul(priv, Point(1, 2));
    }

    function availableTokensAtTime(uint32 start, uint32 end, uint32 current, uint128 cliff, uint128 amount)
        internal
        pure
        returns (uint128)
    {
        if (current > end) {
            return amount;
        } else if (current <= start) {
            return 0;
        } else {
            uint256 cliffAmount = amount.mulDivDown(cliff, 1e18);

            return uint128(cliffAmount + uint128(amount - cliffAmount).mulDivDown(current - start, end - start));
        }
    }

    function encrypt(Point memory toPub, uint256 withPriv, bytes32 message)
        internal
        view
        returns (Point memory pub, bytes32 encrypted)
    {
        encrypted = message ^ hash(mul(withPriv, toPub));
        pub = publicKey(withPriv);
    }

    function decrypt(Point memory point, bytes32 message) internal pure returns (bytes32) {
        return message ^ hash(point);
    }

    function hash(Point memory point) internal pure returns (bytes32) {
        return keccak256(abi.encode(point));
    }
}
