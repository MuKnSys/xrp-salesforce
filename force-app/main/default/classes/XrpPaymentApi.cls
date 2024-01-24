@RestResource(urlMapping='/api/xrp/payments/*')
global with sharing class XrpPaymentApi {
    @HttpPost
    global static void doPost() {
        System.debug('POST Occured');

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        System.debug(req.requestURI);
        System.debug(req.requestBody.toString());
        System.debug(req.headers);
        System.debug(req.params);
        System.debug(req.remoteAddress);
    }
}
