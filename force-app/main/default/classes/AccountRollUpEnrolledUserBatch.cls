global class AccountRollUpEnrolledUserBatch implements Database.Batchable<sObject>,Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('AccountRollUpEnrolledUserBatch');
    
    global final String query;
    global Map<Id,String> errorMap;
    global Account acctInfo;
	  
    global AccountRollUpEnrolledUserBatch(String q)
    {
        query = q;
        errorMap = new Map<Id,String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> records){
        this.zb.callExecute(records[0]?.Id, records.size());
        
        List<Account> accList = new List<Account>();
        Map< Id, Decimal> L31Map = new Map< Id, Decimal>();
        Map< Id, Decimal> L6Map = new Map< Id, Decimal>();
        Map< Id, Decimal> L90Map = new Map< Id, Decimal>();
        Map< Id, Integer> countMap = new Map< Id, Integer>();
        Map< Id, Decimal> L14Map = new Map< Id, Decimal>();    //Added by Ayush Kangar as part of CR# 2872
        Map<Id, Decimal> L14cuMap = new Map<Id,Decimal>();
        List<Zscaler_Cloud_ID__c> ZCloudIdToUpdate = new List<Zscaler_Cloud_ID__c>();
        
        
        for (Account acc : records)  
        {
            acctInfo = acc;
            
            //CR# 2841 -- added Filter -- Usage_Pull_Date__c  != null 
            List<Zscaler_Cloud_ID__c> zTenants = [SELECT ID,ZPA_Active_Users_L31D_RollUp__c,ZPA_Active_Users_L90D_RollUp__c,ZPA_Active_Users_L14D__c,
                                                  (select id,ZPA_last_14_days__c FROM Cloud_Usage_Object__r WHERE  Usage_Pull_Date__c  != null AND Cloud_Usage_Type__c = 'ZPA' order by Usage_Pull_Date__c desc limit 1)
                                             FROM Zscaler_Cloud_ID__c WHERE  Account__c = :acc.Id and Cloud_Type__c = 'ZPA'];   //Updated by Ayush Kangar as part of CR# 2872

            //Added by Ayush Kangar as part of CR# 3200 - Start
            for (Zscaler_Cloud_ID__c cid : zTenants)  {
                for(Cloud_Usage__c bd : cid.Cloud_Usage_Object__r){
                    cid.ZPA_Active_Users_L14D__c = bd.ZPA_last_14_days__c;
                    ZCloudIdToUpdate.add(cid);
                }
            } 
            if(ZCloudIdToUpdate.size()>0){
                update ZCloudIdToUpdate;
            }
            //Added by Ayush Kangar as part of CR# 3200 - End
            for (Zscaler_Cloud_ID__c cid : zTenants)  {
                
                //L31Map.put( acc.Id , L31Map.containsKey(acc.Id) ? L31Map.get(acc.Id)  + checknull(cid.ZPA_Enrolled_Users_L31D_Rollup__c): checknull(cid.ZPA_Enrolled_Users_L31D_Rollup__c));
                L31Map.put( acc.Id , L31Map.containsKey(acc.Id) ? L31Map.get(acc.Id)  + checknull(cid.ZPA_Active_Users_L31D_RollUp__c): checknull(cid.ZPA_Active_Users_L31D_RollUp__c) );
                
                //L6Map.put( acc.Id , L6Map.containsKey(acc.Id) ? L6Map.get(acc.Id)  + checknull(cid.ZPA_Enrolled_Users_L6M_Rollup__c) : checknull(cid.ZPA_Enrolled_Users_L6M_Rollup__c) );
                //L6Map.put( acc.Id , 0); // Commented by Gurjinder: CR# 682
                
                //L90Map.put( acc.Id , L90Map.containsKey(acc.Id) ? L90Map.get(acc.Id)  + checknull(cid.ZPA_Enrolled_Users_L90D_Rollup__c) : checknull(cid.ZPA_Enrolled_Users_L90D_Rollup__c) );
                L90Map.put( acc.Id , L90Map.containsKey(acc.Id) ? L90Map.get(acc.Id)  + checknull(cid.ZPA_Active_Users_L90D_RollUp__c) : checknull(cid.ZPA_Active_Users_L90D_RollUp__c) );
                
                //Added by Ayush Kangar as part of CR# 2872
                L14Map.put( acc.Id , L14Map.containsKey(acc.Id) ? L14Map.get(acc.Id)  + checknull(cid.ZPA_Active_Users_L14D__c): checknull(cid.ZPA_Active_Users_L14D__c) );
                
                if(countMap.containsKey(acc.Id))
                    countMap.put( acc.Id, countMap.get(acc.Id) + 1);
                else 
                    countMap.put( acc.Id, 1);
                    
            }
            
            if(zTenants.size() > 0) {
                acc.ZPA_Enrolled_Users_L31D__c = L31Map.get(acc.Id) ;/// countMap.get(acc.Id)
                //acc.ZPA_Enrolled_Users_L6M__c = L6Map.get(acc.Id)/ countMap.get(acc.Id);  // Commented by Gurjinder: CR# 682
                acc.ZPA_Enrolled_Users_L90D__c = L90Map.get(acc.Id); /// countMap.get(acc.Id)
                acc.ZPA_Enrolled_Users_L14D__c = L14Map.get(acc.Id) ;  //Added by Ayush Kangar as part of CR# 2872
                accList.add(acc);
            } else {
                acc.ZPA_Enrolled_Users_L31D__c = 0;
                //acc.ZPA_Enrolled_Users_L6M__c = 0;  // Commented by Gurjinder: CR# 682
                acc.ZPA_Enrolled_Users_L90D__c = 0;
                acc.ZPA_Enrolled_Users_L14D__c = 0;    //Added by Ayush Kangar as part of CR# 2872
                accList.add(acc);
            }
        }
        
        if(!accList.isEmpty())
        {
            try {
                update accList;
            } 
            catch(Exception ex)
            {
                System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
                errorMap.put(accList.get(0).Id,ex.getMessage() + ' at Line No. ' + ex.getLineNumber()); 
                ZscalerErrorLogsUtility.insertlogsForAsync('AccountRollUpEnrolledUserBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
            }
            
        }
    }    

    global void finish(Database.BatchableContext bc)
    {
        this.zb.callFinish(bc);
        System.debug('--errorMap--'+errorMap);
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        if(!errorMap.Values().isEmpty() || Test.isRunningTest()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {mail1.setOrgWideEmailAddressId(owea[0].Id); }
             else{ mail1.setsenderDisplayName('Sales Ops System Admin'); }
            mail1.setSubject('ZPA Rollup Enrolled User Batch Job Failed');
            String msgbody = 'Below are the Ids of ' + errorMap.Values().size() + ' account records that have failed: \n';
            for(Id s: errorMap.keySet()){ msgbody += 'Id : '+s + ' Error Message : '+errorMap.get(s) +'\n'; }
            mail1.setPlainTextBody(msgbody);messageList.add(mail1);
        }
        if(errorMap.Values().isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('ZPA Rollup Enrolled User Batch Job Completed ');
            mail.setPlainTextBody('ZPA Rollup Enrolled User Batch Job Completed');
            messageList.add(mail);
        }
        
            Messaging.sendEmail(messageList);
       //Commenting out the CustomerRenewalReminderBatch call as part of #CR 4382 by Karthik
        //System.Database.executeBatch(new CustomerRenewalReminderBatch()); //Added by Swathi CR# 2742 to resolve schedule batch limit issue
        
        
    } 
    
    global Decimal checknull(Decimal value) {
        if(value != null) 
            return value;
        return 0.0;
    }
}