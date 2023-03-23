public class OpportunityTriggerUtility {
    public static void beforeInsert(List<Opportunity> newList){
        APTS_OpportunityTriggerHandler instTrHand = new APTS_OpportunityTriggerHandler();
        instTrHand.handleBeforeInsert(newList);       
        OpportunityCreatorRoleHandler.before(trigger.new);
        //Added by Anup : CR#1122 - Start
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(!TriggerUtility.isQualifierRoleInsertExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_UpdateQualifierRole') && tsmap.get('Execute_UpdateQualifierRole') != null && tsmap.get('Execute_UpdateQualifierRole').Execute__c){
            OppotunityTriggerHelper.updateQualifyingSDRRole(newList,null);    
        }
        //Added by Anup : CR#1122 - End
        //Added by Swathi: CR#1926 - Start
        if(!TriggerUtility2.issetOppTechPartnerExecuted()){
            OppotunityTriggerHelper.updateOppField(newList,Null);
        }
        //Added by Swathi: CR#1926 - End
    }
    public static void afterInsert(List<Opportunity> newList){
         Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
         if(!TriggerUtility.isCreateOppExtensionExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Opportunity_Extention') && tsmap.get('Execute_Opportunity_Extention') != null && tsmap.get('Execute_Opportunity_Extention').Execute__c){
             OppotunityTriggerHelper.createOpportunityExtension(newList);//Uncommented by Chandan Panigrahy as this piece of code will create an extension record for the opportunity
        }
        //Added by Swathi: CR#1926 - Start
        if(!TriggerUtility2.issetOppRelTechPartnerExecuted()){
            OppotunityTriggerHelper.updateRelatedOppPartner(newList, null);
        }
        //Added by Swathi: CR#1926 - End
    }
    public static void beforeUpdate(List<Opportunity> newList, Map<Id, Opportunity> newMap, Map<Id,Opportunity> oldmap){
        OpportunityNOTRAHandler.beforeUpdate(oldmap, newMap);
        //Added by Anup : CR#1122 - Start
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(!TriggerUtility.isQualifierRoleUpdateExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_UpdateQualifierRole') && tsmap.get('Execute_UpdateQualifierRole') != null && tsmap.get('Execute_UpdateQualifierRole').Execute__c){
            OppotunityTriggerHelper.updateQualifyingSDRRole(newList,oldmap);    
        }
        
        if(!TriggerUtility.isOppoGotoSevenStageExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Opportunity_Stage_Seven') && tsmap.get('Execute_Opportunity_Stage_Seven') != null && tsmap.get('Execute_Opportunity_Stage_Seven').Execute__c){
            //OppotunityTriggerHelper.oppGotoStageSevenWithOutDuplicateOppName(newList, oldmap);
        }
        //Added by Anup : CR#1122 - End
        ////Added by Swathi: CR#1926 - Start
        if(!TriggerUtility2.issetOppTechPartnerExecuted()){
            OppotunityTriggerHelper.updateOppField(newList,oldmap);
        }
        //Added by Swathi: CR#1926 - End
    }
    public static void afterUpdate(List<Opportunity> newList, Map<Id, Opportunity> newMap, Map<Id,Opportunity> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        //OpportunityUpdatesContactHandler.afterUpdate(newMap, oldMap);//Logic moved to OpportunityAsyncTriggerController, CR# 3382 US-0001402 - Bikram 25th Oct 2021
        if(!TriggerUtility.isSkipQuoteNeedsRepriceExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Quote_Reprice_Logic') && tsmap.get('Execute_Quote_Reprice_Logic') != null && tsmap.get('Execute_Quote_Reprice_Logic').Execute__c){
            OppotunityTriggerHelper.updateneedsRepriceonQuote(newList, oldmap);
        }
        
        //Added by Anup : CR#1117 -Start
        if(!TriggerUtility.isUpdateRelatedOppExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_UpdateRelatedOpportunity') && tsmap.get('Execute_UpdateRelatedOpportunity') != null && tsmap.get('Execute_UpdateRelatedOpportunity').Execute__c){
            //OppotunityTriggerHelper.updateRelatedOpportunityFields(newList, oldMap);////Logic moved to OpportunityAsyncTriggerController, CR# 3382 US-0001415 - Bikram 27th Oct 2021    
        }
        //Added by Anup : CR#1117 -End
        //Added by Swathi: CR#1926 - Start
        if(!TriggerUtility2.issetOppRelTechPartnerExecuted()){
            OppotunityTriggerHelper.updateRelatedOppPartner(newList, oldMap);
        }
        //Added by Swathi: CR#1926 - End
        
        //Added by CSSCorp: 
        if(!TriggerUtility2.isOppOrderTracakerCalledExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Opportunity_OrderTracker') && tsmap.get('Execute_Opportunity_OrderTracker') != null && tsmap.get('Execute_Opportunity_OrderTracker').Execute__c){
            ordertrackerhelper.setOrderTrackersData(newMap.keySet(), newMap);    
        }
        //Added by CSSCorp:  
    }
}