@isTest
private class XrpPaymentApi_Test {
    @isTest
    static void doPost_SuccessCreateOutboundTransaction() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/xrp/payments';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(getPrepBody());

        RestContext.request = req;
        RestContext.response = res;

        OrgWalletService.triggerOn = false;

        Org_Wallet__c orgWallet = new Org_Wallet__c();
        orgWallet.Test_Networks__c = true;
        orgWallet.Wallet_Address__c = 'rNEygqkMv4Vnj8M2eWnYT1TDnV1Sc1X5SN';
        insert orgWallet;

        Account_Wallet__c accWallet = new Account_Wallet__c();
        accWallet.Test_Wallet__c = true;
        accWallet.Wallet_Address__c = 'rP1afBEfikTz7hJh2ExCDni9W4Bx1dUMRk';
        insert accWallet;

        Test.startTest();
        XrpPaymentApi.doPost();
        Test.stopTest();

        List<Outbound_Blockchain_Transaction__c> outboundTransaction = [
            SELECT Id, Account_Wallet__c
            FROM Outbound_Blockchain_Transaction__c
            WHERE Org_Wallet__c = :orgWallet.Id
        ];

        List<Inbound_Blockchain_Transaction__c> inboundTransactions = [
            SELECT Id, Account_Wallet__c
            FROM Inbound_Blockchain_Transaction__c
            WHERE Org_Wallet__c = :orgWallet.Id
        ];

        Assert.areEqual(outboundTransaction.size(), 1);
        Assert.areEqual(outboundTransaction[0].Account_Wallet__c, accWallet.Id);
        Assert.areEqual(inboundTransactions.size(), 0);
    }

    @isTest
    static void doPost_SuccessCreateInboundTransaction() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/xrp/payments';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(getPrepBody());

        RestContext.request = req;
        RestContext.response = res;

        OrgWalletService.triggerOn = false;

        Org_Wallet__c orgWallet = new Org_Wallet__c();
        orgWallet.Test_Networks__c = true;
        orgWallet.Wallet_Address__c = 'rP1afBEfikTz7hJh2ExCDni9W4Bx1dUMRk';
        insert orgWallet;

        Account_Wallet__c accWallet = new Account_Wallet__c();
        accWallet.Test_Wallet__c = true;
        accWallet.Wallet_Address__c = 'rNEygqkMv4Vnj8M2eWnYT1TDnV1Sc1X5SN';
        insert accWallet;

        Test.startTest();
        XrpPaymentApi.doPost();
        Test.stopTest();

        List<Outbound_Blockchain_Transaction__c> outboundTransaction = [
            SELECT Id, Account_Wallet__c
            FROM Outbound_Blockchain_Transaction__c
            WHERE Org_Wallet__c = :orgWallet.Id
        ];

        List<Inbound_Blockchain_Transaction__c> inboundTransactions = [
            SELECT Id, Account_Wallet__c
            FROM Inbound_Blockchain_Transaction__c
            WHERE Org_Wallet__c = :orgWallet.Id
        ];

        Assert.areEqual(inboundTransactions.size(), 1);
        Assert.areEqual(inboundTransactions[0].Account_Wallet__c, accWallet.Id);
        Assert.areEqual(outboundTransaction.size(), 0);
    }

    private static String getPrepBody() {
        return '{"validated":true,"type":"transaction","transaction":' +
            '{"hash":"D8C12166A6ECCCE097B059168CF3DE869573D358F65DD6B687365F8CCB439CD6",' +
            '"date":603665393,"TxnSignature":"3045022100B62D73409E327FB87F4D24A05523A93FA6684A39ACBE92784B16077C0DBBF036022048186886025CA1A50FF84A6CA0B17E19104EB747FFCA7F2D277638E66BB5BE17",' +
            '"TransactionType":"Payment","SigningPubKey":"02FC56A7601914BC0462E28994EF7F059D5A23AA17705BAD668E3E4EE00450FFB9"' +
            ',"Sequence":59011,"Flags":2147483648,"Fee":"310","DestinationTag":84201897,"Destination":"rP1afBEfikTz7hJh2ExCDni9W4Bx1dUMRk"' +
            ',"Amount":"115821286","Account":"rNEygqkMv4Vnj8M2eWnYT1TDnV1Sc1X5SN"},"status":"closed",' +
            '"meta":{"TransactionResult":"tesSUCCESS","TransactionIndex":6,' +
            '"AffectedNodes":[{"ModifiedNode":{"PreviousTxnLgrSeq":45184725,' +
            '"PreviousTxnID":"AFCCC8270E6E8F2B49FA3B293158033997CB0919CA31CDADA1A57FBF714A36FF",' +
            '"PreviousFields":{"Sequence":59011,"Balance":"471349886438"},' +
            '"LedgerIndex":"2D559E46C77FAFDE39F992FF332E32A2E34C4AC5320E3ABC3B2C24F5BD8385C7",' +
            '"LedgerEntryType":"AccountRoot","FinalFields":{"Sequence":59012,"OwnerCount":0,' +
            '"Flags":131072,"Domain":"6274637475726B2E636F6D","Balance":"471234064842","Account":"rNEygqkMv4Vnj8M2eWnYT1TDnV1Sc1X5SN"}}}' +
            ',{"ModifiedNode":{"PreviousTxnLgrSeq":45184724,"PreviousTxnID":"1C05307E92E841DB3CC13ECCD5354B635E539E2F75297F184B869C9BEB204516",' +
            '"PreviousFields":{"Balance":"376583497695"},"LedgerIndex":"628BCCF8592C8C2D861630192D758E712C0DC9B4101F89CE47EC4694B71B1E69",' +
            '"LedgerEntryType":"AccountRoot","FinalFields":{"Sequence":841,"OwnerCount":0,"Flags":131072,"Balance":"376699318981","Account":"rP1afBEfikTz7hJh2ExCDni9W4Bx1dUMRk"}}}]},' +
            '"ledger_index":45184774,"ledger_hash":"887EA4DFE99460F5A5A642F45BAEE33A5CE138B67EA69323FF0BC504960CB845",' +
            '"engine_result_message":"The transaction was applied. Only final in a validated ledger.","engine_result_code":0,"engine_result":"tesSUCCESS"}';
    }
}
