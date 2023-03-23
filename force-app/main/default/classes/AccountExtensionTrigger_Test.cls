@isTest
public class AccountExtensionTrigger_Test {

    
    @testsetup static void setupData() {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Service_Owner_Change_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_AccountOwnerChange_Alert', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Executed_AccountExtRelated_Acc', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        insert trlst;
    }
    @isTest static void serviceOwner(){
        
        User testUser = new User(LastName = 'TestUser',  Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        testUser.FirstName='Test';
        insert testUser;
        
        account ac = new account();
        ac.Name = 'test account';
        ac.Type = 'industry analyst';
        insert ac;
        
        account ac1 = new account();
        ac1.Name = 'test account1';
        ac1.Type = 'Prospect';
        insert ac1;
        
        
        contact cc = new contact();
        cc.FirstName = 'test';
        cc.LastName = 'contact';
        cc.AccountId = ac.id;
        insert cc;
        
        Account_Extension__c actExtension =new Account_Extension__c();
        actExtension.Account__c = ac.id;
        actExtension.Service_Owner__c = cc.id;
        insert actExtension;
        
        Account_Extension__c actExtension1 =new Account_Extension__c();
        actExtension1.Account__c = ac1.id;
        actExtension1.Service_Owner__c = cc.id;
        insert actExtension1;
        
        contact cc1 = new contact();
        cc1.FirstName = 'test';
        cc1.LastName = 'second';
        cc1.AccountId = ac.id;
        insert cc1;
        
        actExtension.Service_Owner__c = cc1.id; 
        actExtension.Secondary_Account_Owner__c=testUser.Id;
        update actExtension;
        
        actExtension1.Service_Owner__c = cc1.id; 
        actExtension1.Secondary_Account_Owner__c=testUser.Id;
        update actExtension1;
        actExtension1.Secondary_Account_Owner__c=null;
        update actExtension1;
    }
    //Added by Swathi :  CR1142
    @isTest static void accountOwnerEmail(){
        
        account ac = new account();
        ac.Name = 'test account';
        ac.Type = 'industry analyst';
        ac.CSM_Name_New__c=userinfo.getuserid();
        insert ac;
        
        contact cc = new contact();
        cc.FirstName = 'test';
        cc.LastName = 'contact';
        cc.AccountId = ac.id; 
        insert cc;
        TriggerUtility.setAccountExtenssionFalse();
        Account_Extension__c actExtension =new Account_Extension__c();
        actExtension.Account__c = ac.id;
        actExtension.Service_Owner__c = cc.id;
        actExtension.Account_Manager_tracker__c = true;
        actExtension.Account_Risk_Type__c = 'Partial Churn Risk';
        actExtension.Risk_Reason__c='Competition';
        actExtension.Risk_Reason_Details__c='test';
        insert actExtension;
        
        contact cc1 = new contact();
        cc1.FirstName = 'test';
        cc1.LastName = 'second';
        cc1.AccountId = ac.id;
        insert cc1;
        TriggerUtility.setAccountExtenssionFalse();
        TriggerUtility.UpdateAccountExtensionmethodsetfalse();
        TriggerUtility2.updateAccExtRelatedAccReset();
        actExtension.Service_Owner__c = cc1.id; 
        actExtension.Account_Manager_tracker__c = False;
        actExtension.Account_Risk_Type__c = 'Full Churn Risk';
        update actExtension;
        
    }
}