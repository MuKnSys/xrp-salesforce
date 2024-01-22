@isTest
private class ConnectionOrgWalletCtrl_Test {
    @isTest
    static void connectWallet_Success() {
        OrgWalletService.triggerOn = false;

        XRPForSalesforceSettings__c settings = new XRPForSalesforceSettings__c();
        settings.XRPWebhookApiKey__c = 'test_webhook_api_key';
        settings.XRPWebhookApiSecret__c = 'test_webhook_api_secret';
        settings.XRPWebhookId__c = 'test_webhook_id';
        XRPForSalesforceSettingsService.settings = settings;

        Org_Wallet__c wallet = new Org_Wallet__c();
        wallet.Wallet_Address__c = 'test_wallet_address';
        wallet.Networks__c = 'XRP_LEDGER';
        insert wallet;

        XrpWebhookService.RegisterSubscriptionResponse body = new XrpWebhookService.RegisterSubscriptionResponse();
        body.subscription_id = 'test_subscription_id';
        body.success = true;
        
        new HttpMock().post(XrpWebhookService.REGISTER_SUBSCRIPTION_SUFFIX, body, 200).mock();

        Test.startTest();
        ConnectionOrgWalletCtrl.connectWallet(wallet.Id);
        Test.stopTest();

        Org_Wallet__c connectedWallet = [SELECT XRPWebhookSubscriptionId__c FROM Org_Wallet__c WHERE Id = :wallet.Id];
        Assert.isNotNull(connectedWallet.XRPWebhookSubscriptionId__c);
    }

    @isTest
    static void disConnectWallet_Success() {
        OrgWalletService.triggerOn = false;

        XRPForSalesforceSettings__c settings = new XRPForSalesforceSettings__c();
        settings.XRPWebhookApiKey__c = 'test_webhook_api_key';
        settings.XRPWebhookApiSecret__c = 'test_webhook_api_secret';
        settings.XRPWebhookId__c = 'test_webhook_id';
        XRPForSalesforceSettingsService.settings = settings;

        Org_Wallet__c wallet = new Org_Wallet__c();
        wallet.Wallet_Address__c = 'test_wallet_address';
        wallet.Networks__c = 'XRP_LEDGER';
        wallet.XRPWebhookSubscriptionId__c = 'test_webhook_subscription_id';
        insert wallet;
        
        new HttpMock().doDelete(
            String.format(
                XrpWebhookService.DELETE_SUBSCRIPTION_SUFFIX,
                new List<Object>{wallet.XRPWebhookSubscriptionId__c
            }), null, 204)
        .mock();

        Test.startTest();
        ConnectionOrgWalletCtrl.disConnectWallet(wallet.Id);
        Test.stopTest();

        Org_Wallet__c connectedWallet = [SELECT XRPWebhookSubscriptionId__c FROM Org_Wallet__c WHERE Id = :wallet.Id];
        Assert.isNull(connectedWallet.XRPWebhookSubscriptionId__c);
    }
}