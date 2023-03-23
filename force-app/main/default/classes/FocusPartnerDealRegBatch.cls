/**
* @description       : 
* Modifications Log 
* Ver   Date         Author        Modification
* 1.0   08/01/2022   Mahesh T.    To run the Batch For DealReg RAM Update for Partner Once Focus Partner uploaded into System
**/

public class FocusPartnerDealRegBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('FocusPartnerDealRegBatch');
    String query;
    List<String> errorlst = new List<String>();
    
    public FocusPartnerDealRegBatch(String query){
        this.query = query;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        this.zscalerBatchFrameWorkObj.callStart();
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Deal_Reg__c> drList){
        this.zscalerBatchFrameWorkObj.callExecute(drList[0]?.Id, drList.size());
        Set<Id> salesTerritoryIdSet = new Set<Id>();
        Set<Id> partnerAccountIdSet = new Set<Id>();
        for(Deal_Reg__c dr : drList){
            salesTerritoryIdSet.add(dr.Sales_Territory__c);
            if(dr.Partner_Account__c != null){
                if(dr.Partner_Account__r.Ultimate_Parent_Account__c != null){
                    partnerAccountIdSet.add(dr.Partner_Account__r.Ultimate_Parent_Account__c);
                }
                else{
                    partnerAccountIdSet.add(dr.Partner_Account__c);
                }
            }
        }
        
        Map<String, Id> territorySalesUserIdMap = new Map<String, Id>();
        Map<String,Id> ramIdVsFocusPartnerkeyStrMap = new Map<String, Id>();
        for(PatchTeam__c territory : [SELECT Id, 
                                        (SELECT Id, Role__c, PatchTeam__c, User__c, User__r.ManagerId FROM PatchTeamMembers__r)
                                      FROM PatchTeam__c WHERE ID IN :salesTerritoryIdSet]){
            for(PatchTeamMember__c salesTeam : territory.PatchTeamMembers__r){
                if(salesTeam.Role__c == 'Channel Manager'){
                    territorySalesUserIdMap.put(territory.id + ' - ChannelManager', salesTeam.User__c);
                }
            }
         }
        for(Focus_Partner__c fp : [  SELECT Id, Partner_Account__c, RAM__c,Sales_Territory__c FROM Focus_Partner__c WHERE Partner_Account__c IN :partnerAccountIdSet and Sales_Territory__c in :salesTerritoryIdSet ]){
          
                String fpKey = fp.Sales_Territory__c+'_'+ fp.Partner_Account__c;
                ramIdVsFocusPartnerkeyStrMap.put( fpKey, fp.RAM__c);
                System.debug('fpKey'+fpKey);
            
            
        }                              
                                      
        
        List<Deal_Reg__c> tobeUpdDRList = new List<Deal_Reg__c>();
        for(Deal_Reg__c deal : drList){
            if(deal.Partner_Type__c == 'Partner'){
                String keyStr =  deal.Sales_Territory__c+'_'+ deal.Partner_Account__c;
                Deal_Reg__c drToUpdate = new Deal_Reg__c();
                drToUpdate.Id =	deal.Id;
                if(ramIdVsFocusPartnerkeyStrMap.containskey(keyStr)){
                    drToUpdate.Channel_Manager__c = ramIdVsFocusPartnerkeyStrMap.get(keyStr);
                }else{
                    drToUpdate.Channel_Manager__c = territorySalesUserIdMap.get(deal.Sales_Territory__c + ' - ChannelManager');
                }
                tobeUpdDRList.add(drToUpdate);
            }
        }

        if(!tobeUpdDRList.isEmpty()){
            List<Database.SaveResult> updatedResultList = database.update(tobeUpdDRList, false);
            for(Database.SaveResult sr : updatedResultList){
                if(!sr.isSuccess() || Test.isRunningTest()){
                    for(Database.Error err : sr.getErrors()){
                        errorLst.add(sr.getId() + ' - ' + err);
                    }
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        this.zscalerBatchFrameWorkObj.callFinish(bc);
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();

        emailMsg.setToAddresses(new List<String>{Label.BSYS_ALERT});
        if(Test.isRunningTest()){
            emailMsg.setToAddresses(new List<String>{'rsangati@zscaler.com'});
        }
        
        emailMsg.setSubject('FocusPartnerDealRegBatch execution result(s) on ' + System.today());

        List<OrgWideEmailAddress> oweaLst = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sfdcsupport@zscaler.com'];
        if(!oweaLst.isEmpty()){
            emailMsg.setOrgWideEmailAddressId(oweaLst[0].Id);
        }else{
            emailMsg.setSenderDisplayName('Sales Ops System Administrator');
        }

        AsyncApexJob aysncJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedDate, CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = 'FocusPartnerDealRegBatch' LIMIT 1];
        String emailBody = 'FocusPartnerDealRegBatch execution is started on '+ aysncJob.CreatedDate +' and completed on '+ aysncJob.CompletedDate +'. In this execution, out of '+ aysncJob.TotalJobItems +' batches, it processed '+ aysncJob.JobItemsProcessed +' batches successfully and errored '+ aysncJob.NumberOfErrors +' batches.\n\n';
        if(!errorLst.isEmpty() || Test.isRunningTest()){
            emailBody += 'List of failed record ids are mentioned below.';
            for(String err : errorLst){
                emailBody += '\n' + err;
            }
        }
        emailMsg.setPlainTextBody(emailBody);
        System.debug('In FocusPartnerDealRegBatch.finish(), emailMsg val is: '+emailMsg);
        
        //Sending an email after batch execution
        TriggerUtility.SkipEmailMessageTriggerExecured();
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMsg});
        TriggerUtility.SkipEmailMessageTriggerReset();
    }
}