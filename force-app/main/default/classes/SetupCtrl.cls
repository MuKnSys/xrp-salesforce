public with sharing class SetupCtrl {
    @AuraEnabled
    public static Settings getSettings(){
        try {
            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
            return new Settings(settings);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Settings saveSettings(String apiKey, String apiSecret) {
        try {
            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
            settings.XRPWebhookApiKey__c = apiKey;
            settings.XRPWebhookApiSecret__c = apiSecret;

            // False Positive - Only Admin can perform this
            upsert as system settings;

            return new Settings(settings);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Settings {
        @AuraEnabled public String apiKey;
        @AuraEnabled public String apiSecret;

        public Settings(){}

        public Settings(XRPForSalesforceSettings__c settings){
            this.apiKey = isBlank(settings.XRPWebhookApiKey__c) ? null : System.Label.settings_api_key_setted;
            this.apiSecret = isBlank(settings.XRPWebhookApiSecret__c) ? null :  System.Label.settings_api_secret_setted; 
        }

        private Boolean isBlank(String value) {
            return value == null || value == '';
        }
    }
}