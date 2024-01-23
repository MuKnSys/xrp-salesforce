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
                settings.XRPSiteDomainUrl__c = settingValues.get('siteDomain');
            }

            // False Positive - Only Admin can perform this
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

    public class Settings {
        @AuraEnabled
        public String apiKey;
        @AuraEnabled
        public String apiSecret;
        @AuraEnabled
        public String webhookId;
        @AuraEnabled
        public String siteDomain;

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
        }

        private Boolean isBlank(String value) {
            return value == null || value == '';
        }
    }
}
