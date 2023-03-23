@isTest
private class LeadMasterTriggerHandlerTest {
    
    static testMethod void RunCreateLead() {
        
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'fname',
                          lastname='lanme',
                          Alias='testali',
                          Email = 'test@gmail.com',
                          username= 'testuser@zscalar.com', 
                          profileId= p.id, 
                          Full_Name__c='testfull',
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;   
        
        
        lead l= new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Marketing Qualified: Sales Untouched');
        insert l;
        list<lead> leadlist = new List<Lead>();
        list<lead> updateleadlist = new List<Lead>();
        for(integer i=0;i<20;i++)
        {
            
            leadlist.add( new lead( FirstName = i+'Test', LastName = i+'Lead', Company = i+'Test Lead Company', Status = 'Pending Marketing Qualification'));
            
            
        }
        test.startTest();
        insert leadlist;
        for (lead l1: leadlist){
            l1.status='Marketing Qualified: Sales Untouched';
            updateleadlist.add(l1);
        }
        
        update  updateleadlist;
        test.stopTest();
        
        
    }
    
    
    static testMethod void AutoCloseLeadBAtch() {
        
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'fname',
                          lastname='lanme',
                          Alias='testali',
                          Email = 'test@gmail.com',
                          username= 'testuser@zscalar.com', 
                          profileId= p.id, 
                          Full_Name__c='testfull',
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;   
        
        
        lead l= new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Marketing Qualified: Sales Untouched');
        insert l;
        list<lead> leadlist = new List<Lead>();
        list<lead> updateleadlist = new List<Lead>();
        for(integer i=0;i<20;i++)
        {
            
            leadlist.add( new lead( FirstName = i+'Test', LastName = i+'Lead', Company = i+'Test Lead Company', Status = 'Pending Marketing Qualification'));
            
            
        }
        
        insert leadlist;
        for (lead l1: leadlist){
            l1.status='Marketing Qualified: Sales Accepted';
            l1.Last_opened_Date__c=System.Today().addDays(-15);
            updateleadlist.add(l1);
        }
        system.debug('Prir to Update!@'+updateleadlist);
        update  updateleadlist;
        system.debug('After  Update!@'+updateleadlist);
        test.startTest();
        
        Database.executeBatch(new BatchAutoCloseLead(),200);
        test.stopTest();
        
        
    }
    static testMethod void AutoCloseLeadBAtch1() {
        
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'fname',
                          lastname='lanme',
                          Alias='testali',
                          Email = 'test@gmail.com',
                          username= 'testuser@zscalar.com', 
                          profileId= p.id, 
                          Full_Name__c='testfull',
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;   
        
        
        lead l= new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Marketing Qualified: Sales Untouched');
        insert l;
        list<lead> leadlist = new List<Lead>();
        list<lead> updateleadlist = new List<Lead>();
        for(integer i=0;i<20;i++)
        {
            
            leadlist.add( new lead( FirstName = i+'Test', LastName = i+'Lead', Company = i+'Test Lead Company', Status = 'Pending Marketing Qualification'));
            
            
        }
        
        insert leadlist;
        for (lead l1: leadlist){
            l1.status='Marketing Qualified: Sales Untouched';
            l1.Last_opened_Date__c=System.Today().addDays(-15);
            updateleadlist.add(l1);
        }
        system.debug('Prir to Update!@'+updateleadlist);
        update  updateleadlist;
        system.debug('After  Update!@'+updateleadlist);
        test.startTest();
        
        Database.executeBatch(new BatchAutoCloseLead(),200);
        test.stopTest();
        
        
    }
    //added by Swathi : CR 1398 start
    static testmethod void test2(){
        BatchAutoCloseLead m = new BatchAutoCloseLead();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test update ter  tasks 1', sch, m);
    }
    //added by Swathi : CR 1398 End
    
