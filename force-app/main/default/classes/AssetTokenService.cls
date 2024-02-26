public with sharing class AssetTokenService {
    private static final String RIPPLE_NAME = 'XRP (FKA Ripple)';
    private static final String RIPPLE_ASSET = 'XRP';
    @TestVisible
    private static final String RIPPLE_COIN_GECKO_API_NAME = 'ripple';
    private static final Decimal RIPPLE_DEFAULT_EXCHANGE_RATE = 0.50;

    public void initializeAssetTokens() {
        List<Asset_Token__c> assetTokens = getAssetTokens();
        insert as user assetTokens;
    }

    private List<Asset_Token__c> getAssetTokens() {
        List<Asset_Token__c> assetTokens = new List<Asset_Token__c>();

        Asset_Token__c rippleAssetToken = new Asset_Token__c();
        rippleAssetToken.Name = RIPPLE_NAME;
        rippleAssetToken.Asset__c = RIPPLE_ASSET;
        rippleAssetToken.Active__c = true;
        rippleAssetToken.CoinGeckoAPIName__c = RIPPLE_COIN_GECKO_API_NAME;
        rippleAssetToken.ConversionRate__c = getRippleExchangeRate();
        rippleAssetToken.ConversionRateLastSet__c = Datetime.now();

        assetTokens.add(rippleAssetToken);
        return assetTokens;
    }

    private Decimal getRippleExchangeRate() {
        try {
            return new CoinGeckoService()
                .getExchangeRate(
                    RIPPLE_COIN_GECKO_API_NAME,
                    CurrencyService.defaultCurrencyCode
                );
        } catch (Exception error) {
            return RIPPLE_DEFAULT_EXCHANGE_RATE;
        }
    }
}
