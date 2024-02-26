@isTest
private class AssetTokenService_Test {
    @isTest
    static void updateRippleAssetTokenExchangeRate_Success() {
        XRPForSalesforceSettings__c settings = new XRPForSalesforceSettings__c();
        settings.XRPWebhookApiKey__c = 'test_webhook_api_key';
        settings.XRPWebhookApiSecret__c = 'test_webhook_api_secret';
        settings.XRPSiteDomainUrl__c = 'test_site_domain';
        settings.XRPWebhookId__c = 'test_webhook_id';
        insert settings;

        Asset_Token__c rippleAssetToken = new Asset_Token__c();
        rippleAssetToken.Name = AssetTokenService.RIPPLE_NAME;
        rippleAssetToken.Asset__c = AssetTokenService.RIPPLE_ASSET;
        rippleAssetToken.Active__c = true;
        rippleAssetToken.CoinGeckoAPIName__c = AssetTokenService.RIPPLE_COIN_GECKO_API_NAME;
        rippleAssetToken.ConversionRate__c = AssetTokenService.RIPPLE_DEFAULT_EXCHANGE_RATE;
        rippleAssetToken.ConversionRateLastSet__c = Datetime.now();
        insert rippleAssetToken;

        Decimal rate = AssetTokenService.RIPPLE_DEFAULT_EXCHANGE_RATE + 0.2;
        String transactionCurrencyCode = 'usd';

        CurrencyService.defaultCurrencyCode = transactionCurrencyCode;
        TestDataFactory.InitializeAssetTokensBody body = new TestDataFactory.InitializeAssetTokensBody(
            rate
        );

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
        List<Decimal> result = AssetTokenService.updateRippleAssetTokenExchangeRate();
        Test.stopTest();

        Assert.areEqual(1, result.size());
        Assert.areEqual(rate, result[0]);
    }
}
