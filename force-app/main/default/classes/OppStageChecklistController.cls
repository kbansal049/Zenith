/**
* @File Name          : OppStageChecklistController.cls
* @Description        : 
* @Author             : kpullagurla@zscaler.com
* @Group              : 
* @Last Modified By   : kpullagurla@zscaler.com
* @Last Modified On   : 12/21/2021, 12:40:28 PM
* @Modification Log   : 
*------------------------------------------------------------------------------
* Ver         Date                     Author                    Modification
*------------------------------------------------------------------------------
* 1.0    12/21/2021, 12:40:28 PM   kpullagurla@zscaler.com     Initial Version
* 2.o    12/29/2021                viralnavadiya@zscaler.COM    
**/
public with sharing class OppStageChecklistController {
    public static Boolean allowPermissionOverride;
    public static Boolean isRequiredFulfilled;
    public static List<FieldWrapper> requiredFields;
    public static List<FieldWrapper> optionalFields;
    public static String nextStageValue;
    public static String prevStageValue;
    public static String recordTypeId;
    public static List<ReferenceWrapper> attrs;
    public static String stageDescription;
    public static String actorsInvolved;
    public static Opportunity opp;
    public static List<ReferenceWrapper> importantLinks = new List<ReferenceWrapper>();
    public static Map<String,String> profileUserTypes = new Map<String,String>{Label.Profiel_Core_Sales_LDR => 'SDR',
        Label.Profile_Core_Sales_CSM => 'CSM', Label.Profile_Core_Sales => 'RSM','Core Sales - SE' => 'SE', 'Core Sales - Federal' => 'Federal'};
     //store and return field type for every field on opportunity object
    public static Map<String,Schema.DisplayType> fieldList;       
    
    @AuraEnabled
    public static void unlinkFileURLFromOpportunity(String oppId, String oppfieldAPIName){
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Opportunity oppRecord = new Opportunity(id = oppId);
        fieldList = new map<string, Schema.DisplayType>();
            map<string,SObjectField> fList = schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
            for(string str: fList.keySet()){
                fieldList.put(str, fList.get(str).getDescribe().getType());                
            }
        Schema.DisplayType fldType = fieldList.get(oppfieldAPIName.toLowerCase());
        if(fldType == Schema.DisplayType.Boolean){
            oppRecord.put(oppfieldAPIName, false);
        }else{
            oppRecord.put(oppfieldAPIName, null);
        }
        
        update oppRecord;
    }
    
    @AuraEnabled
    public static void linkFileURLtoOpportunity(String oppId,List<Map<String, Object>> files, String oppfieldAPIName){
        try {
            if(oppId != null && files != null){
                Set<ID> ContentDocumentIdList = new Set<ID>();
                fieldList = new map<string, Schema.DisplayType>();
                map<string,SObjectField> fList = schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
                for(string str: fList.keySet()){
                    fieldList.put(str, fList.get(str).getDescribe().getType());                
                }
                Map<String,String> filePreviewURLs = new Map<String,String>();
                for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :oppId]){
                    ContentDocumentIdList.add(cdl.ContentDocumentId);
                }
                System.debug('--ContentDocumentIdList--'+ContentDocumentIdList);
                
                List<ContentDocumentLink> reLinkTheFiles = new List<ContentDocumentLink>();
                for(Map<String,Object> file: files){
                    FileDataWP relatedDocument = (FileDataWP) JSON.deserialize(JSON.serialize(file), FileDataWP.class);
                    if(relatedDocument.fileId != null && !ContentDocumentIdList.contains(relatedDocument.fileId)){
                        reLinkTheFiles.add(new contentDocumentLink(ContentDocumentId = relatedDocument.fileId, LinkedEntityId = oppId, ShareType = 'I'));
                    }
                    filePreviewURLs.put(relatedDocument.fieldName,relatedDocument.filePreviewURL);
                }
                
                insert reLinkTheFiles;
                
                TriggerHandler.bypass('OpportunityTriggerHandler');
                Opportunity oppRecord = new Opportunity(id = oppId);
                if(oppfieldAPIName.contains(',')){
                    for(String fieldName: oppfieldAPIName.split(',')){
                    Schema.DisplayType fldType = fieldList.get(fieldName.toLowerCase());
                    if(fldType == Schema.DisplayType.Boolean){
                        oppRecord.put(fieldName, true);
                    }else{

                        oppRecord.put(fieldName, filePreviewURLs.get(fieldName));
                    }
                }
                }else{
                    
                    Schema.DisplayType fldType = fieldList.get(oppfieldAPIName.toLowerCase());
                    if(fldType == Schema.DisplayType.Boolean){
                        oppRecord.put(oppfieldAPIName, true);
                    }else{

                        oppRecord.put(oppfieldAPIName, filePreviewURLs.get(oppfieldAPIName));
                    }
                
                }
                
                
                
                update oppRecord;
            }
            
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' -> ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage()+ex.getLineNumber()); 
        }
    }
    
    //compare and check against the opportunity field value from custom metadata
    public static String determineFieldValue(String fieldName, String valueToCompare, Opportunity oppRec){
        
        fieldName = fieldName.toLowerCase();
        if(fieldList.containsKey(fieldName)){
           
            Switch on fieldList.get(fieldName) {
                when BOOLEAN {
                    System.debug('--fieldName--'+fieldName);
                    System.debug('--valueToCompare--'+valueToCompare);
                    System.debug('--oppRec.get(fieldName)--'+oppRec.get(fieldName));
                    if(valueToCompare.equalsIgnoreCase('true') && oppRec.get(fieldName) == true){
                        
                        return 'true=BOOLEAN-true';
                    }
                    else {
                        return 'false=BOOLEAN-false';
                    }
                }
                when INTEGER {
                    Integer i = (Integer)oppRec.get(fieldName);
                    if(oppRec.get(fieldName) != null){
                        if(valueToCompare.startsWith('>') && Integer.valueOf(valueToCompare.substringAfter('>')) != null && i>Integer.valueOf(valueToCompare.substringAfter('>')))
                            return i+'=INTEGER-true';
                        else if(valueToCompare.startsWith('<') && Integer.valueOf(valueToCompare.substringAfter('<')) != null && i<Integer.valueOf(valueToCompare.substringAfter('>')))
                            return i+'=INTEGER-true';
                        else if(Integer.valueOf(valueToCompare) == i)
                            return i+'=INTEGER-true';
                        else
                            return i+'=INTEGER-false';
                    }
                    else {
                        return '0=INTEGER-false';
                    }
                }
                when DOUBLE {
                    Decimal i = (Decimal)oppRec.get(fieldName);
                    if(oppRec.get(fieldName) != null){
                        if(valueToCompare.contains('>') && Decimal.valueOf(valueToCompare.substringAfter('>')) != null && i>Decimal.valueOf(valueToCompare.substringAfter('>')))
                            return i+'=DOUBLE-true';
                        else if(valueToCompare.contains('<') && Decimal.valueOf(valueToCompare.substringAfter('<')) != null && i<Decimal.valueOf(valueToCompare.substringAfter('>')))
                            return i+'=DOUBLE-true';
                        else if(!valueToCompare.contains('>') && !valueToCompare.contains('>')&& Decimal.valueOf(valueToCompare) == i)
                            return i+'=DOUBLE-true';
                        else
                            return i+'=DOUBLE-false';
                    }
                    else {
                        return '0=DOUBLE-false';
                    }
                }
                when CURRENCY {
                    Decimal i = (Decimal)oppRec.get(fieldName);
                    if(oppRec.get(fieldName) != null){
                        if(valueToCompare.contains('>') && Decimal.valueOf(valueToCompare.substringAfter('>')) != null && i>Decimal.valueOf(valueToCompare.substringAfter('>')))
                            return i+'=CURRENCY-true';
                        else if(valueToCompare.contains('<') && Decimal.valueOf(valueToCompare.substringAfter('<')) != null && i<Decimal.valueOf(valueToCompare.substringAfter('>')))
                            return i+'=CURRENCY-true';
                        else if(!valueToCompare.contains('>') && !valueToCompare.contains('>')&& Decimal.valueOf(valueToCompare) == i)
                            return i+'=CURRENCY-true';
                        else
                            return i+'=CURRENCY-false';
                    }
                    else {
                        return '0=CURRENCY-false';
                    }
                }
                when STRING {
                    if(oppRec.get(fieldName) != null && (valueToCompare == oppRec.get(fieldName) || valueToCompare.equalsIgnoreCase('blank'))){
                        return oppRec.get(fieldName)+'=STRING-true';
                    }
                    else if(oppRec.get(fieldName) != null && valueToCompare.contains('<>') && valueToCompare.substringAfter('<>') != oppRec.get(fieldName)){
                        return oppRec.get(fieldName)+'=STRING-true';
                    }
                    else {
                        return 'null=STRING-false';
                    }
                }
                when TEXTAREA {
                    if(oppRec.get(fieldName) != null && (valueToCompare == oppRec.get(fieldName) || valueToCompare.equalsIgnoreCase('blank'))){
                        return oppRec.get(fieldName)+'=TEXTAREA-true';
                    }
                    else {
                        return oppRec.get(fieldName)+'=TEXTAREA-false';
                    }
                }
                when PICKLIST {
                    String fieldVal = (String)oppRec.get(fieldName);
                    if(fieldVal != null && !valueToCompare.contains('<>') && (valueToCompare == fieldVal || valueToCompare.equalsIgnoreCase('blank') || valueToCompare.contains(fieldVal))){
                        return fieldVal+'=PICKLIST-true';
                    } else if(oppRec.get(fieldName) != null && valueToCompare.contains('<>') && ((!valueToCompare.contains(',')&& valueToCompare.substringAfter('<>') != oppRec.get(fieldName)) || !valueToCompare.contains(fieldVal))){
                        return fieldVal+'=PICKLIST-true';
                    }
                    else {
                        return fieldVal+'=PICKLIST-false';
                    }
                }
                when URL {
                    if(oppRec.get(fieldName) != null && (valueToCompare == oppRec.get(fieldName) || valueToCompare.equalsIgnoreCase('blank'))){
                        return oppRec.get(fieldName)+'=URL-true';
                    }
                    else {
                        return 'null=URL-false';
                    }
                }
                when REFERENCE {
                    if(oppRec.get(fieldName) != null){
                        return oppRec.get(fieldName)+'=REFERENCE-true';
                    }
                    else {
                        return 'null=REFERENCE-false';
                    }
                }
                when MULTIPICKLIST{
                    String fieldVal = (String)oppRec.get(fieldName);
                    if(fieldVal != null && (valueToCompare == fieldVal || valueToCompare.equalsIgnoreCase('blank') || fieldVal.contains(valueToCompare))){
                        return fieldVal+'=MULTIPICKLIST-true';
                    }else if(fieldVal != null && valueToCompare.contains('<>') && !fieldVal.contains(valueToCompare.substringAfter('<>'))){
                        return fieldVal+'=PICKLIST-true';
                    }
                    else {
                        return 'null=MULTIPICKLIST-false';
                    }
                }
                when DATE{
                    if(oppRec.get(fieldName) != null && valueToCompare.equalsIgnoreCase('blank')){
                        return oppRec.get(fieldName)+'=DATE-true';
                    }else{
                        return 'null=DATE-false';
                    }
                }
            }
        }
        system.debug('Account.Market_Segment__c--CPU Limit Consumption Start: '+Limits.getCPUtime());
            if(fieldName.equalsIgnoreCase('Account.Market_Segment__c') && !valueToCompare.contains('<>') && valueToCompare.equals(oppRec.Account.Market_Segment__c)){
                return oppRec.Account.Market_Segment__c+'=MULTIPICKLIST-true';
            }else if(fieldName.equalsIgnoreCase('Account.Market_Segment__c') && valueToCompare.contains('<>') && !valueToCompare.substringAfter('<>').contains(oppRec.Account.Market_Segment__c)){
                return oppRec.Account.Market_Segment__c+'=MULTIPICKLIST-true';
            }else if(fieldName.equalsIgnoreCase('Account.Market_Segment__c') && !valueToCompare.contains('<>') && valueToCompare.equals('Amount') 
                && ((oppRec.Account.Market_Segment__c.equals('Enterprise') && oppRec.Amount > 200000)|| (oppRec.Account.Market_Segment__c.equals('Commercial') && oppRec.Amount > 75000))){
                return oppRec.Account.Market_Segment__c+'=MULTIPICKLIST-true';
            }else if(fieldName.equalsIgnoreCase('Account.Market_Segment__c') && !valueToCompare.contains('<>') && valueToCompare.equals('Amount') 
                && !oppRec.Account.Market_Segment__c.equals('Enterprise') && !oppRec.Account.Market_Segment__c.equals('Commercial')){
            return oppRec.Account.Market_Segment__c+'=MULTIPICKLIST-true';
            }
            else if(fieldName.equalsIgnoreCase('Account.Market_Segment__c')){
                return oppRec.Account.Market_Segment__c+'=MULTIPICKLIST-false';
            }else if(fieldName.equalsIgnoreCase('Account.CSM_Name_New__c') && valueToCompare.equalsIgnoreCase('blank') && oppRec.Account.CSM_Name_New__c != null){
                return oppRec.Account.CSM_Name_New__c+'=REFERENCE-true';
            }else if(fieldName.equalsIgnoreCase('Account.CSM_Name_New__c') && valueToCompare.equalsIgnoreCase('blank') && oppRec.Account.CSM_Name_New__c == null){
                return 'null=REFERENCE-false';
            }
        
        
        /*if(fieldName.equalsIgnoreCase('SBQQ__PrimaryQuote__r.SBQQ__Primary__c') && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c== true){
return 'REFERENCE-true';
}*/
        return 'false';
    }
    
    public static Map<String,FileDataWP> getFileDetails(String oppId){
        Map<String,FileDataWP> fileMapper = new Map<String,FileDataWP>();
        Set<ID> ContentDocumentIdList = new Set<ID>();
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :oppId]){
            ContentDocumentIdList.add(cdl.ContentDocumentId);
        }
        System.debug('--ContentDocumentIdList--'+ContentDocumentIdList);
        
        for(ContentVersion cv : [SELECT ContentDocumentId,Source_fileupload__c,Title
                                 FROM ContentVersion WHERE (ContentDocumentId in :ContentDocumentIdList) and Source_fileupload__c != null and IsLatest=true])
        {
            
            FileDataWP obj = new FileDataWP();
            obj.fileId = cv.ContentDocumentId;
            obj.Title = cv.Title;
            fileMapper.put(cv.Source_fileupload__c,obj);
        }
        return fileMapper; 
    }
    
    public static FieldWrapper processFieldInfo(String fld,Map<String,String> labelAPINameMapping,Map<String,String> fieldtypes,
                                                Map<String,Boolean> fieldAcceptance, Map<String,Boolean> displayValMapping, Map<String,String> errorMsgMappings,
                                                Map<String,String> allowedFieldValues, Map<String,String> quickActionMappings, Map<String,FileDataWP> fileData,
                                                Opportunity oppRec, Map<String,String> fieldDependencies, String userType, Map<String,String> fieldsPermission,
                                                Map<String,String> greenFieldLabels, Map<String,String> hoverTexts, Boolean allowPermissionOverride,
                                                Map<Id,User> users)
    {
        List<ReferenceWrapper> attrs = new List<ReferenceWrapper>();
        FieldWrapper wrap ;
        FileDataWp filesInfo;
        Boolean conditionflag  = true;
        
        if(fld.contains(':')){
            for(string str: fld.substringBefore(':').split('&&')){
                String conditionfieldName = str.SubStringBefore('=');
                String conditionfieldValue = str.SubStringAfter('=');
                String conditionRetValue = conditionfieldName != null && conditionfieldValue != null ?determineFieldValue(conditionfieldName,conditionfieldValue,oppRec):'';
                conditionflag  &= conditionRetValue.contains('-') ?conditionRetValue.contains('true'):true;
            }
        }
        
        if(conditionflag == true){
            String str1 = fld.contains(':')?fld.SubStringAfter(':'):fld;
            String fieldName,fieldValue,retValue,fieldVal,picklistLabel;
            Boolean concatenatedFlag  = true;
            
            for(String eachField: str1.split('&&')){
                fieldName = eachField.SubStringBefore('=');
                fieldValue = eachField.SubStringAfter('=');
                retValue = determineFieldValue(fieldName,fieldValue,oppRec);
                concatenatedFlag  &= retValue.contains('-') ?retValue.contains('true'):true;
                fieldVal = retValue.contains('=')?retValue.SubStringBefore('='):'';
            }
            
            
            String fieldLabel = labelAPINameMapping?.get(fieldName);
            
            String actionName, actionObjectName,allowedValues,errMsg,dependentFieldNames,hoverText;
            
            
            String fieldType = fieldtypes.containsKey(fieldName)?fieldtypes.get(fieldName):retValue.substringBetween('=','-');
            Boolean allowInput = fieldAcceptance.containsKey(fieldName)?fieldAcceptance.get(fieldName):false;
            if(fieldsPermission.containsKey(fieldName) && allowInput){
                String allowedUserTypes = fieldsPermission.get(fieldName);
                
                 allowInput = (userType != null && allowedUserTypes.contains(userType)) || allowPermissionOverride?true:false;
                
            }
            if(fieldName.equalsIgnoreCase('Proposed_Number_of_Users__c') && oppRec.SBQQ__PrimaryQuote__c != null){
                allowInput = false;
            }else if(fieldName.equalsIgnoreCase('Amount') && oppRec.SBQQ__PrimaryQuote__c != null){
                allowInput = false;
            }
            Boolean displayVal = displayValMapping.containsKey(fieldName)?displayValMapping.get(fieldName):false;
            if(fieldType == 'REFERENCE'){
                if(fieldName.equalsIgnoreCase('Economic_Buyer_Contact__c'))
                {
                    attrs.add(new ReferenceWrapper(oppRec.Economic_Buyer_Contact__r.Name,(String) oppRec.get(fieldName),'Contact'));
                    //displayVal = false;
                }
                else if(fieldName.equalsIgnoreCase('Business_Champion_Contact__c'))
                {
                    attrs.add(new ReferenceWrapper(oppRec.Business_Champion_Contact__r.Name,(String) oppRec.get(fieldName),'Contact'));
                    //displayVal = false;
                }
                else if(fieldName.equalsIgnoreCase('Deployment_Contacts__c'))
                {
                    attrs.add(new ReferenceWrapper(oppRec.Deployment_Contacts__r.Name,(String) oppRec.get(fieldName),'Contact'));
                    //displayVal = false;
                }else if(fieldName.equalsIgnoreCase('Customer_Contact__c'))
                {
                    attrs.add(new ReferenceWrapper(oppRec.Customer_Contact__r.Name,(String) oppRec.get(fieldName),'Contact'));
                    //displayVal = false;
                }
                else if(fieldName.equalsIgnoreCase('Service_Owner_Contact__c'))
                {
                    attrs.add(new ReferenceWrapper(oppRec.Service_Owner_Contact__r.Name,(String) oppRec.get(fieldName),'Contact'));
                    //displayVal = false;
                }
                else if(fieldName.equalsIgnoreCase('Account.CSM_Name_New__c'))
                {
                    attrs.add(new ReferenceWrapper(users.get(oppRec.Account.CSM_Name_New__c)?.Name,(String) oppRec.Account.CSM_Name_New__c,'User'));
                    //displayVal = false;
                }
                else if(fieldName.equalsIgnoreCase('SBQQ__PrimaryQuote__c'))
                {
                    attrs.add(new ReferenceWrapper(oppRec.SBQQ__PrimaryQuote__r.Name,(String) oppRec.get(fieldName),'SBQQ__Quote__c'));
                    //displayVal = false;
                }
            }
            
            else if(fieldType == 'DATE' && String.isNotEmpty(fieldVal) && !fieldVal.contains('null')){
                Date dt = date.valueOf(fieldVal);
                fieldVal = Datetime.newInstance(dt.year(), dt.month(),dt.day()).format('yyyy-MMM-dd');
            }
            
            if(errorMsgMappings.containsKey(fieldName)){
                errMsg = errorMsgMappings.get(fieldName);
            }
            if(allowedFieldValues.containsKey(fieldName)){
                allowedValues = allowedFieldValues.get(fieldName);
            }
            String fileFieldLabel;
            if(fieldDependencies.containsKey(fieldName)){
                dependentFieldNames = fieldDependencies.get(fieldName);
                for(string depField: dependentFieldNames.split(',')){
                    if(depField.substringBetween(':', ':').equalsIgnoreCase('true')){
                        fileFieldLabel = depField.split(':')[2];
                    }
                }
            }
            System.debug('--dependentFieldNames--'+dependentFieldNames);
            if(fieldType == 'fileLink' && fileData.containsKey(fieldLabel)){
                filesInfo = fileData.get(fieldLabel);
                
            }else if(String.isNotBlank(fileFieldLabel)){
                filesInfo = fileData.get(fileFieldLabel);
            }
            System.debug('--filesInfo--'+filesInfo);
            if(!concatenatedFlag && quickActionMappings.containsKey(fieldName)){
                actionName = quickActionMappings.get(fieldName).substringBefore(':');
                actionObjectName = quickActionMappings.get(fieldName).substringAfter(':');
            }

            //Validation Stage processing

            if(fieldName.equalsIgnoreCase('Validation_Stage__c')){
                Set<String> notStartedValues = new Set<String>{'0 - Not Started','1 - Establishing Plan & success criteria','2 - Configuration in Progress'};
                Set<String> inProgressValues = new Set<String>{'3 - Detailed validation in progress','4 - Delivering validation findings report','5 - Validation Stalled'};
                Set<String> notRequiredValues = new Set<String>{'8 - Not Required','8B - Not Required - Preferred'};
                Set<String> closedValues = new Set<String>{'6 - Technical Win','7 - Technical Loss'};
                picklistLabel = (String) oppRec.get('ValidationLabel');
                if(fieldVal== 'null' || notStartedValues.contains(fieldVal)){
                    if(fieldVal== 'null' || oppRec.StageName == '3 - Sponsorship' ||  oppRec.StageName == '4 - Impact Validation')
                    concatenatedFlag = false;
                    else
                    concatenatedFlag = true;
                    
                    fieldLabel = 'Technical Validation Not Started';


                }else if (inProgressValues.contains(fieldVal)){
                    if(oppRec.StageName == '2 - Architecture & Alignment' || (oppRec.StageName == '3 - Sponsorship' && oppRec.Technical_Validation_Start_Date__c != null && oppRec.Competitor__c != null &&
                    oppRec.Validation_Plan__c != null))
                    concatenatedFlag = true;
                    else
                    concatenatedFlag = false;
                    fieldLabel = 'Technical Validation In Progress';

                }else if(notRequiredValues.contains(fieldVal)){
                    concatenatedFlag = true;
                    fieldLabel = 'Technical Validation Not Required';
                }else if(fieldVal.equalsIgnoreCase('6 - Technical Win')){
                    if(oppRec.Technical_Validation_Start_Date__c != null && oppRec.Competitor__c != null &&
                    oppRec.Validation_Plan__c != null && oppRec.Technical_Validation_Start_Date__c != null)
                    concatenatedFlag = true;
                        else
                        concatenatedFlag = false;
                        fieldLabel = 'Technical Validation Win';
                }else if(fieldVal.equalsIgnoreCase('5b - Pending customer decision')){
                     if((oppRec.StageName == '2 - Architecture & Alignment') || (oppRec.StageName == '3 - Sponsorship' && oppRec.Technical_Validation_Start_Date__c != null && oppRec.Competitor__c != null &&
                     oppRec.Validation_Plan__c != null)){
                        concatenatedFlag = true;
                     }else{
                        concatenatedFlag = false;
                     }
                      fieldLabel = 'Pending Customer Decision';

                }else{

                    concatenatedFlag = true;
                    fieldLabel = 'Technical Validation Loss';
                }
                
            }

            //Process Field Labels and Hover Text
            if(greenFieldLabels.containsKey(fieldName) && concatenatedFlag){
                fieldLabel = greenFieldLabels.get(fieldName);
            }

            if(hoverTexts.containsKey(fieldName)){
                hoverText = hoverTexts.get(fieldName);
            }
            
            wrap = new FieldWrapper(fieldLabel,fieldVal,concatenatedFlag,fieldName,fieldType,allowInput,attrs, 
                                    displayVal,filesInfo,actionName, actionObjectName,allowedValues,errMsg,dependentFieldNames,hoverText,picklistLabel);
            
        }  
        return wrap;
    }

    public static List<OppStageChecklistHelper.HelperWrapper> miniProcessFieldInfo(String fld,Map<String,String> labelAPINameMapping,Map<String,String> fieldtypes,
                                                Map<String,Boolean> fieldAcceptance, Map<String,FileDataWP> fileData,
                                                Opportunity oppRec, Map<String,String> fieldDependencies, String userType, Map<String,String> fieldsPermission,
                                                Boolean allowPermissionOverride, Boolean isRequired)
    {
        
        FileDataWp filesInfo;
        Boolean conditionflag  = true;
        OppStageChecklistHelper.HelperWrapper wrap;
        List<OppStageChecklistHelper.HelperWrapper> fields = new List<OppStageChecklistHelper.HelperWrapper>();
        if(fld.contains(':')){
            for(string str: fld.substringBefore(':').split('&&')){
                String conditionfieldName = str.SubStringBefore('=');
                String conditionfieldValue = str.SubStringAfter('=');
                String conditionRetValue = conditionfieldName != null && conditionfieldValue != null ?determineFieldValue(conditionfieldName,conditionfieldValue,oppRec):'';
                conditionflag  &= conditionRetValue.contains('-') ?conditionRetValue.contains('true'):true;
            }
        }
        
        if(conditionflag == true){
            String str1 = fld.contains(':')?fld.SubStringAfter(':'):fld;
            String fieldName,fieldValue,retValue,fieldVal,picklistLabel,fieldType,fileName,fileId,fieldLabel;
            Boolean concatenatedFlag  = true;
            Boolean allowInput;
            
            for(String eachField: str1.split('&&')){
                fieldName = eachField.SubStringBefore('=');
                fieldValue = eachField.SubStringAfter('=');
                retValue = determineFieldValue(fieldName,fieldValue,oppRec);
                concatenatedFlag  &= retValue.contains('-') ?retValue.contains('true'):true;
                fieldVal = retValue.contains('=')?retValue.SubStringBefore('='):'';
                allowInput = fieldAcceptance.containsKey(fieldName)?fieldAcceptance.get(fieldName):false;
                fieldLabel = labelAPINameMapping?.get(fieldName);
                fieldType = fieldtypes.containsKey(fieldName)?fieldtypes.get(fieldName):retValue.substringBetween('=','-');
                if(fieldsPermission.containsKey(fieldName) && allowInput){
                    String allowedUserTypes = fieldsPermission.get(fieldName);
                    
                     allowInput = (userType != null && allowedUserTypes.contains(userType)) || allowPermissionOverride?true:false;
                    
                }
                if(fieldName.equalsIgnoreCase('Proposed_Number_of_Users__c') && oppRec.SBQQ__PrimaryQuote__c != null){
                    allowInput = false;
                }else if(fieldName.equalsIgnoreCase('Amount') && oppRec.SBQQ__PrimaryQuote__c != null){
                    allowInput = false;
                }
                Boolean isFile = fieldType == 'fileLink' ? true:false;
                if(String.isNotBlank(fieldLabel) && fileData.containsKey(fieldLabel)){
                    filesInfo = fileData.get(fieldLabel);
                    fileName = filesInfo.Title;
                    fileId = filesInfo.fileId;
                    
                }

                if(fieldName.equalsIgnoreCase('Proposed_Number_of_Users__c') && oppRec.SBQQ__PrimaryQuote__c != null){
                    allowInput = false;
                }else if(fieldName.equalsIgnoreCase('Amount') && oppRec.SBQQ__PrimaryQuote__c != null){
                    allowInput = false;
                }
                Boolean isCustomPicklist = fieldName.equalsIgnoreCase('Buyer_Initiative__c');
                wrap = new OppStageChecklistHelper.HelperWrapper(fieldName,fieldLabel,isFile,fileName,fileId,
                        fieldType,isCustomPicklist,allowInput,isRequired);
                fields.add(wrap);
            }
            
            
           
            
            
            
                        
            
        }  
        return fields;
    }
    
    //method to wrap and return the data elements to LWC
    @AuraEnabled(cacheable=true)
    public static DataWrapper fetchDetails(Id opportunityId){
        String headerInfo;
        DataWrapper obj = new DataWrapper();
        try{
            //stores the list of field properties for Tab 1 in LWC
            requiredFields = new List<FieldWrapper>();
            //stores the list of field properties for Tab 2 in LWC
            optionalFields = new List<FieldWrapper>();
            //stores the field api's and equivalent labels to display on LWC
            attrs = new List<ReferenceWrapper>();
            Map<String,String> labelAPINameMapping = new Map<String,String>();
            Map<String,String> fieldtypes = new Map<String,String>();
            Map<String,Boolean> fieldAcceptance = new Map<String,Boolean>();
            Map<String,Boolean> displayValMapping = new Map<String,Boolean>();
            Map<String,String> quickActionMappings = new Map<String,String>();
            Map<String,String> errorMsgMappings = new Map<String,String>();
            Map<String,String> allowedFieldValues = new Map<String,String>();
            Map<String,String> fieldDependencies = new Map<String,String>();
            Map<String,String> fieldsPermission = new Map<String,String>();
            Map<String,String> greenFieldLabels = new Map<String,String>();
            Map<String,String> hoverTexts = new Map<String,String>();
            opp = [SELECT Id,Name,StageName,RecordType.Name, RecordTypeId,Days_in_Current_Stage__c,
                   Last_Stage_Changed_Date__c,Owner.Name,CreatedBy.Name,Forecast_Category__c  FROM Opportunity WHERE Id=: opportunityId];
            Set<String> uniqueFieldNames = new Set<String>();
            fieldList = new map<string, Schema.DisplayType>();
            map<string,SObjectField> fList = schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
            for(string str: fList.keySet()){
                fieldList.put(str, fList.get(str).getDescribe().getType());                
            }
            recordTypeId = opp.RecordTypeId;
            Profile loggedInProfile = [SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()];
            String userType = profileUserTypes.containsKey(loggedInProfile.Name)?profileUserTypes.get(loggedInProfile.Name):null;
            List<Opportunity_Stage_Age__c> stageAge = [SELECT Id,Age__c FROM Opportunity_Stage_Age__c WHERE Opportunity__c =: opp.Id AND Stage__c =: opp.StageName ORDER BY lastmodifieddate desc];
            Map<Id,User> users = new Map<Id,User>([SELECT Id,Name FROM User WHERE IsActive =: true AND Profile.Name = 'Core Sales - CSM' LIMIT 50000]);
            Map<String,FileDataWp> fileData = getFileDetails(opp.Id);
            String queryStr = 'SELECT Id,StageName,toLabel(Validation_Stage__c) ValidationLabel';
            //retrieve metadata properties based on opportunity record type and current stage value
            List<Opp_Stage_Mapping__mdt> metadataVals = [SELECT Exception_Permission__c,Exception_Field_Names__c,important_links__c,
            Authorized_Personnel_for_Closure__c,Field_Labels__c,Opportunity_Record_Type__c,Optional_Fields__c,Stage_Description__c,
                                                         Optional_Fields_Criteria__c,Required_Field_Criteria__c,Required_Field_Names__c,Action_Steps_Owner__c,
                                                         Display_Field_Value_Mapping__c,Quick_Action_Mapping__c,Allowed_Field_Values__c,Dependent_Fields__c,Error_Message_Mappings__c,
                                                         Next_Stage_value__c, Stage_Value__c, Prev_Stage_Value__c,Fields_Permission__c, Input_Output_Field_Mappings__c,Override_Field_Acceptance__c, 
                                                         Header_Info__c,Authorized_Personnel_for_Stage_Updates__c,Green_Field_Labels__c,Hover_Text__c FROM Opp_Stage_Mapping__mdt WHERE 
                                                         Stage_Value__c =: Opp.StageName AND Opportunity_Record_Type__c =: opp.RecordType.Name ];
            
            if(!metadataVals.isEmpty()){
                Opp_Stage_Mapping__mdt metadata = metadataVals[0];
                nextStageValue = metadata.Next_Stage_Value__c;
                prevStageValue = metadata.Prev_Stage_Value__c;
                stageDescription = metadata.Stage_Description__c;
                if(String.isNotBlank(metadata.Action_Steps_Owner__c)){
                    actorsInvolved = '';
                    for(String str: metadata.Action_Steps_Owner__c.split(';',0)){
                        actorsInvolved+='<strong>'+str.SubStringBefore('=')+'</strong>'+str.SubStringAfter('=')+'<br>';
                    }
                }
                //actorsInvolved = metadata.Action_Steps_Owner__c;
                headerInfo = metadata.Header_Info__c;
                
                //check if Execption is Enabled
                if(String.isNotBlank(metadata.Exception_Permission__c)){
                    allowPermissionOverride = FeatureManagement.checkPermission(metadata.Exception_Permission__c) ? true: false;
                }
                
                if(String.isNotBlank(metadata.Field_Labels__c)){
                    for(String str: metadata.Field_Labels__c.split(';',0)){
                        labelAPINameMapping.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }

                if(String.isNotBlank(metadata.Green_Field_Labels__c)){
                    for(String str: metadata.Green_Field_Labels__c.split(';',0)){
                        greenFieldLabels.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }

                if(String.isNotBlank(metadata.Hover_Text__c)){
                    for(String str: metadata.Hover_Text__c.split(';',0)){
                        hoverTexts.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }
                
                
                if(String.isNotBlank(metadata.Fields_Permission__c)){
                    for(String str: metadata.Fields_Permission__c.split(';',0)){
                        fieldsPermission.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }
                
                if(String.isNotBlank(metadata.Important_Links__c)){
                    for(String str: metadata.Important_Links__c.split(';',0)){
                        importantLinks.add(new ReferenceWrapper(str.SubStringBefore('='),str.SubStringAfter('='),'Object'));
                    }
                }
                if(String.isNotBlank(metadata.Quick_Action_Mapping__c)){
                    for(String str: metadata.Quick_Action_Mapping__c.split(';',0)){
                        quickActionMappings.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }
                if(String.isNotBlank(metadata.Allowed_Field_Values__c)){
                    for(String str: metadata.Allowed_Field_Values__c.split(';',0)){
                        allowedFieldValues.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }
                
                if(String.isNotBlank(metadata.Dependent_Fields__c)){
                    for(String str: metadata.Dependent_Fields__c.split(';',0)){
                        fieldDependencies.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }
                
                if(String.isNotBlank(metadata.Error_Message_Mappings__c)){
                    for(String str: metadata.Error_Message_Mappings__c.split(';',0)){
                        errorMsgMappings.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }
                
                
                if(String.isNotBlank(metadata.Override_Field_Acceptance__c)){
                    for(String str: metadata.Override_Field_Acceptance__c.split(';',0)){
                        fieldAcceptance.put(str.SubStringBefore('='),str.SubStringAfter('=') == 'Yes' ? true : false);
                    }
                }
                if(String.isNotBlank(metadata.Display_Field_Value_Mapping__c)){
                    for(String str: metadata.Display_Field_Value_Mapping__c.split(';',0)){
                        displayValMapping.put(str.SubStringBefore('='),str.SubStringAfter('=') == 'true' ? true : false);
                    }
                }
                if(String.isNotBlank(metadata.Input_Output_Field_Mappings__c)){
                    for(String str: metadata.Input_Output_Field_Mappings__c.split(';',0)){
                        
                        fieldtypes.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }
                
                if(String.isNotBlank(metadata.Required_Field_Names__c)){
                    for(String fieldName: metadata.Required_Field_Names__c.split(',',0)){
                        queryStr += ', '+fieldName;
                    }
                }
                
                if(String.isNotBlank(metadata.Optional_Fields__c)){
                    for(String fieldName: metadata.Optional_Fields__c.split(',',0)){
                        queryStr += ', '+fieldName;
                    }
                }
                
                if(string.isNotBlank(metadata.Exception_Field_Names__c)){
                    for(String fieldName: metadata.Exception_Field_Names__c.split(',',0)){
                        queryStr += ', '+fieldName;
                    }
                }
                
                queryStr += ' FROM Opportunity WHERE Id =: opportunityId';
                
                Opportunity oppRec = (Opportunity) Database.query(queryStr)[0];
                
                if(String.isNotBlank(metadata.Required_Field_Criteria__c)){
                    Integer counter = 0;
                    
                    for(String fld: metadata.Required_Field_Criteria__c.split(';',0)){
                        FieldWrapper wrapObj = processFieldInfo(fld,labelAPINameMapping,fieldtypes,fieldAcceptance, displayValMapping, errorMsgMappings,
                                                                allowedFieldvalues, quickActionMappings, fileData, oppRec,fieldDependencies, userType, fieldsPermission,
                                                                greenFieldLabels,hoverTexts,allowPermissionOverride,users);
                        if(wrapObj != null){
                            requiredFields.add(wrapObj);
                            if(!wrapObj.booleanValue)
                                counter++;
                        }
                    }
                    
                    if(counter==0){
                        isRequiredFulfilled = true;
                        
                    }else {
                        isRequiredFulfilled = false;
                    }
                }else{
                    isRequiredFulfilled = true;
                    
                }
                
                if(String.isNotBlank(metadata.Optional_Fields_Criteria__c)){
                    for(String fld: metadata.Optional_Fields_Criteria__c.split(';',0)){
                        FieldWrapper wrapObj = processFieldInfo(fld,labelAPINameMapping,fieldtypes,fieldAcceptance, displayValMapping, errorMsgMappings,
                                                                allowedFieldvalues, quickActionMappings, fileData, oppRec,fieldDependencies, userType, fieldsPermission,
                                                                greenFieldLabels,hoverTexts,allowPermissionOverride,users);
                        if(wrapObj != null){
                            optionalFields.add(wrapObj);
                        }   
                        
                    }
                }
                
                obj.allowStageUpdates = false;
               
                if(String.isNotBlank(metadata.Authorized_Personnel_for_Stage_Updates__c)){
                    if(String.isNotEmpty(userType) && metadata.Authorized_Personnel_for_Stage_Updates__c.contains(userType)){
                        obj.allowStageUpdates = true;
                    }
                }
                obj.allowClosure = false;
                if(String.isNotBlank(metadata.Authorized_Personnel_for_Closure__c)){
                    if(String.isNotEmpty(userType) && metadata.Authorized_Personnel_for_Closure__c.contains(userType)){
                        obj.allowClosure = true;
                    }
                }
                
                obj.allowPermissionOverride = allowPermissionOverride;
                obj.isRequiredFulfilled = isRequiredFulfilled;
                obj.optionalFields = optionalFields;
                obj.requiredFields = requiredFields;
                obj.nextStageValue = nextStageValue;
                obj.prevStageValue = prevStageValue;
                obj.recordTypeId = recordTypeId;
                obj.actorsInvolved = actorsInvolved;
                obj.stageDescription = stageDescription;
                obj.createdByName = opp.CreatedBy.Name;
                obj.ownerName = opp.Owner.Name;
                obj.loginUserDetails = [Select Id,Name From User Where Id=:UserInfo.getUserId() Limit 1];           
                obj.oppTeamMembers = [select id,OpportunityId, Name, OpportunityAccessLevel from OpportunityTeamMember where OpportunityId=:opportunityId];           
                obj.loggedInProfile =loggedInProfile;     
                if(stageAge.isEmpty()){
                    obj.daysinCurrentStage = opp.Days_in_Current_Stage__c.intValue();
                }else{
                    for(Opportunity_Stage_Age__c oppStage: stageAge){
                        obj.daysinCurrentStage = oppStage.Age__c.intValue();
                    }
                }
                obj.daysinCurrentStage = obj.daysinCurrentStage == 0?1:obj.daysinCurrentStage;
                obj.lastChangedDate = opp.Last_Stage_Changed_Date__c;
                obj.forecastCategory = opp.Forecast_Category__c;
                obj.importantLinks = importantLinks;
                obj.headerInfo = headerInfo;                
                
                
            }
            
            
        }catch(Exception e){
            system.debug(e.getCause()+'--'+e.getMessage()+'--'+e.getLineNumber());
        }
        return obj;
    }
    
    @AuraEnabled
    public static void updateOpportunityStage(String opportunityId, String stageValue, String subStage,
                                              String validatedSolutionTechPartner, String fieldSet, String overageReason, 
                                              String competitiveDeal,String pcVal,String otherPrimaryCompetitor,
                                              String scVal,String otherSecondaryCompetitor, String requiresSigningCustomerDocuments){
        try{
            if(fieldSet != null){
                Sobject churn = (Sobject) JSON.deserialize(fieldSet,Sobject.class);
                upsert churn;
            }
            
            Opportunity oppRec = new Opportunity(Id=opportunityId,StageName = stageValue, Checklist_Update__c = true);
            
            if(String.isNotBlank(subStage)){
                oppRec.Sub_Stage__c = subStage;
                oppRec.isChurnpresent__c = true;
                oppRec.Reason_form_check__c = false;
                oppRec.Confirm_Opportunity_Closure__c = true;
                oppRec.CloseDate = system.today();
            }
            if(String.isNotBlank(validatedSolutionTechPartner)){
                oppRec.Validated_Solution_Tech_Partner__c = validatedSolutionTechPartner;
            }

            if(String.isNotBlank(overageReason)){
                oppRec.Reason_for_overage_loss__c = overageReason;
            }

            if(String.isNotBlank(competitiveDeal)){
                oppRec.How_competitive_was_the_deal__c = competitiveDeal;
            }
            if(String.isNotBlank(pcVal)){
                oppRec.Primary_Competitor__c = pcVal;
                if(pcVal != 'Other'){
                    oppRec.Other_Primary_competitor__c = '';
                }
            }
            if(String.isNotBlank(otherPrimaryCompetitor)){
                oppRec.Other_Primary_competitor__c = otherPrimaryCompetitor;
            }
            if(String.isNotBlank(scVal)){
                oppRec.Secondary_Competitors__c = scVal;
                if(!scVal.contains('Others')){
                    oppRec.Other_Secondary_competitor__c = '';
                }
            }
            if(String.isNotBlank(otherSecondaryCompetitor)){
                oppRec.Other_Secondary_competitor__c = otherSecondaryCompetitor;
            }
            if(String.isNotBlank(requiresSigningCustomerDocuments)){
                oppRec.Requires_signing_customer_documents__c = requiresSigningCustomerDocuments;
            }
            update oppRec;
            TriggerHandler.bypass('OpportunityTriggerHandler');
            //if(StageValue != Label.Stage_7_Closed_Lost){
                oppRec.Checklist_Update__c = false;
            	update oppRec;
           // }
            

        }catch(Exception e){
            system.debug(fieldSet);
            system.debug(e.getMessage() + ', ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    //this method binds solution and Buyer Initiative values
    @AuraEnabled
    public static Map<String,List<String>> getSolutionMapping(){
        Map<String,List<String>> solutionMapping = new Map<String,List<String>>();
        try{
            
            for(Solution_Buyer_Initiative_Mapping__mdt sol: Solution_Buyer_Initiative_Mapping__mdt.getAll().values()){
                List<String> biValues = solutionMapping.containsKey(sol.Solution__c)?solutionMapping.get(sol.Solution__c):new List<String>();
                biValues.add(sol.Buyer_Initiative__c);
                solutionMapping.put(sol.Solution__c,biValues);

            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return solutionMapping;
    }

     //this method determines the required and depedent fields for Validation Stage
     @AuraEnabled
     public static List<ValidationWrapper> getValidationDependencies(String oppId){
         Opportunity oppObj = [SELECT Id,Competitor__c,Validation_Stage__c, Technical_Validation_Start_Date__c,Validation_End_Date__c FROM Opportunity WHERE Id =: oppId ];
         Map<String,FileDataWP> fileWrapper = getFileDetails(oppId);
         Set<String> allowedValues = new Set<String>{'3 - Detailed validation in progress','4 - Delivering validation findings report','5 - Validation Stalled',
         '5b - Pending customer decision', '6 - Technical Win','7 - Technical Loss'};
        
         List<ValidationWrapper> objects = new List<ValidationWrapper>();
         system.debug('--oppObj.Validation_Stage__c'+oppObj.Validation_Stage__c);
            Boolean isStartDateRequired = allowedValues.contains(oppObj.Validation_Stage__c) ?true:false;
            Boolean isEndDateRequired = allowedValues.contains(oppObj.Validation_Stage__c) || oppObj.Validation_Stage__c == '2 - Configuration in Progress'?true:false;
            ValidationWrapper wrap = new ValidationWrapper('Technical_Validation_Start_Date__c','Technical Validation Start Date',false,isStartDateRequired,'','','','');
            objects.add(wrap);
            wrap = new ValidationWrapper('Validation_End_Date__c','Technical Validation End Date',false,isEndDateRequired,'','','','');
            objects.add(wrap);
            if(fileWrapper.containsKey('Attach POV Plan')){
                FileDataWP singleFile = fileWrapper.get('Attach POV Plan');
                wrap = new ValidationWrapper('Validation_Plan__c','Attach POV Plan',false,false,singleFile.Title,singleFile.fileId,'POV Plan Approved','POV_Scope_Approved__c');
            }else{
                wrap = new ValidationWrapper('Validation_Plan__c','Attach POV Plan',false,false,'','','POV Plan Approved','POV_Scope_Approved__c');
            }
            objects.add(wrap);
            
            if(fileWrapper.containsKey('Attach POV Playback/Validation Report')){
                FileDataWP singleFile1 = fileWrapper.get('Attach POV Playback/Validation Report');
                wrap = new ValidationWrapper('Validation_Report__c','Attach POV Playback/Validation Report',false,false,singleFile1.Title,singleFile1.fileId,'POV Playback Approved','POV_Playback_Approved__c');
            }else{
                wrap = new ValidationWrapper('Validation_Report__c','Attach POV Playback/Validation Report',false,false,'','','POV Playback Approved','POV_Playback_Approved__c');
            }
            objects.add(wrap);
           
            wrap = new ValidationWrapper('Competitor__c','Competitor',false,false,'','','','');
            objects.add(wrap);
            if(oppObj.Competitor__c != null && oppObj.Competitor__c.contains('Other')){
                wrap = new ValidationWrapper('Other_Competitors__c','Other Competitors',false,false,'','','','');
                objects.add(wrap);
            }
           
       
        return objects;
     }


      //method to wrap and return the data elements to LWC
    @AuraEnabled(cacheable=true)
    public static List<EditWrapper> getDetailsForEdit(Id opportunityId){
       
        List<EditWrapper> fields = new List<EditWrapper>();
        try{
           
           
            
            //stores the field api's and equivalent labels to display on LWC
            attrs = new List<ReferenceWrapper>();
            Map<String,String> labelAPINameMapping = new Map<String,String>();
            Map<String,String> fieldtypes = new Map<String,String>();
            Map<String,Boolean> fieldAcceptance = new Map<String,Boolean>();
            Map<String,Boolean> displayValMapping = new Map<String,Boolean>();
            Map<String,String> quickActionMappings = new Map<String,String>();
            Map<String,String> errorMsgMappings = new Map<String,String>();
            Map<String,String> allowedFieldValues = new Map<String,String>();
            Map<String,String> fieldDependencies = new Map<String,String>();
            Map<String,String> fieldsPermission = new Map<String,String>();
            Map<String,String> greenFieldLabels = new Map<String,String>();
            Map<String,String> hoverTexts = new Map<String,String>();
            Set<String> allowedStageValues = new Set<String>{'1 - Discovery & Qualification','2 - Architecture & Alignment','3 - Sponsorship','4 - Impact Validation'};
            opp = [SELECT Id,Name,StageName,RecordType.Name  FROM Opportunity WHERE Id=: opportunityId];
            Set<String> uniqueFieldNames = new Set<String>();
            fieldList = new map<string, Schema.DisplayType>();
            map<string,SObjectField> fList = schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
            for(string str: fList.keySet()){
                fieldList.put(str, fList.get(str).getDescribe().getType());                
            }
            recordTypeId = opp.RecordTypeId;
            Profile loggedInProfile = [SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()];
            String userType = profileUserTypes.containsKey(loggedInProfile.Name)?profileUserTypes.get(loggedInProfile.Name):null;
            Map<Id,User> users = new Map<Id,User>([SELECT Id,Name FROM User WHERE IsActive =: true AND Profile.Name = 'Core Sales - CSM' LIMIT 50000]);
            Map<String,FileDataWp> fileData = getFileDetails(opp.Id);
            Set<String> uniqueFields = new Set<String>();
            String queryStr = 'SELECT Id,StageName,toLabel(Validation_Stage__c) ValidationLabel';
            Boolean isRequired = true;
            //retrieve metadata properties based on opportunity record type and current stage value
            List<Opp_Stage_Mapping__mdt> metadataVals = [SELECT Exception_Permission__c,Exception_Field_Names__c,important_links__c,
            Authorized_Personnel_for_Closure__c,Field_Labels__c,Opportunity_Record_Type__c,Optional_Fields__c,Stage_Description__c,
                                                         Optional_Fields_Criteria__c,Required_Field_Criteria__c,Required_Field_Names__c,Action_Steps_Owner__c,
                                                         Display_Field_Value_Mapping__c,Quick_Action_Mapping__c,Allowed_Field_Values__c,Dependent_Fields__c,Error_Message_Mappings__c,
                                                         Next_Stage_value__c, Stage_Value__c, Prev_Stage_Value__c,Fields_Permission__c, Input_Output_Field_Mappings__c,Override_Field_Acceptance__c, 
                                                         Header_Info__c,Authorized_Personnel_for_Stage_Updates__c,Green_Field_Labels__c,Hover_Text__c FROM Opp_Stage_Mapping__mdt WHERE 
                                                         Stage_Value__c IN: allowedStageValues AND Opportunity_Record_Type__c =: opp.RecordType.Name ORDER BY Stage_Value__c ASC];
            
            if(!metadataVals.isEmpty()){
               
                for(Opp_Stage_Mapping__mdt metadata: metadataVals){

                    if(String.isNotBlank(metadata.Required_Field_Names__c)){
                        for(String fieldName: metadata.Required_Field_Names__c.split(',',0)){
                            if(!uniqueFields.contains(fieldName.toLowerCase().trim())){
                                uniqueFields.add(fieldName.toLowerCase().trim());
                                queryStr += ', '+fieldName;
                            }
                        }
                    }
                    
                    if(String.isNotBlank(metadata.Optional_Fields__c)){
                        for(String fieldName: metadata.Optional_Fields__c.split(',',0)){
                            if(!uniqueFields.contains(fieldName.toLowerCase().trim())){
                                uniqueFields.add(fieldName.toLowerCase().trim());
                                queryStr += ', '+fieldName;
                            }
                        }
                    }
                }

                system.debug('--queryStr--'+queryStr);
                queryStr += ' FROM Opportunity WHERE Id =: opportunityId';
                
                Opportunity oppRec = (Opportunity) Database.query(queryStr)[0];

                for(Opp_Stage_Mapping__mdt metadata: metadataVals){

                        //check if Execption is Enabled
                    if(String.isNotBlank(metadata.Exception_Permission__c)){
                        allowPermissionOverride = FeatureManagement.checkPermission(metadata.Exception_Permission__c) ? true: false;
                    }
                    
                    if(String.isNotBlank(metadata.Field_Labels__c)){
                        for(String str: metadata.Field_Labels__c.split(';',0)){
                            labelAPINameMapping.put(str.SubStringBefore('='),str.SubStringAfter('='));
                        }
                    }

                    if(String.isNotBlank(metadata.Fields_Permission__c)){
                        for(String str: metadata.Fields_Permission__c.split(';',0)){
                            fieldsPermission.put(str.SubStringBefore('='),str.SubStringAfter('='));
                        }
                    }
                    
                    if(String.isNotBlank(metadata.Dependent_Fields__c)){
                        for(String str: metadata.Dependent_Fields__c.split(';',0)){
                            fieldDependencies.put(str.SubStringBefore('='),str.SubStringAfter('='));
                        }
                    }
                    
                    
                    
                    
                    if(String.isNotBlank(metadata.Override_Field_Acceptance__c)){
                        for(String str: metadata.Override_Field_Acceptance__c.split(';',0)){
                            fieldAcceptance.put(str.SubStringBefore('='),str.SubStringAfter('=') == 'Yes' ? true : false);
                        }
                    }
                    
                    if(String.isNotBlank(metadata.Input_Output_Field_Mappings__c)){
                        for(String str: metadata.Input_Output_Field_Mappings__c.split(';',0)){
                            
                            fieldtypes.put(str.SubStringBefore('='),str.SubStringAfter('='));
                        }
                    }
                    
                    
                    
                    
                    
                    
                    
                    if(String.isNotBlank(metadata.Required_Field_Criteria__c)){
                        EditWrapper editWrap = new EditWrapper();
                        List<OppStageChecklistHelper.HelperWrapper> wrappers = new List<OppStageChecklistHelper.HelperWrapper>();
                        
                        for(String fld: metadata.Required_Field_Criteria__c.split(';',0)){
                            
                            
                            for(OppStageChecklistHelper.HelperWrapper wrap: miniProcessFieldInfo(fld,labelAPINameMapping,fieldtypes,fieldAcceptance, fileData, oppRec,fieldDependencies, userType, fieldsPermission,
                                                                                         allowPermissionOverride, isRequired)){
                                if(wrap.allowInput && !wrap.fieldName.equalsIgnoreCase('Validation_Stage__c')){
                                    wrappers.add(wrap);
                                }
                                                                                            
                            }
                        }
                        editWrap.stageVal = metadata.Stage_Value__c;
                        editWrap.prevStage = metadata.Prev_Stage_Value__c;
                        editWrap.nextStage = metadata.Next_Stage_value__c;
                        editWrap.fieldsList = wrappers;
                        fields.add(editWrap);
                        
                    }
                    
                    if(oppRec.StageName == metadata.Stage_Value__c){
                        isRequired = false;
                    }
                }

                
                
                
            }
            
            
        }catch(Exception e){
            system.debug(e.getCause()+'--'+e.getMessage()+'--'+e.getLineNumber());
        }
        return fields;
    }

    //added by Arsh - CR 4752 start
    //this updates the qualifying SDR of the closing opportunity to the duplicate opportunity selected - called from OppClosedLostDuplicate.js
    @AuraEnabled
    public static void updateLinkedOppSDR(String opportunityId, String duplicateOppId){
        try{
            if(duplicateOppId != null){
                boolean isUpdateNeeded = false;
                List<Opportunity> dupOpp = [select Id,LDR_Name__c,Qualified_Date__c,LDR_Opp_Date__c,Qualification_Notes__c, Qualifier_Role__c
                                 from Opportunity where Id = :duplicateOppId limit 1];
                List<Opportunity> opp = [select Id,LDR_Name__c,Qualified_Date__c,LDR_Opp_Date__c,Qualification_Notes__c, Qualifier_Role__c
                                 from Opportunity where Id = :opportunityId limit 1];
                
                Opportunity oppRec = new Opportunity(Id=dupOpp[0].Id);
                if(dupOpp[0].LDR_Name__c == null && opp[0].LDR_Name__c != null ) {
                    oppRec.LDR_Name__c = opp[0].LDR_Name__c;
                    isUpdateNeeded= true;
                }
                if(dupOpp[0].Qualified_Date__c == null && opp[0].Qualified_Date__c != null ){
                    oppRec.Qualified_Date__c = opp[0].Qualified_Date__c;
                    isUpdateNeeded= true;
                }
                if(dupOpp[0].LDR_Opp_Date__c == null && opp[0].LDR_Opp_Date__c != null){
                    oppRec.LDR_Opp_Date__c = opp[0].LDR_Opp_Date__c;
                    isUpdateNeeded= true;
                }
                if(dupOpp[0].Qualification_Notes__c == null && opp[0].Qualification_Notes__c != null){
                    oppRec.Qualification_Notes__c = opp[0].Qualification_Notes__c;
                    isUpdateNeeded= true;
                }
                if(dupOpp[0].Qualifier_Role__c == null && opp[0].Qualifier_Role__c != null){
                    oppRec.Qualifier_Role__c = opp[0].Qualifier_Role__c;
                    isUpdateNeeded= true;
                }
                if(isUpdateNeeded){
                    TriggerHandler.bypass('OpportunityTriggerHandler');
                    update oppRec;
                }
            }
        }catch(Exception e){
            system.debug('Duplicate opportunity update error'+ e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    //added by Arsh - CR 4752 end
    
    public class EditWrapper{
        @AuraEnabled
        public List<OppStageChecklistHelper.HelperWrapper> fieldsList{set;get;}
        @AuraEnabled
        public String stageVal{set;get;}
        @AuraEnabled
        public String prevStage{set;get;}
        @AuraEnabled
        public String nextStage{set;get;}
    }

     public class ValidationWrapper{
         @AuraEnabled
         public String fieldName{set;get;}
         @AuraEnabled
         public String fieldLabel{set;get;}
         @AuraEnabled
         public Boolean isFile{set;get;}
         @AuraEnabled
         public Boolean isRequired{set;get;}
         @AuraEnabled
         public String fileName{set;get;}
         @AuraEnabled
         public String fileId{set;get;}
         @AuraEnabled
         public String secondFieldLabel{set;get;}
         @AuraEnabled
         public String secondFieldName{set;get;}

         public ValidationWrapper(String fieldName, String fieldLabel, Boolean isFile, Boolean isRequired, 
                String fileName, String fileId, String secondFieldLabel, String secondFieldName){
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.isFile = isFile;
            this.isRequired = isRequired;
            this.fileName = fileName;
            this.fileId = fileId;
            this.secondFieldLabel = secondFieldLabel;
            this.secondFieldName = secondFieldName;
         }
     }
    //wrapper class to bind data elements
    public class DataWrapper{
        @AuraEnabled
        public List<FieldWrapper> requiredFields{set;get;}
        @AuraEnabled
        public List<FieldWrapper> optionalFields{set;get;}
        @AuraEnabled
        public Boolean allowPermissionOverride{set;get;}
        @AuraEnabled
        public Boolean isRequiredFulfilled{set;get;}
        @AuraEnabled
        public String nextStageValue{set;get;}
        @AuraEnabled
        public string prevStageValue{set;get;}
        @AuraEnabled
        public string recordTypeId{set;get;}
        @AuraEnabled
        public string stageDescription{set;get;}
        @AuraEnabled
        public string actorsInvolved{set;get;}
        @AuraEnabled
        public string forecastCategory{set;get;}
        @AuraEnabled
        public string createdByName{set;get;}
        @AuraEnabled
        public string ownerName{set;get;}
        @AuraEnabled
        public Integer daysinCurrentStage{set;get;}
        @AuraEnabled
        public date lastChangedDate{set;get;}
        @AuraEnabled
        public List<ReferenceWrapper> importantLinks{set;get;}
        @AuraEnabled
        public string headerInfo{set;get;}
        @AuraEnabled
        public User loginUserDetails{set;get;}
        @AuraEnabled
        public List<OpportunityTeamMember> oppTeamMembers{set;get;}
        @AuraEnabled
        public Profile loggedInProfile{set;get;}
        @AuraEnabled
        public Boolean allowStageUpdates{set;get;}
        @AuraEnabled
        public Boolean allowClosure{set;get;}
    }
    
    public class ReferenceWrapper{
        @AuraEnabled
        public String recValue{set;get;}
        @AuraEnabled
        public String recId{set;get;}
        @AuraEnabled
        public String objectName{set;get;}
        
        public ReferenceWrapper(String recValue, String recId, String objectName){
            this.recValue = recValue;
            this.recId = recId;
            this.objectName = objectName;
        }
    }
    
    public class FileDataWP {
        @AuraEnabled
        public String PathOnClient{set;get;}
        @AuraEnabled
        public String Title{set;get;}
        @AuraEnabled
        public String fileId{set;get;}
        @AuraEnabled
        public String filePreviewURL{set;get;}
        @AuraEnabled
        public String fieldName{set;get;}

    }
    
    //wrapper class to bind each field property
    public class FieldWrapper{
        @AuraEnabled
        public string fieldLabel{set;get;}
        @AuraEnabled
        public string fieldValue{set;get;}
        @AuraEnabled
        public Boolean booleanValue{set;get;}
        @AuraEnabled
        public Integer randomId{set;get;}
        @AuraEnabled
        public String fieldName{set;get;}
        @AuraEnabled
        public String fieldType{set;get;}
        @AuraEnabled
        public Boolean allowInput{set;get;}
        @AuraEnabled
        public List<ReferenceWrapper> attrs{set;get;}
        @AuraEnabled
        public Boolean displayFieldValue{set;get;}
        @AuraEnabled
        public FileDataWP fileInfo{set;get;}
        @AuraEnabled
        public String actionName{set;get;}
        @AuraEnabled
        public String actionObjectName{set;get;}
        @AuraEnabled
        public String errMsg{set;get;}
        @AuraEnabled
        public String allowedValues{set;get;}
        @AuraEnabled
        public String dependentFieldNames{set;get;}
        @AuraEnabled
        public Boolean isNumber{set;get;}
        @AuraEnabled
        public String hoverText{set;get;}
        @AuraEnabled
        public String picklistLabel{set;get;}
        
        
        public FieldWrapper(String fieldLabel, String fieldValue, Boolean booleanValue, String fieldName, 
                            String fieldType,Boolean allowInput, List<ReferenceWrapper> attrs, Boolean displayFieldValue, FileDataWP fileInfo,
                            String actionName, String actionObjectName, String allowedValues, String errMsg, String dependentFieldNames, String hoverText, String picklistLabel)
        {
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.booleanValue = booleanValue;
            this.randomId = Integer.valueof((Math.random() * 1000));
            this.fieldName = fieldName;
            this.fieldType = fieldType;
            this.allowInput = allowInput;
            this.attrs = attrs;
            this.displayFieldValue = displayFieldValue;
            this.fileInfo = fileInfo;
            this.actionName = actionName;
            this.actionObjectName = actionObjectName;
            this.allowedValues = allowedValues;
            this.errMsg = errMsg;
            this.dependentFieldNames = dependentFieldNames;
            this.isNumber = fieldType!= null && fieldType== 'DECIMAL' ? true : false;
            this.hoverText = hoverText;
            this.picklistLabel = picklistLabel;
        }
    }
    
}