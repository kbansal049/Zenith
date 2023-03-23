/*****************************************************************************************
Name: CaseCreationFromWebFormsIntegrations
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Restful Service Class to create case from Public Form and other Web Forms
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Anup Dhole           09-14-2022      Initial Version
******************************************************************************************/
@RestResource(urlMapping = '/createCaseServiceSf/*')
global without sharing class CaseCreationFromWebFormsIntegration {
    @HttpPost
    global static String createCaseService(){
        try{
            String dmlResult = '';
        	RestRequest request = RestContext.request;
            String requestBody = request.requestBody.toString();
            Map<String, Object> requestInformation = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
            //system.debug('Specific Param --->'+requestInformation.get('Receiver_Email__c'));
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get('Case_Integration__c');
            Schema.DescribeSObjectResult r = sobjType.getDescribe();
            Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
            system.debug('MapofField--->'+ MapofField);
            //if(requestInformation.containsKey('External_Id__c'))
            Case_Integration__c csInt = new Case_Integration__c();
            for(String fieldName : MapofField.keySet()) {
                Schema.SObjectField ss = MapofField.get(fieldName);
                String fieldapiName = ss.getDescribe().getName();
                
                if(requestInformation.containsKey(fieldapiName)){
                    Object parameterValue = requestInformation.get(fieldapiName);
                    //system.debug('Request Response--->'+parameterValue);
                    if(String.valueOf(ss.getDescribe().getType()) == 'DATETIME'){
                        String currDateTime = String.valueOf(parameterValue);
                        //Logic need to be added here for date time conversion and assignment
                    }else{
                        csInt.put(fieldapiName, parameterValue);    
                    }
                    
                }
            }
            system.debug('Case Integration Record--->'+csInt);
            List<Case_Integration__c> csIntList = new List<Case_Integration__c>{csInt};
            Schema.SObjectField f = Case_Integration__c.Fields.External_Id__c;
            TriggerUtility.caseIntegartionExecutedSetTrue();
            TriggerUtility.caseCaseIntegartionPatchSetTrue();
            csInt.Case_Creation_Status__c = 'Not started';
            if(csInt.External_Id__c !=null && csInt.External_Id__c!=''){
                Database.upsert(csIntList,f,false);
            }
            else{
                Database.insert(csIntList, false);
            }
            Boolean fireEvent = false;
            if(!csIntList.isEmpty() && csIntList[0].Id != null){
                dmlResult =  csIntList[0].Id;
                fireEvent = true;
            }else{
                dmlResult = 'Error in Case Integration creation';
            }
            if(fireEvent){
                Case_Creation_Event__e evn = new Case_Creation_Event__e();
                evn.Case_Integration_Id__c = dmlResult;
                Database.SaveResult eventPub = EventBus.publish(evn);
                if(eventPub.isSuccess()){
                    system.debug('Event Published');
                }
            }
            return dmlResult;

        }catch(Exception e){
            return e.getMessage();
        }
    }
}