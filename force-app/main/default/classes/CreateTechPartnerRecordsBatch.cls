public class CreateTechPartnerRecordsBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CreateTechPartnerRecordsBatch');
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    //String Query = '';
    String ObjectName = 'Tech_Partner_Usage_Placeholder__c';
    

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        Set<id> tempidset= new Set<id>();
        tempidset.add('aMz520000005Q70');
        //String query = 'Select Id from ' +ObjectName +' where Zscaler_Cloud_ID__c!=null and Cloud_usage_Record_created__c=false';
        String query = 'Select Id,External_Id__c from Tech_Partner_Usage_Placeholder__c where Tech_Partner_Usage_record_created__c=false';
        //String query = 'Select Id from ' +ObjectName +' where ID IN:tempidset and Zscaler_Cloud_ID__c!=null ';
        system.debug('query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<Tech_Partner_Usage_Placeholder__c> sobjectlist){
        this.zb.callExecute(sobjectlist[0]?.Id, sobjectlist.size());
        system.debug('inside execute method');
         Map<String,String> ExternalIdandIDmap= new Map<String,String>();
        Set<string> ExternalIdSet= new Set<string>();
        Set<id> Setofids= new Set<id>();
        for(Tech_Partner_Usage_Placeholder__c obj: sobjectlist){
            Setofids.add(obj.id);
            ExternalIdSet.add(obj.External_Id__c);
        }
        system.debug('Setofids  '+Setofids ); 
        system.debug('ExternalIdSet  '+ExternalIdSet ); 
        
        //Query existing Tech Partner Usage records to find which we dont have override
        Map<string,Technology_Partner_Usage__c> existingTPUmap= new Map<string,Technology_Partner_Usage__c>();      
        for(Technology_Partner_Usage__c tpu:[select id,External_Id__c from Technology_Partner_Usage__c where External_Id__c IN:ExternalIdSet and Do_Not_Override__c=true]){
            existingTPUmap.put(tpu.External_Id__c,tpu);
        }
        system.debug('existingTPUmap  '+existingTPUmap); 

        String fieldstoaddinquery='';
        String type='TechPartnerUsage';
        List<Technology_Partner_Usage__c> TPUListtoInsert= new List<Technology_Partner_Usage__c>();
        Map<String,String> fieldsmappingsMap= new Map<String,String>();
       
        
        List<Cloud_Usage_field_Mapping__mdt> CUMdts=[select id,Cloud_Usage_field_API__c,Cloud_Usage_Type__c,ZIA_ZPA_Cloud_Usage_Data_field__c,Tech_Partner_Usage_field_API__c,Tech_Partner_Placeholder_field_API__c from Cloud_Usage_field_Mapping__mdt where IsActive__c=true and Cloud_Usage_Type__c=:type];
        for(Cloud_Usage_field_Mapping__mdt mdt:CUMdts){
                fieldsmappingsMap.put(mdt.Tech_Partner_Placeholder_field_API__c,mdt.Tech_Partner_Usage_field_API__c);
                if(mdt.Tech_Partner_Usage_field_API__c!=''){
                    system.debug('field is not blank');
                    fieldstoaddinquery=fieldstoaddinquery+ ',' +mdt.Tech_Partner_Placeholder_field_API__c;
                    system.debug('fieldstoaddinquery '+fieldstoaddinquery);
                }
        }
        system.debug('fieldsmappingsMap '+fieldsmappingsMap);
        String FinalQuery='SELECT id' + fieldstoaddinquery + ' FROM ' +ObjectName+' where id IN:Setofids and Tech_Partner_Usage_record_created__c=false';
        system.debug('FinalQuery '+FinalQuery);
        List<sObject> resultset  = new List<sObject>();
        resultset = Database.Query(FinalQuery);
        
        for(sobject sobj:resultset){
            system.debug('sobj '+sobj);
            system.debug('sobj.get(External_Id__c) '+sobj.get('External_Id__c'));
            ExternalIdandIDmap.put((string)sobj.get('External_Id__c'),(string)sobj.get('id'));
            if(!existingTPUmap.containskey((string)sobj.get('External_Id__c'))){
                system.debug('inside if');
                Technology_Partner_Usage__c tpu= new Technology_Partner_Usage__c();
                for(String str:fieldsmappingsMap.keyset()){
                    system.debug('str   '+str);
                    system.debug('fieldsmappingsMap value '+fieldsmappingsMap.get(str));
                    system.debug('details from sobj '+sobj.get(str));
                    if(str=='Org_ID__c' || str=='Customer_Account__c' || str=='Technology_Partner_Id__c'){
                        system.debug('inside if');
                        string temp=(string)sobj.get(str);
                        system.debug('temp'+temp);
                        tpu.put(fieldsmappingsMap.get(str),sobj.get(str));                           
                    }else{
                        tpu.put(fieldsmappingsMap.get(str),sobj.get(str));
                    }                                       
                }
                system.debug('tpu    '+tpu);
                TPUListtoInsert.add(tpu);
            }else{
                system.debug('existingTPUmap contains TPU ');
            }
        }
        system.debug('TPUListtoInsert '+TPUListtoInsert);
        Database.SaveResult[] results = database.insert(TPUListtoInsert, false);
        system.debug('results '+results);
       
        Set<String> TechPartnerusagePassed = new Set<String>();
        Set<String> TechPartnerusageFailed = new Set<String>();
         List<Tech_Partner_Usage_Placeholder__c> updatePlaceholderrecords= new List<Tech_Partner_Usage_Placeholder__c>();
         for (Integer i = 0;i<TPUListtoInsert.size();i++) {
            if(results.get(i).isSuccess()){
                system.debug('success');
                // Operation was successful, so get the ID of the record that was processed
                //successlst.add(sr.getId());
                successlst.add((id)TPUListtoInsert.get(i).id);
                TechPartnerusagePassed.add((String)TPUListtoInsert.get(i).External_Id__c);
                
                Tech_Partner_Usage_Placeholder__c tpp= new Tech_Partner_Usage_Placeholder__c(id=ExternalIdandIDmap.get(TPUListtoInsert[i].External_Id__c),External_Id__c=TPUListtoInsert[i].External_Id__c,Tech_Partner_Usage_record_created__c=true);
                updatePlaceholderrecords.add(tpp);
                    
            }
            else {
                system.debug('fail');
                for(Database.Error err : results.get(i).getErrors()) {
                    errorlst.add(results.get(i).getid() + ' - ' + err.getMessage());
                    
                    Tech_Partner_Usage_Placeholder__c tpp= new Tech_Partner_Usage_Placeholder__c(id=ExternalIdandIDmap.get(TPUListtoInsert[i].External_Id__c),External_Id__c=TPUListtoInsert[i].External_Id__c,Tech_Partner_Usage_record_created__c=false,Tech_Partner_creation_Process_failed__c=true,Error_Message__c=err.getMessage());
                    system.debug('tpp '+tpp);
                    updatePlaceholderrecords.add(tpp);
                }
                //errorlst.add(sr.getId() + ' - ' + err.getMessage());
            }
        }
    
        system.debug('successlst '+successlst);     
        system.debug('errorlst '+errorlst); 
                               
        /* for(sobject sobj:resultset){
            if(TechPartnerusagePassed.contains((string)sobj.get('External_Id__c'))){
                system.debug('inside if');
                Tech_Partner_Usage_Placeholder__c tpp= new Tech_Partner_Usage_Placeholder__c(id=(id)sobj.get('id'),External_Id__c=(string)sobj.get('External_Id__c'),Tech_Partner_Usage_record_created__c=true);
                updatePlaceholderrecords.add(tpp);
            }
            
        }    */        
        if(!updatePlaceholderrecords.isempty() && updatePlaceholderrecords.size()>0){
            update updatePlaceholderrecords;
        }
        system.debug('updatePlaceholderrecords '+updatePlaceholderrecords);
        
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
               
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Tech Partner Usage Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Tech Partner Usage Batch Success result ');
            mail.setPlainTextBody('Tech Partner Usage Batch has been executed Successfully and processed '+ successlst.size() + ' records');
            messageList.add(mail);
        }
        if(!test.isrunningtest()){ Messaging.sendEmail(messageList);
        }
    }
    
}