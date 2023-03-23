global class AutoCloseLeadBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('AutoCloseLeadBatch');
    global String query;
    global String Entity;
    //Added by swathi : CR 1398 start
    global Id contId;
    global Map<Id,String> errorMap = new Map<Id,String>();
    //Added by swathi : CR 1398 End
    

    
    global void execute(SchedulableContext SC) {
      AutoCloseLeadBatch M = new AutoCloseLeadBatch();
      Database.executeBatch(M,50);
   }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        //added Status conditions for CR# 2731 :Gurjinder
        
        //Added by Arsh - CR 4717 - fixing batch class  
        query = 'SELECT Contact_Lead_Status__c, Age_Since_Last_Open__c, Days_since_last_activity__c, Remarks__c,Outreach_Status__c, Id FROM Contact where (Contact_Lead_Status__c = \'Marketing Qualified: Sales Untouched\' AND Age_Since_Last_Open__c>10) '; 

        if(Test.isRunningTest())  {
            query = 'SELECT Contact_Lead_Status__c, Age_Since_Last_Open__c, Days_since_last_activity__c, Remarks__c,Outreach_Status__c, Id FROM Contact';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<contact> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        
        List<contact> contacts = (List<contact>)scope;
        //Added by swathi : CR 1398 start
        List<contact> UpdatecontactStatusList = new List<contact>();  
        Try{
            for(contact l : contacts){
          
                l.Remarks__c = 'Lead Not Worked';
                l.Contact_Lead_Status__c = 'Recycled to Marketing';
                //Added Funnel_Stage_Date__c and Funnel_Stage__c to avoid impact of contact trigger bypass
                l.Funnel_Stage_Date__c = NULL;
                l.Funnel_Stage__c = 'Inactive';
                //Added by Arsh - CR 4717 - fixing batch class 
                UpdatecontactStatusList.add(l);
            }
            
        //Added by swathi : CR 1398 Start
            TriggerUtility.contactOwnerShipExecuted();
            TriggerUtility.conWhiteSpaceUpdateExecuted();
            TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
            TriggerUtility.ZCloudIDcontactDeletetriggersettrue();
            TriggerUtility.ZCloudIDcontactAfterInserttriggersettrue();
            TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
            TriggerUtility.contaskFieldUpdateExecuted();
            TriggerUtility2.updateTouchesSinceLastOpenExecuted();
            if(!UpdatecontactStatusList.isempty()){
                triggerUtility.afterUpdateRelatedContactExecuted();
                TriggerHandler.bypass('genericContactTrigger');
                database.update(UpdatecontactStatusList, false);
                TriggerHandler.clearBypass('genericContactTrigger');
                triggerUtility.afterUpdateRelatedContactExecutedReset();
            }
            
        }catch(Exception ex){
            System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            errorMap.put(contId,ex.getMessage() + ' at Line No. ' + ex.getLineNumber());
            ZscalerErrorLogsUtility.insertlogsForAsync('AutoCloseLeadBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        this.zb.callFinish(BC);
        System.debug('--errorMap--'+errorMap);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        if(!errorMap.Values().isEmpty() || Test.isRunningTest()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Auto close contact batch failed');
            String msgbody = 'Below are the Ids of ' + errorMap.Values().size() + ' for which Auto close contact batch failed: \n';
            for(Id s: errorMap.keySet()){
                msgbody += 'Id : '+s + ' Error Message : '+errorMap.get(s) +'\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(errorMap.Values().isEmpty() || Test.isRunningTest()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Auto close contact Batch Job Completed ');
            mail.setPlainTextBody('Auto close contact Batch Job Completed');
            messageList.add(mail);
        }
        if(!Test.isRunningTest()){
            Messaging.sendEmail(messageList);
        }
        
    }
    //Added by swathi : CR 1398 End
}