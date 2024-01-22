public with sharing class ConnectionOrgWalletCtrl {
    @AuraEnabled
    public static void connectWallet(Id recordId){
        try {
            Org_Wallet__c orgWallet = OrgWalletSelector.getOrgWalletById(recordId);
            if(orgWallet.XRPWebhookSubscriptionId__c == null) {
                XrpWebhookService.RegisterSubscriptionResponse response = XrpWebhookService.subscribeToAddress(orgWallet.Wallet_Address__c);

                orgWallet.XRPWebhookSubscriptionId__c = response.subscription_id;
                update as user orgWallet;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void disConnectWallet(Id recordId){
        try {
            Org_Wallet__c orgWallet = OrgWalletSelector.getOrgWalletById(recordId);
            if(orgWallet.XRPWebhookSubscriptionId__c == null) {
                throw new XrpWebhookApi.XrpWebhookAPIException(System.Label.dis_connect_org_wallet_error_not_connected);
            }
            XrpWebhookService.removeSubscriptionToAddress(orgWallet.XRPWebhookSubscriptionId__c);

            orgWallet.XRPWebhookSubscriptionId__c = null;
            update as user orgWallet;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
