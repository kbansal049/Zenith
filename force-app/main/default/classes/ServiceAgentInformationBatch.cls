/**
 * TAM Routing Implementation
 * Added by : Ankit Bhatnagar
 * Description : Batch that processes the Service Agent Info records daily as per the user's timezones. This Batch performs calculation on Weekly, daily and backlog quota.
 */
public class ServiceAgentInformationBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('ServiceAgentInformationBatch');
    public string query;
    public Map<String, User> updatedUserGlobal = new Map<String, User>();
    public List<Id> errorRecords = new List<Id>();
    public ServiceAgentInformationBatch(){
        this.query = 'SELECT id,User__c,name,daily_Quota__c, weekly_Quota__c,backlog__c,timezone__c,returning_Date__c,out_Of_Office__c,Batch_Run_Timestamp__c,Type__c,Overflow_Cases__c,Overflow_Cases_Weekly__c,Override_Daily_Quota__c, Override_Weekly_Quota__c, Shift_Off_Days__c FROM Service_Agent_Information__c';
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Service_Agent_Information__c> scope){
        try {
            this.zb.callExecute(scope[0]?.Id, scope.size());
            //Added by Ankit - IBA-297 - Start 
            List<User> users = new List<User>([ SELECT id,Out_Of_Office__c, start_date__c, returning_Date__c, TimeZoneSIdKey FROM User
                                                WHERE (Start_date__c != null AND (Start_Date__c = LAST_N_DAYS:1 OR Start_Date__c = NEXT_N_DAYS:1)) 
                                                OR (Returning_date__c != null AND (Returning_date__c = LAST_N_DAYS:1))]);
            Map<String, User> usersToBeUpdated = new Map<String, User>();
            if(!users.isEmpty()) {
                for(User u : users) {
                    Boolean oldOOOFlagValue = u.Out_Of_Office__c;
                    User usr = manageOOOFlagOnUsers(u);
                    if(usr.Out_Of_Office__c != oldOOOFlagValue) {
                        //If Changes are to be made
                        usersToBeUpdated.put(usr.Id, usr);
                        updatedUserGlobal.put(usr.Id, usr);
                    }
                }
                if(!usersToBeUpdated.isEmpty()) {
                    Database.update(usersToBeUpdated.values(),false);
                }
            }
            //Added by Ankit - IBA-297 - End

            Map<String, Boolean> timezoneWeekendMap = new Map<String,Boolean>();
            //Added by Anup - Omni Overhaul - Start
            Case_Quota_Management__c orgDefaults = Case_Quota_Management__c.getOrgDefaults();
            Boolean isWeekendForEngineer = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
            Integer frontlineDailyQuota = Integer.valueOf(orgDefaults.Frontline_Daily_Quota__c);
            Integer frontlineWeeklyQuota = Integer.valueOf(orgDefaults.Frontline_Weekly_Quota__c);
            Integer backlineDailyQuota = Integer.valueOf(orgDefaults.Backline_Daily_Quota__c);
            Integer backlineWeeklyQuota = Integer.valueOf(orgDefaults.Backline_Weekly_Quota__c);
            Map<String,String> daysOfWeek = new Map<String,String>{'Mon'=>'Monday','Tue'=>'Tuesday','Wed'=>'Wednesday','Thu'=>'Thursday','Fri'=>'Friday','Sat'=>'Saturday','Sun'=>'Sunday'};
            //Added by Anup - Omni Overhaul - End
            for(Service_Agent_Information__c agentInfo : scope) {
                if(agentInfo.Type__c == 'TAM'){
                    if(!timezoneWeekendMap.containsKey(agentInfo.timezone__c))
                        timezoneWeekendMap.put(agentInfo.timezone__c, CaseTriggerUtility.checkIfWeekend(agentInfo.timezone__c));
                }
            }
            Map<Id, Service_Agent_Information__c> saiMap = new Map<Id, Service_Agent_Information__c>();
            for(Service_Agent_Information__c sai : scope) {
                //Get Agent's Time Zone
                Timezone agentPrefTimezone = Timezone.getTimeZone(sai.timezone__c);
                //Get current time as per Agent's Time Zone
                DateTime currentTimeAgentTimeZone = Datetime.now().addSeconds((agentPrefTimezone.getOffset(Datetime.now())/1000));
                //Get current day as per Agent's Time Zone
                String formattedTime = System.now().format('EEE, yyyy-MM-dd HH:mm:ss',sai.timezone__c);
                String dayOfWeek_currentTimeAgentTimeZone = formattedTime.split(',').get(0);
                //Added by Anup - Backlog Issue Fix - Start
                String formattedTimeOneDayBefore = System.now().addHours(-22).format('EEE, yyyy-MM-dd HH:mm:ss',sai.timezone__c);
                String dayOfWeek_OneDayBefore = formattedTimeOneDayBefore.split(',').get(0);
                //Added by Anup - Backlog issue fix - End
                //Get current Hour as per Agent's Local time
                Integer hourNow = currentTimeAgentTimeZone.hourGmt();
                if(sai.Type__c == 'TAM'){
                    //Anup - Existing logic for TAM
                    //Hour Start and End Values from Custom label
                    Integer hrDayStart = Integer.valueOf(Label.CaseTAMRouting_HourDayStart);
                    Integer hrDayEnd = Integer.valueOf(Label.CaseTAMRouting_HourDayEnd);
                    Integer tamDailyQuota = 0;
                    Integer tamWeeklyQuota = 0;
                    tamDailyQuota = sai.Override_Daily_Quota__c == null?1:Integer.valueOf(sai.Override_Daily_Quota__c);
                    tamWeeklyQuota = sai.Override_Weekly_Quota__c == null?5:Integer.valueOf(sai.Override_Weekly_Quota__c);
                    if((timezoneWeekendMap.containsKey(sai.timezone__c) && timezoneWeekendMap.get(sai.timezone__c)) || Test.isRunningTest()) {
                        if(sai.daily_quota__c == null) {
                            sai.daily_quota__c = 0;
                        }
                        if(sai.weekly_Quota__c == null) {
                            sai.weekly_Quota__c = 0;
                        }
                        if(sai.backlog__c == null) {
                            sai.backlog__c = 0;
                        }
                        //Agent is outside Office Hours
                        if(sai.batch_run_timestamp__c == null || sai.batch_run_timestamp__c <= System.now().addHours(-20)) {
                            if(!saiMap.containsKey(sai.id))
                                saiMap.put(sai.id,sai);
                            //Added by Ankit - IBA-297 - Start
                            Boolean saiOOOFlag = false;
                            if(!usersToBeUpdated.containsKey(sai.User__c)) {
                                if(!updatedUserGlobal.containsKey(sai.User__c)){
                                    saiOOOFlag = sai.out_of_office__c;
                                }else{
                                    saiOOOFlag = updatedUserGlobal.get(sai.User__c).Out_Of_Office__c;
                                }
                            }
                            else {
                                saiOOOFlag = usersToBeUpdated.get(sai.User__c).Out_Of_Office__c;
                            }
                            //UPDATED : if(sai.out_of_office__c && sai.returning_Date__c >= Date.today()) {
                            if(saiOOOFlag) {
                                //SA is out of Office
                                if(sai.daily_quota__c > 0) {
                                    saiMap.get(sai.id).daily_Quota__c -= tamDailyQuota;
                                }
                                if(sai.weekly_Quota__c > 0) {
                                    saiMap.get(sai.id).weekly_Quota__c -= tamDailyQuota;
                                }
                            }
                            else {
                                //SA isn't out of office
                                if(sai.daily_quota__c > 0) {
                                    saiMap.get(sai.id).backlog__c += sai.daily_quota__c;
                                    saiMap.get(sai.id).daily_Quota__c = 0;
                                }
                            }
                            //Added by Ankit - IBA-297 - End
                            if(sai.daily_quota__c == 0)
                                saiMap.get(sai.id).daily_Quota__c = tamDailyQuota;
                            if( (dayOfWeek_currentTimeAgentTimeZone == 'Mon' && hourNow < hrDayStart) ||
                                (dayOfWeek_currentTimeAgentTimeZone == 'Fri' && hourNow >= hrDayEnd) ||
                                (dayOfWeek_currentTimeAgentTimeZone == 'Sun' || dayOfWeek_currentTimeAgentTimeZone == 'Sat')) {
                                saiMap.get(sai.id).daily_quota__c = tamDailyQuota;
                                saiMap.get(sai.id).backlog__c = 0;
                                saiMap.get(sai.id).weekly_Quota__c = tamWeeklyQuota;
                            }
                            saiMap.get(sai.id).Batch_Run_Timestamp__c = System.now();
                        }
                    }
                }else{
                    //Anup- Logic for Support Engineers
                    isWeekendForEngineer = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
                    if(dayOfWeek_currentTimeAgentTimeZone != null && sai.Shift_Off_Days__c!=null){
                        String dayOfWeek = daysOfWeek.get(dayOfWeek_currentTimeAgentTimeZone);
                        if(sai.Shift_Off_Days__c.contains(dayOfWeek)){
                            isWeekendForEngineer = true;
                        }else{
                            isWeekendForEngineer = false;
                        }
                    }
                    Integer hrDayStart = Integer.valueOf(orgDefaults.Weekday_Start_Time__c);
                    Integer hrDayEnd = Integer.valueOf(orgDefaults.Weekday_End_Time__c);
                    Integer dailyQuota = 0;
                    Integer weeklyQuota = 0;
                    if(sai.Type__c == 'Backline'){
                        dailyQuota = sai.Override_Daily_Quota__c == null?backlineDailyQuota:Integer.valueOf(sai.Override_Daily_Quota__c);
                        weeklyQuota = sai.Override_Weekly_Quota__c == null?backlineWeeklyQuota:Integer.valueOf(sai.Override_Weekly_Quota__c);
                    }else{
                        dailyQuota = sai.Override_Daily_Quota__c == null?frontlineDailyQuota:Integer.valueOf(sai.Override_Daily_Quota__c);
                        weeklyQuota = sai.Override_Weekly_Quota__c == null?frontlineWeeklyQuota:Integer.valueOf(sai.Override_Weekly_Quota__c);
                    }
                    if(sai.batch_run_timestamp__c == null || sai.batch_run_timestamp__c <= System.now().addHours(-20)) {
                        if(!saiMap.containsKey(sai.id))
                            saiMap.put(sai.id,sai);
                        if(isWeekendForEngineer && (hourNow >= hrDayEnd && hourNow < hrDayStart)) {
                            saiMap.get(sai.id).daily_quota__c = dailyQuota;
                            saiMap.get(sai.id).backlog__c = 0;
                            saiMap.get(sai.id).weekly_Quota__c = weeklyQuota;
                            saiMap.get(sai.id).Overflow_Cases__c = 0;
                            saiMap.get(sai.id).Overflow_Cases_Weekly__c =0;
                            saiMap.get(sai.id).Batch_Run_Timestamp__c = System.now();
                        }
                        else if((!isWeekendForEngineer && (hourNow >= hrDayEnd && hourNow < hrDayStart)) || Test.isRunningTest()) {
                            //Time after 11 PM and next day 7 Am will be treated as outside office work in weekdays
                            //Added by Ankit - IBA-297 - Start
                            Boolean saiOOOFlag = false;
                            if(!usersToBeUpdated.containsKey(sai.User__c)) {
                                if(!updatedUserGlobal.containsKey(sai.User__c)){
                                    saiOOOFlag = sai.out_of_office__c;
                                }else{
                                    saiOOOFlag = updatedUserGlobal.get(sai.User__c).Out_Of_Office__c;
                                }
                            }
                            else {
                                saiOOOFlag = usersToBeUpdated.get(sai.User__c).Out_Of_Office__c;
                            }
                            //UPDATED : if(sai.out_of_office__c && sai.returning_Date__c >= Date.today()) {
                            if(saiOOOFlag) {
                                //SA is out of Office
                                if(sai.daily_quota__c > 0) {
                                    saiMap.get(sai.id).daily_Quota__c -= dailyQuota;
                                }
                                if(sai.weekly_Quota__c > 0) {
                                    saiMap.get(sai.id).weekly_Quota__c -= dailyQuota;
                                }
                            }
                            else {
                                //SA isn't out of office
                                if(sai.daily_quota__c > 0) {
                                    if(dayOfWeek_OneDayBefore!=null && sai.Shift_Off_Days__c!=null){
                                        String dayOfWeekOneDayBefore = daysOfWeek.get(dayOfWeek_OneDayBefore);
                                        if(!sai.Shift_Off_Days__c.contains(dayOfWeekOneDayBefore)){
                                            saiMap.get(sai.id).backlog__c += sai.daily_quota__c;
                                            //saiMap.get(sai.Id).Weekly_Quota__c -= sai.daily_Quota__c;
                                        }
                                    }
                                    saiMap.get(sai.id).daily_Quota__c = 0;
                                }
                            }
                            //Added by Ankit - IBA-297 - End
                            if(sai.daily_quota__c <= 0)
                                saiMap.get(sai.id).daily_Quota__c = dailyQuota;
                            saiMap.get(sai.id).Overflow_Cases__c = 0;
                            saiMap.get(sai.id).Batch_Run_Timestamp__c = System.now();
                        }
                    }
                }
            }
            if(!saiMap.isEmpty()){
                List<Database.SaveResult> SR = Database.update(saiMap.values(),false);
                Integer counter = 0;
                for (Database.SaveResult currD : SR) {
                    if (!currD.isSuccess()) {
                        for(Database.Error err : currD.getErrors()) {
                            errorRecords.add(saiMap.values()[counter].Id);
                        }
                    }
                    counter++;
                }
            }
        } catch (Exception ex) {
            String exceptionMessage = ex.getMessage() + '\r\nLine: ' + ex.getLineNumber() + '\r\n\r\n' + ex.getStackTraceString();
            logError(exceptionMessage);
        }
    }
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        // execute any post-processing operations
        if(!errorRecords.isEmpty()){
            String errorMessage = 'Following Service Agent Information records failed while processing in ServiceAgentInformationBatch:\r\n';
            errorMessage += String.join(errorRecords, ', ');
            logError(errorMessage);
        }
    }

    //Added by Ankit - IBA-297 -- Start
    public static User manageOOOFlagOnUsers(User u) {
        Timezone userTimeZone = Timezone.getTimeZone(u.TimeZoneSIdKey);
        String formattedTime = Datetime.now().format('EEE, yyyy-MM-dd HH:mm:ss',u.TimeZoneSIdKey);
        String currentDayStr = formattedTime.split(' ').get(1).split('-').get(2);
        Integer currentDay = Integer.valueOf(currentDayStr);
        Integer startDay = u.Start_date__c.day();
        Integer returningDay = u.Returning_date__c.day();
        if(startDay == currentDay) {
            u.Out_of_office__c = true;
        }
        else if(returningDay == currentDay) {
            u.Out_of_office__c = false;
            u.start_date__c = null;
            u.returning_Date__c = null;
        }
        return u;
    }
    //Added by Ankit - IBA-297 -- End

    public static void logError(String exceptionMessage) {
        Zscaler_Error_Logs__c zsErrorRecord = new Zscaler_Error_Logs__c();
        zsErrorRecord.Class_Name__c = 'ServiceAgentInformationBatch';
        zsErrorRecord.Exception_info__c = exceptionMessage;
        zsErrorRecord.Method_Name__c = 'ServiceAgentInformationBatch.execute';
        zsErrorRecord.Multiple_records_info__c = '';
        zsErrorRecord.Operation__c = 'Error occured in ServiceAgentInformationBatch Batch';
        zsErrorRecord.Record_Info__c = '';
        zsErrorRecord.User__c = String.valueOf(UserInfo.getUserId());
        Database.insert(zsErrorRecord, false);
    }
}