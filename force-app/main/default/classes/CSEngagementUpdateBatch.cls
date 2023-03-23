public class CSEngagementUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CSEngagementUpdateBatch');
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    private string query; 
    Boolean error = false;
    Set<Id> aliset = new Set<Id>();
    public CSEngagementUpdateBatch(String query){
        this.query = query;
        //'select id, type, Account_Renewable_ACV__c,(Select id, Customer_Success_Engagement__c  from Account_Extensions__r) from Account where Id IN (SELECT Account__c from Account_Extensions__c WHERE Override_CS_Engagement__c != true AND Account__r.Type = 'Customer' )'
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC,List<Account> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        List<Account_Extension__c> accExtnsToUpdate = new List<Account_Extension__c>();
        for(Account acc:scope){
            
            if(acc.Account_Renewable_ACV__c>=200000 && acc.Account_Extensions__r[0]?.Customer_Success_Engagement__c != 'high'){
                acc.Account_Extensions__r[0].Customer_Success_Engagement__c='high';
                accExtnsToUpdate.add(acc.Account_Extensions__r[0]);
            }
            else if(acc.Account_Extensions__r[0]?.Customer_Success_Engagement__c != 'tech'){
                acc.Account_Extensions__r[0].Customer_Success_Engagement__c='tech';
                accExtnsToUpdate.add(acc.Account_Extensions__r[0]);
            }
            
        }
        if(!accExtnsToUpdate.isEmpty()){
            List<Database.SaveResult> srList3 = database.update(accExtnsToUpdate, false);

            // Iterate through each returned result
            for(Database.SaveResult dr : srList3) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(''+dr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        errorlst.add(dr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        System.debug('errorlst'+errorlst);
        }
            
        
          

    }
    
    public void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
    }
}