public with sharing class XrpWebhookService {
    public static final String PAYMENT_PROCESSING_ENDPOINT = '';
    public static final String REGISTER_WEBHOOK_SUFFIX = '/api/v1/webhooks';
    public static final String REGISTER_SUBSCRIPTION_SUFFIX = '/api/v1/subscriptions';

    public static RegisterWebhookResponse registerWebhook() {
        RegisterWebhookPayload payload = new RegisterWebhookPayload(URL.getOrgDomainUrl().toExternalForm() + PAYMENT_PROCESSING_ENDPOINT);
        XrpWebhookApi request = new XrpWebhookApi(REGISTER_WEBHOOK_SUFFIX).post().body(payload);
        HttpResponse response = request.callout();

        RegisterWebhookResponse result = (RegisterWebhookResponse) JSON.deserialize(response.getBody(), RegisterWebhookResponse.class); 
        return result;
    }

    public static RegisterSubscriptionResponse registerSubscription(String address) {
        RegisterSubscriptionPayload payload = new RegisterSubscriptionPayload(address);
        XrpWebhookApi request = new XrpWebhookApi(REGISTER_SUBSCRIPTION_SUFFIX).post().body(payload);
        HttpResponse response = request.callout();

        RegisterSubscriptionResponse result = (RegisterSubscriptionResponse) JSON.deserialize(response.getBody(), RegisterSubscriptionResponse.class); 
        return result;
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