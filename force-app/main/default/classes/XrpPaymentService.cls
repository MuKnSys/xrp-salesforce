// False Positive: This class needs to work in System Mode - callback from Webhook App
public without sharing class XrpPaymentService {
    public static final Long RIPPLE_EPOCH_TO_TIMESTAM_SECONDS_ADJUSTMENT = 946684800;
    public static final Decimal RIPPLE_DROP = 1000000;

    public static void processIncomingPayment(String requestBody) {
        Map<String, Object> paymentData = (Map<String, Object>) JSON.deserializeUntyped(
            requestBody
        );

        Map<String, Object> transcationData = (Map<String, Object>) paymentData.get(
            'transaction'
        );

        Set<String> walletAddresses = new Set<String>{
            (String) transcationData.get('Account'),
            (String) transcationData.get('Destination')
        };

        List<Org_Wallet__c> orgWallets = OrgWalletSelectorSystem.getOrgWalletByWalletAddressesSystemMode(
            walletAddresses
        );

        if (orgWallets.isEmpty()) {
            // Not recognized Org Wallet - not tracking this payment
            return;
        }

        Map<String, Account_Wallet__c> accountWalletsByWalletAddress = getAccountWalletsByWalletAddress(
            walletAddresses
        );

        if (orgWallets.size() == 1) {
            Org_Wallet__c wallet = orgWallets[0];

            if (wallet.Wallet_Address__c == transcationData.get('Account')) {
                Outbound_Blockchain_Transaction__c outboundTransaction = new Outbound_Blockchain_Transaction__c();
                outboundTransaction.Org_Wallet__c = wallet.Id;
                outboundTransaction.Account_Wallet__c = accountWalletsByWalletAddress.get(
                        (String) transcationData.get('Destination')
                    )
                    ?.Id;

                outboundTransaction = (Outbound_Blockchain_Transaction__c) setGeneralTransactionProperties(
                    outboundTransaction,
                    paymentData,
                    transcationData
                );

                insert as system outboundTransaction;
            } else if (
                wallet.Wallet_Address__c == transcationData.get('Destination')
            ) {
                Inbound_Blockchain_Transaction__c inboundTransaction = new Inbound_Blockchain_Transaction__c();
                inboundTransaction.Org_Wallet__c = wallet.Id;
                // Make wallet lookup null-safe. If the sender wallet is unknown we leave the field blank instead of throwing NPE.
                inboundTransaction.Account_Wallet__c = accountWalletsByWalletAddress
                    .get((String) transcationData.get('Account'))
                    ?.Id;

                inboundTransaction = (Inbound_Blockchain_Transaction__c) setGeneralTransactionProperties(
                    inboundTransaction,
                    paymentData,
                    transcationData
                );

                insert as system inboundTransaction;
            }
        }
    }

    private static Map<String, Account_Wallet__c> getAccountWalletsByWalletAddress(
        Set<String> walletAddresses
    ) {
        Map<String, Account_Wallet__c> accountWalletsByWalletAddress = new Map<String, Account_Wallet__c>();
        for (
            Account_Wallet__c wallet : AccountWalletSelectorSystem.getOrgWalletByWalletAddressesSystemMode(
                walletAddresses
            )
        ) {
            accountWalletsByWalletAddress.put(wallet.Wallet_Address__c, wallet);
        }
        return accountWalletsByWalletAddress;
    }

    private static sObject setGeneralTransactionProperties(
        sObject paymentTransaction,
        Map<String, Object> paymentData,
        Map<String, Object> transcationData
    ) {
        // Prefer delivered_amount; fallback to Amount
        Object rawAmt = paymentData.containsKey('delivered_amount') && paymentData.get('delivered_amount')!=null
            ? paymentData.get('delivered_amount')
            : transcationData.get('Amount');

        if (rawAmt instanceof String) {
            // Native XRP in drops (string integer)
            paymentTransaction.put('Asset__c', 'XRP');
            paymentTransaction.put('Value__c', convertRippleDrop(Decimal.valueOf((String)rawAmt)));
        } else if (rawAmt instanceof Map<String,Object>) {
            Map<String,Object> amt = (Map<String,Object>)rawAmt;
            paymentTransaction.put('Asset__c', (String)amt.get('currency'));
            paymentTransaction.put('Value__c', Decimal.valueOf((String)amt.get('value')));
            paymentTransaction.put('Contract_Address__c', (String)amt.get('issuer'));
        } else {
            // unknown format – default 0
            paymentTransaction.put('Asset__c','UNKNOWN');
            paymentTransaction.put('Value__c',0);
        }

        paymentTransaction.put(
            'From_Address__c',
            (String) transcationData.get('Account')
        );
        paymentTransaction.put('Network_Name__c', 'XRP_Mainnet');
        paymentTransaction.put(
            'BlockNum__c',
            String.valueOf((Integer) paymentData.get('ledger_index'))
        );
        paymentTransaction.put(
            'Transaction_Timestamp__c',
            convertRippleTimestamptoDatetime((Long) transcationData.get('date'))
        );
        paymentTransaction.put(
            'Transaction_Hash__c',
            (String) transcationData.get('hash')
        );
        // Link to public explorer for quick reference
        paymentTransaction.put(
            'Transaction_Detail__c',
            'https://xrpscan.com/tx/' + (String) transcationData.get('hash')
        );
        paymentTransaction.put(
            'To_Address__c',
            (String) transcationData.get('Destination')
        );
        return paymentTransaction;
    }

    private static Datetime convertRippleTimestamptoDatetime(
        Long rippleTimestamp
    ) {
        return Datetime.newInstance(
            (RIPPLE_EPOCH_TO_TIMESTAM_SECONDS_ADJUSTMENT + rippleTimestamp) *
            1000
        );
    }

    private static Decimal convertRippleDrop(Decimal chainAmount) {
        return chainAmount / RIPPLE_DROP;
    }
}