    static testMethod void BatchCountTouchesSinceLastOpenOnLead() {
        
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'fname',
                          lastname='lanme',
                          Alias='testali',
                          Email = 'test@gmail.com',
                          username= 'testuser@zscalar.com', 
                          profileId= p.id, 
                          Full_Name__c='testfull',
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;   
        
        
        lead l= new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Marketing Qualified: Sales Untouched');
        insert l;
        list<lead> leadlist = new List<Lead>();
        list<lead> updateleadlist = new List<Lead>();
        for(integer i=0;i<4;i++)
        {
            
            leadlist.add( new lead( FirstName = i+'Test', LastName = i+'Lead', Company = i+'Test Lead Company', Status = 'Pending Marketing Qualification',last_opened_Date__c=System.today().addDays(-1)));
            
            
        }
        
        insert leadlist;
        for (lead l1: leadlist){
            task t  = new task(whoid=l1.id, Subject='test', Status='Completed',ActivityDate=system.today());
            insert t;
            task t1  = new task(whoid=l1.id, Subject='1test', Status='Completed',ActivityDate=system.today());
            insert t1;
            event e  = new event(whoid=l1.id, Subject='test Event 11',ActivityDate=system.today(), startdatetime=system.now(),enddatetime=system.now());
            insert e;
            system.debug('Prir to Update!@'+e);
            event e1  = new event(whoid=l1.id, Subject='test Event 121', ActivityDate=system.today(),startdatetime=system.now(),enddatetime=system.now());
            insert e1;
            system.debug('Prir to Update!@'+e1);
            
        }
        system.debug('Prir to Update!@'+updateleadlist);
        update  updateleadlist;
        system.debug('After  Update!@'+updateleadlist);
        test.startTest();
        
        Database.executeBatch(new BatchCountTouchesSinceLastOpenOnLead(),200);
        //BatchCountTouchesSinceLastOpenOnLead b1 = new BatchCountTouchesSinceLastOpenOnLead(); 
        //String sch ='0 48 * * * ?'; 
        //System.schedule('Schedule to update Lead Touches', sch,b1);
        test.stopTest();
        
        
    }
    
    
    
    
    /* static testMethod void processCampaignMemberAfterUpdatetest() {
        
        List<ZscalerSetting__c> ZscalerSettinglist= new List<ZscalerSetting__c>();
        ZscalerSetting__c Zsc1= new ZscalerSetting__c(Name='CampaignExceptions1',Value__c='ABC');
        ZscalerSettinglist.add(Zsc1);
        ZscalerSetting__c Zsc2= new ZscalerSetting__c(Name='CampaignExceptions2',Value__c='DEF');
        ZscalerSettinglist.add(Zsc2);
        Insert ZscalerSettinglist;
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0);
        insert lead;
        
        Lead lead1 = new Lead(FirstName = 'Test1', LastName = 'Lead1', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0);
        insert lead1;
        
        
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true);
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
        cm.Campaign_Type__c = 'Assets';
        cm.Activity_Details__c = 'ebook';
        cm.IsActive = true;
        CmpgnList.add(cm);
        
        Campaign cm1 = new Campaign();
        cm1.name='ZPA Interactive1';
        cm1.Department__c = '5000-Corporate Marketing';
        cm1.Geo__c = 'GLOBAL';
        cm1.StartDate = Date.today();
        cm1.EndDate = Date.today()+30;
        cm1.Fiscal_Year__c = 'All Time';
        cm1.Type = 'Default';
        cm1.Campaign_Type__c = 'Assets';
        cm1.Activity_Details__c = 'ebook';
        cm1.IsActive = true;
        CmpgnList.add(cm1);
        
        insert CmpgnList;
        
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        CampaignMember CMM1 = new CampaignMember(Campaignid=cm.id,Contactid=con.id,Status='Sent');
        CmpgnMemList.add(CMM1);
        CampaignMember CMM2 = new CampaignMember(Campaignid=cm.id,Leadid=lead.id,Status='Sent');
        CmpgnMemList.add(CMM2);
        CampaignMember CMM3 = new CampaignMember(Campaignid=cm.id,Leadid=lead1.id,Status='Sent');
        CmpgnMemList.add(CMM3);
        CampaignMember CMM4 = new CampaignMember(Campaignid=cm1.id,Leadid=lead1.id,Status='Other');
        CmpgnMemList.add(CMM4);
        insert CmpgnMemList;
        
        
        
        Test.startTest();
        
        List<CampaignMember> camList = [Select ID,name,Account__c,CampaignId,Campaign.IsActive from CampaignMember where Account__c = null and Campaign.IsActive = true ];
        System.debug('--camList--'+camList);
        
        List<lead> leadList = new List<lead>();
        lead.LeanData__Reporting_Matched_Account__c = acctTest.id;
        lead1.LeanData__Reporting_Matched_Account__c = acctTest.id;
        leadList.add(lead);
        leadList.add(lead1);
        update leadList;
        Test.stopTest();
    }  */
    
}