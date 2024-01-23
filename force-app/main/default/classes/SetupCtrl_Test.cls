@isTest
private class SetupCtrl_Test {
    @isTest
    static void getSttings_ExistingSettings() {
        XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
        settings.XRPWebhookApiKey__c = 'test_API_Key';
        settings.XRPWebhookApiSecret__c = 'test_API_Secret';
        XRPForSalesforceSettingsService.settings = settings;

        Test.startTest();
        SetupCtrl.Settings result = SetupCtrl.getSettings();
        Test.stopTest();

        Assert.areEqual(result.apiKey, System.Label.settings_api_key_setted);
        Assert.areEqual(
            result.apiSecret,
            System.Label.settings_api_secret_setted
        );
    }

    @isTest
    static void getSttings_NoExistingSettings() {
        XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
        XRPForSalesforceSettingsService.settings = settings;

        Test.startTest();
        SetupCtrl.Settings result = SetupCtrl.getSettings();
        Test.stopTest();

        Assert.areEqual(result.apiKey, null);
        Assert.areEqual(result.apiSecret, null);
    }

    @isTest
    static void saveSettings_SettingsSaved() {
        XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
        XRPForSalesforceSettingsService.settings = settings;

        Test.startTest();
        SetupCtrl.Settings result = SetupCtrl.saveSettings(
            'test_new_API_Key',
            'test_new_API_Secret'
        );
        Test.stopTest();

        Assert.areEqual(result.apiKey, System.Label.settings_api_key_setted);
        Assert.areEqual(
            result.apiSecret,
            System.Label.settings_api_secret_setted
        );
    }

    @isTest
    static void subscribeWebhook_Success() {
        XRPForSalesforceSettings__c settings = new XRPForSalesforceSettings__c();
        settings.XRPWebhookApiKey__c = 'test_webhook_api_key';
        settings.XRPWebhookApiSecret__c = 'test_webhook_api_secret';
        insert settings;

        XrpWebhookService.RegisterWebhookResponse body = new XrpWebhookService.RegisterWebhookResponse();
        body.webhook_id = 'test_webhook_id';
        body.success = true;

        new HttpMock()
            .post(XrpWebhookService.REGISTER_WEBHOOK_SUFFIX, body, 200)
            .mock();

        Test.startTest();
        SetupCtrl.subscribeWebhook();
        Test.stopTest();

        settings = XRPForSalesforceSettingsService.settings;
        Assert.isNotNull(settings.XRPWebhookId__c);
    }

    @isTest
    static void deleteWebhook_Success() {
        XRPForSalesforceSettings__c settings = new XRPForSalesforceSettings__c();
        settings.XRPWebhookApiKey__c = 'test_webhook_api_key';
        settings.XRPWebhookApiSecret__c = 'test_webhook_api_secret';
        settings.XRPWebhookId__c = 'test_webhook_id';
        insert settings;

        new HttpMock()
            .doDelete(
                String.format(
                    XrpWebhookService.DELETE_WEBHOOK_SUFFIX,
                    new List<Object>{ settings.XRPWebhookId__c }
                ),
                null,
                204
            )
            .mock();

        Test.startTest();
        SetupCtrl.deleteWebhook();
        Test.stopTest();

        settings = XRPForSalesforceSettingsService.settings;
        Assert.isNull(settings.XRPWebhookId__c);
    }
}
