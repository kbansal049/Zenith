@isTest 
public class AttachmentTriggerHandlerTest {
    static testMethod void testMethod1(){
        Test.startTest();
        Triggers_Switch__c ts1 = new Triggers_Switch__c(Name='Execute_Attachment_Trigger',Execute__c=True,Object_Name__c='Attachment');
        insert ts1;
        Triggers_Switch__c ts2= new Triggers_Switch__c(Name='AttachmentUpdateRFPRequest',Execute__c=True,Object_Name__c='Attachment');
        insert ts2;
        ZscalerCustomSetting__c zs= new ZscalerCustomSetting__c(Name='RFPobjectprefix',Value__c='aCJ');
        insert zs;
        RFP_Request__c rfp = new RFP_Request__c();
            Account Acc= new Account(Name='Test Account',Type='Partner');
            insert Acc;
            
            rfp.Account_Name__c = Acc.id;
            rfp.Due_Date__c = system.today();
            rfp.Proposed_Solution__c = 'ZIA';
            rfp.Request_Status__c = 'Completed';
            //rfp.Post_Request_Status__c = 'Completed';
            //rfp.Send_Attachment_Email__c = false ;
        insert rfp;
        
        Attachment attach=new Attachment();       
         attach.Name='Unit Test Attachment';
         Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
          attach.body = bodyBlob;
          attach.parentId = rfp.id;
        insert attach;
        //AttachmentTriggerHandler.UpdateRFPRequest(new List<Attachment>{attach});
        Test.stopTest();
        }
    
}