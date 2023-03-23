@istest
public class Value_Summary_Attachment_Deletion_Test{
    static testmethod void test1(){
        Value_Summary_Attachment_Deletion_Sch m = new Value_Summary_Attachment_Deletion_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test delete vsa', sch, m);
    }
    static testmethod void test2(){
        Id userId = UserInfo.getUserId();
        Service_Agent_Information__c sai = new Service_Agent_Information__c(user__c=userId,daily_Quota__c = 1, weekly_quota__c = 5, backlog__c = 0, Overflow_Cases__c=0, Overflow_Cases_Weekly__c=0, Type__c='Frontline',Shift_Off_Days__c='Tuesday;Wednesday');
        insert sai;
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=sai.id;
        insert attach;
        //List<String> errorlst = new List<String>();
        Value_Summary_Attachment_Deletion m = new Value_Summary_Attachment_Deletion();
        m.errorlst.add('error');
        Database.executeBatch(m,200);
    }
}