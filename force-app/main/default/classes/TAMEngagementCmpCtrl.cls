/**
* Name : TAMEngagementCmpCtrl
* Description : Controller class for TAMEngagementCmp LWC
* Test Class : TAMEngagementCmpCtrlTest
* Initial Author : Ankit Bhatnagar
*/

public with sharing class TAMEngagementCmpCtrl {
    public TAMEngagementCmpCtrl() {}
    
    @AuraEnabled
    public static TAMEngagementStatusStage getTAMEngagementStage(String recordId) {
        if(String.isNotBlank(recordId)) {
            TAM_Engagement__c eng = [SELECT Stage__c, TAM_Engagement_Status__c,Product__c FROM TAM_Engagement__c WHERE id=:recordId];
            TAMEngagementStatusStage obj = new TAMEngagementStatusStage(eng.Stage__c, eng.TAM_Engagement_Status__c, eng.Product__c);
            return obj;
        }
        else return null;
    }

    @AuraEnabled 
    public static String getPageLayoutFields(String stage, String recordId) {
        Map<String, Schema.SObjectField> fieldMap = TAM_Engagement__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        TAM_Engagement__c engagement;
        if(String.isNotBlank(recordId)) {
            engagement = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM TAM_Engagement__c WHERE Id=:recordId');
            String accId = String.valueOf(engagement.get('Account__c'));
        }
        if(String.isBlank(stage) && String.isNotBlank(recordId)) {
            stage = String.valueOf(engagement.get('Stage__c'));
        }
        
        sObject objRecord;
        String result;
        String layoutName;
        layoutName = 'TAM_Engagement__c-'+ stage;
        
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
                    boolean checkField = false;
                    for(Metadata.LayoutColumn lc : ls.layoutColumns) {                
                        LayoutColumn column = new LayoutColumn();
                        if(lc.layoutItems != null) { 
                            if(maxFieldsInColumn < lc.layoutItems.size()) {
                                maxFieldsInColumn = lc.layoutItems.size();
                            }
                            for(Metadata.LayoutItem li : lc.layoutItems) {
                                if(li.field != null){
                                    checkField = true;   
                                    LayoutField field = new LayoutField(li);
                                    field.fieldType = fieldMap.get(field.fieldName).getDescribe().getType();
                                    if(String.isNotBlank(recordId)) {
                                        if(String.valueOf(field.fieldType) == 'DATETIME') {
                                            field.fieldValue = engagement.get(field.fieldName)!=null?DateTime.valueOf(engagement.get(field.fieldName)).format():null;
                                        }
                                        else {
                                            field.fieldValue = engagement.get(field.fieldName)!=null?String.valueOf(engagement.get(field.fieldName)):null;
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
                    if(checkField) {
                        lstSections.add(section);
                    }
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
    public static String getAccountDetails(String accountId){
        if(String.isNotBlank(accountId)) {
            List<TAM_Engagement_Data_Configuration__mdt> engagementConfigs = new List<TAM_Engagement_Data_Configuration__mdt>([SELECT id,Source_Field_Name__c, Target_Field_Name__c, Object__c FROM TAM_Engagement_Data_Configuration__mdt WHERE Object__c = 'Account']); 
            AccountTAMEngagementConfig config = new AccountTAMEngagementConfig();
            Map<String,String> configMap = new Map<String,String>();
            if(!engagementConfigs.isEmpty()) {
                list<String> lstFieldNames = new List<String>();
                for(TAM_Engagement_Data_Configuration__mdt cmt : engagementConfigs) {
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
    public static String checkIfTAMAccount(Id recordId){
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            if(sObjName == 'Account') {
                return [SELECT id,TAM_Name_New__c FROM Account WHERE id=:recordId].TAM_Name_New__c;
            }
            else if(sObjName == 'TAM_Engagement__c') {
                return [SELECT id,Account__r.TAM_Name_New__c FROM TAM_Engagement__c WHERE id=:recordId].Account__r.TAM_Name_New__c;
            }
            else return '';
        }
        else return '';
    }

    @AuraEnabled
    public static List<TAM_Engagement__c> getTERecords(Id recordId){
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            if(sObjName == 'Account') {
                return [SELECT id,Account__c,Product__c FROM TAM_Engagement__c WHERE Account__c=:recordId and TAM_Engagement_Status__c!='Completed'];
            }
            else return new List<TAM_Engagement__c>();
        }
            return new List<TAM_Engagement__c>();
    }

    @AuraEnabled
    public static Map<String,Decimal> productsValidation(Id recordId){
        Map<String,Decimal> productsPurchased = new Map<String, Decimal>();
        Decimal ZPACount = 0;
        Decimal ZIACount = 0;
        Decimal ZDXCount = 0;
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            if(sObjName == 'Account') {
                Account acc = [SELECT id,No_Of_ZDX_Platform_Users__c,Users_ZPA_Platform__c,No_of_Platform_Seats__c FROM Account WHERE id=:recordId];
                ZPACount = acc.Users_ZPA_Platform__c!=null?acc.Users_ZPA_Platform__c:0;
                ZIACount = acc.No_of_Platform_Seats__c!=null?acc.No_of_Platform_Seats__c:0;
                ZDXCount = acc.No_Of_ZDX_Platform_Users__c!=null?acc.No_Of_ZDX_Platform_Users__c:0;
            }
            else if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c eng = [SELECT id,Account__r.No_Of_ZDX_Platform_Users__c,Account__r.Users_ZPA_Platform__c,Account__r.No_of_Platform_Seats__c FROM TAM_Engagement__c WHERE id=:recordId];
                ZPACount = eng.Account__r.Users_ZPA_Platform__c!=null?eng.Account__r.Users_ZPA_Platform__c:0;
                ZIACount = eng.Account__r.No_of_Platform_Seats__c!=null?eng.Account__r.No_of_Platform_Seats__c:0;
                ZDXCount = eng.Account__r.No_Of_ZDX_Platform_Users__c!=null?eng.Account__r.No_Of_ZDX_Platform_Users__c:0;
            }
        }
        productsPurchased.put('ZIA', ZIACount);
        productsPurchased.put('ZPA', ZPACount);
        productsPurchased.put('ZDX', ZDXCount);
        return productsPurchased;
    }
    
    @AuraEnabled
    public static string getStagePicklistValue(){
        Schema.DescribeFieldResult fieldResult = TAM_Engagement__c.Stage__c.getDescribe();
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
    public static string tamEngagementSetStage(String recordId, String recordStage){
        try {
            TAM_Engagement__c engagement = new TAM_Engagement__c(id = recordId, stage__c = recordStage);
            update engagement;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string tamEngagementSetProducts(String recordId, String selectedProduct){
        try {
            TAM_Engagement__c engagement = new TAM_Engagement__c(id = recordId, product__c = selectedProduct);
            update engagement;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string setClosingComments(String recordId, String comments){
        try {
            TAM_Engagement__c engagement = new TAM_Engagement__c(id = recordId, Closing_Notes__c = comments, tam_engagement_Status__c = 'Completed');
            update engagement;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string handleApprovalResponse(String recordId, String response, String comments){
        try {
            TAM_Engagement__c engagement = new TAM_Engagement__c(id = recordId, Approval_Action_from_cmp__c = true, Approval_Comments__c = comments);
            update engagement;

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
    public static String checkIfUserCanSubmit(String userRecordId, String recordId){
        try {
            User u = [SELECT id,ManagerId FROM User WHERE Id =:userRecordId];
            if(String.isBlank(u.ManagerId)) {
                return 'Your user does not have a Manager assigned to it. You cannot submit this TAM Engagement for Approval!';
            }
            else {
                TAM_Engagement__c eng = [SELECT id,Stage__c, TAM_Engagement_Status__c FROM TAM_Engagement__c WHERE id =: recordId];
                if(eng.TAM_Engagement_Status__c == 'Work in Progress' || eng.TAM_Engagement_Status__c == 'Rejected') {
                    return 'Success';
                }
                else {
                    return 'This TAM Engagement cannot be submitted for approval.';    
                } 
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string submitForApproval(String recordId, String comments, String stage){
        try {
            User usr = [SELECT id,ManagerId FROM User WHERE Id =: UserInfo.getUserId()];
            TAM_Engagement__c eng = new TAM_Engagement__c(Id=recordId, Submitter__c = usr.Id, Approver__c = usr.ManagerId);
            update eng;
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(comments);
            req1.setObjectId(recordId);
            Map<String, String> stagewiseApprovalMap = new Map<String, String>{
                'STAGE 2: Establish Alignment' => 'TAM_Engagement_STAGE_2_Approval',
                'STAGE 3: Adoption Acceleration/Operation Excellence' => 'TAM_Engagement_STAGE_3_Approval',
                'STAGE 4: Audit' => 'TAM_Engagement_STAGE_4_Approval',
                'STAGE 5: Continuous Adoption' => 'TAM_Engagement_STAGE_5_Approval'
            };
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(UserInfo.getUserId()); 
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId(stagewiseApprovalMap.get(stage));
            Approval.ProcessResult result = Approval.process(req1);
            return 'Success';
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String checkIfUserCanApprove(String userRecordId, String recordId){
        try {
            List<Approval.ProcessWorkitemRequest> reqs = new List<Approval.ProcessWorkitemRequest>();
            List<ProcessInstanceWorkitem> piwiList = new List<ProcessInstanceWorkitem>([SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId,ProcessInstance.Status,originalActorId,originalActor.Name 
                                                                                        FROM ProcessInstanceWorkitem 
                                                                                        WHERE ProcessInstance.TargetObjectId = :recordId AND ProcessInstance.Status='Pending']);
            if(!piwiList.isEmpty() && String.valueOf(piwiList.get(0).originalActorId).startsWith('005')) {
                if(userRecordId != piwiList.get(0).originalActorId) {
                    return 'You are not the assigned Approver!';
                }
                else {
                    TAM_Engagement__c eng = [SELECT id,Stage__c, TAM_Engagement_Status__c FROM TAM_Engagement__c WHERE id =: recordId];
                    if(eng.TAM_Engagement_Status__c == 'Pending Approval') {
                        return 'Success';
                    }
                    else {
                        return 'This TAM Engagement hasn\'t been submitted for approval.';    
                    }
                }
            }
            else {
                return 'You are not the assigned Approver!';
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @TestVisible
    private class TAMEngagementStatusStage {
        @AuraEnabled public String stage {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String product {get; set;}

        private TAMEngagementStatusStage(String stage, String status, String product) {
            this.stage = stage;
            this.status = status;
            this.product = product;
        }
    }

    private class AccountTAMEngagementConfig {
        @AuraEnabled public Account accRecord {get; set;}
        @AuraEnabled public Map<String,String> meta {get; set;}

        private AccountTAMEngagementConfig() {
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

	@TestVisible    
    private static String removeQuotes(String s) {
        if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith('\'') && s.endsWith('\''))) {
            return s.substring(1, s.length() - 1);
        } else {
            return s;
        }
    }
}