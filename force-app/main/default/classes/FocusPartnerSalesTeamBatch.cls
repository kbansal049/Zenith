/**
* @description       : 
* Modifications Log 
* Ver   Date         Author        Modification
* 1.0   08/01/2022   Mahesh T.    To run the Batch Once Focus Partner uploaded into System
**/

public class FocusPartnerSalesTeamBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('FocusPartnerSalesTeamBatch');
    String query;
    List<String> errorLst = new List<String>();
    
    public FocusPartnerSalesTeamBatch(String query){
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        this.zscalerBatchFrameWorkObj.callStart();
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Focus_Partner__c> fpList){
        this.zscalerBatchFrameWorkObj.callExecute(fpList[0]?.Id, fpList.size());
        Set<Id> salesTerritoryIDSet = new Set<Id>();
        Map<Id, Focus_Partner__c> fpMap = new Map<Id, Focus_Partner__c>();
        for(Focus_Partner__c fp : fpList){
            fpMap.put(fp.Id, fp);
            salesTerritoryIDSet.add(fp.Sales_Territory__c);
        }
        
        Map<String, ID> userIDVSPatchTeamIdMap = new Map<String, ID>();
        for(PatchTeamMember__c ptm : [SELECT Id, User__c, PatchTeam__c, Role__c FROM PatchTeamMember__c WHERE PatchTeam__c = :salesTerritoryIDSet AND Role__c = 'FP Regional Alliance Manager']){
            String patchUserCombinationKey = ptm.User__c + '_' + ptm.PatchTeam__c;
            userIDVSPatchTeamIdMap.put(patchUserCombinationKey, ptm.PatchTeam__c);
        }

        List<PatchTeamMember__c> patchTeamMemLst = new List<PatchTeamMember__c>();
        for(Focus_Partner__c focusPartner : fpList){
            String keyStr = focusPartner.RAM__c + '_' + focusPartner.Sales_Territory__c;
            if(!userIDVSPatchTeamIdMap.containsKey(keyStr)){
                userIDVSPatchTeamIdMap.put(keyStr, focusPartner.Sales_Territory__c);

                PatchTeamMember__c ptm = new PatchTeamMember__c();
                ptm.Role__c = 'FP Regional Alliance Manager';
                ptm.User__c = focusPartner.RAM__c;
                ptm.PatchTeam__c = focusPartner.Sales_Territory__c;

                patchTeamMemLst.add(ptm);
            }
        }

        if(!patchTeamMemLst.isEmpty()){
            List<Database.SaveResult> insertResultList = Database.insert(patchTeamMemLst, false);
            for(Database.SaveResult sr : insertResultList){
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

        emailMsg.setSubject('FocusPartnerSalesTeamBatch execution result(s) on ' + System.today());

        List<OrgWideEmailAddress> oweaLst = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sfdcsupport@zscaler.com'];
        if(!oweaLst.isEmpty()){
            emailMsg.setOrgWideEmailAddressId(oweaLst[0].Id);
        }else{
            emailMsg.setSenderDisplayName('Sales Ops System Administrator');
        }

        AsyncApexJob aysncJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedDate, CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = 'FocusPartnerSalesTeamBatch' LIMIT 1];
        String emailBody = 'FocusPartnerSalesTeamBatch execution is started on '+ aysncJob.CreatedDate +' and completed on '+ aysncJob.CompletedDate +'. In this execution, out of '+ aysncJob.TotalJobItems +' batches, it processed '+ aysncJob.JobItemsProcessed +' batches successfully and errored '+ aysncJob.NumberOfErrors +' batches.\n\n';
        if(!errorLst.isEmpty() || Test.isRunningTest()){
            emailBody += 'List of failed record ids are mentioned below.';
            for(String err : errorLst){
                emailBody += '\n' + err;
            }
        }
        
        emailMsg.setPlainTextBody(emailBody);
        System.debug('==>>> In FocusPartnerSalesTeamBatch.finish(), emailMsg val is: '+emailMsg);
        
        //Sending an email after batch execution
        TriggerUtility.SkipEmailMessageTriggerExecured();
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMsg});
        TriggerUtility.SkipEmailMessageTriggerReset();
    }
}