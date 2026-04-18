public with sharing class CaseRerouteController {
    @AuraEnabled
    public static void rerouteCase(Id caseId, String newQueueId, String reason) {
        Case c = [SELECT Id, AI_Predicted_Queue__c FROM Case WHERE Id = :caseId];
        c.OwnerId = newQueueId;
        c.Manually_Rerouted__c = true;
        update c;

        insert new Task(
            WhatId = caseId,
            Subject = 'Manual Reroute Override',
            Description = 'AI predicted: ' + c.AI_Predicted_Queue__c + '. Agent override reason: ' + reason,
            Status = 'Completed',
            ActivityDate = Date.today()
        );
    }
}