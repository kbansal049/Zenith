@isTest
private class CampaignMemberTriggerHandlerTest {
    
    private static Patch__c patch { get; set; }    
    
    @TestSetup
    private static void createTestData(){
        
        List<ZscalerSetting__c> ZscalerSettinglist= new List<ZscalerSetting__c>();
        ZscalerSetting__c Zsc1= new ZscalerSetting__c(Name='CampaignExceptions1',Value__c='ABC');
        ZscalerSettinglist.add(Zsc1);
        ZscalerSetting__c Zsc2= new ZscalerSetting__c(Name='CampaignExceptions2',Value__c='DEF');
        ZscalerSettinglist.add(Zsc2);
        Insert ZscalerSettinglist;
        
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
        
        patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = territory.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead',
                             First_Lead_Date__c = date.today(), Company = 'Test Lead Company', 
                             Status = 'Open', Lead_Stage__c = 'Lead', 
                             MKTO71_Lead_Score__c = 0,Person_MQL_Date__c=System.now(),
                             Qualification_Notes__c = 'QualificationNotes',
                             MQL_Date__c=System.today(), Patch__c = patch.Id );
        insert lead;
        
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', 
                                  LastName = 'test con', First_Lead_Date__c = date.today(), 
                                  Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0,
                                  Contacts_That_Matter__c  = true,Person_MQL_Date__c=System.now(),
                             	  Qualification_Notes__c = 'QualificationNotes',
                                  MQL_Date__c=System.today(),Patch__c = patch.Id);
        insert con;
        
        List<Campaign> CmpgnList= new List<Campaign>();
        Campaign cm = new Campaign();
        cm.name='ZPA Interactive';
        cm.Department__c = '5000-Corporate Marketing';
        cm.Geo__c = 'GLOBAL';
        cm.StartDate = Date.today();
        cm.EndDate = Date.today()+30;
        cm.Fiscal_Year__c = 'All Time';
        cm.Type = 'Default';
        cm.Campaign_Type__c = 'Networking Event';
        cm.Activity_Details__c = 'Local Association/Chapter Meetings';
        cm.Recommended_Outreach_Sequence__c ='Testing';
        cm.FCRM__FCR_Repeat_Responses_Allowed__c = true;
        
        CmpgnList.add(cm);
        
        /* Campaign cm2 = new Campaign();
cm2.name='ZPA Interactive';
cm2.Department__c = '5000-Corporate Marketing';
cm2.Geo__c = 'GLOBAL';
cm2.StartDate = Date.today();
cm2.EndDate = Date.today()+30;
cm2.Fiscal_Year__c = 'All Time';
cm2.Type = 'Default';
cm2.Campaign_Type__c = 'Networking Event';
cm2.Activity_Details__c = 'Local Association/Chapter Meetings';

CmpgnList.add(cm2); */
        
        insert CmpgnList;
        
    }
    
    @isTest 
    static void campaignMemberInsertTest(){   
        
        Lead leadRecord = [SELECT Id FROM Lead WHERE Company = 'Test Lead Company'];
        Contact contactRecord = [SELECT Id FROM Contact WHERE LastName = 'test con'];
        Campaign campaignRecord = [SELECT Id FROM Campaign WHERE Name='ZPA Interactive'];
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        CampaignMember CM2= new CampaignMember(Campaignid=campaignRecord.id,Leadid=leadRecord.id,Status='Sent', FCRM__FCR_SQR_Won__c = true,
                                               CFCR_Discovery_Meeting_Completed__c= true, CFCR_Discovery_Meeting_Scheduled__c= true, 
                                               FCRM__FCR_QR__c= true, SAL_Sales_Connected_Lead__c= true, FCRM__FCR_SAR__c= true,
                                               CFCR_Sales_Qualified_Lead__c= true, FCRM__FCR_SQR__c= true);
        CmpgnMemList.add(CM2);
        CampaignMember CM1= new CampaignMember(Campaignid=campaignRecord.id,Contactid=contactRecord.id,Status='Sent');
        CmpgnMemList.add(CM1); 
        
        Test.startTest();
        System.debug('CmpgnMemList : ' + CmpgnMemList);
        insert CmpgnMemList;
        Test.stopTest();  
        system.assertEquals(2, CmpgnMemList.size());
    }
    
    @isTest 
    static void campaignMemberUpdateTest(){   
        
        Lead leadRecord = [SELECT Id FROM Lead WHERE Company = 'Test Lead Company' LIMIT 1];
        Contact contactRecord = [SELECT Id FROM Contact WHERE LastName = 'test con' LIMIT 1];
        Campaign campaignRecord = [SELECT Id FROM Campaign WHERE Name='ZPA Interactive' LIMIT 1];
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        CampaignMember CM2= new CampaignMember(Campaignid=campaignRecord.id,Leadid=leadRecord.id,Status='Sent');
        CmpgnMemList.add(CM2);
        CampaignMember CM1= new CampaignMember(Campaignid=campaignRecord.id,Contactid=contactRecord.id,Status='Sent');
        CmpgnMemList.add(CM1); 
        insert CmpgnMemList;
        
        CampaignMember campaignMemberContactRecord = [SELECT Id,Status FROM CampaignMember WHERE Contactid=:contactRecord.id LIMIT 1];
        CampaignMember campaignMemberLeadRecord = [SELECT Id,Status FROM CampaignMember WHERE Leadid=:leadRecord.id LIMIT 1];
        
        Test.startTest();
        campaignMemberContactRecord.Status = 'Accepted';        
        update campaignMemberContactRecord;
        campaignMemberLeadRecord.Status = 'Accepted';        
        update campaignMemberLeadRecord;
        Test.stopTest();
		
        CampaignMemberTriggerHelper.cmTriggerSkip = False;
        campaignMemberContactRecord.Status = 'Responded';        
		update campaignMemberContactRecord;  
        campaignMemberLeadRecord.Status = 'Responded';        
		update campaignMemberLeadRecord;
    }
    
    @isTest 
    static void deleteCampaignMemberTest(){
        
        Lead leadRecord = [SELECT Id FROM Lead WHERE Company = 'Test Lead Company' LIMIT 1];
        Contact contactRecord = [SELECT Id FROM Contact WHERE LastName = 'test con' LIMIT 1];
        Campaign campaignRecord = [SELECT Id FROM Campaign WHERE Name='ZPA Interactive' LIMIT 1];
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        CampaignMember CM2= new CampaignMember(Campaignid=campaignRecord.id,Leadid=leadRecord.id,Status='Sent');
        CmpgnMemList.add(CM2);
        CampaignMember CM1= new CampaignMember(Campaignid=campaignRecord.id,Contactid=contactRecord.id,Status='Sent');
        CmpgnMemList.add(CM1); 
        insert CmpgnMemList;
        
        CampaignMember campaignMemberRecord = [SELECT Id,Contactid FROM CampaignMember WHERE Leadid =:leadRecord.id LIMIT 1];
        
        Test.startTest();
        delete campaignMemberRecord;
        Test.stopTest();        
    }

    @isTest 
    static void testBeforeInsert(){   
        
        Lead leadRecord = [SELECT Id FROM Lead WHERE Company = 'Test Lead Company' LIMIT 1];
        Contact contactRecord = [SELECT Id FROM Contact WHERE LastName = 'test con' LIMIT 1];
        Campaign campaignRecord = [SELECT Id FROM Campaign WHERE Name='ZPA Interactive' LIMIT 1];
        campaignRecord.FCRM__FCR_Repeat_Responses_Allowed__c = true;
        campaignRecord.Type = 'Contact Request-Live Chat';
        update campaignRecord;
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        CampaignMember CM2= new CampaignMember(Campaignid=campaignRecord.id,Leadid=leadRecord.id,Status='Meeting Scheduled');
        CmpgnMemList.add(CM2);
        CampaignMember CM1= new CampaignMember(Campaignid=campaignRecord.id,Contactid=contactRecord.id,Status='Responded');
        CmpgnMemList.add(CM1);
        insert CmpgnMemList;

        CM1.Status='Demo Requested';
        CM1.FCRM__FCR_SQR_Won__c = true;
        CM1.CFCR_Discovery_Meeting_Completed__c = true;
        CM1.CFCR_Discovery_Meeting_Scheduled__c = true;
        CM1.FCRM__FCR_QR__c = true;
        CM1.SAL_Sales_Connected_Lead__c = true;
        CM1.FCRM__FCR_SAR__c = true;
        CM1.CFCR_Sales_Qualified_Lead__c = true;
        CM1.FCRM__FCR_SQR__c = true;

        update CM1;
        
        CampaignMember campaignMemberContactRecord = [SELECT Id,Status FROM CampaignMember WHERE Contactid=:contactRecord.id LIMIT 1];
        CampaignMember campaignMemberLeadRecord = [SELECT Id,Status FROM CampaignMember WHERE Leadid=:leadRecord.id LIMIT 1];
        
        Test.startTest();
        campaignMemberContactRecord.Status = 'Accepted';        
        update campaignMemberContactRecord;
        campaignMemberLeadRecord.Status = 'Accepted';        
        update campaignMemberLeadRecord;
        Test.stopTest();
		
        CampaignMemberTriggerHelper.cmTriggerSkip = False;
        campaignMemberContactRecord.Status = 'Responded';        
		update campaignMemberContactRecord;  
        campaignMemberLeadRecord.Status = 'Responded';        
		update campaignMemberLeadRecord;
    }
    
}