import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getSettings from "@salesforce/apex/SetupCtrl.getSettings";
import saveSettings from "@salesforce/apex/SetupCtrl.saveSettings";
import subscribeWebhook from "@salesforce/apex/SetupCtrl.subscribeWebhook";
import deleteWebhook from "@salesforce/apex/SetupCtrl.deleteWebhook";
import clearSettings from "@salesforce/apex/SetupCtrl.clearSettings";
import initializeAssetTokens from "@salesforce/apex/SetupCtrl.initializeAssetTokens";

import { labels } from "./setupLabels";

const TOAST_VARIANT = {
    error : "error",
    success: "success"
};

export default class Setup extends LightningElement {
    @track settings = {};

    isLoading = true;
    settingValues = {
        baseUrl: null,
        apiKey: null,
        apiSecret: null,
        siteDomain: null,
    };
    labels = labels;

    isEditingApiKey = false;
    isEditingApiSecret = false;
    isEditingSiteDomain = false;
    isEditingBaseUrl = false;

    // return array with all accordion section names so they start open
    get allSections() {
        return [
            this.labels.webhookServer,
            this.labels.credentials,
            this.labels.site_domain,
            this.labels.webhook,
            this.labels.assetTokens
        ];
    }

    // No activeSections logic; accordion defaults to all sections open

    get registerWebhookDisabled() {
        return !(
            this.settings.apiKey &&
            this.settings.apiSecret &&
            this.settings.siteDomain &&
            !this.settings.webhookId
        );
    }

    get saveCredentialsDisabled() {
        return this.settings.webhookId;
    }

    get deleteWebhookDisabled() {
        return !(
            this.settings.apiKey &&
            this.settings.apiSecret &&
            this.settings.siteDomain &&
            this.settings.webhookId
        );
    }

    get registerWebhookSuccess() {
        return this.settings.webhookId;
    }

    get initializeAssetTokenLabel() {
        return this.settings.assetTokensInitialized ? labels.reinitializeAssetTokens : labels.initializeAssetTokens;
    }

    get apiKeyDisabled() {
        return !!this.settings.apiKey && !this.isEditingApiKey;
    }
    get apiKeyConnected() {
        return !!this.settings.apiKey && !this.isEditingApiKey;
    }
    get apiSecretDisabled() {
        return !!this.settings.apiSecret && !this.isEditingApiSecret;
    }
    get apiSecretConnected() {
        return !!this.settings.apiSecret && !this.isEditingApiSecret;
    }
    get siteDomainDisabled() {
        return !!this.settings.siteDomain && !this.isEditingSiteDomain;
    }
    get siteDomainConnected() {
        return !!this.settings.siteDomain && !this.isEditingSiteDomain;
    }

    get showApiKeyActions() {
        return this.isEditingApiKey || !this.apiKeyConnected;
    }
    get showApiSecretActions() {
        return this.isEditingApiSecret || !this.apiSecretConnected;
    }
    get showSiteDomainActions() {
        return this.isEditingSiteDomain || !this.siteDomainConnected;
    }

    get apiCredentialsConnected() {
        return this.apiKeyConnected && this.apiSecretConnected;
    }

    get apiCredsAllSet() {
        return this.apiCredentialsConnected && !this.isEditingApiKey && !this.isEditingApiSecret;
    }

    async refreshSettings() {
        try {
            this.settings = await getSettings();
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }

    resetState() {
        this.settingValues = {
            baseUrl: null,
            apiKey: null,
            apiSecret: null,
            siteDomain: null,
        };
    }

    showToastNotification(
        message,
        title = labels.errorTitle,
        variant = TOAST_VARIANT.error
    ) {
        const toast = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });

