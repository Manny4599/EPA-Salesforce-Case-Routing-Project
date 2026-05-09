
@isTest
private class CaseRerouteControllerTest {

    @isTest
    static void testRerouteCase_success() {
        Case c = new Case(
            Subject = 'Reroute Test',
            Description = 'Testing the reroute functionality',
            Origin = 'Web',
            AI_Predicted_Queue__c = 'Technical Support'
        );
        insert c;

        List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' LIMIT 1];
        if (queues.isEmpty()) {
            return; 
        }
        String queueId = queues[0].Id;

        Test.startTest();
        CaseRerouteController.rerouteCase(c.Id, queueId, 'Wrong category assigned by AI');
        Test.stopTest();

        Case updated = [SELECT OwnerId, Manually_Rerouted__c FROM Case WHERE Id = :c.Id];
        System.assertEquals(queueId, String.valueOf(updated.OwnerId).substring(0, 15), 'Owner should be updated');
        System.assertEquals(true, updated.Manually_Rerouted__c, 'Should be flagged as manually rerouted');

        List<Task> tasks = [SELECT Subject, Description FROM Task WHERE WhatId = :c.Id];
        System.assertEquals(1, tasks.size(), 'Should create one override task');
        System.assertEquals('Manual Reroute Override', tasks[0].Subject);
        System.assert(tasks[0].Description.contains('Agent override reason:'), 'Task should contain the reason');
    }

    @isTest
    static void testRerouteCase_nullCaseId() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            CaseRerouteController.rerouteCase(null, '00Gfj000008fmfB', 'Test reason');
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
    }

    @isTest
    static void testRerouteCase_blankReason() {
        Case c = new Case(
            Subject = 'Blank Reason Test',
            Description = 'Testing with blank reason',
            Origin = 'Web',
            AI_Predicted_Queue__c = 'Billing'
        );
        insert c;

        List<Group> queues = [SELECT Id FROM Group WHERE Type = 'Queue' LIMIT 1];
        if (queues.isEmpty()) return;

        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            CaseRerouteController.rerouteCase(c.Id, queues[0].Id, '');
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
    }
}
