public with sharing class AssetTokenService {
    @TestVisible
    private static final String RIPPLE_NAME = 'XRP (FKA Ripple)';
    @TestVisible
    private static final String RIPPLE_ASSET = 'XRP';
    @TestVisible
    private static final String RIPPLE_COIN_GECKO_API_NAME = 'ripple';
    @TestVisible
    private static final Decimal RIPPLE_DEFAULT_EXCHANGE_RATE = 0.50;

    @InvocableMethod(
        label='Update Ripple Asset Token Exchange Rate / Transaction Value'
        description='Fetches current exchange rate for Ripple and updates Asset Token / Transaction records'
    )
    public static void updateRippleAssetTokenExchangeRate(
        List<Id> transactionIds
    ) {
        updateRippleAssetTokenExchangeRateAsyncWrapper(transactionIds);
    }

    @future(callout=true)
    public static void updateRippleAssetTokenExchangeRateAsyncWrapper(
        List<Id> transactionIds
    ) {
        Decimal newExchangeRate = updateAssetTokenExchangeRate();
        updateTransactionValue(transactionIds, newExchangeRate);
    }

    private static Decimal updateAssetTokenExchangeRate() {
        Decimal newExchangeRate = getRippleExchangeRate(false);
        Asset_Token__c rippleAssetToken = AssetTokenSelector.getAssetTokenByAsset(
            RIPPLE_ASSET
        );

        if (newExchangeRate != null && rippleAssetToken != null) {
            rippleAssetToken.ConversionRate__c = newExchangeRate;
            rippleAssetToken.ConversionRateLastSet__c = Datetime.now();

            update as user rippleAssetToken;
        }

        return newExchangeRate;
    }

    private static void updateTransactionValue(
        List<Id> transactionIds,
        Decimal newExchangeRate
    ) {
        SObject chainTransaction;
        try {
            if (transactionIds.isEmpty() || newExchangeRate == null) {
                throw new AssetTokenException();
            }
            Id transactionId = transactionIds[0];

            List<SObject> chainTransactions = TransactionSelector.getTransactionById(
                transactionId
            );

            if (chainTransactions.isEmpty()) {
                throw new AssetTokenException();
            }
            chainTransaction = chainTransactions[0];

            chainTransaction.put(
                'Transaction_Value__c',
                (Decimal) chainTransaction.get('Value__c') * newExchangeRate
            );
            chainTransaction.put(
                'System_Notes__c',
                System.Label.flow_exchange_rate_success_calculated
            );

            update chainTransaction;
        } catch (AssetTokenException error) {
            if (chainTransaction != null) {
                chainTransaction.put(
                    'System_Notes__c',
                    System.Label.flow_exchange_rate_error_calculated
                );
                update chainTransaction;
            }
        }
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

    public class AssetTokenException extends Exception {
    }
}
