public with sharing class OrgWalletSelector {
    public static Org_Wallet__c getOrgWalletById(Id recordId) {
        List<Org_Wallet__c> wallets = [
            SELECT Wallet_Address__c, XRPWebhookSubscriptionId__c
            FROM Org_Wallet__c
            WHERE Id = :recordId
            WITH USER_MODE
        ];

        return wallets.isEmpty() ? null : wallets[0];
    }

    public static List<Org_Wallet__c> getOrgWalletByWalletAddresses(
        Set<String> walletAddresses
    ) {
        return [
            SELECT Wallet_Address__c
            FROM Org_Wallet__c
            WHERE Wallet_Address__c IN :walletAddresses
            WITH USER_MODE
        ];
    }
}
