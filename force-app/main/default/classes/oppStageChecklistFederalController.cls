public with sharing class oppStageChecklistFederalController {

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
        Label.Profile_Core_Sales_CSM => 'CSM', Label.Profile_Core_Sales => 'RSM','Core Sales - SE' => 'SE'};
     //store and return field type for every field on opportunity object
    public static Map<String,Schema.DisplayType> fieldList; 

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
            List<Opportunity_Stage_Age__c> stageAge = [SELECT Id,Age__c FROM Opportunity_Stage_Age__c WHERE Opportunity__c =: opp.Id AND Stage__c ='2 - Architecture & Alignment' ORDER BY lastmodifieddate desc];
            Map<Id,User> users = new Map<Id,User>([SELECT Id,Name FROM User WHERE IsActive =: true AND Profile.Name = 'Core Sales - CSM' LIMIT 50000]);
            Map<String,FileDataWp> fileData = getFileDetails(opp.Id);
            String queryStr = 'SELECT Id,StageName,toLabel(Validation_Stage__c) ValidationLabel';
            //retrieve metadata properties based on opportunity record type and current stage value
            List<Opp_Stage_Mapping__mdt> metadataVals = [SELECT Exception_Permission__c,Exception_Field_Names__c,important_links__c,
            Authorized_Personnel_for_Closure__c,Field_Labels__c,Opportunity_Record_Type__c,Optional_Fields__c,Stage_Description__c,DeveloperName,
                                                         Optional_Fields_Criteria__c,Required_Field_Criteria__c,Required_Field_Names__c,Action_Steps_Owner__c,
                                                         Display_Field_Value_Mapping__c,Quick_Action_Mapping__c,Allowed_Field_Values__c,Dependent_Fields__c,Error_Message_Mappings__c,
                                                         Next_Stage_value__c, Stage_Value__c, Prev_Stage_Value__c,Fields_Permission__c, Input_Output_Field_Mappings__c,Override_Field_Acceptance__c, 
                                                         Header_Info__c,Authorized_Personnel_for_Stage_Updates__c,Green_Field_Labels__c,Hover_Text__c FROM Opp_Stage_Mapping__mdt WHERE 
                                                         DeveloperName='Federal' ];
            
            if(!metadataVals.isEmpty()){
                Opp_Stage_Mapping__mdt metadata = metadataVals[0];
                nextStageValue = metadata.Next_Stage_Value__c;
                prevStageValue = metadata.Prev_Stage_Value__c;
                stageDescription = metadata.Stage_Description__c;
                /*if(String.isNotBlank(metadata.Action_Steps_Owner__c)){
                    actorsInvolved = '';
                    for(String str: metadata.Action_Steps_Owner__c.split(';',0)){
                        actorsInvolved+='<strong>'+str.SubStringBefore('=')+'</strong>'+str.SubStringAfter('=')+'<br>';
                    }
                }*/
                //actorsInvolved = metadata.Action_Steps_Owner__c;
                headerInfo = metadata.Header_Info__c;
                
                //check if Execption is Enabled
                /*if(String.isNotBlank(metadata.Exception_Permission__c)){
                    allowPermissionOverride = FeatureManagement.checkPermission(metadata.Exception_Permission__c) ? true: false;
                }*/
                
                if(String.isNotBlank(metadata.Field_Labels__c)){
                    for(String str: metadata.Field_Labels__c.split(';',0)){
                        labelAPINameMapping.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }

                /*if(String.isNotBlank(metadata.Green_Field_Labels__c)){
                    for(String str: metadata.Green_Field_Labels__c.split(';',0)){
                        greenFieldLabels.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }*/

               /* if(String.isNotBlank(metadata.Hover_Text__c)){
                    for(String str: metadata.Hover_Text__c.split(';',0)){
                        hoverTexts.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }*/
                
                
                /*if(String.isNotBlank(metadata.Fields_Permission__c)){
                    for(String str: metadata.Fields_Permission__c.split(';',0)){
                        fieldsPermission.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }*/
                
                /*if(String.isNotBlank(metadata.Important_Links__c)){
                    for(String str: metadata.Important_Links__c.split(';',0)){
                        importantLinks.add(new ReferenceWrapper(str.SubStringBefore('='),str.SubStringAfter('='),'Object'));
                    }
                }*/
                /*if(String.isNotBlank(metadata.Quick_Action_Mapping__c)){
                    for(String str: metadata.Quick_Action_Mapping__c.split(';',0)){
                        quickActionMappings.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }*/
                /*if(String.isNotBlank(metadata.Allowed_Field_Values__c)){
                    for(String str: metadata.Allowed_Field_Values__c.split(';',0)){
                        allowedFieldValues.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }*/
                
                /*if(String.isNotBlank(metadata.Dependent_Fields__c)){
                    for(String str: metadata.Dependent_Fields__c.split(';',0)){
                        fieldDependencies.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }*/
                
                /*if(String.isNotBlank(metadata.Error_Message_Mappings__c)){
                    for(String str: metadata.Error_Message_Mappings__c.split(';',0)){
                        errorMsgMappings.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }*/
                
                
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
                /*if(String.isNotBlank(metadata.Input_Output_Field_Mappings__c)){
                    for(String str: metadata.Input_Output_Field_Mappings__c.split(';',0)){
                        
                        fieldtypes.put(str.SubStringBefore('='),str.SubStringAfter('='));
                    }
                }*/
                
                if(String.isNotBlank(metadata.Required_Field_Names__c)){
                    for(String fieldName: metadata.Required_Field_Names__c.split(',',0)){
                        queryStr += ', '+fieldName;
                    }
                }
                
                /*if(String.isNotBlank(metadata.Optional_Fields__c)){
                    for(String fieldName: metadata.Optional_Fields__c.split(',',0)){
                        queryStr += ', '+fieldName;
                    }
                }*/
                
                /*if(string.isNotBlank(metadata.Exception_Field_Names__c)){
                    for(String fieldName: metadata.Exception_Field_Names__c.split(',',0)){
                        queryStr += ', '+fieldName;
                    }
                }*/
                
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
                
                /*if(String.isNotBlank(metadata.Optional_Fields_Criteria__c)){
                    for(String fld: metadata.Optional_Fields_Criteria__c.split(';',0)){
                        FieldWrapper wrapObj = processFieldInfo(fld,labelAPINameMapping,fieldtypes,fieldAcceptance, displayValMapping, errorMsgMappings,
                                                                allowedFieldvalues, quickActionMappings, fileData, oppRec,fieldDependencies, userType, fieldsPermission,
                                                                greenFieldLabels,hoverTexts,allowPermissionOverride,users);
                        if(wrapObj != null){
                            optionalFields.add(wrapObj);
                        }   
                        
                    }
                }*/
                
                obj.allowStageUpdates = false;
               
                /*if(String.isNotBlank(metadata.Authorized_Personnel_for_Stage_Updates__c)){
                    if(String.isNotEmpty(userType) && metadata.Authorized_Personnel_for_Stage_Updates__c.contains(userType)){
                        obj.allowStageUpdates = true;
                    }
                }*/
                obj.allowClosure = true;
                /*if(String.isNotBlank(metadata.Authorized_Personnel_for_Closure__c)){
                    if(String.isNotEmpty(userType) && metadata.Authorized_Personnel_for_Closure__c.contains(userType)){
                        obj.allowClosure = true;
                    }
                }*/
                
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
        
        /*if(fld.contains(':')){
            for(string str: fld.substringBefore(':').split('&&')){
                String conditionfieldName = str.SubStringBefore('=');
                String conditionfieldValue = str.SubStringAfter('=');
                String conditionRetValue = conditionfieldName != null && conditionfieldValue != null ?determineFieldValue(conditionfieldName,conditionfieldValue,oppRec):'';
                conditionflag  &= conditionRetValue.contains('-') ?conditionRetValue.contains('true'):true;
            }
        }*/
        
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

            /*if(fieldName.equalsIgnoreCase('Validation_Stage__c')){
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
                
            }*/

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

    public static String determineFieldValue(String fieldName, String valueToCompare, Opportunity oppRec){
        
        fieldName = fieldName.toLowerCase();
        if(fieldList.containsKey(fieldName)){
           
            Switch on fieldList.get(fieldName) {
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
            }
        }
        system.debug('Account.Market_Segment__c--CPU Limit Consumption Start: '+Limits.getCPUtime());
            /*if(fieldName.equalsIgnoreCase('Account.Market_Segment__c') && !valueToCompare.contains('<>') && valueToCompare.equals(oppRec.Account.Market_Segment__c)){
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
            }*/
        
        
        /*if(fieldName.equalsIgnoreCase('SBQQ__PrimaryQuote__r.SBQQ__Primary__c') && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c== true){
return 'REFERENCE-true';
}*/
        return 'false';
    }

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