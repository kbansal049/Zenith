@isTest 
public class NoteTriggerHandlerTest {
    static testMethod void testMethod1(){
        Triggers_Switch__c ts1= new Triggers_Switch__c(Name='NoteUpdateRFPRequest',Execute__c=True,Object_Name__c='Note');
        insert ts1;
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
        
        Note nt=new Note();       
         nt.Title='Unit Test NOte';
          nt.body = 'Unit Test Attachment Body';
          nt.parentId = rfp.id;
        insert nt;
        
        }
}