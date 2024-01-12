import { LightningElement } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { labels } from './setupLabels';

export default class Setup extends LightningElement {
    apiKey = null;
    apiSecret = null;

    labels = labels;

    handleApiKey(event) {
        this.apiKey = event.target.value;
    }

    handleApiSecret(event) {
        this.apiSecret = event.target.value;
    }

    handleSave() {
        if(this.apiKey == null || this.apiSecret == null){
            this.showToastNotification(labels.errorMessage);
            return;
        }

        // Call apex
    }

    showToastNotification(message, title=labels.errorTitle, variant='error') {
        const toast = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });

        this.dispatchEvent(toast);
    }
}