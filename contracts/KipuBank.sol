// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank
/// @author Alejandro Cardenas
/// @notice Un contrato bancario simple para depositar y retirar Ether (ETH).
/// @dev Este contrato impone un límite de retiro por transacción y un límite global de depósitos a definir en el constructor.
contract KipuBank {
    /*///////////////////////////////////////////////////////////////
                              VARIABLES DE ESTADO
    //////////////////////////////////////////////////////////////*/

    /// @notice Límite global de depósitos del banco.
    /// @dev Este límite se establece durante el despliegue en una variable inmutable y no se puede cambiar.
    uint256 public immutable bankCap;

    /// @notice Límite máximo de retiro por transacción.
    /// @dev Este límite se establece durante el despliegue en una variable inmutable y no se puede cambiar.
    uint256 public immutable transactionWithdrawalCap;

    /// @notice Mapeo de direcciones a los saldos de las cuentas.
    mapping(address => uint256) private vaults;

    /// @notice Contador total de depósitos realizados.
    uint256 public totalDeposits;

    /// @notice Contador total de retiros realizados.
    uint256 public totalWithdrawals;

    /*///////////////////////////////////////////////////////////////
                            ERRORES PERSONALIZADOS
    //////////////////////////////////////////////////////////////*/

    /// @notice Se emite cuando un depósito excede el límite global establecido del banco.
    error DepositExceedsBankCap(uint256 depositAmount, uint256 currentBalance, uint256 bankCap);

    /// @notice Se emite cuando el saldo del usuario es insuficiente para el retiro.
    error InsufficientBalance(uint256 requestedAmount, uint256 userBalance);

    /// @notice Se emite cuando un retiro excede el límite por transacción.
    error WithdrawalExceedsCap(uint256 requestedAmount, uint256 transactionWithdrawalCap);

    /*///////////////////////////////////////////////////////////////
                               EVENTOS
    //////////////////////////////////////////////////////////////*/

    /// @notice Se emite cuando un usuario deposita fondos exitosamente.
    /// @param depositor La dirección que realizó el depósito.
    /// @param amount La cantidad de ETH depositada.
    /// @param newBalance El nuevo saldo del usuario.
    event DepositMade(address indexed depositor, uint256 amount, uint256 newBalance);

    /// @notice Se emite cuando un usuario retira fondos exitosamente.
    /// @param withdrawer La dirección que realizó el retiro.
    /// @param amount La cantidad de ETH retirada.
    /// @param newBalance El nuevo saldo del usuario.
    event WithdrawalMade(address indexed withdrawer, uint256 amount, uint256 newBalance);

    /*///////////////////////////////////////////////////////////////
                            CONSTRUCTOR Y MODIFICADORES
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _bankCap, uint256 _transactionWithdrawalCap) {
        bankCap = _bankCap;
        transactionWithdrawalCap = _transactionWithdrawalCap;
    }

    /// @notice Valida que la cantidad de Ether depositada no sea cero.
    modifier nonZeroAmount() {
        if (msg.value == 0) {
            revert("Amount must be greater than zero"); // Revert con una cadena para el mensale en este caso.
        }
        _;
    }

    /*///////////////////////////////////////////////////////////////
                            FUNCIONES 
    //////////////////////////////////////////////////////////////*/

    /// @notice Permite a los usuarios depositar ETH en su cuenta personal.
    /// @dev La función valida si el depósito excede el límite global del banco.
    function deposit() external payable nonZeroAmount {
        uint256 newBankBalance = address(this).balance + msg.value;
        if (newBankBalance > bankCap) {
            revert DepositExceedsBankCap(msg.value, address(this).balance, bankCap);
        }

        // Checks
        uint256 oldBalance = vaults[msg.sender];
        uint256 newBalance = oldBalance + msg.value;

        // Effects
        vaults[msg.sender] = newBalance;
        totalDeposits++;

        // Interactions (n/a en este caso)
        emit DepositMade(msg.sender, msg.value, newBalance);
    }

    /// @notice Permite a los usuarios retirar ETH de su cuenta.
    /// @dev Sigue el patrón checks-effects-interactions para una transferencia segura.
    /// @param amount La cantidad de ETH a retirar.
    function withdraw(uint256 amount) external {
        // Checks
        if (amount > transactionWithdrawalCap) {
            revert WithdrawalExceedsCap(amount, transactionWithdrawalCap);
        }
        if (amount > vaults[msg.sender]) {
            revert InsufficientBalance(amount, vaults[msg.sender]);
        }

        // Effects
        vaults[msg.sender] -= amount;
        totalWithdrawals++;
        
        // Interactions
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            revert("Transfer failed"); // Una falla en la interacción debe revertir la transacción.
        }

        emit WithdrawalMade(msg.sender, amount, vaults[msg.sender]);
    }

    /// @notice Obtiene el saldo del vault de un usuario.
    /// @param user La dirección del usuario.
    /// @return El saldo actual del usuario.
    function getBalance(address user) external view returns (uint256) {
        return vaults[user];
    }
    
    /// @notice Obtiene el saldo total de un usuario.
    /// @dev Esta es una función `private` para uso interno del contrato.
    /// @param user La dirección del usuario.
    /// @return El saldo actual del usuario.
    function _getVaultBalance(address user) private view returns (uint256) {
        return vaults[user];
    }
}