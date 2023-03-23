global class RollupEnrolledUsersBatch implements Database.Batchable<sObject>,Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('RollupEnrolledUsersBatch');

    global List<String> fieldnameList;
    Map< Id, Decimal> LMap = new Map< Id, Decimal>();
    Map< Id, Integer> countMap = new Map< Id, Integer>();
    
    global Map<Id,String> errorMap;
    
    global RollupEnrolledUsersBatch (List<String> fieldnameList) {
        this.fieldnameList = fieldnameList;
        errorMap = new Map<Id,String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        return Database.getQueryLocator(
            'Select Enrolled_Users__c, Zscaler_Cloud_ID__c FROM  ' +
            'Cloud_Usage__c Where Cloud_Usage_Type__c = \'ZPA\' AND ' +
            fieldnameList.get(0) + ' = true ORDER BY Zscaler_Cloud_ID__c LIMIT 500'
        );
    }
    global void execute(Database.BatchableContext bc, List<Cloud_Usage__c> records){
        this.zb.callExecute(records[0]?.Id, records.size());
        for (Cloud_Usage__c ar : records)  {
            System.debug('----ar--'+ar);
            if(ar.Zscaler_Cloud_Id__c != null && ar.Enrolled_Users__c != null){
                LMap.put( ar.Zscaler_Cloud_Id__c , LMap.containsKey(ar.Zscaler_Cloud_Id__c) ? LMap.get(ar.Zscaler_Cloud_Id__c)  + ar.Enrolled_Users__c: ar.Enrolled_Users__c );
                if(countMap.containskey( ar.Zscaler_Cloud_Id__c))
                    countMap.put( ar.Zscaler_Cloud_Id__c, countMap.get( ar.Zscaler_Cloud_Id__c) + 1);
                else
                    countMap.put( ar.Zscaler_Cloud_Id__c,  1);
            }
        }

    }    

    global void finish(Database.BatchableContext bc){
		this.zb.callFinish(bc);
        List<Zscaler_Cloud_ID__c> clouds = new List<Zscaler_Cloud_ID__c>();
        String fieldname = 'ZPA_Enrolled_Users_L90D_Rollup__c';
        if(fieldnameList.get(0) == 'Last_31_Days__c')
            fieldname = 'ZPA_Enrolled_Users_L31D_Rollup__c';
        else if( fieldnameList.get(0) == 'Last_6_Months__c')
            fieldname = 'ZPA_Enrolled_Users_L6M_Rollup__c';
        else if( fieldnameList.get(0) == 'Last_90_Days__c')
            fieldname = 'ZPA_Enrolled_Users_L90D_Rollup__c';

        for (Id ar : LMap.keyset())  {
            Zscaler_Cloud_ID__c cloudIdRecord = new Zscaler_Cloud_ID__c(Id = ar);
            cloudIdRecord.put( fieldname, LMap.get(ar) /countMap.get(ar));
            clouds.add( cloudIdRecord );
        }

        if(!clouds.isEmpty() && Test.isRunningTest()) {
            TriggerUtility2.UpdateZscalerCloudIdTriggerExecuted();
            //update clouds;
            Database.executeBatch(new RollupCloudIdUpdateBatch(clouds));
        }

        LMap = new Map< Id, Decimal>();
        countMap = new Map< Id, Integer>();

        if(!fieldnameList.isEmpty()){
            String batchType = fieldnameList[0];
            fieldnameList.remove(0);

            if(!fieldnameList.isEmpty()) {
                RollupEnrolledUsersBatch b = new RollupEnrolledUsersBatch(fieldnameList);
                database.executebatch(b);
            } else {
                String query = 'SELECT Id,ZPA_Use_Cases__c, (SELECT ID,ZPA_Active_Users_L31D_RollUp__c,ZPA_Active_Users_L90D_RollUp__c, '+
                ' ZPA_Enrolled_Users_L31D_Rollup__c, ZPA_Enrolled_Users_L6M_Rollup__c,ZPA_Enrolled_Users_L90D_Rollup__c '+
                ' FROM Zscaler_Cloud_IDs__R WHERE Cloud_Type__c = \'ZPA\') FROM Account WHERE First_ZPA_Contract_Date__c != null and Type =\'Customer\'';
                AccountRollUpEnrolledUserBatch rollup = new AccountRollUpEnrolledUserBatch(query);
                 Database.executeBatch(rollup,1);
                
            }
            
            sendConfirmationEmail(batchType);
        }
        
    }
    
    global void sendConfirmationEmail(String batchType){
        
        System.debug('--errorMap--'+errorMap);
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {Label.BSYS_INFO});
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }else{
            mail.setsenderDisplayName('Sales Ops System Admin');
        }
	   
        if(!errorMap.Values().isEmpty()){
            mail.setSubject('RollupEnrolledUsersBatch-'+batchType+' Job Failed');
            String msgbody = 'Below are the Ids of ' + errorMap.Values().size() + ' account records that have failed: \n';
            for(Id s: errorMap.keySet()){ msgbody += 'Id : '+s+ ' Error Message : '+errorMap.get(s) +'\n'; }
            mail.setPlainTextBody(msgbody);
        }else if(errorMap.Values().isEmpty()){
            mail.setSubject('RollupEnrolledUsersBatch-'+batchType+' Job Completed ');
            mail.setPlainTextBody('RollupEnrolledUsersBatch Job Completed');
        }
        messageList.add(mail);
        
        if(!Test.isRunningTest()){
            System.debug('----messageList---'+messageList);
        	Messaging.sendEmail(messageList);
        }
    }
}