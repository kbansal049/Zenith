global class ColdTransferQueueProcessBatch implements Database.Batchable<sObject>, Database.stateful{
    static final String APEX_CLASS_NAME = 'ColdTransferQueueProcessBatch';
    ZscalerBatchFramework zb = new ZscalerBatchFramework('ColdTransferQueueProcessBatch');

    String query;
    Id handOffQueueId;
    List<String> errorCaseId = new List<String>();
    Map<String, List<Integer>> mapOfSlotAndHour = new Map<String, List<Integer>>();

    global ColdTransferQueueProcessBatch() {
        List<TAC_Time_Slot_Hour_Mapping__mdt> timeSlotMapping = TAC_Time_Slot_Hour_Mapping__mdt.getAll().values();
        for(TAC_Time_Slot_Hour_Mapping__mdt tsl : timeSlotMapping){
            List<Integer> hoursList = new List<Integer>();
            hoursList.add(Integer.valueOf(tsl.Start_Hour__c));
            hoursList.add(Integer.valueOf(tsl.End_Hour__c));
            mapOfSlotAndHour.put(tsl.Contact_Time_Slot__c, hoursList);
        }
        handOffQueueId = [SELECT Id FROM Group where type = 'Queue' and DeveloperName = 'Cold_Transfer_Queue'].Id;
        this.query = 'SELECT Id, AccountId, OwnerId,Case_Type__c, Contact_Time_Slot__c, Warm_Handoff__c, Primary_Support__c,' 
                        + ' Secondary_Support__c, Escalation_Support__c, Priority_Support__c, Product_Type__c, Overflow_Support__c,' 
                        + ' Product_New__c, Priority, Language_Support__c, Preferred_Contact_Time_Zone__c' 
                        + ' FROM Case' 
                        + ' WHERE OwnerId = :handOffQueueId' 
                        + ' AND RecordType.DeveloperName = \'Support\'';
    }

    global Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext context, List<Case> scope){
        final String METHOD_NAME = 'execute';
        this.zb.callExecute(scope[0]?.Id, scope.size());
        try {
            TriggerHandler.bypass('AccountTriggerHandler');
            ContactTriggerHelper.skipTrigger = true;
            String supportQueueId = Label.Support_Queue_Id;
            String zpaSupportQueueId = Label.ZPA_Support_Queue_Id;
            Integer minutesBefore = Integer.valueOf(Label.Minutes_for_Case_Cold_To_Support_Queue);
            List<Case> listOfCaseToProcess = new List<Case>();
            for(Case cs : scope){
                if(cs.Contact_Time_Slot__c != null 
                    && cs.Preferred_Contact_Time_Zone__c != null 
                    && String.valueOf(cs.OwnerId).contains(handOffQueueId)){
                    String formattedTime = System.now().format(GCSCommonConstants.TAC_TIME_FORMAT, cs.Preferred_Contact_Time_Zone__c);
                    List<String> splitTime = formattedTime.split(' ');
                    String timePart = splitTime[2].trim();
                    List<String> timeSplitList = timePart.split(':');
                    Integer hourNow = Integer.valueOf(timeSplitList[0].trim());
                    Integer minuteNow = Integer.valueOf(timeSplitList[1].trim());
                    if(mapOfSlotAndHour.containsKey(cs.Contact_Time_Slot__c) 
                        && mapOfSlotAndHour.get(cs.Contact_Time_Slot__c)!=null){
                        Integer startHour = Integer.valueOf(mapOfSlotAndHour.get(cs.Contact_Time_Slot__c)[0]);
                        Integer endHour = Integer.valueOf(mapOfSlotAndHour.get(cs.Contact_Time_Slot__c)[1]);
                        Integer startOneHourBack = startHour - 1; 
                        if((hourNow >= startHour 
                                && hourNow < endHour) 
                            || (hourNow == startOneHourBack 
                                && minuteNow >= minutesBefore) 
                            || Test.isRunningTest()){
                            if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA){
                                cs.OwnerId = zpaSupportQueueId;
                            }
                            else{
                                cs.OwnerId = supportQueueId;
                            }
                            cs.Warm_Handoff__c  = true;
                            listOfCaseToProcess.add(cs);
                        }
                    }
                }
            }
            if(!listOfCaseToProcess.isEmpty()){
                List<Case> finalListOfCaseToUpdate = updateSkills(listOfCaseToProcess);
                TriggerUtility.SkipCaseTriggerExecuted();
                if(!finalListOfCaseToUpdate.isEmpty()){
                    List<Database.SaveResult> updateResultList = Database.update(finalListOfCaseToUpdate, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        } catch (Exception ex) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }
    }

    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
    }
    
    static List<Case> updateSkills(List<Case> newList){
        List<String> nonZpaProducts = new List<String>();
        List<Id> listOfAccountId = new List<Id>();
        List<Case> casesToUpdate = new List<Case>();
        if(String.isNotBlank(Label.Non_ZPA_Products)){
            nonZpaProducts = Label.Non_ZPA_Products.trim().split(',');
        }
        Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
        Map<String, Timezone_Region_Mapping__c> tacTimeRegionMap = Timezone_Region_Mapping__c.getAll();
        Set<String> setOfRegionSupport = new Set<String>();
        for(String csData : psesupportmap.keySet()){
            if(psesupportmap.get(csData)!= null && psesupportmap.get(csData).Region_Support__c != null){
                setOfRegionSupport.add(csData);
            }
        }
        for(Case cs:newList){
            if(cs.AccountId != null){
                listOfAccountId.add(cs.AccountId);
            }
        }
        Map<Id, Account> accmap = new Map<Id, Account>();
        if(!listOfAccountId.isEmpty()){
            for(Account acc : [SELECT Id, Customer_Support_Segment__c, Prospect_Type__c, Exclude_Partner_Support__c, 
                                Support_Type__c, District__c 
                                FROM Account 
                                WHERE Id IN :listOfAccountId]){
                accmap.put(acc.Id, acc);
            }
        }

        for(Case cs : newList){
            cs.Work_Item_Progress__c = 'In-Progress';
            if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROVISIONING 
                || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION){
                cs.Primary_Support__c = GCSCommonConstants.CS_CASE_SKILL;
                cs.Secondary_Support__c = GCSCommonConstants.EMPTY_STRING;
                cs.Escalation_Support__c = GCSCommonConstants.EMPTY_STRING;
                cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                cs.Overflow_Support__c= GCSCommonConstants.EMPTY_STRING;
            }else{
                if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA) {
                    cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_ZPA;
                }else if(nonZpaProducts.contains(cs.Product_New__c)) {
                    cs.Product_Type__c = 'Non ZPA';
                }
                Case_Quota_Management__c orgDefaults = Case_Quota_Management__c.getOrgDefaults();

                Boolean isWeekendCaseRouting = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
                if(cs.Priority_Support__c != GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE){
                    if(!isWeekendCaseRouting){
                        if(cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT){
                            cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P1;
                        }else{
                            cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P2_P4;
                        }
                    }else{
                        cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                        cs.Overflow_Support__c=GCSCommonConstants.EMPTY_STRING;
                    }
                }
            }
            
            if(cs.Priority_Support__c != GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE){
                if(cs.AccountId != null 
                    && accmap != null 
                    && accmap.containsKey(cs.AccountId) 
                    && accmap.get(cs.AccountId) != null){
                    String segmentForCase = accmap.get(cs.AccountId).Customer_Support_Segment__c;
                    String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                    List<String> premiumPlusTypesList =  premiumPlusTypes.split(';');
                    String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                    List<String> premiumPlusProductsList =  premiumPlusProducts.split(',');
                    if(!premiumPlusProductsList.isEmpty() 
                        && premiumPlusProductsList.contains(cs.Product_New__c) 
                        && cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT 
                        && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                            || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)){
                        segmentForCase = GCSCommonConstants.CASE_CUSTOMER_SEGMENT_PLATINUM;
                    }
                    else if(String.isBlank(segmentForCase) 
                        || accmap.get(cs.AccountId).Prospect_Type__c == GCSCommonConstants.PROSPECT_TYPE_POC){
                        segmentForCase = GCSCommonConstants.CASE_CUSTOMER_SEGMENT_PLATINUM;
                    }
                    else if(premiumPlusTypesList != null 
                        && accmap.get(cs.AccountId).Support_Type__c != null 
                        && premiumPlusTypesList.contains(accmap.get(cs.AccountId).Support_Type__c)){
                        segmentForCase = GCSCommonConstants.CASE_CUSTOMER_SEGMENT_PLATINUM;
                    }
                    cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) 
                                            ? psesupportmap.get(segmentForCase).Primary_Support__c 
                                            : GCSCommonConstants.EMPTY_STRING;
                    if(accmap.get(cs.AccountId).Exclude_Partner_Support__c){
                        cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) 
                                                    ? psesupportmap.get(segmentForCase).Escalation_Support__c 
                                                    : GCSCommonConstants.EMPTY_STRING;
                    }
                }
                else{
                    cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL) 
                                            ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c 
                                            : GCSCommonConstants.EMPTY_STRING;
                    cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL) 
                                            ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c 
                                            : GCSCommonConstants.EMPTY_STRING;
                    cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL) 
                                            ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c 
                                            : GCSCommonConstants.EMPTY_STRING;
                    cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                    cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                    cs.Overflow_Support__c = GCSCommonConstants.EMPTY_STRING;
                }
            }
            
            if(cs.Primary_Support__c != GCSCommonConstants.CS_CASE_SKILL){
                cs.Language_Support__c = GCSCommonConstants.EMPTY_STRING;
                if(cs.AccountId != null 
                    && accmap != null 
                    && accmap.containsKey(cs.AccountId) 
                    && accmap.get(cs.AccountId) != null 
                    && accmap.get(cs.AccountId).District__c != null){
                    String accountRegion = accmap.get(cs.AccountId).District__c;
                    for(String region : setOfRegionSupport){
                        if(accountRegion.containsIgnoreCase(region)){
                            cs.Language_Support__c = psesupportmap != null && psesupportmap.containsKey(region) 
                                                    ? psesupportmap.get(region).Region_Support__c 
                                                    : GCSCommonConstants.EMPTY_STRING;
                        }
                    }
                    if(!accountRegion.containsIgnoreCase('Japan')){
                        cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL) 
                                                    ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    }
                }else{
                    cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL) 
                                                ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c 
                                                : GCSCommonConstants.EMPTY_STRING;
                }
            }else{
                cs.Language_Support__c = GCSCommonConstants.EMPTY_STRING;
                cs.Secondary_Support__c = GCSCommonConstants.EMPTY_STRING;
            }
            
            if(cs.Preferred_Contact_Time_Zone__c != null 
                && tacTimeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c) 
                && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c) != null 
                && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c != null){
                String tacRegion = tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c;
                cs.Region_Support__c = tacRegion;
            }
            casesToUpdate.add(cs);
        } 
        return casesToUpdate;       
    }
}