global class BatchToUpdateLeadFields implements Database.Batchable<sObject>, Database.Stateful{
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchToUpdateLeadFields');
    global final String Query;
    global Id contId;
    global Map<Id,String> errorMap = new Map<Id,String>();
	//updated by Akash 1: CR# 5023 start
    public Integer noOfRecordsProcessed = 0;
    public dateTime startTime = datetime.now();
    //updated by Akash 1: CR# 5023 end
   global BatchToUpdateLeadFields(String q)
   {
      Query=q; 
   }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        //String query = 'Select Id,Qualifying_SDR__c,Qualification_Status__c From Lead where Age_Past_Qualification_Date__c >= 90 AND IsConverted = False AND (Qualifying_SDR__c!=Null OR Qualification_Status__c !=Null)';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        //updated by Akash 1: CR# 5023 start
        noOfRecordsProcessed = noOfRecordsProcessed + scope.Size();
        //updated by Akash 1: CR# 5023 end
        
		List<lead> leadlist = new List<lead>();
        List<Contact> Contactlist = new List<contact>();
        Try{
        for(sObject l: scope){ 
            contId=l.id;
            if(l.getSObjectType()==Lead.sObjectType){
                leadlist.add((Lead)l);
            }
            if(l.getSObjectType()==Contact.sObjectType){
                Contactlist.add((Contact)l);
            }
        }
        if(!leadlist.isempty()){
            for(Lead l: leadlist){
                l.Qualifying_SDR__c = null; 
                l.Qualification_Status__c = '' ;
            }
            TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        	TriggerUtility.updateLeadSalesTeamEmailFieldsExecuted();
        	TriggerUtility.UpdatingMarketsegmentforLeadsettrue();
        	//TriggerUtility.leadtaskFieldUpdateExecuted();
        	Database.update (leadlist,false);
        }
        if(!Contactlist.isempty()){
            for(Contact l: Contactlist){
                if(l.Latest_Opportunity_Date__c==Null || (l.Latest_Opportunity_Date__c < l.Qualified_Date__c)){
                	l.Qualifying_SDR__c = null; 
                	l.Qualification_Status__c = '' ;
                }
            }
            TriggerUtility.contactOwnerShipExecuted();
        	TriggerUtility.conWhiteSpaceUpdateExecuted();
        	TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
        	TriggerUtility.ZCloudIDcontactDeletetriggersettrue();
        	TriggerUtility.ZCloudIDcontactAfterInserttriggersettrue();
        	TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
            TriggerUtility2.updateTaskRelatedContOrLeadExecuted();
        	TriggerUtility.realignPatch();
        	TriggerUtility2.updateTouchesSinceLastOpenExecuted();
        	database.update(Contactlist, false);
        }
        }catch(Exception ex){
            System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            errorMap.put(contId,ex.getMessage() + ' at Line No. ' + ex.getLineNumber());
            //updated by Akash 1: CR# 5023 start
            ZscalerErrorLogsUtility.insertlogsForAsync('BatchToUpdateLeadFields', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
        	//updated by Akash 1: CR# 5023 end
        }
    }
    
    global void finish(Database.BatchableContext BC){
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
        if(!Test.isRunningTest()){
            Messaging.sendEmail(messageList);
        }
    }
    
}