/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AccountTriggerHandler
* @description    This is the Account Trigger handler class called synchronously from AccountMasterTrigger.
*                 All the methods needs to be called synchronously from the Account Trigger
*                 should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-11-08
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Chandan Panigrahy
* 2022-01-31      Added logic to handle the Federal account recordType and Type update CR# 4040
* 2022-06-06      CR# 4948
* 2022-06-30      CR# 4826
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class AccountTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        
        List<Account> newAccountList = new List<Account>();
        //CR#-4040
        List<Account> fedAccountList = new List<Account> ();
        
        for (SObject acc: Trigger.new) {            
            Account newAccount = (Account) acc;
            if(!newAccount.Is_Federal_Account_Sync__c){ //Skip all logic for Federal Accounts            
                newAccountList.add(newAccount);
            } else {
                fedAccountList.add(newAccount);
            }
            
            if(!newAccount.Is_Federal_Account_Sync__c){        //Added by Ayush Kangar as part of CR#3539
                newAccount.TriggerPatchAssignment__c = true;
            }
            //CR# 4948 start
            if(newAccount.Type == 'Technology Partner' ){
               newAccount.Partner_Level__c = 'Tier 3: Ecosystem';
            }
            //CR# 4948 end
        }
        //START moved from UpdateAccountMarketSegment, Line#51
        for(Account acc : newAccountList){
            if(!acc.Is_Federal_Account_Sync__c && acc.TriggerPatchAssignment__c){//Added by Ayush Kangar as part of CR#3539
                TriggerUtility.realignPatch();
                break;
            }
        }
        
        if (!fedAccountList.isEmpty()) {
            AccountTriggerHelper.updateFedAccountCustomerType(fedAccountList);
        }
        
        //END moved from UpdateAccountMarketSegment, Line#56
        if(!newAccountList.isEmpty() && !TriggerUtility.isSkipAccTriggerExecuted()){
            AccountTriggerHelper.UpdateDateRange(newAccountList); //moved from LinkAccountToPatch, Line#47
            
            AccountTriggerHelper.UpdateMarketSegment(newAccountList,
                                                     (Map<Id,Account>)trigger.oldMap,
                                                     trigger.isinsert,
                                                     trigger.isupdate);//moved from UpdateAccountMarketSegment, Line#66
            
            AccountTriggerHelper.AccountWorkflowOptimizationmethod(newAccountList,
                                                                   (Map<Id,Account>)trigger.oldMap,
                                                                   Trigger.isInsert, 
                                                                   Trigger.isUpdate);//moved from UpdateAccountMarketSegment, Line#203

            
            if(!TriggerUtility.isAccTerritoryPatchexecuted()){//moved from UpdateAccountMarketSegment, Line#75
                //Added by Ayush Kangar as part of CR#3539 - Start
                List<Account> nonFederalAccountList = new List<Account>();
                for(Account acc: newAccountList){
                    if(!acc.Is_Federal_Account_Sync__c){
                        nonFederalAccountList.add(acc);
                    }  
                }
                AccountSalesTerritoryAndContactPatch.setAccountSalesTerritory(nonFederalAccountList);
                //Added by Ayush Kangar as part of CR#3539 - End
            }
            
            if(!TriggerUtility.isAccSalesTeamExecuted()){//moved from UpdateAccountMarketSegment, Line#79
                //Added by Ayush Kangar as part of CR#3539 - Start
                List<Account> nonFederalAccountList = new List<Account>();
                for(Account acc: newAccountList){
                    if(!acc.Is_Federal_Account_Sync__c){
                        nonFederalAccountList.add(acc);
                    }  
                }
                AccountTriggerHelper.getAccSalesTeam(nonFederalAccountList, (Map<Id,Account>)trigger.oldMap);
                //Added by Ayush Kangar as part of CR#3539 - End                
            }
            
            /**START BELOW IS REPEATED IN BEFORE UPDATE METHOD, CAN BE MOVED TO SINGLE METHOD**/
            //START moved from UpdateAccountMarketSegment, Line#84
            //Added to update Customer Success Stage on Account: Gurjinder :Start
            List <ByPassTriggerForSpecifiedUser__c> bypasstrigger = ByPassTriggerForSpecifiedUser__c.getAll().values();
            Map<String, ByPassTriggerForSpecifiedUser__c> triggersMap= new Map<String, ByPassTriggerForSpecifiedUser__c>();
            boolean bypassflag=false;
            if(!bypasstrigger.isempty() && bypasstrigger.size()>0){
                for(ByPassTriggerForSpecifiedUser__c objbypass: bypasstrigger) {
                    triggersMap.put(objbypass.User_Name__c ,objbypass);
                }
            }
            
            if(triggersMap!= null && 
               triggersMap.containsKey(UserInfo.getUserName()) && 
               triggersMap.get(UserInfo.getUserName()).bypass_component__c==TRUE){        
                ByPassTriggerForSpecifiedUser__c objbypass = triggersMap.get(UserInfo.getUserName());
                if(objbypass.User_Name__c==UserInfo.getUserName() && objbypass.bypass_component__c==TRUE)      
                {             
                    bypassflag=true;
                }else{
                }
            }
            if(!bypassflag && 
               !TriggerUtility.CustomerSuccessUpdatemethodexecuted() && 
               !TriggerUtility.isPatchRealigning()){
                if(OnOffSwitch__c.getInstance('updateCSMfieldonAccount')!=null && 
                   OnOffSwitch__c.getInstance('updateCSMfieldonAccount').Deactivate_Component__c!=null && 
                   OnOffSwitch__c.getInstance('updateCSMfieldonAccount').Deactivate_Component__c==False){
                    AccountTriggerHelper.UpdateCustomerSuccessStage(newAccountList,(Map<Id,Account>)trigger.oldMap);
                }
            }
            
            if(trigger.isbefore && (trigger.isInsert || trigger.isUpdate) && !TriggerUtility2.issetPartnerDiscountExecuted()){
                AccountTriggerHelper.updatePartnerDiscounts(newAccountList,(Map<Id,Account>)trigger.oldMap);
            }
            //Added to update Customer Success Stage on Account: Gurjinder :End
            //END moved from UpdateAccountMarketSegment, Line#117
            /**END BELOW IS REPEATED IN BEFORE UPDATE METHOD, CAN BE MOVED TO SINGLE METHOD**/
                        
            //START moved from UpdateAccountMarketSegment, Line#122
            AccountTriggerHelper obj = new AccountTriggerHelper();
            obj.updateCustomerSupportStage(newAccountList);
            if(!TriggerUtility.isProspectUpdateExecuted()){
                obj.updateProspectTypeOnAccount(newAccountList);
            }
            //END moved from UpdateAccountMarketSegment, Line#126
        }
        //Updating country code and state code for account
        if(!newAccountList.isEmpty()){
            AccountTriggerHelper.setCountryStateCodeOnAccount(newAccountList);}
        
        updateSyncToPlanhat(null,Trigger.new);
        
    }
    
    public override void beforeUpdate(){        
        
        
        Map<Id, Account> newAccountMap = new Map<Id,Account>();
        Map<Id, Account> oldAccountMap = new Map<Id,Account>();
        Map<Id, Account> fedOldAccountMap = new Map<Id,Account>();
        
        //CR# 4040
        List<Account> fedAccountList = new List<Account> ();
        
        for (SObject acc: Trigger.new) {
            Account newAccount = (Account) acc;
            Account oldAccount = (Account) Trigger.oldMap.get(newAccount.Id);
            if(!newAccount.Is_Federal_Account_Sync__c){ //Skip all logic for Federal Accounts
                
                //This commented as AccountWorkflowOptimizationmethod was not getting called
                //if(!ManageRecursive.processedAccountIds.contains(newAccount.Id) || qualifiedUpdate(newAccount, oldAccount)){
                newAccountMap.put(newAccount.Id, newAccount);
                oldAccountMap.put(oldAccount.Id, oldAccount);                
                //}
                
                //START moved from LinkAccountToPatch, Line#77
                if(!newAccount.Is_Federal_Account_Sync__c &&
                   !PatchRuleEngineStarter.isInPipeline(newAccount.Id))//Added by Ayush Kangar as part of CR#3539
                {
                    PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(newAccount);
                    PatchDataModel.MatchTarget oldTarget = new PatchDataModel.MatchTarget(oldAccount);
                    if(!target.isSameTarget(oldTarget))
                    {
                        //newAccount.TriggerPatchAssignment__c = true;//To avoid loop from Async Trigger
                    }
                }
                //END moved from LinkAccountToPatch, Line#86
            } else {
                
                fedAccountList.add(newAccount);
                fedOldAccountMap.put(oldAccount.Id, oldAccount);
                
            }
        }
        
        
        //START moved from UpdateAccountMarketSegment, Line#45
        for(Account acc : newAccountMap.values()){
            if(!acc.Is_Federal_Account_Sync__c && acc.TriggerPatchAssignment__c && 
               acc.TriggerPatchAssignment__c != oldAccountMap.get(acc.Id).TriggerPatchAssignment__c){//Added by Ayush Kangar as part of CR#3539
                TriggerUtility.realignPatch();
                break;
            }
        }

        if (!fedAccountList.isEmpty()) {
            AccountTriggerHelper.updateFedAccountCustomerType(fedAccountList);
            
            //Start  IBA-4825
            AccountTriggerUpdateCls accInstance = AccountTriggerUpdateCls.getInstance();
            accInstance.populateRAMEmail(fedAccountList,fedOldAccountMap);
            //End IBA-4825
        }

        //END moved from UpdateAccountMarketSegment, Line#50
        if(!newAccountMap.isEmpty()){
            
            AccountTriggerHelper.UpdateDateRange(newAccountMap.values(), oldAccountMap);//moved from LinkAccountToPatch, Line#50
            
            if(!TriggerUtility.UpdatingMarketsegmentforEMEAExecuted()){
                AccountTriggerHelper.UpdateMarketSegment(newAccountMap.values(),
                                                         oldAccountMap,
                                                         trigger.isinsert,
                                                         trigger.isupdate);//moved from UpdateAccountMarketSegment, Line#70
            }
            AccountTriggerHelper.AccountWorkflowOptimizationmethod(newAccountMap.values(),
                                                                   oldAccountMap,
                                                                   Trigger.isInsert, 
                                                                   Trigger.isUpdate);//moved from UpdateAccountMarketSegment, Line#203
            
            if(!TriggerUtility.isAccTerritoryPatchexecuted()){//moved from UpdateAccountMarketSegment, Line#75
                AccountSalesTerritoryAndContactPatch.setAccountSalesTerritory(newAccountMap.values());
            }
            
            if(!TriggerUtility.isAccSalesTeamExecuted()){//moved from UpdateAccountMarketSegment, Line#79
                AccountTriggerHelper.getAccSalesTeam(newAccountMap.values(), oldAccountMap);
            }
            
            //Start  IBA-3060
            AccountTriggerUpdateCls accInstance = AccountTriggerUpdateCls.getInstance();
            accInstance.isPartnerUpdate(newAccountMap.values());
            //End IBA-3060
            //Start  IBA-4825
            accInstance.populateRAMEmail(newAccountMap.values(),oldAccountMap);
            //End IBA-4825
            
            /**START BELOW IS REPEATED IN BEFORE INSERT METHOD, CAN BE MOVED TO SINGLE METHOD**/
            //START moved from UpdateAccountMarketSegment, Line#84
            //Added to update Customer Success Stage on Account: Gurjinder :Start
            List <ByPassTriggerForSpecifiedUser__c> bypasstrigger = ByPassTriggerForSpecifiedUser__c.getAll().values();
            Map<String, ByPassTriggerForSpecifiedUser__c> triggersMap= new Map<String, ByPassTriggerForSpecifiedUser__c>();
            boolean bypassflag=false;
            if(!bypasstrigger.isempty() && bypasstrigger.size()>0){
                for(ByPassTriggerForSpecifiedUser__c objbypass: bypasstrigger) {
                    triggersMap.put(objbypass.User_Name__c ,objbypass);
                }
            }
            
            if(triggersMap!= null && 
               triggersMap.containsKey(UserInfo.getUserName()) && 
               triggersMap.get(UserInfo.getUserName()).bypass_component__c==TRUE){        
                ByPassTriggerForSpecifiedUser__c objbypass = triggersMap.get(UserInfo.getUserName());
                if(objbypass.User_Name__c==UserInfo.getUserName() && objbypass.bypass_component__c==TRUE)      
                {             
                    bypassflag=true;
                }else{
                }
            }
            if(!bypassflag && 
               !TriggerUtility.CustomerSuccessUpdatemethodexecuted() && 
               !TriggerUtility.isPatchRealigning()){
                if(OnOffSwitch__c.getInstance('updateCSMfieldonAccount')!=null && 
                   OnOffSwitch__c.getInstance('updateCSMfieldonAccount').Deactivate_Component__c!=null && 
                   OnOffSwitch__c.getInstance('updateCSMfieldonAccount').Deactivate_Component__c==False){
                    AccountTriggerHelper.UpdateCustomerSuccessStage(newAccountMap.values(), oldAccountMap);
                }
            }
            
            // CR# 4608 START
            for (Account currentAccount : newAccountMap.values()) {
                Account oldAccount = oldAccountMap.get(currentAccount.id);
                //CR# 4839 START
                if (currentAccount.Type != oldAccount.Type && currentAccount.type == 'Ex-Customer') {
                    currentAccount.Customer_Sentiment__c = 'Lost';

                } else if ((currentAccount.Type != oldAccount.Type || currentAccount.Last_SCI_Date__c != oldAccount.Last_SCI_Date__c) && 
                    currentAccount.Type == 'Customer') {

                    // CR # 5201 START
                    Date lastMeetingDateWithTime = currentAccount.Last_SCI_Date__c != null ? Date.valueOf(currentAccount.Last_SCI_Date__c) : null; 
                    // lastMeetingDateWithTime was giving the time component as well when converting the Last_SCI_Date__c using Date.valueOf method 
                    // which was skipping one day while using daysBetween method
                    // so added the variable lastMeetingDateWithoutTime below to get the date component only using Date.newInstance method (to explicitly discard time)
                    Date lastMeetingDateWithoutTime = lastMeetingDateWithTime != null ? Date.newInstance(lastMeetingDateWithTime.year(), lastMeetingDateWithTime.month(), lastMeetingDateWithTime.day()) : null;
                    
                   	if (lastMeetingDateWithoutTime == null || lastMeetingDateWithoutTime.daysBetween(Date.today()) > 90) {
                        currentAccount.Customer_Sentiment__c = 'No Engagement';
                    } else if (lastMeetingDateWithoutTime.daysBetween(Date.today()) >= 0 && lastMeetingDateWithoutTime.daysBetween(Date.today()) <= 90 && 
                        'No Engagement'.equalsIgnoreCase(currentAccount.Customer_Sentiment__c)) {
                        currentAccount.Customer_Sentiment__c = 'Unknown';
                    }
                    // CR# 5201 END
                }
                //CR# 4839 END
            }
            // CR# 4608 END
            
            if(trigger.isbefore && (trigger.isInsert || trigger.isUpdate) && !TriggerUtility2.issetPartnerDiscountExecuted()){
                AccountTriggerHelper.updatePartnerDiscounts(newAccountMap.values(), oldAccountMap);
            }
            //Added to update Customer Success Stage on Account: Gurjinder :End
            //END moved from UpdateAccountMarketSegment, Line#117
            /**END BELOW IS REPEATED IN BEFORE INSERT METHOD, CAN BE MOVED TO SINGLE METHOD**/
            
            //START moved from UpdateAccountMarketSegment, Line#122
            AccountTriggerHelper obj = new AccountTriggerHelper();
            obj.updateCustomerSupportStage(newAccountMap.values());
            if(!TriggerUtility.isProspectUpdateExecuted()){
                obj.updateProspectTypeOnAccount(newAccountMap.values());
            }
            //END moved from UpdateAccountMarketSegment, Line#126
            
            //Updating country code and state code for account
        	AccountTriggerHelper.setCountryStateCodeOnAccount(newAccountMap.values());
        }
        updateSyncToPlanhat(Trigger.oldMap,Trigger.new);
        AccountTriggerHelper.overageOpportunityBeforeUpdate(oldAccountMap,newAccountMap.values());		//Added as part of IBA-6326
    }
    
    public override void afterInsert(){
        
        
        Map<Id, Account> newAccountMap = new Map<Id,Account>();
        List<Id> accNeedsPatchAssign = new List<Id>();
        
        for (SObject acc: Trigger.new) {
            Account newAccount = (Account) acc;
            if(!newAccount.Is_Federal_Account_Sync__c){ //Skip all logic for Federal Accounts  
                newAccountMap.put(newAccount.Id, newAccount);
            }
            
            if(!newAccount.Is_Federal_Account_Sync__c){        //Added by Ayush Kangar as part of CR#3539
                accNeedsPatchAssign.add(newAccount.Id);
            }
        }
        //START moved from LinkAccountToPatch, Line#115, Below is moved to AccountAsyncTriggerHelper
        if(!accNeedsPatchAssign.isEmpty() && !TriggerUtility.isSkipAccTriggerExecuted()){
            //PatchRuleEngineStarter starter = new PatchRuleEngineStarter(accNeedsPatchAssign);
            //starter.start();
            List<Account_Event__e> accEvts = new List<Account_Event__e>();
            for(Id accId:accNeedsPatchAssign){
                Account_Event__e accEvt = new Account_Event__e(Record_Id__c=accId, Event_Type__c='LinkAccountToPatch');
                accEvts.add(accEvt);
            }
            Eventbus.publish(accEvts);
            TriggerUtility.acctPatchManagerAfterInsertExecuted();
        }
        //END moved from LinkAccountToPatch, Line#119
        
        if(!newAccountMap.isEmpty() && !TriggerUtility.isSkipAccTriggerExecuted()){
            //START moved from LinkAccountToPatch, Line#130
            CaseCreationForAccountAndOpportunity.accountCaseCreation(newAccountMap.values());
            if(!TriggerUtility.isProspectEntitlementExecuted()){
                AccountTriggerHelper.entitlementCreationforProspect(newAccountMap.values());
            }
            //END moved from LinkAccountToPatch, Line#135
            
            //START moved from UpdateAccountMarketSegment, Line#170
            if(!TriggerUtility.isCreateCustomerScoreCardExecuted()){
                AccountTriggerHelper.CreateCustomerScoreCardrecord(newAccountMap.values());
            }
            if(!TriggerUtility.isCreateAccExtensionExecuted()){
                AccountTriggerHelper.CreateAccExtensionrecord(newAccountMap.values());
            }
            
            //Added by Viral : CR# 318
            //if(!TriggerUtility.ScreenAccountsWithAmberRoadExecuted()){
                AccountTriggerHelper.screenAccountsWithAmberRoad(newAccountMap.values());
                   
            //}
            //Added by Viral : CR# 318
            //END moved from UpdateAccountMarketSegment, Line#184

            // IBA-3258 START     
            AccountTriggerHelper.updateAuthenticatedConsumptionFieldsOnAccountExtension(newAccountMap.values());
            // IBA-3258 END
            
            //Account Extension History CR# 473 - Parth Doshi : START
            if(!TriggerUtility.isAccountExtensionHistoryExecuted()){//moved from UpdateAccountMarketSegment, Line#218
                AccountTriggerHelper.createAccountExtensionHistory((Map<Id,Account>) Trigger.oldMap,
                                                                   newAccountMap.values(),
                                                                   Trigger.isInsert ? TRUE : FALSE);
            }
            //Account Extension History CR# 473 - Parth Doshi : END
        }
        
        //inserting error logs for CountryStateCode on Account
        if(!newAccountMap.isEmpty()){
            AccountTriggerHelper.insertLogForCountryStateCode(newAccountMap.values());}
    }
    
    public override void afterUpdate(){
        
        List<Account> accountsCSBusinessAlignmentList = new List<Account>();
        
        List<Id> accNeedsPatchAssign = new List<Id>();
        ManageRecursive.timesAccountTriggerInvoked = ManageRecursive.timesAccountTriggerInvoked + 1;
        
        Map<Id, Account> newAccountMap = new Map<Id,Account>();
        Map<Id, Account> oldAccountMap = new Map<Id,Account>();

        Map<Id, Account> newAccountIdToAccountMap = (Map<Id, Account>) Trigger.newMap;
        Map<Id, Account> oldAccountIdToAccountMap = (Map<Id, Account>) Trigger.oldMap;

        // IBA-1931 START
        AccountTriggerHelper.updateAssociatedStudentRecords(newAccountIdToAccountMap, oldAccountIdToAccountMap);
        // IBA-1931 END

        
        // IBA-3258 START
        List<Account> newAccountListForAccountExtensionUpdate = new List<Account>();
        // IBA-3258 END
        for (SObject acc: Trigger.new) {
            Account newAccount = (Account) acc;
            Account oldAccount = (Account) Trigger.oldMap.get(newAccount.Id);
            if(!newAccount.Is_Federal_Account_Sync__c){ //Skip all logic for Federal Accounts  
                // IBA-3258 START
                if (newAccount.Avg_Estimated_Users_L90D_Vs_Purchase__c != oldAccount.Avg_Estimated_Users_L90D_Vs_Purchase__c) {
                    newAccountListForAccountExtensionUpdate.add(newAccount);
                }
                // IBA-3258 END
                if(!ManageRecursive.processedAccountIds.contains(newAccount.Id) || qualifiedUpdate(newAccount, oldAccount)){
                    
                    newAccountMap.put(newAccount.Id, newAccount);
                    oldAccountMap.put(oldAccount.Id, oldAccount);
                    
                    ManageRecursive.processedAccountIds.add(newAccount.Id);
                    
                }
                //START moved from LinkAccountToPatch, Line#99
                if(!newAccount.Is_Federal_Account_Sync__c && !PatchRuleEngineStarter.isInPipeline(newAccount.Id))//Added by Ayush Kangar as part of CR#3539
                {
                    PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(newAccount);
                    PatchDataModel.MatchTarget oldTarget = new PatchDataModel.MatchTarget(oldAccount);
                    if(newAccount.TriggerPatchAssignment__c || !target.isSameTarget(oldTarget))
                    {
                        accNeedsPatchAssign.add(newAccount.Id);
                    }
                }
                //END moved from LinkAccountToPatch, Line#108
				
				//Added for CR# 3178 - Start
                if(oldAccountMap.get(newAccount.Id)!=null  && oldAccountMap.get(newAccount.Id).CS_Business_Alignment__c != newAccount.CS_Business_Alignment__c){
                    accountsCSBusinessAlignmentList.add(newAccount);
                }
                //Added for CR# 3178 -End
            }
        }

        // IBA-3258 START
        AccountTriggerHelper.updateAuthenticatedConsumptionFieldsOnAccountExtension(newAccountListForAccountExtensionUpdate);
        // IBA-3258 END

        
        //START moved from LinkAccountToPatch, Line#115, Below is moved to AccountAsyncTriggerHelper
        if(!accNeedsPatchAssign.isEmpty() && !TriggerUtility.isSkipAccTriggerExecuted() && !TriggerUtility.isAcctPatchManagerAfterInsertExecuted()){
            //PatchRuleEngineStarter starter = new PatchRuleEngineStarter(accNeedsPatchAssign);
            //starter.start();
            List<Account_Event__e> accEvts = new List<Account_Event__e>();
            for(Id accId:accNeedsPatchAssign){
                Account_Event__e accEvt = new Account_Event__e(Record_Id__c=accId, Event_Type__c='LinkAccountToPatch');
                accEvts.add(accEvt);
            }
            Eventbus.publish(accEvts);
        }
        //END moved from LinkAccountToPatch, Line#119
        
        if(!newAccountMap.isEmpty() && !TriggerUtility.isSkipAccTriggerExecuted()){            
            //check added as apart of RBAC
            if(!TriggerUtility.isPatchRealigning()) {
                //Need to run when patch is realigned
                //Added by Ayush Kangar as part of CR#3539 - Start
                List<Account> nonFederalAccountList = new List<Account>();
                for(Account acc: newAccountMap.values()){
                    if(!acc.Is_Federal_Account_Sync__c){
                        nonFederalAccountList.add(acc);
                    }  
                }
                //Moved to AccountAsyncTriggerHelper
                //AccountSalesTerritoryAndContactPatch.updateContactsPatch(nonFederalAccountList, oldAccountMap);
                //Added by Ayush Kangar as part of CR#3539 - End
            }
                        
            //START moved from LinkAccountToPatch, Line#149
            if(!TriggerUtility.isPatchRealigning()) {
                //Skip these methods when patch is realigned -- Don't change anything here
                //Need to run when patch is realigned
                //Moved to AccountAsyncTriggerHelper
                //AccountTriggerHelper.changeRelatedContactsOwner(newAccountMap.values(), oldAccountMap);            
                if (!TriggerUtility.isCaptureCustomerNextStepsHistoryExecuted()) {
                    //Ignore
                    AccountTriggerHelper.captureCustomerNextStepsHistory(newAccountMap.values(), oldAccountMap);
                }            
                if (!TriggerUtility.isUpdateContractEndDateExecuted()) {
                    //Ignore
                    AccountTriggerHelper.updateContractEndDateInOpportunity(newAccountMap.values(), oldAccountMap);
                }
                
                if (!TriggerUtility.isAcctoActivityTerritoryExecuted()) {
                    //Need to run when patch is realigned. Commented by Sateesh
                    //Added by Ayush Kangar as part of CR#3539 - Start
                    List<Account> nonFederalAccountList = new List<Account>();
                    for(Account acc: newAccountMap.values()){
                        if(!acc.Is_Federal_Account_Sync__c){
                            nonFederalAccountList.add(acc);
                        }  
                    }
                    AccountTriggerHelper.updateTerritoryonActivities(nonFederalAccountList, oldAccountMap);
                    //Added by Ayush Kangar as part of CR#3539 - End
                }
            }
            //END moved from LinkAccountToPatch, Line#186
            
            //START moved from LinkAccountToPatch, Line#194
            //if account owner changes create the account team member
            AccountTriggerHelper.AAUCreateAccountTeamMember(newAccountMap.values(), oldAccountMap);
            
            if (!TriggerUtility.isupdateSENameFromAccountExecuted()) {
                //Need to run when patch is realigned
                AccountTriggerHelper.updateSENamesInOpportunity(newAccountMap.values(), oldAccountMap);
            }
            
            
            if(!TriggerUtility.isEntitlementUpdateExecuted()){
                AccountTriggerHelper.updateEntitlement(newAccountMap.values(), oldAccountMap);
            }
            
            //Added by Varun : CR# 1807: Start
            if(!TriggerUtility.isUpdateAccountExtensionCheckBoxExecuted()){
                AccountTriggerHelper.updateAccountExtensionCheckBox(newAccountMap, oldAccountMap);
            }
            //Added by Varun : CR# 1807: End
            //END moved from LinkAccountToPatch, Line#214
            
            
            //START moved from UpdateAccountMarketSegment, Line#136
            if(OnOffSwitch__c.getInstance('updateAccountExtension')!=null && OnOffSwitch__c.getInstance('updateAccountExtension').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('updateAccountExtension').Deactivate_Component__c==False){
                if(!TriggerUtility.UpdateAccountExtensionmethodExecuted()){
                    AccountTriggerHelper.UpdateAccountExtensionmethod(newAccountMap.values(), oldAccountMap);
                }
            }
            //added by tirth 
            //CR#996 : 
            
            Set<Id> accIdSet = new Set<Id> ();
            
            for (SObject acc: Trigger.new) {
                Account newAccount = (Account) acc;
                Account oldAccount = (Account) Trigger.oldMap.get(newAccount.Id);
                if ((newAccount.Type == 'Customer') && (newAccount.Type != oldAccount.Type)) {
                    accIdSet.add(acc.Id);
                }
            }
            if(!accIdSet.isEmpty()){
                if(System.isBatch() || System.isFuture()){
                    AccountTriggerHelper.UpdateCSMAccountExtenssionMethod(accIdSet);
                }else{
                    AccountTriggerHelper.UpdateCSMAccountExtenssionMethodAsync(accIdSet);
                }
            }   
            
            //Added by Viral : CR# 318
            if(!TriggerUtility.ScreenAccountsWithAmberRoadExecuted()){
                AccountTriggerHelper.screenAccountsWithAmberRoad(newAccountMap.values(), oldAccountMap);
                  
            }
            //Added by Viral : CR# 318
            //END moved from UpdateAccountMarketSegment, Line#164
        
            //Added by Pankaj  : CR# 61 : Architecture Next Steps : Start
            //Architecture Next Steps, moved from UpdateAccountMarketSegment, Line#210
            AccountTriggerHelper.updateArchitectureNextStepsHistory(oldAccountMap,newAccountMap.values());
            //Added by Pankaj  : CR# 61 : Architecture Next Steps : END
            
            //Account Extension History CR# 473 - Parth Doshi : START
            if(!TriggerUtility.isAccountExtensionHistoryExecuted()){//moved from UpdateAccountMarketSegment, Line#218
                AccountTriggerHelper.createAccountExtensionHistory(oldAccountMap,
                                                                   newAccountMap.values(),
                                                                   Trigger.isInsert ? TRUE : FALSE);
            }
            //Account Extension History CR# 473 - Parth Doshi : END
                       
			//Added for CR# 3178 - Start
			if(!TriggerUtility.isUpdateCSBusinessAlignmentExecuted()){
                //CR# 4826-Start
                Boolean skipTrigger = false;
                Skip_Triggers_User_Based__c userToSkip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
                SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
                String objname = triggerType.getDescribe().getName();
                if(objname != null && userToSkip.Id != null && userToSkip.Object_s_to_skip__c != null && userToSkip.Object_s_to_skip__c.split(';') != null && !userToSkip.Object_s_to_skip__c.split(';').isEmpty() && userToSkip.Object_s_to_skip__c.split(';').contains(objname)){
                    skipTrigger = true;
                }
                if(!skipTrigger){
                    AccountTriggerHelper.updateCSBusinessAlignment(accountsCSBusinessAlignmentList,oldAccountMap);
                }
               //CR#-4826-End 
            }
			//Added for CR# 3178 - End

            //Added for CR 2258 by Chetan-Start
            if(!TriggerUtility.updateSkipTAMReassignmentOnChildCasesExecuted()){
               
                //AccountTriggerHelper.updateSkipTAMReassignmentOnChildCases(oldAccountMap,newAccountMap.values());
            }
            //Added for CR 2258 by Chetan-Start
                       
        }   
       //inserting error logs for CountryStateCode on Account
        if(!newAccountMap.isEmpty()){
            AccountTriggerHelper.insertLogForCountryStateCode(newAccountMap.values());}
        
        //Added Ayush Kangar as part of IBA-2489 - Start
        AccountTriggerHelper.createOverageOpportunity(oldAccountIdToAccountMap,newAccountIdToAccountMap.values());
        AccountTriggerHelper.updateOverageOpportunities(oldAccountIdToAccountMap,newAccountIdToAccountMap);
        AccountTriggerHelper.createAccountExtensionHistory(oldAccountIdToAccountMap,newAccountIdToAccountMap);
        //Added Ayush Kangar as part of IBA-2489 - End
    }
    
    public override void beforeDelete(){
        
    }
    
    public override void afterDelete(){
        
    }
    
    public override void afterUndelete(){
        
    }
    
    public boolean qualifiedUpdate(Account newAccount, Account oldAccount){
        
        Boolean valChanged = false;
        
        //if( newAccount.HeadOfIT__c != oldAccount.HeadOfIT__c )
        if( (newAccount.HeadOfIT__c != oldAccount.HeadOfIT__c ) || (newAccount.Sales_Territory__c != oldAccount.Sales_Territory__c ))
        {
            valChanged = true;
        }
        return valChanged;
    }
    
    public static void updateSyncToPlanhat(Map<Id,sObject> oldAccountMap, List<sObject> newAccountList){
        for (SObject acc: newAccountList) {
            Account newAccount = (Account) acc;
            if(newAccount.Type == 'Customer'){
                if(oldAccountMap != null){
                    Account oldAccount = (Account) oldAccountMap.get(newAccount.Id);
                    if(oldAccount.Type != newAccount.Type && newAccount.Sync_to_Planhat__c != true){
                        newAccount.Sync_to_Planhat__c = true;
                    }
                }else{
                    newAccount.Sync_to_Planhat__c = true;
                }
            }
        }
    }
}