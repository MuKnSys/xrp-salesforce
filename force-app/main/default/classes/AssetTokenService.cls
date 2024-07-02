public with sharing class AssetTokenService {
    @TestVisible
    private static final String RIPPLE_NAME = 'XRP (FKA Ripple)';
    public static final String RIPPLE_ASSET = 'XRP';
    @TestVisible
    private static final String RIPPLE_COIN_GECKO_API_NAME = 'ripple';
    @TestVisible
    private static final String RIPPLE_COIN_GECKO_TOKEN_INFO = 'https://xrpl.org/';
    @TestVisible
    private static final Decimal RIPPLE_DEFAULT_EXCHANGE_RATE = 0.50;

    public static void initializeAssetTokens() {
        List<Asset_Token__c> assetTokens = getAssetTokens();
        upsert as user assetTokens Asset__c;
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
        rippleAssetToken.TokenInformation__c = RIPPLE_COIN_GECKO_TOKEN_INFO;

        assetTokens.add(rippleAssetToken);
        return assetTokens;
    }

    public static Decimal getRippleExchangeRate(Boolean onErrorDefault) {
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

    public class AssetTokenException extends Exception {
    }
}
