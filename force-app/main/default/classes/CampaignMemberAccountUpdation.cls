//CR# 190 
//Purpose:: If Account is empty in Campaign Member, make a update call taht will run the Processbuilder which will update the account__c field on Campaign Member
//Report :: https://zscaler--qa.my.salesforce.com/00O0g000005Zx5J -- Missing MCI
public class CampaignMemberAccountUpdation implements Database.Batchable<sObject>, Schedulable,Database.Stateful  {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CampaignMemberAccountUpdation');
    public string query = '';
    
    public CampaignMemberAccountUpdation(){ 
    }
    
    public CampaignMemberAccountUpdation(String query){
        this.query = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        String qry= null;
        if(query != null && String.isNotBlank(query)){
            qry = query;
        }else{
            qry  = 'Select ID from CampaignMember where '+
                ' Campaign.Campaign_Type__c not in (\'Non-Marketing Programs\',\'Operational\') and'+
                ' Status not in (\'Mailed\',\'Sent\',\'Mailer Sent\',\'Selected to Mail\',\'Member\',\'Default\',\'Heat\',\'On List\',\'On-List\',\'Pre Reg List\',\'Pre-Reg List\',\'Other\',\'Item Shipped\',\'Item Processing\') and'+
                ' First_Associate_Date__c = LAST_N_MONTHS:6 and '+
                ' Account__c = null and LeadId != null and lead.LeanData__Reporting_Matched_Account__c != null'; 
        }
        System.debug('---qry---'+qry);
        return Database.getQueryLocator(qry);
    }

    
    public void execute(Database.BatchableContext BC, list<CampaignMember> cmList){
        this.zb.callExecute(cmList[0]?.Id, cmList.size());
        System.debug('-cmList-'+cmList);
        if(cmList.size()>0){
            update cmList;
        }    
    }
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        System.debug('--CampaignMemberAccountUpdation Finished--');
    }
    
    
    public void execute(SchedulableContext sc) {
        CampaignMemberAccountUpdation b = null;
        if(query != null && String.isNotEmpty(query)){
            b = new CampaignMemberAccountUpdation(query); 
        }else{
            b = new CampaignMemberAccountUpdation(); 
        }
        database.executebatch(b,100);
    }
}