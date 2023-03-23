@isTest
public class OpportunityNOTRAHandlerTest {
    
    
    @testSetup  static void setupdata(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Opp_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Quote_Reprice_Logic', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        
    }
    

    @isTest static void doOpportunityNOTRAHandlerTest(){
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        
        opportunity opp = new opportunity( Name = 'Test opportunity', 
                                          Primary_Quote_Exception__c  = true, 
                                          AccountId = acc.Id, 
                                          StageName = label.Stage_1_Alignment, 
                                          CloseDate = Date.newInstance(system.today().Year(), 2, 1),
                                          Renewal_VP_In_my_Number__c = true,
                                          Type = 'Existing Customer (Renewal)',
                                          Contract_End_Date_New__c = system.Today() + 1,
                                          CRO_Forecast_Category__c = 'Commit');
        insert opp;
        
        
        Test.startTest();
        //Opportunity Opp = [select Id,Name,AccountId,CloseDate  from Opportunity limit 1];
        opp.CloseDate = Date.newInstance(system.today().Year(), 3, 1);
        
        update opp;
        
        opp.CloseDate = Date.newInstance(system.today().Year(), 5, 1);
        
        update opp;
        
        opp.CloseDate = Date.newInstance(system.today().Year(), 8, 1);
        
        update opp;
        
        opp.CloseDate = Date.newInstance(system.today().Year(), 11, 1);
        
        update opp;
        
        
        opp.CloseDate = Date.newInstance(system.today().addYears(-1).Year(), 3, 1);
        
        update opp;
        
        opp.CloseDate = Date.newInstance(system.today().addYears(-1).Year(), 5, 1);
        
        update opp;
        
        opp.CloseDate = Date.newInstance(system.today().addYears(-1).Year(), 8, 1);
        
        update opp;
        
        opp.CloseDate = Date.newInstance(system.today().addYears(-1).Year(), 11, 1);
        
        update opp;

        Test.stopTest();
    }
}