public with sharing class XrpWebhookApi {
    private final static String XRP_WEBHOOK_ENDPOINT = 'https://webhook.xrpayments.co';
    private final static Integer SUCCESS_CODE = 200;
    private HttpRequest request;

    public XrpWebhookApi(String urlSuffix) {
        XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
        if (settings.XRPWebhookApiKey__c == null || settings.XRPWebhookApiSecret__c == null) {
            throw new XrpWebhookAPIException(System.Label.api_app_not_correctly_configred);
        }

        request = new HttpRequest();
        request.setEndpoint(XRP_WEBHOOK_ENDPOINT + urlSuffix);
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('x-api-key', settings.XRPWebhookApiKey__c);
        request.setHeader('x-api-secret', settings.XRPWebhookApiSecret__c);
    }

    public XrpWebhookApi post() {
        request.setMethod('POST');
        return this;
    }

    public XrpWebhookApi body(Object payload) {
        request.setBody(JSON.serialize(payload));
        return this;
    }

    public HttpResponse callout() {
        HttpResponse response = null;

        try {
            response = new Http().send(request);
            if(response.getStatusCode() != SUCCESS_CODE) {
                throw new XrpWebhookAPIException('Code: ' + response.getStatusCode() + ', Message: ' + response.getBody() + '.');
            }
        } 
        catch(Exception error) {
            throw new XrpWebhookAPIException('Failed calling ' + request.getEndpoint() + ' :' + error.getMessage(), error);
        }

        return response;
    }

    public class XrpWebhookAPIException extends Exception {}
}