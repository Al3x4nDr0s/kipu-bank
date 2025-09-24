//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title KipuBank
/// @author Alejandro Cardenas
/// @notice Un contrato bancario simple para depositar y retirar Ether (ETH).
/// @dev Este contrato impone un límite de retiro por transacción y un límite global de depósitos.

contract KipuBank {

    /*///// VARIABLES DE ESTADO /////*/

    // Límite máximo de retiro por transacción (1 ETH)
    // uint256 public constant transactionWithdrawalCap = 1 ether;

    /// @notice Límite máximo de retiro por transacción.
    /// @dev Este límite se establece en el constructor y no se puede cambiar. Gasta menos gas que una variable constante.
    uint256 public immutable transactionWithdrawalCap;

    // Límite máximo de depósitos globales (100 ETH)
    // uint256 public constant bankCap = 100 ether;

    /// @notice Límite global de depósitos del banco.
    /// @dev Este límite se establece en el constructor y no se puede cambiar. Gasta menos gas que una variable constante.
    uint256 public immutable bankCap;

    /*///// EVENTOS /////*/

    /// @notice Evento que se emite cuando un usuario realiza un depósito.
    /// @param user La dirección del usuario que realizó el depósito.
    /// @param amount La cantidad de ETH depositada.
    /// @param newBalance El nuevo saldo del usuario después del depósito.
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);

    /// @notice Evento que se emite cuando un usuario realiza un retiro.
    /// @param user La dirección del usuario que realizó el retiro.
    /// @param amount La cantidad de ETH retirada.
    /// @param newBalance El nuevo saldo del usuario después del retiro.
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);

    /*///// CONSTRUCTOR Y MODIFICADORES /////*/

    /// @notice Constructor del contrato KipuBank.
    /// @param _transactionWithdrawalCap El límite máximo de retiro por transacción.
    /// @param _bankCap El límite máximo de depósitos globales del banco.
    constructor(uint256 _transactionWithdrawalCap, uint256 _bankCap) {
        transactionWithdrawalCap = _transactionWithdrawalCap;
        bankCap = _bankCap;
    }

    /// @notice Valida que el monto total de depósitos no exceda el límite global del banco.
    modifier withinBankCap(uint256 amount) {
        if (address(this).balance + amount > bankCap) {
            revert("Excede el limite global del banco"); // Revert con una cadena simple para este caso.
        }
        _;
    }

    /// @notice Valida que el monto de retiro no exceda el límite por transacción.
    modifier withinTransactionWithdrawalCap(uint256 amount) {
        if (amount > transactionWithdrawalCap) {
            revert("Excede el limite por transaccion"); // Revert con una cadena simple para este caso.
        }
        _;
    }
    
    /// @notice Valida que la cantidad de Ether depositada no sea cero.
    modifier nonZeroAmount() {
        if (msg.value == 0) {
            revert("El monto debe ser mayor a Cero"); // Revert con una cadena simple para este caso.
        }
        _;
    }


}