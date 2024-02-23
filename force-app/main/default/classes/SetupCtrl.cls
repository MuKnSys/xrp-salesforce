public with sharing class SetupCtrl {
    private static final String RIPPLE_NAME = 'XRP (FKA Ripple)';
    private static final String RIPPLE_ASSET = 'XRP';
    private static final String RIPPLE_COIN_GECKO_API_NAME = 'ripple';
    private static final Decimal RIPPLE_DEFAULT_EXCHANGE_RATE = 0.50;

    @AuraEnabled
    public static Settings getSettings() {
        try {
            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
            return new Settings(settings);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Settings saveSettings(Map<String, String> settingValues) {
        try {
            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;

            if (settingValues.get('apiKey') != null) {
                settings.XRPWebhookApiKey__c = settingValues.get('apiKey');
            }

            if (settingValues.get('apiSecret') != null) {
                settings.XRPWebhookApiSecret__c = settingValues.get(
                    'apiSecret'
                );
            }

            if (settingValues.get('siteDomain') != null) {
                settings.XRPSiteDomainUrl__c = settingValues.get('siteDomain');
            }

            // False Positive - Custom Settings need to be hidden
            // but need to be accessible through Apex - action performed only by Admin on Setup Stage
            upsert as system settings;

            return new Settings(settings);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void subscribeWebhook() {
        try {
            XrpWebhookService.RegisterWebhookResponse result = XrpWebhookService.registerWebhook();

            if (!result.success) {
                throw new XrpWebhookApi.XrpWebhookAPIException(
                    System.Label.setup_register_web_hook_error
                );
            }

            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
            settings.XRPWebhookId__c = result.webhook_id;

            // False Positive - Custom Settings need to be hidden
            // but need to be accessible through Apex - action performed only by Admin on Setup Stage
            update as system settings;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteWebhook() {
        try {
            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
            XrpWebhookService.deleteWebhook(settings.XRPWebhookId__c);
            settings.XRPWebhookId__c = null;

            // False Positive - Custom Settings need to be hidden
            // but need to be accessible through Apex - action performed only by Admin on Setup Stage
            update as system settings;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Settings initializeAssetTokens() {
        try {
            Decimal exchangeRate;
            try {
                exchangeRate = new CoinGeckoService()
                    .getExchangeRate(
                        RIPPLE_COIN_GECKO_API_NAME,
                        CurrencyService.getDefaultCurrencyCode()
                    );
            } catch (Exception error) {
                exchangeRate = RIPPLE_DEFAULT_EXCHANGE_RATE;
            }

            Asset_Token__c assetToken = new Asset_Token__c();
            assetToken.Name = RIPPLE_NAME;
            assetToken.Asset__c = RIPPLE_ASSET;
            assetToken.Active__c = true;
            assetToken.CoinGeckoAPIName__c = RIPPLE_COIN_GECKO_API_NAME;
            assetToken.ConversionRate__c = exchangeRate;
            assetToken.ConversionRateLastSet__c = Datetime.now();
            insert as user assetToken;

            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
            settings.AssetTokensInitialized__c = true;

            // False Positive - Custom Settings need to be hidden
            // but need to be accessible through Apex - action performed only by Admin on Setup Stage
            update as system settings;

            return new Settings(settings);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Settings {
        @AuraEnabled
        public String apiKey;
        @AuraEnabled
        public String apiSecret;
        @AuraEnabled
        public String webhookId;
        @AuraEnabled
        public String siteDomain;
        @AuraEnabled
        public Boolean assetTokensInitialized;

        public Settings() {
        }

        public Settings(XRPForSalesforceSettings__c settings) {
            this.apiKey = isBlank(settings.XRPWebhookApiKey__c)
                ? null
                : System.Label.settings_api_key_setted;
            this.apiSecret = isBlank(settings.XRPWebhookApiSecret__c)
                ? null
                : System.Label.settings_api_secret_setted;
            this.webhookId = isBlank(settings.XRPWebhookId__c)
                ? null
                : System.Label.settings_webhook_id_setted;
            this.siteDomain = isBlank(settings.XRPSiteDomainUrl__c)
                ? null
                : System.Label.settings_site_domain_setted;
            this.assetTokensInitialized = isBlank(settings.XRPSiteDomainUrl__c)
                ? false
                : settings.AssetTokensInitialized__c;
        }

        private Boolean isBlank(String value) {
            return value == null || value == '';
        }
    }
}
