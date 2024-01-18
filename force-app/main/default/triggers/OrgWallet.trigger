trigger OrgWallet on Org_Wallet__c (after insert) {
    OrgWalletService.execute(Trigger.new);
}