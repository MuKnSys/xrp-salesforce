public with sharing class XrpWebhookService {
    public static final String PAYMENT_PROCESSING_ENDPOINT = '/services/apexrest/api/xrp/payments';
    public static final String REGISTER_WEBHOOK_SUFFIX = '/api/v1/webhooks';
    public static final String DELETE_WEBHOOK_SUFFIX = '/api/v1/webhooks/{0}';
    public static final String REGISTER_SUBSCRIPTION_SUFFIX = '/api/v1/subscriptions';
    public static final String DELETE_SUBSCRIPTION_SUFFIX = '/api/v1/subscriptions/{0}';

    public static RegisterWebhookResponse registerWebhook() {
        XRPForSalesforceSettings__c settings = XRPForSalesforceSettingsService.settings;
        if (settings.XRPSiteDomainUrl__c == null) {
            throw new XrpWebhookApi.XrpWebhookAPIException(
                System.Label.api_app_not_correctly_configred
            );
        }

        RegisterWebhookPayload payload = new RegisterWebhookPayload(
            settings.XRPSiteDomainUrl__c + PAYMENT_PROCESSING_ENDPOINT
        );

        XrpWebhookApi request = new XrpWebhookApi(
                REGISTER_WEBHOOK_SUFFIX,
                false
            )
            .doPost()
            .body(payload);
        HttpResponse response = request.callout();

        return (RegisterWebhookResponse) JSON.deserialize(
            response.getBody(),
            RegisterWebhookResponse.class
        );
    }

    public static void deleteWebhook(String webhookId) {
        XrpWebhookApi request = new XrpWebhookApi(
                String.format(
                    DELETE_WEBHOOK_SUFFIX,
                    new List<Object>{ webhookId }
                ),
                false
            )
            .doDelete();
        HttpResponse response = request.callout();
    }

    public static RegisterSubscriptionResponse subscribeToAddress(
        String address
    ) {
        RegisterSubscriptionPayload payload = new RegisterSubscriptionPayload(
            address
        );
        XrpWebhookApi request = new XrpWebhookApi(
                REGISTER_SUBSCRIPTION_SUFFIX,
                true
            )
            .doPost()
            .body(payload);
        HttpResponse response = request.callout();

        return (RegisterSubscriptionResponse) JSON.deserialize(
            response.getBody(),
            RegisterSubscriptionResponse.class
        );
    }

    public static void removeSubscriptionToAddress(String subscriptionId) {
        XrpWebhookApi request = new XrpWebhookApi(
                String.format(
                    DELETE_SUBSCRIPTION_SUFFIX,
                    new List<Object>{ subscriptionId }
                ),
                true
            )
            .doDelete();
        HttpResponse response = request.callout();
    }

    public class RegisterWebhookPayload {
        public String url;

        public RegisterWebhookPayload() {
        }

        public RegisterWebhookPayload(String url) {
            this.url = url;
        }
    }

    public class RegisterWebhookResponse {
        public String webhook_id;
        public Boolean success;
    }

    public class RegisterSubscriptionPayload {
        public String address;

        public RegisterSubscriptionPayload() {
        }

        public RegisterSubscriptionPayload(String address) {
            this.address = address;
        }
    }

    public class RegisterSubscriptionResponse {
        public String subscription_id;
        public Boolean success;
    }
}
