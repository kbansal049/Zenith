@isTest
private class CampaignTriggerHandlerTest {


    @isTest
    static void testUpdate() {
        List<ZscalerSetting__c> ZscalerSettinglist= new List<ZscalerSetting__c>();
        ZscalerSetting__c Zsc1= new ZscalerSetting__c(Name='CampaignExceptions1',Value__c='ABC');
        ZscalerSettinglist.add(Zsc1);
        ZscalerSetting__c Zsc2= new ZscalerSetting__c(Name='CampaignExceptions2',Value__c='DEF');
        ZscalerSettinglist.add(Zsc2);
        Insert ZscalerSettinglist;
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0,Person_MQL_Date__c=System.now(),MQL_Date__c=System.today());
        lead.Qualification_Notes__c = 'Test';
        insert lead;
        
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true,Person_MQL_Date__c=System.now(),MQL_Date__c=System.today());
        con.Qualification_Notes__c  = 'Test';
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
        cm.Post_Event_to_Web__c = true;
        cm.Led_By__c = 'Zscaler';
        
        Campaign cm4 = new Campaign();
        cm4.name='ZPA Interactive 2';
        cm4.Department__c = '5000-Corporate Marketing';
        cm4.Geo__c = 'GLOBAL';
        cm4.StartDate = Date.today();
        cm4.EndDate = Date.today()+30;
        cm4.Fiscal_Year__c = 'All Time';
        cm4.Type = 'Default';
        cm4.Campaign_Type__c = 'Networking Event';
        cm4.Activity_Details__c = 'Local Association/Chapter Meetings';
        cm4.Post_Event_to_Web__c = true;
        cm4.Led_By__c = 'Channel Partner';
        
        Campaign cm3 = new Campaign();
        cm3.name='ZPA Interactive 3';
        cm3.Department__c = '5000-Corporate Marketing';
        cm3.Geo__c = 'GLOBAL';
        cm3.StartDate = Date.today();
        cm3.EndDate = Date.today()+30;
        cm3.Fiscal_Year__c = 'All Time';
        cm3.Type = 'Default';
        cm3.Campaign_Type__c = 'Networking Event';
        cm3.Activity_Details__c = 'Local Association/Chapter Meetings';
        cm3.Post_Event_to_Web__c = true;
        cm3.Led_By__c = 'Tech Partner';
        
        CmpgnList.add(cm);
        CmpgnList.add(cm4);
        CmpgnList.add(cm3);
        Test.startTest();
        insert CmpgnList;
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        CampaignMember CM2= new CampaignMember(Campaignid=cm.id,Leadid=lead.id,Status='Sent');
        CmpgnMemList.add(CM2);
        CampaignMember CM1= new CampaignMember(Campaignid=cm.id,Contactid=con.id,Status='Sent');
        CmpgnMemList.add(CM1);
        insert CmpgnMemList;
        
        Campaign newCampaign = [Select Id, Recommended_Outreach_Sequence__c from Campaign where id = :cm.Id];
        newCampaign.Recommended_Outreach_Sequence__c = 'Testttt';
        newCampaign.Post_Event_to_Web__c = false;
        newCampaign.Activity_Details__c = null;
        newCampaign.Led_By__c = '3rd Party';
        
        TriggerUtility.afterUpdateRelatedLeadExecutedReset();
        TriggerUtility.afterUpdateRelatedContactExecutedReset();
        update newCampaign;
        newCampaign.Recommended_Outreach_Sequence__c = 'Testttt123';
        newCampaign.Led_By__c ='Channel Partner';
        TriggerUtility.afterUpdateRelatedLeadExecutedReset();
        TriggerUtility.afterUpdateRelatedContactExecutedReset();
        update newCampaign; 
        
        newCampaign.Led_By__c ='Tech Partner';
        update newCampaign; 
        Test.stopTest();
        
    }
}