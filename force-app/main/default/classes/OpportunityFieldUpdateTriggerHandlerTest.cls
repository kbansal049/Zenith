@isTest
public class OpportunityFieldUpdateTriggerHandlerTest {
    
    
    @testSetup static void setup() {
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        //skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
    }
    
    
    static testMethod void testmethod1(){
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_2_Configuration_in_Progress,Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        insert opp;
        
        opp.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_3_Detailed_validation_in_progress;    
		opp.Technical_Validation_Start_Date__c = Date.today();
        opp.Is_Federal_Opportunity_Sync__c = false;
        update opp; 
        
        Opp.LeadSource = ZScalarConstants.Opp_LeadSource_Sales_Generated;
        opp.type = ZScalarConstants.Opp_Type_Existing_Customer_Add_On;
        opp.StageName = Label.Stage_4_Economic_Buyer_Signoff;
        opp.NextStep = 'Test1';
        opp.Value_Creation_Stage__c = ZScalarConstants.Value_Creation_Stage_Qualified;
        Opp.CloseDate = System.today().adddays(-2);
        opp.Forecast_Category__c = 'Commit';
        update opp;
        
        
        TriggerUtility.isopportunityfieldupdateReset();
        
        
        opp.LeadSource = ZScalarConstants.Opp_LeadSource_Deal_Registration;
        opp.Value_Creation_Stage__c = ZScalarConstants.Value_Creation_Stage_Qualified;
        Opp.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_2_Configuration_in_Progress;
        Opp.CloseDate = System.today().adddays(-1);
        opp.NextStep = 'Test2';
        opp.Forecast_Category__c = 'Best Case';
        update opp;
        
        Test.startTest();
        TriggerUtility.isopportunityfieldupdateReset();
        
        
        Opportunity opp1 = [Select Validation_Stage__c, Technical_Validation_Start_Date__c from Opportunity where id = :opp.id];
        System.debug('---testmethod1--opp--'+opp1);
        
        opp.LeadSource = ZScalarConstants.Opp_LeadSource_Advertisement;
        opp.LDR_Name__c = Userinfo.getUserId();
        Opp.CloseDate = System.today().adddays(1);
        update opp;
        
        TriggerUtility.isopportunityfieldupdateReset();
        
        opp.StageName = Label.Stage_7_Closed_Lost;
        opp.Sub_Stage__c = 'Closed Lost';
        update opp;
       	Test.stopTest(); 
        OpportunityFieldUpdateTriggerHandler.TestCoverageBooster();
        
    }
    
