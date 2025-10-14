// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank
/// @author Web3 Expert Developer
/// @notice A simple bank contract for depositing and withdrawing native tokens (ETH).
/// @dev This contract enforces a per-transaction withdrawal limit and a global deposit cap.
contract KipuBank {
    /*///////////////////////////////////////////////////////////////
                              STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The global deposit limit for the bank.
    /// @dev This limit is set at deployment in an immutable variable and cannot be changed.
    uint256 public immutable bankCap; // UpperCamelCase for contract/struct/enum names, lowerCamelCase for variables.

    /// @notice The maximum amount allowed to be withdrawn per transaction.
    /// @dev This limit is set at deployment in an immutable variable and cannot be changed.
    uint256 public immutable transactionWithdrawalCap;

    /// @notice Mapping of addresses to account balances (in Wei).
    mapping(address => uint256) private userVaults; 

    /// @notice Total count of successful deposits made.
    uint256 public totalDeposits;

    /// @notice Total count of successful withdrawals made.
    uint256 public totalWithdrawals;

    /*///////////////////////////////////////////////////////////////
                           CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a deposit exceeds the established global bank cap.
    /// @param depositAmount The amount the user attempted to deposit.
    /// @param currentContractBalance The balance of the contract before the deposit.
    /// @param bankCap The global maximum deposit cap.
    error DepositExceedsBankCap(uint256 depositAmount, uint256 currentContractBalance, uint256 bankCap);

    /// @notice Emitted when the user's balance is insufficient for the requested withdrawal.
    /// @param requestedAmount The amount the user tried to withdraw.
    /// @param userBalance The user's current available balance.
    error InsufficientBalance(uint256 requestedAmount, uint256 userBalance);

    /// @notice Emitted when a withdrawal exceeds the per-transaction limit.
    /// @param requestedAmount The amount the user tried to withdraw.
    /// @param transactionWithdrawalCap The maximum allowed amount per transaction.
    error WithdrawalExceedsCap(uint256 requestedAmount, uint256 transactionWithdrawalCap);
    
    /// @notice Emitted when the transfer of Ether fails during a withdrawal.
    error TransferFailed();

    /// @notice Emitted when a zero amount is deposited, violating the requirement.
    error ZeroAmount();

    /*///////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a user successfully deposits funds.
    /// @param depositor The address that made the deposit.
    /// @param amount The amount of ETH deposited.
    /// @param newBalance The user's new balance.
    event DepositMade(address indexed depositor, uint256 amount, uint256 newBalance);

    /// @notice Emitted when a user successfully withdraws funds.
    /// @param withdrawer The address that performed the withdrawal.
    /// @param amount The amount of ETH withdrawn.
    /// @param newBalance The user's new balance.
    event WithdrawalMade(address indexed withdrawer, uint256 amount, uint256 newBalance);

    /*///////////////////////////////////////////////////////////////
                            CONSTRUCTOR AND MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @dev Initializes the contract with the required deposit and withdrawal caps.
    /// @param _bankCap The global deposit limit.
    /// @param _transactionWithdrawalCap The maximum withdrawal amount per transaction.
    constructor(uint256 _bankCap, uint256 _transactionWithdrawalCap) {
        bankCap = _bankCap;
        transactionWithdrawalCap = _transactionWithdrawalCap;
    }

    /// @notice Validates that the amount of Ether deposited is not zero.
    modifier nonZeroAmount() {
        if (msg.value == 0) {
            revert ZeroAmount(); 
        }
        _;
    }

    /*///////////////////////////////////////////////////////////////
                            FUNCTIONS 
    //////////////////////////////////////////////////////////////*/

    /// @notice Allows users to deposit ETH into their personal vault.
    /// @dev The function checks if the deposit exceeds the global bank limit before processing.
    function deposit() external payable nonZeroAmount {
                
        // CHECK: Cap check (requires reading the current contract balance once).
        uint256 currentContractBalance = address(this).balance; // Current balance is read once.
        uint256 futureContractBalance = currentContractBalance + msg.value; // Calculate potential new balance.

        if (futureContractBalance > bankCap) {
            revert DepositExceedsBankCap(msg.value, currentContractBalance, bankCap);
        }

        // CHECK: Get user's old balance (Single read).
        uint256 oldBalance = userVaults[msg.sender];

        // EFFECTS: Update user balance and total deposits counter.
        // The addition is safe as it's checked against bankCap, but for general counter safety, we can use unchecked.
        userVaults[msg.sender] = oldBalance + msg.value;
        
        // Use unchecked for known-safe increments.
        unchecked {
            totalDeposits++; 
        }

        // Emit Event
        emit DepositMade(msg.sender, msg.value, userVaults[msg.sender]);
    }

    /// @notice Allows users to withdraw ETH from their account.
    /// @dev Strictly follows the Checks-Effects-Interactions pattern for secure transfer.
    /// @param amount The amount of ETH to withdraw (in Wei).
    function withdraw(uint256 amount) external {
        // CHECKS
        // Withdrawal cap check
        if (amount == 0) revert ZeroAmount();
        if (amount > transactionWithdrawalCap) {
            revert WithdrawalExceedsCap(amount, transactionWithdrawalCap);
        }
        
        // Insufficient balance check (Single read of state variable)
        uint256 userBalance = userVaults[msg.sender];
        if (amount > userBalance) {
            revert InsufficientBalance(amount, userBalance);
        }

        // EFFECTS (Update state BEFORE interaction)
        // Subtraction is safe due to the check above.
        userVaults[msg.sender] = userBalance - amount; 
        
        // Use unchecked for known-safe increments.
        unchecked {
            totalWithdrawals++;
        }
        
        // INTERACTIONS (Secure transfer using call)
        (bool success, ) = payable(msg.sender).call{value: amount}(""); // Use payable(msg.sender).call
        if (!success) {
            // Revert state change if interaction fails.
            revert TransferFailed(); 
        }

        // Emit Event
        emit WithdrawalMade(msg.sender, amount, userVaults[msg.sender]);
    }

    /// @notice Gets the vault balance of a specific user.
    /// @param _user The address of the user.
    /// @return The user's current balance (in Wei).
    function getBalance(address _user) external view returns (uint256) {
        return userVaults[_user];
    }
    
    /// @notice Gets the private vault balance of a user.
    /// @dev This is a private function for internal contract use.
    /// @param _user The address of the user.
    /// @return The user's current balance (in Wei).
    function _getVaultBalance(address _user) private view returns (uint256) {
        return userVaults[_user];
    }
}