@isTest
public with sharing class TestDataFactory {
    public class InitializeAssetTokensBodyRipple {
        public Decimal usd;
    }

    public class InitializeAssetTokensBody {
        public InitializeAssetTokensBodyRipple ripple;

        public InitializeAssetTokensBody(Decimal rate) {
            InitializeAssetTokensBodyRipple ripple = new InitializeAssetTokensBodyRipple();
            ripple.usd = rate;

            this.ripple = ripple;
        }
    }
}
