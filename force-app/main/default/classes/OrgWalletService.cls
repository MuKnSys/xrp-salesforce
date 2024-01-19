public with sharing class OrgWalletService {
    public static final Integer MAXIMUM_AMOUNT_OF_CALLOUTS = 90; 

    public static void execute(List<Org_Wallet__c> wallets){
        processXRPWebhooks(wallets);
    }

    private static void processXRPWebhooks(List<Org_Wallet__c> wallets) {
        List<List<String>> addressesBulkiefied = new List<List<String>>();
        List<String> addressesSubSet = new List<String>();

        for(Org_Wallet__c wallet : wallets) {
            if(wallet.Wallet_Address__c != null) {
                addressesSubSet.add(wallet.Wallet_Address__c);
                
                if (addressesSubSet.size() >= MAXIMUM_AMOUNT_OF_CALLOUTS) {
                    addressesBulkiefied.add(addressesSubSet);
                    addressesSubSet = new List<String>();
                }
            }
        }

        if(!addressesSubSet.isEmpty()){
            addressesBulkiefied.add(addressesSubSet);
        }

        for(List<String> addresses : addressesBulkiefied) {
            subscribeToAddressWrapper(addresses);
        }
    }

    @future(callout=true)
    public static void subscribeToAddressWrapper(List<String> addresses)
    {   
        Map<String, String> subscriptionIdByAddress = new Map<String, String>();

        for(String address : addresses){
            XrpWebhookService.RegisterSubscriptionResponse response = XrpWebhookService.subscribeToAddress(address);
            subscriptionIdByAddress.put(address, response.subscription_id);
        }

        List<Org_Wallet__c> wallets = new List<Org_Wallet__c>();
        for(Org_Wallet__c wallet : OrgWalletSelector.getOrgWalletByWalletAddresses(subscriptionIdByAddress.keySet())){
            wallet.XRPWebhookSubscriptionId__c = subscriptionIdByAddress.get(wallet.Wallet_Address__c);
            wallets.add(wallet);
        }

        update as user wallets;
    }
}