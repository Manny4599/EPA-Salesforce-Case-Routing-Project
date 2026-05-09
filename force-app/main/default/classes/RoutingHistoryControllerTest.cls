@isTest
private class RoutingHistoryControllerTest {

    @TestSetup
    static void setup() {
        Case c = new Case(
            Subject = 'History Test Case',
            Description = 'Testing routing history timeline',
            Origin = 'Web'
        );
        insert c;

        insert new AI_Routing_Insight__c(
            Case__c = c.Id,
            Predicted_Category__c = 'Technical Support',
            Predicted_Queue__c = 'Technical Support',
            Confidence__c = 'High',
            Escalation__c = false,
            Routing_Timestamp__c = DateTime.now().addHours(-2)
        );

        insert new Task(
            WhatId = c.Id,
            Subject = 'Manual Reroute Override',
            Description = 'AI predicted: Technical Support. Agent override reason: wrong category',
            Status = 'Completed',
            ActivityDate = Date.today()
        );
    }

    @isTest
    static void testGetRoutingHistory_withEvents() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        List<RoutingHistoryController.RoutingEvent> events =
            RoutingHistoryController.getRoutingHistory(c.Id);
        Test.stopTest();
        System.assertEquals(2, events.size(), 'Should have 2 events: AI routing + manual override');

        System.assertEquals('AI Routing Decision', events[0].title, 'First event should be AI routing');
        System.assertEquals('Manual Override', events[1].title, 'Second event should be manual override');
    }

    @isTest
    static void testGetRoutingHistory_onlyAIRouting() {
        Case c = new Case(
            Subject = 'AI Only Test',
            Description = 'Only AI routing, no override',
            Origin = 'Web'
        );
        insert c;

        insert new AI_Routing_Insight__c(
            Case__c = c.Id,
            Predicted_Category__c = 'Billing',
            Predicted_Queue__c = 'Billing',
            Confidence__c = 'Medium',
            Routing_Timestamp__c = DateTime.now()
        );

        Test.startTest();
        List<RoutingHistoryController.RoutingEvent> events =
            RoutingHistoryController.getRoutingHistory(c.Id);
        Test.stopTest();
        System.assertEquals(1, events.size(), 'Should have 1 event');
        System.assertEquals('AI Routing Decision', events[0].title);
        System.assert(events[0].detail.contains('Billing'), 'Detail should mention Billing');
    }

    @isTest
    static void testGetRoutingHistory_escalationEvent() {
        Case c = new Case(
            Subject = 'Escalation Test',
            Description = 'Testing escalation event type',
            Origin = 'Web'
        );
        insert c;

        insert new AI_Routing_Insight__c(
            Case__c = c.Id,
            Predicted_Category__c = 'Technical Support',
            Predicted_Queue__c = 'Technical Support',
            Confidence__c = 'High',
            Escalation__c = true,
            Routing_Timestamp__c = DateTime.now()
        );

        Test.startTest();
        List<RoutingHistoryController.RoutingEvent> events =
            RoutingHistoryController.getRoutingHistory(c.Id);
        Test.stopTest();
        System.assertEquals(1, events.size());
        System.assertEquals('escalation', events[0].eventType, 'Should be escalation type when escalated');
    }

    @isTest
    static void testGetRoutingHistory_emptyHistory() {
        Case c = new Case(
            Subject = 'Empty History',
            Description = 'No routing events at all',
            Origin = 'Web'
        );
        insert c;
        Test.startTest();
        List<RoutingHistoryController.RoutingEvent> events =
            RoutingHistoryController.getRoutingHistory(c.Id);
        Test.stopTest();
        System.assertEquals(0, events.size(), 'Should have no events');
    }
}