        this.dispatchEvent(toast);
    }

    handleApiKey(event) {
        this.settingValues.apiKey = event.target.value;
    }

    handleApiSecret(event) {
        this.settingValues.apiSecret = event.target.value;
    }

    handleExcpetion(excp) {
        const errorMessage = excp.body?.message || excp.message;
        this.showToastNotification(errorMessage);
    }

    handleEditApiKey() {
        this.isEditingApiKey = true;
    }
    handleEditApiSecret() {
        this.isEditingApiSecret = true;
    }
    handleEditSiteDomain() {
        this.isEditingSiteDomain = true;
    }

    async handleInitializeAssetTokens() {
        try {
            this.isLoading = true;
            this.settings = await initializeAssetTokens();
            this.showToastNotification(labels.successAssetTokenMessage, labels.successTitle, TOAST_VARIANT.success);
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }

    async handleSave() {
        try {
            this.isLoading = true;
            this.settings = await saveSettings({
                settingValues: this.settingValues,
            });
            this.resetState();
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }

    async handleSaveApiKey() {
        try {
            this.isLoading = true;
            this.settingValues.apiKey = this.settingValues.apiKey || this.settings.apiKey;
            this.settings = await saveSettings({ settingValues: { apiKey: this.settingValues.apiKey } });
            this.showToastNotification(this.labels.successMessage, this.labels.successTitle, TOAST_VARIANT.success);
            this.isEditingApiKey = false;
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }
    async handleSaveApiSecret() {
        try {
            this.isLoading = true;
            this.settingValues.apiSecret = this.settingValues.apiSecret || this.settings.apiSecret;
            this.settings = await saveSettings({ settingValues: { apiSecret: this.settingValues.apiSecret } });
            this.showToastNotification(this.labels.successMessage, this.labels.successTitle, TOAST_VARIANT.success);
            this.isEditingApiSecret = false;
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }
    async handleSaveSiteDomain() {
        try {
            this.isLoading = true;
            this.settingValues.siteDomain = this.settingValues.siteDomain || this.settings.siteDomain;

            const validation = this.validateUrl(this.settingValues.siteDomain);
            if (!validation.valid) {
                throw new Error(validation.error);
            }
            this.settings = await saveSettings({ settingValues: { siteDomain: this.settingValues.siteDomain } });
            this.showToastNotification(this.labels.successMessage, this.labels.successTitle, TOAST_VARIANT.success);
            this.isEditingSiteDomain = false;
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }

    handleSiteDomain(event) {
        this.settingValues.siteDomain = event.target.value;
    }

    // Validate URL format using browser URL parser
    validateUrl(url) {
        if (!url) {
            return { valid: true };
        }

        try {
            const parsedUrl = new URL(url);

            // Check for protocol and host presence
            if (!parsedUrl.protocol || !parsedUrl.hostname) {
                return { valid: false, error: this.labels.site_domain + ' format is invalid' };
            }

            return { valid: true };
        } catch (e) {
            return { valid: false, error: this.labels.site_domain + ' format is invalid' };
        }
    }

    async handleRegisterWebhook() {
        try {
            this.isLoading = true;

            await subscribeWebhook();
            await this.refreshSettings();
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }

    async handleDeleteWebhook() {
        try {
            this.isLoading = true;

            await deleteWebhook();
            await this.refreshSettings();
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }

    async handleRefresh() {
        try {
            this.isLoading = true;
            await clearSettings();
            await this.refreshSettings();
            this.resetState();
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }

    async connectedCallback() {
        await this.refreshSettings();
    }

    // Base URL connected helpers
    get baseUrlConnected() {
        return !!this.settings.baseUrl && !this.isEditingBaseUrl;
    }
    get showBaseUrlActions() {
        return this.isEditingBaseUrl || !this.baseUrlConnected;
    }

    handleBaseUrl(event) {
        this.settingValues.baseUrl = event.target.value;
    }

    handleEditBaseUrl() {
        this.isEditingBaseUrl = true;
    }

    async handleSaveBaseUrl() {
        try {
            this.isLoading = true;
            let clean = this.settingValues.baseUrl || this.settings.baseUrl;
            clean = clean.endsWith('/') ? clean.slice(0, -1) : clean;
            const validation = this.validateUrl(clean);
            if (!validation.valid) {
                throw new Error(validation.error);
            }
            this.settings = await saveSettings({ settingValues: { baseUrl: clean } });
            this.showToastNotification(this.labels.successMessage, this.labels.successTitle, TOAST_VARIANT.success);
            this.isEditingBaseUrl = false;
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }

    get dynamicBaseUrl() {
        return this.settings.baseUrl ? this.settings.baseUrl : 'https://xrpwebhooks.web3enabler.net';
    }

    get displayBaseUrl() {
        return this.settings.baseUrl ? this.settings.baseUrl.replace(/^https?:\/\//, '') : 'xrpwebhooks.web3enabler.net';
    }

    get showSaveBaseUrl() {
        return !this.baseUrlConnected || this.isEditingBaseUrl;
    }
}
