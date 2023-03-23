global class updateAccountCloseCaseDate implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('updateAccountCloseCaseDate');
    global String query;
    global Id typeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Weekly_Meeting').getRecordTypeId();
    global updateAccountCloseCaseDate(){
        query = 'SELECT Id,(select id,ClosedDate from cases where ClosedDate != null and recordtypeid =: typeId order by ClosedDate desc limit 1) FROM Account';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Account> lstaccounts){
        this.zb.callExecute(lstaccounts[0]?.Id, lstaccounts.size());
        Map<Id,DateTime> mapCloseDateTime = new Map<Id,DateTime>();
        for (Account  acc: lstaccounts){
            for(Case caseVal : acc.cases){
                mapCloseDateTime.put(acc.id,caseVal.ClosedDate);
            }
        }
        
        List<Account_Extension__c> lstaccEx = [select id, name,Account__c from Account_Extension__c where Account__c in :mapCloseDateTime.KeySet()];
        System.debug('List ------  '+lstaccEx);
        for(Account_Extension__c ae : lstaccEx){
          	ae.TAM_Weekly_DateTime__c  = mapCloseDateTime.get(ae.Account__c);                
        }
        System.debug('Final list'+lstaccEx);
        if(lstaccEx.size() > 0){
            update lstaccEx;
        }        
    }
    
    global void finish(Database.BatchableContext BC){
        this.zb.callFinish(bc);
        System.debug('Finish');
    }
    
}