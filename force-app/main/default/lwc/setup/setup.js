import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getSettings from "@salesforce/apex/SetupCtrl.getSettings";
import saveSettings from "@salesforce/apex/SetupCtrl.saveSettings";

import { labels } from './setupLabels';

export default class Setup extends LightningElement {
    apiKey = null;
    apiSecret = null;
    @track placeholders = {};

    labels = labels;

    async processSettings() {
        const settings = await getSettings();
        if(settings.apiKey) {
            this.placeholders['apiKey'] = 'API Key is setted up';
        }
        if(settings.apiSecret) {
            this.placeholders['apiSecret'] = 'API Secret is setted up';
        }
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

    async handleSave() {
        if(this.apiKey == null || this.apiSecret == null){
            this.showToastNotification(labels.errorMessage);
            return;
        }

        await saveSettings({
            apiKey : this.apiKey,
            apiSecret : this.apiSecret
        });
    }

    async connectedCallback() {
        await this.processSettings();
    }
}