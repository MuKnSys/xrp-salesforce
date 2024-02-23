public with sharing class CurrencyService {
    public static String getDefaultCurrencyCode() {
        // Assumption: No Support for Multicurrency Orgs
        return UserInfo.getDefaultCurrency();
    }
}
