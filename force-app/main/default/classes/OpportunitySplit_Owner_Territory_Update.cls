public class OpportunitySplit_Owner_Territory_Update implements Database.Batchable<sObject>, Database.Stateful {
    
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('OpportunitySplit_Owner_Territory_Update');
    
    public String query = '';
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public OpportunitySplit_Owner_Territory_Update(String q){
        query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callStart();
        return Database.getQueryLocator(query);
        
    }
    
    public void execute (Database.BatchableContext context, List<OpportunitySplit> newSplits){
        
        this.zscalerBatchFrameWorkObj.callExecute(newSplits[0]?.Id, newSplits.size());
        
        List<OpportunitySplit> opSpliList = new List<OpportunitySplit>();
        TriggerUtility.opportunitySplitsAfterUpdateExecuted();
        TriggerUtility.revisitOpportunitySplitsSalesTerritoryExecuted();
        TriggerUtility.OpptySplitTriggerFCexecuted();
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
        
        Set<Id> userIds = new Set<Id>();
        Map<Id,Id> userIdTerritoryIdMap = new Map<Id,Id>();
        for(OpportunitySplit os: newSplits){
            userIds.add(os.SplitOwnerId);
        }
        for(PatchTeamMember__c salesTeam : [Select Id, PatchTeam__c , User__c from PatchTeamMember__c where User__c IN: userIds AND PatchTeam__r.Sales_Territory_Year__c = 'Current']){
            if (!userIdTerritoryIdMap.containsKey(salesTeam.User__c)) {
                userIdTerritoryIdMap.put(salesTeam.User__c,salesTeam.PatchTeam__c);
            }
        }
        for(OpportunitySplit os: newSplits){
            if(userIdTerritoryIdMap.containsKey(os.SplitOwnerId) && os.Owner_Sales_Territory__c != userIdTerritoryIdMap.get(os.SplitOwnerId)){
                os.Owner_Sales_Territory__c = userIdTerritoryIdMap.get(os.SplitOwnerId);
                opSpliList.add(os);
            }
        }
        //IBA-6518-Start
        Skip_Triggers_User_Based__c bypassTriggerForOpportunitySplit = new Skip_Triggers_User_Based__c(SetupOwnerId = UserInfo.getUserId(),Object_s_to_skip__c = 'OpportunitySplit',Skip_all_triggers__c = true);
        insert bypassTriggerForOpportunitySplit;
        Database.SaveResult[] srList = database.update(opSpliList, false);
        delete bypassTriggerForOpportunitySplit;
        //IBA-6518-End
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                successlst.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    errorlst.add(sr.getId() + ' - ' + err.getMessage());
                    //updated by Akash 1: CR# 5023 start
                    ZscalerErrorLogsUtility.insertlogsForAsync('OpportunitySplit_Owner_Territory_Update', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', err.getMessage(), err.getMessage(), err.getMessage());
                    //updated by Akash 1: CR# 5023 end
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
            mail1.setSubject('Opportunity Split Owner Territory Fields Update Batch Failure result');
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
            mail.setSubject('Opportunity Split Owner Territory Fields Update Batch Success result ');
            mail.setPlainTextBody('Opportunity Split Owner Territory Fields Update Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        if(!Test.isRunningTest())
            Messaging.sendEmail(messageList);
    }
}