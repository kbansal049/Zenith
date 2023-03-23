/*********************************************************************************
** Class Name: QuoteCustomtrigger 
**
** Description: It's a trigger written mainly to handle the custom 
                functionalities on Quote.
**
** author     : Dilowar
*********************************************************************************/
trigger QuoteCustomtrigger on SBQQ__Quote__c (Before Insert, Before Update, After Insert, After Update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            QuotetriggerHelper.setQuoteFields(trigger.new,null);
            QuotetriggerHelper.assignRecordType(trigger.NEW);
            QuotetriggerHelper.resetApprovedSubscriptionTerm(trigger.new);
            QuotetriggerHelper.setSubscriptionProductCodes(trigger.new);
            QuotetriggerHelper.setAmendQuoteFields(trigger.new);  
            //QuotetriggerHelper.setYearWiseSplit(trigger.new,null);  
            QuotetriggerHelper.setNetSuiteInternalId(trigger.new,null);
            QuotetriggerHelper.setPartner(trigger.new);
            //added as a part of CR#3519 
            QuotetriggerHelper.setDocumentTypeFields(trigger.new,null);   
            QuotetriggerHelper.setCloudTypeField(trigger.new);
            //added as a part of CR# 3465
            //QuotetriggerHelper.setRenewalQuoteFields(trigger.new);  
            QuotetriggerHelper.psCreditValidation(trigger.new);
        }
        if(trigger.isUpdate){
            QuotetriggerHelper.setQuoteFields(trigger.new, trigger.oldMap);
            QuotetriggerHelper.assignProductCodes(trigger.new);
            QuotetriggerHelper.setApprovedSubscriptionTerm(trigger.new, trigger.oldMap);
            QuotetriggerHelper.setSubscriptionProductCodes(trigger.new);
            QuotetriggerHelper.updateRepCompImpactedOnQuote(trigger.new);
            QuotetriggerHelper.setRenewableACV(trigger.newMap, trigger.oldMap);
            //QuotetriggerHelper.setYearWiseSplit(trigger.new,trigger.oldMap);
            QuotetriggerHelper.updatePreviousRecordTypeName(trigger.new);
            QuotetriggerHelper.setQuoteACV(trigger.new);
            //commented as part of CR# 3587
            //QuotetriggerHelper.updateQuoteEndDateOnEarlyRenewal(trigger.new);
            QuotetriggerHelper.setNetSuiteInternalId(trigger.new, trigger.oldMap);
            //added as a part of CR#3519
            //QuotetriggerHelper.setDocumentTypeFields(trigger.new, trigger.oldMap);  
            //added as a part of JIRA-IBA-1279
            QuotetriggerHelper.upgradeProduct(trigger.new, trigger.oldMap);
        }
    }   
    if(trigger.isAfter){
        if(trigger.isInsert){
            QuotetriggerHelper.setPrimaryQuote(trigger.new,trigger.oldMap,true);
            QuotetriggerHelper.shareQuoteToOppTeam(trigger.new);
        }
        if(trigger.isUpdate){
            QuotetriggerHelper.setPrimaryQuote(trigger.new,trigger.oldMap,false);
            QuotetriggerHelper.updateChecboxesOnQE(trigger.newMap);
            //QuotetriggerHelper.createSplitRecords(trigger.newMap,trigger.oldMap);
            //IBA-5540 added below line
            QuotetriggerHelper.afterUpdate(trigger.new,trigger.oldMap);
        }
    }
}