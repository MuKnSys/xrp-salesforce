// False Positive: This class needs to work in System Mode - callback from Webhook App
public without sharing class XrpPaymentService {
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

        List<Org_Wallet__c> orgWallets = [
            SELECT Id, Wallet_Address__c
            FROM Org_Wallet__c
            WHERE Wallet_Address__c IN :walletAddresses
            WITH SYSTEM_MODE
        ];

        if (orgWallets.isEmpty()) {
            // Not recognized Org Wallet - not tracking this payment
            return;
        }

        if (orgWallets.size() == 1) {
            Org_Wallet__c wallet = orgWallets[0];

            if (wallet.Wallet_Address__c == transcationData.get('Account')) {
                Outbound_Blockchain_Transaction__c outboundTransaction = new Outbound_Blockchain_Transaction__c();
                outboundTransaction.Org_Wallet__c = wallet.Id;
                outboundTransaction.Network_Name__c = 'XRP_Mainnet';
                outboundTransaction.Value__c = (Decimal) transcationData.get(
                    'Amount'
                );
                outboundTransaction.BlockNum__c = (String) paymentData.get(
                    'ledger_index'
                );
                outboundTransaction.Transaction_Timestamp__c = Datetime.newInstance(
                    946684800 + (Integer) transcationData.get('date')
                );
                outboundTransaction.Account_Wallet__c = null;
            } else if (
                wallet.Wallet_Address__c == transcationData.get('Destination')
            ) {
                Inbound_Blockchain_Transaction__c inboundTransaction = new Inbound_Blockchain_Transaction__c();
                inboundTransaction.Org_Wallet__c = wallet.Id;
                inboundTransaction.Network_Name__c = 'XRP_Mainnet';
                inboundTransaction.Value__c = (Decimal) transcationData.get(
                    'Amount'
                );
                inboundTransaction.BlockNum__c = (String) paymentData.get(
                    'ledger_index'
                );
                inboundTransaction.Transaction_Timestamp__c = Datetime.newInstance(
                    946684800 + (Integer) transcationData.get('date')
                );
                inboundTransaction.Account_Wallet__c = null;
            }
        }
    }
}
