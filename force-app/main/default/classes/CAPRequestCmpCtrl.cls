/**
 * Name : CAPRequestCmpCtrl
 * Description : Controller class for capRequestCmp LWC
 * Test Class : CAPRequestCmpCtrlTest
 * Initial Author : Ankit Bhatnagar
 */

public with sharing class CAPRequestCmpCtrl {
    public CAPRequestCmpCtrl() {}

    @AuraEnabled
    public static String getCapRequestStatus(String recordId) {
        if(String.isNotBlank(recordId)) {
            return [SELECT Status__c FROM CAP_Request__c WHERE id=:recordId].status__c;
        }
        else return '';
    }

    @AuraEnabled
    public static String setApprovalFlag(String recordId) {
        try {
            CAP_Request__c cap = new CAP_Request__c(id = recordId, Approval_Action_from_cmp__c = true);
            update cap;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getCapRequestAccountDetails(String accountId){
        if(String.isNotBlank(accountId)) {
            List<CAP_Request_Data_Configuration__mdt> capReqConfigs = new List<CAP_Request_Data_Configuration__mdt>([SELECT id,Source_Field_Name__c, Target_Field_Name__c, Object__c FROM CAP_Request_Data_Configuration__mdt WHERE Object__c = 'Account']); 
            AccountCAPConfigurations config = new AccountCAPConfigurations();
            Map<String,String> configMap = new Map<String,String>();
            if(!capReqConfigs.isEmpty()) {
                list<String> lstFieldNames = new List<String>();
                for(CAP_Request_Data_Configuration__mdt cmt : capReqConfigs) {
                    configMap.put(cmt.Target_Field_Name__c, cmt.Source_Field_Name__c);
                }
                config.meta = configMap;
                Account acc;
                if(!configMap.isEmpty()) {
                    acc = Database.query('SELECT ' + String.join(configMap.values(), ',') + ' FROM Account WHERE Id=:accountId');
                }
                config.accRecord = acc;
            }
            return JSON.serialize(config);
        }
        else return '';
    }

    @AuraEnabled
    public static List<CAP_Request_Interaction__c> getDailyNotesData(String recordId){
        if(String.isNotBlank(recordId)) {
            List<CAP_Request_Interaction__c> capReqInts = new List<CAP_Request_Interaction__c>([SELECT id, Field_Name__c,Field_Label__c, Old_Value__c, New_Value__c, CreatedBy.Name,CreatedDate FROM CAP_Request_Interaction__c WHERE CAP_Request__c =: recordId order by createdDate desc]);
            return capReqInts;
        }
        else return null;
    }
    

    @AuraEnabled 
    public static String getPageLayoutFields(String status, String recordId) {
        Map<String, Schema.SObjectField> fieldMap = CAP_Request__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        CAP_Request__c cap;
        String isRenewalRisk = '';
        if(String.isNotBlank(recordId)) {
            cap = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM CAP_Request__c WHERE Id=:recordId');
            String accId = String.valueOf(cap.get('Account__c'));
            Account acc = [SELECT id,Next_Renewal_Due_Date__c FROM Account WHERE id=:accId];
            if(String.isBlank(String.valueOf(cap.get('Is_Account_a_renewal_risk__c')))) {
                isRenewalRisk = 'No';
            }
            if(acc.next_Renewal_Due_Date__c != null && String.isBlank(String.valueOf(cap.get('Is_Account_a_renewal_risk__c')))) {
                isRenewalRisk = (system.today()).daysBetween(Date.valueOf(acc.next_Renewal_Due_Date__c))<=180?'Yes':'No';
            }
        }
        if(String.isBlank(status) && String.isNotBlank(recordId)) {
            status = String.valueOf(cap.get('Status__c'));
        }
        
        sObject objRecord;
        String result;
        String layoutName;
        layoutName = 'CAP_Request__c-'+ status;

        List<String> componentNameList = new List<String>{layoutName};
        List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
        if(!components.isEmpty()){
            Metadata.Layout layout = (Metadata.Layout) components.get(0);
            List<LayoutSection> lstSections = new List<LayoutSection>();
            for(Metadata.LayoutSection ls : layout.layoutSections) {    
                if(ls.label != 'System Information') {
                    LayoutSection section = new LayoutSection(ls.layoutColumns.size());
                section.label = ls.label;
                List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                Integer maxFieldsInColumn = 0;
                boolean checkFiled = false;
                for(Metadata.LayoutColumn lc : ls.layoutColumns) {                
                    LayoutColumn column = new LayoutColumn();
                    if(lc.layoutItems != null) { 
                        if(maxFieldsInColumn < lc.layoutItems.size()) {
                            maxFieldsInColumn = lc.layoutItems.size();
                        }
                        for(Metadata.LayoutItem li : lc.layoutItems) {
                            //if(li.behavior != Metadata.UiBehavior.ReadOnly ){ 
                            if(li.field != null){
                                checkFiled = true;   
                                LayoutField field = new LayoutField(li);
                                field.fieldType = fieldMap.get(field.fieldName).getDescribe().getType();
                                if(String.isNotBlank(recordId)) {
                                    if(String.valueOf(field.fieldType) == 'DATETIME') {
                                        //field.fieldValue = cap.get(field.fieldName)!=null?DateTime.valueOf(cap.get(field.fieldName)).format():null;
                                        field.fieldValue = cap.get(field.fieldName)!=null?DateTime.valueOf(cap.get(field.fieldName)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'):null;
                                    }
                                    else {
                                        field.fieldValue = cap.get(field.fieldName)!=null?String.valueOf(cap.get(field.fieldName)):null;
                                    }
                                    if(field.fieldName == 'Is_Account_a_renewal_risk__c') {
                                        field.fieldValue = isRenewalRisk;
                                    }
                                }
                                else {
                                    if(String.valueOf(field.fieldType) == 'PICKLIST') {
                                        String defaultVal = fieldMap.get(field.fieldName).getDescribe().getDefaultValueFormula();
                                        if(String.isNotBlank(defaultVal)){
                                            field.fieldValue = removeQuotes(defaultVal);
                                        }
                                    }
                                }
                                column.lstFields.add(field);
                            }
                            //}
                        }
                    }
                    if(column.lstFields.size() > 0) {
                        lstColumns.add(column);
                    }
                }
                if(maxFieldsInColumn > 0) {
                    for(Integer i = 0; i < maxFieldsInColumn; i++) {
                        for(Integer j = 0; j < lstColumns.size(); j++) {
                            if(lstColumns[j].lstFields.size() > i) {
                                section.lstFields.add(lstColumns[j].lstFields[i]);    
                            }    
                            else {
                                section.lstFields.add(new LayoutField());
                            }
                        }    
                    }    
                }
                if(checkFiled)
                    lstSections.add(section);
                }
            }
            PageLayoutWrapper plw = new PageLayoutWrapper(lstSections, objRecord);
            result= JSON.serialize(plw);
        }
        else{ 
            result = null;
        }
        return result;
    }

    @AuraEnabled
    public static string getStatusPicklistValue(){
        Schema.DescribeFieldResult fieldResult = CAP_Request__c.Status__c.getDescribe();
        Map<String,String> picklistValuesMap = new Map<String,String>();
        Map<String,String> picklistValuesMap_reverse = new Map<String,String>();
        
        for( Schema.PicklistEntry v : fieldResult.getPicklistValues()) {
           picklistValuesMap.put(v.getValue(),v.getLabel());
        }
        List<String> picklistMapList = new List<String>(picklistValuesMap.keySet());
        for(Integer i=picklistMapList.size()-1;i>=0;i--){
            picklistValuesMap_reverse.put(picklistMapList.get(i),picklistValuesMap.get(picklistMapList.get(i)));
        }
        if(!picklistValuesMap_reverse.isEmpty())
            return JSON.serialize(picklistValuesMap_reverse);
        else 
            return '';
    }

    @AuraEnabled
    public static string submitForApproval(String recordId, String comments){
        try {
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(comments);
            req1.setObjectId(recordId);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(UserInfo.getUserId()); 
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('CAP_Request_Approval_Process');
            Approval.ProcessResult result = Approval.process(req1);
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string handleCAPApproval(String recordId, String response, String comments){
        try {
            CAP_Request__c cap = new CAP_Request__c(id = recordId, Approval_Action_from_cmp__c = true);
            update cap;
           
            List<Approval.ProcessWorkitemRequest> reqs = new List<Approval.ProcessWorkitemRequest>();
            List<ProcessInstanceWorkitem> piwiList = new List<ProcessInstanceWorkitem>([SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId,ProcessInstance.Status
                                                                                        FROM ProcessInstanceWorkitem 
                                                                                        WHERE ProcessInstance.TargetObjectId = :recordId AND ProcessInstance.Status='Pending']);
            for(ProcessInstanceWorkitem piwi : piwiList) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction(response);        
                req.setComments(comments);  
                req.setWorkitemId(piwi.Id);
                reqs.add(req);
            }
            if(!reqs.isEmpty()) {
                Approval.ProcessResult[] results = Approval.process(reqs,false);
                System.debug('## Results'+results);
                if(!results.isEmpty() && results.get(0).isSuccess()) {
                    return 'Success';
                }
                else return 'Failure';
            }
            else return 'Failure';
        } catch (Exception e) {
            System.debug('##'+e.getMessage() + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
      
    @AuraEnabled
    public static Boolean checkIfUserCanApprove(String userRecordId, String recordId){
        try {
            List<Approval.ProcessWorkitemRequest> reqs = new List<Approval.ProcessWorkitemRequest>();
            List<ProcessInstanceWorkitem> piwiList = new List<ProcessInstanceWorkitem>([SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId,ProcessInstance.Status,originalActorId,originalActor.Name 
                                                                                        FROM ProcessInstanceWorkitem 
                                                                                        WHERE ProcessInstance.TargetObjectId = :recordId AND ProcessInstance.Status='Pending']);
            
            String grpName = '';
            if(!piwiList.isEmpty() && !String.valueOf(piwiList.get(0).originalActorId).startsWith('005')) {
                grpName = piwiList.get(0).originalActor.Name;
            }

            Set<String> userSet = new Set<String>();
            List<GroupMember> grpMembers = new List<GroupMember>([SELECT id,GroupID,UserOrGroupId FROM GroupMember WHERE Group.Name = :grpName]);
            if(!grpMembers.isEmpty()) {
                for(GroupMember grpMem : grpMembers) {
                    if(String.valueOf(grpMem.UserOrGroupId).startsWith('005')) {}
                        userSet.add(grpMem.userOrGroupId);
                }
                if(userSet.contains(userRecordId))  
                    return true;
                else return false;
            }
            else return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string CAPSetStatus(String recordId, String recordStatus){
        try {
            CAP_Request__c cap = new CAP_Request__c(id = recordId, Status__c = recordStatus);
            update cap;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private class AccountCAPConfigurations {
        @AuraEnabled public Account accRecord {get; set;}
        @AuraEnabled public Map<String,String> meta {get; set;}

        private AccountCAPConfigurations() {
            this.accRecord = null;
            this.meta = new Map<String,String>();
        }
    }
    
    
    /**
     * @description PageLayoutWrapper to hold details of page Layout for Selected Record's Record Type
     *
     *  
	 **/
    private class PageLayoutWrapper {
        @AuraEnabled public List<LayoutSection> lstSections {get; set;}
        @AuraEnabled public sObject selectedRecord {get; set;}
        
        private PageLayoutWrapper(List<LayoutSection> lstSections, sObject selectedRecord) {
            this.lstSections = lstSections;
            this.selectedRecord = selectedRecord;
        }
    }
    
    
    /*
     * @description LayoutSection to hold details related to selected Record's PageLayout Sections and associated fields with each sections
	 **/
    
    private class LayoutSection {
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;       
        @AuraEnabled public Integer totalColumns;
        
        private LayoutSection(Integer totalColumns) {
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();            
        }
    }
    
    /*
     * @description LayoutColumn to hold details related to fields of each Section of record Page Layout
     * */
    
    private class LayoutColumn {
        private List<LayoutField> lstFields;  
        
        private LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }
    
    
    /*
     * @description LayoutField to hold details related to each field on record Page Layout
     * */
    
    private class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        @AuraEnabled public String fieldValue;
        @AuraEnabled public Boolean hasCustomLabel;
        @AuraEnabled public  Schema.DisplayType fieldType;
        
        private LayoutField() {}
        
        private LayoutField(Metadata.LayoutItem li ) {
            this.fieldName = li.field;          
            this.isRequired = false;
            this.isReadOnly = false;
            if(li.field == 'ownerId') {
                this.hasCustomLabel = true;
            }
            else {
                this.hasCustomLabel = false;
            }
            if(li.behavior == Metadata.UiBehavior.Required) {
                this.isRequired = true;
            }
            else if(li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }   
        }
    }

    private static String removeQuotes(String s) {
        if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith('\'') && s.endsWith('\''))) {
            return s.substring(1, s.length() - 1);
        } else {
            return s;
        }
    }
    @InvocableMethod(label='handleCAPRejection')
    public static List<Boolean> handleCAPRejection(List<String> recordId){
        try {
            Boolean isSuccess = false;
            CAP_Request__c cap = new CAP_Request__c(id = recordId.get(0), Approval_Action_from_cmp__c = true);
            update cap;
            List<Approval.ProcessWorkitemRequest> reqs = new List<Approval.ProcessWorkitemRequest>();
            List<ProcessInstanceWorkitem> piwiList = new List<ProcessInstanceWorkitem>([SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId,ProcessInstance.Status
                                                                                        FROM ProcessInstanceWorkitem 
                                                                                        WHERE ProcessInstance.TargetObjectId = :recordId AND ProcessInstance.Status='Pending']);
            for(ProcessInstanceWorkitem piwi : piwiList) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Reject');        
                req.setWorkitemId(piwi.Id);
                reqs.add(req);
            }
            if(!reqs.isEmpty()) {
                Approval.ProcessResult[] results = Approval.process(reqs,false);
                if(!results.isEmpty() && results.get(0).isSuccess()) {
                    isSuccess = true;
                }
                else {
                    isSuccess = false;
                }
            }
            else{
                cap.Status__c='Rejected';
                update cap;
                isSuccess = true;
            } 
            return new List<Boolean>{isSuccess};
        } catch (Exception e) {
            System.debug('##'+e.getMessage() + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
}