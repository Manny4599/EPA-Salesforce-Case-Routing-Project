@isTest
private class AIRoutingControllerTest {

    @TestSetup
    static void setup() {
        Case c = new Case(
            Subject = 'Test Case',
            Description = 'Test description for routing panel',
            Origin = 'Web',
            SLA_Breach_Risk__c = 0.75,
            Routing_Method__c = 'AI',
            AI_Confidence__c = 'High'
        );
        insert c;

        AI_Routing_Insight__c insight = new AI_Routing_Insight__c(
            Case__c = c.Id,
            Predicted_Category__c = 'Technical Support',
            Predicted_Queue__c = 'Technical Support',
            Confidence__c = 'High',
            Escalation__c = false,
            Agentforce_AI_Response__c = 'Category: Technical Support\nReasoning: Login issue detected',
            Routing_Timestamp__c = DateTime.now()
        );
        insert insight;
    }

    @isTest
    static void testGetRoutingInsight_withData() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        AI_Routing_Insight__c result = AIRoutingController.getRoutingInsight(c.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Should return an insight record');
        System.assertEquals('Technical Support', result.Predicted_Category__c);
        System.assertEquals('High', result.Confidence__c);
    }

    @isTest
    static void testGetRoutingInsight_noData() {
        Case c = new Case(
            Subject = 'Empty Case',
            Description = 'No insight record exists',
            Origin = 'Web'
        );
        insert c;
        Test.startTest();
        AI_Routing_Insight__c result = AIRoutingController.getRoutingInsight(c.Id);
        Test.stopTest();
        System.assertEquals(null, result, 'Should return null when no insight exists');
    }

    @isTest
    static void testGetRoutingData_withData() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Map<String, Object> result = AIRoutingController.getRoutingData(c.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Should return a map');
        System.assertNotEquals(null, result.get('insight'), 'Should contain insight');
        System.assertNotEquals(null, result.get('slaRisk'), 'Should contain SLA risk');
        System.assertEquals('AI', result.get('routingMethod'), 'Routing method should be AI');
    }

    @isTest
    static void testGetRoutingData_noInsight() {
        Case c = new Case(
            Subject = 'No Insight Case',
            Description = 'Case with no insight record',
            Origin = 'Web',
            Routing_Method__c = 'Manual'
        );
        insert c;
        Test.startTest();
        Map<String, Object> result = AIRoutingController.getRoutingData(c.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Should return a map even without insight');
        System.assertEquals(null, result.get('insight'), 'Insight should be null');
        System.assertEquals('Manual', result.get('routingMethod'));
    }

    @isTest
    static void testGetRoutingInsight_bulkData() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        List<AI_Routing_Insight__c> insights = new List<AI_Routing_Insight__c>();
        for (Integer i = 0; i < 200; i++) {
            insights.add(new AI_Routing_Insight__c(
                Case__c = c.Id,
                Predicted_Category__c = 'Technical Support',
                Predicted_Queue__c = 'Technical Support',
                Confidence__c = 'High',
                Routing_Timestamp__c = DateTime.now().addHours(-i)
            ));
        }
        insert insights;
        Test.startTest();
        AI_Routing_Insight__c result = AIRoutingController.getRoutingInsight(c.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Should return the most recent insight');
    }
}
