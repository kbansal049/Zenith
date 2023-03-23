@isTest
public class ExtendInteractiveControllerTest {
    
    @isTest
    public static void testmethod1(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        
        Id prRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZB2B Interactive').getRecordTypeId();
        Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = '';
        insert pr;
        
        Test.startTest();
        
        PageReference myVfPage = Page.ExtendInteractive;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(pr);
        ExtendInteractiveController pc = new ExtendInteractiveController(sc);
        pc.doRedirectProductDemoInteractiveRequest();
        
        ExtendInteractiveController.ExtendInteractive(pr.id);
        ExtendInteractiveController.DisableInteractive(pr.id);
        ExtendInteractiveController.reEnableInteractive(pr.id);
        ExtendInteractiveController.DecommissionInteractive(pr.id);        
        Test.stopTest();
    }
    
    @isTest
    public static void testmethod2(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        
        Id prRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZB2B Interactive').getRecordTypeId();
        Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'Decommissioned';
        insert pr;
        
        Test.startTest();
        
        PageReference myVfPage = Page.ExtendInteractive;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(pr);
        ExtendInteractiveController pc = new ExtendInteractiveController(sc);
        pc.doRedirectProductDemoInteractiveRequest();
        
        ExtendInteractiveController.ExtendInteractive(pr.id);
        ExtendInteractiveController.DisableInteractive(pr.id);
        ExtendInteractiveController.reEnableInteractive(pr.id);
        ExtendInteractiveController.DecommissionInteractive(pr.id);        
        
        
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void testmethod3(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        
        Id prRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZB2B Interactive').getRecordTypeId();
        Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'Disabled';
        insert pr;
        
        Test.startTest();
        
        pr.Provisioning_Status__c = 'Disabled';
        update pr;
        
        PageReference myVfPage = Page.ExtendInteractive;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(pr);
        ExtendInteractiveController pc = new ExtendInteractiveController(sc);
        pc.doRedirectProductDemoInteractiveRequest();
        
        ExtendInteractiveController.reEnableInteractive(pr.id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testmethod4(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        TriggerUtility.SkipContactTriggerExecuted();
        Contact cc = new Contact(FirstName='TestFname', LastName='TestLaname', OKTA_User_ID__c='345', accountid = acc.id);
        insert cc;
        
        
        Id prRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('Safemarch for Partners').getRecordTypeId();
        
        Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Primary_Eval_Contact__c = cc.Id;
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = '';
        pr.Interactive_Type__c = 'Safemarch for Partners';
        insert pr;
        
        pr = new Product_Demo_Instance_Request__c();
        ExtendInteractiveController.DecommissionInteractive(pr.id);        
    }
    
    @isTest
    public static void testmethod5(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        
        Id prRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZPA Interactive for Partners').getRecordTypeId();
        Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = '';
        pr.Interactive_Type__c='ZPA Interactive for Partners';
        insert pr;
        Test.startTest();
        
        PageReference myVfPage = Page.ExtendInteractive;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(pr);
        ExtendInteractiveController pc = new ExtendInteractiveController(sc);
        pc.doRedirectProductDemoInteractiveRequest();
        
        
        ExtendInteractiveController.ExtendInteractive(pr.id);
        ExtendInteractiveController.DisableInteractive(pr.id);
        ExtendInteractiveController.reEnableInteractive(pr.id);
        ExtendInteractiveController.DecommissionInteractive(pr.id);        
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void testmethod6(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        
        
        Id prRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZPA Interactive for Partners').getRecordTypeId();
        
        Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'Disabled';
        insert pr;
        
        Test.startTest();
        pr.Provisioning_Status__c = 'Disabled';
        update pr;
        PageReference myVfPage = Page.ExtendInteractive;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(pr);
        ExtendInteractiveController pc = new ExtendInteractiveController(sc);
        pc.doRedirectProductDemoInteractiveRequest();
        
        ExtendInteractiveController.reEnableInteractive(pr.id);        
        Test.stopTest();
    }
    
    
    
    @isTest
    public static void QueueTestMethod1(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        Contact con = new Contact(FirstName='Test', LastName = 'Test1', accountid = acc.id);
        insert con;
        
        lead l= new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Marketing Qualified: Sales Untouched');
        insert l;
        
        Id prRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZB2B Interactive').getRecordTypeId();
        Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = '';
        insert pr;
        
        Test.startTest();
        
        
        ZB2BInteractiveRequest ad = new ZB2BInteractiveRequest ('Contact', new List<ID>{con.id});
        System.enqueueJob(ad);
        
        
        ZB2BInteractiveRequest ad1 = new ZB2BInteractiveRequest ('Lead', new List<ID>{l.id});
        System.enqueueJob(ad1);
        
        Test.stopTest();
    }
    
}