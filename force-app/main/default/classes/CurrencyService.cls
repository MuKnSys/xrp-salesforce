public with sharing class CurrencyService {
    // Assumption: No Support for Multicurrency Orgs
    public static String defaultCurrencyCode {
        get {
            if (defaultCurrencyCode == null) {
                defaultCurrencyCode = UserInfo.getDefaultCurrency();
            }
            return defaultCurrencyCode;
        }
        set;
    }
}
