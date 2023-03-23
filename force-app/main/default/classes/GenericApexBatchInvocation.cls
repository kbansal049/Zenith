@RestResource(urlMapping='/GenericApexBatchInvocation/*')
global with sharing class GenericApexBatchInvocation {
    global static Boolean avoidtriggers = false;
    
    @HttpPost
    //global static Map<String, String> doPost(Map<String,Account> acclst, List<Opportunity> opptylst, List<Partner> oppartlst, Boolean isparentUPsame) {
    global static void doPost(String BatchClassName) {
        String Returnmessage='';
        Integer returnresponsecode=200;
        system.debug('BatchClassName '+BatchClassName);
        RestResponse restRes = RestContext.response;
        
        if(BatchClassName!=null && BatchClassName!=''){
            Type cls = Type.forName(BatchClassName);
            if(cls!=null){
                if(BatchClassName=='DeleteTechPartnerUsageRecordsBatch'){
                    //Technology_Partner_Usage__c,Tech_Partner_Usage_Placeholder__c
                    DeleteTechPartnerUsageRecordsBatch btch= new DeleteTechPartnerUsageRecordsBatch('Technology_Partner_Usage__c');
                    database.executeBatch(btch);
                    Returnmessage='Request for the batch class has been successfully invoked';
                    restRes.statusCode=200;
                    
                }
                if(BatchClassName=='CreateTechPartnerRecordsBatch'){
                    Database.Batchable<sObject> obj = (Database.Batchable<sObject>) cls.newInstance();
                    Database.executeBatch(Obj);
                    Returnmessage='Request for the batch class has been successfully invoked';
                    restRes.statusCode=200;
                }
                if(BatchClassName=='UpdateZscalerCloudIDRecordsBatch'){
                    Database.Batchable<sObject> obj = (Database.Batchable<sObject>) cls.newInstance();
                    Database.executeBatch(Obj);
                    Returnmessage='Request for the batch class has been successfully invoked';
                    restRes.statusCode=200;
                }               
            }else{
                Returnmessage='Invalid Request. Please provide valid class name';
                restRes.statusCode=404;
            }
        }else{
            Returnmessage='Invalid Input. Please provide class name';
            if(!test.isrunningtest()){
                restRes.statusCode=400;
            }
        }
        
        GeneralResponse resp= new GeneralResponse();
        resp.responsemessage=Returnmessage;
        resp.Apexclassname=BatchClassName;
       
        //restRes.statusCode = returnresponsecode;
        restRes.responseBody = Blob.valueOf(JSON.serialize(resp));
            
        //return Returnmessage;       
    }
    
     global class GeneralResponse {
        String responsemessage;
        String Apexclassname;
    }
}