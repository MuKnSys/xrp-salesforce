public with sharing class TransactionSelector {
    public static List<SObject> getTransactionById(Id transactionId) {
        String transactionType = transactionId.getSObjectType()
            .getDescribe()
            .getName();

        Map<String, Object> queryBinds = new Map<String, Object>{
            'transactionId' => transactionId
        };

        return Database.queryWithBinds(
            'SELECT Value__c, Transaction_Value__c, System_Notes__c FROM ' +
                transactionType +
                ' WHERE Id = :transactionId',
            queryBinds,
            AccessLevel.USER_MODE
        );
    }
}
