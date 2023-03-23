/*
 *  Author : Raghu Manchiraju 
 *  Change : Modified Code to call Push ZPA Interactive Cloud on Creation
 *  Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   NA				NA		    Initial Version
 * 2.0   25-05-2022   Mahesh T       CR# 4369
 */ 
trigger genericProvisioningRequestTrigger on Provisioning_Request__c (before insert, after insert, before update, after update, before delete, after delete) {
    
    if(ProvisioningRequestTriggerHelper.skipTrigger == false)
    {
    // Changes added by Gurjinder as part of GDPR :Start    GEO_SE_Director_Email__c, GEO_SE_Director__c
    if(trigger.isBefore){
                
        if(trigger.isInsert || trigger.isUpdate){
                      
            boolean isInsert=false;
            boolean Isupdate=false;
            boolean IsError=false;
               
            if(Trigger.isinsert){
                system.debug('trigger.isInsert event type'); 
                isInsert=true;
                Isupdate=false;
                //CR# 4395 START 4th April 2022 - Bikram AmberRoadValidation          
                AmberRoadValidation.checkPRComplianceStatusOnInsert(Trigger.new);
                //CR# 4395 END 4th April 2022 - Bikram AmberRoadValidation          
            }
            if(Trigger.Isupdate){
                system.debug('trigger.Isupdate event type'); 
                //CR# 4395 START 4th April 2022 - Bikram AmberRoadValidation          
                AmberRoadValidation.checkPRComplianceStatusOnUpdate(Trigger.new);
                //CR# 4395 END 4th April 2022 - Bikram AmberRoadValidation          
                // Changes for Force Purge button:Start
                Set<String> FinanceTeamIdSet= new Set<String>();
                
                String FinanceTeamIdString= ZscalerCustomSetting__c.getInstance('FinanceForcePurgeTeamIdSet')!=null && ZscalerCustomSetting__c.getInstance('FinanceForcePurgeTeamIdSet').Value__c!=null ? ZscalerCustomSetting__c.getInstance('FinanceForcePurgeTeamIdSet').Value__c:'00570000003LFyG';
                
                FinanceTeamIdSet.addall(FinanceTeamIdString.split(','));
                System.debug('FinanceTeamIdSet'+FinanceTeamIdSet);
                // Changes for Force Purge button:End
                
                
                // Changes for Stop Purge button:Start
                Set<String> GroupMemberIdSet = new Set<String>();
                String StopPurgeTeamIdString= ZscalerCustomSetting__c.getInstance('PRStopPurgeTeamIdSet')!=null && ZscalerCustomSetting__c.getInstance('PRStopPurgeTeamIdSet').Value__c!=null ? ZscalerCustomSetting__c.getInstance('PRStopPurgeTeamIdSet').Value__c:'00570000003LFyG';
                GroupMemberIdSet.addall(StopPurgeTeamIdString.split(','));
                System.debug('GroupMemberIdSet'+GroupMemberIdSet);
                
                /* for(GroupMember  u :[select id,UserOrGroupId,groupId,Group.DeveloperName  from GroupMember where Group.DeveloperName = 'GDPRStopPurgeAccessGroup'])
                {
                    system.debug('u    '+u);
                    GroupMemberIdSet.add(u.UserOrGroupId);
                }
                system.debug('GroupMemberIdSet'+GroupMemberIdSet); */
                // Changes for Stop Purge button:End
        
                for(Provisioning_Request__c pr : trigger.new){
                    system.debug('pr '+pr);
                    // Changes for Force Purge button:Start
                    if(pr.RunGDPRvalidations__c && pr.Provisioning_Status__c=='Awaiting Rep Confirmation' && trigger.oldMap.get(pr.id).Provisioning_Status__c!='Awaiting Rep Confirmation' && !FinanceTeamIdSet.contains(String.valueof(Userinfo.getuserid())) && !FinanceTeamIdSet.contains(String.valueof(Userinfo.getUserRoleId()))){
                        IsError=true;
                        pr.adderror('You dont have permissions to Forcefully Purge. Please Contact your Manager');
                    }
                    // Changes for Force Purge button:End
                    
                    // Changes for Stop Purge button:Start                  
                    /* if(pr.RunGDPRvalidations__c && pr.Provisioning_Status__c=='Purge Stopped' && (trigger.oldMap.get(pr.id).Provisioning_Status__c=='Decommissioned' || trigger.oldMap.get(pr.id).Provisioning_Status__c=='To Be Purged')){
                        IsError=true;
                        pr.adderror('You dont have permissions to Stop the Purge. Please Contact your Manager');
                    } */
                    if(!IsError){
                        pr.RunGDPRvalidations__c=false;
                    }
                    // Changes for Stop Purge button:End
                }               
                isInsert=false;
                Isupdate=true;
                
            }
        
            // Changes added by Gurjinder as part of Workflow Optimization :Start  
            system.debug('before calling optimization method'+IsError); 
            if(!IsError){
                ProvisioningRequestTriggerHelper.WorkflowOptimization(trigger.new,trigger.oldMap,isInsert,Isupdate);
            }           
            system.debug('after calling optimization method');  
            // Changes added by Gurjinder as part of Workflow Optimization :Start
        }
    
    }
    // Changes added by Gurjinder as part of GDPR :End
    
        if(trigger.isAfter){
            ProvisioningRequestTriggerHelper.skipTrigger = true;
            list<Opportunity> oppUpdateList = new list<Opportunity>();
            set<Id> inlineOppIdSet = new set<Id>();
            set<Id> fevaOppIdSet = new set<Id>();
            Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            Id inline2RecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud Details').getRecordTypeId();
            Id fevaRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
            Id ZPAInteractiveRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('ZPA Interactive').getRecordTypeId();
            
            if(trigger.isInsert){
                for(Provisioning_Request__c pr : trigger.new){
                    if(pr.RecordTypeId == inlineRecordTypeId && pr.Opportunity__c != null)
                        inlineOppIdSet.add(pr.Opportunity__c);               
                    if(pr.RecordTypeId == fevaRecordTypeId && pr.Opportunity__c != null)
                        fevaOppIdSet.add(pr.Opportunity__c);
                    if(pr.RecordTypeId == ZPAInteractiveRecordTypeId)
                    {
                        ProvisioningRequestTriggerHelper.sendProvisioningRequesttoZPA(pr);
                    }
                }

                //Changed by Nathan : CR# 196: AmberRoad Fixes : Start
                //Active Screen accounts against Amber Road upon insertion
                //ProvisioningRequestTriggerHelper.screenAccounts(trigger.new);
                //Changed by Nathan : CR# 196: AmberRoad Fixes : End
                if(!TriggerUtility.isPRafterInsertExecuted()){
                    ProvisioningRequestTriggerHelper.afterInsert(trigger.new);
                }
            }
            if(trigger.isUpdate){
                for(Provisioning_Request__c pr : trigger.new){
                    if((pr.RecordTypeId == inlineRecordTypeId && pr.Opportunity__c != null && pr.RecordTypeId != trigger.oldMap.get(pr.Id).RecordTypeId) || (pr.RecordTypeId == inline2RecordTypeId && pr.Opportunity__c != null && pr.RecordTypeId != trigger.oldMap.get(pr.Id).RecordTypeId))
                        inlineOppIdSet.add(pr.Opportunity__c);               
                    if(pr.RecordTypeId == fevaRecordTypeId && pr.Opportunity__c != null && pr.RecordTypeId != trigger.oldMap.get(pr.Id).RecordTypeId)
                        fevaOppIdSet.add(pr.Opportunity__c);
                }
                if(!TriggerUtility.isPRafterUpdateExecuted()){
                    ProvisioningRequestTriggerHelper.afterUpdate(trigger.new, trigger.oldMap);
                }
            }
            if(trigger.isDelete){
                for(Provisioning_Request__c pr : trigger.old){
                    if((pr.RecordTypeId == inlineRecordTypeId || pr.RecordTypeId == inline2RecordTypeId) && pr.Opportunity__c != null)
                        inlineOppIdSet.add(pr.Opportunity__c);               
                    if(pr.RecordTypeId == fevaRecordTypeId && pr.Opportunity__c != null)
                        fevaOppIdSet.add(pr.Opportunity__c);
                }
            }
            
            set<Id> oppIdSet = new set<id>();
            oppIdSet.addAll(inlineOppIdSet);
            oppIdSet.addAll(fevaOppIdSet);
            
            if(!oppIdSet.isEmpty()){
                for(Opportunity opp : [Select Id, Inline_POC__c,FEVA__c, (Select Id, RecordTypeId from Evaluations__r) from Opportunity where ID IN: oppIdSet]){
                    
                    if(opp.Evaluations__r.isEmpty()){
                        opp.Inline_POC__c = false;
                        opp.FEVA__c = false;
                        oppUpdateList.add(opp);
                    }
                    
                    boolean feva = false;
                    boolean inlinePoc = false;
                    
                    for(Provisioning_Request__c pr : opp.Evaluations__r){
                        if((pr.RecordTypeId == inlineRecordTypeId || pr.RecordTypeId == inline2RecordTypeId) && !inlinePoc){
                            inlinePoc = true;
                        }
                        if(pr.RecordTypeId == fevaRecordTypeId && !feva){
                            feva = true;
                        }
                    }
                    opp.Inline_POC__c = inlinePoc;
                    opp.FEVA__c = feva;
                    oppUpdateList.add(opp);
                    
                }
                if(!oppUpdateList.isEmpty())
                    database.update(oppUpdateList, false);
            }   
        }
    }
    //CR#4369 Case not getting created if more than one provision request created at same time.
    if(ProvisioningRequestTriggerHelper.skipTrigger == true && trigger.isAfter && trigger.isUpdate ){
        
        Map<Id, Provisioning_Request__c> newPRMap = new Map<Id,Provisioning_Request__c>();
        Map<Id, Provisioning_Request__c> oldPRMap = new Map<Id,Provisioning_Request__c>();
        
        Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
        Set<Id> prIds = new Set<Id>();
        for(Provisioning_Request__c prCase : trigger.new){    
            prIds.add(prCase.Id);
        }
        Map<Id, Provisioning_Request__c> prWithCases = new Map<Id, Provisioning_Request__c>([
            SELECT Id,(select Id from Cases__r)
            FROM Provisioning_Request__c WHERE Id = :prIds]);

        for(Provisioning_Request__c pr : trigger.new){ 
            if (prWithCases.containsKey(pr.Id)) {
                List<Case> cs = prWithCases.get(pr.Id).Cases__r;
                if (cs.isEmpty()) {
                                   
                    if(!TriggerUtility.isCaseCreationUpdatePRExecuted()  && pr.Provisioning_Status__c=='Requested' && trigger.oldMap.get(pr.id).Provisioning_Status__c!='Requested'  && pr.RecordTypeId == inlineRecordTypeId && pr.Opportunity__c != null && pr.GEO__c=='WW Commercial'){
                        
                        Provisioning_Request__c newPR = (Provisioning_Request__c) pr;
                        Provisioning_Request__c oldPR = (Provisioning_Request__c) Trigger.oldMap.get(newPR.Id);
                        
                        newPRMap.put(newPR.Id, newPR);
                        oldPRMap.put(oldPR.Id, oldPR);
                    }
                }
            }
        }
        if(newPRMap !=null){
            ProvisioningRequestTriggerHelper.createCasefromPRonUpdate(newPRMap.values(), oldPRMap);
        }
    }   
}