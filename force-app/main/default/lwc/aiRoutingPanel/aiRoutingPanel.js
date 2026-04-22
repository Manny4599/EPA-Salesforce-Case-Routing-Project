  import { LightningElement, api, wire } from 'lwc';
  import getRoutingData from '@salesforce/apex/AIRoutingController.getRoutingData';
  
  export default class AiRoutingPanel extends LightningElement {
      @api recordId;
      data;
      error;
      showReasoning = false;
  
      @wire(getRoutingData, { caseId: '$recordId' })
      wiredData({ error, data }) {
          if (data) {
              this.data = data;
              this.error = undefined;
          } else if (error) {
              this.error = error;
              this.data = undefined;
          }
      }
  
      get insight() {
          return this.data ? this.data.insight : null;
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
  
      get slaRiskDisplay() {
          const risk = this.data?.slaRisk;
          if (risk === null || risk === undefined) return 'N/A';
          return (risk * 100).toFixed(0) + '%';
      }
  
      get slaBarWidth() {
          const risk = this.data?.slaRisk || 0;
          return 'width: ' + (risk * 100) + '%';
      }

      get slaBarClass() {
          const risk = this.data?.slaRisk || 0;
          if (risk >= 0.7) return 'sla-bar sla-high';
          if (risk >= 0.4) return 'sla-bar sla-medium';
          return 'sla-bar sla-low';
      }
      
      get routingMethodBadge() {
          const method = this.data?.routingMethod;
          if (method === 'AI') return 'slds-badge slds-theme_success';
          if (method === 'PII') return 'slds-badge slds-theme_error';
          return 'slds-badge';
      }
  
      get routingMethod() {
          return this.data?.routingMethod || 'Unknown';
      }
  
      get formattedTimestamp() {
          const ts = this.insight?.Routing_Timestamp__c;
          if (!ts) return '';
          return new Date(ts).toLocaleString('en-GB', {
              day: 'numeric', month: 'short', year: 'numeric',
              hour: '2-digit', minute: '2-digit'
          });
      }
  
      get isManuallyRerouted() {
          return this.data?.manuallyRerouted === true;
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

  