/***********************************************
Changes by              Date           Description
Gurjinder Singh Mann    13-May-2019    Changes done to execute the Tasks on the basis of IsRecurrence. 
************************************************/
global class UpdateTerritoryonTasks_Schedulable implements Schedulable
{
    global Date sd;
    global Date ed;
    
    global UpdateTerritoryonTasks_Schedulable(Date startdate, Date enddate)
    {
        sd = startdate;
        ed = enddate;
    }
    
    global void execute(SchedulableContext SC)
    {
        UpdateTerritoryonTasks batch;
        if(sd == null){
            sd = Date.Today().addDays(-6);
        }
        if(ed == null){
            ed = Date.Today();
        }
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        
        //Execute the batch for Non Recurring task with a batch size of 200     
        String NonRecurringTaskBatchQuery = 'Select Id,WhoId,WhatId,AccountId,Sales_Territory__c,Territory_Area__c,Territory_Geo__c,Territory_Type__c,IsRecurrence from Task where IsRecurrence=False and IsClosed = false AND LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate and Sales_Territory__c=null and Territory_Area__c=null and Territory_Geo__c=null and Territory_Type__c=null and (accountId != null or Who.Type = \'Lead\')';
        
        Integer NonRecurringTaskBatchSize=integer.valueof(ZscalerCustomSetting__c.getInstance('NonRecurringTaskBatchSize')!=null && ZscalerCustomSetting__c.getInstance('NonRecurringTaskBatchSize').Value__c!=null ? ZscalerCustomSetting__c.getInstance('NonRecurringTaskBatchSize').Value__c:'200');
            
        batch = new UpdateTerritoryonTasks(startdate,enddate,NonRecurringTaskBatchQuery);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,NonRecurringTaskBatchSize);
        }
        
        //Execute the batch for Recurring task with a batch size of 1
        String RecurringTaskBatchQuery='Select Id,WhoId,WhatId,AccountId,Sales_Territory__c,Territory_Area__c,Territory_Geo__c,Territory_Type__c,IsRecurrence from Task where IsRecurrence=True and IsClosed = false AND LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate and Sales_Territory__c=null and Territory_Area__c=null and Territory_Geo__c=null and Territory_Type__c=null and (accountId != null or Who.Type = \'Lead\')';

        Integer RecurringTaskBatchSize = integer.valueof(ZscalerCustomSetting__c.getInstance('RecurringTaskBatchSize')!=null && ZscalerCustomSetting__c.getInstance('RecurringTaskBatchSize').Value__c!=null ? ZscalerCustomSetting__c.getInstance('RecurringTaskBatchSize').Value__c:'1');
        
        batch = new UpdateTerritoryonTasks(startdate,enddate,RecurringTaskBatchQuery);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,RecurringTaskBatchSize);
        }
        
    }
 }