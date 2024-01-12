public with sharing class SetupCtrl {
    @AuraEnabled
    public static Settings getSettings(){
        try {
            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
            return new Settings(settings.XRPWebhookApiKey__c, settings.XRPWebhookApiSecret__c);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveSettings(String apiKey, String apiSecret) {
        try {
            XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;

            settings.XRPWebhookApiKey__c = apiKey;
            settings.XRPWebhookApiSecret__c = apiSecret;

            upsert as user settings;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Settings {
        @AuraEnabled public Boolean apiKey;
        @AuraEnabled public Boolean apiSecret;

        public Settings(){}

        public Settings(String apiKey, String apiSecret){
            this.apiKey = apiKey != null;
            this.apiSecret = apiSecret != null;
        }
    }
}