@isTest
private class SetupCtrl_Test {
    @isTest
    static void getSttings_ExistingSettings() {
        XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
        settings.XRPWebhookApiKey__c = 'test_API_Key';
        settings.XRPWebhookApiSecret__c = 'test_API_Secret';
        settings.XRPSiteDomainUrl__c = 'test_Site_Domain';
        XRPForSalesforceSettingsService.settings = settings;

        Test.startTest();
        SetupCtrl.Settings result = SetupCtrl.getSettings();
        Test.stopTest();

        Assert.areEqual(result.apiKey, System.Label.settings_api_key_setted);
        Assert.areEqual(
            result.apiSecret,
            System.Label.settings_api_secret_setted
        );
        Assert.areEqual(
            result.siteDomain,
            System.Label.settings_site_domain_setted
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
        Assert.areEqual(result.siteDomain, null);
    }

    @isTest
    static void saveSettings_SettingsSaved() {
        XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
        XRPForSalesforceSettingsService.settings = settings;

        Map<String, String> settingValues = new Map<String, String>();
        settingValues.put('apiKey', 'test_new_API_Key');
        settingValues.put('apiSecret', 'test_new_API_Secret');
        settingValues.put('siteDomain', 'test_new_Site_Domain');

        Test.startTest();
        SetupCtrl.Settings result = SetupCtrl.saveSettings(settingValues);
        Test.stopTest();

        Assert.areEqual(result.apiKey, System.Label.settings_api_key_setted);
        Assert.areEqual(
            result.apiSecret,
            System.Label.settings_api_secret_setted
        );
        Assert.areEqual(
            result.siteDomain,
            System.Label.settings_site_domain_setted
        );
    }

    @isTest
    static void subscribeWebhook_Success() {
        XRPForSalesforceSettings__c settings = new XRPForSalesforceSettings__c();
        settings.XRPWebhookApiKey__c = 'test_webhook_api_key';
        settings.XRPWebhookApiSecret__c = 'test_webhook_api_secret';
        settings.XRPSiteDomainUrl__c = 'test_site_domain';
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
        settings.XRPSiteDomainUrl__c = 'test_site_domain';
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

    @isTest
    static void initializeAssetTokens_Success() {
        XRPForSalesforceSettings__c settings = new XRPForSalesforceSettings__c();
        settings.XRPWebhookApiKey__c = 'test_webhook_api_key';
        settings.XRPWebhookApiSecret__c = 'test_webhook_api_secret';
        settings.XRPSiteDomainUrl__c = 'test_site_domain';
        settings.XRPWebhookId__c = 'test_webhook_id';
        insert settings;

        Decimal rate = 0.7;
        String transactionCurrencyCode = 'usd';

        CurrencyService.defaultCurrencyCode = transactionCurrencyCode;
        InitializeAssetTokensBody body = new InitializeAssetTokensBody(rate);

        new HttpMock()
            .get(
                String.format(
                    CoinGeckoService.GET_EXCHANGE_RATE_ENDPOINT,
                    new List<String>{
                        AssetTokenService.RIPPLE_COIN_GECKO_API_NAME,
                        transactionCurrencyCode
                    }
                ),
                body,
                200
            )
            .mock();

        Test.startTest();
        SetupCtrl.Settings result = SetupCtrl.initializeAssetTokens();
        Test.stopTest();

        List<Asset_Token__c> assetTokens = [
            SELECT Id, ConversionRate__c
            FROM Asset_Token__c
        ];

        Assert.areEqual(true, result.assetTokensInitialized);
        Assert.isFalse(assetTokens.isEmpty());
        Assert.areEqual(1, assetTokens.size());
        Assert.areEqual(rate, assetTokens[0].ConversionRate__c);
    }

    public class InitializeAssetTokensBodyRipple {
        public Decimal usd;
    }

    public class InitializeAssetTokensBody {
        public InitializeAssetTokensBodyRipple ripple;

        public InitializeAssetTokensBody(Decimal rate) {
            InitializeAssetTokensBodyRipple ripple = new InitializeAssetTokensBodyRipple();
            ripple.usd = rate;

            this.ripple = ripple;
        }
    }
}
