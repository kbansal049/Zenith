@isTest
private class AmberRoadValidationTest {
    
    @TestSetup
    private static void createTestData(){
        
        Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        AmberRoadValidation.PRAccOppScreenStatusWrapper obj1 = new AmberRoadValidation.PRAccOppScreenStatusWrapper();
        AmberRoadValidation.ScreeningStatusWrapper obj2 = new AmberRoadValidation.ScreeningStatusWrapper();
        AmberRoadValidation.PRScreeningWrapper obj3 = new AmberRoadValidation.PRScreeningWrapper();
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
        TriggerHandler.bypass('OpportunityTriggerHandler');
        opportunity opp = new opportunity(Name = 'Test opportunity', 
                                          AccountId = account.Id, 
                                          StageName = '1 - Discovery & Qualification', 
                                          CloseDate = system.Today()+30);
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
        opportunity opp1 = new opportunity(Name = 'Test opportunity', 
                                          AccountId = accountNoMatch.Id, 
                                          StageName = '1 - Discovery & Qualification', 
                                          CloseDate = system.Today()+30);
        insert opp1;
        Provisioning_Request__c testPR1 = new Provisioning_Request__c(Organization_Domain__c = 'test1.domain.com', 
                                                                      Preferred_Cloud__c = 'Zscaler.net', 
                                                                      Send_Initial_l__c = 'SE',
                                                                      SE__c = uu.Id,
                                                                      Account__c = accountNoMatch.Id,
                                                                      Opportunity__c=opp1.Id, 
                                                                      RecordTypeId = recordTypeId);
        ListPR.add(testPR1);
        TriggerHandler.bypass('OpportunityTriggerHandler');
        opportunity opp2 = new opportunity(Name = 'Test opportunity', 
                                          AccountId = accountNoMatch.Id, 
                                          StageName = '1 - Discovery & Qualification', 
                                          CloseDate = system.Today()+30,
                                          Primary_Reseller_Partner__c = account.Id);
       
        insert opp2;
        Provisioning_Request__c testPR2 = new Provisioning_Request__c(Organization_Domain__c = 'test2.domain.com', 
                                                                      Preferred_Cloud__c = 'Zscaler.net', 
                                                                      Send_Initial_l__c = 'SE', 
                                                                      SE__c = uu.Id,
                                                                      Account__c = accountNoMatch.Id, 
                                                                      Opportunity__c=opp2.Id, 
                                                                      RecordTypeId = recordTypeId);
        ListPR.add(testPR2);
        opportunity opp3 = new opportunity(Name = 'Test opportunity', 
                                          AccountId = accountNoMatch.Id, 
                                          StageName = '1 - Discovery & Qualification', 
                                          CloseDate = system.Today()+30,
                                          Primary_Reseller_Partner__c = account.Id);
        insert opp3;
        Opportunity_Partner__c OppPartner3 = new Opportunity_Partner__c(Is_Primary__c = false,
                                                                       Opportunity__c = opp3.Id,
                                                                       Partner_Type__c = 'Reseller',
                                                                       Account__c = account.Id);
        Provisioning_Request__c testPR3 = new Provisioning_Request__c(Organization_Domain__c = 'test1.domain.com', 
                                                                      Preferred_Cloud__c = 'Zscaler.net', 
                                                                      Send_Initial_l__c = 'SE',
                                                                      SE__c = uu.Id,
                                                                      Account__c = accountNoMatch.Id,
                                                                      Opportunity__c=opp3.Id, 
                                                                      RecordTypeId = recordTypeId);
        ListPR.add(testPR3);
        
        Insert ListPR;
        
    }
    
