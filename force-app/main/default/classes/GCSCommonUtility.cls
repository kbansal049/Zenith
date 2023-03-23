/**
 * @description       : This class contains commonly used methods for GCS POD functionalities
 * @author            : Ram Sangati
 * @last modified on  : 01-15-2023
 * @last modified by  : Ram Sangati
**/
public with sharing class GCSCommonUtility {
    /**
     * This method will return the Record Type Id of given given Case Record Developer Name
     * @param  recordTypeName recordTypeName
     * @return                recordTypeId
     */
    public static String getCaseRecordTypeId(String recordTypeName) {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    /**
     * This method will return the Record Type Id of given given Survey__c Record Developer Name
     * @param  recordTypeName recordTypeName
     * @return                recordTypeId
     */
    public static String getSurveyRecordTypeId(String recordTypeName) {
        return Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    /**
     * This method will return the List<FieldSetMember> for given fieldSetName
     * @param  fieldSetName fieldSetName
     * @return              List<FieldSetMember>
     */
    public static List<FieldSetMember> getCaseFieldSet(String fieldSetName) {
       return Schema.SObjectType.Case.fieldSets.getMap().get(fieldSetName).getFields();
    }

    /**
     * This method will return the List<EmailTemplate> for given templateDevNames
     * @param  templateDevNames templateDevNames
     * @return                  List<EmailTemplate>
     */
    public static List<EmailTemplate> getEmailTemplate(List<String> templateDevNames) {
        return [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName IN :templateDevNames];
    }

    /**
     * This method will prepare EmailMessage with given inputs
     * @param  templateId                templateId
     * @param  targetObjId               targetObjId
     * @param  treatTargetObjAsRecipient treatTargetObjAsRecipient
     * @param  setOrgWideEmailAddress    setOrgWideEmailAddress
     * @return                           Messaging.SingleEmailMessage
     */
    public static Messaging.SingleEmailMessage prepareEmailMessage(String templateId, String targetObjId, Boolean treatTargetObjAsRecipient,String orgWideEmailAddress) {
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        if(String.isNotBlank(templateId)) {
            mail.setTemplateId(templateId);
        }
        if(String.isNotBlank(targetObjId)) {
            mail.setTargetObjectId(targetObjId);
        }
        mail.setTreatTargetObjectAsRecipient(treatTargetObjAsRecipient);
        if(String.isNotBlank(orgWideEmailAddress)){
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);  
        }

        return mail;
    }

    /**
     * This method will prepare FeedItem with given inputs
     * @param  parentId   parentId
     * @param  body       body
     * @param  visibility visibility
     * @param  isRichText isRichText
     * @return            FeedItem
     */
    public static FeedItem prepareFeedItem(String parentId, String body, String visibility, Boolean isRichText, Boolean isSiemensFeed) {
        FeedItem fItem = new FeedItem();
        fItem.parentId = parentId;
        fItem.Body = isSiemensFeed ? getSiemensFeedBody(body) : body;
        fItem.Visibility = visibility;
        fItem.IsRichText = IsRichText;
        return fItem;
    }

    private static String getSiemensFeedBody(String bodyTxt){
        return String.isNotBlank(bodyTxt) ? 'Siemens:\n' + bodyTxt.left(9000) : GCSCommonConstants.EMPTY_STRING;
    }

    /**
     * This method is used to identify the current running SF instance type (i.e., Sandbox / Production)
     * @return   Boolean
     */
    public static Boolean isSandbox(){
        return [SELECT IsSandbox, InstanceName FROM Organization].isSandbox;
    }

    /**
     * This method is used to construct a string which can be used in dynamic SOQL
     * @param  listOfStrs List of Id's
     * @param  setOfStrs  Set of Id's
     * @return            Formatted String with given Id's
     */
    public static String getFormattedString(List<String> listOfStrs, Set<String> setOfStrs) {
        System.debug('000(A) ===>> In getFormattedString(), listOfStrs val is: '+listOfStrs);
        System.debug('000(B) ===>> In getFormattedString(), setOfStrs val is: '+setOfStrs);
        String formattedStr = '';
        if(!listOfStrs.isEmpty()) {
            formattedStr = '(';
            for(String str : listOfStrs) {
                formattedStr += '\'' + str + '\', ';
            }
            //Remove the last , 
            formattedStr = formattedStr.removeEnd(', ');
            formattedStr += ')';
        } else if(!setOfStrs.isEmpty()) {
            formattedStr = '(';
            for(String str : setOfStrs) {
                formattedStr += '\'' + str + '\', ';
            }
            //Remove the last , 
            formattedStr = formattedStr.removeEnd(', ');
            formattedStr += ')';
        }
        System.debug('000(C) ===>> formattedStr val is: '+formattedStr);
        return formattedStr;
    }

    /**
     * This method is used to construct a string which can be used in dynamic SOQL
     * @param  listOfStrs List of Id's
     * @param  setOfStrs  Set of Id's
     * @return            Formatted String with given Id's
     */
    public static String getFormattedString(List<Id> listOfIds, Set<Id> setOfIds) {
        return getFormattedString(
            (listOfIds != null && !listOfIds.isEmpty()) ? (List<String>)listOfIds : new List<String>(),
            (setOfIds != null && !setOfIds.isEmpty()) ? (Set<String>)JSON.deserialize(JSON.serialize(setOfIds), Set<String>.class) : new Set<String>()
        );
    }

    /**
     * This method is used to log an error with failed Insertion / Updation records
     * @param  srList     List of Database.SaveResult
     * @param  className  className where the DB operation performed
     * @param  methodName methodName where the DB operation performed
     * @param  stackTrace Custom stack trace for better understanding of the error especially where there is not record identifier is logged
     */
    public static void logDBInsertOrUpdateError(List<Database.SaveResult> srList, String className, String methodName, String stackTrace) {
        List<Zscaler_Error_Logs__c> errorLogs = new List<Zscaler_Error_Logs__c>();
        for(Database.SaveResult sr : srList) {
            if(!sr.isSuccess()) {
                for(Database.Error e : sr.getErrors()) {
                    String customStackTrace = String.isNotBlank(stackTrace) 
                                                ? stackTrace 
                                                : e.getMessage() + ': ' + String.join(e.getFields(), GCSCommonConstants.COMMA_STRING);
                    errorLogs.add(prepareZscalerErrorLog(className, methodName, sr.getId(), 
                        customStackTrace, String.valueOf(e), GCSCommonConstants.DML_EXCEPTION_ERROR_TYPE));
                }
            }
        }
        if(!errorLogs.isEmpty()) {
            Database.insert(errorLogs, false);
        }
    }

    /**
     * This method is used to log an error with failed Upsert records
     * @param  srList     List of Database.UpsertResult
     * @param  className  className where the DB operation performed
     * @param  methodName methodName where the DB operation performed
     * @param  stackTrace Custom stack trace for better understanding of the error especially where there is not record identifier is logged
     */
    public static void logDBUpsertError(List<Database.UpsertResult> urList, String className, String methodName, String stackTrace) {
        List<Zscaler_Error_Logs__c> errorLogs = new List<Zscaler_Error_Logs__c>();
        for(Database.UpsertResult ur : urList) {
            if(!ur.isSuccess()) {
                for(Database.Error e : ur.getErrors()) {
                    String customStackTrace = String.isNotBlank(stackTrace) 
                                                ? stackTrace 
                                                : e.getMessage() + ': ' + String.join(e.getFields(), GCSCommonConstants.COMMA_STRING);
                    errorLogs.add(prepareZscalerErrorLog(className, methodName, ur.getId(), 
                        customStackTrace, String.valueOf(e), GCSCommonConstants.DML_EXCEPTION_ERROR_TYPE));
                }
            }
        }
        if(!errorLogs.isEmpty()) {
            Database.insert(errorLogs, false);
        }
    }

    /**
     * This method is used to log an error with failed Delete records
     * @param  srList     List of Database.DeleteResult
     * @param  className  className where the DB operation performed
     * @param  methodName methodName where the DB operation performed
     * @param  stackTrace Custom stack trace for better understanding of the error especially where there is not record identifier is logged
     */
    public static void logDBDeleteError(List<Database.DeleteResult> drList, String className, String methodName, String stackTrace) {
        List<Zscaler_Error_Logs__c> errorLogs = new List<Zscaler_Error_Logs__c>();
        for(Database.DeleteResult dr : drList) {
            if(!dr.isSuccess()) {
                for(Database.Error e : dr.getErrors()) {
                    String customStackTrace = String.isNotBlank(stackTrace) 
                                                ? stackTrace 
                                                : e.getMessage() + ': ' + String.join(e.getFields(), GCSCommonConstants.COMMA_STRING);
                    errorLogs.add(prepareZscalerErrorLog(className, methodName, dr.getId(), 
                        customStackTrace, String.valueOf(e), GCSCommonConstants.DML_EXCEPTION_ERROR_TYPE));
                }
            }
        }
        if(!errorLogs.isEmpty()) {
            Database.insert(errorLogs, false);
        }
    }

    /**
     * This method is used to log an error with failed Send Email records
     * @param  srList     List of Database.SendEmailResult
     * @param  className  className where the DB operation performed
     * @param  methodName methodName where the DB operation performed
     * @param  stackTrace Custom stack trace for better understanding of the error especially where there is not record identifier is logged
     */
    public static void logSendEmailError(List<Messaging.SendEmailResult> serList, String className, String methodName, String stackTrace) {
        List<Zscaler_Error_Logs__c> errorLogs = new List<Zscaler_Error_Logs__c>();
        for(Messaging.SendEmailResult ser : serList) {
            if(!ser.isSuccess()) {
                for(Messaging.SendEmailError e : ser.getErrors()) {
                    String customStackTrace = String.isNotBlank(stackTrace) 
                                                ? stackTrace 
                                                : e.getMessage() + ': ' + String.join(e.getFields(), GCSCommonConstants.COMMA_STRING);
                    errorLogs.add(prepareZscalerErrorLog(className, methodName, e.getTargetObjectId(), 
                        customStackTrace, String.valueOf(e), GCSCommonConstants.DML_EXCEPTION_ERROR_TYPE));
                }
            }
        }
        if(!errorLogs.isEmpty()) {
            Database.insert(errorLogs, false);
        }
    }

    /**
     * This generic method is used to log any exception/error
     * @param  className        className where the given operation performed
     * @param  methodName       methodName where the given operation performed
     * @param  recordId         recordId for which the error occurred
     * @param  stackTraceString stackTraceString
     * @param  exceptionInfo    String format of entire Exception object
     * @param  errorType        errorType
     */
    @future
    public static void insertZscalerErrorLog(String className, String methodName, String recordId, String stackTraceString, String exceptionInfo, String errorType){
        Database.insert(prepareZscalerErrorLog(className, methodName, recordId, stackTraceString, exceptionInfo, errorType), false);
    }

    /**
     * This method will prepare the Zscaler_Error_Logs__c record with given inputs
     * @param  className        className where the given operation performed
     * @param  methodName       methodName where the given operation performed
     * @param  recordId         recordId for which the error occurred
     * @param  stackTraceString stackTraceString
     * @param  exceptionInfo    String format of entire Exception object
     * @param  errorType        errorType
     * @return                  Zscaler_Error_Logs__c record
     */
    public static Zscaler_Error_Logs__c prepareZscalerErrorLog(String className, 
		String methodName, String recordId, String stackTraceString, String info, String errorType){
        return new Zscaler_Error_Logs__c(
            Biz_Area__c	= GCSCommonConstants.BIZ_AREA_AS_SERVICE_CLOUD,    
            Error_in__c = GCSCommonConstants.ERROR_IN_AS_APEX, 
            Class_Name__c = className,
            Method_Name__c = methodName,
            Record_Info__c = recordId, 
            User__c	= UserInfo.getUserId(),
            Stack_Trace_String__c = stackTraceString,
            Exception_info__c = info,
            Error_Type__c = errorType
        );
    }

    /**
     * This method is used to get the contact id which will be used to send an email
     * @return   random contact id
     */
    public static String getContactId(){
        return [SELECT Id FROM Contact LIMIT :GCSCommonConstants.INTEGER_1].Id;
    }

    /**
     * This method is used to check weekend
     * @return   boolean true if its a weekend
     */
    public static Boolean checkIfWeekend(){
        Boolean isWeekend = false;
        Case_Quota_Management__c orgDefaults = Case_Quota_Management__c.getOrgDefaults();
        if(orgDefaults != null){
        	isWeekend = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
        }
        return isWeekend;
    }

    /**
     * This method is used to prepare the SOQL with given inputs
     * @param  objectName    objectName
     * @param  fields        fields
     * @param  whereClause   whereClause
     * @param  orderByClause orderByClause
     * @param  limitClause   limitClause
     * @return               SOQL string
     */
    public static String getSOQL(String objectName, String fields, String whereClause, String orderByClause, Integer limitClause){
        String soql = '';
        if(String.isNotBlank(objectName) && String.isNotBlank(fields)){
            soql = 'SELECT ' + fields + ' FROM ' + objectName;
            if(String.isNotBlank(whereClause)){
                soql += ' WHERE ' + whereClause;
            }

            if(String.isNotBlank(orderByClause)){
                soql += ' ORDER BY ' + orderByClause;
            }

            if(limitClause > GCSCommonConstants.INTEGER_0 && limitClause <= 50000){
                soql += ' LIMIT ' + limitClause;
            }else{
                soql += ' LIMIT 50000';
            }
        }
        return soql;
    }

    /**
     * This method is used to retrieve list of CaseMilestone records with given fields and filter criteria
     * @param  fields        fields
     * @param  whereClause   whereClause
     * @return               List of CaseMilestone / null
     */
    public static List<CaseMilestone> getCaseMilestones(List<String> mlsCaseIdsList, List<String> mlsNamesList){
        System.debug('444(A) ===>> Entered into getCaseMilestones() ...!!');
        List<CaseMilestone> caseMilestoneList = new List<CaseMilestone>();
        String mlsQueryFields = 'Id, MilestoneType.Name, CaseId, StartDate, TargetDate, CompletionDate';
        String whereClause = 'CompletionDate = null';
        if(!mlsCaseIdsList.isEmpty() && !mlsNamesList.isEmpty()){
            whereClause += ' AND CaseId IN ' + getFormattedString(mlsCaseIdsList, new Set<String>()) 
                        + ' AND MilestoneType.Name IN ' + getFormattedString(mlsNamesList, new Set<String>());
        }else if(!mlsCaseIdsList.isEmpty() && mlsNamesList.isEmpty()){
            whereClause += ' AND CaseId IN ' + getFormattedString(mlsCaseIdsList, new Set<String>());
        }else if(mlsCaseIdsList.isEmpty() && !mlsNamesList.isEmpty()){
            whereClause += ' AND MilestoneType.Name IN ' + getFormattedString(mlsNamesList, new Set<String>());
        }

        String soql = getSOQL('CaseMilestone', mlsQueryFields, whereClause, null, null);
        System.debug('444(B) ===>> CaseMilestone soql val is: ' + soql);
        if(String.isNotBlank(soql)){
            caseMilestoneList = Database.query(soql);
        }
        System.debug('444(C) ===>> caseMilestoneList val is: ' + caseMilestoneList);
        return caseMilestoneList;
    }

    /**
     * This method is used to retrieve Case Queue Id with given Queue developer name
     * @param  qDevName Queue Developer Name
     * @return          Queue Id
     */
    public static String getCaseQueueId(String qDevName){
        System.debug('555(A) ===>> Entered into getCaseQueueId() ...!!');
        String caseQueueId = GCSCommonConstants.EMPTY_STRING;
        if(String.isNotBlank(qDevName)){
            String qSobjQueryFields = 'Id, QueueId, Queue.DeveloperName, SobjectType';
            String whereClause = 'sObjectType = \'' + GCSCommonConstants.CASE_STRING 
                                + '\' AND Queue.DeveloperName = \'' + qDevName
                                + '\'';

            String soql = getSOQL('QueueSobject', qSobjQueryFields, whereClause, null, null);
            System.debug('555(B) ===>> QueueSobject soql val is: ' + soql);
            if(String.isNotBlank(soql)){
                List<QueueSobject> queueSobjectList = Database.query(soql);
                System.debug('555(C) ===>> queueSobjectList val is: ' + queueSobjectList);
                caseQueueId = !queueSobjectList.isEmpty() 
                                    ? queueSobjectList.get(GCSCommonConstants.INTEGER_0).QueueId 
                                    : GCSCommonConstants.EMPTY_STRING;
            }
        }
        System.debug('555(D) ===>> caseQueueId val is: ' + caseQueueId);
        return caseQueueId;
    }

    /**
     * This method is used to filter Defcon Cases from given list of Cases
     * @param  caseList Case List
     * @return          List of Defcon Cases
     */
    public static List<Case> getDefconCases(List<Case> caseList){
        List<Case> defconCaseList = new List<Case>();
        for(Case cs : caseList){
            if(cs.Case_Record_Type_Name__c == GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME){
                defconCaseList.add(cs);
            }
        }
        return defconCaseList;
    }
    
    /**
     * This method is used to filter SObject records with given filter criteria
     * @param  objectName    objectName
     * @param  fields        fields
     * @param  whereClause   whereClause
     * @param  orderByClause orderByClause
     * @param  limitClause   limitClause
     * @return               List of SObjects
     */
    public static List<SObject> getSObjectRecords(String objectName, String fields, String whereClause, String orderByClause, Integer limitClause){
        System.debug('666 ===>> Entered into getSObjectRecords() ...!!');
        List<SObject> lstSObjRecords = new List<SObject>();
        if(String.isNotBlank(objectName) && String.isNotBlank(fields)){
            String soql = getSOQL(objectName, fields, whereClause, orderByClause, limitClause);
            System.debug('666(A) ===>> ' +objectName+ ' soql val is: ' + soql);
            lstSObjRecords = Database.query(soql);
        }
        System.debug('666(C) ===>> lstSObjRecords val is: ' + lstSObjRecords);
        return lstSObjRecords;
    }

    /**
     * This method will return the List<OrgWideEmailAddress> for given address
     * @param  address          address
     * @return                  List<OrgWideEmailAddress>
     */
    public static List<OrgWideEmailAddress> getOrgWideEmailAddresses(List<String> address) {
        return [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN :address];
    }
}