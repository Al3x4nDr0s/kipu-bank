//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title KipuBank
/// @author Alejandro Cardenas
/// @notice Un contrato bancario simple para depositar y retirar Ether (ETH).
/// @dev Este contrato impone un límite de retiro por transacción y un límite global de depósitos.

contract KipuBank {
    // Límite máximo de retiro por transacción (1 ETH)
    uint256 public constant MAX_WITHDRAWAL = 1 ether;
    }