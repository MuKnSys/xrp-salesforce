public with sharing class CoinGeckoAPI {
    private final static String COIN_GECKO_EXCHANGE_RATE_ENDPOINT = 'https://api.coingecko.com';
    private final static Map<String, Integer> HTTP_METHOD_BY_HTTP_CODE = new Map<String, Integer>{
        'GET' => 200
    };
    private HttpRequest request;

    public CoinGeckoAPI(String suffix) {
        request = new HttpRequest();
        request.setEndpoint(COIN_GECKO_EXCHANGE_RATE_ENDPOINT + suffix);
    }

    public CoinGeckoAPI doGET() {
        request.setMethod('GET');
        return this;
    }

    public HttpResponse callout() {
        HttpResponse response = null;

        try {
            response = new Http().send(request);
        } catch (Exception error) {
            throw new CoinGeckoAPIException(
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
            throw new CoinGeckoAPIException(
                'Code: ' + response.getStatusCode()
            );
        }

        return response;
    }

    public class CoinGeckoAPIException extends Exception {
    }
}
