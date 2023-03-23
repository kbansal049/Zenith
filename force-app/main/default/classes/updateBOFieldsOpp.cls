public class updateBOFieldsOpp implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('updateBOFieldsOpp');
    public string query;
    
    public updateBOFieldsOpp(String query){
        this.query = query;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Account> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        
        try{
            List<Opportunity> lstOpp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN: scope];
            Map<Id,Opportunity> extOppMap = new Map<Id,Opportunity>();
            for(Opportunity opp: lstOpp){
                //updated by Ayush Kangar: CR# 2583 Start
                if(extOppMap.containsKey(opp.Id)){
                    extOppMap.put(opp.Id,opp);    					
                }else{
                    extOppMap.put(opp.Id,opp);
                }
                //updated by Ayush Kangar: CR# 2583 End
            }
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            Id trailId1 = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            Id trailId2 = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud Details').getRecordTypeId();
            List<Id> trailRecordTypeIds = new List<Id>();
            trailRecordTypeIds.add(trailId1);
            trailRecordTypeIds.add(trailId2);
            //updated by Ayush Kangar: CR# 2583 Start
            List<AggregateResult> maxDates = [Select WhatId, MAX(StartDateTime) from Event where WhatId IN: extOppMap.keySet() AND StartDateTime < TODAY GROUP BY WhatId];		
            List<AggregateResult> minDates = [Select WhatId, MIN(StartDateTime) from Event where WhatId IN: extOppMap.keySet() AND StartDateTime > TODAY GROUP BY WhatId];		
            List<AggregateResult> countActivity = [Select WhatId, COUNT(Id) from Event where WhatId IN: extOppMap.keySet() AND StartDateTime = LAST_N_DAYS:60 GROUP BY WhatId];
            //updated by Ayush Kangar: CR# 2583 End
            List<AggregateResult> countPR = [Select Account__c, Count(Id) from Provisioning_Request__c where Eval_Extended_End_Date__c > TODAY AND RecordTypeId IN: trailRecordTypeIds AND Account__c IN: scope GROUP BY Account__c];
            
            Set<id> MaxId = new Set<id>();
            for(AggregateResult result : maxDates){
                //updated by Ayush Kangar: CR# 2583 Start
                Id oppId = String.valueOf(result.get('WhatId'));
                if(oppId != null && extOppMap.containsKey(oppId)){
                    //updated by Ayush Kangar: CR# 2583 end
                    Opportunity opp = extOppMap.get(oppId);
                    DateTime dT = DateTime.valueOf(result.get('expr0'));
                    opp.Last_Activity_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                    oppMap.put(opp.Id,opp);
                    MaxId.add(opp.Id);
                }
            }
            Set<id> minId = new Set<id>();
            for(AggregateResult result : minDates){
                //updated by Ayush Kangar: CR# 2583 Start
                Id oppId = String.valueOf(result.get('WhatId'));
                if(oppId != null && extOppMap.containsKey(oppId )){
                    //updated by Ayush Kangar: CR# 2583 end
                    Opportunity opp = extOppMap.get(oppId);
                    Opportunity tempOpp = new Opportunity();
                    if(oppMap.containsKey(opp.Id)){
                        tempOpp = oppMap.get(opp.Id);
                    }else{
                        tempOpp = opp;
                    }
                    DateTime dT = DateTime.valueOf(result.get('expr0'));
                    tempOpp.Next_Activity_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                    oppMap.put(opp.Id,tempOpp);
                    minId.add(opp.Id);
                }
            }
            Set<id> countId = new Set<id>();
            for(AggregateResult result : countActivity){
                //updated by Ayush Kangar: CR# 2583 Start
                Id oppId = String.valueOf(result.get('WhatId'));			
                if(oppId != null && extOppMap.containsKey(oppId )){	
                    //updated by Ayush Kangar: CR# 2583 end
                    Opportunity opp = extOppMap.get(oppId);
                    Opportunity tempOpp = new Opportunity();
                    if(oppMap.containsKey(opp.Id)){
                        tempOpp = oppMap.get(opp.Id);
                    }else{
                        tempOpp = opp;
                    }
                    DateTime dT = DateTime.valueOf(result.get('expr0'));
                    tempOpp.Activity_Last_60D__c = Integer.valueOf(result.get('expr0'));
                    oppMap.put(opp.Id,tempOpp);
                    countId.add(opp.Id);
                }
            }
            Map<Id, Boolean> activeTrailPR = new Map<Id, Boolean>();
            for(AggregateResult result : countPR){
                Id accId = String.valueOf(result.get('Account__c'));
                if(accId != null && Integer.valueOf(result.get('expr0')) > 0){
                    activeTrailPR.put(accId, true);
                }
            }
            for(Opportunity oppty: lstOpp){
                if(activeTrailPR.containsKey(oppty.AccountId)){
                    if(oppMap.containsKey(oppty.Id)){
                        Opportunity opp = oppMap.get(oppty.Id);
                        opp.Software_access__c = true;
                        oppMap.put(oppty.Id,opp);
                    }else{
                        Opportunity opp = new Opportunity();
                        opp.Id = oppty.Id;
                        opp.Software_access__c = true;
                        oppMap.put(oppty.Id,opp);
                    }
                }else{
                    if(oppMap.containsKey(oppty.Id)){
                        Opportunity opp = oppMap.get(oppty.Id);
                        opp.Software_access__c = false;
                        oppMap.put(oppty.Id,opp);
                    }else{
                        Opportunity opp = new Opportunity();
                        opp.Id = oppty.Id;
                        opp.Software_access__c = false;
                        oppMap.put(oppty.Id,opp);
                    }
                }
                if(extOppMap.containsKey(oppty.Id)){
                    if(oppMap.containsKey(oppty.Id)){
                        Opportunity opp = oppMap.get(oppty.Id);
                        if(!countId.contains(oppty.Id))
                            opp.Activity_Last_60D__c = Null;
                        if(!MaxId.contains(oppty.Id))
                            opp.Last_Activity_Date__c = Null;
                        if(!minId.contains(oppty.Id))
                            opp.Next_Activity_Date__c = Null;
                        oppMap.put(oppty.Id,opp);
                    }else{
                        Opportunity opp = new Opportunity();
                        opp.Id = oppty.Id;
                        if(!countId.contains(oppty.Id))
                            opp.Activity_Last_60D__c = Null;
                        if(!MaxId.contains(oppty.Id))
                            opp.Last_Activity_Date__c = Null;
                        if(!minId.contains(oppty.Id))
                            opp.Next_Activity_Date__c = Null;
                        oppMap.put(oppty.Id,opp);
                    }
                }
            }
            if(oppMap.size() > 0){
                TriggerUtility.skipOppBeforeUpdateTriggerExecuted();
                TriggerUtility.skipOppAfterUpdateTriggerExecuted();
                TriggerUtility.realignPatch();
                TriggerUtility.fsAccountOwnerIdUpdateExecuted();
                TriggerUtility.oppPatchManagerAfterUpdateExecuted();
                TriggerUtility.updateContactRoleCountExecuted();
                TriggerUtility2.OppBeforeUpdateExecuted();
                TriggerUtility2.OppAfterUpdateExecuted();
                TriggerUtility.isopportunityfieldupdateExecuted();
                TriggerHandler.bypass('OpportunityTriggerHandler');
                update oppMap.Values();
                TriggerHandler.clearBypass('OpportunityTriggerHandler');
            }
        }
        catch(Exception e){
            ZscalerErrorLogsUtility.insertlogsForAsync('updateBOFieldsOpp', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
    }
}