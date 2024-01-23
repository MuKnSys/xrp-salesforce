import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord } from "lightning/uiRecordApi";

import disConnectWallet from "@salesforce/apex/ConnectionOrgWalletCtrl.disConnectWallet";

import { labels } from "./disConnectOrgWalletLabels";

export default class ConnectOrgWallet extends LightningElement {
    _recordId;
    isLoading = true;
    isSuccess = false;

    labels = labels;

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        const recordIdChanged = this._recordId != value;
        this._recordId = value;

        if (this._recordId != null && recordIdChanged) {
            this.disConnectOrgWallet();
        }
    }

    async disConnectOrgWallet() {
        try {
            await disConnectWallet({ recordId: this._recordId });
            this.isSuccess = true;
        } catch (excp) {
            this.handleExcpetion(excp);
        } finally {
            await updateRecord({ fields: { Id: this._recordId } });
            this.isLoading = false;
        }
    }

    showToastNotification(
        message,
        title = labels.errorTitle,
        variant = "error"
    ) {
        const toast = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });

        this.dispatchEvent(toast);
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleExcpetion(excp) {
        const errorMessage = excp.body?.message || excp.message;
        this.showToastNotification(errorMessage);
    }
}
