@isTest
public class UpdateOpportunityStageKMBatch_Test{
    @testsetup 
    static void setupdata(){
        Contact con = new Contact(Lastname = 'test con', email='testemail@zscaler.com');
        insert con;

        Opportunity opp = new Opportunity(Name = 'Test opp1', StageName = Label.Stage_1_Alignment, closedate = date.today().adddays(30));
        insert opp;

        List<Event> evtlst = new List<Event>{new Event(WhatId = opp.Id, WhoId = con.id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.PG_New_Business_Meeting)};
        evtlst.add(new Event(WhatId = opp.Id, WhoId = con.id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.VO_Architecture_Workshop));
        evtlst.add(new Event(WhatId = opp.Id, WhoId = con.id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.VO_EB_Sponsorship));
        evtlst.add(new Event(WhatId = opp.Id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.VO_EB_Final_Signoff));
        insert evtlst;
    }
    static testmethod void test1(){
        UpdateOpportunityStageKeyMetricsBatch ins1 = new UpdateOpportunityStageKeyMetricsBatch('Select Id,CloseDate, Type, StageName,NBM_Completed__c, Architecture_Workshop_Complete__c, EB_Sponsorship_Complete__c, EB_Readout_Complete__c from Opportunity');
        ins1.errorlst.add('error');
        test.starttest();
        database.executebatch(ins1, 200);
        test.stoptest();
        for(Opportunity opp: [select Id, NBM_Completed__c, Architecture_Workshop_Complete__c, EB_Sponsorship_Complete__c, EB_Readout_Complete__c from opportunity where Name = 'Test opp1' limit 1]){
            //system.assertEquals(opp.NBM_Completed__c, 'Yes');
            //system.assertEquals(opp.Architecture_Workshop_Complete__c, 'Yes');
            //system.assertEquals(opp.EB_Sponsorship_Complete__c, 'Yes');
            //system.assertEquals(opp.EB_Readout_Complete__c, 'Yes');
        }
    }
}