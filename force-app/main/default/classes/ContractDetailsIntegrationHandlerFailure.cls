public class ContractDetailsIntegrationHandlerFailure implements Database.Batchable<sObject>, Database.Stateful{
	ZscalerBatchFramework zb = new ZscalerBatchFramework('ContractDetailsIntegrationHandlerFailure');
    public Set<Id> FailedContIntSyncIdlist = new Set<Id>();
    
    public static List<String> errorlist = new List<String>();

    public ContractDetailsIntegrationHandlerFailure(Set<Id> failedIds){
        this.FailedContIntSyncIdlist = failedIds;
    }
    
     public Database.QueryLocator start(Database.BatchableContext context){
         this.zb.callStart();
        String query = 'Select Id,name from Contract_Details_Integration_Sync__c where  Sales_Order_Internal_Id__c != null and id in : FailedContIntSyncIdlist';
        return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext context, List<Contract_Details_Integration_Sync__c> conList){
       	this.zb.callExecute(conList[0]?.Id, conList.size());
        try{
            
            if(conList.size()>0){
                MAP<Id, Contract_Details_Integration_Sync__c> updateConSyncRecorMAP = new  MAP<Id, Contract_Details_Integration_Sync__c> (conList);
                
                ContractDetailsIntegrationHandler.ContractDetailsIntegrationIDSet = updateConSyncRecorMAP.keyset();
                ContractDetailsIntegrationHandler.createContractDetails();
            }
            
        }catch(Exception ex){
            System.debug('---Exception Message--'+ex.getMessage());
            System.debug('---Exception Line--'+ex.getLineNumber());
            errorlist.add('Message -['+ex.getMessage()+'] Line -['+ex.getLineNumber()+']');
        }
        
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        System.debug('--errorlist--'+errorlist);
        
        if(!errorlist.isEmpty() || Test.isRunningTest()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(getCCEmailListFromLabel(Label.CONTARCT_DETAIL_ERROR));
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('ContractDetailsIntegrationHandlerFailure Failure result');
            String msgbody = 'Below are the Details : \n';
            for(String s: errorlist){
                msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        
        if(!Test.isRunningTest())
            Messaging.sendEmail(messageList);
		
	}
    
     public List<String> getCCEmailListFromLabel(String label){
        if(label.contains(',')){
            List<String> returnList = new list<String>();
            for(string lb : label.split(',')){
                if(lb != null && lb.trim() != '')
                    returnList.add(lb.trim());
            }
            return returnList;
        }else{
            return new String[] {label};
        }
    }
}