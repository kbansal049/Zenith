@isTest
public class POC_Notification_Batch_Test{
    static testmethod void test1(){
        Account acctTest = new Account(Name = 'Test Account', APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000));
        acctTest.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';
        insert acctTest;
        Contact con= new Contact(accountid = acctTest.Id,lastname = 'testContact1', email='testContact1@abc.com',Contacts_that_matter__c = false,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        insert con;
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Provisioning_Request__c PRRec= new Provisioning_Request__c();
        PRRec.Account__c = acctTest.Id;
        PRRec.Provisioning_Status__c = 'Production';
        PRRec.Organization_Domain__c = 'motabilityoperations.co.uk';
        PRRec.Send_Initial_l__c = 'SE';
        PRRec.SE__c = u.Id;
        PRRec.Approval_for_Purge_Status__c = 'Not Yet Submitted for Purge Approval';
        PRRec.Provisioning_Date__c = system.today().addDays(-30);
        PRRec.Provisioning_Request_Expiry_Date__c = system.today();
        PRRec.Email_Sent__c = date.today().adddays(-5);
        PRRec.Send_Reminder_Emails__c = true;
        PRRec.POC_Alert_Recipient_1__c = con.Id;
        PRRec.POC_Alert_Recipient_2__c = con.Id;
        PRRec.POC_Alert_Recipient_3__c = con.Id;
            
		try{
        insert PRRec; 
        }catch(Exception ex){
		
		}
        POC_Notification_Batch batch;
        batch = new POC_Notification_Batch();
        batch.errorlst.add('abc');
        Database.executeBatch(batch,1);
        
    }
}