public class EmailTouchpointNotStarted {
    @InvocableMethod(label='callEmailTouchpointNotStartedBatch')
    public static void callEmailTouchpointNotStartedBatch(){
        String Query;
        if(Test.isRunningTest()){
            Query='Select id,Name,inspire1__Project__c,inspire1__Project__r.inspire1__Account__r.TAM_Name_New__r.Email,inspire1__Project__r.inspire1__Account__r.TAM_Name_New__r.Manager.Email,inspire1__Project__r.inspire1__Account__r.Name,inspire1__Project__r.Name,inspire1__StartDate__c from inspire1__Project_Tasks__c where inspire1__Project__r.inspire1__Account__c!=null and Name LIKE \'PSC-TAM%\' and inspire1__Project__r.inspire1__Project_Status__c IN (\'In Progress\',\'On Hold\') and inspire1__Status__c IN (\'Not Started\')';
        }
        else{
            Query='Select id,Name,inspire1__Project__c,inspire1__Project__r.inspire1__Account__r.TAM_Name_New__r.Email,inspire1__Project__r.inspire1__Account__r.TAM_Name_New__r.Manager.Email,inspire1__Project__r.inspire1__Account__r.Name,inspire1__Project__r.Name,inspire1__StartDate__c from inspire1__Project_Tasks__c where inspire1__Project__r.inspire1__Account__c!=null and Name LIKE \'PSC-TAM%\' and inspire1__StartDate__c = YESTERDAY and inspire1__Project__r.inspire1__Project_Status__c IN (\'In Progress\',\'On Hold\') and inspire1__Status__c IN (\'Not Started\')';
        }
        system.debug('Query...'+Query);
        EmailTouchpointNotStartedBatch batch=new EmailTouchpointNotStartedBatch(Query);
        Database.executeBatch(batch);
    }
}