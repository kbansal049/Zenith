@istest
public class CaseIntegrationHandlerTest {
    
    
    @testSetup 
    static void createTestData() 
    {
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        TriggerUtility.SkipEmailMessageTriggerReset();
        TriggerUtility.SkipAccTriggerExecuted();
        
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        insert acct;
        
        Contact con = new Contact();
        con.lastname = 'test';
        con.FirstName = 'ts';
        con.AccountId = acct.id;
        insert con;
        
        
        CaseIntegrationHandler.testAccountID = acct.id;
        CaseIntegrationHandler.testContactID = con.id;
        
        Triggers_Switch__c ts = new Triggers_Switch__c(name = 'Execute_CASE_Integration_Trigger', Execute__c = true);
        insert ts;
        
        Triggers_Switch__c ts1 = new Triggers_Switch__c(name = 'Execute_Case_Integration_Updation', Execute__c = true);
        insert ts1;
        
        Triggers_Switch__c ts2 = new Triggers_Switch__c(name = 'Execute_EmailMessageCDL_to_CaseCDL', Execute__c = true);
        insert ts2;
        
        Triggers_Switch__c ts3 = new Triggers_Switch__c(name = 'Execute_Case_Trigger', Execute__c = true);
        insert ts3;
        
        Boolean execute = true;
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        
        trlst.add(new Triggers_Switch__c(name = 'Execute_CaseComment_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Description_to_Comment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Entitlement_Assignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Escalation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_SkillAssignment', Execute__c = false));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Status_History', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Contact_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'ExecuteUpdateTAMemail', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'ExecuteUpdateOriginalTAMdetails', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Close_with_Action_Plan', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'updateExtentison', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'ExecuteUpdateCSMonCase', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_TAM_Reassignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CC_toCaseTeam', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_TAM_Assignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_TAM_Notes_History', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Assign_TAM_As_Owner', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Escalation_Notes_Creation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Manual_SLA', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Get_Feedback', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'CloseMilestonesonCaseClose', Execute__c = execute));
		trlst.add(new Triggers_Switch__c(name = 'UpdateDetailsonMasterCase', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'UpdateAccountDataTime', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Sync_CaseBA_With_CR', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_AgentWork_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_ContentDocumentLink_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_EmailMessage_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_EmailMessage_CaseComment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Close_Case_FRT', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Last_Public_Comment', Execute__c = execute));
        //Added by Anup- Workato Migration
        trlst.add(new Triggers_Switch__c(name = 'Execute_Field_Changed_Check', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_File_Association_With_Cases', Execute__c = execute));
        //Added by Anup- Workato Migration
        
        insert trlst;
    }
    
    @IsTest
    static void test1(){
        
        Case_Integration__c ci = new Case_Integration__c();
        ci.Integration_Status__c = 'Not Started';
        ci.External_ID__c = 'INC123456';
        ci.Category_ID__c = 'CI12345';
        ci.SubCategory_ID__c = 'CI545645';
        ci.SubSubCategory_ID__c = 'CI545646';
        ci.Data_Points__c = 'Test Data Points';
        ci.Customer_Communication__c = 'Test Communication';
        ci.Ticket_Status__c = 'Open';
        ci.Detailed_Description__c = 'Test';
        ci.Internal_Work_Notes__c = 'Test';
        ci.Severity__c = '4';
        ci.Short_Description__c = 'Test';
        ci.Assignment_Group__c = 'INC_Zscaler';
        ci.Case_Origin__c = 'Siemens';
        ci.Incident_Type__c = 'Incident';
        insert ci;
        
        //Added by Anup - Workato Migration
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        Case_Integration__c ciPub = new Case_Integration__c();
        ciPub.Integration_Status__c = 'Not Started';
        ciPub.External_ID__c = 'INC123478';
        ciPub.Category_ID__c = 'CI12345';
        ciPub.SubCategory_ID__c = 'CI545645';
        ciPub.SubSubCategory_ID__c = 'CI545646';
        ciPub.Data_Points__c = 'Test Data Points';
        ciPub.Customer_Communication__c = 'Test Communication';
        ciPub.Ticket_Status__c = 'Open';
        ciPub.Detailed_Description__c = 'Test';
        ciPub.Internal_Work_Notes__c = 'Test';
        ciPub.Severity__c = 'Medium (P3)';
        ciPub.Short_Description__c = 'Test';
        ciPub.Assignment_Group__c = 'INC_Zscaler';
        ciPub.Case_Origin__c = 'Public Form';
        ciPub.Incident_Type__c = 'Incident';
        insert ciPub;
        //Added by Anup - Workato Migration
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
        ci.Ticket_Status__c = 'Pending';
        ci.Assignment_Group__c = 'INC_ATOS';
        ci.Detailed_Description__c = 'Test updated';
        ci.Internal_Work_Notes__c = 'Test updated';
        ci.Customer_Communication__c = 'Test Communication updated';
        update ci;
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
        ci.Ticket_Status__c = 'Pending';
        ci.Assignment_Group__c = 'INC_Zscaler_Interface';
        ci.Detailed_Description__c = 'Test updated';
        ci.Internal_Work_Notes__c = 'Test updated 123';
        ci.Customer_Communication__c = 'Test Communication updated 12';
        update ci;
        
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
        Case_Integration__c ci1 = new Case_Integration__c();
        ci1.Integration_Status__c = 'Not Started';
        ci1.External_ID__c = 'INC123450';
        ci1.Category_ID__c = 'CI12345';
        ci1.SubCategory_ID__c = 'CI545645';
        ci1.SubSubCategory_ID__c = 'CI545646';
        ci1.Data_Points__c = 'Test Data Points';
        ci1.Customer_Communication__c = 'Test Communication';
        ci1.Ticket_Status__c = 'Open';
        ci1.Detailed_Description__c = 'Test';
        ci1.Internal_Work_Notes__c = 'Test';
        ci1.Severity__c = '4';
        ci1.Short_Description__c = 'Test';
        ci1.Assignment_Group__c = 'INC_Zscaler';
        ci1.Case_Origin__c = 'Siemens';
         ci1.Incident_Type__c = 'Incident';
        insert ci1;
        
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
        Case_Integration__c ci11 = new Case_Integration__c();
        ci11.Integration_Status__c = 'Not Started';
        ci11.Parent_Incident__c = 'INC123456';
        ci11.External_ID__c = 'INC123457';
        ci11.Category_ID__c = 'CI12345';
        ci11.SubCategory_ID__c = 'CI545645';
        ci11.SubSubCategory_ID__c = 'CI545646';
        ci11.Data_Points__c = 'Test Data Points';
        ci11.Customer_Communication__c = 'Test Communication';
        ci11.Ticket_Status__c = 'Open';
        ci11.Detailed_Description__c = 'Test';
        ci11.Internal_Work_Notes__c = 'Test';
        ci11.Severity__c = '4';
        ci11.Short_Description__c = 'Test';
        ci11.Assignment_Group__c = 'INC_Zscaler';
        ci11.Case_Origin__c = 'Siemens';
        ci11.Incident_Type__c = 'Incident';
        insert ci11;
        
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
        ci11.Case__c = null;
        ci11.Assignment_Group__c = 'zzzFITS';
        ci11.Detailed_Description__c = 'Test updated';
        ci11.Internal_Work_Notes__c = 'Test updated';
        ci11.Customer_Communication__c = 'Test Communication updated';
        update ci11;
        
    }
    
    
    
    @IsTest
    static void test2(){
    
        Case_Integration__c ci = new Case_Integration__c();
        ci.Integration_Status__c = 'Not Started';
        ci.External_ID__c = 'INC123456';
        ci.Category_ID__c = 'CI12345';
        ci.SubCategory_ID__c = 'CI545645';
        ci.SubSubCategory_ID__c = 'CI545646';
        ci.Data_Points__c = 'Test Data Points';
        ci.Customer_Communication__c = 'Test Communication';
        ci.Ticket_Status__c = 'Open';
        ci.Detailed_Description__c = 'Test';
        ci.Internal_Work_Notes__c = 'Test';
        ci.Severity__c = '4';
        ci.Short_Description__c = 'Test';
        ci.Assignment_Group__c = 'INC_Zscaler';
        ci.Case_Origin__c = 'Siemens';
        ci.Incident_Type__c = 'Incident';
        insert ci;
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
        
        Case_Integration__c ci11 = new Case_Integration__c();
        ci11.Integration_Status__c = 'Not Started';
        ci11.Parent_Incident__c = 'INC123456';
        ci11.External_ID__c = 'INC123457';
        ci11.Category_ID__c = 'CI12345';
        ci11.SubCategory_ID__c = 'CI545645';
        ci11.SubSubCategory_ID__c = 'CI545646';
        ci11.Data_Points__c = 'Test Data Points';
        ci11.Customer_Communication__c = 'Test Communication';
        ci11.Ticket_Status__c = 'Open';
        ci11.Detailed_Description__c = 'Test';
        ci11.Internal_Work_Notes__c = 'Test';
        ci11.Severity__c = '4';
        ci11.Short_Description__c = 'Test';
        ci11.Assignment_Group__c = 'INC_Zscaler';
        ci11.Case_Origin__c = 'Siemens';
        ci11.Incident_Type__c = 'Incident';
        insert ci11;
        
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
        
        ci.Ticket_Status__c = 'Closed';
        ci.Assignment_Group__c = 'INC_Zscaler_Interface';
        ci.Detailed_Description__c = 'Test updated';
        ci.Internal_Work_Notes__c = 'Test updated 123';
        ci.Customer_Communication__c = 'Test Communication updated 12';
        update ci;
        
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
    }
    
    
    @IsTest
    static void test3(){
    
        Case_Integration__c ci = new Case_Integration__c();
        ci.Integration_Status__c = 'Not Started';
        ci.External_ID__c = 'INC123456';
        ci.Category_ID__c = 'CI12345';
        ci.SubCategory_ID__c = 'CI545645';
        ci.SubSubCategory_ID__c = 'CI545646';
        ci.Data_Points__c = 'Test Data Points';
        ci.Customer_Communication__c = 'Test Communication';
        ci.Ticket_Status__c = 'Open';
        ci.Detailed_Description__c = 'Test';
        ci.Internal_Work_Notes__c = 'Test';
        ci.Severity__c = '4';
        ci.Short_Description__c = 'Test';
        ci.Assignment_Group__c = 'INC_Zscaler';
        ci.Case_Origin__c = 'Siemens';
        ci.Incident_Type__c = 'Incident';
        ci.Assignment_Group__c = System.label.Zscaler_Assignment_Group;
        insert ci;
        
        /*Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case csNew1 = new Case(Subject='abcd', Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem', Customer_CC_List__c='test@test.com;test2@test2.com',Status='New');
        insert csNew1;
        ci.Case__c = csNew1.Id;
        update ci;*/
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
        TriggerUtility.executeCaseAfterUpdateCaseIntegartionSetFalse();
        TriggerUtility.CaseAfterUpdateReset();
        
        Case_Integration__c ci2 = new Case_Integration__c();
        ci2.Integration_Status__c = 'Not Started';
        ci2.External_ID__c = 'INC1234567';
        ci2.Category_ID__c = 'CI12345';
        ci2.SubCategory_ID__c = 'CI545645';
        ci2.SubSubCategory_ID__c = 'CI545646';
        ci2.Data_Points__c = 'Test Data Points';
        ci2.Customer_Communication__c = 'Test Communication';
        ci2.Ticket_Status__c = 'Open';
        ci2.Detailed_Description__c = 'Test';
        ci2.Internal_Work_Notes__c = 'Test';
        ci2.Severity__c = '4';
        ci2.Short_Description__c = 'Test';
        ci2.Assignment_Group__c = 'INC_Zscaler';
        ci2.Case_Origin__c = 'Siemens';
        ci2.Incident_Type__c = 'Complaint';
        ci2.Originated_From_Incident__c = 'INC123456';
        insert ci2;
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        
        
        TriggerUtility.executeCaseAfterUpdateCaseIntegartionSetFalse();
        TriggerUtility.CaseAfterUpdateReset();
        
        
        
        Case_Integration__c ci3 = new Case_Integration__c();
        ci3.Integration_Status__c = 'Not Started';
        ci3.External_ID__c = 'INC12345678';
        ci3.Category_ID__c = 'CI12345';
        ci3.SubCategory_ID__c = 'CI545645';
        ci3.SubSubCategory_ID__c = 'CI545646';
        ci3.Data_Points__c = 'Test Data Points';
        ci3.Customer_Communication__c = 'Test Communication';
        ci3.Ticket_Status__c = 'Open';
        ci3.Detailed_Description__c = 'Test';
        ci3.Internal_Work_Notes__c = 'Test';
        ci3.Severity__c = '4';
        ci3.Short_Description__c = 'Test';
        ci3.Assignment_Group__c = 'INC_Zscaler';
        ci3.Case_Origin__c = 'Siemens';
        ci3.Incident_Type__c = 'Incident';
        ci3.Parent_Incident__c = 'INC123456';
        insert ci3;
        
        Case_Integration__c ciInt = [Select id,case__c from Case_Integration__c where id = :ci.id and case__c != null];
        
        Case cs = [Select id,status from case where id = :ciInt.case__c];
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(cvList.size(), 1);
        
        
        
        
        TriggerUtility.caseIntegartionExecutedSetFalse();
        TriggerUtility.caseCaseIntegartionPatchSetFalse();
        TriggerUtility.executeCaseAfterUpdateCaseIntegartionSetFalse();
        
        
        
        TriggerUtility.executeCaseAfterUpdateCaseIntegartionSetFalse();
        TriggerUtility.CaseAfterUpdateReset();
        TriggerUtility.CaseEscalationHistoryReset();
        
        cs.status= 'Pending Customer';
        cs.Business_Analyst__c = userinfo.getUserId();
        cs.Escalation_Resolution_Notes__c = 'test';
        cs.Primary_TAM_Email__c='test@test.com';
        update cs;
        
        
        TriggerUtility.EmailMessageAfterInsertReset();
        
        EmailMessage emailMessage = new EmailMessage(); 
        emailMessage.status = '3';
        emailMessage.fromName = 'Test'; 
        emailMessage.ccaddress = 'test1@zscaler.com';
        emailMessage.subject = 'This is the Subject!';
        emailMessage.Incoming = false;
        emailMessage.htmlBody = '<html><body><b>Hello</b></body></html>';
        
        emailMessage.ToAddress = 'test@testmail.com;test@zscaler.com';
        emailMessage.ParentId = cs.id;
        insert emailMessage;
        

        // Add Email Message Relation for id of the sender 
        EmailMessageRelation emr = new EmailMessageRelation(); 
        emr.emailMessageId = emailMessage.Id; 
        emr.relationId = userinfo.getUserId(); 
        emr.relationType = 'FromAddress'; 
        insert emr;
        
        TriggerUtility.CDLAfterInsertReset();
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = cs.id;
        contentlink.ContentDocumentId = cvList[0].ContentDocumentId;
        contentlink.Visibility = 'AllUsers';  
        contentlink.ShareType = 'V';  
        insert contentlink;
        
        
        
        
        
        
        CaseIntegrationHandler.callComplaintPatchForSiemens(cs.id);
        
        List<Id> csIntIds = new List<ID>();
        csIntIds.add(ci2.Id);
        CaseIntegrationHandler.prepareCaseComplaintRecordsSiemens(csIntIds, 'Reassign', 'Test');
        
        
        TriggerUtility.CDLAfterInsertReset();
        contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = emailMessage.id;
        contentlink.ContentDocumentId = cvList[0].ContentDocumentId;
        contentlink.Visibility = 'AllUsers';  
        contentlink.ShareType = 'V';  
        insert contentlink;
        
    }
    
}