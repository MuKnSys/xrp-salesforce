public with sharing class XrpWebhookApi {
    private final static String XRP_WEBHOOK_ENDPOINT = 'https://webhook.xrpayments.co';
    private final static Map<String, Integer> HTTP_METHOD_BY_HTTP_CODE = new Map<String, Integer> {
        'POST' => 200,
        'DELETE' => 204
    };
    private HttpRequest request;

    public XrpWebhookApi(String urlSuffix, Boolean checkWebhookId) {
        XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
        if (settings.XRPWebhookApiKey__c == null || settings.XRPWebhookApiSecret__c == null || checkWebhookId ? settings.XRPWebhookId__c == null : false) {
            throw new XrpWebhookAPIException(System.Label.api_app_not_correctly_configred);
        }

        request = new HttpRequest();
        request.setEndpoint(XRP_WEBHOOK_ENDPOINT + urlSuffix);
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('x-api-key', settings.XRPWebhookApiKey__c);
        request.setHeader('x-api-secret', settings.XRPWebhookApiSecret__c);
    }

    public XrpWebhookApi doPost() {
        request.setMethod('POST');
        return this;
    }

    public XrpWebhookApi doDelete() {
        request.setMethod('DELETE');
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
        } 
        catch(Exception error) {
            throw new XrpWebhookAPIException('Failed calling ' + request.getEndpoint() + ' :' + error.getMessage(), error);
        }

        if(response.getStatusCode() != HTTP_METHOD_BY_HTTP_CODE.get(request.getMethod())) {
            Map<String, String> message = (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class);
            throw new XrpWebhookAPIException('Code: ' + response.getStatusCode() + ', Message: ' + message.get('error') + '.');
        }

        return response;
    }

    public class XrpWebhookAPIException extends Exception {}
}