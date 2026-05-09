public class RoutingAccuracyBatch implements Database.Batchable<SObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Routing_Method__c, AI_Confidence__c,
                   Manually_Rerouted__c, SLA_Breach_Risk__c,
                   Category__c, AI_Predicted_Queue__c
            FROM Case
            WHERE CreatedDate = TODAY
            AND Routing_Method__c != null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Case> cases) {
        Integer total = cases.size();
        Integer correct = 0;
        Integer highConf = 0;
        Integer overrides = 0;
        Integer pii = 0;
        Decimal totalSlaRisk = 0;

        for (Case c : cases) {
            if (c.Routing_Method__c == 'AI' && c.Manually_Rerouted__c == false) {
                correct++;
            }
            if (c.AI_Confidence__c == 'High') highConf++;
            if (c.Manually_Rerouted__c == true) overrides++;
            if (c.Routing_Method__c == 'PII') pii++;
            if (c.SLA_Breach_Risk__c != null) {
                totalSlaRisk += c.SLA_Breach_Risk__c;
            }
        }

        Routing_Metric__c metric = new Routing_Metric__c(
            Metric_Date__c = Date.today(),
            Total_Cases__c = total,
            Correctly_Routed__c = correct,
            Accuracy_Percent__c = total > 0 ?
                (Decimal.valueOf(correct) / total * 100).setScale(1) : 0,
            High_Confidence_Count__c = highConf,
            Manual_Override_Count__c = overrides,
            PII_Cases__c = pii,
            Average_SLA_Risk__c = total > 0 ?
                (totalSlaRisk / total).setScale(2) : 0
        );
        insert metric;
    }

    public void finish(Database.BatchableContext bc) {
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new RoutingAccuracyBatch(), 200);
    }
}