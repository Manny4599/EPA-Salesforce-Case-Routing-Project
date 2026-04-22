import { LightningElement, api, wire } from 'lwc';
import getRoutingInsight from
    '@salesforce/apex/AIRoutingController.getRoutingInsight';
export default class aiRoutingPanel extends LightningElement {
    @api recordId;
    insight;
    error;
    showReasoning = false;

    @wire(getRoutingInsight, { caseId: '$recordId' })
    wiredInsight({ error, data }) {
        if (data) {
            this.insight = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.insight = undefined;
        }
    }

    get hasInsight() {
        return !!this.insight;
    }

    get confidenceClass() {
        const c = this.insight?.Confidence__c;
        if (c === 'High') return 'slds-badge slds-theme_success';
        if (c === 'Medium') return 'slds-badge slds-theme_warning';
        return 'slds-badge slds-theme_error';
    }

    get slaRiskPercent() {
        const risk = this.insight?.Escalation__c ? 85 : 40;
        return `width: ${risk}%`;
    }

    get reasoningText() {
        const resp = this.insight?.Agentforce_AI_Response__c;
        if (!resp) return '';
        const idx = resp.indexOf('Reasoning:');
        return idx >= 0 ? resp.substring(idx + 10).trim() : resp;
    }

    get reasoningButtonLabel() {
    return this.showReasoning ? 'Hide reasoning' : 'Show AI reasoning';
}

    toggleReasoning() {
        this.showReasoning = !this.showReasoning;
    }
}