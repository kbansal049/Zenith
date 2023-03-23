@IsTest 
private class CustomerRenewalReminderBatchTest {
    @IsTest static void testBatch() {
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_RHX_Opportunity_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Opp_Trigger', Execute__c = true);

        
        
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        insert trlst;
        Account acc = new Account(Name = 'Test Account',Type='Prospect');
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test contact lastname';
        con.AccountId = acc.Id;
        con.Contacts_that_matter__c = TRUE;
        con.Email = 'testContact@zscaler.com.invalid';
        
        INSERT con;
        
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30);
        opp.LDR_Name__c = UserInfo.getUserId();
        opp.Technical_Validation_Start_Date__c = System.Date.today();
        opp.Validation_Stage__c = '0 - Not Started';
        opp.Created_from_Lead__c = true;
        opp.Opportunity_Account_Manager__c = UserInfo.getUserId();
        opp.Deal_Path__c = 'Bridge to BC';
        insert opp;
        
        opp.StageName = '4 - Impact Validation';
        //opp.StageName = 'System.Label.Stage_6_Closed_Won';
        opp.Contract_End_Date_New__c = System.Date.today() + 270;
        opp.CloseDate = System.Date.today() + 250;
        opp.Renewal_Rep_Forecast_Category__c = 'Commit';
        opp.Type = 'Existing Customer (Renewal)';
        opp.Technical_Validation_Start_Date__c = System.Date.today();
        opp.Validation_Stage__c = '2 - Configuration in Progress';
        UPDATE opp;
        
        Opportunity_Extension__c oppExtRecord = new Opportunity_Extension__c
            (
                Opportunity__c = opp.Id
        	);
        insert oppExtRecord;
        
		List<Opportunity_Extension__c> oppExtList = new List<Opportunity_Extension__c> ();      
        for (Opportunity_Extension__c oppExt : [SELECT Id, Name, Opportunity__c, Renewal_Notice_to_CTMs_10d__c, Renewal_Notice_to_CTMs_100d__c, Renewal_Notice_to_CTMs_270d__c FROM Opportunity_Extension__c]) {
            oppExt.Renewal_Notice_to_CTMs_10d__c = opp.Contract_End_Date_New__c - 10;
            oppExt.Renewal_Notice_to_CTMs_100d__c = opp.Contract_End_Date_New__c - 100;
            oppExt.Renewal_Notice_to_CTMs_270d__c = opp.Contract_End_Date_New__c - 270;
            oppExtList.add(oppExt);
        }
        
        UPDATE oppExtList;
        
        List<Opportunity_Extension__c> oppExtListNew = new List<Opportunity_Extension__c> ();
        for (Opportunity_Extension__c oppExtNew : [SELECT Id, Name, Opportunity__c, Renewal_Notice_to_CTMs_10d__c, Renewal_Notice_to_CTMs_100d__c, Renewal_Notice_to_CTMs_270d__c FROM Opportunity_Extension__c where Opportunity__c=:opp.Id]) {
            oppExtNew.Renewal_Notice_to_CTMs_10d__c = opp.Contract_End_Date_New__c - 10;
            oppExtNew.Renewal_Notice_to_CTMs_100d__c = opp.Contract_End_Date_New__c - 100;
            oppExtNew.Renewal_Notice_to_CTMs_270d__c = opp.Contract_End_Date_New__c - 270;
            oppExtListNew.add(oppExtNew);
        }
        
        UPDATE oppExtListNew;
        
        CustomerRenewalReminderScheduler instance = CustomerRenewalReminderScheduler.getInstance();
        
        System.Database.executeBatch(new CustomerRenewalReminderBatch());
        Test.startTest();
        String jobId = System.schedule('Test customer renewal reminder email','0 0 10 ? * MON-FRI', instance);
        
        Test.stopTest();
        
        
        
    }
}