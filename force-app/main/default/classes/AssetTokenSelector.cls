public inherited sharing class AssetTokenSelector {
    public static Asset_Token__c getAssetTokenByAssetSystem(String asset) {
        List<Asset_Token__c> assetToken = [
            SELECT ConversionRate__c
            FROM Asset_Token__c
            WHERE Asset__c = :asset
            WITH SYSTEM_MODE
        ];

        return assetToken.isEmpty() ? null : assetToken[0];
    }
}
