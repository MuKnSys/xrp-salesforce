// Used in System Mode for System User - should Bypass OLS/FLS 
public without sharing class AssetTokenInvocable {
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
        Id transactionId = transactionIds[0];
        Decimal newExchangeRate = updateAssetTokenExchangeRate();
        TransactionService.updateTransactionValue(transactionId, newExchangeRate);
    }

    private static Decimal updateAssetTokenExchangeRate() {
        Decimal newExchangeRate = AssetTokenService.getRippleExchangeRate(false);
        Asset_Token__c rippleAssetToken = AssetTokenSelector.getAssetTokenByAssetSystem(
            AssetTokenService.RIPPLE_ASSET
        );

        if (newExchangeRate != null && rippleAssetToken != null) {
            rippleAssetToken.ConversionRate__c = newExchangeRate;
            rippleAssetToken.ConversionRateLastSet__c = Datetime.now();

            update as system rippleAssetToken;
        }

        return newExchangeRate;
    }
}