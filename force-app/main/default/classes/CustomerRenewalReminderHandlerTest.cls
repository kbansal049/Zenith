/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CustomerRenewalReminderControllerTest
* @description    Test class for CustomerRenewalReminderHandler 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-09-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Chandan Panigrahy
* 2021-10-26      Removed multiple UPDATE statements to avoid 101 SOQL query error
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

@IsTest 
private class CustomerRenewalReminderHandlerTest {
    @IsTest static void testBatch() {
        
        Triggers_Switch__c setting = new Triggers_Switch__c();
        setting.Name = 'OpportunityUpdatesContactHandler';
        setting.Execute__c = TRUE;
        insert setting;
        
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(false);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_RHX_Opportunity_Trigger', Execute__c = false);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = false);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Opp_Trigger', Execute__c = false);

        
        
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        insert trlst;
        
        Test.enableChangeDataCapture();
        
        Account acc = new Account(Name = 'Test Account',Type='Prospect');
        insert acc;
        Test.getEventBus().deliver();
        
        Contact con = new Contact();
        con.LastName = 'Test contact lastname';
        con.AccountId = acc.Id;
        con.Contacts_that_matter__c = TRUE;
        con.Email = 'testContact@zscaler.com.invalid';
        
        INSERT con;
        	
        Test.getEventBus().deliver();
        
