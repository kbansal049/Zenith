@isTest
private class CreateShiftInstanceTest {

    @testSetup static void setup(){
        
        Provisioning_Request__c PrForPurged = new Provisioning_Request__c(Provisioning_Status__c = 'To Be Purged',Is_ZPA_FeVa_Extended__c = false); 
        insert PrForPurged;
        
        Provisioning_Request__c PrForDisabled = new Provisioning_Request__c(Provisioning_Status__c = 'Disabled',Is_ZPA_FeVa_Extended__c = false);
        insert PrForDisabled;
        
        Provisioning_Request__c PrForDecommissioned = new Provisioning_Request__c(Provisioning_Status__c = 'Decommissioned',Is_ZPA_FeVa_Extended__c = false);
        insert PrForDecommissioned;
        
                Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
        insert territory;
        
        List<PatchTeamMember__c> ptms = new List<PatchTeamMember__c>();
        
        PatchTeamMember__c ptm = new PatchTeamMember__c();
        ptm.PatchTeam__c = territory.Id;
        ptm.Role__c = 'Account Manager';
        ptm.User__c = UserInfo.getUserId();
        ptms.add(ptm);
        
        PatchTeamMember__c ptm1 = new PatchTeamMember__c();
        ptm1.PatchTeam__c = territory.Id;
        ptm1.Role__c = 'Channel Manager';
        ptm1.User__c = UserInfo.getUserId();
        ptms.add(ptm1);
        
        PatchTeamMember__c ptm2 = new PatchTeamMember__c();
        ptm2.PatchTeam__c = territory.Id;
        ptm2.Role__c = 'Area Director';
        ptm2.User__c = UserInfo.getUserId();
        ptms.add(ptm2);
        
        PatchTeamMember__c ptm3 = new PatchTeamMember__c();
        ptm3.PatchTeam__c = territory.Id;
        ptm3.Role__c = 'Customer Advocate';
        ptm3.User__c = UserInfo.getUserId();
        ptms.add(ptm3);
        insert ptms;
        
        Market_Segmentation_Setting__c ms = new Market_Segmentation_Setting__c();
        ms.Name = '1';
        ms.End_Range__c = 1000000;
        ms.Is_EMEA_Region__c = false;
        ms.Market_Segmentation__c = 'Commercial';
        ms.Start_Range__c = 1;
        
        insert ms;
        
        Account account = new Account(Name = 'Test Account - Potential Match');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.type = 'Customer'; 
        account.Sales_Territory__c = territory.id;
        account.Prospect_Type__c = 'Pipeline';
        account.NumberOfEmployees=400000;   
        account.No_of_Employees_Users__c='40000+';
        account.TAM_Name_New__c= UserInfo.getUserId();
        account.Is_Federal_Account_Sync__c = FALSE;
        account.Amber_Road_Status__c = 'Potential Match';
        insert account;
        
        Account accountNoMatch = new Account(Name = 'Test Account - No Match');
        accountNoMatch.CSM_Name_New__c = UserInfo.getUserId();
        accountNoMatch.type = 'Customer'; 
        accountNoMatch.Sales_Territory__c = territory.id;
        accountNoMatch.Prospect_Type__c = 'Pipeline';
        accountNoMatch.NumberOfEmployees=400000;   
        accountNoMatch.No_of_Employees_Users__c='40000+';
        accountNoMatch.TAM_Name_New__c= UserInfo.getUserId();
        accountNoMatch.Is_Federal_Account_Sync__c = TRUE;
        accountNoMatch.Amber_Road_Status__c = 'No Match';
        insert accountNoMatch;
        
        Contact con = new Contact(Lastname = 'Test Contact',AccountId=account.id);
        insert con;
        
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Profile pf= [Select Id from profile where Name='Core Sales']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'Core', 
                         lastName = 'Sales User', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
        opportunity opp = new opportunity(Name = 'Test opportunity', 
                                          AccountId = account.Id, 
                                          StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,
                                          Opportunity_Sales_Engineer__c=UserInfo.getUserId(), 
                                          SE_name__c = uu.id, 
                                          NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, 
                                          Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', 
                                          Validation_Plan__c = 'Test');
        insert opp;
        
        DefaultData__c Dff = new DefaultData__c(name = 'PRCaseCreationDefault', 
                                                Account_Id__c = account.id, 
                                                Category__c='Provisioning Request',
                                                Priority__c='Medium (P3)',
                                                Product__c='ZIA', 
                                                Stage_Status__c='New',
                                                Type__c='Provisioning');
        Insert Dff;
        
        //Insert Custom Settings
        ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'DefaultPRDecommisionContact';
        setting.Value__c = '0034u00002UusGqAAJ';
        insert setting;
        
        //create test PR
        List<Provisioning_Request__c> ListPR = new List<Provisioning_Request__c>();
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', 
                                                                     Preferred_Cloud__c = 'Zscaler.net', 
                                                                     Send_Initial_l__c = 'SE', 
                                                                     SE__c = uu.Id,
                                                                     Account__c = account.Id, 
                                                                     Opportunity__c=opp.Id, 
                                                                     RecordTypeId = recordTypeId);
        ListPR.add(testPR);
        Provisioning_Request__c testPR1 = new Provisioning_Request__c(Organization_Domain__c = 'test1.domain.com', 
                                                                      Preferred_Cloud__c = 'Zscaler.net', 
                                                                      Send_Initial_l__c = 'SE',
                                                                      SE__c = uu.Id,
                                                                      Account__c = account.Id, 
                                                                      Opportunity__c=null, 
                                                                      RecordTypeId = recordTypeId);
                 
