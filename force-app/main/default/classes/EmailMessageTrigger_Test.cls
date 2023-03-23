@istest
public class EmailMessageTrigger_Test {
    
    
    @testSetup 
    static void createTestData() 
    {
        Boolean execute = true;
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'UpdateCaseStatus', Execute__c = execute));
        insert trlst;

        Case_Quota_Management__c cs = new Case_Quota_Management__c();
        cs.SetupOwnerId=UserInfo.getOrganizationId();
        cs.Backline_Daily_Quota__c=2;
        cs.Backline_Weekly_Quota__c=10;
        cs.Frontline_Daily_Quota__c=3;
        cs.Frontline_Weekly_Quota__c=15;
        cs.Online_Omni_Status__c='Quota_Met;Overflow';
        cs.Profiles_Allowed__c='';
        cs.Skills_to_Skip__c='CS;TAM';
        cs.Timezone__c='America/Los_Angeles';
        cs.Weekday_End_Time__c=0;
        cs.Weekday_Start_Time__c=7;
        cs.Weekend_End_Day__c='Sun';
        cs.Weekend_End_Time__c=16;
        cs.Weekend_Start_Day__c	='Fri';
        cs.Weekend_Start_Time__c=19;
        insert cs;
    }
    
    
    @IsTest
    static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Triggers_Switch__c tr = new Triggers_Switch__c(name = 'Execute_Last_Public_Comment', Execute__c = true);
        insert tr;
        User ur = [Select Id from User where Service_Level__c != null and isActive=true limit 1];
        Test.startTest();
        System.runAs(ur){
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem', Internal_CC_List__c='test@test.com;', Customer_CC_List__c='test2@test2.com;');
            TriggerUtility.isSkipCaseTriggerExecuted();
            insert cs;
            Id caseId = cs.Id;

            Case cs2 = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes2', Case_type__c = 'Problem');
            insert cs2;
            
            List<EmailMessage> emList = new List<EmailMessage>();
            
            EmailMessage em = new EmailMessage(parentId = caseId, incoming=true, fromaddress='avaideeswaran@gmail.com', toaddress='avaideeswaran@gmail.com',ccaddress='avaideeswaran@gmail.com');
            em.HTMLBody = 'abcd';
            emList.add(em);
            //insert em;
            
            EmailMessage em1 = new EmailMessage(parentId = cs2.Id, incoming=false, fromaddress='avaideeswaran@zscaler.com', toaddress='avaideeswaran@gmail.com;adhole@gmail.com',ccaddress='avaideeswaran@gmail.com');
            em1.HTMLBody = 'xyz';
            emList.add(em1);
            
            insert emList;
        }
        Test.stopTest();
        
    }
    @IsTest
    static void test2(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        User ur = [Select Id from User where Service_Level__c != null and isActive=true limit 1];
        Test.startTest();
        System.runAs(ur){
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            cs.External_Reference__c = 'test reference';
            TriggerUtility.isSkipCaseTriggerExecuted();
            insert cs;
            Id caseId = cs.Id;
			//Added by Anup - CR#1700 - Start
            Case_Integration__c csInt = new Case_Integration__c();
            csInt.Case__c = caseId;
            csInt.External_ID__c = 'test reference';
            csInt.Incident_Type__c = 'Incident';
            insert csInt;
            cs.External_Reference__c = 'test reference';
            cs.status = 'Researching' ;
            update cs;
            //Added by Anup - CR#1700 - End
            EmailMessage em = new EmailMessage(parentId = caseId, incoming=true, fromaddress='avaideeswaran@zscaler.com', toaddress='avaideeswaran@zscaler.com',ccaddress='avaideeswaran@zscaler.com');
            em.HTMLBody = 'abcd';
            insert em;
            //Added by Anup - CR#1700 - Start
            cs.Status = 'Pending Customer';
            update cs;
            TriggerUtility.EmailMessageAfterInsertReset();
            TriggerUtility.EmailMessagetoCaseCommentReset();
            EmailMessage em2 = new EmailMessage(parentId = cs.Id, incoming=false, fromaddress='adhole@zscaler.com', toaddress='anupdhole@gmail.com',ccaddress='test@zscaler.com');
            //Added by: Ankit Bhatnagar - IBA-166 Starts
            em2.HTMLBody = 'abcd'+' '+Label.Siemens_Customer_Communication_Keyword;
            em2.textBody = 'abcd'+' '+Label.Siemens_Customer_Communication_Keyword;
            //Added by: Ankit Bhatnagar - IBA-166 Ends
            insert em2;
            //Added by Anup - CR#1700 - End
        }
        Test.stopTest();
        
    }
    
    @IsTest
    static void test3(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        TriggerUtility.isSkipCaseTriggerExecuted();
        insert cs;
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        Incident inc = new Incident(Subject = 'Test Incident', priority = 'SEV-2', region__c = 'Global', recordTypeId = cloudIncRecordTypeId);
        insert inc;
        Id incId=inc.Id;
        Map<String, String> emailIncidentMap= new Map<String, String>();
        Test.startTest();
        EmailMessage em = new EmailMessage(RelatedToId = incId, incoming=false,subject='Z-EXT Test',Textbody='Test',fromaddress='test@zscaler.com', toaddress='test@zscaler.com',ccaddress='test@zscaler.com');
        insert em;
        ContentVersion ContentVer = new ContentVersion();
        ContentVer.Title = 'My Doc';
        ContentVer.ContentUrl= 'test.com';
        Insert ContentVer;
        ContentDocumentLink ContentDL = new ContentDocumentLink();
        ContentDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ContentVer.Id].ContentDocumentId;
        ContentDL.LinkedEntityId=em.id;
        ContentDL.ShareType='V';
        Insert ContentDL;
        CaseRelatedIssue cri=new CaseRelatedIssue();
        cri.caseId=cs.Id;
        cri.RelatedIssueId=inc.Id;
        insert cri;
        ContentDL = [SELECT Id,ShareType FROM ContentDocumentLink WHERE Id =:ContentDL.Id];
        FeedItem newFI= new FeedItem(ParentId=cs.id,body='Test',Visibility='AllUsers');
        insert newFI;
        emailIncidentMap.put(em.Id,em.RelatedToId);
        
        Test.stopTest();  
    }
   
}