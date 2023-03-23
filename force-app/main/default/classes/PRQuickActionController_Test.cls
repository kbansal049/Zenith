@isTest
public class PRQuickActionController_Test {
    
    @isTest
    public static void ActionController(){
        
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acc = new Account(Name='TestAccount',Type='Customer',Domain__c='TestAccount.com');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact',Email = 'test@test.com', AccountId =acc.id);
        insert con;
            
        Id profiles=userinfo.getProfileId();

        User u = new User( Alias = 'testu',
                           Email = 'test@test12.com',
                           EmailEncodingKey = 'UTF-8',
                           LastName = 'Test',
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US',
                           TimeZoneSidKey='America/Los_Angeles',
                           ProfileId = profiles,
                           UserName='test12356@example.com'
                        );
        
        Test.startTest();
        insert u;
        
        Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            
        Provisioning_Request__c Pr = new Provisioning_Request__c( RecordTypeId = inlineRecordTypeId,
                                                                  Organization_Domain__c='Test',
                                                                  Org_ID_with_cloud__c='irds',
                                                                  Provisioning_Status__c='Request Decommission',  
                                                                  Send_Initial_l__c = 'ATT Usell',
                                                                  Partner_Contact__c = con.id,
                                                                  SE__c=u.id,     
                                                                  Primary_Eval_Contact__c=con.id
                                                                );
        
        insert Pr;
        
        PRQuickActionController.RequestDecommission(Pr.id);
        PRQuickActionController.GetProvReqDetail(Pr.id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void ActionController2(){ 
        
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acc = new Account(Name='TestAccount',Type='Customer',Domain__c='TestAccount.com');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact',Email = 'test@test.com', AccountId =acc.id);
        insert con;
            
        Id profiles=userinfo.getProfileId();

        User u = new User( Alias = 'testu',
                           Email = 'test@example.com',
                           EmailEncodingKey = 'UTF-8',
                           LastName = 'Test',
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US',
                           TimeZoneSidKey='America/Los_Angeles',
                           ProfileId = profiles,
                           UserName='test1235@example.com'
                        );
        Test.startTest();
        insert u;
        
        Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            
        Provisioning_Request__c Pr = new Provisioning_Request__c( RecordTypeId = inlineRecordTypeId,
                                                                  Organization_Domain__c='Test',
                                                                  Org_ID_with_cloud__c='irds',
                                                                  Provisioning_Status__c='',
                                                                  Send_Initial_l__c = 'ATT Usell',
                                                                  Partner_Contact__c = con.id,
                                                                  SE__c=u.id,     
                                                                  Primary_Eval_Contact__c=con.id
                                                                );
        
        insert Pr;
        PRQuickActionController.RequestDecommission(Pr.id);
        PRQuickActionController.RequestDecommission(Null);
        PRQuickActionController.GetProvReqDetail(Null);
        Test.stopTest();
    }
}