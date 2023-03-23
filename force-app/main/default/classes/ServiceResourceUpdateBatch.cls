/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* ServiceResourceUpdateBatch
* @description - This Batch class that processes the Service Resource records daily as per the user's timezones. 
 *               This Batch performs calculation on Weekly, daily and backlog quota and OOO Management.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Anup Dhole
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-01-20
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class ServiceResourceUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    static final String APEX_CLASS_NAME = 'ServiceResourceUpdateBatch';
    ZscalerBatchFramework zb = new ZscalerBatchFramework('ServiceResourceUpdateBatch');
    Map<String, ServiceResource> updatedServiceResourceUserGlobalMap = new Map<String, ServiceResource>();

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(Label.ServiceResourceUpdateBatch_Query);
    }

    public void execute(Database.BatchableContext context, List<ServiceResource> scope){
        final String METHOD_NAME = 'execute';
        this.zb.callExecute(scope[GCSCommonConstants.INTEGER_0]?.Id, scope.size());
        try {
            //Logic to Manage OOO checkbox on Service Resource - Start
            Map<String, ServiceResource> tobeUpdateServiceResourceUserLocalMap = updateUsersOutOfOffice(scope);
            updatedServiceResourceUserGlobalMap.putAll(tobeUpdateServiceResourceUserLocalMap);

            //Logic to Manage OOO checkbox on Service Resource - End
            Map<String, Boolean> timezoneWeekendMap = new Map<String,Boolean>();
            Case_Quota_Management__c orgDefaults = Case_Quota_Management__c.getOrgDefaults();
            Boolean isWeekendForEngineer = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
            Integer frontlineDailyQuota = Integer.valueOf(orgDefaults.Frontline_Daily_Quota__c);
            Integer frontlineWeeklyQuota = Integer.valueOf(orgDefaults.Frontline_Weekly_Quota__c);
            Integer backlineDailyQuota = Integer.valueOf(orgDefaults.Backline_Daily_Quota__c);
            Integer backlineWeeklyQuota = Integer.valueOf(orgDefaults.Backline_Weekly_Quota__c);
            Map<String,String> daysOfWeekMap = new Map<String,String>{
                'Mon' => 'Monday',
                'Tue' => 'Tuesday',
                'Wed' => 'Wednesday',
                'Thu' => 'Thursday',
                'Fri' => 'Friday',
                'Sat' => 'Saturday',
                'Sun' => 'Sunday'
            };

            for(ServiceResource currentSRRec : scope) {
                if(currentSRRec.Type__c == GCSCommonConstants.SERVICE_RESOURCE_TYPE_TAM 
                    && !timezoneWeekendMap.containsKey(currentSRRec.timezone__c)){
                    timezoneWeekendMap.put(currentSRRec.timezone__c, CaseTriggerUtility.checkIfWeekend(currentSRRec.timezone__c));
                }
            }

            Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>();
            for(ServiceResource currentSRAgent : scope) {
                //Get Service Resource Agent Time Zone
                Timezone agentPrefTimezone = Timezone.getTimeZone(currentSRAgent.timezone__c);

                //Get current time as per Service Resource Agent Time Zone
                DateTime currentTimeAgentTimeZone = Datetime.now().addSeconds((agentPrefTimezone.getOffset(Datetime.now()) / 1000));

                //Get current day as per Service Resource Agent Time Zone
                String formattedTime = System.now().format(GCSCommonConstants.TAC_TIME_FORMAT, currentSRAgent.timezone__c);
                String dayOfWeekAtCurrentAgentTZ = formattedTime.split(',').get(GCSCommonConstants.INTEGER_0);
                String formattedTimeOneDayBefore = System.now().addHours(-22).format(GCSCommonConstants.TAC_TIME_FORMAT, currentSRAgent.timezone__c);
                String oneDayBeforeDayOfWeekAtCurrentAgentTZ = formattedTimeOneDayBefore.split(',').get(GCSCommonConstants.INTEGER_0);
                
                //Get current Hour as per Service Resource Agent Local time
                Integer currentGMTHour = currentTimeAgentTimeZone.hourGmt();
                if(currentSRAgent.Type__c == GCSCommonConstants.SERVICE_RESOURCE_TYPE_TAM){
                    //Hour Start and End Values from Custom label
                    Integer hrDayStart = Integer.valueOf(Label.CaseTAMRouting_HourDayStart);
                    Integer hrDayEnd = Integer.valueOf(Label.CaseTAMRouting_HourDayEnd);
                    Integer tamDailyQuota = currentSRAgent.Override_Daily_Quota__c == null ? 1 : Integer.valueOf(currentSRAgent.Override_Daily_Quota__c);
                    Integer tamWeeklyQuota = currentSRAgent.Override_Weekly_Quota__c == null ? 5 : Integer.valueOf(currentSRAgent.Override_Weekly_Quota__c);
                    if((timezoneWeekendMap.containsKey(currentSRAgent.timezone__c) 
                            && timezoneWeekendMap.get(currentSRAgent.timezone__c)) 
                        || Test.isRunningTest()) {
                        if(currentSRAgent.daily_quota__c == null) {
                            currentSRAgent.daily_quota__c = GCSCommonConstants.INTEGER_0;
                        }
                        if(currentSRAgent.weekly_Quota__c == null) {
                            currentSRAgent.weekly_Quota__c = GCSCommonConstants.INTEGER_0;
                        }
                        if(currentSRAgent.backlog__c == null) {
                            currentSRAgent.backlog__c = GCSCommonConstants.INTEGER_0;
                        }
                        //Agent is outside Office Hours
                        if(currentSRAgent.batch_run_timestamp__c == null 
                            || currentSRAgent.batch_run_timestamp__c <= System.now().addHours(-20)) {
                            if(!srMap.containsKey(currentSRAgent.Id)){
                                srMap.put(currentSRAgent.Id, currentSRAgent);
                            }

                            Boolean isSRonOutOfOffice = false;
                            if(!tobeUpdateServiceResourceUserLocalMap.containsKey(currentSRAgent.RelatedRecordId)) {
                                if(!updatedServiceResourceUserGlobalMap.containsKey(currentSRAgent.RelatedRecordId)){
                                    isSRonOutOfOffice = currentSRAgent.out_of_office__c;
                                }else{
                                    isSRonOutOfOffice = updatedServiceResourceUserGlobalMap.get(currentSRAgent.RelatedRecordId).Out_Of_Office__c;
                                }
                            }else{
                                isSRonOutOfOffice = tobeUpdateServiceResourceUserLocalMap.get(currentSRAgent.RelatedRecordId).Out_Of_Office__c;
                            }

                            if(isSRonOutOfOffice) {
                                //SR is out of Office
                                if(currentSRAgent.daily_quota__c > GCSCommonConstants.INTEGER_0) {
                                    srMap.get(currentSRAgent.Id).daily_Quota__c -= tamDailyQuota;
                                }
                                if(currentSRAgent.weekly_Quota__c > GCSCommonConstants.INTEGER_0) {
                                    srMap.get(currentSRAgent.Id).weekly_Quota__c -= tamDailyQuota;
                                }
                            }else{
                                //SR isn't out of office
                                if(currentSRAgent.daily_quota__c > GCSCommonConstants.INTEGER_0) {
                                    srMap.get(currentSRAgent.Id).backlog__c += currentSRAgent.daily_quota__c;
                                    srMap.get(currentSRAgent.Id).daily_Quota__c = GCSCommonConstants.INTEGER_0;
                                }
                            }

                            if(currentSRAgent.daily_quota__c == GCSCommonConstants.INTEGER_0){
                                srMap.get(currentSRAgent.Id).daily_Quota__c = tamDailyQuota;
                            }

                            if((dayOfWeekAtCurrentAgentTZ == GCSCommonConstants.DAY_MONDAY && currentGMTHour < hrDayStart) 
                                || (dayOfWeekAtCurrentAgentTZ == GCSCommonConstants.DAY_FRIDAY && currentGMTHour >= hrDayEnd) 
                                || (dayOfWeekAtCurrentAgentTZ == GCSCommonConstants.DAY_SUNDAY 
                                    || dayOfWeekAtCurrentAgentTZ == GCSCommonConstants.DAY_SATURDAY)) {
                                srMap.get(currentSRAgent.Id).daily_quota__c = tamDailyQuota;
                                srMap.get(currentSRAgent.Id).backlog__c = GCSCommonConstants.INTEGER_0;
                                srMap.get(currentSRAgent.Id).weekly_Quota__c = tamWeeklyQuota;
                            }
                            srMap.get(currentSRAgent.Id).Batch_Run_Timestamp__c = System.now();
                        }
                    }
                }else{
                    //Logic for Weekend Support Engineers
                    isWeekendForEngineer = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
                    if(dayOfWeekAtCurrentAgentTZ != null && currentSRAgent.Shift_Off_Days__c!=null){
                        String dow = daysOfWeekMap.get(dayOfWeekAtCurrentAgentTZ);
                        if(currentSRAgent.Shift_Off_Days__c.contains(dow)){
                            isWeekendForEngineer = true;
                        }else{
                            isWeekendForEngineer = false;
                        }
                    }

                    Integer hrDayStart = Integer.valueOf(orgDefaults.Weekday_Start_Time__c);
                    Integer hrDayEnd = Integer.valueOf(orgDefaults.Weekday_End_Time__c);
                    Integer dailyQuota = GCSCommonConstants.INTEGER_0;
                    Integer weeklyQuota = GCSCommonConstants.INTEGER_0;
                    if(currentSRAgent.Type__c == GCSCommonConstants.SERVICE_RESOURCE_TYPE_BACKLINE){
                        dailyQuota = currentSRAgent.Override_Daily_Quota__c == null ? backlineDailyQuota : Integer.valueOf(currentSRAgent.Override_Daily_Quota__c);
                        weeklyQuota = currentSRAgent.Override_Weekly_Quota__c == null ? backlineWeeklyQuota : Integer.valueOf(currentSRAgent.Override_Weekly_Quota__c);
                    }else{
                        dailyQuota = currentSRAgent.Override_Daily_Quota__c == null?frontlineDailyQuota:Integer.valueOf(currentSRAgent.Override_Daily_Quota__c);
                        weeklyQuota = currentSRAgent.Override_Weekly_Quota__c == null?frontlineWeeklyQuota:Integer.valueOf(currentSRAgent.Override_Weekly_Quota__c);
                    }

                    if(currentSRAgent.batch_run_timestamp__c == null 
                        || currentSRAgent.batch_run_timestamp__c <= System.now().addHours(-20)) {
                        if(!srMap.containsKey(currentSRAgent.Id)){
                            srMap.put(currentSRAgent.Id, currentSRAgent);
                        }

                        if(isWeekendForEngineer 
                            && currentGMTHour >= hrDayEnd 
                            && currentGMTHour < hrDayStart) {
                            srMap.get(currentSRAgent.Id).daily_quota__c = dailyQuota;
                            srMap.get(currentSRAgent.Id).backlog__c = GCSCommonConstants.INTEGER_0;
                            srMap.get(currentSRAgent.Id).weekly_Quota__c = weeklyQuota;
                            srMap.get(currentSRAgent.Id).Overflow_Cases__c = GCSCommonConstants.INTEGER_0;
                            srMap.get(currentSRAgent.Id).Overflow_Cases_Weekly__c = GCSCommonConstants.INTEGER_0;
                            srMap.get(currentSRAgent.Id).Batch_Run_Timestamp__c = System.now();
                        }else if((!isWeekendForEngineer 
                                && (currentGMTHour >= hrDayEnd 
                                && currentGMTHour < hrDayStart)) 
                            || Test.isRunningTest()) {
                            //Time after 11 PM and next day 7 Am will be treated as outside office work in weekdays
                            Boolean isSRonOutOfOffice = false;
                            if(!tobeUpdateServiceResourceUserLocalMap.containsKey(currentSRAgent.RelatedRecordId)) {
                                if(!updatedServiceResourceUserGlobalMap.containsKey(currentSRAgent.RelatedRecordId)){
                                    isSRonOutOfOffice = currentSRAgent.out_of_office__c;
                                }else{
                                    isSRonOutOfOffice = updatedServiceResourceUserGlobalMap.get(currentSRAgent.RelatedRecordId).Out_Of_Office__c;
                                }
                            }else{
                                isSRonOutOfOffice = tobeUpdateServiceResourceUserLocalMap.get(currentSRAgent.RelatedRecordId).Out_Of_Office__c;
                            }

                            if(isSRonOutOfOffice) {
                                //SR is out of Office
                                if(currentSRAgent.daily_quota__c > GCSCommonConstants.INTEGER_0) {
                                    srMap.get(currentSRAgent.Id).daily_Quota__c -= dailyQuota;
                                }
                                if(currentSRAgent.weekly_Quota__c > GCSCommonConstants.INTEGER_0) {
                                    srMap.get(currentSRAgent.Id).weekly_Quota__c -= dailyQuota;
                                }
                            }else{
                                //SR isn't out of office
                                if(currentSRAgent.daily_quota__c > GCSCommonConstants.INTEGER_0) {
                                    if(oneDayBeforeDayOfWeekAtCurrentAgentTZ != null && currentSRAgent.Shift_Off_Days__c != null){
                                        String dayOfWeekOneDayBefore = daysOfWeekMap.get(oneDayBeforeDayOfWeekAtCurrentAgentTZ);
                                        if(!currentSRAgent.Shift_Off_Days__c.contains(dayOfWeekOneDayBefore)){
                                            srMap.get(currentSRAgent.Id).backlog__c += currentSRAgent.daily_quota__c;
                                        }
                                    }
                                    srMap.get(currentSRAgent.Id).daily_Quota__c = GCSCommonConstants.INTEGER_0;
                                }
                            }

                            if(currentSRAgent.daily_quota__c <= GCSCommonConstants.INTEGER_0){
                                srMap.get(currentSRAgent.Id).daily_Quota__c = dailyQuota;
                            }
                            srMap.get(currentSRAgent.Id).Overflow_Cases__c = GCSCommonConstants.INTEGER_0;
                            srMap.get(currentSRAgent.Id).Batch_Run_Timestamp__c = System.now();
                        }
                    }
                }
            }
            if(!srMap.isEmpty()){
                List<Database.SaveResult> updateResultList = Database.update(srMap.values(), false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
        }catch(Exception ex){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }
    }

    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
    }

    private Map<String, ServiceResource> updateUsersOutOfOffice(List<ServiceResource> listOfResources){
        List<ResourceAbsence> resourceAbsences = new List<ResourceAbsence>([SELECT Id, Timezone__c, Start, End, ResourceId, Resource.RelatedRecordId, Resource.Timezone__c, Resource.Out_Of_Office__c 
                                                                            FROM ResourceAbsence
                                                                            WHERE ((Start != null AND (Start = LAST_N_DAYS:1 OR Start = NEXT_N_DAYS:1)) 
                                                                                OR (End != null AND (End = LAST_N_DAYS:1))) 
                                                                            AND ResourceId IN :listOfResources]);
        Map<String, ServiceResource> updatedUserGlobalTemp = new Map<String, ServiceResource>();
        if(!resourceAbsences.isEmpty()) {
            Map<Id, ServiceResource> mapOfResources = new Map<Id, ServiceResource>();
        
            Set<Id> setOfResourceId = new Set<Id>();
            for(ResourceAbsence ra : resourceAbsences){
                Timezone agentPrefTimezone = Timezone.getTimeZone(ra.timezone__c);
                DateTime currentTimeAgentTimeZone = Datetime.now().addSeconds((agentPrefTimezone.getOffset(Datetime.now()) / 1000));
                DateTime startInAgentTime = ra.Start.addSeconds((agentPrefTimezone.getOffset(ra.Start) / 1000));
                Datetime endInAgentTime = ra.End.addSeconds((agentPrefTimezone.getOffset(ra.End) / 1000));
                
                if(!mapOfResources.containsKey(ra.ResourceId)){
                    mapOfResources.put(ra.ResourceId, new ServiceResource(Id=ra.ResourceId));
                }

                if(!updatedUserGlobalTemp.containsKey(ra.Resource.RelatedRecordId)){
                    updatedUserGlobalTemp.put(ra.Resource.RelatedRecordId, new ServiceResource(Id=ra.ResourceId));
                }
                
                if(startInAgentTime <= currentTimeAgentTimeZone && endInAgentTime > currentTimeAgentTimeZone){
                    Date returnDate = Date.newinstance(endInAgentTime.year(), endInAgentTime.month(), endInAgentTime.day());
                    mapOfResources.get(ra.ResourceId).Out_Of_Office__c = true;
                    mapOfResources.get(ra.ResourceId).Returning_Date__c = returnDate;
                    updatedUserGlobalTemp.get(ra.Resource.RelatedRecordId).Out_Of_Office__c = true;
                    updatedUserGlobalTemp.get(ra.Resource.RelatedRecordId).Returning_Date__c = returnDate;
                    setOfResourceId.add(ra.ResourceId);
                }
                else{
                    if(!setOfResourceId.contains(ra.ResourceId)){
                        mapOfResources.get(ra.ResourceId).Out_Of_Office__c = false;
                        mapOfResources.get(ra.ResourceId).Returning_Date__c = null;
                        updatedUserGlobalTemp.get(ra.Resource.RelatedRecordId).Out_Of_Office__c = false;
                        updatedUserGlobalTemp.get(ra.Resource.RelatedRecordId).Returning_Date__c = null;
                    }
                }
            }
            if(!mapOfResources.isEmpty()){
                update mapOfResources.values();
            }
        }
        return updatedUserGlobalTemp;
    }
}