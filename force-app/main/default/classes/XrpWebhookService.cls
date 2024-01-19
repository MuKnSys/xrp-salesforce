public with sharing class XrpWebhookService {
    public static final String PAYMENT_PROCESSING_ENDPOINT = '/services/apexrest/api/XrpPayments';
    public static final String REGISTER_WEBHOOK_SUFFIX = '/api/v1/webhooks';
    public static final String DELETE_WEBHOOK_SUFFIX = '/api/v1/webhooks/{0}';
    public static final String REGISTER_SUBSCRIPTION_SUFFIX = '/api/v1/subscriptions';
    public static final String DELETE_SUBSCRIPTION_SUFFIX = '/api/v1/subscriptions/{0}';

    public static RegisterWebhookResponse registerWebhook() {
        RegisterWebhookPayload payload = new RegisterWebhookPayload(URL.getOrgDomainUrl().toExternalForm() + PAYMENT_PROCESSING_ENDPOINT);
        XrpWebhookApi request = new XrpWebhookApi(REGISTER_WEBHOOK_SUFFIX).doPost().body(payload);
        HttpResponse response = request.callout();

        return (RegisterWebhookResponse) JSON.deserialize(response.getBody(), RegisterWebhookResponse.class); 
    }

    public static void deleteWebhook(String webhookId) {
        XrpWebhookApi request = new XrpWebhookApi(String.format(DELETE_WEBHOOK_SUFFIX, new List<Object>{webhookId})).doDelete();
        HttpResponse response = request.callout();
    }

    public static RegisterSubscriptionResponse subscribeToAddress(String address) {
        RegisterSubscriptionPayload payload = new RegisterSubscriptionPayload(address);
        XrpWebhookApi request = new XrpWebhookApi(REGISTER_SUBSCRIPTION_SUFFIX).doPost().body(payload);
        HttpResponse response = request.callout();

        return (RegisterSubscriptionResponse) JSON.deserialize(response.getBody(), RegisterSubscriptionResponse.class);
    }

    public static void removeSubscriptionToAddress(String subscriptionId) {
        XrpWebhookApi request = new XrpWebhookApi(String.format(DELETE_SUBSCRIPTION_SUFFIX, new List<Object>{subscriptionId})).doDelete();
        HttpResponse response = request.callout();
    }

    public class RegisterWebhookPayload {
        public String url;

        public RegisterWebhookPayload() {}

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

        public RegisterSubscriptionPayload() {}

        public RegisterSubscriptionPayload(String address) {
            this.address = address;
        }
    }

    public class RegisterSubscriptionResponse {
        public String subscription_id;
        public Boolean success;
    }
}