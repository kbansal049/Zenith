@istest
public class OppNotraBatchApexTest {
    
    @isTest static void opportunityBatch(){
        
        List<Account> acc = new List<Account>{
            new Account(
                Name= 'Test Account', 
                BillingStreet= 'Street No 12', 
                BillingCity= 'Pune', 
                BillingState= 'MH'
            )
                };
                    insert acc;
        Test.startTest();
        Opportunity opp = new Opportunity(Name = 'Test opportunity', 
                                          Primary_Quote_Exception__c  = true, 
                                          AccountId = acc[0].Id, 
                                          StageName = label.Stage_1_Alignment, 
                                          CloseDate = Date.newInstance(system.today().Year(), 8, 1), 
                                          Type = 'Existing Customer (Renewal)',
                                          Renewal_VP_In_my_Number__c = true,
                                          Contract_End_Date_New__c = system.Today() + 1,
                                          CRO_Forecast_Category__c = 'Commit');
        
        
        insert opp;
        
        
        //String CRON_EXP = '0 0 0 15 3 ? *';
        OpportunityNOTRABatch ob =new OpportunityNOTRABatch();
        //String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new OpportunityNOTRABatch());
        Database.executeBatch(ob);
        Test.stopTest();
        
    }
    
    
    @isTest static void opportunityBatch1(){
        
        List<Account> acc = new List<Account>{
            new Account(
                Name= 'Test Account', 
                BillingStreet= 'Street No 12', 
                BillingCity= 'Pune', 
                BillingState= 'MH'
            )
                };
                    insert acc;
        Test.startTest();
        Opportunity opp = new Opportunity(Name = 'Test opportunity', 
                                          Primary_Quote_Exception__c  = true, 
                                          AccountId = acc[0].Id, 
                                          StageName = label.Stage_1_Alignment, 
                                          CloseDate = Date.newInstance(2019, 11, 1), 
                                          Renewal_VP_In_my_Number__c = true,
                                          Type = 'Existing Customer (Renewal)',
                                          Contract_End_Date_New__c = system.Today() + 1,
                                          CRO_Forecast_Category__c = 'Commit');
        
        
        insert opp;
        
        
        //String CRON_EXP = '0 0 0 15 3 ? *';
        OpportunityNOTRABatch ob =new OpportunityNOTRABatch();
        //String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new OpportunityNOTRABatch());
        Database.executeBatch(ob);
        Test.stopTest();
        
    }
    
    
    @isTest static void opportunityBatch2(){
        
        List<Account> acc = new List<Account>{
            new Account(
                Name= 'Test Account', 
                BillingStreet= 'Street No 12', 
                BillingCity= 'Pune', 
                BillingState= 'MH'
            )
                };
                    insert acc;
        Test.startTest();
        Opportunity opp = new Opportunity(Name = 'Test opportunity', 
                                          Primary_Quote_Exception__c  = true, 
                                          AccountId = acc[0].Id, 
                                          StageName = label.Stage_6_Closed_Won, 
                                          CloseDate = Date.newInstance(2021, 2, 1), 
                                          Renewal_VP_In_my_Number__c = true,
                                          Type = 'Existing Customer (Renewal)',
                                          Contract_End_Date_New__c = system.Today() + 1,
                                          CRO_Forecast_Category__c = 'Commit');
        
        
        insert opp;
        
        
        //String CRON_EXP = '0 0 0 15 3 ? *';
        OpportunityNOTRABatch ob =new OpportunityNOTRABatch();
        //String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new OpportunityNOTRABatch());
        Database.executeBatch(ob);
        Test.stopTest();
        
    }
    
    
    @isTest static void opportunityBatch4(){
        
        List<Account> acc = new List<Account>{
            new Account(
                Name= 'Test Account', 
                BillingStreet= 'Street No 12', 
                BillingCity= 'Pune', 
                BillingState= 'MH'
            )
                };
                    insert acc;
        Test.startTest();
        Opportunity opp = new Opportunity(Name = 'Test opportunity', 
                                          Primary_Quote_Exception__c  = true, 
                                          AccountId = acc[0].Id, 
                                          StageName = label.Stage_6_Closed_Won, 
                                          CloseDate = Date.newInstance(2018, 1, 1), 
                                          Renewal_VP_In_my_Number__c = true,
                                          Type = 'Existing Customer (Renewal)',
                                          Contract_End_Date_New__c = system.Today() + 1,
                                          CRO_Forecast_Category__c = 'Commit');
        
        
        insert opp;
        
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        //OpportunityNOTRABatch ob =new OpportunityNOTRABatch();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new OpportunityNOTRABatch());
        //Database.executeBatch(ob);
        Test.stopTest();
        
    }
    @isTest static void opportunityBatch5(){
        
        List<Account> acc = new List<Account>{
            new Account(
                Name= 'Test Account', 
                BillingStreet= 'Street No 12', 
                BillingCity= 'Pune', 
                BillingState= 'MH'
            )
                };
                    insert acc;
        Test.startTest();
        Opportunity opp = new Opportunity(Name = 'Test opportunity', 
                                          Primary_Quote_Exception__c  = true, 
                                          AccountId = acc[0].Id, 
                                          StageName = label.Stage_6_Closed_Won, 
                                          CloseDate = Date.newInstance(2021, 05, 1), 
                                          Renewal_VP_In_my_Number__c = true,
                                          Type = 'Existing Customer (Renewal)',
                                          Contract_End_Date_New__c = system.Today() + 1,
                                          CRO_Forecast_Category__c = 'Commit');
        
        
        insert opp;
        
        
        //String CRON_EXP = '0 0 0 15 3 ? *';
        OpportunityNOTRABatch ob =new OpportunityNOTRABatch();
        //String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new OpportunityNOTRABatch());
        Database.executeBatch(ob);
        Test.stopTest();
        
    }
    
}