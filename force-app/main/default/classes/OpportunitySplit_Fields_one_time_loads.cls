/*****************************************************************************************
Name: One Time Batch for OpportunitySplit
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. One Time Batch for OpportunitySplit

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           24-Sep-2019      Initial Development
2.0            Harish Gowda N       23-Dec-2022      Added Changes for Batch Monitoring Frame Work.
******************************************************************************************/

public class OpportunitySplit_Fields_one_time_loads implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('OpportunitySplit_Fields_one_time_loads');
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public string query = '';
    public string batchjobname = '';
    public boolean runRVP = false;
    public OpportunitySplit_Fields_one_time_loads(String q, boolean runRVPFCchange, String batchname){
        query = q;
        batchjobname = batchname;
        runRVP = runRVPFCchange;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callStart();
        return Database.getQueryLocator(query);
        
    }
    
    public void execute (Database.BatchableContext context, List<OpportunitySplit> opplst){
        this.zscalerBatchFrameWorkObj.callExecute(opplst[0]?.Id, opplst.size());
        Set<Id> oppIdSet = new set<Id>();
        
        list<OpportunitySplit> oppUpdateList = new list<OpportunitySplit >();
               
        for(OpportunitySplit opp: opplst){
            
            
            if(runRVP){
                opp.RVP_Forecast_Category__c = opp.AD_Forecast_Category__c;
                if(opp.Opportunity.Account.Sales_territory__r.Regional_VP__c != null){
                    opp.RVP_Forecast_Category_Lock__c = opp.AD_Forecast_Category_Lock__c;
                }
            }
            
            oppUpdateList.add(opp);
        }
        TriggerUtility.accTerritoryPatchExecuted();
        TriggerUtility.accSalesTeamExecuted();
        TriggerUtility.OpptyTriggerFCexecuted();
        TriggerUtility.oppPatchManagerAfterInsertExecuted();
        TriggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.oppPRProductionStatusUpdateExecuted();
        TriggerUtility.opportunityAccountsScreeningExecuted();
        TriggerUtility.OpportunityPartnerAdditionExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.updateOppNextStepHistoryExecuted();
        TriggerUtility.updateTechValHistoryExecuted();
        TriggerUtility.architectureHistoryExecuted();
        TriggerUtility.ERNotificationExecuted();
        TriggerUtility.updateSEManagerEmailExecuted();
        TriggerUtility.updateAccountForApprovedPZENExecuted();
        TriggerUtility.updateForecastCategoryExecuted();
        TriggerUtility.overrideACVValuesResetExecuted();
        TriggerUtility.OpptySplitTriggerFCexecuted();
        TriggerUtility.beforeUpdateSplitExecuted();
        TriggerUtility.splitOwnerterritory_UpdateExecuted();
        TriggerUtility.opportunitySplitsAfterUpdateExecuted();
        
        Database.SaveResult[] srList = database.update(oppUpdateList, false);
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
    
    public void finish(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callFinish(context);
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