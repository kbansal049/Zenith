trigger APTS_Opportunity_Master_trigger on Opportunity (before insert, before update, after insert, after update) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    //CR# 1332 : NFR License validation update
    //Id profileId=userinfo.getProfileId();
    //String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    //CR# 1332 : End
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skiptrigger && !TriggerUtility.isSkipOppTriggerExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Opp_Trigger') && tsmap.get('Execute_Opp_Trigger') != null && tsmap.get('Execute_Opp_Trigger').Execute__c){        
        if (trigger.isafter && trigger.isinsert && !TriggerUtility.isskipOppAfterInsertTriggerExecuted()){
           // instTrHand.onAfterInsert(trigger.new);
           OpportunityTriggerUtility.afterInsert(trigger.new);
        }
        if(trigger.isbefore && trigger.isupdate && !TriggerUtility.isskipOppBeforeUpdateTriggerExecuted()){
            //Integer countCHURN = [SELECT count() FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c IN: Trigger.new];
            Set<String> OppSubStageSet = new Set<String>();
            OppSubStageSet.add('Closed Lost');
            OppSubStageSet.add('Closed With No Decision');
            //if(!System.Label.System_Admin_Id.contains(UserInfo.getProfileId()) || Test.isRunningTest()){
                for(Opportunity opp : Trigger.new){
                    /*if(opp.Stagename == Label.Stage_7_Closed_Lost && opp.Stagename != trigger.oldMap.get(opp.Id).Stagename && !String.isblank(opp.Validation_Stage__c) && opp.Validation_Stage__c != '6 - Technical Win'  && opp.Validation_Stage__c != '7 - Technical Loss' && opp.Validation_Stage__c != '8 - Not Required' && opp.Validation_Stage__c!='0 - Not Started' && opp.Validation_Stage__c!='8B - Not Required - Preferred'){
                        opp.addError('Please choose the Technical Validation Stage value from "6 - Technical Win" or "7 - Technical Loss" or "8A - Not Required" or "8B - Not Required - Preferred"',false);
                    }
                    else */
                    
                    if(!String.isBlank(opp.Sub_Stage__c)){
                        if(!opp.Has_Technology_Partner__c && opp.Stagename != trigger.oldMap.get(opp.Id).Stagename && opp.Stagename == Label.Stage_7_Closed_Lost && System.Label.Stages_for_Loss_Form.contains(opp.Sub_Stage__c) && !System.FeatureManagement.checkPermission('Ops_Team_ByPass') && 
                            !System.Label.Profile_System_Administrator.contains(userInfo.getProfileId()) && System.Label.Profile_Finance_Id != userInfo.getProfileId() && System.Label.Profile_Core_Sales_DealDesk != opp.CurrentUserProfile__c && System.Label.Profile_Core_Sales_Sales_Ops != opp.CurrentUserProfile__c && 
                            (System.Label.Profile_Core_Sales_Renewals != opp.CurrentUserProfile__c || (System.Label.Profile_Core_Sales_Renewals == opp.CurrentUserProfile__c && opp.Split_Type__c == System.Label.Renewal_Upsell_Split))){
                            
                                if(!Test.isRunningTest())
                                opp.addError(System.Label.Primary_Technology_Partner_Validation_Message);
                        }else if(!System.Label.Profile_System_Administrator.contains(userInfo.getProfileId()) && ((opp.Stagename == Label.Stage_7_Closed_Lost && System.Label.Stages_for_Loss_Form.contains(opp.Sub_Stage__c) && opp.isChurnpresent__c == false && opp.Stagename != trigger.oldMap.get(opp.Id).Stagename && System.Label.Skip_Churn_And_Loss != 'Yes' && !String.isblank(opp.Validation_Stage__c) && opp.Validation_Stage__c != '0 - Not Started') || (System.Label.Skip_Churn_And_Loss != 'Yes' && opp.isChurnpresent__c == false && opp.Stagename == Label.Stage_7_Closed_Lost && OppSubStageSet.contains(opp.Sub_Stage__c) && opp.Type=='Existing Customer (Renewal)') && opp.Stagename != trigger.oldMap.get(opp.Id).Stagename)){ // Added condition as part of CR# 946:Gurjinder, Modified by Swathi CR1356 
                            //if(!Test.isRunningTest()){
                                //Priyanka : CR# 1325 - Added params to URL to read them in VF page
                                //opp.addError('The opportunity cannot be set to closed set without completing the opportunity loss form. <a href=\''+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/OppLossReasonFormPage?oppId='+opp.Id+'&subStage='+opp.Sub_Stage__c+'&technicalValStage='+opp.Validation_Stage__c+'&userProfile='+opp.CurrentUserProfile__c+'&splitType='+opp.Split_Type__c+'\'>Click here</a> to complete the form.', false);
                                //CR# 2850 This alert is now rendered through a VF Page OppLossFormErrorAlert as 
                                //the errors are not working correctly in lightning
                                opp.Reason_form_check__c=true;
                                if(opp.Sub_Stage__c == 'Closed Lost'){
                                    opp.Render_Substage_churn_form__c = true;
                                }
                                else if (opp.Sub_Stage__c == 'Closed With No Decision'){
                                    opp.Render_Substage_churn_form__c = false;
                                }
                                opp.Stagename = trigger.oldMap.get(opp.Id).Stagename;
                                opp.Sub_Stage__c = trigger.oldMap.get(opp.Id).Sub_Stage__c;
                                
                            //}
                        }
                    }
                }
            //}
        }
        if (trigger.isbefore && trigger.isinsert && !TriggerUtility.isskipOppBeforeInsertTriggerExecuted()){
           // instTrHand.onBeforeInsert(trigger.new);
           system.debug('1122 Opportunity before insert');
           OpportunityTriggerUtility.beforeInsert(trigger.new);
        }
        if (trigger.isbefore && trigger.isupdate && !TriggerUtility.isskipOppBeforeUpdateTriggerExecuted()){
            //instTrHand.onBeforeUpdate(trigger.new,trigger.oldmap);
            system.debug('here it is');
            OpportunityTriggerUtility.beforeUpdate(trigger.new, trigger.newMap, trigger.oldMap);
        }
        if (trigger.isafter && trigger.isupdate && !TriggerUtility.isskipOppAfterUpdateTriggerExecuted()){
          // instTrHand.autoreneOpportunity(trigger.new,trigger.oldmap);
          //  instTrHand.onAfterUpdate(trigger.new,trigger.oldmap);
            OpportunityTriggerUtility.afterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
}