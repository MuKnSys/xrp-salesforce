// Used in System Mode for System User - should Bypass OLS/FLS
public without sharing class TransactionService {
    public static void updateTransactionValue(
        Id transactionId,
        Decimal newExchangeRate
    ) {
        SObject chainTransaction;
        try {
            if (transactionId == null || newExchangeRate == null) {
                throw new TransactionException();
            }

            List<SObject> chainTransactions = TransactionSelector.getTransactionByIdSystem(
                transactionId
            );

            if (chainTransactions.isEmpty()) {
                throw new TransactionException();
            }
            chainTransaction = chainTransactions[0];

            chainTransaction.put(
                'Transaction_Value__c',
                (Decimal) chainTransaction.get('Value__c') * newExchangeRate
            );
            chainTransaction.put(
                'System_Notes__c',
                System.Label.flow_exchange_rate_success_calculated
            );

            update as system chainTransaction;
        } catch (TransactionException error) {
            if (chainTransaction != null) {
                chainTransaction.put(
                    'System_Notes__c',
                    System.Label.flow_exchange_rate_error_calculated
                );
                update as system chainTransaction;
            }
        }
    }

    public class TransactionException extends Exception {
    }
}