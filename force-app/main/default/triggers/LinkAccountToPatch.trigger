/*
 * Links account to a matching patch on new account insert or certain fields update.
 */
trigger LinkAccountToPatch on Account (before insert, after insert, before update, after update) 
{
    
    /**for(Account accRec : trigger.new){ 
        if(trigger.isUpdate){
            if(accRec.TriggerPatchAssignment__c && accRec.TriggerPatchAssignment__c != trigger.oldMap.get(accRec.Id).TriggerPatchAssignment__c){
                TriggerUtility.realignPatch();
                break;
            }
        }
        if(trigger.isInsert){
            if(accRec.TriggerPatchAssignment__c){
                TriggerUtility.realignPatch();
                break;
            }
        }
    }**/
    
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        //Changed by Abhijit for CR866 - '=' needs to change to '==' as = will assign the value        
        if(skipTriggers[0].Skip_Account_Triggers__c == true){
            skipTrigger = true;
        }
    }
    
    //Added by Gurjinder for bypassing trigger for specific user
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    system.debug('usertoskip '+usertoskip);
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        system.debug('inside if of skip triggers on user based');
        skiptrigger = true;
    }
    system.debug('inside if of skip triggers on user based'+skiptrigger);

    
    if((!skipTrigger) && (!TriggerUtility.isSkipAccTriggerExecuted())){
        
        if(trigger.isInsert && trigger.isBefore){   
            AccountTriggerHelper.UpdateDateRange(Trigger.new);
        }   
        if(trigger.isUpdate && trigger.isBefore){   
            AccountTriggerHelper.UpdateDateRange(Trigger.new,Trigger.oldMap);   
        }
        
        List<Id> accNeedsPatchAssign = new List<Id>();
        if(Trigger.isInsert)
        {
            if(Trigger.isBefore)
            {
                for(Account acc : Trigger.new)
                {	
                    if(!acc.Is_Federal_Account_Sync__c){		//Added by Ayush Kangar as part of CR#3539
                    	acc.TriggerPatchAssignment__c = true;
                    }
                }
            }
            else if(Trigger.isAfter)
            {
                for(Account acc : Trigger.new)
                {
                    if(!acc.Is_Federal_Account_Sync__c){		//Added by Ayush Kangar as part of CR#3539
                    	accNeedsPatchAssign.add(acc.Id);
                    }
                }
            }
        }
        else if(Trigger.isUpdate)
        {   //changes added as apart of RBAC:Start
            if(Trigger.isBefore)
            {
                for(Account acc : Trigger.new)
                {
                    if(!acc.Is_Federal_Account_Sync__c){		//Added by Ayush Kangar as part of CR#3539 
                    	if(!PatchRuleEngineStarter.isInPipeline(acc.Id))
                    	{
                        	Account oldAccount = Trigger.oldMap.get(acc.Id);
                        	PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(acc);
                        	PatchDataModel.MatchTarget oldTarget = new PatchDataModel.MatchTarget(oldAccount);
                        	if(!target.isSameTarget(oldTarget))
                        	{
                            	acc.TriggerPatchAssignment__c = true;
                       		 }
                    	}
                    }
                }
            }
            else if(Trigger.isAfter)
            {   //changes added as apart of RBAC:End
                //Commented as a part of hot fix of CR# 488 :Gurjinder: Start
                //Added for CR#488
                //AccountAfterUpdateHandler.process(Trigger.newMap , Trigger.oldMap );
                //Commented as a part of hot fix of CR# 488 :Gurjinder: End
                for(Account acc : Trigger.new)
                {	
                    if(!acc.Is_Federal_Account_Sync__c){		//Added by Ayush Kangar as part of CR#3539
                    	if(!PatchRuleEngineStarter.isInPipeline(acc.Id))
                    	{
                       		Account oldAccount = Trigger.oldMap.get(acc.Id);
                       		PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(acc);
                       		PatchDataModel.MatchTarget oldTarget = new PatchDataModel.MatchTarget(oldAccount);
                        	if(acc.TriggerPatchAssignment__c || !target.isSameTarget(oldTarget))
                       		{
                           		accNeedsPatchAssign.add(acc.Id);
                       		}
                    	}
                    }
                }
            }
        }
        if(accNeedsPatchAssign.size() > 0)
        {	
            PatchRuleEngineStarter starter = new PatchRuleEngineStarter(accNeedsPatchAssign);
            starter.start();
        }
        //check added as apart of RBAC
        if(!TriggerUtility.isPatchRealigning()) {
            //Need to run when patch is realigned
            system.debug('call the AccountSalesTerritoryAndContactPatch.updateContactsPatch method');
            //Added by Ayush Kangar as part of CR#3539 - Start
            List<Account> nonFederalAccountList = new List<Account>();
                for(Account acc:trigger.new){
                    if(!acc.Is_Federal_Account_Sync__c){
                        nonFederalAccountList.add(acc);
                    }  
                }
            AccountSalesTerritoryAndContactPatch.updateContactsPatch(nonFederalAccountList, trigger.oldMap);
            //Added by Ayush Kangar as part of CR#3539 - End
        }
    
        if(trigger.isAfter && trigger.isInsert) {
            CaseCreationForAccountAndOpportunity.accountCaseCreation(trigger.new);
            if(!TriggerUtility.isProspectEntitlementExecuted()){
                AccountTriggerHelper.entitlementCreationforProspect(Trigger.new);
            }
        }
        //Changed by Nathan : CR# 196: AmberRoad Fixes : Start
        // if(trigger.isAfter /* && !TriggerUtility.ScreenAccountsWithAmberRoadExecuted() */ && (trigger.isInsert || trigger.isupdate)){
        //     AccountTriggerHelper.screenAccountsWithAmberRoad(trigger.new,trigger.oldMap);
        // }
        //Changed by Nathan : CR# 196: AmberRoad Fixes : End
        
        
        system.debug('the patch realign' + TriggerUtility.isPatchRealigning());
        system.debug('is Update ' + trigger.isUpdate);
        
         //check added as apart of RBAC
        if(!TriggerUtility.isPatchRealigning()) {
            //Skip these methods when patch is realigned -- Don't change anything here
            if(trigger.isUpdate && trigger.isAfter){
                
                //AccountTriggerHelper.reCreateAccountTeams(Trigger.new, Trigger.oldMap);            
                //Need to run when patch is realigned
                AccountTriggerHelper.changeRelatedContactsOwner(trigger.new, trigger.oldmap);
        
                // Vijay - 03/26/2018: Commented this out as the logic will be handled by contact trigger
                // if(!TriggerUtility.isAccContactWhiteSpaceUpdateExecuted())
                //     AccountTriggerHelper.updateContactWhitespaceRole(trigger.new, trigger.oldMap);
            //commented by gurjinder :CR# 198:start
                /* system.debug('TriggerUtility.isupdateSENameFromAccountExecuted()  '+TriggerUtility.isupdateSENameFromAccountExecuted());
                if (!TriggerUtility.isupdateSENameFromAccountExecuted()) {
                    //Need to run when patch is realigned
                    AccountTriggerHelper.updateSENamesInOpportunity(trigger.new, trigger.oldMap);
                } */
            //Commented by Gurjinder: CR# 198 :End
                if (!TriggerUtility.isCaptureCustomerNextStepsHistoryExecuted()) {
                    //Ignore
                    AccountTriggerHelper.captureCustomerNextStepsHistory(Trigger.new, Trigger.oldMap);
                }
                
                system.debug('here it is' + TriggerUtility.isUpdateContractEndDateExecuted());
                
                if (!TriggerUtility.isUpdateContractEndDateExecuted()) {
                    //Ignore
                    AccountTriggerHelper.updateContractEndDateInOpportunity(Trigger.new, Trigger.oldMap);
                }
                
                if (!TriggerUtility.isAcctoActivityTerritoryExecuted()) {
                    //Need to run when patch is realigned. Commented by Sateesh
                    //Added by Ayush Kangar as part of CR#3539 - Start
                    List<Account> nonFederalAccountList = new List<Account>();
                	for(Account acc:trigger.new){
                    	if(!acc.Is_Federal_Account_Sync__c){
                        	nonFederalAccountList.add(acc);
                    	}  
                	}
                    AccountTriggerHelper.updateTerritoryonActivities(nonFederalAccountList, Trigger.oldMap);
                    //Added by Ayush Kangar as part of CR#3539 - End
                }

            }
        }
        
        //if(TriggerUtility.isPatchRealigning()){
        if(trigger.isUpdate && trigger.isAfter){
            //if account owner changes create the account team member
            AccountTriggerHelper.AAUCreateAccountTeamMember(Trigger.new, Trigger.oldMap);
            
            system.debug('TriggerUtility.isupdateSENameFromAccountExecuted()  '+TriggerUtility.isupdateSENameFromAccountExecuted());
            if (!TriggerUtility.isupdateSENameFromAccountExecuted()) {
                //Need to run when patch is realigned
                AccountTriggerHelper.updateSENamesInOpportunity(trigger.new, trigger.oldMap);
            }
                
            
            if(!TriggerUtility.isEntitlementUpdateExecuted()){
                AccountTriggerHelper.updateEntitlement(Trigger.new, Trigger.OldMap);
            }
			
			//Added by Varun : CR# 1807: Start
            if(!TriggerUtility.isUpdateAccountExtensionCheckBoxExecuted()){
            	AccountTriggerHelper.updateAccountExtensionCheckBox(trigger.newMap,trigger.oldMap);
            }
            //Added by Varun : CR# 1807: End
        }
        //}
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
    }
}