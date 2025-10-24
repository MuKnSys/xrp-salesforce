public with sharing class XrpWebhookApi {
    private final static String DEFAULT_ENDPOINT = 'https://xrpwebhooks.web3enabler.net';
    private final static Map<String, Integer> HTTP_METHOD_BY_HTTP_CODE = new Map<String, Integer>{
        'POST' => 200,
        'DELETE' => 200
    };
    private HttpRequest request;

    public XrpWebhookApi(String urlSuffix, Boolean checkWebhookId) {
        XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
        if (
            settings.XRPWebhookApiKey__c == null ||
                settings.XRPWebhookApiSecret__c == null ||
                settings.XRPSiteDomainUrl__c == null ||
                checkWebhookId
                ? settings.XRPWebhookId__c == null
                : false
        ) {
            throw new XrpWebhookAPIException(
                System.Label.api_app_not_correctly_configred
            );
        }

        String base = String.isBlank(settings.XRPWebhookBaseUrl__c)
            ? DEFAULT_ENDPOINT
            : settings.XRPWebhookBaseUrl__c;
        if (base.endsWith('/')) {
            base = base.substring(0, base.length() - 1);
        }

        request = new HttpRequest();
        request.setEndpoint(base + urlSuffix);
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
            // Debug logging: output full request details for testing purposes
            System.debug(LoggingLevel.INFO, 'XrpWebhookApi request: Method=' + request.getMethod() + ' Endpoint=' + request.getEndpoint());
            System.debug(LoggingLevel.INFO, 'Headers: Content-Type=' + request.getHeader('Content-Type') + ', x-api-key=' + request.getHeader('x-api-key') + ', x-api-secret=' + request.getHeader('x-api-secret'));
            System.debug(LoggingLevel.INFO, 'Request Body: ' + request.getBody());

            response = new Http().send(request);
        } catch (Exception error) {
            throw new XrpWebhookAPIException(
                'Failed calling ' +
                    request.getEndpoint() +
                    ' :' +
                    error.getMessage(),
                error
            );
        }

        if (
            response.getStatusCode() !=
            HTTP_METHOD_BY_HTTP_CODE.get(request.getMethod())
        ) {
            String raw = response.getBody();
            Integer idx = raw.lastIndexOf('}');
            if (idx > 0) raw = raw.substring(0, idx + 1);
            Map<String, String> message;
            try {
                message = (Map<String, String>) JSON.deserialize(raw, Map<String, String>.class);
            } catch (Exception e) {
                message = new Map<String,String>{ 'error' => raw };
            }
            throw new XrpWebhookAPIException(
                'Code: ' +
                    response.getStatusCode() +
                    ', Message: ' +
                    message.get('error') +
                    '.'
            );
        }

        return response;
    }

    public class XrpWebhookAPIException extends Exception {
    }
}
