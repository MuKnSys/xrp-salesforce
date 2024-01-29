public without sharing class AccountWalletSelectorSystem {
    public static List<Account_Wallet__c> getOrgWalletByWalletAddressesSystemMode(
        Set<String> walletAddresses
    ) {
        return [
            SELECT Wallet_Address__c
            FROM Account_Wallet__c
            WHERE Wallet_Address__c IN :walletAddresses
            WITH SYSTEM_MODE
        ];
    }
}
