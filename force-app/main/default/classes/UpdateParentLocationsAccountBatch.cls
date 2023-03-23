//Added by Abhijit for CR1001
global class UpdateParentLocationsAccountBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateParentLocationsAccountBatch');
    String batchSoql;
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();  
    public string batchjobname = 'Parent Locations Update Job - UpdateParentLocationsAccountBatch'; 

    public UpdateParentLocationsAccountBatch(String soql){
        batchSoql = soql;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        return Database.getQueryLocator(batchSoql);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        List<Monthly_Policy_Configurations__c> cList = [select id, Parent_Location__c, Account__c from Monthly_Policy_Configurations__c where Account__c in: scope and Monthly_Config_Date__c = THIS_MONTH order by Account__c];//new List<Monthly_Policy_Configurations__c>();
        Map<Id, Decimal> accountLocationMap = new Map<Id, Decimal>();
        
        for(Monthly_Policy_Configurations__c mpc: cList){
            if(!accountLocationMap.containsKey(mpc.Account__c)){
                if(mpc.Parent_Location__c != null){
                    accountLocationMap.put(mpc.Account__c, mpc.Parent_Location__c );                
                }else{
                    accountLocationMap.put(mpc.Account__c, 0 );                
                }

            }else{
                if(mpc.Parent_Location__c != null){
                    accountLocationMap.put(mpc.Account__c, accountLocationMap.get(mpc.Account__c) + mpc.Parent_Location__c);                
                }
            }
            
        }

        List<Customer_Score_Card__c> scoreCards = [select id, No_of_Parent_Location__c, Account__c from Customer_Score_Card__c where Account__c in: accountLocationMap.keySet()];
        for(Customer_Score_Card__c scoreCard: scoreCards){
               scoreCard.No_of_Parent_Location__c = accountLocationMap.get(scoreCard.Account__c);            
        }
        
        system.debug('bbbbbbb - ' + scoreCards);

       Database.SaveResult[] srList = database.update(scoreCards, false);
       for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                successlst.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    errorlst.add(sr.getId() + ' - ' + err.getMessage());
                }
            }
        } 
    } 

    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject(batchjobname + ' Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){
                msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(!successlst.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject(batchjobname + ' Batch Success result ');
            mail.setPlainTextBody(batchjobname + ' Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);        
    }    
}