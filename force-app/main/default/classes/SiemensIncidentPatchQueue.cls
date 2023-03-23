public class SiemensIncidentPatchQueue implements queueable,Database.AllowsCallouts {
    //For Input
    private  Map<Id, Case_Integration__c> csiMap = new Map<Id, Case_Integration__c>();
    
    private  Boolean isAttachment = false;
    
    //constructors
    public SiemensIncidentPatchQueue(Map<Id, Case_Integration__c> passedMap) {
        System.debug('--SiemensIncidentPatchQueue--passedMap--'+passedMap);
        this.csiMap = passedMap;
    }
    
    public SiemensIncidentPatchQueue(Map<Id, Case_Integration__c> passedMap, Boolean isAttach) {
        System.debug('--SiemensIncidentPatchQueue--passedMap--'+passedMap);
        csiMap = passedMap;
        this.isAttachment = isAttach;
    }
    
    //executes the queueable logic
    public void execute(QueueableContext qc) {
        
        System.debug('--SiemensIncidentPatchQueue--csiMap--'+csiMap);
        System.debug('--SiemensIncidentPatchQueue--isAttachment--'+isAttachment);
        
        if(csiMap != null && csiMap.size()>0){
            List<Case_Integration__c> csiupdate = new  List<Case_Integration__c>();
            if(isAttachment){
                Set<Id> setOfCId = new Set<Id>();
                for(ID cv : csiMap.keyset()){
                    if(csiMap.get(cv) != null){
                        Case_Integration__c ci = callOutSiemensPatchIntegrationAttachMent(cv,csiMap.get(cv));
                        if(ci.id != null  && !setOfCId.contains(ci.id))
                            csiupdate.add(ci);
                        	setOfCId.add(ci.id);
                    }
                } 
            }else{
                for(Case_Integration__c csi : csiMap.values()){
                    Case_Integration__c ci = callOutSiemensPatchIntegration(csi);
                    if(ci.id != null)
                        csiupdate.add(ci);
                }
            }
            
            
            //Importnant Step to break the Loop
            TriggerUtility.caseIntegartionExecutedSetTrue();
            TriggerUtility.caseCaseIntegartionPatchSetTrue();
            
            update csiupdate;
        }
    }
    
    //CR# 318 : SFDC--Boomi--AmberRoad 
    public static Case_Integration__c callOutSiemensPatchIntegration(Case_Integration__c ci) {
        
        System.debug('--callOutSiemensPatchIntegration--ci--'+ci);
        System.debug('--callOutSiemensPatchIntegration--ci.Patch_Source__c--'+ci.Patch_Source__c);
        
        Case_Integration__c csi = new  Case_Integration__c();
        
        if(ci.External_ID__c != null && ci.id != null){
            
            csi = new Case_Integration__c(id=ci.id,External_ID__c = ci.External_ID__c);
            
            try {
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeBooleanField('isAttachment', false);
                gen.writeStringField('IncidentNumber', csi.External_ID__c);
                gen.writeStringField('PatchSource', ci.Patch_Source__c != null ? ci.Patch_Source__c : '');
                gen.writeStringField('ContentVersionId', '');
                gen.writeEndObject();
                String jsonString = gen.getAsString();
                /*HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setEndpoint('callout:Siemens_Incident_Patch');
                req.setMethod('POST');
                req.setBody(jsonString);
                req.setTimeout(60000);
                
                Http http = new Http();
                HttpResponse response = null;
                System.debug('----request---'+req);
                System.debug('----request body---'+jsonString);
                
                if (!Test.isRunningTest()) {
                    response = http.send(req);
                }else{
                    response = new HttpResponse();
                    response.setStatusCode(200);
                }
                system.debug('----response---'+response);
                
                if (response.getStatusCode() == 200) {
                    csi.Integration_Status__c = 'Initiated';
                    csi.Integration_Error__c = '';
                }else {
                    csi.Integration_Status__c  = 'Failed';
                    csi.Integration_Error__c = 'Error -'+response.getBody();
                }*/
                Workato_Generic_Event__e evn = new Workato_Generic_Event__e();
                evn.Process__c = 'Siemens Patch';
                evn.Object_API_Name__c = 'Case_Integration__c';
                evn.Additional_Detail__c = jsonString;
                Database.SaveResult eventPub = EventBus.publish(evn);
                if(eventPub.isSuccess()){
                    csi.Integration_Status__c = 'Initiated';
                    csi.Integration_Error__c = '';
                }else{
                    csi.Integration_Status__c = 'Failed';
                    csi.Integration_Error__c = 'Siemens Platform Event Publish Failed';
                }
                if(csi.is_First_Time_Patch__c == false){
                    csi.is_First_Time_Patch__c = true;
                }
                
            }catch (Exception e) {
                system.debug('---exception---e--'+e.getMessage());
                system.debug('---exception---e--'+e.getStackTraceString());
                csi.Integration_Status__c = 'Failed';
                csi.Integration_Error__c = 'Error -'+e.getMessage();
            }
            
        }
        return  csi;
    }
    
    //CR# 318 : SFDC--Boomi--AmberRoad 
    public static Case_Integration__c callOutSiemensPatchIntegrationAttachMent(ID contentVersionID,Case_Integration__c ci) {
        
        System.debug('--callOutSiemensPatchIntegrationAttachMent--ci--'+ci);
        System.debug('--callOutSiemensPatchIntegrationAttachMent--contentVersionID--'+contentVersionID);
        
        Case_Integration__c csi = new  Case_Integration__c();
        
        if(contentVersionID != null && ci.External_ID__c != null && ci.id != null){
            
            csi = new Case_Integration__c(id=ci.id,External_ID__c = ci.External_ID__c);
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeBooleanField('isAttachment', true);
            gen.writeStringField('IncidentNumber', ci.External_ID__c);
            gen.writeStringField('ContentVersionId', contentVersionID);
            gen.writeEndObject();
            String jsonString = gen.getAsString();
            /*HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setEndpoint('callout:Siemens_Incident_Patch');
            req.setMethod('POST');
            req.setBody(jsonString);
            req.setTimeout(60000);*/
            try {
                /*Http http = new Http();
                HttpResponse response = null;
                System.debug('----request---'+req);
                System.debug('----request body---'+jsonString);
                
                if (!Test.isRunningTest()) {
                    response = http.send(req);
                }else{
                    response = new HttpResponse();
                    response.setStatusCode(200);
                }
                system.debug('----response---'+response);
                
                if (response.getStatusCode() == 200) {
                    csi.Integration_Status__c = 'Initiated';
                    csi.Integration_Error__c = '';
                }else {
                    csi.Integration_Status__c = 'Failed';
                    csi.Integration_Error__c = 'Error -'+response.getBody();
                }*/
            //try{
            	Workato_Generic_Event__e evn = new Workato_Generic_Event__e();
                evn.Process__c = 'Siemens Patch';
                evn.Object_API_Name__c = 'Case_Integration__c';
                evn.Additional_Detail__c = jsonString;
                Database.SaveResult eventPub = EventBus.publish(evn);
                if(eventPub.isSuccess()){
                    csi.Integration_Status__c = 'Initiated';
                    csi.Integration_Error__c = '';
                }else{
                    csi.Integration_Status__c = 'Failed';
                    csi.Integration_Error__c = 'Siemens Platform Event Publish Failed';
                }
            } catch (Exception e) {
                system.debug('---exception---e--'+e.getMessage());
                system.debug('---exception---e--'+e.getStackTraceString());
                csi.Integration_Status__c = 'Failed';
                csi.Integration_Error__c = 'Error -'+e.getMessage();
            }
        }
        return  csi;
    }
}