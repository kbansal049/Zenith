public class CreateCloudUsageRecordsBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CreateCloudUsageRecordsBatch');
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    //String Query = '';
    String ObjectName = '';
    
    public CreateCloudUsageRecordsBatch(String objName){ //,String Eventquery
        ObjectName = objName;
        //Query=Eventquery;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        Set<id> tempidset= new Set<id>();
        tempidset.add('aMz520000005Q70');
        String query = 'Select Id from ' +ObjectName +' where Zscaler_Cloud_ID__c!=null and Cloud_usage_Record_created__c=false';
        //String query = 'Select Id from ' +ObjectName +' where ID IN:tempidset and Zscaler_Cloud_ID__c!=null ';
        system.debug('query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<sobject> sobjectlist){
        this.zb.callExecute(sobjectlist[0]?.Id, sobjectlist.size());
        system.debug('inside execute method');
        Set<id> Setofids= new Set<id>();
        for(sObject sobj: sobjectlist){
            Setofids.add(sobj.id);
        }
        system.debug('Setofids  '+Setofids ); 
        String type='';
        if(ObjectName=='ZPA_Cloud_Usage_data__c'){
            type='ZPA';
        }else if(ObjectName=='ZIA_Cloud_Usage_data__c'){
            type='ZIA';
        }
        system.debug('type '+type);
        String ZIAfieldsquery='';
        String ZPAfieldsquery='';
        String fieldstoaddinquery='';
        List<Cloud_Usage__c> CloudUsageListtoInsert= new List<Cloud_Usage__c>();
        Map<String,String> ZIAfieldsmappings= new Map<String,String>();
        Map<String,String> ZPAfieldsmappings= new Map<String,String>();
        Map<String,String> ZIAZPAfieldsmappings= new Map<String,String>();
        
        List<Cloud_Usage_field_Mapping__mdt> CUMdts=[select id,Cloud_Usage_field_API__c,Cloud_Usage_Type__c,ZIA_ZPA_Cloud_Usage_Data_field__c from Cloud_Usage_field_Mapping__mdt where IsActive__c=true and Cloud_Usage_Type__c=:type];
        for(Cloud_Usage_field_Mapping__mdt mdt:CUMdts){
                ZIAZPAfieldsmappings.put(mdt.ZIA_ZPA_Cloud_Usage_Data_field__c,mdt.Cloud_Usage_field_API__c);
                if(mdt.Cloud_Usage_field_API__c!=''){
                    system.debug('field is not blank');
                    fieldstoaddinquery=fieldstoaddinquery+ ',' +mdt.ZIA_ZPA_Cloud_Usage_Data_field__c;
                    system.debug('ZPAfieldsquery '+ZPAfieldsquery);
                }
        }
        system.debug('ZIAZPAfieldsmappings '+ZIAZPAfieldsmappings);
        String FinalQuery='SELECT id' + fieldstoaddinquery + ' FROM ' +ObjectName+' where id IN:Setofids';
        system.debug('FinalQuery '+FinalQuery);
        List<sObject> resultset  = new List<sObject>();
        resultset = Database.Query(FinalQuery);
        
        Set<String> ZscalerCloudidSet= new Set<String>();
        Map<string,id> ZscalerCloudidMap= new Map<string,id>();
        String zscloudidName='Zscaler_Cloud_ID__c';
        
        for(sobject sobj:resultset){
            system.debug('sobj '+sobj);
            Cloud_Usage__c cu= new Cloud_Usage__c();
            cu.Cloud_Usage_Type__c=type;
                for(String str:ZIAZPAfieldsmappings.keyset()){
                    system.debug('str   '+str);
                    system.debug('ZIAZPAfieldsmappings value '+ZIAZPAfieldsmappings.get(str));
                    system.debug('details from sobj '+sobj.get(str));
                    if(str=='Zscaler_Cloud_ID__c'){
                        system.debug('inside if');
                        string temp=(string)sobj.get(str);
                        system.debug('temp'+temp);
                        /* if(ObjectName=='ZPA_Cloud_Usage_data__c'){
                            cu.put(ZIAZPAfieldsmappings.get(str),ZscalerCloudidMap.get((string)sobj.get(str)));
                        }else {} */
                            
                        //if(ObjectName=='ZIA_Cloud_Usage_data__c'){
                            cu.put(ZIAZPAfieldsmappings.get(str),sobj.get(str));
                        //}
                            
                    }else{
                        cu.put(ZIAZPAfieldsmappings.get(str),sobj.get(str));
                    }
                                        
                }
                system.debug('cu    '+cu);
                CloudUsageListtoInsert.add(cu);
        }
        system.debug('CloudUsageListtoInsert '+CloudUsageListtoInsert);
        Database.SaveResult[] results = database.insert(CloudUsageListtoInsert, false);
        system.debug('results '+results);
       
       TriggerUtility.SkipAccTriggerExecuted();
       
        Set<String> ZIAZPAcloudusagePassed = new Set<String>();
        for (Integer i = 0;i<CloudUsageListtoInsert.size();i++) {
            if(results.get(i).isSuccess()){
                system.debug('success');
                // Operation was successful, so get the ID of the record that was processed
                //successlst.add(sr.getId());
                successlst.add((id)CloudUsageListtoInsert.get(i).id);
                ZIAZPAcloudusagePassed.add((String)CloudUsageListtoInsert.get(i).Cloud_Usage_External_Id__c);
            }
            else {
                system.debug('fail');
                for(Database.Error err : results.get(i).getErrors()) {
                    errorlst.add(results.get(i).getid() + ' - ' + err.getMessage());
                }
                //errorlst.add(sr.getId() + ' - ' + err.getMessage());
            }
        }
    
        system.debug('successlst '+successlst);     
        system.debug('errorlst '+errorlst); 
                
        List<ZPA_Cloud_Usage_data__c> updateZPACloudusagerecords= new List<ZPA_Cloud_Usage_data__c>();
        List<ZIA_Cloud_Usage_data__c> updateZIACloudusagerecords= new List<ZIA_Cloud_Usage_data__c>();
        
        if(ObjectName=='ZPA_Cloud_Usage_data__c'){          
            for(sobject sobj:resultset){
                if(ZIAZPAcloudusagePassed.contains((string)sobj.get('Cloud_Usage_External_Id__c'))){
                    system.debug('inside if');
                    ZPA_Cloud_Usage_data__c zpa= new ZPA_Cloud_Usage_data__c(id=(id)sobj.get('id'),Cloud_Usage_External_Id__c=(string)sobj.get('Cloud_Usage_External_Id__c'),Cloud_usage_Record_created__c=true);
                    updateZPACloudusagerecords.add(zpa);
                }
                
            }           
        }else if(ObjectName=='ZIA_Cloud_Usage_data__c'){
            for(sobject sobj:resultset){
                if(ZIAZPAcloudusagePassed.contains((string)sobj.get('Externalid__c'))){
                        system.debug('inside if');
                        ZIA_Cloud_Usage_data__c zpa= new ZIA_Cloud_Usage_data__c(id=(id)sobj.get('id'),Externalid__c=(string)sobj.get('Externalid__c'),Cloud_usage_Record_created__c=true);
                        updateZIACloudusagerecords.add(zpa);
                }
            }
        }
        if(!updateZPACloudusagerecords.isempty() && updateZPACloudusagerecords.size()>0){
            update updateZPACloudusagerecords;
        }
        system.debug('updateZPACloudusagerecords '+updateZPACloudusagerecords);
        if(!updateZIACloudusagerecords.isempty() && updateZIACloudusagerecords.size()>0){
            update updateZIACloudusagerecords;
        }
        system.debug('updateZIACloudusagerecords '+updateZIACloudusagerecords);
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Cloud Usage Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){
                msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Cloud Usage Batch Success result ');
            mail.setPlainTextBody('Cloud Usage Batch has been executed Successfully and processed '+ successlst.size() + ' records');
            messageList.add(mail);
        }
        if(!test.isrunningtest()){
            Messaging.sendEmail(messageList);
        }
    }
    
}