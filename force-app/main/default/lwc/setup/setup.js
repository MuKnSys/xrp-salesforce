import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getSettings from "@salesforce/apex/SetupCtrl.getSettings";
import saveSettings from "@salesforce/apex/SetupCtrl.saveSettings";

import { labels } from './setupLabels';

export default class Setup extends LightningElement {
    @track settings = {};

    isLoading = true;
    apiKey = null;
    apiSecret = null;
    labels = labels;

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

    async connectedCallback() {
        try {
            this.settings = await getSettings();
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            this.isLoading = false;
        }
    }
}