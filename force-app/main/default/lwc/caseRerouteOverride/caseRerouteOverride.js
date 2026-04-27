import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rerouteCase from '@salesforce/apex/CaseRerouteController.rerouteCase';

export default class CaseRerouteOverride extends LightningElement {
    @api recordId;
    selectedQueue = '';
    reason = '';
    isLoading = false;

    get queueOptions() {
        return [
            { label: '-- Select a queue --', value: '' },
            { label: 'Technical Support', value: '00Gfj000008Kg1h' },
            { label: 'Billing', value: '00Gfj000008Kg4v' },
            { label: 'General Enquiries', value: '00Gfj000008fkft' },
            { label: 'Complaints', value: '00Gfj000008fmYj' },
            { label: 'Exception Queue', value: '00Gfj000008fmfB' }
        ];
    }

    get isSubmitDisabled() {
        return !this.selectedQueue || !this.reason || this.isLoading;
    }

    handleQueueChange(event) {
        this.selectedQueue = event.detail.value;
    }

    handleReasonChange(event) {
        this.reason = event.detail.value;
    }
    
    get reasonCharCount() {
        const len = this.reason ? this.reason.length : 0;
        return len + ' / 500 characters';
    }

    get reasonCharClass() {
        const len = this.reason ? this.reason.length : 0;
        return len > 400 ? 'char-count char-warning' : 'char-count';
    }


    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async handleSubmit() {
        this.isLoading = true;
        try {
            await rerouteCase({
                caseId: this.recordId,
                newQueueId: this.selectedQueue,
                reason: this.reason
            });
            this.dispatchEvent(new ShowToastEvent({
                title: 'Case rerouted',
                message: 'Case has been reassigned and flagged as manually rerouted.',
                variant: 'success'
            }));
            this.dispatchEvent(new CloseActionScreenEvent());
            setTimeout(() => { eval("$A.get('e.force:refreshView').fire()"); }, 500);
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body ? error.body.message : 'An error occurred',
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }
}