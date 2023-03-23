public class TAMReassignmentBatch implements Database.Batchable<sObject>, Database.Stateful{
    static final String APEX_CLASS_NAME = 'TAMReassignmentBatch';
    ZscalerBatchFramework zb = new ZscalerBatchFramework('TAMReassignmentBatch');

    List<String> productsToExclude = new List<String>();
    DateTime currentTime = System.now().addminutes(Integer.valueOf(System.Label.TAM_Reassignment_Batch));
    
    List<String> listOfPriority = new List<String>{
        GCSCommonConstants.CASE_PRIORITY_HIGH, 
        GCSCommonConstants.CASE_PRIORITY_MEDIUM
    };

    List<String> listOfStatus = new List<String>{
        GCSCommonConstants.CASE_STATUS_NEW, 
        GCSCommonConstants.CASE_STATUS_REOPEN,
        GCSCommonConstants.CASE_STATUS_RESEARCHING, 
        GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER,
        GCSCommonConstants.CASE_STATUS_CUSTOMER_NOTE_ADDED, 
        GCSCommonConstants.CASE_STATUS_ESCALATED_TO_ENGINEERING
    };
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        if(String.isNotBlank(Label.TAM_Assignment_Exclusion_Products)){
            productsToExclude = Label.TAM_Reassignment_Excluded_Products.trim().split(';');
        }
        String query = 'SELECT Id, Prior_Owner__c, Case_Owner_Assigned_Date__c, TAM_Assignment__c, Case_TAM_Assignment__c,' 
                        + ' Is_TAM_Account__c, TAM_Reassignment__c, Internal_Escalation__c, Status, Next_TAM_Date__c, Product_New__c,' 
                        + ' OwnerId, No_of_TAM_Reassignment_Attempts__c,Account.TAM_Name_New__c, Account.Secondary_TAM_Name__c, Account.X3rd_TAM_Name__c' 
                        + ' FROM Case ' 
                        + ' WHERE RecordType.DeveloperName = \'Support\'' 
                        + ' AND Priority IN :listOfPriority' 
                        + ' AND Status IN :listOfStatus' 
                        + ' AND Product_New__c NOT IN :productsToExclude' 
                        + ' AND Is_TAM_Account__c = true' 
                        + ' AND TAM_Reassignment__c = false' 
                        + ' AND TAM_Assignment__c = \'Assigned To Support\'' 
                        + ' AND Internal_Escalation__c = false' 
                        + ' AND Next_TAM_Date__c < :currentTime';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case> scope){
        final String METHOD_NAME = 'execute';
        this.zb.callExecute(scope[0]?.Id, scope.size());
        try {
            Set<Id> listOfCaseToProcess = new Set<Id>();
            List<Case> casesToUpdate = new List<Case>();
            Map<Id, Id> mapOfCaseAndTAM = new Map<Id, Id>();
            Map<String, ServiceResource> tamServiceResMap = new Map<String, ServiceResource>();
            for(Case currentCase : scope){
                listOfCaseToProcess.add(currentCase.Id);
                if(String.isNotBlank(currentCase.Account.TAM_Name_New__c)) {
                    tamServiceResMap.put(currentCase.Account.TAM_Name_New__c, new ServiceResource());
                }
                if(String.isNotBlank(currentCase.Account.Secondary_TAM_Name__c)) {
                    tamServiceResMap.put(currentCase.Account.Secondary_TAM_Name__c, new ServiceResource());
                }
                if(String.isNotBlank(currentCase.Account.X3rd_TAM_Name__c)) {
                    tamServiceResMap.put(currentCase.Account.X3rd_TAM_Name__c, new ServiceResource());
                } 
            }
            if(!tamServiceResMap.isEmpty()) {
                for(ServiceResource sr : [SELECT id, relatedRecordId, returning_date__c, Out_Of_Office__c FROM ServiceResource WHERE relatedRecordId IN :tamServiceResMap.keySet()]) {
                    tamServiceResMap.put(sr.relatedRecordId, sr);
                }
            }
            if(!listOfCaseToProcess.isEmpty()){
                Map<String, Timezone_Region_Mapping__c> timeRegionMap = Timezone_Region_Mapping__c.getAll();
                for(Case currentCase : [SELECT Id, OwnerId, Preferred_Contact_Time_Zone__c, AccountId, 
                                        Account.TAM_Name_New__c, Account.Secondary_TAM_Name__c, Account.X3rd_TAM_Name__c, 
                                        Account.TAM_Name_New__r.TimeZoneSidKey, Account.Secondary_TAM_Name__r.TimeZoneSidKey, Account.X3rd_TAM_Name__r.TimeZoneSidKey, 
                                        Account.TAM_Name_New__r.Out_Of_Office__c, Account.Secondary_TAM_Name__r.Out_Of_Office__c, Account.X3rd_TAM_Name__r.Out_Of_Office__c, 
                                        Account.TAM_Name_New__r.Returning_Date__c, Account.Secondary_TAM_Name__r.Returning_Date__c, Account.X3rd_TAM_Name__r.Returning_Date__c 
                                        FROM Case 
                                        WHERE Id IN :listOfCaseToProcess]){
                    if(currentCase.AccountId != null 
                        && currentCase.Account.TAM_Name_New__c != null 
                        && (currentCase.Preferred_Contact_Time_Zone__c == null 
                            || (timeRegionMap.containsKey(currentCase.Preferred_Contact_Time_Zone__c) 
                                && timeRegionMap.containsKey(currentCase.Account.TAM_Name_New__r.TimeZoneSidKey) 
                                && timeRegionMap.get(currentCase.Preferred_Contact_Time_Zone__c).Region__c == timeRegionMap.get(currentCase.Account.TAM_Name_New__r.TimeZoneSidKey).Region__c)) 
                        && tamServiceResMap.containsKey(currentCase.Account.TAM_Name_New__c) &&  !tamServiceResMap.get(currentCase.Account.TAM_Name_New__c).Out_Of_Office__c 
                        && (tamServiceResMap.get(currentCase.Account.TAM_Name_New__c).Returning_Date__c == null 
                            || (tamServiceResMap.get(currentCase.Account.TAM_Name_New__c).Returning_Date__c != null 
                                && tamServiceResMap.get(currentCase.Account.TAM_Name_New__c).Returning_Date__c.daysBetween(Date.Today()) >= 2))){
                        mapOfCaseAndTAM.put(currentCase.Id, currentCase.Account.TAM_Name_New__c);
                        continue;
                    }
                    if(currentCase.AccountId != null 
                        && currentCase.Account.Secondary_TAM_Name__c != null 
                        && (currentCase.Preferred_Contact_Time_Zone__c == null 
                            || (timeRegionMap.containsKey(currentCase.Preferred_Contact_Time_Zone__c) 
                                && timeRegionMap.containsKey(currentCase.Account.Secondary_TAM_Name__r.TimeZoneSidKey) 
                                && timeRegionMap.get(currentCase.Preferred_Contact_Time_Zone__c).Region__c == timeRegionMap.get(currentCase.Account.Secondary_TAM_Name__r.TimeZoneSidKey).Region__c)) 
                        && tamServiceResMap.containsKey(currentCase.Account.Secondary_TAM_Name__c) &&  !tamServiceResMap.get(currentCase.Account.Secondary_TAM_Name__c).Out_Of_Office__c 
                        && (tamServiceResMap.get(currentCase.Account.Secondary_TAM_Name__c).Returning_Date__c == null 
                            || (tamServiceResMap.get(currentCase.Account.Secondary_TAM_Name__c).Returning_Date__c != null 
                                && tamServiceResMap.get(currentCase.Account.Secondary_TAM_Name__c).Returning_Date__c.daysBetween(Date.Today()) >= 2))){
                        mapOfCaseAndTAM.put(currentCase.Id, currentCase.Account.Secondary_TAM_Name__c);
                        continue;
                    }
                    if(currentCase.AccountId != null 
                        && currentCase.Account.X3rd_TAM_Name__c != null 
                        && (currentCase.Preferred_Contact_Time_Zone__c == null 
                            || (timeRegionMap.containsKey(currentCase.Preferred_Contact_Time_Zone__c) 
                                && timeRegionMap.containsKey(currentCase.Account.X3rd_TAM_Name__r.TimeZoneSidKey) 
                                && timeRegionMap.get(currentCase.Preferred_Contact_Time_Zone__c).Region__c == timeRegionMap.get(currentCase.Account.X3rd_TAM_Name__r.TimeZoneSidKey).Region__c)) 
                        && tamServiceResMap.containsKey(currentCase.Account.X3rd_TAM_Name__c) &&  !tamServiceResMap.get(currentCase.Account.X3rd_TAM_Name__c).Out_Of_Office__c 
                        && (tamServiceResMap.get(currentCase.Account.X3rd_TAM_Name__c).Returning_Date__c == null 
                            || (tamServiceResMap.get(currentCase.Account.X3rd_TAM_Name__c).Returning_Date__c != null 
                                && tamServiceResMap.get(currentCase.Account.X3rd_TAM_Name__c).Returning_Date__c.daysBetween(Date.Today()) >= 2))){
                        mapOfCaseAndTAM.put(currentCase.Id, currentCase.Account.X3rd_TAM_Name__c);
                        continue;
                    }
                }

                for(Case cs : scope){
                    if(mapOfCaseAndTAM.containsKey(cs.Id) && mapOfCaseAndTAM.get(cs.Id) != null){
                        if(cs.OwnerId != mapOfCaseAndTAM.get(cs.Id)){
                            if(String.valueOf(cs.Ownerid).startsWith('005')){
                                cs.Prior_Owner__c = cs.OwnerId;
                            }
                            cs.Case_Owner_Assigned_Date__c = System.now();
                            cs.OwnerId = mapOfCaseAndTAM.get(cs.Id); 
                        }
                        cs.Case_TAM_Assignment__c = 'Reassignment';
                        cs.TAM_Assignment__c = 'Assigned To TAM';
                    }
                    else if(!mapOfCaseAndTAM.containsKey(cs.Id) && listOfCaseToProcess.contains(cs.Id)){
                        cs.TAM_Assignment__c = 'Assigned To Support';
                        Decimal currentCount = cs.No_of_TAM_Reassignment_Attempts__c;
                        cs.No_of_TAM_Reassignment_Attempts__c = currentCount + 1;
                        if(cs.No_Of_TAM_Reassignment_Attempts__c < 2){
                            DateTime nextTamDate = cs.Next_TAM_Date__c != null ? cs.Next_TAM_Date__c : System.now();
                            String addingHours = Label.TAM_Reassignment_Reschedule_Hours;
                            if(!String.isBlank(addingHours) && addingHours.isNumeric()){
                                Integer addHours = Integer.valueOf(addingHours);
                                cs.Next_TAM_Date__c = nextTamDate.addHours(addHours);
                            }else{
                                cs.Next_TAM_Date__c = nextTamDate.addHours(12);
                            }  
                        }else{
                            cs.TAM_Reassignment__c = true;
                        }
                    }
                    casesToUpdate.add(cs);
                }
            }
            if(!casesToUpdate.isEmpty()){
                List<Database.SaveResult> updateResultList = Database.update(casesToUpdate, false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
        } catch (Exception ex) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }
    }
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
    }
}