public class UpdateOpportunityStageKMBatch_Sch implements System.Schedulable{
    public void execute(SchedulableContext sc){
        
        string q = 'Select Id,CloseDate, Type, StageName,NBM_Completed__c, Architecture_Workshop_Complete__c, EB_Sponsorship_Complete__c, EB_Readout_Complete__c from Opportunity where stagename in (\'1 - Discovery & Qualification\', \'2 - Architecture & Alignment\', \'3 - Sponsorship\', \'4 - Impact Validation\') and closeDate = NEXT_N_DAYS:180 and Type !=\'Existing Customer (Renewal)\'';
        database.executebatch(new UpdateOpportunityStageKeyMetricsBatch(q), 200);
        
    }

}