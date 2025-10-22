public with sharing class AssetTokenService {
    public static final String RIPPLE_NAME = 'XRPL - XRP';
    public static final String RIPPLE_ASSET = 'XRP';
    public static final String RIPPLE_COIN_GECKO_API_NAME = 'ripple';
    public static final String RIPPLE_COIN_GECKO_TOKEN_INFO = 'https://xrpl.org/';
    public static final Decimal RIPPLE_DEFAULT_EXCHANGE_RATE = 0.50;
    public static final String RLUSD_NAME = 'Ripple - RLUSD';
    public static final String RLUSD_ASSET = 'RLUSD';
    public static final String RLUSD_COIN_GECKO_API_NAME = 'rlusd';
    public static final Decimal RLUSD_DEFAULT_EXCHANGE_RATE = 1;
    public static final String USDC_NAME = 'Circle - USDC';
    public static final String USDC_ASSET = 'USDC';
    public static final String USDC_COIN_GECKO_API_NAME = 'usd-coin';
    public static final Decimal USDC_DEFAULT_EXCHANGE_RATE = 1;
    public static final String NETWORK_MAINNET = 'XRP_Mainnet';
    public static final String NETWORK_TESTNET = 'XRP_Testnet';

    // Issuer list structure
    public class IssuerInfo {
        public String name;
        public String address;
        public String network;
        public IssuerInfo(String n, String a, String net) { name=n; address=a; network=net; }
    }

    private static final Map<String, List<IssuerInfo>> ISSUERS_BY_ASSET = new Map<String, List<IssuerInfo>>{
        USDC_ASSET => new List<IssuerInfo>{
            new IssuerInfo('Circle', 'rGm7WCVp9gb4jZHWTEtGUr4dd74z2XuWhE', NETWORK_MAINNET),
            new IssuerInfo('Circle Testnet', 'rHuGNhqTG32mfmAvWA8hUyWRLV3tCSwKQt', NETWORK_TESTNET)
        },
        RLUSD_ASSET => new List<IssuerInfo>{
            new IssuerInfo('RLUSD', 'rMxCKbEDwqr76QuheSUMdEGf4B9xJ8m5De', NETWORK_MAINNET),
            new IssuerInfo('RLUSD Testnet', 'rQhWct2fv4Vc4KRjRgMrxa8xPN9Zx9iLKV', NETWORK_TESTNET)
        }
    };

    public static void initializeAssetTokens() {
        List<Asset_Token__c> assetTokens = getAssetTokens();
        upsert as user assetTokens Asset__c;

        // Map asset code to Asset_Token__c Id for foreign key reference
        Map<String, Id> assetIdByCode = new Map<String, Id>();
        for (Asset_Token__c at : [SELECT Id, Asset__c FROM Asset_Token__c WHERE Asset__c IN :new List<String>{ RIPPLE_ASSET, RLUSD_ASSET, USDC_ASSET }]) {
            assetIdByCode.put(at.Asset__c, at.Id);
        }

        // Initialize TokenContract records for each asset token (placeholder defaults)
        List<TokenContract__c> contracts = new List<TokenContract__c>();
        for (Asset_Token__c tkn : assetTokens) {
            List<IssuerInfo> infos = ISSUERS_BY_ASSET.containsKey(tkn.Asset__c)
                ? ISSUERS_BY_ASSET.get(tkn.Asset__c)
                : new List<IssuerInfo>();

            if (infos.isEmpty()) {
                // create a generic contract without issuer details
                TokenContract__c generic = new TokenContract__c();
                generic.Name = tkn.Name;
                generic.AssetToken__c = assetIdByCode.get(tkn.Asset__c);
                contracts.add(generic);
            } else {
                for (IssuerInfo info : infos) {
                    TokenContract__c tc = new TokenContract__c();
                    String netLabel = info.network == NETWORK_MAINNET ? 'Mainnet' : 'Testnet';
                    tc.Name = info.name + ' - ' + tkn.Asset__c + ' ' + netLabel;
                    tc.AssetToken__c = assetIdByCode.get(tkn.Asset__c);
                    tc.Network__c = info.network;
                    tc.Issuer__c = info.name;
                    tc.Contract_Address__c = info.address;
                    String base = info.network == NETWORK_MAINNET ? 'https://xrpscan.com/account/' : 'https://testnet.xrpscan.com/account/';
                    tc.Contract_Detail__c = base + info.address;
                    contracts.add(tc);
                }
            }
        }
        if (!contracts.isEmpty()) {
            insert as user contracts;
        }
    }

    private static List<Asset_Token__c> getAssetTokens() {
        List<Asset_Token__c> assetTokens = new List<Asset_Token__c>();

        Asset_Token__c rippleAssetToken = new Asset_Token__c();
        rippleAssetToken.Name = RIPPLE_NAME;
        rippleAssetToken.Asset__c = RIPPLE_ASSET;
        rippleAssetToken.Active__c = true;
        rippleAssetToken.CoinGeckoAPIName__c = RIPPLE_COIN_GECKO_API_NAME;
        rippleAssetToken.ConversionRate__c = getRippleExchangeRate(true);
        rippleAssetToken.ConversionRateLastSet__c = Datetime.now();
        rippleAssetToken.TokenInformation__c = RIPPLE_COIN_GECKO_TOKEN_INFO;

        assetTokens.add(rippleAssetToken);

        Asset_Token__c rlusdToken = new Asset_Token__c();
        rlusdToken.Name = RLUSD_NAME;
        rlusdToken.Asset__c = RLUSD_ASSET;
        rlusdToken.Active__c = true;
        rlusdToken.CoinGeckoAPIName__c = RLUSD_COIN_GECKO_API_NAME;
        rlusdToken.ConversionRate__c = RLUSD_DEFAULT_EXCHANGE_RATE;
        rlusdToken.ConversionRateLastSet__c = Datetime.now();

        assetTokens.add(rlusdToken);

        Asset_Token__c usdcToken = new Asset_Token__c();
        usdcToken.Name = USDC_NAME;
        usdcToken.Asset__c = USDC_ASSET;
        usdcToken.Active__c = true;
        usdcToken.CoinGeckoAPIName__c = USDC_COIN_GECKO_API_NAME;
        usdcToken.ConversionRate__c = USDC_DEFAULT_EXCHANGE_RATE;
        usdcToken.ConversionRateLastSet__c = Datetime.now();

        assetTokens.add(usdcToken);
        return assetTokens;
    }

    public static Decimal getRippleExchangeRate(Boolean onErrorDefault) {
        try {
            return new CoinGeckoService()
                .getExchangeRate(
                    RIPPLE_COIN_GECKO_API_NAME,
                    CurrencyService.defaultCurrencyCode
                );
        } catch (Exception error) {
            Decimal result;
            if (onErrorDefault) {
                result = RIPPLE_DEFAULT_EXCHANGE_RATE;
            }
            return result;
        }
    }

    public class AssetTokenException extends Exception {
    }
}
