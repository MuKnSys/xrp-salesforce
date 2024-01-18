public with sharing class ConnectOrgWalletCtrl {
    @AuraEnabled
    public static void connectWallet(Id recordId){
        try {
            Org_Wallet__c orgWallet = [SELECT Wallet_Address__c FROM Org_Wallet__c WHERE Id = :recordId];

            XrpWebhookService.RegisterSubscriptionResponse response = XrpWebhookService.subscribeToAddress(orgWallet.Wallet_Address__c);

            orgWallet.XRPWebhookSubscriptionId__c = response.subscription_id;
            update as user orgWallet;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
