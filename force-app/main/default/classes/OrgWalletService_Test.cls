@isTest
private class OrgWalletService_Test {
    @isTest
    static void processXRPWebhooks_Success() {
        XRPForSalesforceSettings__c settings = new XRPForSalesforceSettings__c();
        settings.XRPWebhookApiKey__c = 'test_webhook_api_key';
        settings.XRPWebhookApiSecret__c = 'test_webhook_api_secret';
        settings.XRPWebhookId__c = 'test_webhook_id';
        XRPForSalesforceSettingsService.settings = settings;

        XrpWebhookService.RegisterSubscriptionResponse body = new XrpWebhookService.RegisterSubscriptionResponse();
        body.subscription_id = 'test_subscription_id';
        body.success = true;
        
        new HttpMock().post(XrpWebhookService.REGISTER_SUBSCRIPTION_SUFFIX, body, 200).mock();

        Test.startTest();
        Org_Wallet__c wallet = new Org_Wallet__c();
        wallet.Wallet_Address__c = 'test_wallet_address';
        wallet.Networks__c = 'XRP_LEDGER';

        insert wallet;
        Test.stopTest();

        Org_Wallet__c connectedWallet = [SELECT XRPWebhookSubscriptionId__c FROM Org_Wallet__c WHERE Id = :wallet.Id];
        Assert.isNotNull(connectedWallet.XRPWebhookSubscriptionId__c);
    }
}