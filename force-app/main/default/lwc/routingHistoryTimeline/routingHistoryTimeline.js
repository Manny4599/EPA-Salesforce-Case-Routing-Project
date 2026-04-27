  import { LightningElement, api, wire } from 'lwc';
  import getRoutingHistory from '@salesforce/apex/RoutingHistoryController.getRoutingHistory';
  
  export default class RoutingHistoryTimeline extends LightningElement {
      @api recordId;
      routingEvents;
      error;
  
      @wire(getRoutingHistory, { caseId: '$recordId' })
      wiredHistory({ error, data }) {
          if (data) {
              this.routingEvents = data;
              this.error = undefined;
          } else if (error) {
              this.error = error;
              this.routingEvents = undefined;
          }
      }
  
      get hasEvents() {
          return this.routingEvents && this.routingEvents.length > 0;
      }
  
      get events() {
          if (!this.routingEvents) return [];
          return this.routingEvents.map(e => ({
              ...e,
              timelineClass: 'timeline-item timeline-' + e.eventType,
              key: e.formattedTime + e.title
          }));
      }
  }
