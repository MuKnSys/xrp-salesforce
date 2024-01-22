import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getSettings from "@salesforce/apex/SetupCtrl.getSettings";
import saveSettings from "@salesforce/apex/SetupCtrl.saveSettings";
import subscribeWebhook from "@salesforce/apex/SetupCtrl.subscribeWebhook";
import deleteWebhook from "@salesforce/apex/SetupCtrl.deleteWebhook";

import { labels } from './setupLabels';

export default class Setup extends LightningElement {
    @track settings = {};

    isLoading = true;
    apiKey = null;
    apiSecret = null;
    labels = labels;
    activeSections = [labels.credentials, labels.webhook];

    get registerWebhookDisabled() {
        return !(this.settings.apiKey && this.settings.apiSecret && !this.settings.webhookId);
    }

    get deleteWebhookDisabled() {
        return !(this.settings.apiKey && this.settings.apiSecret && this.settings.webhookId);
    }

    get registerWebhookSuccess() {
        return this.settings.webhookId;
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
        this.apiKey = null;
        this.apiSecret = null;
    }

    showToastNotification(message, title=labels.errorTitle, variant='error') {
        const toast = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });

        this.dispatchEvent(toast);
    }

    handleApiKey(event) {
        this.apiKey = event.target.value;
    }

    handleApiSecret(event) {
        this.apiSecret = event.target.value;
    }

    handleExcpetion(excp) {
        const errorMessage = excp.body?.message || excp.message;
        this.showToastNotification(errorMessage);
    }

    async handleSave() {
        try {
            if(this.apiKey == null || this.apiSecret == null){
                this.showToastNotification(labels.errorMessage);
                return;
            }
    
            this.isLoading = true;
            this.settings = await saveSettings({
                apiKey : this.apiKey,
                apiSecret : this.apiSecret
            });
            this.resetState();
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
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

    async connectedCallback() {
        await this.refreshSettings();
    }
}