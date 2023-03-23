@isTest
public class GCSProjectTriggerUtilityTest {
    
    @isTest
    public static void Test1(){
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateCompletionDate', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_ValidateAttachment', Execute__c = true));
        insert trlst;
        GCS_Project__c project=new GCS_Project__c();
        project.Project_Status__c='Completed';
        insert project;
        GCS_Project__c project2=new GCS_Project__c();
        project2.Project_Status__c='In Progress';
        insert project2;
        project2.Project_Status__c='Completed';
        update project2;  
    }
    
}