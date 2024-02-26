public with sharing class CoinGeckoService {
    public static final String GET_EXCHANGE_RATE_ENDPOINT = '/api/v3/simple/price?ids={0}&vs_currencies={1}';

    public Decimal getExchangeRate(String source, String targetCurrency) {
        CoinGeckoAPI request = new CoinGeckoAPI(
                String.format(
                    GET_EXCHANGE_RATE_ENDPOINT,
                    new List<String>{ source, targetCurrency.toLowerCase() }
                )
            )
            .doGET();

        HttpResponse response = request.callout();

        Map<String, Object> exchangeRateResponse = (Map<String, Object>) JSON.deserializeUntyped(
            response.getBody()
        );
        Map<String, Object> exchangeRateRipple = (Map<String, Object>) exchangeRateResponse.get(
            source
        );
        return (Decimal) exchangeRateRipple.get(targetCurrency.toLowerCase());
    }
}
