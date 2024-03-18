// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {SignatureChecker} from "openzeppelin/utils/cryptography/SignatureChecker.sol";
import {EIP712WithNonce, EIP712} from "src/helpers/EIP712WithNonce.sol";

contract Forwarder is EIP712WithNonce {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        uint256 deadline;
        bytes data;
    }

    bytes32 private constant _FORWARDREQUEST_TYPEHASH = keccak256(
        "ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,uint256 deadline,bytes data)"
    );

    error DeadlineExpired();
    error SignatureDoesNotMatch();

    constructor() EIP712("Forwarder", "1") {}

    function execute(ForwardRequest calldata req, bytes calldata signature)
        external
        payable
        returns (bool, bytes memory)
    {
        _verifyAndConsumeNonce(req.from, req.nonce);

        if (!(req.deadline == 0 || req.deadline > block.timestamp)) revert DeadlineExpired();
        if (
            !SignatureChecker.isValidSignatureNow(
                req.from,
                _hashTypedDataV4(
                    keccak256(
                        abi.encode(
                            _FORWARDREQUEST_TYPEHASH,
                            req.from,
                            req.to,
                            req.value,
                            req.gas,
                            req.nonce,
                            req.deadline,
                            keccak256(req.data)
                        )
                    )
                ),
                signature
            )
        ) revert SignatureDoesNotMatch();

        (bool success, bytes memory returndata) =
            req.to.call{gas: req.gas, value: req.value}(abi.encodePacked(req.data, req.from));

        if (gasleft() <= req.gas / 63) {
            assembly {
                invalid()
            }
        }
        return (success, returndata);
    }
}
