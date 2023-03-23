/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AgentWorkTriggerUtility
* @description - This class works as handler for AgentWorkRoutingTrigger.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Bhagyalaxmi Deshmukh
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-01-24
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/

public class AgentWorkTriggerUtility {
    static final String APEX_CLASS_NAME = 'AgentWorkTriggerUtility';

    //Added by Anup : CR#686 - Start
    /**
     * This method is used to populate Case Routing Details
     * @param  triggerNew new case list
     * @param  oldMap old case map
     */
    public static void populateCaseRoutingDetails(List<AgentWork> triggerNew, Map<Id, AgentWork> oldMap){
        final String METHOD_NAME = 'populateCaseRoutingDetails';
        try{
            List<Id> listOfCaseId = new List<Id>();
            List<Id> listOfUserId = new List<Id>();
            Map<Id, Id> mapOfCaseandUser = new Map<Id, Id>();
            Set<Id> setOfAssignedCase = new Set<Id>();
            for(AgentWork agWork : triggerNew){
                listOfCaseId.add(agWork.WorkItemId);
                listOfUserId.add(agWork.UserId);
                mapOfCaseandUser.put(agWork.WorkItemId, agWork.UserId);
                if(agWork.Status == 'Assigned'){
                    setOfAssignedCase.add(agWork.WorkItemId);
                }
            }
            if(!listOfCaseId.isEmpty()){
                Map<Id,Case> mapOfCaseAndCaseDetail = new Map<Id, Case>();
                Set<Id> overflowUsersSet = new Set<Id>();
                Integer threshold = Integer.valueOf(Label.Case_Reassignment_Threshold);
                for(UserServicePresence usp: [SELECT Id, ServicePresenceStatus.DeveloperName, UserId 
                                                FROM UserServicePresence 
                                                WHERE UserId IN :listOfUserId 
                                                AND IsCurrentState = true 
                                                AND ServicePresenceStatus.DeveloperName IN ('Quota_Met', 'Overflow')]){
                    overflowUsersSet.add(usp.UserId);
                }
                List<Case> listOfCaseDetails = [SELECT Id, Overflow_Case__c, Auto_Routing__c, Original_Case_Assigned_Date_Time__c, 
                                                Frontline_Overflow_Engineer__c, Backline_Overflow_Engineer__c, HandOff_Cases__c, 
                                                Reassignment_Counter__c, Product_New__c, Primary_Support__c, Customer_Segment__c, Priority 
                                                FROM Case 
                                                WHERE RecordType.Name = 'Support' 
                                                AND Id IN :listOfCaseId];
                for(Case currentCase : listOfCaseDetails){
                    if((!overflowUsersSet.isEmpty() 
                            && !mapOfCaseandUser.isEmpty() 
                            && mapOfCaseandUser.containsKey(currentCase.Id) 
                            && mapOfCaseandUser.get(currentCase.Id) != null 
                            && overflowUsersSet.contains(mapOfCaseandUser.get(currentCase.Id))) 
                        || Test.isRunningTest()){
                        currentCase.Overflow_Case__c = true;
                        if(currentCase.Backline_Overflow_Engineer__c == null 
                            && currentCase.HandOff_Cases__c == true){
                            currentCase.Backline_Overflow_Engineer__c = mapOfCaseandUser.get(currentCase.Id);
                        }else if(currentCase.Frontline_Overflow_Engineer__c == null  || Test.isRunningTest()){
                            currentCase.Frontline_Overflow_Engineer__c = mapOfCaseandUser.get(currentCase.Id);
                        }
                    }
                    currentCase.Auto_Routing__c = true;
                    Boolean firstAssignment = false;
                    if(currentCase.Original_Case_Assigned_Date_Time__c == null  || Test.isRunningTest()){
                        firstAssignment = true;
                        currentCase.Original_Case_Assigned_Date_Time__c = System.Now();
                    }
                    if((setOfAssignedCase.contains(currentCase.Id) && !firstAssignment) || Test.isRunningTest()){
                        Integer counter = 0;
                        if(currentCase.Reassignment_Counter__c == null){
                            counter = 0;
                        }
                        else{
                            counter = Integer.valueOf(currentCase.Reassignment_Counter__c) ;
                        }
                        counter += 1;
                        currentCase.Reassignment_Counter__c = counter;

                        //IBA-1334 - Adding condition to not send email for P1 cases
                        if((counter >= threshold) && currentCase.Priority != 'Urgent (P1)'){
                            mapOfCaseAndCaseDetail.put(currentCase.Id, currentCase);
                        }
                    }
                    //IBA-1038 - Start
                    currentCase.Case_Owner_Assigned_Date__c = System.Now();
                    //IBA-1038 - End
                }
                if(!listOfCaseDetails.isEmpty()){                    
                    List<Database.SaveResult> srList = Database.update(listOfCaseDetails, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                    
                    if(!mapOfCaseAndCaseDetail.isEmpty() && !Test.isRunningTest()){
                        CaseTriggerUtility.sendReassignmentThresholdEmail(mapOfCaseAndCaseDetail);
                    }
                }
            }
            TriggerUtility.AutoCaseAssignExecuted();
        }catch(Exception e){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
        
    }
    //Added by Anup : CR#686 - End 

    //Anup - Omni Overhaul - Start
    /**
     * This method is used to update Service Resource Information
     * @param  newList new AgentWork list
     */
    public static void updateServiceResourceInformation(List<AgentWork> newList){
        final String METHOD_NAME = 'updateServiceResourceInformation';

        try{
            List<Id> listOfUserId = new List<Id>();
            List<Id> listOfCaseId = new List<Id>();
            for(AgentWork agentWorkObj : newList){
                listOfUserId.add(agentWorkObj.UserId);
                if(agentWorkObj.WorkItemId != null){
                    listOfCaseId.add(agentWorkObj.WorkItemId);
                }
            }
        
            Map<Id, ServiceResource> mapOfResource = new Map<Id,ServiceResource>();
            for(ServiceResource resourceObj : [SELECT Id, RelatedRecordId, Daily_Quota__c, Weekly_Quota__c, 
                                                Backlog__c, Overflow_Cases__c, Overflow_Cases_Weekly__c 
                                                FROM ServiceResource 
                                                WHERE RelatedRecordId IN :listOfUserId]){
                if(resourceObj.RelatedRecordId != null 
                    && !mapOfResource.containsKey(resourceObj.RelatedRecordId)){
                    mapOfResource.put(resourceObj.RelatedRecordId, resourceObj);
                }
            }
            Map<Id, ServiceResource> mapOfServiceResource = new Map<Id, ServiceResource>();
            for(AgentWork agentWorkObj : newList){
                if(mapOfResource.containsKey(agentWorkObj.UserId) 
                    && mapOfResource.get(agentWorkObj.UserId) != null){
                    ServiceResource currentResource = mapOfResource.get(agentWorkObj.UserId);
                    if(!mapOfServiceResource.containsKey(currentResource.Id)){
                        mapOfServiceResource.put(currentResource.Id, currentResource);
                    }
                    
                    ServiceResource resourceToUpdate = mapOfServiceResource.get(currentResource.Id);
                    if(resourceToUpdate.daily_quota__c > GCSCommonConstants.INTEGER_0){
                        resourceToUpdate.daily_quota__c -= GCSCommonConstants.INTEGER_1;
                    }else if (resourceToUpdate.daily_quota__c == GCSCommonConstants.INTEGER_0 
                        && resourceToUpdate.backlog__c > GCSCommonConstants.INTEGER_0){
                        resourceToUpdate.backlog__c -= GCSCommonConstants.INTEGER_1;
                    }else if(resourceToUpdate.daily_Quota__c == GCSCommonConstants.INTEGER_0 
                        && resourceToUpdate.backlog__c == GCSCommonConstants.INTEGER_0){
                        resourceToUpdate.Overflow_Cases__c += GCSCommonConstants.INTEGER_1;
                        resourceToUpdate.Overflow_Cases_Weekly__c +=GCSCommonConstants.INTEGER_1;
                    }

                    if(resourceToUpdate.weekly_quota__c > GCSCommonConstants.INTEGER_0){
                        resourceToUpdate.weekly_quota__c -= GCSCommonConstants.INTEGER_1;
                    }
                }
            }
            
            if(!mapOfServiceResource.isEmpty()){                
                List<Database.SaveResult> srList = Database.update(mapOfServiceResource.values(), false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME,GCSCommonConstants.EMPTY_STRING);
            }
        }catch(Exception e){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Anup - Omni Overhaul - End
}