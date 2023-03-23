@istest
public class RelatedListControllerTest {
    
    @istest
    public static void testmethod1(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Test.startTest();
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Service_Level__c = null and Profile.name = 'System Administrator' and isActive = true limit 1];
        System.runAs(ur){
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            insert acct;
      
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;
        
            RelatedListController.RequestWrapper rWrap  = new RelatedListController.RequestWrapper();
            rWrap.lmt = 5;
            rWrap.objName = 'Case';
            rWrap.parentId = acct.id;
            rWrap.parent_API_Name = 'name';
            rWrap.fieldSetName = 'Meeting_Detail_Page_Support_Cases_Set';
            rWrap.child_API_Name = 'AccountId';
            String req = JSON.serialize(rWrap);
            RelatedListController.fetchRecords(req);
        }
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    public static void testmethod2(){
        
        TriggerUtility.SkipAccTriggerExecuted();
        Account a = new Account(Name='TEST-Z1');
        insert a;
        
        TriggerUtility.SkipContactTriggerExecuted();
        Contact con1 = new Contact();
        con1.AccountId = a.id;
        con1.lastname = 'Test2';
        con1.firstname = 'Test2';
        insert con1;
        
        
        Case cs = new Case(AccountId = a.id, Description='Test Desc');
        insert cs;
        
        
        Meeting__c mt = new Meeting__c(Date_of_meeting__c = System.now(), Customer_Name__c = a.id,Duration__c = 15, Executive_Summary__c = 'Test');
        insert mt;
        
        RelatedListController.getdefaultParameters(cs.id, mt.id);
        
        
        Id depRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project') != null) ?
            Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project').getRecordTypeId() :
        Null;
        
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = 'Test project 2';
        IP.inspire1__Account__c=a.ID;
        IP.inspire1__Project_Status__c='In Progress';
        IP.Action_Plan__c = 'Test Plan';
        IP.RecordTypeId = depRecordTypeId;
        IP.Primary_Customer_Contact__c = con1.id;
        IP.Secondary_Customer_Contact__c = con1.id;
        insert IP;
        
        RelatedListController.getdefaultParameters(IP.id, mt.id);
        
        
        Objective__c obj = new Objective__c(Meeting_ID__c = mt.id,TAM_Notes__c = 'test notes');
        RelatedListController.createRecord(new List<Sobject>{obj});
        
        RelatedListController.getdefaultParameters(obj.id, mt.id);
        
        
        RelatedListController.delRecs(obj);
        RelatedListController.saveRecs(new List<Sobject>{mt});
        
    }
}