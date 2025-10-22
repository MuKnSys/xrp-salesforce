public with sharing class SetupCtrl {
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
                String domainVal = settingValues.get('siteDomain');
                // Strip trailing slash if present
                if (domainVal.endsWith('/')) {
                    domainVal = domainVal.substring(0, domainVal.length() - 1);
                }

                if (!isValidUrl(domainVal)) {
                    throw new AuraHandledException('Site Domain URL is not valid. It must start with http:// or https:// and include a host name.');
                }
                settings.XRPSiteDomainUrl__c = domainVal;
            }

            if (settingValues.get('baseUrl') != null) {
                String baseVal = settingValues.get('baseUrl');
                if (baseVal.endsWith('/')) {
                    baseVal = baseVal.substring(0, baseVal.length() - 1);
                }
                if (!isValidUrl(baseVal)) {
                    throw new AuraHandledException('Webhook Server URL is not valid.');
                }
                settings.XRPWebhookBaseUrl__c = baseVal;
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
    public static void clearSettings() {
        try {
            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
            settings.XRPWebhookApiKey__c = null;
            settings.XRPWebhookApiSecret__c = null;
            settings.XRPSiteDomainUrl__c = null;
            settings.XRPWebhookBaseUrl__c = null;
            settings.XRPWebhookId__c = null;
            settings.AssetTokensInitialized__c = false;

            // False Positive - Custom Settings need to be hidden but accessible via Apex
            upsert as system settings;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Settings initializeAssetTokens() {
        try {
            AssetTokenService.initializeAssetTokens();

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

    private static Boolean isValidUrl(String url) {
        if (url == null) return false;
        Pattern p = Pattern.compile('^https?://[A-Za-z0-9._%+-]+(?:\\:[0-9]+)?(?:/.*)?$');
        return p.matcher(url).matches();
    }

    public class Settings {
        @AuraEnabled
        public String apiKey;
        @AuraEnabled
        public String apiSecret;
        @AuraEnabled
        public String webhookId;
        @AuraEnabled
        public String baseUrl;
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
            this.baseUrl = settings.XRPWebhookBaseUrl__c;
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