    @isTest 
    static void checkOppPartnerAccComplianceScreeningStatusTest(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        Account accountRecordNoMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                        FROM Account 
                                        WHERE Name = 'Test Account - No Match' LIMIT 1];
        Map<Id,Opportunity> oppRecordMap = new Map<Id,Opportunity>([SELECT Id
                                                                    FROM Opportunity 
                                                                    WHERE Name = 'Test opportunity' LIMIT 1]);
        Id oppId;
        for(Opportunity oppRecord : oppRecordMap.values()){
            oppId = oppRecord.Id;
            break;
        }
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,
                                                                       Opportunity__c = oppId,
                                                                       Partner_Type__c = 'Reseller',
                                                                       Account__c = accountRecordPotentialMatch.Id);
        insert OppPartner;
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            Test.startTest();
            AmberRoadValidation.checkOppPartnerAccComplianceScreeningStatus(oppRecordMap);
            Test.stopTest();
        }
        
        Opportunity oppRecord = [SELECT Id,AccountId,Primary_Reseller_Partner__c
                                 FROM Opportunity 
                                 WHERE Name = 'Test opportunity' LIMIT 1];
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = accountRecordNoMatch.Id; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;
        System.runAs(me) {   
            AmberRoadValidation.checkPRComplianceStatusForOppotunity(oppRecord.Id);            
        }        
    }
    
    @isTest 
    static void checkPRComplianceStatusForOppotunityTest1(){
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        Account accountRecordNoMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                        FROM Account 
                                        WHERE Name = 'Test Account - No Match' LIMIT 1];
        Opportunity oppRecord = [SELECT Id,AccountId,Primary_Reseller_Partner__c
                                 FROM Opportunity 
                                 WHERE Name = 'Test opportunity' LIMIT 1];
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            
            Test.startTest();
            
            AmberRoadValidation.checkPRComplianceStatusForOppotunity(oppRecord.Id);
            
            Test.stopTest();
        }
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = accountRecordPotentialMatch.Id; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;   
        System.runAs(me) {
            AmberRoadValidation.checkPRComplianceStatusForOppotunity(oppRecord.Id);
        }
        
    }
    
    @isTest
    static void checkPRComplianceStatusForOppotunityTest2(){
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        Account accountRecordNoMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                        FROM Account 
                                        WHERE Name = 'Test Account - No Match' LIMIT 1];
        Opportunity oppRecord = [SELECT Id,AccountId,Primary_Reseller_Partner__c
                                 FROM Opportunity 
                                 WHERE Name = 'Test opportunity' LIMIT 1];          
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,
                                                                       Opportunity__c = oppRecord.Id,
                                                                       Partner_Type__c = 'Reseller',
                                                                       Account__c = accountRecordPotentialMatch.Id);
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = null; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;  
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {            
            Test.startTest();				          
            	AmberRoadValidation.checkPRComplianceStatusForOppotunity(oppRecord.Id);            
            Test.stopTest();
        }
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = accountRecordPotentialMatch.Id; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;   
        System.runAs(me) {
            AmberRoadValidation.checkPRComplianceStatusForOppotunity(oppRecord.Id);
        }
        
    }
    
    @isTest
    static void checkPRComplianceStatusForOppotunityTest3(){
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        Account accountRecordNoMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                        FROM Account 
                                        WHERE Name = 'Test Account - No Match' LIMIT 1];
        Opportunity oppRecord = [SELECT Id,AccountId,Primary_Reseller_Partner__c
                                 FROM Opportunity 
                                 WHERE Name = 'Test opportunity' LIMIT 1];
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            
            Test.startTest();
            
            AmberRoadValidation.checkPRComplianceStatusForOppotunity(oppRecord.Id);
            
            Test.stopTest();
        }
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = accountRecordPotentialMatch.Id; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;   
        System.runAs(me) {
            AmberRoadValidation.checkPRComplianceStatusForOppotunity(oppRecord.Id);
        }
        
    }
    
    @isTest 
    static void checkPRComplianceStatusForAccountTest(){
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            Test.startTest();
            AmberRoadValidation.checkPRComplianceStatusForAccount(accountRecordPotentialMatch.Id);
            Test.stopTest();
        }
    }
    
    @isTest 
    static void checkPRComplianceStatusOnUpdateTest1(){
        List<Provisioning_Request__c> newPRRec = [SELECT ID,
                                                  Account__c,
                                                  Account__r.Name,
                                                  Account__r.Amber_Road_Status__c,                                        
                                                  Account__r.Is_Federal_Account_Sync__c,
                                                  Opportunity__c,
                                                  Opportunity__r.Name, 
                                                  Opportunity__r.AccountId,
                                                  Opportunity__r.Account.Name,
                                                  Opportunity__r.Account.Amber_Road_Status__c,
                                                  Opportunity__r.Account.Is_Federal_Account_Sync__c,                                       
                                                  Opportunity__r.Primary_Reseller_Partner__c,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Name,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,                                        
                                                  Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c
                                                  FROM Provisioning_Request__c
                                                  where 
                                                  Organization_Domain__c = 'test.domain.com' limit 1];
        
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            Test.startTest();
            AmberRoadValidation.checkPRComplianceStatusOnUpdate(newPRRec);
            Test.stopTest();
        }
    }
    
    @isTest 
    static void checkPRComplianceStatusOnUpdateTest2(){
        
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        Account accountRecordNoMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                        FROM Account 
                                        WHERE Name = 'Test Account - No Match' LIMIT 1];
        Opportunity oppRecord = [SELECT Id,AccountId,Primary_Reseller_Partner__c
                                 FROM Opportunity 
                                 WHERE Name = 'Test opportunity' LIMIT 1];          
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,
                                                                       Opportunity__c = oppRecord.Id,
                                                                       Partner_Type__c = 'Reseller',
                                                                       Account__c = accountRecordPotentialMatch.Id);
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = accountRecordPotentialMatch.Id; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;  
        
        List<Provisioning_Request__c> newPRRec = [SELECT ID,
                                                  Account__c,
                                                  Account__r.Name,
                                                  Account__r.Amber_Road_Status__c,                                        
                                                  Account__r.Is_Federal_Account_Sync__c,
                                                  Opportunity__c,
                                                  Opportunity__r.Name, 
                                                  Opportunity__r.AccountId,
                                                  Opportunity__r.Account.Name,
                                                  Opportunity__r.Account.Amber_Road_Status__c,
                                                  Opportunity__r.Account.Is_Federal_Account_Sync__c,                                       
                                                  Opportunity__r.Primary_Reseller_Partner__c,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Name,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,                                        
                                                  Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c
                                                  FROM Provisioning_Request__c
                                                  where 
                                                  Organization_Domain__c = 'test1.domain.com' limit 1];
        
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            Test.startTest();
            AmberRoadValidation.checkPRComplianceStatusOnUpdate(newPRRec);
            Test.stopTest();
        }
    }
    
    @isTest 
    static void checkPRComplianceStatusOnUpdateTest3(){
        
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        Account accountRecordNoMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                        FROM Account 
                                        WHERE Name = 'Test Account - No Match' LIMIT 1];
        Opportunity oppRecord = [SELECT Id,AccountId,Primary_Reseller_Partner__c
                                 FROM Opportunity 
                                 WHERE Name = 'Test opportunity' LIMIT 1];          
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,
                                                                       Opportunity__c = oppRecord.Id,
                                                                       Partner_Type__c = 'Reseller',
                                                                       Account__c = accountRecordPotentialMatch.Id);
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = accountRecordNoMatch.Id; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;  
        
        List<Provisioning_Request__c> newPRRec = [SELECT ID,
                                                  Account__c,
                                                  Account__r.Name,
                                                  Account__r.Amber_Road_Status__c,                                        
                                                  Account__r.Is_Federal_Account_Sync__c,
                                                  Opportunity__c,
                                                  Opportunity__r.Name, 
                                                  Opportunity__r.AccountId,
                                                  Opportunity__r.Account.Name,
                                                  Opportunity__r.Account.Amber_Road_Status__c,
                                                  Opportunity__r.Account.Is_Federal_Account_Sync__c,                                       
                                                  Opportunity__r.Primary_Reseller_Partner__c,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Name,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,                                        
                                                  Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c
                                                  FROM Provisioning_Request__c
                                                  where 
                                                  Organization_Domain__c = 'test1.domain.com' limit 1];
        
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            Test.startTest();
            AmberRoadValidation.checkPRComplianceStatusOnUpdate(newPRRec);
            Test.stopTest();
        }
    }
    
    @isTest 
    static void checkPRComplianceStatusOnInsertTest1(){
        List<Provisioning_Request__c> newPRRec = [SELECT ID,
                                                  Account__c,
                                                  Account__r.Name,
                                                  Account__r.Amber_Road_Status__c,                                        
                                                  Account__r.Is_Federal_Account_Sync__c,
                                                  Opportunity__c,
                                                  Opportunity__r.Name, 
                                                  Opportunity__r.AccountId,
                                                  Opportunity__r.Account.Name,
                                                  Opportunity__r.Account.Amber_Road_Status__c,
                                                  Opportunity__r.Account.Is_Federal_Account_Sync__c,                                       
                                                  Opportunity__r.Primary_Reseller_Partner__c,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Name,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,                                        
                                                  Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c
                                                  FROM Provisioning_Request__c
                                                  where 
                                                  Organization_Domain__c = 'test.domain.com' limit 1];
        
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            Test.startTest();
            AmberRoadValidation.checkPRComplianceStatusOnInsert(newPRRec);
            Test.stopTest();
        }
    }
    
    @isTest
    static void checkPRComplianceStatusOnInsertTest2(){
        
        Opportunity oppRecord = [SELECT Id,AccountId,Primary_Reseller_Partner__c
                                 FROM Opportunity 
                                 WHERE Name = 'Test opportunity' LIMIT 1];
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        Account accountRecordNoMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                        FROM Account 
                                        WHERE Name = 'Test Account - No Match' LIMIT 1];

        List<Provisioning_Request__c> newPRRec = [SELECT ID,
                                                  Account__c,
                                                  Account__r.Name,
                                                  Account__r.Amber_Road_Status__c,                                        
                                                  Account__r.Is_Federal_Account_Sync__c,
                                                  Opportunity__c,
                                                  Opportunity__r.Name, 
                                                  Opportunity__r.AccountId,
                                                  Opportunity__r.Account.Name,
                                                  Opportunity__r.Account.Amber_Road_Status__c,
                                                  Opportunity__r.Account.Is_Federal_Account_Sync__c,                                       
                                                  Opportunity__r.Primary_Reseller_Partner__c,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Name,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,                                        
                                                  Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c
                                                  FROM Provisioning_Request__c
                                                  where 
                                                  Organization_Domain__c = 'test.domain.com' limit 1];        

        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            Test.startTest();
            AmberRoadValidation.checkPRComplianceStatusOnInsert(newPRRec);
            Test.stopTest();
        }
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = accountRecordPotentialMatch.Id; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;   
        
        newPRRec[0].Account__c = accountRecordNoMatch.Id;
        update newPRRec;
        System.runAs(me) {
            AmberRoadValidation.checkPRComplianceStatusOnInsert(newPRRec);
        }
        
    }
    
    @isTest
    static void checkPRComplianceStatusOnInsertTest3(){
        
        Opportunity oppRecord = [SELECT Id,AccountId,Primary_Reseller_Partner__c
                                 FROM Opportunity 
                                 WHERE Name = 'Test opportunity' LIMIT 1];
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        Account accountRecordNoMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                        FROM Account 
                                        WHERE Name = 'Test Account - No Match' LIMIT 1];

        List<Provisioning_Request__c> newPRRec = [SELECT ID,
                                                  Account__c,
                                                  Account__r.Name,
                                                  Account__r.Amber_Road_Status__c,                                        
                                                  Account__r.Is_Federal_Account_Sync__c,
                                                  Opportunity__c,
                                                  Opportunity__r.Name, 
                                                  Opportunity__r.AccountId,
                                                  Opportunity__r.Account.Name,
                                                  Opportunity__r.Account.Amber_Road_Status__c,
                                                  Opportunity__r.Account.Is_Federal_Account_Sync__c,                                       
                                                  Opportunity__r.Primary_Reseller_Partner__c,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Name,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,                                        
                                                  Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c
                                                  FROM Provisioning_Request__c
                                                  where 
                                                  Organization_Domain__c = 'test.domain.com' limit 1];        

        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            Test.startTest();
            AmberRoadValidation.checkPRComplianceStatusOnInsert(newPRRec);
            Test.stopTest();
        }
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = accountRecordPotentialMatch.Id; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;   
        
        newPRRec[0].Account__c = accountRecordNoMatch.Id;
        update newPRRec;
        System.runAs(me) {
            AmberRoadValidation.checkPRComplianceStatusOnInsert(newPRRec);
        }
        
    }
    
    @isTest
    static void checkPRComplianceStatusOnInsertTest4(){
        
        Opportunity oppRecord = [SELECT Id,AccountId,Primary_Reseller_Partner__c
                                 FROM Opportunity 
                                 WHERE Name = 'Test opportunity' LIMIT 1];
        Account accountRecordPotentialMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                               FROM Account 
                                               WHERE Name = 'Test Account - Potential Match' LIMIT 1];
        Account accountRecordNoMatch = [SELECT Id,Amber_Road_Status__c,Is_Federal_Account_Sync__c
                                        FROM Account 
                                        WHERE Name = 'Test Account - No Match' LIMIT 1];
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,
                                                                       Opportunity__c = oppRecord.Id,
                                                                       Partner_Type__c = 'Reseller',
                                                                       Account__c = accountRecordPotentialMatch.Id);

        List<Provisioning_Request__c> newPRRec = [SELECT ID,
                                                  Account__c,
                                                  Account__r.Name,
                                                  Account__r.Amber_Road_Status__c,                                        
                                                  Account__r.Is_Federal_Account_Sync__c,
                                                  Opportunity__c,
                                                  Opportunity__r.Name, 
                                                  Opportunity__r.AccountId,
                                                  Opportunity__r.Account.Name,
                                                  Opportunity__r.Account.Amber_Road_Status__c,
                                                  Opportunity__r.Account.Is_Federal_Account_Sync__c,                                       
                                                  Opportunity__r.Primary_Reseller_Partner__c,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Name,
                                                  Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,                                        
                                                  Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c
                                                  FROM Provisioning_Request__c
                                                  where 
                                                  Organization_Domain__c = 'test.domain.com' limit 1];        
		
        User me = [SELECT Id, Name FROM User WHERE lastName = 'Sales User' LIMIT 1];
        System.runAs(me) {
            Test.startTest();
            AmberRoadValidation.checkPRComplianceStatusOnInsert(newPRRec);
            Test.stopTest();
        }
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        oppRecord.Primary_Reseller_Partner__c = accountRecordNoMatch.Id; 
        oppRecord.AccountId = accountRecordNoMatch.Id;            
        update oppRecord;   
        newPRRec[0].Account__c = accountRecordNoMatch.Id;
        update newPRRec;
        newPRRec[0].Account__c = accountRecordNoMatch.Id;
        update newPRRec;
        System.runAs(me) {
            AmberRoadValidation.checkPRComplianceStatusOnInsert(newPRRec);
        }
        
    }
    
}