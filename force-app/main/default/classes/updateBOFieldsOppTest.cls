@isTest
public class updateBOFieldsOppTest 
{
    
    private static Account creatAccount () {
        Account acc = new Account ();
        acc.Name = 'Test Account';
        acc.type = 'prospect';
        acc.APTS_Platform_Subscription_End_Date__c = Date.today();
        return acc;
    }
    
    static testMethod void test1() {
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        Account acc= creatAccount();
        insert acc;
        
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.closedate =  Date.today();
        opp.Start_Date__c  =  Date.today();
        opp.accountId = acc.Id;
        opp.type ='Existing Customer (Renewal)';
        opp.Stagename = label.Stage_4_Economic_Buyer_Signoff;
        insert opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'test opp1ortunity';
        opp1.closedate =  Date.today();
        opp1.Start_Date__c  =  Date.today();
        opp1.accountId = acc.Id;
        opp1.type ='Existing Customer (Renewal)';
        opp1.Stagename = label.Stage_4_Economic_Buyer_Signoff;
        insert opp1;
        
        dateTime dt = Datetime.now();
        event myEvent = new event();
        myEvent.Subject = 'test meeting with CSIO';
        myEvent.StartDateTime = dt.addDays(-1) ;
        myEvent.EndDateTime = dt;
        myEvent.Type = 'CISO Security Policy Review';
        myEvent.WhatId = opp1.Id;
        insert myEvent;
        
        event myEvent1 = new event();
        myEvent1.Subject = 'test meeting with CSIO';
        myEvent1.StartDateTime = dt.addDays(+1) ;
        myEvent1.EndDateTime = dt.addDays(+2);
        myEvent1.Type = 'CISO Security Policy Review';
        myEvent1.WhatId = opp.Id;
        insert myEvent1;
        
        event myEvent2 = new event();
        myEvent2.Subject = 'test meeting with CSIO';
        myEvent2.StartDateTime = dt.addDays(+1) ;
        myEvent2.EndDateTime = dt.addDays(+2);
        myEvent2.Type = 'CISO Security Policy Review';
        myEvent2.WhatId = opp1.Id;
        insert myEvent2;
        
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Provisioning_Request__c PRRec= new Provisioning_Request__c();
        PRRec.Account__c = acc.Id;
        PRRec.Opportunity__c = opp.Id;
        PRRec.Provisioning_Status__c = 'Provisioned';
        PRRec.Organization_Domain__c = 'motabilityoperations.co.uk';
        PRRec.Send_Initial_l__c = 'SE';
        PRRec.SE__c = u.Id;
        PRRec.Provisioning_Date__c = system.today().addDays(-30);
        PRRec.Provisioning_Request_Expiry_Date__c = system.today().addDays(30);
        PRRec.Eval_Extended_End_Date__c = system.today().addDays(30);
        PRRec.RecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
        insert PRRec;
        
        List<Provisioning_Request__c> countPR = [Select Opportunity__c, Eval_Extended_End_Date__c, RecordTypeId from Provisioning_Request__c ];
        
        Test.startTest();
        
        Database.executeBatch(new updateBOFieldsOpp('SELECT Id FROM Account'),2);
        
        Test.stopTest();
        
        Account accnt = [SELECT Id FROM Account LIMIT 1];
        system.assertNotEquals(NULL, accnt.Id);
    }
    
    
    static testMethod void test2() {
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        
        Account acc= creatAccount();
        insert acc;
        
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.closedate =  Date.today();
        opp.Start_Date__c  =  Date.today();
        opp.accountId = acc.Id;
        opp.type ='Existing Customer (Renewal)';
        opp.Stagename = label.Stage_4_Economic_Buyer_Signoff;
        insert opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'test opp1ortunity';
        opp1.closedate =  Date.today();
        opp1.Start_Date__c  =  Date.today();
        opp1.accountId = acc.Id;
        opp1.type ='Existing Customer (Renewal)';
        opp1.Stagename = label.Stage_4_Economic_Buyer_Signoff;
        insert opp1;
        
        
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Provisioning_Request__c PRRec= new Provisioning_Request__c();
        PRRec.Account__c = acc.Id;
        PRRec.Opportunity__c = opp.Id;
        PRRec.Provisioning_Status__c = 'Provisioned';
        PRRec.Organization_Domain__c = 'motabilityoperations.co.uk';
        PRRec.Send_Initial_l__c = 'SE';
        PRRec.SE__c = u.Id;
        PRRec.Provisioning_Date__c = system.today().addDays(-30);
        PRRec.Provisioning_Request_Expiry_Date__c = system.today().addDays(30);
        PRRec.Eval_Extended_End_Date__c = system.today().addDays(30);
        PRRec.RecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
        insert PRRec;
        
        List<Provisioning_Request__c> countPR = [Select Opportunity__c, Eval_Extended_End_Date__c, RecordTypeId from Provisioning_Request__c ];
        
        Test.startTest();
        
        Database.executeBatch(new updateBOFieldsOpp('SELECT Id FROM Account'),2);
        
        Test.stopTest();
        
         Account accnt = [SELECT Id FROM Account LIMIT 1];
        system.assertNotEquals(NULL, accnt.Id);
    }
    
    
    static testMethod void test4() {
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        Account acc=creatAccount();
        insert acc;
        
        date d1 = date.newInstance(2020, 04, 10);
        date d3 = date.newInstance(2021, 04, 10);
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity1';
        opp.closedate =  Date.today();
        opp.Start_Date__c  =  Date.today();
        opp.accountId = acc.Id;
        opp.type ='Existing Customer (Renewal)';
        opp.Stagename = label.Stage_4_Economic_Buyer_Signoff;
        opp.Next_Activity_Date__c= d1;
        opp.Activity_Last_60D__c = 10;
        insert opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'test opp1ortunity2';
        opp1.closedate =  Date.today();
        opp1.Start_Date__c  =  Date.today();
        opp1.accountId = acc.Id;
        opp1.type ='Existing Customer (Renewal)';
        opp1.Stagename = label.Stage_4_Economic_Buyer_Signoff;
        opp.Next_Activity_Date__c= d3;
        opp.Activity_Last_60D__c = 40;
        insert opp1;
        
        Test.startTest();
        Database.executeBatch(new updateBOFieldsOpp('SELECT Id FROM Account')); 
        
        updateBOFieldsOppBatchSch m = new updateBOFieldsOppBatchSch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test ren notification exp rem', sch, m);
        Test.stopTest();
        
        opportunity oppor = [SELECT id,Activity_Last_60D__c from opportunity WHERE Activity_Last_60D__c = NULL LIMIT 1];
        assert.isTrue(oppor.Activity_Last_60D__c == NULL);
    }
}