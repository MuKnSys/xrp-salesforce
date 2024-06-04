import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getSettings from "@salesforce/apex/SetupCtrl.getSettings";
import saveSettings from "@salesforce/apex/SetupCtrl.saveSettings";
import subscribeWebhook from "@salesforce/apex/SetupCtrl.subscribeWebhook";
import deleteWebhook from "@salesforce/apex/SetupCtrl.deleteWebhook";
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
        apiKey: null,
        apiSecret: null,
        siteDomain: null,
    };
    labels = labels;

    get activeSections() {
        if (
            !this.settings.apiKey ||
            !this.settings.apiSecret ||
            !this.settings.siteDomain
        ) {
            return [labels.credentials];
        } else if (
            this.settings.apiKey &&
            this.settings.apiSecret &&
            this.settings.siteDomain &&
            !this.settings.webhookId
        ) {
            return [labels.credentials, labels.webhook];
        } else {
            return [labels.credentials, labels.webhook, labels.assetTokens];
        }
    }

    get registerWebhookDisabled() {
        return !(
            this.settings.apiKey &&
            this.settings.apiSecret &&
            this.settings.siteDomain &&
            !this.settings.webhookId
        );
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

    handleSiteDomain(event) {
        this.settingValues.siteDomain = event.target.value;
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

    async connectedCallback() {
        await this.refreshSettings();
    }
}
