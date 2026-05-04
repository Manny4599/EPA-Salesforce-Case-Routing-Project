@isTest
private class RoutingDashboardControllerTest {

    @TestSetup
    static void setup() {
        List<Case> cases = new List<Case>();
        // Create AI routed cases
        for (Integer i = 0; i < 5; i++) {
            cases.add(new Case(
                Subject = 'AI Dashboard Test ' + i,
                Description = 'Test case for dashboard metrics ' + i,
                Origin = 'Web',
                Routing_Method__c = 'AI',
                AI_Confidence__c = 'High',
                AI_Predicted_Queue__c = 'Technical Support'
            ));
        }
        //
        cases.add(new Case(
            Subject = 'PII Dashboard Test',
            Description = 'Test PII case',
            Origin = 'Web',
            Routing_Method__c = 'PII',
            AI_Confidence__c = null,
            AI_Predicted_Queue__c = 'Review Queue'
        ));
        //
        cases.add(new Case(
            Subject = 'Manual Dashboard Test',
            Description = 'Test manual case',
            Origin = 'Web',
            Routing_Method__c = 'Manual',
            AI_Confidence__c = null
        ));
        insert cases;
    }

    @isTest
    static void testGetDashboardData_withData() {
        Test.startTest();
        Map<String, Object> result = RoutingDashboardController.getDashboardData();
        Test.stopTest();
        System.assertNotEquals(null, result, 'Should return dashboard data');
        System.assertEquals(7, result.get('totalCases'), 'Should have 7 total cases');
        System.assertEquals(5, result.get('aiRouted'), 'Should have 5 AI routed');
        System.assertEquals(1, result.get('piiRouted'), 'Should have 1 PII routed');
        System.assertEquals(1, result.get('manualRouted'), 'Should have 1 manual routed');
    }

    @isTest
    static void testGetDashboardData_confidenceCounts() {
        Test.startTest();
        Map<String, Object> result = RoutingDashboardController.getDashboardData();
        Test.stopTest();
        System.assertEquals(5, result.get('highConf'), 'Should have 5 high confidence');
    }

    @isTest
    static void testGetDashboardData_empty() {
        delete [SELECT Id FROM Case];
        Test.startTest();
        Map<String, Object> result = RoutingDashboardController.getDashboardData();
        Test.stopTest();
        System.assertEquals(0, result.get('totalCases'), 'Should have 0 cases');
        System.assertEquals(0, result.get('aiRouted'), 'Should have 0 AI routed');
    }
}
