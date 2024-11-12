//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {
    IAccount,
    Transaction
} from "../../lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";

contract ZKMinimalAccount is IAccount {

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Validates the transaction and returns the magic number.
     * @notice must increase increase the nonce of the account 
     * @param _txHash The hash of the transaction.
     * @param _suggestedSignedHash The hash of the transaction signed by the user.
     * @param _transaction The transaction to be validated.
     */
    function validateTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
        external
        payable
        returns (bytes4 magic)
    {}

    function executeTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
        external
        payable
    {}

    // There is no point in providing possible signed hash in the `executeTransactionFromOutside` method,
    // since it typically should not be trusted.
    function executeTransactionFromOutside(Transaction calldata _transaction) external payable {}

    function payForTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
        external
        payable
    {}

    function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction memory _transaction)
        external
        payable
    {}

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
}