    static testMethod void test1(){
        
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='AMERICAS';
        pateam.Region__c ='AMERICAS';
        pateam.Area__c ='AMERICAS';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=pateam.Id, Role__c='acme', User__c=UserInfo.getUserId());
        insert member;
        
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=pateam.Id);
        insert patch;
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect',Patch__c = patch.Id,CSM_Name_New__c = UserInfo.getUserId());
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@abc.com',Type='Prospect',Patch__c = patch.Id,CSM_Name_New__c = UserInfo.getUserId());
        insert acc1;
        
        opportunity opp10 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        insert opp10;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_Existing_Customer_Add_On,
                                          AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp.Primary_Reseller_Partner__c = acc1.Id;
        
        List<opportunity> lstOpp = new List<opportunity>();
        lstOpp.add(opp);
        
        opportunity opp1 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp1.LeadSource = ZScalarConstants.Opp_LeadSource_Advertisement;
        lstOpp.add(opp1);
        
        opportunity opp3 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_Existing_Customer_Add_On,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp3.LeadSource = ZScalarConstants.Opp_LeadSource_Deal_Registration;
        lstOpp.add(opp3);
        
        opportunity opp4 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp4.LeadSource = ZScalarConstants.Opp_LeadSource_Sales_Generated;
        opp4.Type = ZScalarConstants.Opp_Type_Existing_Customer_Add_On;
        lstOpp.add(opp4);
        
        opportunity opp5 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp5.Sales_Rep_OTB_Override__c = true;
        lstOpp.add(opp5);
        
        opportunity opp6 = opp1.clone(false,false,false,false);
        lstOpp.add(opp6);
        
        opportunity opp7 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp7.StageName = System.Label.Stage_7_Closed_Lost;
        lstOpp.add(opp7);
        
        opportunity opp8 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp8.StageName = System.Label.Stage_5B_Opportunity ;
        opp8.Type = ZScalarConstants.Opp_Type_New_Business;
        lstOpp.add(opp8);
        
        opportunity opp11 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp11.StageName = System.Label.Stage_4_Economic_Buyer_Signoff;
        opp11.Type = ZScalarConstants.Opp_Type_Existing_Customer_Add_On;
        opp11.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_6_Technical_Win;
        lstOpp.add(opp11);
        
        opportunity opp9 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp9.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_1_Establishing_Plan_sucess_criteria;
        lstOpp.add(opp9);
        
        opportunity opp12 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp12.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_1_Establishing_Plan_sucess_criteria;
        lstOpp.add(opp12);
        
        opportunity opp14 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id,StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,Sales_Rep_OTB_Override__c = False,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        
        opp14.Type = ZScalarConstants.Opp_Type_Existing_Customer_Renewal;
        lstOpp.add(opp14);
        
        opportunity opp15 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          Sales_Rep_OTB_Override__c = true,StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        lstOpp.add(opp15);
        
        OpportunityFieldUpdateTriggerHandler.BeforeInsert(lstOpp);
        

        //opp15.Type = ZScalarConstants.Opp_Type_Existing_Customer_Renewal;
        
        Test.startTest();
        opportunity opp13 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',LeadSource = ZScalarConstants.Opp_LeadSource_Deal_Registration,Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp13.Next_Steps__c = 'Test'; 
        opp13.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_6_Technical_Win;
        insert opp13;
        
        TriggerUtility.isopportunityfieldupdateReset();
        opp13.Service_Start_Date__c=System.today();
        opp13.Next_Steps__c = 'Why Test?';   
        opp13.StageName = label.Stage_4_Economic_Buyer_Signoff;
        opp13.Validation_Stage__c = null;
        opp13.Primary_Reseller_Partner__c = acc1.Id;
        update opp13;
        TriggerUtility.isopportunityfieldupdateReset();
        opp13.Type= ZScalarConstants.Opp_Type_Existing_Customer_Add_On;
        update opp13;
        TriggerUtility.isopportunityfieldupdateReset();
        opp13.StageName = label.Stage_2_Qualified_Budgeted;
        opp13.Type= ZScalarConstants.Opp_Type_New_Business;
        update opp13;
        TriggerUtility.isopportunityfieldupdateReset();
        opp13.Sales_Rep_OTB_Override__c = False;
        opp13.Type= ZScalarConstants.Opp_Type_Existing_Customer_Renewal;
        opp13.LeadSource = ZScalarConstants.Opp_LeadSource_Sales_Generated;
        update opp13;
        Test.stopTest();
        
    }

	    static testMethod void testmethod2(){

        TriggerHandler.bypass('AccountTriggerHandler');
		TriggerHandler.bypass('OpportunityTriggerHandler');
        Account acc = new Account(Name = 'Test Account1', TAM_Email__c = 'abc1@abc.com',Type='Prospect');
        insert acc;
        
        opportunity opp1 = new opportunity(Name = 'Test opportunity1', 
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',
                                          Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_3_Detailed_validation_in_progress,
                                          Competitor__c = 'Akamai',Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        insert opp1;   
        opportunity opp6 = opp1.clone(false,false,false,false);
        insert opp6;        
        opp1.StageName = Label.Stage_5_Contracts_Complete;
        opp1.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_0_Not_Started;
        opp1.Competitor__c = Null;    
        update opp1;

		opp1.LDR_Name__c = Userinfo.getUserId();
        opp1.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_8B_Not_Required_Preferred;
        update opp1;
        
        opp1.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_0_Not_Started;
        opp1.StageName = Label.Stage_7_Closed_Lost;
        opp1.Sub_Stage__c = 'Closed Lost';
        update opp1; 
		TriggerHandler.clearBypass('AccountTriggerHandler');
		TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
}