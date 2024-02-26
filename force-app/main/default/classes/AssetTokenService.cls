public with sharing class AssetTokenService {
    private static final String RIPPLE_NAME = 'XRP (FKA Ripple)';
    private static final String RIPPLE_ASSET = 'XRP';
    @TestVisible
    private static final String RIPPLE_COIN_GECKO_API_NAME = 'ripple';
    private static final Decimal RIPPLE_DEFAULT_EXCHANGE_RATE = 0.50;

    @InvocableMethod(
        label='Update Ripple Asset Token Exchange Rate'
        description='Fetches current exchange rate for Ripple and updates Asset Token record'
        callout=true
    )
    public static List<Decimal> updateRippleAssetTokenExchangeRate() {
        Decimal newExchangeRate = getRippleExchangeRate(false);
        Asset_Token__c rippleAssetToken = AssetTokenSelector.getAssetTokenByAsset(
            RIPPLE_ASSET
        );

        if (newExchangeRate != null && rippleAssetToken != null) {
            rippleAssetToken.ConversionRate__c = newExchangeRate;
            rippleAssetToken.ConversionRateLastSet__c = Datetime.now();

            update as user rippleAssetToken;
        }

        return new List<Decimal>{ rippleAssetToken.ConversionRate__c };
    }

    public static void initializeAssetTokens() {
        List<Asset_Token__c> assetTokens = getAssetTokens();
        insert as user assetTokens;
    }

    private static List<Asset_Token__c> getAssetTokens() {
        List<Asset_Token__c> assetTokens = new List<Asset_Token__c>();

        Asset_Token__c rippleAssetToken = new Asset_Token__c();
        rippleAssetToken.Name = RIPPLE_NAME;
        rippleAssetToken.Asset__c = RIPPLE_ASSET;
        rippleAssetToken.Active__c = true;
        rippleAssetToken.CoinGeckoAPIName__c = RIPPLE_COIN_GECKO_API_NAME;
        rippleAssetToken.ConversionRate__c = getRippleExchangeRate(true);
        rippleAssetToken.ConversionRateLastSet__c = Datetime.now();

        assetTokens.add(rippleAssetToken);
        return assetTokens;
    }

    private static Decimal getRippleExchangeRate(Boolean onErrorDefault) {
        try {
            return new CoinGeckoService()
                .getExchangeRate(
                    RIPPLE_COIN_GECKO_API_NAME,
                    CurrencyService.defaultCurrencyCode
                );
        } catch (Exception error) {
            Decimal result;
            if (onErrorDefault) {
                result = RIPPLE_DEFAULT_EXCHANGE_RATE;
            }
            return result;
        }
    }
}
