public class CoupaCampaignBatch implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CoupaCampaignBatch');

    public Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        String query = '';
        if(Test.isRunningTest()){
            query = 'Select ID,Name from campaign where status != null and status not in (\'Completed\',\'Canceled\',\'Cancelled\',\'Aborted\') and Coupa_Integration_Status__c = null and CreatedDate >= LAST_N_YEARS:2  limit 1';
        }else{
            query = 'Select ID,Name from campaign where status != null and status not in (\'Completed\',\'Canceled\',\'Cancelled\',\'Aborted\') and Coupa_Integration_Status__c = null and CreatedDate >= LAST_N_YEARS:2';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Campaign> records){
        this.zb.callExecute(records[0]?.Id, records.size());
        for(Campaign camp : records){
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            CoupaCampaignController pc = new CoupaCampaignController(sc);
            try{
                pc.callCoupaIntegraion();
            }catch(exception ex){
                System.debug('-Exception Occured-');
                System.debug('-ex line-'+ex.getLineNumber());
                System.debug('-ex message-'+ex.getMessage());
                System.debug('-ex-'+ex.getStackTraceString());
            }
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        System.debug('--CoupaCampaignBatch--finished');
    }
}