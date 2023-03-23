/**
* @description       : 
* Modifications Log 
* Ver   Date         Author        Modification
* 1.0   08/01/2022   Mahesh T.    To run the Batch For OppSplit RAM Update Once Focus Partner uploaded into System
**/

public class FocusPartnerOppSplitBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('FocusPartnerOppSplitBatch');
    String query;
    List<String> errorlst = new List<String>();
    
    public FocusPartnerOppSplitBatch(String query){
        if(String.isNotBlank(query)){
            this.query = query;
        }else{
            this.query = 'SELECT Id, OpportunityId, SplitOwnerId, Channel_Rep__c, Owner_Sales_Territory__c, Sales_Territory__c, Primary_Reseller__c, SE__c, Override_SE__c, Opportunity_Stage__c, CreatedDate FROM OpportunitySplit WHERE CreatedDate = THIS_YEAR';  
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<OpportunitySplit> oppSplitList){
        this.zb.callExecute(oppSplitList[0]?.Id, oppSplitList.size());
        List<OpportunitySplit> tobeUpdOpptSplitList = OpportunitySplitTriggerHelper.populateOwnerSalesTerritoryAndRAM(oppSplitList, null, false, true, true);
        if(!tobeUpdOpptSplitList.isEmpty()){
            //Update RAM value on given Oppportinity Split records.
            List<Database.SaveResult> updatedResultList = database.update(tobeUpdOpptSplitList, false);
            System.debug('777(D0D) ==>>> Final updatedResultList Size is: '+updatedResultList.size());
            System.debug('777(D1D) ==>>> Final updatedResultList val is: '+updatedResultList);
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
        this.zb.callFinish(bc);
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();

        emailMsg.setToAddresses(new List<String>{Label.BSYS_ALERT});
        if(Test.isRunningTest()){
            emailMsg.setToAddresses(new List<String>{'rsangati@zscaler.com'});
        }
        
        emailMsg.setSubject('FocusPartnerOppSplitBatch execution result(s) on ' + System.today());

        List<OrgWideEmailAddress> oweaLst = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sfdcsupport@zscaler.com'];
        if(!oweaLst.isEmpty()){
            emailMsg.setOrgWideEmailAddressId(oweaLst[0].Id);
        }else{
            emailMsg.setSenderDisplayName('Sales Ops System Administrator');
        }

        AsyncApexJob aysncJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedDate, CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = 'FocusPartnerOppSplitBatch' LIMIT 1];
        String emailBody = 'FocusPartnerOppSplitBatch execution is started on '+ aysncJob.CreatedDate +' and completed on '+ aysncJob.CompletedDate +'. In this execution, out of '+ aysncJob.TotalJobItems +' batches, it processed '+ aysncJob.JobItemsProcessed +' batches successfully and errored '+ aysncJob.NumberOfErrors +' batches.\n\n';
        if(!errorLst.isEmpty() || Test.isRunningTest()){
            emailBody += 'List of failed record ids are mentioned below.';
            for(String err : errorLst){
                emailBody += '\n' + err;
            }
        }
        emailMsg.setPlainTextBody(emailBody);
        System.debug('In FocusPartnerOppSplitBatch.finish(), emailMsg val is: '+emailMsg);
        
        //Sending an email after batch execution
        TriggerUtility.SkipEmailMessageTriggerExecured();
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMsg});
        TriggerUtility.SkipEmailMessageTriggerReset();
    }
}