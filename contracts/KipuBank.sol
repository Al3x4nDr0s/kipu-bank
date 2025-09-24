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

    /*///// CONSTRUCTOR /////*/

    /// @notice Constructor del contrato KipuBank.
    /// @param _transactionWithdrawalCap El límite máximo de retiro por transacción.
    /// @param _bankCap El límite máximo de depósitos globales del banco.
    constructor(uint256 _transactionWithdrawalCap, uint256 _bankCap) {
        transactionWithdrawalCap = _transactionWithdrawalCap;
        bankCap = _bankCap;
    }

    /*///// MODIFICADORES /////*/

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

    /*///// MAPEOS /////*/

    /// @notice Mapeo que almacena los saldos de los usuarios.
    mapping(address => uint256) private balances;

    /*///// FUNCIONES /////*/

    /// @notice Permite a los usuarios depositar Ether en el banco.
    /// @dev La función es payable y utiliza los modificadores para validar que el depósito no sea cero ni que exceda el límite global del banco.
    function deposit() external payable nonZeroAmount withinBankCap(msg.value) {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value, balances[msg.sender]);
    }

    /// @notice Permite a los usuarios retirar Ether de sus saldos.
    /// @param amount La cantidad de Ether que el usuario desea retirar.
    /// @dev La función utiliza los modificadores para validar que el monto de retiro no exceda el límite por transacción y que el usuario tenga suficiente saldo.
    function withdraw(uint256 amount) external withinTransactionWithdrawalCap(amount) {
        uint256 userBalance = balances[msg.sender];
        if (amount > userBalance) {
            revert("Saldo insuficiente"); // Revert con una cadena simple para este caso.
        }
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount, balances[msg.sender]);
    }

    /// @notice Permite a los usuarios consultar su saldo actual en el banco.
    /// @return El saldo actual del usuario.
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    /// @notice Permite consultar el saldo total del banco.
    /// @return El saldo total del contrato.
    function getBankBalance() external view returns (uint256) {
        return address(this).balance;
    }

}