        List<Opportunity> oppList = new List<Opportunity>();
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, ContactId = con.id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30,Type = 'Existing Customer (Renewal)');
        opp.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp2 = new opportunity(Name = 'Test opportunity2', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                          Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)');
        opp2.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp3 = new opportunity(Name = 'Test opportunity3', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                          Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)');
        opp3.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp4 = new opportunity(Name = 'Test opportunity4', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                          Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)');
        opp4.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp5 = new opportunity(Name = 'Test opportunity5', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                          Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)');
        opp5.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp6 = new opportunity(Name = 'Test opportunity6', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                          Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)');
        opp6.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp7 = new opportunity(Name = 'Test opportunity7', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                          Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)');
        opp7.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp8 = new opportunity(Name = 'Test opportunity8', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                          Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)');
        opp8.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp9 = new opportunity(Name = 'Test opportunity9', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                          Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)');
        opp9.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp10 = new opportunity(Name = 'Test opportunity10', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                          Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)');
        opp10.LDR_Name__c = UserInfo.getUserId();
        
        oppList.add(opp);
        oppList.add(opp2);
        oppList.add(opp3);
        oppList.add(opp4);
        oppList.add(opp5);
        oppList.add(opp6);
        oppList.add(opp7);
        oppList.add(opp8);
        oppList.add(opp9);
        oppList.add(opp10);
        insert oppList;
        
        Test.getEventBus().deliver();
            
        Test.startTest();
        
        opp.StageName = '4 - Impact Validation';
        opp.Contract_End_Date_New__c = System.Date.today() + 270;
        opp.CloseDate = System.Date.today() + 250;
        opp.Renewal_Rep_Forecast_Category__c = 'Commit';
        opp.Type = 'Existing Customer (Add On)';
        opp.Primary_Competitor__c = 'Palo Alto Networks';
        opp.Secondary_Competitors__c = 'Netskope';
		
        UPDATE opp;
            Test.getEventBus().deliver();
        
        Id FinanceProfileID = [select id from profile where name = 'Finance v2' limit 1 ][0].id;
       	User FinanceUserId = [select id from user where ProfileId=:FinanceProfileID and isActive = true limit 1][0];
        System.RunAs(FinanceUserId){
        opp.StageName = System.Label.Stage_5C_Opportunity;
        opp.Reason_for_5C__c = 'Test';
        //opp.ownerID = FinanceUserId.id;
        opp.AD_Forecast_Category__c = 'Commit';
        opp.RVP_Forecast_Category__c = 'Commit';
        opp.VP_Forecast_Category__c = 'Commit';
        opp.CRO_Forecast_Category__c = 'Commit';
        opp.DM_Forecast_Category__c = 'Commit';
        opp.Forecast_Category__c = 'Commit';
        opp.Requires_signing_customer_documents__c = 'Other';
        UPDATE opp; 
        Test.getEventBus().deliver();
            
        
        opp.StageName = System.Label.Stage_6_Closed_Won;
        opp.Reason_for_5C__c = 'TestStage6';
        opp.Primary_Reseller_Partner__c = acc.id;
        
        UPDATE opp; 
        Test.getEventBus().deliver();
        }
        
        opp.StageName = '7 - Closed Lost';
        opp.Sub_Stage__c = System.label.SubStage_Closed_Delete_Duplicate;
        update opp;
        Test.getEventBus().deliver();
        
        
        
		List<Opportunity_Extension__c> oppExtList = new List<Opportunity_Extension__c> ();      
        for (Opportunity_Extension__c oppExt : [SELECT Id, Name, Opportunity__c, Renewal_Notice_to_CTMs_10d__c, Renewal_Notice_to_CTMs_100d__c, Renewal_Notice_to_CTMs_270d__c FROM Opportunity_Extension__c]) {
            oppExt.Renewal_Notice_to_CTMs_10d__c = opp.Contract_End_Date_New__c - 10;
            oppExt.Renewal_Notice_to_CTMs_100d__c = opp.Contract_End_Date_New__c - 100;
            oppExt.Renewal_Notice_to_CTMs_270d__c = opp.Contract_End_Date_New__c - 270;
            oppExtList.add(oppExt);
        }
        
        UPDATE oppExtList;
        
        Test.getEventBus().deliver();     
        Test.stopTest();
    }
    
    @IsTest static void testAfterUpdate()
    {
        //Core Sales User
        Id CoreSalesProfileID = [select id from profile where name = 'Core Sales' limit 1 ][0].id;
        User CoreSalesUser = [select id from user where ProfileId=:CoreSalesProfileID and isActive = true limit 1][0];
      
        Account acc = new Account(Name = 'Test Account',Type='Prospect',ownerId= CoreSalesUser.id);
        insert acc;
        Test.getEventBus().deliver();
        
        Contact con = new Contact();
        con.LastName = 'Test contact lastname';
        con.AccountId = acc.Id;
        con.Contacts_that_matter__c = TRUE;
        con.Email = 'testContact@zscaler.com.invalid';
        INSERT con; 
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = ZScalarConstants.Opp_STAGE_1, CloseDate = system.Today()+30,Type = 'Existing Customer (Renewal)');
        opp.LDR_Name__c = UserInfo.getUserId();
        
        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Domain__c ='Test';
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Opportunity2__c = opp.id;
        insert quote;
        Map<id,opportunity> oldMap = new Map<id,opportunity>();
        
        Test.startTest();
        oldMap.put(opp.id, opp);
        opp.StageName = ZScalarConstants.Opp_STAGE_2;
        opp.Reason_for_5C__c = 'Test';
        opp.AD_Forecast_Category__c = 'Commit';
        opp.RVP_Forecast_Category__c = 'Commit';
        opp.VP_Forecast_Category__c = 'Commit';
        opp.CRO_Forecast_Category__c = 'Commit';
        opp.DM_Forecast_Category__c = 'Commit';
        opp.Forecast_Category__c = 'Commit';
        opp.Primary_Competitor__c = 'Palo Alto Networks';
        opp.Secondary_Competitors__c = 'Palo Alto Networks';
        opp.Validation_Plan__c = 'Test';
        opp.Product_Type__c = 'Web';
        opp.Proposed_Number_of_Users__c = 600;
        opp.Business_Champion_Contact__c = con.id;
        opp.Economic_Buyer_Contact__c = con.id;
        opp.Value_Pyramid__c='test';
        
        System.RunAs(CoreSalesUser){
        	update opp;
        }
        Map<id,opportunity> newMap = new Map<id,opportunity>();
        newMap.put(opp.id, opp);
        OpportunityUpdatesContactHandler.afterUpdate(newMap,oldMap);
        Test.stopTest();
         
    }
    
   
}