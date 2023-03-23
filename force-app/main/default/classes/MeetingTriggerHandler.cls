/*

TestClass MeetingTriggerHandlerTest

*/
public class MeetingTriggerHandler {
    public static void beforeInsert(List<Meeting__c> newList){  
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_UpdateParticipants') && 
        tsmap.get('Execute_UpdateParticipants') != null && tsmap.get('Execute_UpdateParticipants').Execute__c){
            MeetingTriggerUtility.updateParticipants(newList);
       }
    }
    public static void afterInsert(List<Meeting__c> newList){
        
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(!TriggerUtility.isSkipCreateObjectiveExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Meeting_Objective_Creation') && 
           tsmap.get('Execute_Meeting_Objective_Creation') != null && tsmap.get('Execute_Meeting_Objective_Creation').Execute__c){
               MeetingTriggerUtility.createObjectivesWithMeasures(newList);
           }  
        
        /*Priyanka - Priyanka - CR# 2374 - 05/07/2021*/
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Auto_Create_ActionPlan') && 
           tsmap.get('Auto_Create_ActionPlan') != null && tsmap.get('Auto_Create_ActionPlan').Execute__c){
               MeetingTriggerUtility.createDefaultActionPlan(newList);
           } 
        
    }
    public static void beforeUpdate(List<Meeting__c> newList,Map<Id,Meeting__c> oldMap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_ValidateCompletedStatus') && 
           tsmap.get('Execute_ValidateCompletedStatus') != null && tsmap.get('Execute_ValidateCompletedStatus').Execute__c){
               MeetingTriggerUtility.validateCompletedStatus(newList,oldMap);
           } 
    }
    public static void afterUpdate(List<Meeting__c> newList, Map<Id, Meeting__c> newMap, Map<Id,Meeting__c> oldmap){
        
    }
    
    // Added by Rajesh CR# 1229 : Start
    public static void updateMeetingDateAccExt(List<Meeting__c> newList){
        Set<Id> acctIds = new Set<Id>();
        for(Meeting__c meet : newList){
            if(meet.Status__c == 'Completed'){
                acctIds.add(meet.Customer_Name__c);
            }
        }
        
        if(!acctIds.IsEmpty() && acctIds.size() > 0){
            Map<Id,Account_Extension__c> lstAccExt = new Map<Id,Account_Extension__c>([select Id, Account__c, TAM_Weekly_DateTime__c from Account_Extension__c where Account__c IN: acctIds]);
            Map<Id,Id> accVsAccExt = new Map<Id,Id>();
            for(Id accExt :lstAccExt.keySet()){
                accVsAccExt.put(lstAccExt.get(accExt).Account__c, accExt);
            }
            
            List<AggregateResult> maxMeeting = [SELECT Customer_Name__c, Max(Date_of_meeting__c) 
                                                FROM Meeting__c 
                                                WHERE Status__c = 'Completed' AND Customer_Name__c IN: acctIds
                                                GROUP BY Customer_Name__c];
            
            system.debug('Agg Result: ' + maxMeeting);
            List<Account_Extension__c> lstToUpdate = new List<Account_Extension__c>();                                          
            for(AggregateResult result : maxMeeting){
                Id accountId = String.valueOf(result.get('Customer_Name__c'));
                DateTime maxDate = DateTime.valueOf(result.get('expr0'));
                if(accVsAccExt.containsKey(accountId) && (maxDate > lstAccExt.get(accVsAccExt.get(accountId)).TAM_Weekly_DateTime__c || lstAccExt.get(accVsAccExt.get(accountId)).TAM_Weekly_DateTime__c == null)){
                    Account_Extension__c accExtToUpdate = lstAccExt.get(accVsAccExt.get(accountId)); 
                    accExtToUpdate.TAM_Weekly_DateTime__c = maxDate;
                    lstToUpdate.add(accExtToUpdate);
                }
            }
            
            if(lstToUpdate.size() > 0 && !lstToUpdate.IsEmpty()){
                update lstToUpdate;
            }
            TriggerUtility2.updateTAMMetingDateExecuted();
        }
    }
    // Added by Rajesh CR# 1229 : End
    
}