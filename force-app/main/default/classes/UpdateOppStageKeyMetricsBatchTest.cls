@isTest
public class UpdateOppStageKeyMetricsBatchTest {
    static testMethod void testme(){
           
        Account acc = new Account(Name = 'Test Acc');
        insert acc; 
        
        Contact con = new Contact(Lastname = 'test con');
        insert con;
               
        opportunity opp = new opportunity(Name = 'Test opportunity', StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30, amount = 10000,NBM_Completed__c = 'Yes', Architecture_Workshop_Complete__c = 'No', EB_Sponsorship_Complete__c = 'No', EB_Readout_Complete__c = 'No', Tested_Champ__c = true, Value_Discovery_Completed__c=true);
        insert opp;
        
        opportunity opp1 = new opportunity(Name = 'Test opportunity', StageName = '5 - Procurement', CloseDate = system.Today()+30, amount = 10000,NBM_Completed__c = 'Yes', Architecture_Workshop_Complete__c = 'No', EB_Sponsorship_Complete__c = 'No', EB_Readout_Complete__c = 'No', Tested_Champ__c = false, Value_Discovery_Completed__c=false);
        insert opp1;
        
        Technical_Validation_Next_Steps_History__c tech = new Technical_Validation_Next_Steps_History__c();
        tech.Opportunity__c = opp.Id;
        insert tech;
        
        Architecture_Next_Steps__c arch = new Architecture_Next_Steps__c();
        arch.Opportunity__c = opp.Id;
        insert arch;
        
        Architecture_Next_Steps__c arch1 = new Architecture_Next_Steps__c();
        arch.Opportunity__c = opp1.Id;
        insert arch1;
  
        List<Event> evtlst = new List<Event>{new Event(WhatId = opp.Id, WhoId = con.id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.PG_New_Business_Meeting)};
        evtlst.add(new Event(WhatId = opp.Id, WhoId = con.id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.VO_Architecture_Workshop));
        evtlst.add(new Event(WhatId = opp.Id, WhoId = con.id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.VO_EB_Sponsorship));
        evtlst.add(new Event(WhatId = opp.Id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.VO_EB_Final_Signoff));
        evtlst.add(new Event(WhatId = opp.Id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.VO_Champion_Building));
        evtlst.add(new Event(WhatId = opp.Id, StartDateTime=system.today()+1, DurationInMinutes=10, Type=System.Label.PG_Discovery_Call));
        insert evtlst;
        
        Test.StartTest();
        UpdateOpportunityStageKMBatch_Sch testsche = new UpdateOpportunityStageKMBatch_Sch();
        String sch = '0 0 23 * * ?';
        System.schedule('Test status Check', sch, testsche);
        Test.stopTest();
        Architecture_Next_Steps__c cs = [Select Opportunity__c From Architecture_Next_Steps__c Limit 1];
        System.assert(cs.Opportunity__c != NULL);
    }
}