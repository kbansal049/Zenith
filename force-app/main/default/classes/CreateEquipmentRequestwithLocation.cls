public with Sharing class CreateEquipmentRequestwithLocation {
    
    Id partnerDCRecordTypeId = Schema.SObjectType.Datacenter__c.getRecordTypeInfosByDeveloperName().get('Partner_Datacenter').getRecordTypeId();
    
    public Equipment_Request__c eReq {get; set;}
    public list<Datacenter__c> datacenterlst{get; set;}
    public String indextoRemove{get;set;}
    public List<SelectOption> reqHWmodel{get;set;}
    public List<SelectOption> dcRecTypeOptions{get;set;}
    public String rectypeDC{get; set;}
    public Boolean isedit{get; set;}
    public Boolean isinApproval{get; set;}
    public String erBanner{get; set;}
    public String GEvalue{get; set;}
    Map<String,string> urlparams; 
    String profname = '';
    
    public String architectureWorkshopLink{get; set;}    
	public Boolean isDedicated_LB_quantityReadOnly{get; set;}
    public Boolean isService_Edge_CalculatorReadOnly{get; set;}
    public List<DataCenterWarapper> dataCenterWarapperList{get; set;}
    List<DataCenterWarapper> dcWrapperListToDelete;
        
    public CreateEquipmentRequestwithLocation(ApexPages.StandardController controller) {
        
        GEvalue = '';
        erBanner = 'Equipment Request Form';
        urlparams = ApexPages.currentPage().getParameters();
        if (!Test.isRunningTest()) controller.addFields(new String[]{
			'Architecture_Workshop_Link__c'
		});
        eReq = (Equipment_Request__c )controller.getRecord();
        isedit = ereq.Id != null;
        
        if((ereq.Id != null && ereq.Opportunity__c != null) || (urlparams.containsKey('CF00N70000002s1R1_lkid') && urlparams.get('CF00N70000002s1R1_lkid') != null && urlparams.get('CF00N70000002s1R1_lkid') != '')){
            String oppId = ereq.Opportunity__c != null? ereq.Opportunity__c : urlparams.get('CF00N70000002s1R1_lkid');
            List<Opportunity> opplst = [Select Id, name from Opportunity where Id = :oppId];
            if(!opplst.isEmpty()){
                erBanner += ' for ' + opplst[0].name;
            }
            getOpportunity();//Pre-Populate Architecture_Workshop_Link__c
        }
        datacenterlst = new list<Datacenter__c>();
        dataCenterWarapperList = new List<DataCenterWarapper>();
        dcWrapperListToDelete = new List<DataCenterWarapper>();
        
        String developerName = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosById().get(eReq.RecordTypeId).getDeveloperName();
        if(developerName == 'PZEN'){
            eReq.Equipment_type__c = 'Private ZEN (Existing PZEN customers only)';
            isDedicated_LB_quantityReadOnly = TRUE;
        }else if(developerName == 'Private_ZEN_with_LB'){
            eReq.Equipment_type__c = 'Private ZEN with LB (Existing PZEN customers only)';
            isDedicated_LB_quantityReadOnly = FALSE;
        }else if(developerName == 'ZIA_Service_Edge_PZEN'){
            eReq.Equipment_type__c = 'ZIA Service Edge  ';
            isDedicated_LB_quantityReadOnly = TRUE;
        }else {
            isDedicated_LB_quantityReadOnly = TRUE;
        }
        
        reqHWmodel = new List<SelectOption>();
        if(developerName != 'Cavium_Card'){		// Added by Ayush Kangar as part of CR# 3719 - Start
        for(String s: Requested_Hardware_Model_Values__c.getValues(developerName).Values__c.split(';')){
            reqHWmodel.add(new SelectOption(s,s));
        }
        }
        dcRecTypeOptions = new List<SelectOption>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Datacenter__c;
        List<Schema.RecordTypeInfo> RT = d.getRecordTypeInfos();
        for( Schema.RecordTypeInfo recordType : RT )
        {
            if(recordType != null && recordType.isAvailable()){ 
                String val = recordType.getName();
                if(val != null && val != '' && val != 'Master') {
                    dcRecTypeOptions.add(new SelectOption(val , val ));
                }
            }
        }

    }
    
    public void pageLoad(){
        if(eReq.Id != null){
            architectureWorkshopLink = eReq.Architecture_Workshop_Link__c;//Pre-Populate Architecture_Workshop_Link__c            
            for(Datacenter__c dcRecord : [select id, Account__c, Facility_Address__c, Shipping_Address__c, Customer_Contact__c, 
                                          name, Equipment_Request__c, Quantity_Requested_for_LB__c, Facility_Country__c, Facility_City__c, 
                                          Requested_Hardware_Model__c, Quantity_Requested__c, Available_Bandwidth_MBPS__c, Download_throughput_ServiceEdge_Gbps__c,
                                          Reason_for_Pitching_PZEN__c, Number_of_Users_at_location__c, Is_latency_less_than_300_milliseconds__c, 
                                          Link_to_Architecture_Workshop__c, Shipment_Receiving_Contact_Name__c, Shipment_Receiving_contact_Email__c, 
                                          Shipment_Receiving_Contact_Ph_No__c, Project_Manager_Name__c, Project_Manager_Phone_No__c, 
                                          Projet_Manager_Email_Address__c,Please_provide_more_information__c, Host_partner_Name__c, RecordTypeId 
                                          FROM Datacenter__c 
                                          WHERE Equipment_Request__c = :eReq.Id]){
                                              DataCenterWarapper dcWrapperObj = new DataCenterWarapper();
                                              dcWrapperObj.dataCenterRecord = dcRecord;                                              
                                              dcWrapperObj.isDedicatedLBQuantityReadOnly = dcRecord.Requested_Hardware_Model__c == 'ZIA Service Edge-5 + LB (>5Gbps only)' ? FALSE : TRUE;                                            
                                              dcWrapperObj.isHostPartnerNameRequired = dcRecord.RecordTypeId == partnerDCRecordTypeId ? TRUE : FALSE;
                                              dcWrapperObj.isDCRemoved = FALSE;
                                              
                                              dataCenterWarapperList.add(dcWrapperObj);
                                          }            
        }else {
            eReq.Service_Edge_Calculator__c = System.Label.Service_Edge_Calculator;
        }
        List<Profile> profilelst = [Select Id, Name from Profile where Id = :userinfo.getProfileId()];        
        if(!profilelst.isEmpty()){
            profname = profilelst[0].name;
        }
        isinApproval = profname != 'System Administrator' && (eReq.Approval_Status__c == 'Approved' || eReq.Approval_Status__c == 'Pending Approval' || eReq.Approval_Status__c == 'Pending Cloud Ops Approval' || eReq.Approval_Status__c == 'Pending GEO SE Approval' || eReq.Approval_Status__c == 'Pending PM Approval' || eReq.Approval_Status__c == 'Pending CEO Approval' || eReq.Approval_Status__c == 'Pending Cloud Ops/Support Approval');
        if(profname == 'Core Sales - SE'){
            isService_Edge_CalculatorReadOnly = TRUE;
        }
    }
    
    public void addLocation(){
        Id rectypeId = null;
        if(String.isNotBlank(rectypeDC)){
            rectypeId = Schema.SObjectType.Datacenter__c.getRecordTypeInfosByName().get(rectypeDC).getRecordTypeId();
        }  
        Datacenter__c dcObj = new Datacenter__c();
        dcObj.Equipment_Request__c = eReq.Id;
        dcObj.RecordtypeId = rectypeId;
        
        DataCenterWarapper dcWrapperObj = new DataCenterWarapper();
        dcWrapperObj.dataCenterRecord = dcObj;
        if(!isDedicated_LB_quantityReadOnly){
            dcWrapperObj.isDedicatedLBQuantityReadOnly = FALSE;
        }else if(dcWrapperObj.dataCenterRecord.Requested_Hardware_Model__c == 'ZIA Service Edge-5 + LB (>5Gbps only)'){
            dcWrapperObj.isDedicatedLBQuantityReadOnly = FALSE;
        }else {
            dcWrapperObj.isDedicatedLBQuantityReadOnly = TRUE;
        }
        dcWrapperObj.isHostPartnerNameRequired = dcObj.RecordtypeId == partnerDCRecordTypeId ? TRUE : FALSE;
        dcWrapperObj.isDCRemoved = FALSE;
        dcWrapperObj.isQuantityRequestedAlertVisible = FALSE;
        dcWrapperObj.isQuantityRequestedForLBAlertVisible = FALSE;
        dcWrapperObj.isNumberOfUsersAtLocationAlertVisible = FALSE;
        dataCenterWarapperList.add(dcWrapperObj);
        
    }
    
    public void removeLocation(){
        if(String.isNotBlank(indextoRemove) && !dataCenterWarapperList.isEmpty()){
            if(dataCenterWarapperList.get(Integer.valueOf(indextoRemove) - 1).dataCenterRecord.Id == null){
                dataCenterWarapperList.get(Integer.valueOf(indextoRemove) - 1).isDCRemoved = TRUE;
                dataCenterWarapperList.remove(Integer.valueOf(indextoRemove) - 1);
            }else {
                dataCenterWarapperList.get(Integer.valueOf(indextoRemove) - 1).isDCRemoved = TRUE;
                dcWrapperListToDelete.add(dataCenterWarapperList.get(Integer.valueOf(indextoRemove) - 1));
                dataCenterWarapperList.remove(Integer.valueOf(indextoRemove) - 1);
            }
        }        
    }
    
    public void getOpportunity(){
        if(eReq.Opportunity__c == null){
            architectureWorkshopLink = '';
        }else {
            Opportunity oppRecord = [SELECT Account.Architecture_Workshop_Link__c 
                                     FROM Opportunity
                                     WHERE Id =:eReq.Opportunity__c];
            architectureWorkshopLink = String.isNotBlank(oppRecord.Account.Architecture_Workshop_Link__c) ? 
                										oppRecord.Account.Architecture_Workshop_Link__c : '';
        }
    }
    
    public void getReqHWmodel(){
        if(!dataCenterWarapperList.isEmpty()){
            for(DataCenterWarapper dcWarpper : dataCenterWarapperList){
                if(!isDedicated_LB_quantityReadOnly){
                    dcWarpper.isDedicatedLBQuantityReadOnly = FALSE;
                }else if(dcWarpper.dataCenterRecord.Requested_Hardware_Model__c == 'ZIA Service Edge-5 + LB (>5Gbps only)'){
                    dcWarpper.isDedicatedLBQuantityReadOnly = FALSE;
                }else {
                    dcWarpper.isDedicatedLBQuantityReadOnly = TRUE;
                    dcWarpper.dataCenterRecord.Quantity_Requested_for_LB__c = null;
                    dcWarpper.isQuantityRequestedForLBAlertVisible = FALSE;
                }
            }
        }
    }
    
    public void getNumberOfUsersAtLocation(){
        if(!dataCenterWarapperList.isEmpty()){
            for(DataCenterWarapper dcWarpper : dataCenterWarapperList){                
                if(Integer.valueOf(dcWarpper.dataCenterRecord.Number_of_Users_at_location__c) > 5000){
                    dcWarpper.isNumberOfUsersAtLocationAlertVisible = TRUE;
                }else {
                    dcWarpper.isNumberOfUsersAtLocationAlertVisible = FALSE;
                }
            }
        }
    }
    
    public void getQuantityRequested(){
        if(!dataCenterWarapperList.isEmpty()){
            for(DataCenterWarapper dcWarpper : dataCenterWarapperList){
                if(Integer.valueOf(dcWarpper.dataCenterRecord.Quantity_Requested__c) > 10){
                    dcWarpper.isQuantityRequestedAlertVisible = TRUE;
                }else {
                    dcWarpper.isQuantityRequestedAlertVisible = FALSE;
                }
            }
        }
    }
    
    public void getQuantityRequestedForLB(){
        if(!dataCenterWarapperList.isEmpty()){
            for(DataCenterWarapper dcWarpper : dataCenterWarapperList){
                if(Integer.valueOf(dcWarpper.dataCenterRecord.Quantity_Requested_for_LB__c) > 2){
                    dcWarpper.isQuantityRequestedForLBAlertVisible = TRUE;
                }else {
                    dcWarpper.isQuantityRequestedForLBAlertVisible = FALSE;
                }
            }
        }
    }
    
    public pagereference onSave(){
        ApexPages.getMessages().clear();
        Savepoint sp = Database.setSavepoint();
        system.debug(GEvalue);
        eReq.PZen_Access_Requirements_Provided__c  = GEvalue;
        eReq.Architecture_Workshop_Link__c  = architectureWorkshopLink;
        
        datacenterlst.clear();//avoid dups while upsert        
        for(DataCenterWarapper dcWrapper : dataCenterWarapperList){
            if(dcWrapper.isDCRemoved == FALSE){
                datacenterlst.add(dcWrapper.dataCenterRecord);
            }            
        }        
        if(datacenterlst.isEmpty() && profname != 'System Administrator' && (eReq.Id == null || ereq.createddate.date() >= date.valueOf('2019-09-10 00:00:00'))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Atleast 1 Datacenter should be added to proceed'));
            return null;
        }
        for(Datacenter__c dc: datacenterlst){
           if(dc.Requested_Hardware_Model__c == 'ZIA – Service Edge 5' || dc.Requested_Hardware_Model__c == 'ZIA Service Edge-5 + LB (>5Gbps only)'){
               if(eReq.PZen_Access_Requirements_Provided__c != 'Yes - acknowledged by customer' && (eReq.Id == null || ereq.createddate.date() >= date.valueOf('2019-09-10 00:00:00'))){
                   ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, '\'10GE interfaces requirements been communicated to customer\' field on Equipment Request has to be \'Yes\' if hardware requested is either ZIA – Service Edge 5 or ZIA Service Edge-5 + LB (>5Gbps only)'));
                   return null;
               }
           }
        } 
        try{
            Id accId = null;
            if(eReq.Id == null || !isinApproval){
                upsert eReq;
            }
            if(eReq.Opportunity__c != null){
                Opportunity[] opp = [Select Id, AccountId from Opportunity where Id = :eReq.Opportunity__c];
                if(!opp.isEmpty()){
                    accId = opp[0].AccountId;
                }
            }
            for(Datacenter__c dc: datacenterlst){
                dc.Account__c = accId;
                dc.Equipment_Request__c = eReq.Id;
            }           
            upsert datacenterlst;
                        
            List<Datacenter__c> dcToDeleteList = new List<Datacenter__c>();
            for(DataCenterWarapper dcWrapper : dcWrapperListToDelete){
                if(dcWrapper.isDCRemoved == TRUE){
                    dcToDeleteList.add(dcWrapper.dataCenterRecord);
                }                
            }
            if(!dcToDeleteList.isEmpty()){
                delete dcToDeleteList;
            }
            
        }catch(DmlException ex){
            String err = 'Unable to save record: ' + ex.getDmlMessage(0);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, err));
            if(!isedit){
                eReq = eReq.clone(false);
            }
            Database.rollback(sp);
            return null;
        }
        return new PageReference('/'+eReq.Id);
    }
    
    public pagereference onCancel(){
        if(eReq.Id != null){
            return new PageReference('/'+eReq.Id);
        }else{
            Schema.DescribeSObjectResult r = Equipment_Request__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            return new PageReference('/'+ keyPrefix + '/o');
        }
    }
    
    public class DataCenterWarapper{
        public Datacenter__c dataCenterRecord{get; set;}
        public Boolean isDedicatedLBQuantityReadOnly{get; set;}
        public Boolean isHostPartnerNameRequired{get; set;}
        public Boolean isQuantityRequestedAlertVisible{get; set;}
        public Boolean isQuantityRequestedForLBAlertVisible{get; set;}
        public Boolean isNumberOfUsersAtLocationAlertVisible{get; set;}
        public Boolean isDCRemoved{get; set { isDCRemoved = FALSE; }}
    }

}