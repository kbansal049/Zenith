public class RollupCloudIdUpdateBatch implements Database.Batchable<sObject>,Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('RollupCloudIdUpdateBatch');

    public List<Zscaler_Cloud_ID__c> cloudIDList;
    public Map<Id,String> errorMap;
    public static Boolean testClassVerify = false;
    
    public RollupCloudIdUpdateBatch (List<Zscaler_Cloud_ID__c> cloudIDList) {
        this.cloudIDList = cloudIDList;
        errorMap = new Map<Id,String>();
    }
    
    public Iterable<sObject> start(Database.BatchableContext bc) {
        this.zb.callStart();
        return cloudIDList;
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        TriggerUtility2.UpdateZscalerCloudIdTriggerExecuted();
        Database.saveresult[] srList =  Database.update(scope,false);
        integer i = 0;
        for(Database.saveresult sr: srList){
            if(!sr.isSuccess() && scope[i].id != null){
                errorMap.put(scope[i].id, sr.getErrors()[0].getMessage());
            }
            i++;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        sendConfirmationEmail();
    }  


    public void sendConfirmationEmail(){
        
        System.debug('--errorMap--'+errorMap);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {Label.BSYS_INFO});
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }else{
            mail.setsenderDisplayName('Sales Ops System Admin');
        }
        if(!errorMap.Values().isEmpty() || (testClassVerify == true && Test.isRunningTest()) ){
            mail.setSubject('RollupCloudIdUpdateBatch-Job Failed');
            Integer errMapSize = errorMap.Values().size();
            String msgbody = 'Below are the Ids of ' + errMapSize + ' account records that have failed: \n';
            for(Id s: errorMap.keySet()){ msgbody += 'Id : '+s+ ' Error Message : '+errorMap.get(s) +'\n'; }
            mail.setPlainTextBody(msgbody);
        }else if(errorMap.Values().isEmpty()){
            mail.setSubject('RollupCloudIdUpdateBatch-Job Completed ');
            mail.setPlainTextBody('RollupCloudIdUpdateBatch Job Completed');
        }
        messageList.add(mail);
        if(!Test.isRunningTest()){
            System.debug('----messageList---'+messageList);
            Messaging.sendEmail(messageList);
        }
    }    
}