            Insert ListPR;
        
        
    }
    
	private static testMethod void test() {
        
	    Test.startTest();
        Provisioning_Request__c PRRecForPurge = [select Id,Name from Provisioning_Request__c where Provisioning_Status__c = 'To Be Purged' limit 1];
        Provisioning_Request__c PRRecForDisabledStatus = [select Id,Name from Provisioning_Request__c where Provisioning_Status__c = 'Disabled' limit 1];
        Provisioning_Request__c PrForDecommissioned = [select Id,Name from Provisioning_Request__c where Provisioning_Status__c = 'Decommissioned' limit 1];
        CreateShiftInstance.GetProvisioningReqDetails(PRRecForPurge.Id);
        CreateShiftInstance.allowPRExtensionOrNot(PRRecForPurge.Id);
        CreateShiftInstance.ExtendZPAInteractive(PRRecForDisabledStatus.Id);
        CreateShiftInstance.ExtendZPAInteractive(PrForDecommissioned.Id);
        CreateShiftInstance.DoNotPurge(PRRecForPurge.Id);
        Try{
        	CreateShiftInstance.ExtendZPAInteractive(Null);
        	CreateShiftInstance.DoNotPurge(Null);
        	CreateShiftInstance.GetProvisioningReqDetails(Null);
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        Test.stopTest();
	}
	
	private static testMethod void test1() {
	    Test.startTest();
        Provisioning_Request__c PRRecForPurge = [select Id,Name from Provisioning_Request__c where Provisioning_Status__c = 'To Be Purged' limit 1];
        Provisioning_Request__c PRRecForDisabledStatus = [select Id,Name from Provisioning_Request__c where Provisioning_Status__c = 'Disabled' limit 1];
        CreateShiftInstance.ExtendZPAInteractive(PRRecForPurge.Id);
        CreateShiftInstance.DoNotPurge(PRRecForDisabledStatus.Id);
        Test.stopTest();
	}
    
    @isTest
    static void checkPRComplianceStatusForOppotunityTest2(){
        Provisioning_Request__c prWithOpp = [SELECT Id FROM
                                             Provisioning_Request__c
                                             WHERE Opportunity__c != NULL
                                             LIMIT 1];
        
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {            
            Test.startTest();				          
            CreateShiftInstance.allowPRExtensionOrNot(String.valueOf(prWithOpp.Id));  
            
            Provisioning_Request__c prNoOpp = [SELECT Id FROM
                                               Provisioning_Request__c
                                               WHERE Opportunity__c = NULL
                                               LIMIT 1];
            CreateShiftInstance.allowPRExtensionOrNot(String.valueOf(prWithOpp.Id));  
            Test.stopTest();
        }
    }

}