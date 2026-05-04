public with sharing class RoutingHistoryController {
      @AuraEnabled(cacheable=true)
      public static List<RoutingEvent> getRoutingHistory(Id caseId) {
          List<RoutingEvent> events = new List<RoutingEvent>();
  
          for (AI_Routing_Insight__c insight : [
              SELECT Id, Predicted_Category__c, Predicted_Queue__c,
                     Confidence__c, Escalation__c, Routing_Timestamp__c,
                     CreatedDate
              FROM AI_Routing_Insight__c
              WHERE Case__c = :caseId
              ORDER BY CreatedDate ASC
          ]) {
              events.add(new RoutingEvent(
                  'AI Routing Decision',
                  'Routed to ' + insight.Predicted_Queue__c
                      + ' (Confidence: ' + insight.Confidence__c + ')',
                  insight.Routing_Timestamp__c != null
                      ? insight.Routing_Timestamp__c : insight.CreatedDate,
                  insight.Escalation__c ? 'escalation' : 'routing',
                  insight.Confidence__c
              ));
          }
  
          for (Task t : [
              SELECT Id, Subject, Description, CreatedDate
              FROM Task
              WHERE WhatId = :caseId
              AND Subject = 'Manual Reroute Override'
              ORDER BY CreatedDate ASC
          ]) {
              events.add(new RoutingEvent(
                  'Manual Override',
                  t.Description,
                  t.CreatedDate,
                  'override',
                  'N/A'
              ));
          }
  
          events.sort();
          return events;
      }
  
      public class RoutingEvent implements Comparable {
          @AuraEnabled public String title;
          @AuraEnabled public String detail;
          @AuraEnabled public DateTime eventTime;
          @AuraEnabled public String eventType;
          @AuraEnabled public String confidence;
          @AuraEnabled public String formattedTime;
  
          public RoutingEvent(String title, String detail,
                  DateTime eventTime, String eventType, String confidence) {
              this.title = title;
              this.detail = detail;
              this.eventTime = eventTime;
              this.eventType = eventType;
              this.confidence = confidence;
              this.formattedTime = eventTime != null
                  ? eventTime.format('dd MMM yyyy HH:mm') : '';
          }
  
          public Integer compareTo(Object other) {
              RoutingEvent o = (RoutingEvent) other;
              if (this.eventTime == null) return 1;
              if (o.eventTime == null) return -1;
              return this.eventTime > o.eventTime ? 1 : -1;
          }
      }
  }
