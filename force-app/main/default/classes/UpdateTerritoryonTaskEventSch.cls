global class UpdateTerritoryonTaskEventSch  implements Schedulable{
    global Date sd;
    global Date ed;
    global DateTime currentDateTime;
    
    global UpdateTerritoryonTaskEventSch(Date startdate, Date enddate)
    {
        sd = startdate;
        ed = enddate;
        currentDateTime = System.now();
    }
    
    global void execute(SchedulableContext SC)
    {
        // Logic to Schedule batch jobs for Tasks : Start 
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
        
        // Logic to Schedule batch jobs for Tasks : End  
    
    // Logic to Schedule batch jobs for Events :Start 
        UpdateTerritoryonEvents batch2;
        
         //Execute the batch for Non Recurring task with a batch size of 200 
        String NonRecurringEventBatchQuery='Select Id,WhoId,WhatId,AccountId,Sales_Territory__c,Territory_Area__c,Territory_Geo__c,Territory_Type__c,IsRecurrence from event where IsRecurrence=False and LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate and Sales_Territory__c=null and Territory_Area__c=null and Territory_Geo__c=null and Territory_Type__c=null and (accountId != null or Who.Type = \'Lead\') AND EndDateTime >= :currentDateTime';
        
        Integer NonRecurringEventBatchSize = integer.valueof(ZscalerCustomSetting__c.getInstance('NonRecurringEventBatchSize')!=null && ZscalerCustomSetting__c.getInstance('NonRecurringEventBatchSize').Value__c!=null ? ZscalerCustomSetting__c.getInstance('NonRecurringEventBatchSize').Value__c:'200');
        
        batch2 = new UpdateTerritoryonEvents(startdate,enddate,NonRecurringEventBatchQuery);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,NonRecurringEventBatchSize);
        }
        
        //Execute the batch for Recurring task with a batch size of 1   
        String RecurringEventBatchQuery='Select Id,WhoId,WhatId,AccountId,Sales_Territory__c,Territory_Area__c,Territory_Geo__c,Territory_Type__c,IsRecurrence from event where IsRecurrence=True and LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate and Sales_Territory__c=null and Territory_Area__c=null and Territory_Geo__c=null and Territory_Type__c=null and (accountId != null or Who.Type = \'Lead\') AND EndDateTime >= :currentDateTime';
        
        Integer RecurringEventBatchSize = integer.valueof(ZscalerCustomSetting__c.getInstance('RecurringEventBatchSize')!=null && ZscalerCustomSetting__c.getInstance('RecurringEventBatchSize').Value__c!=null ? ZscalerCustomSetting__c.getInstance('RecurringEventBatchSize').Value__c:'1');
        
        batch2 = new UpdateTerritoryonEvents(startdate,enddate,RecurringEventBatchQuery);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,RecurringEventBatchSize);
        }
    // Logic to Schedule batch jobs for Events :End  
    }
    
}