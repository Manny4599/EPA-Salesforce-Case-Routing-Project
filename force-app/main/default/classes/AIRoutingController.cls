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
}