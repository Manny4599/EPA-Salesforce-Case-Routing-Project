public with sharing class AIRoutingController {
    @AuraEnabled(cacheable=true)
    public static AI_Routing_Insight__c getRoutingInsight(Id caseId) {
        List<AI_Routing_Insight__c> insights = [
            SELECT Id, Predicted_Category__c, Predicted_Queue__c,
                   Confidence__c, Escalation__c, Routing_Timestamp__c,
                   Agentforce_AI_Response__c
            FROM AI_Routing_Insight__c
            WHERE Case__c = :caseId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        return insights.isEmpty() ? null : insights[0];
    }

    @AuraEnabled(cacheable=true)
      public static Map<String, Object> getRoutingData(Id caseId) {
          Map<String, Object> result = new Map<String, Object>();
  
          List<AI_Routing_Insight__c> insights = [
              SELECT Id, Predicted_Category__c, Predicted_Queue__c,
                     Confidence__c, Escalation__c, Routing_Timestamp__c,
                     Agentforce_AI_Response__c
              FROM AI_Routing_Insight__c
              WHERE Case__c = :caseId
              ORDER BY CreatedDate DESC
              LIMIT 1
          ];
  
          Case c = [SELECT Id, SLA_Breach_Risk__c, Routing_Method__c,
                    AI_Confidence__c, Manually_Rerouted__c
                    FROM Case WHERE Id = :caseId];
  
          result.put('insight', insights.isEmpty() ? null : insights[0]);
          result.put('slaRisk', c.SLA_Breach_Risk__c);
          result.put('routingMethod', c.Routing_Method__c);
          result.put('manuallyRerouted', c.Manually_Rerouted__c);
  
          return result;
      }

}
