import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import disConnectWallet from "@salesforce/apex/ConnectionOrgWalletCtrl.disConnectWallet";

import { labels } from './disConnectOrgWalletLabels';

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
        } catch (error) {
            const erroMessage = error.body ? error.body.message : error.message;
            this.showToast(erroMessage);
        } finally {
            this.isLoading = false;
        }
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, type = TOAST_VARIANT.ERROR, mode = TOAST_MODE.ERROR) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: type,
                mode: mode
            })
        );
    }
}