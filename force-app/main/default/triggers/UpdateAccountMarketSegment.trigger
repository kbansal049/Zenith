/**
* @File Name          : UpdateAccountMarketSegment.trigger
* @Description        : 
* @Author             : pranjalsingh@zscaler.com
* @Group              : 
* @Last Modified By   : pranjalsingh@zscaler.com
* @Last Modified On   : 20/5/2019, 12:31:05 PM
* @Modification Log   : 
*==============================================================================
*  Date                     Author                    Modification
*==============================================================================
*  3June,2019        Gurjinder Singh     Added logic to update Customer Success Stage on Account
**/

trigger UpdateAccountMarketSegment on Account (before insert, before update, after update,after insert)
{
    //changes added as a part of RBAC:Start
    
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
        
        if(trigger.isbefore){
            
            for(Account accRec : trigger.new){
                if(!accRec.Is_Federal_Account_Sync__c){		//Added by Ayush Kangar as part of CR#3539
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
              }
            }
            //changes added as a part of RBAC:End
            //for(Account accRec : trigger.new){
            //}
            //if(!TriggerUtility.isPatchRealigning()){
            
            system.debug(' TriggerUtility.UpdatingMarketsegmentforEMEAExecuted   '+TriggerUtility.UpdatingMarketsegmentforEMEAExecuted());
            if(trigger.isInsert){
                system.debug('in insert');
                AccountTriggerHelper.UpdateMarketSegment(trigger.new,trigger.oldMap,trigger.isinsert,trigger.isupdate);
                
            }else if(trigger.isUpdate && !TriggerUtility.UpdatingMarketsegmentforEMEAExecuted()){
                {
                    AccountTriggerHelper.UpdateMarketSegment(trigger.new,trigger.oldmap,trigger.isinsert,trigger.isupdate);
                    //TriggerUtility.UpdatingMarketsegmentforEMEAsettrue();
                }
            }
            
			if(!TriggerUtility.isAccTerritoryPatchexecuted()){
                //Added by Ayush Kangar as part of CR#3539 - Start
                List<Account> nonFederalAccountList = new List<Account>();
                for(Account acc:trigger.new){
                    if(!acc.Is_Federal_Account_Sync__c){
                        nonFederalAccountList.add(acc);
                    }  
                }
                AccountSalesTerritoryAndContactPatch.setAccountSalesTerritory(nonFederalAccountList);
                //Added by Ayush Kangar as part of CR#3539 - End
            }
            
            if(!TriggerUtility.isAccSalesTeamExecuted()){
                //Added by Ayush Kangar as part of CR#3539 - Start
                List<Account> nonFederalAccountList = new List<Account>();
                for(Account acc:trigger.new){
                    if(!acc.Is_Federal_Account_Sync__c){
                        nonFederalAccountList.add(acc);
                    }  
                }
                AccountTriggerHelper.getAccSalesTeam(nonFederalAccountList, trigger.oldMap);
                //Added by Ayush Kangar as part of CR#3539 - End
            }
            
            //if(!TriggerUtility.isPatchRealigning()){
            //Added to update Customer Success Stage on Account: Gurjinder :Start
            List <ByPassTriggerForSpecifiedUser__c> bypasstrigger = ByPassTriggerForSpecifiedUser__c.getAll().values();
            Map<String, ByPassTriggerForSpecifiedUser__c> triggersMap= new Map<String, ByPassTriggerForSpecifiedUser__c>();
            boolean bypassflag=false;
            if(!bypasstrigger.isempty() && bypasstrigger.size()>0){
                for(ByPassTriggerForSpecifiedUser__c objbypass: bypasstrigger) {
                    triggersMap.put(objbypass.User_Name__c ,objbypass);
                }
            }
            
            if(triggersMap!= null && triggersMap.containsKey(UserInfo.getUserName()) && triggersMap.get(UserInfo.getUserName()).bypass_component__c==TRUE){        
                ByPassTriggerForSpecifiedUser__c objbypass = triggersMap.get(UserInfo.getUserName());
                if(objbypass.User_Name__c==UserInfo.getUserName() && objbypass.bypass_component__c==TRUE)      
                {             
                    system.debug('bypass the logic ');
                    bypassflag=true;
                }else{
                    system.debug('execute the logic ');
                }
            }
            if(!bypassflag &&  trigger.isbefore && (trigger.isInsert || trigger.isUpdate) && !TriggerUtility.CustomerSuccessUpdatemethodexecuted() && !TriggerUtility.isPatchRealigning()){
                system.debug('passed condition 1');
                if(OnOffSwitch__c.getInstance('updateCSMfieldonAccount')!=null && OnOffSwitch__c.getInstance('updateCSMfieldonAccount').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('updateCSMfieldonAccount').Deactivate_Component__c==False){
                    system.debug('passed condition 2');
                    AccountTriggerHelper.UpdateCustomerSuccessStage(trigger.new,trigger.oldMap);
                }
            }
            
            if(trigger.isbefore && (trigger.isInsert || trigger.isUpdate) && !TriggerUtility2.issetPartnerDiscountExecuted()){
                AccountTriggerHelper.updatePartnerDiscounts(trigger.new,trigger.oldMap);
            }
            
            //}
            //Added to update Customer Success Stage on Account: Gurjinder :End
            
            //if(!TriggerUtility.isPatchRealigning()){
            //BEFORE INSERT & UPDATE - Account->ProspectType updates on related SCI and Opp stages
            if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
                AccountTriggerHelper obj = new AccountTriggerHelper();
                obj.updateCustomerSupportStage(trigger.new);
                if(!TriggerUtility.isProspectUpdateExecuted()){
                    obj.updateProspectTypeOnAccount(trigger.new);
                }
            }
            //}
        }
        
        
        if(trigger.isAfter && Trigger.isUpdate){
            system.debug('in After update event');           
            system.debug('TriggerUtility.UpdateAccountExtensionmethodExecuted()' + TriggerUtility.UpdateAccountExtensionmethodExecuted());
            if(OnOffSwitch__c.getInstance('updateAccountExtension')!=null && OnOffSwitch__c.getInstance('updateAccountExtension').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('updateAccountExtension').Deactivate_Component__c==False){
                if(!TriggerUtility.UpdateAccountExtensionmethodExecuted()){
                    AccountTriggerHelper.UpdateAccountExtensionmethod(trigger.new,trigger.oldMap);
                }
            }
            //added by tirth 
             //CR#996 : 
            if(!TriggerUtility.UpdateCSMAccountExtenssionMethodExecuted()){
               
                AccountTriggerHelper.UpdateCSMAccountExtenssionMethod(trigger.new,trigger.oldMap);
            }
            
            //Added by Anup : CR#1142 - Start
            //SendEmailtoCSM logic moved to account extension object trigger
            /*Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
            if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_AccountOwnerChange_Alert') && tsmap.get('Execute_AccountOwnerChange_Alert') != null && tsmap.get('Execute_AccountOwnerChange_Alert').Execute__c && !TriggerUtility.isAccountOwnerChangeAlertExecuted()){
                AccountTriggerHelper.SendEmailtoCSM(Trigger.new, trigger.oldMap);  
            }*/
            //Added by Anup : CR#1142 - End
        
        //Added by Viral : CR# 318
            System.debug('----ScreenAccountsWithAmberRoadExecuted---'+!TriggerUtility.ScreenAccountsWithAmberRoadExecuted());
            if(!TriggerUtility.ScreenAccountsWithAmberRoadExecuted()){
                System.debug('----ScreenAccountsWithAmberRoadExecuted--called--');
                AccountTriggerHelper.screenAccountsWithAmberRoad(trigger.new,trigger.oldMap);   
            }
            //Added by Viral : CR# 318
        }
        if(trigger.isAfter && Trigger.isInsert){
            system.debug('in After insert event'); 
            if(!TriggerUtility.isCreateCustomerScoreCardExecuted()){
                AccountTriggerHelper.CreateCustomerScoreCardrecord(trigger.new);
            }
            system.debug('TriggerUtility.isCreateAccExtensionExecuted()' + TriggerUtility.isCreateAccExtensionExecuted());
            if(!TriggerUtility.isCreateAccExtensionExecuted()){
                AccountTriggerHelper.CreateAccExtensionrecord(trigger.new);
            }
            
            System.debug('----screenAccountsWithAmberRoad----called');
            //Added by Viral : CR# 318
            //if(!TriggerUtility.ScreenAccountsWithAmberRoadExecuted()){
                AccountTriggerHelper.screenAccountsWithAmberRoad(trigger.new);   
            //}
            //Added by Viral : CR# 318
        }
        
        //Removed by Nathan : CR# 55: CTM Changes : Start
        //Added by Gurjinder : CR# 154: CTM update : Start  
        /*if(trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){  
system.debug('in After event');             
system.debug('TriggerUtility.isUpdateContactHeadfieldsExecuted()' + TriggerUtility.isUpdateContactHeadfieldsExecuted());  
if(!TriggerUtility.isUpdateContactHeadfieldsExecuted()){  
AccountTriggerHelper.UpdateContactHeadfields(trigger.new,trigger.oldMap,Trigger.isInsert , Trigger.isUpdate);  
}  
}*/  
        //Added by Gurjinder : CR# 154: CTM update : End
        //Removed by Nathan : CR# 55: CTM Changes : Start
        
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
            //system.debug('TriggerUtility.UpdateAccountExtensionmethodExecuted()' + TriggerUtility.AccountWorkflowOptimizationmethodExecuted());
            //if(!TriggerUtility.AccountWorkflowOptimizationmethodExecuted()){
            AccountTriggerHelper.AccountWorkflowOptimizationmethod(trigger.new,trigger.oldMap,Trigger.isInsert , Trigger.isUpdate);
            // }
        }
        //Added by Pankaj  : CR# 61 : Architecture Next Steps : Start
        //Architecture Next Steps
        if(trigger.isAfter && Trigger.isUpdate )
        {
            AccountTriggerHelper.updateArchitectureNextStepsHistory(trigger.oldmap,trigger.new);
        }
        
        //Added by Pankaj  : CR# 61 : Architecture Next Steps : END
        
        //Account Extension History CR# 473 - Parth Doshi : START
        if(trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
            if(!TriggerUtility.isAccountExtensionHistoryExecuted()){
                AccountTriggerHelper.createAccountExtensionHistory(Trigger.oldMap, Trigger.New, Trigger.isInsert ? TRUE : FALSE);
            }
        }
        //Account Extension History CR# 473 - Parth Doshi : END
    }
    
    if(trigger.Isbefore && (trigger.isInsert || trigger.isUpdate)){ 
        //AccountTriggerHelper.updateSalesTerritory(Trigger.New);
    }
    
}