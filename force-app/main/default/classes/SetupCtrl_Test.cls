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
        Assert.areEqual(result.apiSecret, System.Label.settings_api_secret_setted);
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
        SetupCtrl.Settings result = SetupCtrl.saveSettings('test_new_API_Key', 'test_new_API_Secret');
        Test.stopTest();

        Assert.areEqual(result.apiKey, System.Label.settings_api_key_setted);
        Assert.areEqual(result.apiSecret, System.Label.settings_api_secret_setted);
    }
}