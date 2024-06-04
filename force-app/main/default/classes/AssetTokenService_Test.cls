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
        rippleAssetToken.TokenInformation__c = AssetTokenService.RIPPLE_COIN_GECKO_TOKEN_INFO;
        insert rippleAssetToken;

        Inbound_Blockchain_Transaction__c chainTransaction = new Inbound_Blockchain_Transaction__c();
        chainTransaction.Asset__c = 'XRP';
        chainTransaction.Value__c = 1000;
        chainTransaction.Transaction_Value__c = null;
        chainTransaction.System_Notes__c = 'test_sytem_notes';
        insert chainTransaction;

        Decimal rate = 0.7;
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
        AssetTokenService.updateRippleAssetTokenExchangeRate(
            new List<Id>{ chainTransaction.Id }
        );
        Test.stopTest();

        List<Asset_Token__c> assetToken = [
            SELECT ConversionRate__c
            FROM Asset_Token__c
        ];

        List<Inbound_Blockchain_Transaction__c> chainTransactions = [
            SELECT Transaction_Value__c, System_Notes__c
            FROM Inbound_Blockchain_Transaction__c
            WHERE Id = :chainTransaction.Id
        ];

        Assert.areEqual(1, assetToken.size());
        Assert.areEqual(0.7, assetToken[0].ConversionRate__c);

        Assert.areEqual(1, chainTransactions.size());
        Assert.areEqual(700, chainTransactions[0].Transaction_Value__c);
        Assert.areEqual(
            System.Label.flow_exchange_rate_success_calculated,
            chainTransactions[0].System_Notes__c
        );
    }
}
