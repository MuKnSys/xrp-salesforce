public with sharing class XRPForSalesforceSettingsService {
    public static XRPForSalesforceSettings__c settings {
        get {
            if (settings == null) {
                settings = XRPForSalesforceSettings__c.getOrgDefaults();
            }
            return settings;
        }
        set;
    }
}