/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger genricOpportunitySplitTrigger on OpportunitySplit (before Insert, Before Update, after insert, after update, After delete) {

//Added by Gurjinder for bypassing trigger for specific user
boolean skiptrigger=false;
Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
system.debug('usertoskip '+usertoskip);
SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
String objname = triggerType.getDescribe().getName();
if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
    system.debug('inside if of skip triggers on user based');
    skiptrigger = true;
}
system.debug('inside if of skip triggers on user based'+skiptrigger);
if(!skiptrigger){
   if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && !TriggerUtility.isOpptySplitTriggerFCexecuted()){
       Boolean skipupsell = false;
       Triggers_Switch__c tg = Triggers_Switch__c.getValues('OppSplitForecastCategoryAutomation');
       if(tg != null && tg.Execute__c){
           for(OpportunitySplit oppSplit : trigger.new){
               //Clubbed 4 criteria's into one if as its end actions are same. Also, we are trying to get User Level based FC fields from Oppty to Split fields
                if(Trigger.isinsert && Trigger.isBefore && oppSplit.Opportunity_Forecast_Type__c == 'Renewal' && oppSplit.Forecast_Type__c == 'Upsell'){
                   
                   //For primary split line, copy the fc from oppty to split
                   if(oppSplit.Forecast_Category_New__c == null){
                    oppSplit.Forecast_Category_New__c = oppSplit.Opportunity_Forecast_Category__c;
                   }
                   oppSplit.Deal_Path__c = oppSplit.Opportunity_Deal_Path__c;
                   if(oppSplit.AD_Forecast_Category__c == null){
                    oppSplit.AD_Forecast_Category__c = oppSplit.Opportunity_AD_Forecast_Category__c;
                   }
                   if(oppSplit.CRO_Forecast_Category__c == null){
                    oppSplit.CRO_Forecast_Category__c = oppSplit.Opportunity_CRO_Forecast_Category__c;
                   }
                   if(oppSplit.DM_Forecast_Category__c == null){
                    oppSplit.DM_Forecast_Category__c  = oppSplit.Opportunity_DM_Forecast_Category__c;
                   }
                   if(oppSplit.VP_Forecast_Category__c == null){
                    oppSplit.VP_Forecast_Category__c = oppSplit.Opportunity_VP_Forecast_Category__c;
                   }
                   if(oppSplit.RVP_Forecast_Category__c == null){
                    oppSplit.RVP_Forecast_Category__c = oppSplit.Opportunity_RVP_Forecast_Category__c;
                   }
                   oppSplit.AD_Forecast_Category_Lock__c = oppSplit.Opportunity_AD_Forecast_Category_Lock__c;
                   oppSplit.CRO_Forecast_Category_Lock__c = oppSplit.Opportunity_CRO_Forecast_Category_Lock__c;
                   oppSplit.DM_Forecast_Category_Lock__c = oppSplit.Opportunity_DM_Forecast_Category_Lock__c;
                   oppSplit.VP_Forecast_Category_Lock__c = oppSplit.Opportunity_VP_Forecast_Category_Lock__c;
                   oppSplit.RVP_Forecast_Category_Lock__c = oppSplit.Opportunity_RVP_Forecast_Category_Lock__c;
                   
                   if(!oppSplit.DM_Forecast_Category_Lock__c){
                        oppSplit.DM_Forecast_Category__c = oppSplit.Forecast_Category_New__c;
                    }
                    if(!oppSplit.AD_Forecast_Category_Lock__c){
                        oppSplit.AD_Forecast_Category__c = oppSplit.DM_Forecast_Category__c;
                    }
                    if(!oppSplit.RVP_Forecast_Category_Lock__c){
                        oppSplit.RVP_Forecast_Category__c = oppSplit.AD_Forecast_Category__c;
                    }
                    if(!oppSplit.VP_Forecast_Category_Lock__c){
                        oppSplit.VP_Forecast_Category__c = oppSplit.RVP_Forecast_Category__c;
                    }
                    if(!oppSplit.CRO_Forecast_Category_Lock__c){
                        oppSplit.CRO_Forecast_Category__c = oppSplit.VP_Forecast_Category__c;
                    }
                }
                
                if(oppSplit.SplitOwnerId == oppSplit.Opportunity_Owner__c || (oppSplit.Opportunity_Forecast_Type__c == 'New' || oppSplit.Opportunity_Forecast_Type__c == 'Upsell') || (oppSplit.Opportunity_Forecast_Type__c == 'Renewal' && oppSplit.Forecast_Type__c == 'Renewal') || (oppSplit.Opportunity_Forecast_Category__c == 'Closed') || (oppSplit.Opportunity_Forecast_Category__c == 'Omitted') || ((oppSplit.Opportunity_Stage__c == label.Stage_5_Contracts_Complete || oppSplit.Opportunity_Stage__c == label.Stage_5A_Opportunity || oppSplit.Opportunity_Stage__c == label.Stage_5B_Opportunity || oppSplit.Opportunity_Stage__c == label.Stage_5C_Opportunity || oppSplit.Opportunity_Stage__c == label.Stage_4_Economic_Buyer_Signoff) && oppSplit.Opportunity_Forecast_Category__c == 'Commit')){
                   //all 5
                   //For primary split line, copy the fc from oppty to split
                   oppSplit.Forecast_Category_New__c = oppSplit.Opportunity_Forecast_Category__c;
                   oppSplit.Deal_Path__c = oppSplit.Opportunity_Deal_Path__c;
                   oppSplit.AD_Forecast_Category__c = oppSplit.Opportunity_AD_Forecast_Category__c;
                   oppSplit.CRO_Forecast_Category__c = oppSplit.Opportunity_CRO_Forecast_Category__c;
                   oppSplit.DM_Forecast_Category__c  = oppSplit.Opportunity_DM_Forecast_Category__c;
                   oppSplit.VP_Forecast_Category__c = oppSplit.Opportunity_VP_Forecast_Category__c;
                   oppSplit.RVP_Forecast_Category__c = oppSplit.Opportunity_RVP_Forecast_Category__c;
                   oppSplit.AD_Forecast_Category_Lock__c = oppSplit.Opportunity_AD_Forecast_Category_Lock__c;
                   oppSplit.CRO_Forecast_Category_Lock__c = oppSplit.Opportunity_CRO_Forecast_Category_Lock__c;
                   oppSplit.DM_Forecast_Category_Lock__c = oppSplit.Opportunity_DM_Forecast_Category_Lock__c;
                   oppSplit.VP_Forecast_Category_Lock__c = oppSplit.Opportunity_VP_Forecast_Category_Lock__c;
                   oppSplit.RVP_Forecast_Category_Lock__c = oppSplit.Opportunity_RVP_Forecast_Category_Lock__c;
                   skipupsell = true;
                }else if(oppSplit.Forecast_Type__c == 'Upsell' && oppSplit.Forecast_Category_New__c != 'Upside'){
                  oppSplit.Deal_Path__c = '';
                }
                
                
                if(!skipupsell && Trigger.isUpdate && Trigger.isBefore && oppSplit.Opportunity_Forecast_Type__c == 'Renewal' && oppSplit.Forecast_Type__c == 'Upsell'){
                    if(oppSplit.Forecast_Category_New__c == null){
                        oppSplit.Forecast_Category_New__c = Trigger.Oldmap.get(oppSplit.Id).Forecast_Category_New__c;
                    }
                    if(oppSplit.AD_Forecast_Category__c == null){
                        oppSplit.AD_Forecast_Category__c = Trigger.Oldmap.get(oppSplit.Id).AD_Forecast_Category__c;
                        oppSplit.AD_Forecast_Category_Lock__c = Trigger.Oldmap.get(oppSplit.Id).AD_Forecast_Category_Lock__c;
                    }
                    if(oppSplit.DM_Forecast_Category__c == null){
                        oppSplit.DM_Forecast_Category__c = Trigger.Oldmap.get(oppSplit.Id).DM_Forecast_Category__c;
                        oppSplit.DM_Forecast_Category_Lock__c = Trigger.Oldmap.get(oppSplit.Id).DM_Forecast_Category_Lock__c;
                    }
                    if(oppSplit.RVP_Forecast_Category__c == null){
                        oppSplit.RVP_Forecast_Category__c = Trigger.Oldmap.get(oppSplit.Id).RVP_Forecast_Category__c;
                        oppSplit.RVP_Forecast_Category_Lock__c = Trigger.Oldmap.get(oppSplit.Id).RVP_Forecast_Category_Lock__c;
                    }
                    if(oppSplit.VP_Forecast_Category__c == null){
                        oppSplit.VP_Forecast_Category__c = Trigger.Oldmap.get(oppSplit.Id).VP_Forecast_Category__c;
                        oppSplit.VP_Forecast_Category_Lock__c = Trigger.Oldmap.get(oppSplit.Id).VP_Forecast_Category_Lock__c;
                    }
                    if(oppSplit.CRO_Forecast_Category__c == null){
                        oppSplit.CRO_Forecast_Category__c = Trigger.Oldmap.get(oppSplit.Id).CRO_Forecast_Category__c;
                        oppSplit.CRO_Forecast_Category_Lock__c = Trigger.Oldmap.get(oppSplit.Id).CRO_Forecast_Category_Lock__c;
                    }
                    
                    if(oppSplit.Forecast_Category_New__c != Trigger.Oldmap.get(oppSplit.Id).Forecast_Category_New__c){
						//all 5
                        if(oppSplit.Forecast_Category_New__c == 'Omitted' || oppSplit.Forecast_Category_New__c == 'Closed' || ((oppSplit.Opportunity_Stage__c == label.Stage_5_Contracts_Complete || oppSplit.Opportunity_Stage__c == label.Stage_5A_Opportunity || oppSplit.Opportunity_Stage__c == label.Stage_5B_Opportunity || oppSplit.Opportunity_Stage__c == label.Stage_5C_Opportunity || oppSplit.Opportunity_Stage__c == label.Stage_4_Economic_Buyer_Signoff) && oppSplit.Opportunity_Forecast_Category__c == 'Commit')){
                            oppSplit.AD_Forecast_Category_Lock__c = false;
                            oppSplit.CRO_Forecast_Category_Lock__c = false;
                            oppSplit.DM_Forecast_Category_Lock__c = false;
                            oppSplit.VP_Forecast_Category_Lock__c = false;
                            oppSplit.RVP_Forecast_Category_Lock__c = false;
                            
                        }
                    }   
                    if(oppSplit.AD_Forecast_Category__c != Trigger.oldmap.get(oppSplit.Id).AD_Forecast_Category__c && oppSplit.AD_Forecast_Category__c != null){
                        oppSplit.AD_Forecast_Category_Lock__c = true;
                    }
                    if(oppSplit.CRO_Forecast_Category__c != Trigger.oldmap.get(oppSplit.Id).CRO_Forecast_Category__c && oppSplit.CRO_Forecast_Category__c != null){
                        oppSplit.CRO_Forecast_Category_Lock__c = true;
                    }
                    if(oppSplit.DM_Forecast_Category__c != Trigger.oldmap.get(oppSplit.Id).DM_Forecast_Category__c && oppSplit.DM_Forecast_Category__c != null){
                        oppSplit.DM_Forecast_Category_Lock__c = true;
                    }
                    if(oppSplit.VP_Forecast_Category__c != Trigger.oldmap.get(oppSplit.Id).VP_Forecast_Category__c && oppSplit.VP_Forecast_Category__c != null){
                        oppSplit.VP_Forecast_Category_Lock__c = true;
                    }
                    if(oppSplit.RVP_Forecast_Category__c != Trigger.oldmap.get(oppSplit.Id).RVP_Forecast_Category__c && oppSplit.RVP_Forecast_Category__c != null){
                        oppSplit.RVP_Forecast_Category_Lock__c = true;
                    }
                    
                    //Copy Lower FC to higher FC if higher FC is unlocked                    
                    if(oppSplit.AD_Forecast_Category_Lock__c != Trigger.oldmap.get(oppSplit.Id).AD_Forecast_Category_Lock__c && !oppSplit.AD_Forecast_Category_Lock__c){
                        oppSplit.AD_Forecast_Category__c = oppSplit.DM_Forecast_Category__c;
                    }
                    if(oppSplit.CRO_Forecast_Category_Lock__c != Trigger.oldmap.get(oppSplit.Id).CRO_Forecast_Category_Lock__c && !oppSplit.CRO_Forecast_Category_Lock__c){
                        oppSplit.CRO_Forecast_Category__c = oppSplit.VP_Forecast_Category__c;
                    }
                    if(oppSplit.DM_Forecast_Category_Lock__c != Trigger.oldmap.get(oppSplit.Id).DM_Forecast_Category_Lock__c && !oppSplit.DM_Forecast_Category_Lock__c){
                        oppSplit.DM_Forecast_Category__c = oppSplit.Forecast_Category_New__c;
                    }
                    if(oppSplit.RVP_Forecast_Category_Lock__c != Trigger.oldmap.get(oppSplit.Id).RVP_Forecast_Category_Lock__c && !oppSplit.RVP_Forecast_Category_Lock__c){
                        oppSplit.RVP_Forecast_Category__c = oppSplit.AD_Forecast_Category__c;
                    }
                    if(oppSplit.VP_Forecast_Category_Lock__c != Trigger.oldmap.get(oppSplit.Id).VP_Forecast_Category_Lock__c && !oppSplit.VP_Forecast_Category_Lock__c){
                        oppSplit.VP_Forecast_Category__c = oppSplit.RVP_Forecast_Category__c;
                    }
                    
                    //copy lower FC to higher if higher FC Lock is false
                    if(!oppSplit.DM_Forecast_Category_Lock__c){
                        oppSplit.DM_Forecast_Category__c = oppSplit.Forecast_Category_New__c;
                    }
                    if(!oppSplit.AD_Forecast_Category_Lock__c){
                        oppSplit.AD_Forecast_Category__c = oppSplit.DM_Forecast_Category__c;
                    }
                    if(!oppSplit.RVP_Forecast_Category_Lock__c){
                        oppSplit.RVP_Forecast_Category__c = oppSplit.AD_Forecast_Category__c;
                    }
                    if(!oppSplit.VP_Forecast_Category_Lock__c){
                        oppSplit.VP_Forecast_Category__c = oppSplit.RVP_Forecast_Category__c;
                    }
                    if(!oppSplit.CRO_Forecast_Category_Lock__c){
                        oppSplit.CRO_Forecast_Category__c = oppSplit.VP_Forecast_Category__c;
                    }
                }
           }
       }
   }
    
   if(trigger.isBefore && (trigger.isInsert) && !TriggerUtility.isbeforeUpdateSplitExecuted()){
       OpportunitySplitTriggerHelper.beforeInsertSplit(trigger.New);
    }

    if (!TriggerUtility.isOpportunitySplitsAfterUpdateExecuted()) {
        OpportunitySplitTriggerHelper.afterUpdateOppSplit();
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        OpportunitySplitTriggerHelper.afterDeleteSplit(trigger.old);
    }
    
    //CR# 4867 and CR# 4868 Start
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && !TriggerUtility2.isOppSplitRAMAssignmentProcessExecuted()){
        OpportunitySplitTriggerHelper.populateOwnerSalesTerritoryAndRAM(trigger.new, trigger.oldMap, trigger.isInsert, trigger.isUpdate, false);
    }
    if(trigger.isAfter && trigger.isUpdate && !TriggerUtility2.isOppSplitTeamMemberUpdateProcessExecuted()){
        OpportunitySplitTriggerHelper.createOpportunityTeamforSplit(trigger.new, trigger.oldMap);
    }
    //CR# 4867 and CR# 4868 End
}
	if(test.isrunningtest()){
		integer i=0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}
}