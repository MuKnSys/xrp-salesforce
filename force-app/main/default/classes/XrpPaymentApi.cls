@RestResource(urlMapping='/api/xrp/payments/*')
global with sharing class XrpPaymentApi {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        XrpPaymentService.processIncomingPayment(req.requestBody.toString());
    }
}
