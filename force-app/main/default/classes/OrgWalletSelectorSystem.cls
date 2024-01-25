public without sharing class OrgWalletSelectorSystem {
    public static List<Org_Wallet__c> getOrgWalletByWalletAddressesSystemMode(
        Set<String> walletAddresses
    ) {
        return [
            SELECT Wallet_Address__c
            FROM Org_Wallet__c
            WHERE Wallet_Address__c IN :walletAddresses
            WITH SYSTEM_MODE
        ];
    }
}
