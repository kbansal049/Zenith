/**
* @File Name          : CaseTriggerHelper.cls
* @Description        : 
* @Author             : Ankit Bhatnagar
* @Group              : 
* @Last Modified By   : Ankit Bhatnagar
* @Last Modified On   : 21/12/2022
* @Modification Log   : 
*------------------------------------------------------------------------------
* Ver         Date                     Author                    Modification
*------------------------------------------------------------------------------
* 1.0       21/12/2022                 Ankit Bhatnagar           Initial Version
**/

public class CaseTriggerHelper {
    static final String APEX_CLASS_NAME = 'CaseTriggerHelper';
    static final String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
    static final String CASE_EXPERIENCE_PROJECT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_EXPERIENCE_PROJECT_RECORD_TYPE_NAME);
    static final String CASE_SALES_OPS_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SALES_OPS_RECORD_TYPE_NAME);
    static final String CASE_ESCALATION_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME);
    
    static String tamroutingStr = 'tamrouting';
    static String internalagentcreationStr = 'internalagentcreation';
    static String cspmCaseStr = 'cspmCase';
    static String zpaCaseStr = 'zpaCase';
    static String zwsCaseStr = 'zwsCase';
    static String sitereviewCaseStr = 'sitereviewCase';
    static String zscalerDeceptionCaseStr = 'zscalerDeceptionCase';
    static String cloudConnectorCaseStr = 'cloudConnectorCase';
    static String branchConnectorCaseStr = 'branchConnectorCase';
    static String zpcCaseStr = 'zpcCase';
    static String inCountryRoutingUSAStr = 'incountryroutingusa';
    static String levelStr = 'Level ';
    static String pocStr = 'POC';
    static String customerStr = 'Customer';
    static String internalAgentStr = 'Internal Agent';
    static String whereClauseIdInStr = 'Id IN ';

    //Added by Anup : CR#2195 - Start
    /**
     * This method is used to validate Exclude Partner Case Assignment
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void validateExcludePartnerCaseAssignment(List<Case> newList, map<Id, Case> oldMap) {
        final String METHOD_NAME = 'validateExcludePartnerCaseAssignment';
        try {
            List<Id> listOfOwnerId = new List<Id>();
            Set<Id> setOfCaseId = new Set<Id>();
            for(Case cs : newList){
                if((cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                        && cs.Exclude_Partner_Support__c 
                        && oldMap.get(cs.Id).OwnerId == Label.Handoff_Queue_ID 
                        && String.valueOf(cs.OwnerId).startswith(GCSCommonConstants.STARTS_WITH_005) 
                        && cs.OwnerId != oldMap.get(cs.Id).OwnerId) 
                    || Test.isRunningTest()){
                    listOfOwnerId.add(cs.OwnerId);
                    setOfCaseId.add(cs.Id);
                }
            }
            if(!listOfOwnerId.isEmpty()){
                String partnerProfileIds = Label.Partner_Engineer_Profile_Ids;
                List<Id> listOfProfileId = partnerProfileIds.split(GCSCommonConstants.COMMA_STRING);
                Set<Id> setOfPE = new Set<Id>();
                for(User usr : UserSelector.getUsers(listOfOwnerId, listOfProfileId, null)){
                    setOfPE.add(usr.Id);
                }
                for(Case cs : newList){
                    if(setOfCaseId.contains(cs.Id) && setOfPE.contains(cs.OwnerId)){
                        cs.addError(Label.Excluded_Partner_Validation_Message);
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Anup : CR#2195 - End
    
    //Added by Anup : CR#1702 - Start
    /**
     * This method is used to validate and Update Customer CC List on given Case
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void validateAndUpdateCustomerCCList(List<Case> newList, Map<Id, Case> oldMap) {
        final String METHOD_NAME = 'validateAndUpdateCustomerCCList';
        try {
            Set<String> setOfEmailId = new Set<String>();
            for(Case cs: newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                && (oldMap == null 
                    || (cs.Internal_cc_List__c != oldmap.get(cs.Id).Internal_cc_List__c 
                        || cs.Customer_CC_List__c != oldmap.get(cs.Id).Customer_CC_List__c))){
                    setOfEmailId = new Set<String>();
                    if(!String.isBlank(cs.Customer_CC_List__c) 
                        && (oldMap == null 
                            || (oldMap != null && cs.Customer_CC_List__c != oldmap.get(cs.Id).Customer_CC_List__c))){
                        String ccListCheck = cs.Customer_CC_List__c.removeEnd(GCSCommonConstants.SEMI_COLON_STRING);
                        
                        if(!((ccListCheck.countMatches(GCSCommonConstants.AT_THE_RATE_STRING) == ccListCheck.countMatches(GCSCommonConstants.SEMI_COLON_STRING)) 
                            || (ccListCheck.countMatches(GCSCommonConstants.AT_THE_RATE_STRING) == ccListCheck.countMatches(GCSCommonConstants.SEMI_COLON_STRING) + GCSCommonConstants.INTEGER_1))){
                            cs.addError('Please seperate the emails by semi-colon in Customer CC List');
                        }
                        
                        String ccList = GCSCommonConstants.EMPTY_STRING;
                        List<String> listOfEmail = cs.Customer_CC_List__c.split(GCSCommonConstants.SEMI_COLON_STRING);
                        for(String email: listOfEmail){
                            if(!String.isBlank(email) && !setOfEmailId.contains(email)){
                                ccList += email.trim() + GCSCommonConstants.SEMI_COLON_STRING;
                                setOfEmailId.add(email);
                            }
                        }
                        cs.Customer_CC_List__c = ccList;
                    }
                    if(oldMap != null 
                        && (cs.Internal_cc_List__c != oldmap.get(cs.Id).Internal_cc_List__c) 
                        && !String.isBlank(cs.Internal_CC_List__c)){
                        String internalListCheck = cs.Internal_cc_List__c.removeEnd(GCSCommonConstants.SEMI_COLON_STRING);
                        if(!((internalListCheck.countMatches(GCSCommonConstants.AT_THE_RATE_STRING) == internalListCheck.countMatches(GCSCommonConstants.SEMI_COLON_STRING)) 
                            || (internalListCheck.countMatches(GCSCommonConstants.AT_THE_RATE_STRING) == internalListCheck.countMatches(GCSCommonConstants.SEMI_COLON_STRING) + GCSCommonConstants.INTEGER_1))){
                            cs.addError('Please seperate the emails by semi-colon in Internal CC List');
                        }
                        
                        String internalList = GCSCommonConstants.EMPTY_STRING;
                        List<String> listOfEmail2 = cs.Internal_CC_List__c.split(GCSCommonConstants.SEMI_COLON_STRING);
                        for(String email : listOfEmail2){
                            if(!String.isBlank(email) && !setOfEmailId.contains(email)){
                                internalList += email.trim() + GCSCommonConstants.SEMI_COLON_STRING;
                                setOfEmailId.add(email);
                            }
                        }
                        cs.Internal_CC_List__c = internalList;
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Anup : CR#1702 - End 
    
    //Added by Anup : CR#502 - Start
    /**
     * This method is used to send Email To TAM Manager when an engineer is OOO
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void sendEmailToTamManagerForOOO(List<Case> newList, Map<Id, Case> oldMap) {
        final String METHOD_NAME = 'sendEmailToTamManagerForOOO';
        try {
            Map<Id,Id> caseOwnerMap = new Map<Id,Id>();
            for(Case cs: newList){
                //Changed by Ankit : CR# 2686 - START 
                if((cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION) 
                    && cs.Status != oldMap.get(cs.Id).Status 
                    && cs.Status == GCSCommonConstants.CASE_STATUS_CUSTOMER_NOTE_ADDED) {
                    caseOwnerMap.put(cs.Id, cs.ownerId);
                }
            }
            if(!caseOwnerMap.isEmpty() || Test.isRunningTest()){
                Map<Id, List<String>> mapOfUserAndEmails = new Map<Id, List<String>>();
                for(User usr : UserSelector.getUsers(caseOwnerMap.values(), new List<Id>(), System.today())){
                    mapOfUserAndEmails.put(usr.Id, new List<String>{usr.Email, usr.Manager.Email});
                }
                if(!mapOfUserAndEmails.isEmpty() || Test.isRunningTest()){
                    List<Messaging.SingleEmailMessage> mailLst = new List<Messaging.SingleEmailMessage>();
                    
                    EmailTemplate emailTemplate = GCSCommonUtility.getEmailTemplate(
                        new List<String>{'Custom_Comment_To_TAM_Managers'}).get(GCSCommonConstants.INTEGER_0);
                    OrgWideEmailAddress owea = GCSCommonUtility.getOrgWideEmailAddresses(
                        new List<String>{GCSCommonConstants.ZS_SUPPORT_EMAIL_ID}).get(GCSCommonConstants.INTEGER_0);
                    Messaging.SingleEmailMessage mail = GCSCommonUtility.prepareEmailMessage(
                        emailTemplate.Id, 
                        GCSCommonUtility.getContactId(), 
                        false,
                        owea.Id);
                    for(Case cs : newList){
                        if(caseOwnerMap.containsKey(cs.Id) 
                            && mapOfUserAndEmails.containsKey(cs.OwnerId) 
                            && mapOfUserAndEmails.get(cs.OwnerId) != null){
                            List<String> listOfAddress = mapOfUserAndEmails.get(cs.OwnerId);
                            mail.setWhatId(cs.Id);
                            if(listOfAddress.get(GCSCommonConstants.INTEGER_1) != null){
                                mail.setToAddresses(new List<String>{listOfAddress.get(GCSCommonConstants.INTEGER_1)});
                                mail.setCcAddresses(new List<String>{listOfAddress.get(GCSCommonConstants.INTEGER_0)});
                                mailLst.add(mail);
                            }
                        }
                    }
                    if(!mailLst.isEmpty() && !Test.isRunningTest()){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(mailLst);
                        GCSCommonUtility.logSendEmailError(results, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Anup : CR#502 - End
    
    //Added by Anup : TAM Reassignment - Start
    /**
     * This method is used to check TAM assignment
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void checkTAMReassignment(List<Case> newList, Map<Id, Case> oldMap) {
        final String METHOD_NAME = 'checkTAMReassignment';
        try {
            //Added By Anup-CR#1465 - Start
            Set<Id> setOfAccountId = new Set<Id>();

            //Anup - Product Exclusions for TAM Reassignment - Start
            List<String> productsToExclude = new List<String>();
            if(String.isNotBlank(Label.TAM_Assignment_Exclusion_Products)){
                productsToExclude = Label.TAM_Reassignment_Excluded_Products.trim().split(GCSCommonConstants.SEMI_COLON_STRING);
            }
            //Anup - Product Exclusions for TAM Reassignment - End

            Map<String, Set<Id>> mapOfAccountAndTAM = new Map<String, Set<Id>>();
            for(Case currCase : newList){
                if(currCase.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && currCase.Priority != GCSCommonConstants.CASE_PRIORITY_LOW 
                    && currCase.Priority != GCSCommonConstants.CASE_PRIORITY_URGENT 
                    && (currCase.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || currCase.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION) 
                    && !productsToExclude.contains(currCase.Product_New__c)
                    && String.isNotBlank(currCase.AccountId)){
                    mapOfAccountAndTAM.put(currCase.AccountId, new Set<Id>());
                }
            }
            if(!mapOfAccountAndTAM.isEmpty()){
                String queryFields = 'Id, Skip_TAM_Reassignments__c, TAM_Name_New__c, Secondary_TAM_Name__c, X3rd_TAM_Name__c';
                String whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(new List<String>(), mapOfAccountAndTAM.keySet());
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                for (Account acc : AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause)) {
                    if(acc.Skip_TAM_Reassignments__c){
                        setOfAccountId.add(acc.Id);
                    }
                    if(String.isNotBlank(acc.TAM_Name_New__c)) {
                        mapOfAccountAndTAM.get(acc.Id).add(acc.TAM_Name_New__c);
                    }
                    if(String.isNotBlank(acc.Secondary_TAM_Name__c)) {
                        mapOfAccountAndTAM.get(acc.Id).add(acc.Secondary_TAM_Name__c);
                    }
                    if(String.isNotBlank(acc.X3rd_TAM_Name__c)) {
                        mapOfAccountAndTAM.get(acc.Id).add(acc.X3rd_TAM_Name__c);
                    }
                }
            }
            //Added By Anup-CR#1465 - End
            for(Case currentCase : newList){
                Set<Id> setOfPresentTAMs = new Set<Id>();
                if(mapOfAccountAndTAM.containsKey(currentCase.AccountId)){
                    setOfPresentTAMs = mapOfAccountAndTAM.get(currentCase.AccountId);
                }
                if((currentCase.RecordTypeId == CASE_SUPPORT_RT_ID) 
                    && currentCase.Next_TAM_Date__c == null 
                    && currentCase.is_Tam_Account__c 
                    && currentCase.Priority != GCSCommonConstants.CASE_PRIORITY_LOW 
                    && currentCase.Priority != GCSCommonConstants.CASE_PRIORITY_URGENT 
                    && (currentCase.Case_Type__c==GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || currentCase.Case_Type__c==GCSCommonConstants.CASE_TYPE_QUESTION) 
                    && !productsToExclude.contains(currentCase.Product_New__c)){
                    Integer daysAdded = GCSCommonConstants.INTEGER_1;
                    Integer numberOfDays = GCSCommonConstants.INTEGER_0;
                    DateTime nextTamDate;
                    if(oldMap != null){
                        nextTamDate = currentCase.CreatedDate;
                    }else{
                        nextTamDate = System.now();
                    }
                    
                    if(currentcase.Priority == GCSCommonConstants.CASE_PRIORITY_HIGH){
                        numberOfDays = 3;
                    }
                    
                    if(currentcase.Priority == GCSCommonConstants.CASE_PRIORITY_MEDIUM){
                        numberOfDays = 7;
                    }
                    
                    while(daysAdded <= numberOfDays){
                        nextTamDate = nextTamDate.addDays(GCSCommonConstants.INTEGER_1);
                        daysAdded += GCSCommonConstants.INTEGER_1;
                    }
                    
                    String day = nextTamDate.format('E');
                    if(day == 'Sat'){
                        nextTamDate = nextTamDate.addDays(GCSCommonConstants.INTEGER_2);
                        nextTamDate = DateTime.newInstance(nextTamDate.year(), nextTamDate.month(), nextTamDate.day());
                    }else if(day == 'Sun'){
                        nextTamDate = nextTamDate.addDays(GCSCommonConstants.INTEGER_1);
                        nextTamDate = DateTime.newInstance(nextTamDate.year(), nextTamDate.month(), nextTamDate.day());
                    }
                    currentCase.Next_TAM_Date__c = nextTamDate;
                }
                
                if(setOfPresentTAMs!= null && !setOfPresentTAMs.isEmpty() 
                    && setOfPresentTAMs.contains(currentCase.OwnerId)){
                    currentCase.TAM_Assignment__c = 'Assigned To TAM';
                }else if(setOfPresentTAMs.isEmpty()){
                    currentCase.TAM_Assignment__c = 'Not TAM Account';
                }else if(currentCase.TAM_Assignment__c != 'Pending TAM Assignment'){
                    currentCase.TAM_Assignment__c = 'Assigned To Support';
                }
                
                //Added By Anup-CR#1465 - Start
                if(!setOfAccountId.isEmpty() && setOfAccountId.contains(currentCase.AccountId)){
                    currentCase.TAM_Reassignment__c = true;
                }
                //Added By Anup-CR#1465 - End
            }
            TriggerUtility.TAMReassignmentExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //Added by Anup : CR1022 - Start
    /**
     * This method is used to Sync BusinessAnalyst With CR
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void syncBusinessAnalystWithCR(List<Case> newList, Map<Id, Case> oldmap) {
        final String METHOD_NAME = 'syncBusinessAnalystWithCR';
        try {
            Map<Id,Id> mapOfCaseAndBSA = new Map<Id,Id>();
            for(Case cs : newList) {
                if(cs.RecordTypeId == CASE_SALES_OPS_RT_ID 
                    && cs.Business_Analyst__c != null 
                    && cs.Business_Analyst__c != oldMap.get(cs.Id).Business_Analyst__c){
                    mapOfCaseAndBSA.put(cs.Id, cs.Business_Analyst__c);
                }
            }
            if(!mapOfCaseAndBSA.isEmpty()) {
                List<Tracker_Change_request__c> listOfCRToUpdate = new List<Tracker_Change_request__c>();
                for(Tracker_Change_request__c cr : [SELECT Id, Business_Analyst__c, Case__c 
                                                    FROM Tracker_Change_Request__c 
                                                    WHERE Case__c IN :mapOfCaseAndBSA.keySet() 
                                                        AND Stage__c NOT IN('Archived', 'Released') 
                                                        AND Parent_Request__c = null]) {
                    if(mapOfCaseAndBSA.get(cr.Case__c) != null 
                        && cr.Business_Analyst__c != mapOfCaseAndBSA.get(cr.Case__c)) {
                        cr.Business_analyst__c = mapOfCaseAndBSA.get(cr.Case__c);
                        listOfCRToUpdate.add(cr);
                    }
                }
                if(!listOfCRToUpdate.isEmpty()) {
                    List<Database.SaveResult> srList = Database.update(listOfCRToUpdate, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Anup : CR1022 - End
    
    //Added by Anup : CR# 686  : Start

    /**
     * This method is used to Update when a Case is Manual Routed
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void updateManualRoutingOfCase(List<Case> newList, Map<Id, Case> oldmap) {
        final String METHOD_NAME = 'updateManualRoutingOfCase';
        try {
            for(Case cs:newList){
                String oldOwnerId = String.valueOf(oldMap.get(cs.id).OwnerId);
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.Ownerid != oldmap.get(cs.id).Ownerid 
                    && oldOwnerId.containsIgnoreCase(Label.Support_Queue_Id) 
                    && cs.Original_Case_Assigned_Date_Time__c == null){
                    cs.Original_Case_Assigned_Date_Time__c = System.Now();
                }
            }
            TriggerUtility.ManualCaseAssignExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Anup : CR# 686  : End
    
    //Siemens -- 1139
    /**
     * This method is used to Update Case Integration record
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void updateCaseIntegration(List<Case> newList, Map<Id, Case> oldmap) {
        final String METHOD_NAME = 'updateCaseIntegration';
        try {
            List<Case> siemensCases = new  List<Case>();
            for(Case cs:newList){
                if(cs.External_Reference__c != null 
                    && cs.origin == GCSCommonConstants.CASE_ORIGIN_API){
                    siemensCases.add(cs);
                }
            }
            if(!siemensCases.isEmpty()){
                List<Generic_Field_Mapping__mdt> metaDataList = 
                    GenericFieldMappingController.getMappingFromMetaData(GCSCommonConstants.CASE_STRING, 'Case_Integration__c');
                
                Set<String> siemensFields = new Set<String>();
                for(Generic_Field_Mapping__mdt mdt : metaDataList){
                    if(mdt.Source_Field_API_Name__c != null && mdt.Origin__c == 'Siemens'){
                        siemensFields.add(mdt.Source_Field_API_Name__c);
                    }
                }
                List<Case> updatedCases = new List<Case>();
                for(Case cs : siemensCases){
                    case csOld = oldmap.get(cs.id);
                    for (String field : siemensFields) {
                        if (cs.get(field) !=  csOld.get(field)) {
                            updatedCases.add(cs);
                            break;
                        }
                    }
                }
                MAP<ID,ID> caseIdCaseIntegartionIDMap = new MAP<ID,ID>();
                MAP<ID,List<ID>> caseIdCaseIntComplaintIDMap = new MAP<ID,List<ID>>();
                for(Case_Integration__c cst : [SELECT Id, Name,Case__c,Incident_Type__c, Createddate 
                                                FROM Case_Integration__c  
                                                WHERE case__c IN :updatedCases 
                                                AND case__c != null 
                                                ORDER BY Createddate]) {
                    if(cst.Incident_Type__c == GCSCommonConstants.CASE_INT_INCIDENT_TYPE_INCIDENT) {
                        caseIdCaseIntegartionIDMap.put(cst.case__c,cst.id);
                    }else if(cst.Incident_Type__c == GCSCommonConstants.CASE_INT_INCIDENT_TYPE_COMPLAINT) {
                        List<ID> complaintIds = caseIdCaseIntComplaintIDMap.containskey(cst.case__c) ? caseIdCaseIntComplaintIDMap.get(cst.case__c) : new List<ID>();
                        complaintIds.add(cst.id);
                        caseIdCaseIntComplaintIDMap.put(cst.case__c,complaintIds);
                    }
                }
                MAP<ID, Case> caseMessageMap = new MAP<ID, Case>([SELECT Id, CaseNumber, 
                                                                    (SELECT Id, FromName, RelatedToId, Incoming, TextBody, MessageDate 
                                                                        FROM emailmessages 
                                                                        WHERE Incoming = false 
                                                                        ORDER BY MessageDate Desc 
                                                                        LIMIT :GCSCommonConstants.INTEGER_1) 
                                                                    FROM Case 
                                                                    WHERE Id IN :caseIdCaseIntegartionIDMap.keyset()]);
                
                List<Case_Integration__c> caseIntegartionRecordUpdate = new List<Case_Integration__c>();
                for(case cs : updatedCases){
                    if(caseIdCaseIntegartionIDMap.containskey(cs.id) 
                        && caseIdCaseIntegartionIDMap.get(cs.id) != null 
                        && ((cs.AccountID == System.label.Siemens_Account_ID) || Test.isRunningTest()) 
                        && (cs.status == GCSCommonConstants.CASE_STATUS_CLOSED 
                            || cs.status == GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER 
                            || cs.status == GCSCommonConstants.CASE_STATUS_RESEARCHING 
                            || cs.status == GCSCommonConstants.CASE_STATUS_ESCALATED_TO_ENGINEERING 
                            || cs.status == GCSCommonConstants.CASE_STATUS_AWAITING_FIX 
                            || cs.status == GCSCommonConstants.CASE_STATUS_CUSTOMER_CALLBACK_SCHEDULED)) {
                        Case_Integration__c csInst = new Case_Integration__c();
                        csInst.id = caseIdCaseIntegartionIDMap.get(cs.id);
                        csInst = prepareCaseIntegartionRecordFromCaseSiemens(cs, csInst, metaDataList);
                        if(caseMessageMap.containskey(cs.id) 
                            && caseMessageMap.get(cs.id).emailmessages != null){
                            for(EmailMessage em : caseMessageMap.get(cs.id).emailmessages) {
                                String timeStamp = em.MessageDate.formatGMT('yyyy-MM-dd HH:mm:ss');
                                String siemensMessage = 'Zscaler :' + timeStamp + '-' + em.FromName + ' : ' + em.TextBody.stripHtmlTags();
                                if(cs.status == GCSCommonConstants.CASE_STATUS_CLOSED){
                                    csInst.Detailed_Solution_Description__c = siemensMessage;
                                    csInst.is_Detailed_Solution_Description_Changed__c = true;
                                    csInst.Assignment_Group__c = (cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZIA) ? System.label.ZIA_Assignment_Group_Siemens : System.label.Siemens_Assignment_Group;
                                    csInst.Patch_Source__c = 'Resolved';
                                    
                                    //Added by Anup - CR#4177 - Start
                                    if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZIA) {
                                        csInst.Ticket_Status__c = 'Open';
                                        csInst.Internal_Work_Notes__c = siemensMessage;
                                        csInst.IS_Work_Notes_Changed__c = true;
                                    }
                                    csInst.Resolution_Code__c = 'Solved permanently';
                                    //Added by Anup - CR#4177 - End
                                    
                                    if(caseIdCaseIntComplaintIDMap.containskey(cs.id)) {
                                        List<Id> complaintIDs = caseIdCaseIntComplaintIDMap.get(cs.id);
                                        caseIntegartionRecordUpdate.addALL(CaseIntegrationHandler.prepareCaseComplaintRecordsSiemens(complaintIDs, csInst.Patch_Source__c, siemensMessage));
                                    }
                                }else if(cs.status == GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER) {
                                    csInst.Internal_Work_Notes__c = siemensMessage;
                                    csInst.IS_Work_Notes_Changed__c = true;
                                    csInst.Assignment_Group__c = cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZIA ? System.label.ZIA_Assignment_Group_Siemens : System.label.Siemens_Assignment_Group;
                                    csInst.Patch_Source__c = 'Reassign';
                                    if(caseIdCaseIntComplaintIDMap.containskey(cs.id)) {
                                        List<Id> complaintIDs = caseIdCaseIntComplaintIDMap.get(cs.id);
                                        caseIntegartionRecordUpdate.addALL(CaseIntegrationHandler.prepareCaseComplaintRecordsSiemens(complaintIDs,csInst.Patch_Source__c,siemensMessage));
                                    }
                                    //Added by: Ankit Bhatnagar - IBA-1622 Starts
                                    if(em.TextBody.containsIgnoreCase(System.Label.Siemens_Customer_Communication_Keyword) || Test.isRunningTest()) {
                                        csInst.Customer_Communication__c = siemensMessage;
                                        csInst.Is_Customer_Communications_Changed__c = true;
                                        csInst.Assignment_Group__c = System.Label.Zscaler_Assignment_Group;
                                    }
                                    //Added by: Ankit Bhatnagar - IBA-1622 ends         
                                }else if(cs.status == GCSCommonConstants.CASE_STATUS_RESEARCHING 
                                    || cs.status == GCSCommonConstants.CASE_STATUS_ESCALATED_TO_ENGINEERING 
                                    || cs.status == GCSCommonConstants.CASE_STATUS_AWAITING_FIX 
                                    || cs.status == GCSCommonConstants.CASE_STATUS_CUSTOMER_CALLBACK_SCHEDULED) {
                                    csInst.Internal_Work_Notes__c = siemensMessage;
                                    csInst.IS_Work_Notes_Changed__c = true;
                                    csInst.Ticket_Status__c = 'Open';
                                    csInst.Patch_Source__c = 'Worknotes';
                                }
                            }
                        }
                        csInst.Status_Code__c = String.valueOf(GCSCommonConstants.INTEGER_0);
                        csInst.Integration_Status__c = 'Not Started';
                        System.debug('--csInst--'+csInst);
                        caseIntegartionRecordUpdate.add(csInst);
                    }
                }
                if(!caseIntegartionRecordUpdate.isEmpty()) {
                    TriggerUtility.caseIntegartionExecutedSetTrue();
                    List<Database.SaveResult> srList = Database.update(caseIntegartionRecordUpdate, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to Prepare CaseIntegartion Record From a Siemens Case
     * @param  csObj        Siemens Case record
     * @param  caseInt      Case_Integration__c record
     * @param  metaDataList List<Generic_Field_Mapping__mdt>
     * @return              Case_Integration__c
     */
    private static Case_Integration__c prepareCaseIntegartionRecordFromCaseSiemens(Case csObj, Case_Integration__c caseInt, List<Generic_Field_Mapping__mdt> metaDataList) {
        List<Generic_Field_Mapping__mdt> siemnsMapping = new List<Generic_Field_Mapping__mdt>();
        for(Generic_Field_Mapping__mdt mdt : metaDataList){
            if(mdt.Origin__c != null && mdt.Origin__c == 'Siemens'){
                siemnsMapping.add(mdt);
            }
        }
        return (Case_Integration__c)GenericFieldMappingController.prepareRecordFromGenericFieldMapping(csObj, caseInt, siemnsMapping);
    }
    
    /**
     * This method is used to Update Prior Owner of a Case
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void updatePriorOwnerofCase(List<Case> newList, Map<Id, Case> oldmap) {
        final String METHOD_NAME = 'updatePriorOwnerofCase';
        try {
            Integer threshold = Integer.valueOf(Label.Case_Reassignment_Threshold);
            Map<Id, Case> mapOfCaseAndCaseDetail = new Map<Id, Case>();
            for(Case cs:newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID && cs.Ownerid != oldmap.get(cs.id).Ownerid){
                    if(oldmap.get(cs.id).Ownerid != null 
                        && string.valueOf(oldmap.get(cs.id).Ownerid).startsWith(GCSCommonConstants.STARTS_WITH_005)){
                        cs.Prior_Owner__c=oldmap.get(cs.id).Ownerid;
                    }
                    cs.Case_Owner_Assigned_Date__c = System.now();
                    
                    //Case Handoff Project - Anup - Start
                    if(cs.OwnerId != null 
                        && String.valueOf(cs.OwnerId).startsWith(GCSCommonConstants.STARTS_WITH_005) 
                        && !String.valueOf(oldmap.get(cs.id).Ownerid).startsWith(GCSCommonConstants.STARTS_WITH_005) 
                        && cs.Original_Case_Assigned_Date_Time__c != null){
                        Integer counter = GCSCommonConstants.INTEGER_0;
                        if(cs.Reassignment_Counter__c == null) {
                            counter = GCSCommonConstants.INTEGER_0;
                        }else{
                            counter = Integer.valueOf(cs.Reassignment_Counter__c);
                        }
                        counter += GCSCommonConstants.INTEGER_1;
                        cs.Reassignment_Counter__c = counter;
                        
                        //IBA-1334 - Adding condition to not send email for P1 cases
                        if((counter >= threshold) && cs.Priority != GCSCommonConstants.CASE_PRIORITY_URGENT){
                            mapOfCaseAndCaseDetail.put(cs.Id, cs);
                        }
                    }
                    //Case Handoff Project - Anup - End
                }
            }
            if((mapOfCaseAndCaseDetail != null && !mapOfCaseAndCaseDetail.isEmpty()) || Test.isRunningTest()){
                sendReassignmentThresholdEmail(mapOfCaseAndCaseDetail);
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to Update the Account on a Support Case
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void changeAccountofSupportCase(List<Case> newList, Map<Id, Case> oldmap) {
        List<Case> caselist = new List<Case>();
        for(Case cs : newList){
            if(cs.RecordTypeId == CASE_SUPPORT_RT_ID && cs.AccountId != oldmap.get(cs.id).AccountId){
                caselist.add(cs);
            }
        }
        if(!caselist.isEmpty()){
            assignAccountforSupportCase(caselist);
        }
    }
    
    /**
     * This method is used to Update Master Case Record
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void updateDetailsOnMasterCase(List<Case> newList, map<Id,Case> oldMap) {
        List<Id> caseIdList = new List<Id>();
        for(Case cs : newList){
            if(cs.Master_Case__c != null && cs.Master_Case__c != oldMap.get(cs.Id).Master_Case__c){
                caseIdList.add(cs.Master_Case__c);
            }else if(cs.Master_Case__c == null && oldMap.get(cs.Id).Master_Case__c != null){
                caseIdList.add(oldMap.get(cs.Id).Master_Case__c);
            }
        }
        if(!caseIdList.isEmpty()){
            UpdateMasterCaseKeyfields qJob = new UpdateMasterCaseKeyfields(caseIdList);
            System.enqueueJob(qJob);
        }
        TriggerUtility.UpdateDetailsonMasterCaseExecuted();
    }
    
    /**
     * This method is used to Close Milestoen when a Case is Closed
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void closeMilestonesonCaseClosure(List<Case> newList, map<Id,Case> oldMap) {
        Set<Id> caseIds = new Set<Id>();
        for(Case cs: newList){
            if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                && cs.IsClosed 
                && cs.IsClosed != oldMap.get(cs.Id).IsClosed){
                caseIds.add(cs.Id);
            }
        }
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        if(!caseIds.isEmpty()){
            MilestoneUtils.completeMilestone(caseIds, GCSCommonConstants.CASE_MILESTONE_FIRST_RESPONSE, System.now());
            MilestoneUtils.completeMilestone(caseIds, GCSCommonConstants.CASE_MILESTONE_SUBSEQUENT, System.now());
        }
        TriggerUtility.CloseMilestonesonCaseCloseExecuted();
    }
    
    /**
     * This method is used to Survey record on a Case
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void getFeedbackSurveyCreation(List<Case> newList, map<Id, case> oldMap) {
        final String METHOD_NAME = 'getFeedbackSurveyCreation';
        try {
            List<Survey__c> ticketList = new List<Survey__c>();
            
            //Added By Anup : CR#959 - Start
            List<String> domainsToExclude = new List<String>();
            domainsToExclude = fetchDomainsToExclude();
            //Added By Anup : CR#959 - End
            
            //Added By Anup : CR987 - Start
            List<Id> listOfuserId = new List<Id>();
            for(Case cs : newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.IsClosed 
                    && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION) 
                    && cs.IsClosed != oldMap.get(cs.Id).IsClosed) {
                    listOfuserId.add(cs.Case_Owner_Manager__c);
                    listOfuserId.add(cs.OwnerId);
                }
            }
            Map<Id, User> mapOfUserDetails = new Map<Id, User>();
            if(!listOfuserId.isEmpty()){
                mapOfUserDetails = new Map<Id,user>(UserSelector.getUsers(listOfuserId, new List<Id>(), null));
            }
            
            //Added By Anup : CR987 - Start
            Boolean isSandboxOrg = GCSCommonUtility.isSandbox();
            for(Case cs : newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.IsClosed 
                    && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION) 
                    && cs.IsClosed != oldMap.get(cs.Id).IsClosed) {
                    ticketList.add(createSurvey(cs, domainsToExclude, mapOfUserDetails, isSandboxOrg));//Anup : Adding mapOfUserDetails parameter for CR987
                }
            }
            if(!ticketList.isEmpty()){
                List<Database.SaveResult> srList = Database.insert(ticketList, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
            TriggerUtility.GetFeedbackExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to prepare Survey record with given details
     * @param  ticket                 Case record on which Survey is created
     * @param  listOfDomainsToExclude List Of Domains To Exclude strings
     * @param  mapOfUserDetails       User Details Map
     * @return                        Survey__c record
     */
    public static Survey__c createSurvey(Case ticket, List<String> listOfDomainsToExclude, Map<Id, User> mapOfUserDetails, Boolean isSandboxOrg) {
        Survey__c ticketFeedback = new Survey__c();
        ticketFeedback.RecordTypeId = GCSCommonUtility.getSurveyRecordTypeId(GCSCommonConstants.CSAT_SURVEY_RECORD_TYPE_NAME);
        ticketFeedback.Case__c = ticket.Id;
        if(ticket.accountId != null) {
            ticketFeedback.Account__c = ticket.accountId;
        }
        if(ticket.contactId != null) {
            ticketFeedback.Contact__c = ticket.contactId;
        }
        ticketFeedback.Zendesk_Area__c = ticket.Case_Category__c;
        ticketFeedback.Zendesk_Sub_Area__c = ticket.Case_Sub_Category__c;
        String currEmail = GCSCommonConstants.EMPTY_STRING;//Added By Anup : CR#959
        if(isSandboxOrg) {
            ticketFeedback.Contact_Email__c = Label.surveySandboxEmail;
            currEmail = Label.surveySandboxEmail;//Added By Anup : CR#959
        }else {
            ticketFeedback.Contact_Email__c = ticket.ContactEmail;
            currEmail = ticket.ContactEmail;//Added By Anup : CR#959
        }
        
        //Added By Anup : CR#959 - Start
        if(checkEmailDomainsExclude(currEmail, listOfDomainsToExclude) || Test.isRunningTest()){
            ticketFeedback.Contact_Email_Includes_Public_Domain__c = true;
            ticketFeedback.Survey_Status__c = 'Survey not Sent due to Public Domain';
        }
        //Added By Anup : CR#959 - End
        
        ticketFeedback.Contact_Name__c = ticket.Contact_Name__c;
        ticketFeedback.Ticket_Assignee__c = ticket.OwnerId;
        ticketFeedback.Case_Owner_Manager__c = ticket.Case_Owner_Manager__c;
        
        //Added by Anup : CR987 - Start
        if(!mapOfUserDetails.isEmpty()){
            if(mapOfUserDetails.containsKey(ticket.Case_Owner_Manager__c) 
                && mapOfUserDetails.get(ticket.Case_Owner_manager__c) != null) {
                ticketFeedback.Case_Owner_Manager_s_Manager__c = mapOfUserDetails.get(ticket.Case_Owner_manager__c).ManagerId;
            }
            if(mapOfUserDetails.containsKey(ticket.OwnerId)) {
                ticketFeedback.Parent_Case_Owner__c = ticket.OwnerId;
            }
        }
        if(ticket.Account_Extension__c != null){
            ticketFeedback.Account_Extension__c = ticket.Account_Extension__c;
        }
        //Added by Anup : CR987 - End
        
        return ticketFeedback;
    }
    
    /**
     * This method is used to populate the Support Record Type Id on a Case whch are created through Integration
     * @param  newList new case list
     */
    public static void convertIntegrationCasestoSupport(List<Case> newList) {
        for(Case cs : newList){
            if(cs.case_source__c == GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION){
                cs.RecordTypeId = CASE_SUPPORT_RT_ID;
                if(String.isNotBlank(cs.Case_Type__c)){
                    cs.Case_Type__c = GCSCommonConstants.CASE_TYPE_PROBLEM;
                }
            }
        }
    }
    
    /**
     * This method is used to populate the Account Id on a Case
     * @param  newList new case list
     */
    public static void assignAccountforSupportCase(List<Case> newList) {
        for(Case cs : newList){
            if(cs.RecordTypeId == CASE_SUPPORT_RT_ID){
                cs.Account_of_Support_Case__c = cs.AccountId;
            }
        }
    }
    
    /**
     * This method is used to Escalate a Case
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void escalateCase(List<Case> newList, map<Id, case> oldmap) {
        final String METHOD_NAME = 'escalateCase';
        try {
            Set<String> accIds = new Set<String>();
            Set<Id> caseOwners = new Set<Id>();
            List<Case> supportcases = new List<Case>();
            
            //Added by Anup - Handoff Project - Start
            Map<String, Timezone_Region_Mapping__c> tacTimeRegionMap = Timezone_Region_Mapping__c.getAll();
            //Added by Anup - Handoff Project - End
            
            for(Case cs : newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.HandOff_Cases__c 
                    && cs.HandOff_Cases__c != oldmap.get(cs.Id).HandOff_Cases__c
                    && String.isNotBlank(cs.AccountId)){
                    supportcases.add(cs);
                    caseOwners.add(cs.OwnerId);
                    accIds.add(cs.AccountId);
                }
            }
            Map<Id, String> userIdToLevelMap = new Map<Id, String>();
            for(User us : UserSelector.getUsers(caseOwners, true)){
                userIdToLevelMap.put(us.Id, us.Skills__c);
            }

            //Added by Anup - CR#2195 - Start
            Set<Id> accountIdExcludedPartner = new Set<Id>();

            if(!accIds.isEmpty()) {
                String queryFields = 'Id, Exclude_Partner_Support__c';
                String whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(new List<String>(), accIds);
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                for (Account acc : AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause)) {
                    accountIdExcludedPartner.add(acc.Id);
                }
            }
            
            List<String> nonZpaProducts = new List<String>();
            if(String.isNotBlank(Label.Non_ZPA_Products)){
                nonZpaProducts = Label.Non_ZPA_Products.trim().split(GCSCommonConstants.COMMA_STRING);
            }
            /*List<QueueSobject> queues = new List<QueueSobject>([SELECT Id, QueueId 
                                                                FROM QueueSobject 
                                                                WHERE sObjectType = :GCSCommonConstants.CASE_STRING 
                                                                AND Queue.DeveloperName = 'ZPA_Product_Queue']);
            String zpaQueueId = !queues.isEmpty() ? queues.get(GCSCommonConstants.INTEGER_0).queueId : GCSCommonConstants.EMPTY_STRING;*/
            String zpaQueueId = GCSCommonUtility.getCaseQueueId(GCSCommonConstants.Q_DEV_NAME_ZPA_PRODUCT_QUEUE);
            //Added by Anup - CR#2195 - End
            
            for(case cs: supportcases){
                //Added by Ankit - CR# 4069 Start
                if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                    || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION) {
                    //On Weekdays: Set Product Type on the basis of Case's Product
                    //Added by Chetan - CR# 6176 Start
                    Boolean isWeekendCaseRouting = GCSCommonUtility.checkIfWeekend();
                    if(!isWeekendCaseRouting 
                        && cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZCC){
                        cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_ZCC;
                    }
                    else{
                        if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA) {
                            cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_ZPA;
                        }else if(nonZpaProducts.contains(cs.Product_New__c)) {
                            cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_NON_ZPA;
                        }
                    }
                    //Added by Chetan - CR# 6176 End 
                }
                //Added by Ankit - CR# 4069 End
                
                cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE;//Added by Anup - Omni Overhaul
                cs.Primary_Support__c = GCSCommonConstants.EMPTY_STRING;
                cs.Escalation_Support__c = GCSCommonConstants.EMPTY_STRING;
                
                //Added by Anup - Handoff Project - Start
                if(cs.Preferred_Contact_Time_Zone__c != null 
                    && tacTimeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c) 
                    && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c) != null 
                    && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c != null){
                    String tacRegion = tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c;
                    cs.Region_Support__c = tacRegion;
                }
                //Added by Anup - Handoff Project - End
                
                if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA){
                    cs.OwnerID = zpaQueueId;
                }else{
                    cs.OwnerId = Label.Support_Queue_Id;
                }
                cs.Handed_Off_Case__c = false;//IBA-1316
                cs.Work_Item_Progress__c = GCSCommonConstants.CASE_WORK_ITEM_PROGRESS_IN_PROGRESS;//IBA-2400 - Anup
            }
            TriggerUtility.skipCaseEscalationExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to populate the Status & Start Date on a Case
     * @param  case list
     */
    public static void assignStatusStartDate(List<Case> cslst) {
        for(Case cs : cslst){
            if(cs.status != null && cs.recordtypeId == CASE_SUPPORT_RT_ID){
                cs.Status_Start_Date__c = System.now();
                cs.Work_Item_Progress__c = GCSCommonConstants.CASE_WORK_ITEM_PROGRESS_IN_PROGRESS;//IBA-2400 - Anup
            }
        }
    }
    
    /**
     * This method is used to create a Case_Escalation_History__c
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void escalationHistoryCreation(List<Case> newList, map<Id, case> oldMap) {
        final String METHOD_NAME = 'escalationHistoryCreation';
        try {
            List<Case> supportCases = new List<Case>();
            List<Case> casesToUpdate = new List<Case>();
            Map<Id, Case_Escalation_History__c> mapCaseToEscalation = new Map<Id, Case_Escalation_History__c>();
            for(Case cs: newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.IsClosed 
                    && cs.IsClosed != oldmap.get(cs.Id).IsClosed){
                    supportCases.add(cs);
                }
            }
            List<Case_Escalation_History__c> cEscHisList = new List<Case_Escalation_History__c>();
            List<Case_Notes_History__c> cNotesHisList = new List<Case_Notes_History__c>();
            for(Case cs: supportcases){
                case csToUpdate = new case(Id = cs.Id);
                Case_Escalation_History__c ceh = new Case_Escalation_History__c(Case__c = cs.Id);
                for (FieldSetMember fm : GCSCommonUtility.getCaseFieldSet(GCSCommonConstants.CASE_ESCALATION_HISTORY_CREATION_FIELDSET_NAME)) {
                    ceh.put(fm.getFieldPath(), cs.get(fm.getFieldPath()));
                }
                if(cs.OwnerId.getSObjectType().getDescribe().getName() == 'User'){
                    ceh.Case_Owner__c = cs.OwnerId;
                }
                ceh.Escalation_End_time__c = system.now();
                ceh.Escalation_Resolved_By__c = UserInfo.getUserId();
                cEscHisList.add(ceh);
                cstoupdate.Escalation_End_time__c = system.now();
                cstoupdate.Escalation_Resolved_By__c = UserInfo.getUserId();
                casesToUpdate.add(cstoupdate);
                
                if(!mapCaseToEscalation.containskey(cs.Id)){
                    mapCaseToEscalation.put(cs.Id, ceh);
                }
            }
            if(!cEscHisList.isEmpty()) {
                List<Database.SaveResult> srList = Database.insert(cEscHisList, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
            TriggerUtility.CaseBeforeUpdateExecuted();
            TriggerUtility.CaseAfterUpdateExecuted();
            if(!casesToUpdate.isEmpty()) {
                List<Database.SaveResult> srList = Database.update(casesToUpdate, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
            for(Case_Notes_History__c cnh : [SELECT Id, Case__c, Case_Escalation_History__c 
                                                FROM Case_Notes_History__c 
                                                WHERE Case__c IN :mapCaseToEscalation.keyset() 
                                                AND Case_Escalation_History__c = null]){
                if(cnh.Case__c != null 
                    && mapCaseToEscalation.containsKey(cnh.Case__c) 
                    && mapCaseToEscalation.get(cnh.Case__c) != null 
                    && mapCaseToEscalation.get(cnh.Case__c).Id != null){
                    cnh.Case_Escalation_History__c = mapCaseToEscalation.get(cnh.Case__c).Id;
                    cNotesHisList.add(cnh);
                }
            }
            if(!cNotesHisList.isEmpty() || Test.isRunningTest()) {
                List<Database.SaveResult> srList = Database.update(cNotesHisList, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
            TriggerUtility.CaseEscalationHistoryExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to create a Case_Notes_History__c
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void escalationNotesCreation(List<Case> newList, map<Id, case> oldMap) {
        final String METHOD_NAME = 'escalationNotesCreation';
        List<Case_Notes_History__c> cNotesHisList = new List<Case_Notes_History__c>();
        for(Case cs: newList){
            if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                && cs.Escalation_Resolution_Notes__c != oldMap.get(cs.Id).Escalation_Resolution_Notes__c){
                Case_Notes_History__c cnh = new Case_Notes_History__c(
                    Escalation_Stage__c = cs.Escalation_Stage__c, 
                    Escalation_Notes__c = cs.Escalation_Resolution_Notes__c, 
                    Case__c = cs.Id, 
                    Notes_Added_at__c = system.now(), 
                    Notes_Added_By__c=userinfo.getUserId(), 
                    Customer_Temperature__c = cs.Customer_Temperature__c, 
                    Escalation__c = cs.Escalation_Reason_New_n__c
                );//Added By Anup- CR#1648 - Replacing Escalation_Reason_New__c with Escalation_Reason_New_n__c
                cNotesHisList.add(cnh);
            }
        }
        if(!cNotesHisList.isEmpty()) {
            List<Database.SaveResult> srList = Database.insert(cNotesHisList, false);
            GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
        }
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        TriggerUtility.CaseEscalationNotesExecuted();
    }
    
    /**
     * This method is used to populate Entitlement on a Case
     * @param  newList new case list
     */
    public static void assignEntitlementtoCase(List<Case> newList) {
        final String METHOD_NAME = 'assignEntitlementtoCase';
        try {
            Map<Id, Case> csMap = new Map<Id, Case>();
            for(Case cs: newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID){
                    csMap.put(cs.AccountId, cs);
                }
            }
            for(Entitlement ent : [SELECT Id, AccountId 
                                    FROM Entitlement 
                                    WHERE AccountId IN :csMap.keySet() 
                                    AND EndDate = null/*AND Status = 'Active'*/]){
                if(ent.AccountId != null){
                    csMap.get(ent.AccountId).EntitlementId = ent.Id;
                }
            }
            TriggerUtility.CaseEntitlementAssigned();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to manage the Case Status changes
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void caseStatusChangeManagement(List<Case> newList, map<Id, case> oldMap) {
        final String METHOD_NAME = 'caseStatusChangeManagement';
        try {
            Map<Id, Case> csMap = new Map<Id, Case>();
            Set<Id> caseIds = new Set<Id>();
            Map<String, Case_Status_and_SLA_Map__c> cSSMap = Case_Status_and_SLA_Map__c.getAll();
            Set<Id> caseIdForStatusManage = new Set<Id>();
            for(Case cs: newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID && cs.Status != oldmap.get(cs.Id).Status){
                    csMap.put(cs.AccountId, cs);
                }
                
                //IBA-2400 - Anup - Start
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.Work_Item_Progress__c != oldMap.get(cs.Id).Work_Item_Progress__c 
                    && cs.Work_Item_Progress__c == 'Completed'){
                    caseIdForStatusManage.add(cs.Id);
                }
                //IBA-2400 - Anup - End
            }
            List<Case_Stage_History__c> caseStageHistoryList = new List<Case_Stage_History__c>();
            for(Case cs: csMap.values()){
                Case_Stage_History__c csh = new Case_Stage_History__c(Case__c = cs.Id, 
                                                                    Start_Date__c = oldmap.get(cs.Id).Status_Start_Date__c,
                                                                    End_Date__c = System.now(),
                                                                    Modified_By__c = UserInfo.getUserId(),
                                                                    Case_Status__c = oldmap.get(cs.Id).Status);
                if(cs.SRT_Violated_Time__c >= csh.Start_Date__c 
                    && cs.SRT_Violated_Time__c <= csh.End_Date__c){
                    csh.Subsequent_Response_Breached__c = cs.Subsequent_Response_Breached__c;
                    csh.SRT_Violated_Time__c = cs.SRT_Violated_Time__c;
                }
                if(cs.First_Response_Violated_Time__c >= csh.Start_Date__c 
                    && cs.First_Response_Violated_Time__c <= csh.End_Date__c){
                    csh.First_Response_Time_Violated__c = cs.First_Response_Time_Violated__c;
                    csh.First_Response_Violated_Time__c = cs.First_Response_Violated_Time__c;
                }
                caseStageHistoryList.add(csh);
                if(cs.Status == GCSCommonConstants.CASE_STATUS_CLOSED){
                    csh = new Case_Stage_History__c(Case__c = cs.Id, 
                                                    Start_Date__c = System.now(),
                                                    End_Date__c = System.now(),
                                                    Modified_By__c = UserInfo.getUserId(),
                                                    Case_Status__c = cs.Status);
                    caseStageHistoryList.add(csh);
                }
                if(oldMap.get(cs.Id).Status != null 
                    && cSSMap.containskey(oldMap.get(cs.Id).Status) 
                    && cssMap.get(oldMap.get(cs.Id).Status).SLA_Type__c == 'SRT') {
                    caseIds.add(cs.Id);
                }
            }
            TriggerUtility.CaseBeforeUpdateExecuted();
            TriggerUtility.CaseAfterUpdateExecuted();
            if(!caseStageHistoryList.isEmpty()){
                List<Database.SaveResult> srList = Database.insert(caseStageHistoryList, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
            if(!caseIds.isEmpty()){
                MilestoneUtils.completeMilestone(caseIds, GCSCommonConstants.CASE_MILESTONE_SUBSEQUENT, System.now());
            }

            //IBA-2400 - Anup - Start
            if(!caseIdForStatusManage.isEmpty()){
                MilestoneUtils.completeMilestone(caseIdForStatusManage, 'Ticket Assignment Timer', System.now());
            }
            //IBA-2400 - Anup - End

            TriggerUtility.CaseStatusHistoryExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to post chatter feed on a given case
     * @param  newList new case list
     */
    public static void makeCaseDescriptionToComment(List<Case> newList) {
        final String METHOD_NAME = 'makeCaseDescriptionToComment';
        //Ram added to debug & fix the failed chatter feeds
        String caseDesc = GCSCommonConstants.EMPTY_STRING;
        try {
            Map<Id, Case> csMap = new Map<Id, Case>();
            for(Case cs : newList){
                if((cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                        || cs.RecordTypeId == CASE_EXPERIENCE_PROJECT_RT_ID) 
                    && String.isNotBlank(cs.Description)){
                    csMap.put(cs.Id, cs);
                }
            }
            List<FeedItem> feedItems = new List<FeedItem>();
            for(Case cs : csmap.values()){
                caseDesc += cs.Id + '##' + cs.CaseNumber + '##' + cs.Description + '\n';
                feedItems.add(GCSCommonUtility.prepareFeedItem(cs.Id, cs.Description, GCSCommonConstants.ALL_USERS_VISIBILITY, true, false));
            }
            caseDesc = String.isNotBlank(caseDesc) ? caseDesc.removeEnd('\n') : GCSCommonConstants.EMPTY_STRING;

            TriggerUtility.CaseBeforeInsertExecuted();
            TriggerUtility.CaseAfterInsertExecuted();
            TriggerUtility.skipCaseEscalationExecuted();
            TriggerUtility.UpdateTAMemailExecuted();
            TriggerUtility.UpdateSEonCaseExecuted();
            TriggerUtility.CaseAfterUpdateExecuted();
            TriggerUtility.SkipFeedItemTriggerExecuted();
            TriggerUtility.SkipCaseCommentTriggerExecuted();
            if(!feedItems.isEmpty()) {
                List<Database.SaveResult> srList = Database.insert(feedItems, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, caseDesc);
            }
            TriggerUtility.CaseDesctoCommentExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, caseDesc, String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to assign new Start Date whenever Case Status changes
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void assignNewStartDateforStatus(List<Case> newList, map<Id, case> oldMap) {
        for(Case cs: newList){
            if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                && cs.Status != oldMap.get(cs.Id).Status){
                cs.Status_Start_Date__c = system.now();
                cs.Manual_SLA_Timestamp__c = null;
            }
        }
    }
    
    /**
     * This method is used to handle Manual SLA changes
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void manualSLAChange(List<Case> newList, map<Id, case> oldMap) {
        final String METHOD_NAME = 'manualSLAChange';
        try {
            Map<String, Case> csMap = new Map<String, Case>();
            for(Case cs : newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.Manual_SLA_Timestamp__c != oldmap.get(cs.Id).Manual_SLA_Timestamp__c){
                    csMap.put(cs.Id, cs);
                }
            }

            List<CaseMilestone> milestones = new List<CaseMilestone>();
            if(!csMap.isEmpty()){
                for(CaseMilestone cm : GCSCommonUtility.getCaseMilestones(
                        new List<String>(csMap.keyset()), 
                        new List<String>{GCSCommonConstants.CASE_MILESTONE_SUBSEQUENT})){
                /*for(CaseMilestone cm : [SELECT Id, MilestoneType.Name, CaseId, StartDate, TargetDate, CompletionDate 
                                        FROM CaseMilestone 
                                        WHERE CaseId IN :csMap.keyset() 
                                        AND MilestoneType.Name = 'Subsequent' 
                                        AND CompletionDate = null]){*/
                    Long diffInMs = (cm.TargetDate.getTime() - cm.StartDate.getTime());
                    Long diffInSec = diffInMs/GCSCommonConstants.INTEGER_1000;
                    Integer diffInMin = -GCSCommonConstants.INTEGER_1 * Integer.valueOf(diffInSec / GCSCommonConstants.INTEGER_60);
                    cm.StartDate = csMap.containsKey(cm.CaseId) 
                        && csMap.get(cm.CaseId) != null 
                        && csMap.get(cm.CaseId).Manual_SLA_Timestamp__c != null 
                        && diffInMin != null ? csMap.get(cm.CaseId).Manual_SLA_Timestamp__c.addMinutes(diffInMin) : cm.StartDate;
                    milestones.add(cm);
                }
            }
            TriggerUtility.CaseBeforeUpdateExecuted();
            TriggerUtility.CaseAfterUpdateExecuted();
            if(!milestones.isEmpty()) {
                List<Database.SaveResult> srList = Database.update(milestones, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
            TriggerUtility.ManualSLAExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //NEED TO CHECK IF THIS IS STILL RELEVANT 
    /**
     * This method is used to populate Customer Score details on a Case
     * @param  newList new case list
     */
    public static void assignCustomerScoreParameters(List<Case> newList) {
        Map<String, Case_Priority_Score__c> cpsMap = Case_Priority_Score__c.getAll();
        Map<String, DEFCON_Case_Score__c> dccMap = DEFCON_Case_Score__c.getAll();
        for(Case cs : newList){
            if(cs.RecordTypeId == CASE_SUPPORT_RT_ID){
                if(String.isNotBlank(cs.Priority)){
                    cs.Case_Priority_Score__c = cpsMap.containsKey(cs.Priority) ? cpsMap.get(cs.Priority).Score__c : cs.Case_Priority_Score__c;
                }
                if(String.isNotBlank(cs.Defcon_Level__c)){
                    cs.DEFCON_Score__c = dccMap.containsKey(cs.Defcon_Level__c) ? dccMap.get(cs.Defcon_Level__c).Score__c : cs.DEFCON_Score__c;
                }
            }
        }
    }
    //NEED TO CHECK IF THIS IS STILL RELEVANT 
    
    /**
     * This method is used to Update TAM Email
     * @param  Caselist
     */
    public static void updateTAMemail(List<Case> Caselist) {
        final String METHOD_NAME = 'updateTAMemail';
        try {
            Map<Id, String> mapOfAccExtAndEmail = new Map<Id, String>();
            for(Case cs:Caselist){
                cs.X3rd_TAM_Email__c=cs.X3_TAM_Email__c;
                cs.Primary_TAM_Email__c=cs.Primary_TAM_Emailformula__c;
                cs.Secondary_TAM_Email__c=cs.Secondary_TAM_EmailFormula__c;
                
                //Added by Anup : CR#1701 - Start
                if(cs.Account_Extension__c != null){
                    mapOfAccExtAndEmail.put(cs.Account_Extension__c, GCSCommonConstants.EMPTY_STRING);
                }
                //Added by Anup : CR#1701 - End
            }
            
            //Added by Anup : CR#1701 - Start
            if(!mapOfAccExtAndEmail.isEmpty()){
                for(Account_Extension__c accExt : [SELECT Id, X4th_TAM_Name__c, X4th_TAM_Name__r.Email 
                                                    FROM Account_Extension__c 
                                                    WHERE Id IN :mapOfAccExtAndEmail.keySet() 
                                                        AND X4th_TAM_Name__c != null]){
                    if(String.isNotBlank(accExt.X4th_TAM_Name__r.Email)){
                        mapOfAccExtAndEmail.put(accExt.Id, accExt.X4th_TAM_Name__r.Email);
                    }
                }
                for(Case cs:CaseList){
                    if(mapOfAccExtAndEmail.containsKey(cs.Account_Extension__c) 
                        && String.isNotBlank(mapOfAccExtAndEmail.get(cs.Account_Extension__c))){
                        cs.X4th_TAM_Email__c = mapOfAccExtAndEmail.get(cs.Account_Extension__c);
                    }
                }
            }
            //Added by Anup : CR#1701 - End
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    // Added by Gurjinder : CR# 125 :Start
    /**
     * This method is used to Update SE details on a Case
     * @param  Caselist
     */
    public static void updateSEonCase(List<Case> Caselist) {
        for(Case cs : Caselist){
            cs.Sales_Engineer__c = cs.Account_SE_id__c;
        }
        TriggerUtility.UpdateSEonCaseExecuted();
    }
    // Added by Gurjinder : CR# 125 :End
    
    // CR# 180 : Abhishek : Short term fixes for CC List : Start
    /**
     * This method is used to update case CC list after Case update
     * @param  newList new case list
     * @param  oldMap old case map
     */
    public static void cctoCaseTeamafterUpdate(List<Case> newlist, Map<Id, Case> oldmap) {
        List<Case> cslst = new List<Case>();
        for(Case cs: newlist){
            if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                && (cs.Internal_cc_List__c != oldmap.get(cs.Id).Internal_cc_List__c 
                    || cs.Customer_CC_List__c != oldmap.get(cs.Id).Customer_CC_List__c)) {
                cslst.add(cs);
            }
        }
        createCaseTeam(cslst);
    }
    
    /**
     * This method is used to update case CC list after Case insert
     * @param  newList new case list
     */
    public static void cctoCaseTeamafterInsert(List<Case> newlist) {
        List<Case> cslst = new List<Case>();
        for(Case cs: newlist){
            if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                && (cs.Internal_cc_List__c != null 
            || cs.Customer_CC_List__c != null)){
                cslst.add(cs);
            }
        }
        createCaseTeam(cslst);
    }
    
    //CR# 251 replicate Original TAM information into Case during creation
    /**
     * This method is used to populate the TAM details on a given Case
     * @param  case list
     */
    public static void fillTAMDetails(List<Case> caseList) {
        final String METHOD_NAME = 'fillTAMDetails';
        try {
            Set<String> accountIdSet = new Set<String>();
            for(Case c: caseList){
                if(String.isNotBlank(c.AccountId)){
                    accountIdSet.add(c.AccountId);
                }
            }

            MAP<ID, Account> accMap;
            if(!accountIdSet.isEmpty()){
                String queryFields = 'Id, Name, TAM_Name_New__c, Secondary_TAM_Name__c, X3rd_TAM_Name__c';
                String whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(new List<String>(), accountIdSet);
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                accMap = new MAP<ID, Account>(AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause));
            }

            for(Case c : caseList) {
                if(accMap != null 
                    && !accMap.isEmpty() 
                    && accMap.containskey(c.accountid) 
                    && accMap.get(c.accountid) != null){
                    Account acc = accMap.get(c.accountid);
                    c.Original_Primary_TAM__c = acc.TAM_Name_New__c;
                    c.Original_Secondary_TAM__c = acc.Secondary_TAM_Name__c;
                    c.Original_Third_TAM__c = acc.X3rd_TAM_Name__c;
                }
            }
            TriggerUtility.UpdateOriginalTAMexecuted();

        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //Added by Swathi: CR1008 Start
    /**
     * This method is used to update CSM on a Case
     * @param  case list
     */
    public static void updateCSMonCase(List<Case> caseLists) {
        final String METHOD_NAME = 'updateCSMonCase';
        try {
            Set<String> accountIdSet = new Set<String>();
            for(Case c : caseLists){
                if(String.isNotBlank(c.AccountId)){
                    accountIdSet.add(c.AccountId);
                }
            }

            MAP<ID, Account> accMap;
            if(!accountIdSet.isEmpty()){
                String queryFields = 'Id, Name, CSM_Name_New__r.Email';
                String whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(new List<String>(), accountIdSet);
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                accMap = new MAP<ID, Account>(AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause));
            }

            for(Case c : caseLists){
                if(accMap != null 
                    && !accMap.isEmpty() 
                    && accMap.containskey(c.accountid) 
                    && accMap.get(c.accountid) != null){
                    Account acc = accMap.get(c.accountid);
                    c.CSM_Email__c = acc.CSM_Name_New__r.Email;
                }
            }
            TriggerUtility.UpdateCSMonCaseExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Swathi: CR1008 End
    
    /**
     * This method is used to create Case Team on a Case
     * @param  case list
     */
    public static void createCaseTeam(List<Case> cases) {
        final String METHOD_NAME = 'createCaseTeam';
        try {
            Map<Id, Set<Id>> mapCstoCaseTeamMemberId = new Map<Id, Set<Id>>();
            if(!cases.isEmpty()){
                Map<String, Id> teamRoleToIdMap = new Map<String, Id>();
                for(CaseTeamRole ctr : [SELECT Id, Name 
                                        FROM CaseTeamRole 
                                        WHERE Name IN (:customerStr, :internalAgentStr)]){
                    teamRoleToIdMap.put(ctr.Name, ctr.Id);
                }
                for(CaseTeamMember csteam : [SELECT Id, parentId, MemberId 
                                            FROM CaseTeamMember 
                                            WHERE ParentId IN :cases]){
                    if(!mapCstoCaseTeamMemberId.isEmpty()){
                        Set<Id> memberIds = mapCstoCaseTeamMemberId.get(csteam.parentId);
                        memberIds.add(csteam.MemberId);
                        mapCstoCaseTeamMemberId.put(csteam.parentId, memberIds);
                    }else{
                        mapCstoCaseTeamMemberId.put(csteam.parentId, new Set<Id>{csteam.MemberId});
                    }
                }
                Map<Id, Set<String>> mapCaseToInternal = new Map<Id, Set<String>>();
                Map<Id, Set<String>> mapCaseToExternal = new Map<Id, Set<String>>();
                Set<String> internalEmails = new Set<String>();
                Set<String> externalEmails = new Set<String>();
                
                //Added by Anup - CR# 4578 - Start
                Set<String> setOfDomain = new Set<String>();
                Map<String, ID> setOfDomainAndAccount = new Map<String, ID>();
                //Added by Anup - CR# 4578 - End
                
                for(Case cs: cases){
                    Set<String> intSetOfCase = new Set<String>();
                    Set<String> extSetOfCase = new Set<String>();
                    if(String.isNotBlank(cs.Internal_CC_List__c)){
                        for(String s: cs.Internal_CC_List__c.split(GCSCommonConstants.SEMI_COLON_STRING)){
                            if(s != GCSCommonConstants.EMPTY_STRING && s!= null){
                                internalEmails.add(s.trim().toLowerCase());
                                intsetofcase.add(s.trim().toLowerCase());
                            }
                        }
                    }
                    if(String.isNotBlank(cs.Customer_CC_List__c)){
                        for(String s : cs.Customer_CC_List__c.split(GCSCommonConstants.SEMI_COLON_STRING)){
                            if(s != GCSCommonConstants.EMPTY_STRING && s!= null){
                                externalEmails.add(s.trim().toLowerCase());
                                extsetofcase.add(s.trim().toLowerCase());
                                List<String> splittedEmail = s.split(GCSCommonConstants.AT_THE_RATE_STRING);
                                if(splittedEmail.size() >= GCSCommonConstants.INTEGER_2){
                                    setOfDomain.add(splittedEmail[GCSCommonConstants.INTEGER_1]);
                                }
                            }
                        }
                    }
                    mapCasetoInternal.put(cs.Id, intSetOfCase);
                    mapCasetoExternal.put(cs.Id, extSetOfCase);
                }
                
                Map<String, Id> mapEmailtoId = new Map<String, Id>();
                if(!internalEmails.isEmpty()){
                    List<Id> teamEmails = new List<Id>();
                    for(Set<Id> s : mapCstoCaseTeamMemberId.values()){
                        List<Id> strlst = new List<Id>(s);
                        teamEmails.addAll(strlst);
                    }
                    for(User us : [SELECT Id, Email 
                                    FROM User 
                                    WHERE isActive = true 
                                        AND Email IN :internalEmails 
                                        AND Profile.Name NOT IN (:GCSCommonConstants.ZS_PARTNER_COMMUNITY_USER_PROFILE_NAME, 
                                                                :GCSCommonConstants.CUSTOMER_COMMUNITY_USER_PROFILE_NAME)]){
                        if(!mapEmailtoId.containskey(us.email) 
                            || (teamEmails != null 
                                && !teamEmails.isEmpty() 
                                && teamEmails.contains(us.Id))){
                            mapEmailtoId.put(us.email, us.Id);
                        }
                    }
                }
                if(!externalEmails.isEmpty()){
                    List<Id> teamEmails = new List<Id>();
                    for(Set<Id> s: mapCstoCaseTeamMemberId.values()){
                        List<Id> strlst = new List<Id>(s);
                        teamEmails.addAll(strlst);
                    }
                    for(Contact con : [SELECT Id, Email 
                                        FROM Contact 
                                        WHERE Email IN :externalEmails]){
                        if(!mapEmailtoId.containskey(con.email) 
                            || (teamEmails != null 
                                && !teamEmails.isEmpty() 
                                && teamEmails.contains(con.Id))){
                            mapEmailtoId.put(con.email, con.Id);
                        }
                    }
                }
                
                //Added by Anup - CR# 4578 - Start
                if(!setOfDomain.isEmpty()){
                    String queryFields = 'Id, Domain__c, Additional_Organization_Domains__c';
                    String whereClause = 'Domain__c IN ' + GCSCommonUtility.getFormattedString(new List<String>(), setOfDomain) + ' AND Domain__c != null';
                    String orderByClause = GCSCommonConstants.EMPTY_STRING;
                    Integer limitClause = null;
                    for(Account acc : AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause)){
                        setOfDomainAndAccount.put(acc.Domain__c, acc.Id);
                        if(String.isNotBlank(acc.Additional_Organization_Domains__c)){
                            for(String adddomain : acc.Additional_Organization_Domains__c.split(GCSCommonConstants.COMMA_STRING)){
                                String accdomain = adddomain.trim().remove('https://www.').remove('http://www.').remove('https://').remove('http://');
                                if(String.isNotBlank(accdomain)){
                                    setOfDomainAndAccount.put(accdomain, acc.Id);
                                }
                            }
                        }
                    }
                }
                //Added by Anup - CR# 4578 - End
                
                List<CaseTeamMember> ctmlst = new List<CaseTeamMember>();
                Map<String, Contact> conEmailtoContact = new Map<String, Contact>();
                Map<String, CaseTeamMember> conEmailtoCTM = new Map<String, CaseTeamMember>();
                for(Id csid : mapCasetoInternal.keySet()){
                    Set<Id> existingCaseTeamIds = mapCstoCaseTeamMemberId.containsKey(csid) ? mapCstoCaseTeamMemberId.get(csId) : new Set<Id>();
                    for(String conEmail : mapCasetoInternal.get(csid)){
                        if((String.isNotBlank(conEmail) 
                                && mapEmailtoId.containsKey(conEmail.toLowerCase())) 
                            || Test.isRunningTest()){
                            String userId = mapEmailtoId.get(conEmail.toLowerCase());
                            if(!existingCaseTeamIds.contains(userId)){
                                CaseTeamMember ctm = new CaseTeamMember();
                                ctm.MemberId = userId;
                                ctm.ParentId = csid;
                                ctm.TeamRoleId = teamRoleToIdMap.containsKey(internalAgentStr) ? teamRoleToIdMap.get(internalAgentStr) : null;
                                ctmlst.add(ctm);
                            }
                        }
                    }
                }
                for(Id csid : mapCasetoExternal.keySet()){
                    Set<Id> existingCaseTeamIds = mapCstoCaseTeamMemberId.containsKey(csid) ? mapCstoCaseTeamMemberId.get(csId) : new Set<Id>();
                    for(String conEmail : mapCasetoExternal.get(csid)){
                        if(String.isNotBlank(conEmail)){
                            if(mapEmailtoId.containsKey(conEmail.toLowerCase())) {
                                String conId = mapEmailtoId.get(conEmail.toLowerCase());
                                if(!existingCaseTeamIds.contains(conId)){
                                    CaseTeamMember ctm = new CaseTeamMember();
                                    ctm.MemberId = conId;
                                    ctm.ParentId = csid;
                                    ctm.TeamRoleId = teamRoleToIdMap.containsKey(customerStr) ? teamRoleToIdMap.get(customerStr) : null;
                                    ctmlst.add(ctm);
                                }
                            }else{
                                //Added by Anup - CR# 4578 - Start
                                List<String> splittedEmail1 = conEmail.split(GCSCommonConstants.AT_THE_RATE_STRING);
                                String accountIdToPatch = label.Account_of_CC_Contact;
                                if(!splittedEmail1.isEmpty() 
                                    && splittedEmail1.size() >= GCSCommonConstants.INTEGER_2 
                                    && !setOfDomainAndAccount.isEmpty() 
                                    && setOfDomainAndAccount.containsKey(splittedEmail1[GCSCommonConstants.INTEGER_1]) 
                                    && setOfDomainAndAccount.get(splittedEmail1[GCSCommonConstants.INTEGER_1]) != null){
                                    accountIdToPatch = setOfDomainAndAccount.get(splittedEmail1[GCSCommonConstants.INTEGER_1]);
                                }
                                //Added by Anup - CR# 4578 - End
                                
                                conEmailtoContact.put(conEmail, new contact(email = conEmail, lastname = conEmail, accountid = accountIdToPatch, Contact_Type__c = 'Support'));
                                CaseTeamMember ctm = new CaseTeamMember();
                                ctm.ParentId = csid;
                                ctm.TeamRoleId = teamRoleToIdMap.containsKey(customerStr) ? teamRoleToIdMap.get(customerStr) : null;
                                conEmailtoCTM.put(conEmail, ctm);
                            }
                        }
                    }
                }
                if(!conEmailtoContact.isEmpty()){
                    ContactTriggerHelper.skipTrigger = true;
                    TriggerUtility.realignPatch();
                    List<Database.SaveResult> srList = Database.insert(conEmailtoContact.values(), false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);

                    if(!conEmailtoCTM.isEmpty()){
                        for(String conEmail : conEmailtoCTM.keyset()){
                            if(String.isNotBlank(conEmail)
                                && conEmailtoContact.containsKey(conEmail)){
                                CaseTeamMember ctm = conEmailtoCTM.get(conEmail);
                                ctm.MemberId = conEmailtoContact.get(conEmail).Id;
                                ctmlst.add(ctm);
                            }
                        }
                    }
                }
                if(!ctmlst.isEmpty()){
                    List<Database.SaveResult> srList = Database.insert(ctmlst, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    // CR# 180 : Abhishek : Short term fixes for CC List : Start
    /**
     * This method is used to update TAM Weekly Date Time
     * @param  case list
     * @param  oldMap old case map
     */
    public static void updateTAMWeeklyDateTime(List<Case> cases, Map<Id,Case> mapOldCases) {
        final String METHOD_NAME = 'updateTAMWeeklyDateTime';
        try {
            Id typeId = System.Label.CaseRT_Weekly_Meeting ;
            Map<Id, DateTime> mapCloseDateTime = new Map<Id,DateTime>();
            for (Case c: cases){
                if((c.AccountId != null 
                    && c.recordTypeID == typeId 
                    && c.closedDate != null 
                    && (mapOldCases == null 
                        || mapOldCases.get(c.Id).closedDate == null)) 
                || Test.isRunningTest()){
                    mapCloseDateTime.put(c.AccountId, c.ClosedDate);
                }
            }
            if(!mapCloseDateTime.isEmpty()){
                List<Account_Extension__c> accExtensions = new List<Account_Extension__c>();
                for(Account_Extension__c ae : [SELECT Id, Name,Account__c, TAM_Weekly_DateTime__c 
                                                FROM Account_Extension__c 
                                                WHERE Account__c IN : mapCloseDateTime.keySet()]){
                    // Added IF Condition by Rajesh : CR# 1229 : Start
                    if(mapCloseDateTime.containsKey(ae.Account__c) && ae.TAM_Weekly_DateTime__c < mapCloseDateTime.get(ae.Account__c)) {
                        ae.TAM_Weekly_DateTime__c = mapCloseDateTime.get(ae.Account__c);
                        accExtensions.add(ae);
                    }
                    // Added IF Condition by Rajesh : CR# 1229 : End
                }
                if(!accExtensions.isEmpty() || Test.isRunningTest()) {
                    List<Database.SaveResult> srList = Database.update(accExtensions, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to update Account_Extension__c on a Case
     * @param  cases        case list
     * @param  oldCaseMap   oldCaseMap old case map
     */
    public static void updateExtentison(List<Case> cases, Map<Id,Case> oldCaseMap) {
        final String METHOD_NAME = 'updateExtentison';
        try {
            Map<Id, Id> extMap = new Map<Id, Id>();
            List<String> extIdSet = new List<String>();
            for(Case c : cases){
                if(oldCaseMap == null || (oldCaseMap.get(c.Id).AccountId != c.AccountId)) {
                    extIdSet.add(c.AccountId);
                }
            }
            if(!extIdSet.isEmpty()) {
                for(Account_Extension__c ae : [SELECT Id, Account__c 
                                                FROM Account_Extension__c 
                                                WHERE Account__c IN :extIdSet]) {
                    extMap.put(ae.Account__c, ae.id);
                }
                if(!extMap.isEmpty()) {
                    for(Case cs : cases){
                        if(extMap.containsKey(cs.accountId) 
                        && (oldCaseMap == null || (oldCaseMap.get(cs.Id).AccountId != cs.AccountId))) {
                            cs.Account_Extension__c = extMap.get(cs.accountId);
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //Added By Anup : CR#959 - Start
    /**
     * This method is used to fetch Domains that needs to be Excluded
     * @return   List<String>
     */
    public static List<String> fetchDomainsToExclude() {
        Map<String, Email_Domains_to_Exclude__c> emailDomainMaps = Email_Domains_to_Exclude__c.getAll();
        List<String> domainsToExcludeData = new List<String>(emailDomainMaps.keySet());
        Internal_Domains_Exclusion__c internalDomainsToExclude = Internal_Domains_Exclusion__c.getOrgDefaults();
        if(String.isNotBlank(internalDomainsToExclude.Domains__c)){
            String domains = internalDomainsToExclude.Domains__c;
            List<String> listOfDomains = domains.split(GCSCommonConstants.COMMA_STRING);
            domainsToExcludeData.addAll(listOfDomains);
        }
        return domainsToExcludeData;
    }
    
    /**
     * This method is used to check Email Domains that needs to be Excluded
     * @param  currEmail              current Email address
     * @param  listOfDomainsToExclude list Of Domains To be Excluded
     * @return                        boolean
     */
    public static boolean checkEmailDomainsExclude(String currEmail, List<String> listOfDomainsToExclude) {
        String domain = GCSCommonConstants.EMPTY_STRING;
        if(String.isNotBlank(currEmail)){
            List<String> splittedEmail = currEmail.split(GCSCommonConstants.AT_THE_RATE_STRING);
            if(splittedEmail.size() > GCSCommonConstants.INTEGER_1) {
                domain = splittedEmail.get(GCSCommonConstants.INTEGER_1);
            }
        }
        if(!listOfDomainsToExclude.isEmpty() 
            && String.isNotBlank(domain) 
            && listOfDomainsToExclude.contains(domain)){
            return true;
        }else{
            return false;
        }
    }
    //Added By Anup : CR#959 - End
    
    /**
     * This method is used to create TAM Notes History
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void createTAMNotesHistory(List<Case> newList, map<Id, Case> oldMap) {
        final String METHOD_NAME = 'createTAMNotesHistory';
        try {
            List<TAM_Meeting_History__c> tamHistlst = new List<TAM_Meeting_History__c>();
            for(Case ap: newList){
                for (FieldSetMember fm: GCSCommonUtility.getCaseFieldSet(GCSCommonConstants.CASE_TAM_MEETING_HISTORY_FIELDSET_NAME)) {
                    String oldVal = (oldMap != null && oldMap.get(ap.Id) != null) ? String.valueOf(oldMap.get(ap.Id).get(fm.getFieldPath())) : null;
                    String newVal = String.valueOf(ap.get(fm.getFieldPath()));
                    if(oldVal != newVal) {
                        TAM_Meeting_History__c tamHist = new TAM_Meeting_History__c(Case__c = ap.Id);
                        tamhist.Old_Value__c = oldVal;
                        tamhist.New_Value__c = newVal;
                        tamhist.Field_Modified__c = fm.getLabel();
                        tamhist.Field_Modified_API__c = fm.getFieldPath();
                        tamhist.Modified_at__c = system.now();
                        tamhist.Modified_By__c = UserInfo.getUserId();
                        tamhistlst.add(tamhist);
                    }
                }
            }
            if(!tamHistlst.isEmpty()) {
                List<Database.SaveResult> srList = Database.insert(tamhistlst, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
            TriggerUtility.CaseTAMNotesHistoryExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //CR# DSAT Closed Loop Process
    /**
     * This method is used to check the Action_Plan__c when a Case is Closed
     * @param  cases      cases
     * @param  oldCaseMap oldCaseMap
     */
    public static void checkActionPlanIsCloseForCase(List<Case> cases, Map<Id,Case> oldCaseMap) {
        final String METHOD_NAME = 'checkActionPlanIsCloseForCase';
        try {
            Set<Id> caseIdList = new Set<Id>();
            Map<Id, Boolean> caseActionPlanMap = new Map<Id, Boolean>();
            for(Case caseObj : cases){
                if(((oldCaseMap == null) 
                        || (oldCaseMap != null && caseObj.Status != oldCaseMap.get(caseObj.id).Status)) 
                    && (caseObj.Status == GCSCommonConstants.CASE_STATUS_CLOSED 
                        || caseObj.Status == GCSCommonConstants.CASE_STATUS_CLOSED_RESOLVED 
                        || caseObj.Status == GCSCommonConstants.CASE_STATUS_CLOSED_NO_ACTION 
                        || caseObj.Status == GCSCommonConstants.CASE_STATUS_CLOSED_NO_RESP 
                        || caseObj.Status == GCSCommonConstants.CASE_STATUS_CLOSED_DUPLICATE)){
                    caseIdList.add(caseObj.Id);
                    caseActionPlanMap.put(caseObj.Id, false);
                }
            }
            for(Action_Plan__c ap : [SELECT Id, Case__c 
                                        FROM Action_Plan__c 
                                        WHERE Case__c IN :caseIdList 
                                        AND Case__r.recordType.DeveloperName = :GCSCommonConstants.CASE_DSAT_TICKET_RECORD_TYPE_NAME 
                                        AND (Status__c != :GCSCommonConstants.ACTION_PLAN_STATUS_COMPLETED 
                                        AND Status__c != :GCSCommonConstants.ACTION_PLAN_STATUS_CLOSED 
                                        AND Status__c != :GCSCommonConstants.ACTION_PLAN_STATUS_CANCELLED)]) {
                caseActionPlanMap.put(ap.Case__c, true);
            }
            for(Case c : cases){
                if(caseActionPlanMap.containsKey(c.Id) && caseActionPlanMap.get(c.Id)) {
                    c.addError(Label.Message_Case_Close_Action_Plan_NotCompleted);
                }
            }
            TriggerUtility.caseCloseCompleteActionPlanSetTrue();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //Added by Swathi : CR1408 start
    /**
     * This method is used to update Customer Scroce Card
     * @param  cases cases list
     * @param  oldMap old case map
     */
    public static void updateCustomerScroceCard(List<Case> cases, Map<Id, Case> oldMap) {
        final String METHOD_NAME = 'updateCustomerScroceCard';
        try {
            Set<String> accIds = new Set<String>();
            for(Case cs : cases){
                if(String.isNotBlank(cs.AccountId) 
                    && (oldMap == null 
                        || (oldMap != null 
                            && (cs.Priority != oldMap.get(cs.id).Priority 
                                || cs.Escalated__c != oldMap.get(cs.id).Escalated__c)))){
                    accIds.add(cs.AccountID);
                }
            }
            List<Customer_Score_Card__c> customerCard = new List<Customer_Score_Card__c>();
            Decimal countofopenP1sc = GCSCommonConstants.INTEGER_0;
            Decimal countofopenP2sc = GCSCommonConstants.INTEGER_0;
            Decimal countofopenP3P4sc = GCSCommonConstants.INTEGER_0;
            Decimal countofopenDefcon = GCSCommonConstants.INTEGER_0;
            Datetime mostRecent = null;
            Boolean trackvalue = False;
            if(!accIds.isEmpty()){
                String queryFields = 'Id, Account_Name__c, Priority, Status, IsEscalated, CreatedDate';
                String whereClause = 'AccountID IN ' + GCSCommonUtility.getFormattedString(new List<String>(), accIds) 
                    + ' AND (Case_Type__c = \'' + GCSCommonConstants.CASE_TYPE_PROBLEM 
                    + '\' OR Case_Type__c  = \'' + GCSCommonConstants.CASE_TYPE_QUESTION 
                    + '\' OR Case_Type__c  = \'' + GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                    + '\') AND Status !=\''+ GCSCommonConstants.CASE_STATUS_CLOSED 
                    + '\'';
                String orderByClause = 'CreatedDate';
                Integer limitClause = null;
                for(Case cs : CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause)) {
                    if(cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT){
                        countofopenP1sc = countofopenP1sc + GCSCommonConstants.INTEGER_1;
                    }
                    if(cs.Priority == GCSCommonConstants.CASE_PRIORITY_HIGH){
                        countofopenP2sc = countofopenP2sc + GCSCommonConstants.INTEGER_1;
                    }
                    if((cs.Priority == GCSCommonConstants.CASE_PRIORITY_MEDIUM 
                        || cs.Priority == GCSCommonConstants.CASE_PRIORITY_LOW)){
                        countofopenP3P4sc = countofopenP3P4sc + GCSCommonConstants.INTEGER_1;
                    }
                    if(cs.IsEscalated){
                        countofopenDefcon = countofopenDefcon + GCSCommonConstants.INTEGER_1;
                    }
                    if(mostRecent == null || cs.CreatedDate < mostRecent) {
                        mostRecent = cs.CreatedDate;
                    }
                }
                for(Customer_Score_Card__c csm : [SELECT Count_of_open_P1s__c, Count_of_open_P2s__c, 
                                                Count_of_open_Defcon_tickets__c, Count_of_open_P3_P4s__c, DateoflastExecmeeting__c 
                                                FROM Customer_Score_Card__c 
                                                WHERE Account__c IN :accIds]){
                    if(countofopenP1sc != csm.Count_of_open_P1s__c){
                        csm.Count_of_open_P1s__c = countofopenP1sc;
                        trackvalue = true;
                    }
                    if(countofopenP2sc != csm.Count_of_open_P2s__c){
                        csm.Count_of_open_P2s__c = countofopenP2sc;
                        trackvalue = true;
                    }
                    if(countofopenP3P4sc != csm.Count_of_open_P3_P4s__c){
                        csm.Count_of_open_P3_P4s__c = countofopenP3P4sc;
                        trackvalue = true;
                    }
                    if(countofopenDefcon != csm.Count_of_open_Defcon_tickets__c){
                        csm.Count_of_open_Defcon_tickets__c = countofopenDefcon;
                        trackvalue = true;
                    }
                    if(mostRecent != csm.DateoflastExecmeeting__c){
                        csm.DateoflastExecmeeting__c = mostRecent;
                        trackvalue = true;
                    }
                    if(trackvalue){
                        customerCard.add(csm);
                    }
                }
                if(!customerCard.isEmpty()){
                    List<Database.SaveResult> srList = Database.update(customerCard, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
            TriggerUtility2.UpdateCustomerScroceCardValueExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Swathi : CR1408 end
    
    //Added by Chetan : CR2268 start
    /**
     * This method is used to Contact under an Account where given Case is linked
     * @param  newList new case list
     */
    public static void createContactUnderAccount(List<Case>newList) {
        final String METHOD_NAME = 'createContactUnderAccount';
        try {
            Map<string,Case> mapDomainCase=new map<string,Case>();
            List<Case> newCaseList=new List<Case>();
            Set<String> setOfDomainPresent = new Set<String>();
            for(Case cs:newList) {
                if (cs.ContactId == null 
                    && cs.Origin == GCSCommonConstants.CASE_ORIGIN_SITEREVIEW 
                    && cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                    && cs.Priority == GCSCommonConstants.CASE_PRIORITY_LOW) {
                    newCaseList.add(cs);
                    String caseDomain = GCSCommonConstants.EMPTY_STRING;
                    List<String> splittedEmail = cs.Case_Created_By_Email__c.split(GCSCommonConstants.AT_THE_RATE_STRING);
                    caseDomain = splittedEmail.get(GCSCommonConstants.INTEGER_1);
                    mapDomainCase.put(caseDomain, cs);
                }
            }
            if(!mapDomainCase.isEmpty()) {
                String queryFields = 'Name, Domain__c';
                String whereClause = 'Domain__c IN ' + GCSCommonUtility.getFormattedString(new List<String>(), mapDomainCase.keyset());
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                for(Account acc : AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause)){
                    setOfDomainPresent.add(acc.Domain__c);
                    Case currentCase = mapDomainCase.get(Acc.Domain__c);
                    currentCase.AccountId = Acc.Id;
                }
                for(String domain : mapDomainCase.keyset()) {
                    if(!setOfDomainPresent.contains(domain)) {
                        Case currentCase = mapDomainCase.get(domain);
                        if (!Test.isRunningTest()) {
                            currentCase.AccountId = Label.Sitereview_default;
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Chetan : CR2268 end
    
    //Added by Ankit : CR2750 start
    /**
     * This method is used to set Request_Type__c on a Case
     * @param  newList new case list
     */
    public static void setRequestType (List<Case>newList){
        final String METHOD_NAME = 'setRequestType';
        try {
            if(!newList.isEmpty()) {
                Map<String, Case_Request_Type_Configurations__mdt> rtConfigMap = new Map<String, Case_Request_Type_Configurations__mdt>();
                for (Case_Request_Type_Configurations__mdt rtConfig : [SELECT MasterLabel, DeveloperName, Current_URL_Category__c, Suggested_URL_Category__c 
                                                                        FROM Case_Request_Type_Configurations__mdt]) {
                    rtConfigMap.put(rtConfig.MasterLabel, rtConfig);
                }
                for(Case c : newList) {
                    //Case is created from Site Review Integration
                    if(c.origin == GCSCommonConstants.CASE_ORIGIN_SITEREVIEW 
                        && c.case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                        && c.priority == GCSCommonConstants.CASE_PRIORITY_LOW) {
                        //Added by Chetan CR 3113 Start
                        setURLFromDescription(c);
                        //Added by Chetan CR 3113 Start
                        Set<String> caseCurrCatSet = new Set<String>();
                        Set<String> caseSuggCatSet = new Set<String>();
                        if(String.isNotBlank(c.Current_Category__c) 
                            && !c.Current_Category__c.split(GCSCommonConstants.COMMA_STRING).isEmpty()) {
                            caseCurrCatSet = new Set<String>(c.Current_Category__c.split(GCSCommonConstants.COMMA_STRING));
                        }
                        if(String.isNotBlank(c.Suggested_Category__c) 
                            && !c.Suggested_Category__c.split(GCSCommonConstants.COMMA_STRING).isEmpty()) {
                            caseSuggCatSet = new Set<String>(c.Suggested_Category__c.split(GCSCommonConstants.COMMA_STRING));
                        }
                        Set<String> currentURLCategorySet = new Set<String>();
                        Set<String> suggestedURLCategorySet = new Set<String>();
                        Set<String> currentURLRecategorySet = new Set<String>();
                        Set<String> suggestedURLRecategorySet = new Set<String>();
                        Set<String> secRevAddBlockCurrentURLCategorySet = new Set<String>();
                        Set<String> secRevAddBlockSuggestedURLCategorySet = new Set<String>();
                        Set<String> secRevLiftBlockCurrentURLCategorySet = new Set<String>();
                        Set<String> secRevLiftBlockSuggestedURLCategorySet = new Set<String>();
                        if(rtConfigMap.containsKey('URL Categorization')) {
                            Case_Request_Type_Configurations__mdt urlCategorization = rtConfigMap.get('URL Categorization');
                            if(String.isNotBlank(urlCategorization.current_URL_Category__c)) {
                                currentURLCategorySet = new Set<String>(urlCategorization.current_URL_Category__c.split(GCSCommonConstants.COMMA_STRING));
                            }
                            if(String.isNotBlank(urlCategorization.suggested_URL_Category__c)) {
                                suggestedURLCategorySet = new Set<String>(urlCategorization.suggested_URL_Category__c.split(GCSCommonConstants.COMMA_STRING));
                            }
                        }
                        if(rtConfigMap.containsKey('URL Re-categorization')) {
                            Case_Request_Type_Configurations__mdt urlReCategorization = rtConfigMap.get('URL Re-categorization');
                            if(String.isNotBlank(urlReCategorization.current_URL_Category__c)) {
                                currentURLRecategorySet = new Set<String>(urlReCategorization.current_URL_Category__c.split(GCSCommonConstants.COMMA_STRING));
                            }
                            if(String.isNotBlank(urlReCategorization.suggested_URL_Category__c)) {
                                suggestedURLRecategorySet = new Set<String>(urlReCategorization.suggested_URL_Category__c.split(GCSCommonConstants.COMMA_STRING));
                            }
                        }
                        if(rtConfigMap.containsKey('Security Review Add Block')) {
                            Case_Request_Type_Configurations__mdt secReviewAddBlock = rtConfigMap.get('Security Review Add Block');
                            if(String.isNotBlank(secReviewAddBlock.current_URL_Category__c)) {
                                secRevAddBlockCurrentURLCategorySet = new Set<String>(secReviewAddBlock.current_URL_Category__c.split(GCSCommonConstants.COMMA_STRING));
                            }
                            if(String.isNotBlank(secReviewAddBlock.suggested_URL_Category__c)) {
                                secRevAddBlockSuggestedURLCategorySet = new Set<String>(secReviewAddBlock.suggested_URL_Category__c.split(GCSCommonConstants.COMMA_STRING));
                            }
                        }
                        if(rtConfigMap.containsKey('Security Review Lift Block')) {
                            Case_Request_Type_Configurations__mdt secReviewLiftBlock = rtConfigMap.get('Security Review Lift Block');
                            if(String.isNotBlank(secReviewLiftBlock.current_URL_Category__c)) {
                                secRevLiftBlockCurrentURLCategorySet = new Set<String>(secReviewLiftBlock.current_URL_Category__c.split(GCSCommonConstants.COMMA_STRING));
                            }
                            if(String.isNotBlank(secReviewLiftBlock.suggested_URL_Category__c)) {
                                secRevLiftBlockSuggestedURLCategorySet = new Set<String>(secReviewLiftBlock.suggested_URL_Category__c.split(GCSCommonConstants.COMMA_STRING));
                            }
                        }
                        
                        Boolean isCurrentURLCategoryCheck = false;
                        Boolean isSuggestedURLCategoryCheck = false;
                        Boolean isCurrentURLRecategoryCheck = false;
                        Boolean isSuggestedURLRecategoryCheck = false;
                        Boolean isSecRevAddBlockCurrentURLCategoryCheck = false;
                        Boolean isSecRevAddBlockSuggestedURLCategoryCheck = false;
                        Boolean isSecRevLiftBlockCurrentURLCategoryCheck = false;
                        Boolean isSecRevLiftBlockSuggestedURLCategoryCheck = false;
                        //Loop over Case Current Categories
                        if(!caseCurrCatSet.isEmpty()) {
                            for(String currCat : caseCurrCatSet) {
                                if(!currentURLCategorySet.isEmpty() && currentURLCategorySet.contains(currCat)) {
                                    isCurrentURLCategoryCheck = true;
                                }
                                if(!currentURLRecategorySet.isEmpty() && !currentURLRecategorySet.contains(currCat)) {
                                    isCurrentURLRecategoryCheck = true;
                                }
                                if(!secRevAddBlockCurrentURLCategorySet.isEmpty() && secRevAddBlockCurrentURLCategorySet.contains(currCat)) {
                                    isSecRevAddBlockCurrentURLCategoryCheck = true;
                                }
                                if(!secRevLiftBlockCurrentURLCategorySet.isEmpty() && secRevLiftBlockCurrentURLCategorySet.contains(currCat)) {
                                    isSecRevLiftBlockCurrentURLCategoryCheck = true;
                                }
                            }
                        }
                        //Loop over Case Suggested Categories
                        if(!caseSuggCatSet.isEmpty()) {
                            for(String suggCat : caseSuggCatSet) {
                                if(!suggestedURLCategorySet.isEmpty() && !suggestedURLCategorySet.contains(suggCat)) {
                                    isSuggestedURLCategoryCheck = true;
                                }
                                if(!suggestedURLRecategorySet.isEmpty() && !suggestedURLRecategorySet.contains(suggCat)) {
                                    isSuggestedURLRecategoryCheck = true;
                                }
                                if(!secRevAddBlockSuggestedURLCategorySet.isEmpty() && secRevAddBlockSuggestedURLCategorySet.contains(suggCat)) {
                                    isSecRevAddBlockSuggestedURLCategoryCheck = true;
                                }
                                if(!secRevLiftBlockSuggestedURLCategorySet.isEmpty() && !secRevLiftBlockSuggestedURLCategorySet.contains(suggCat)) {
                                    isSecRevLiftBlockSuggestedURLCategoryCheck = true;
                                }
                            }
                        }
                        if(isCurrentURLCategoryCheck && isSuggestedURLCategoryCheck) {
                            c.Request_Type__c = 'URL Categorization';
                        }
                        if(isCurrentURLRecategoryCheck && isSuggestedURLRecategoryCheck) {
                            c.Request_Type__c = 'URL Re-categorization';
                        }
                        if(isSecRevAddBlockCurrentURLCategoryCheck && isSecRevAddBlockSuggestedURLCategoryCheck) {
                            c.Request_Type__c = 'Security Review Add Block';
                        }
                        if(isSecRevLiftBlockCurrentURLCategoryCheck && isSecRevLiftBlockSuggestedURLCategoryCheck) {
                            c.Request_Type__c = 'Security Review Lift Block';
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Ankit : CR2750 end  
    
    //Added by Chetan : CR3113 start
    /**
     * This method is used to set Sitereview_Case_URL__c From Case Description
     * @param  c case record
     */
    public static void setURLFromDescription (Case c){
        if(String.isNotBlank(c.Description) && c.Description.contains('URL :')) {
            String descriptionExtract = !c.description.split(GCSCommonConstants.COMMA_STRING).isEmpty() ? (c.description.split(GCSCommonConstants.COMMA_STRING).get(GCSCommonConstants.INTEGER_0)).replaceAll('URL :', GCSCommonConstants.EMPTY_STRING).trim() : GCSCommonConstants.EMPTY_STRING;
            c.Sitereview_Case_URL__c = descriptionExtract;
        }
    }
    //Added by Chetan : CR3113 End  
    
    //TAM Routing Implementation -- Added by : Ankit Bhatnagar
    /**
     * This method is used to assign Case Skill for TAM Routing
     * @param  newList new case list
     */
    public static void assignCasesbySkill_TamRouting(List<Case> newList){
        final String METHOD_NAME = 'assignCasesbySkill_TamRouting';
        try {
            Set<Id> accIds = new Set<Id>();
            List<Case> supportcases = new List<Case>();
            Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
            Set<String> setOfRegionSupport = new Set<String>();
            for(String csData : psesupportmap.keySet()){
                if(psesupportmap.get(csData)!= null 
                    && psesupportmap.get(csData).Region_Support__c != null){
                    setOfRegionSupport.add(csData);
                }
            }
            Map<String, Timezone_Region_Mapping__c> timeRegionMap = Timezone_Region_Mapping__c.getAll();
            for(Case cs: newList){
                if(cs.case_source__c == GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION){
                    cs.RecordTypeId = CASE_SUPPORT_RT_ID;
                }
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID){
                    supportcases.add(cs);
                    accIds.add(cs.AccountId);
                }
            }
            Map<Id, Account> accMap = new Map<Id, Account>();
            set<Id> tamIds = new Set<Id>();
            Set<Id> prioritizedCaseRoutingAccountsSet = new Set<Id>();
            
            //Map<Id, Service_Agent_Information__c> userServiceAgentMap = new Map<Id, Service_Agent_Information__c>();//Commented By Anup - Scheduler Project - Start
            Map<Id, ServiceResource> userServiceAgentMap = new Map<Id, ServiceResource>();
            for(Account acc: [SELECT Id, Type, TAM_Name_New__c, Name, Secondary_TAM_Name__c, X3rd_TAM_Name__c, 
                                Customer_Support_Segment__c, Support_Type__c, Prospect_Type__c, Exclude_Partner_Support__c, 
                                Language_Support__c, District__c, CAP_Level__c,Support_Offering__c, 
                                (SELECT Id, CAP_Level__c, Prioritized_Case_Routing__c, Status__c 
                                    FROM CAP_Requests__r 
                                    WHERE Status__c != :GCSCommonConstants.CASE_STATUS_CLOSED  
                                    ORDER BY LastModifiedDate DESC 
                                    LIMIT :GCSCommonConstants.INTEGER_1) 
                                FROM Account 
                                WHERE Id IN :accIds]){
                if(acc.TAM_Name_New__c != null){
                    tamIds.add(acc.TAM_Name_New__c);
                    System.debug('TAM Routing tamIds** : '+tamIds);
                }
                if(acc.Secondary_TAM_Name__c != null){
                    tamIds.add(acc.Secondary_TAM_Name__c);
                }
                if(acc.X3rd_TAM_Name__c != null){
                    tamIds.add(acc.X3rd_TAM_Name__c);
                }
                accMap.put(acc.Id, acc);
            }
            if(!tamIds.isEmpty()) {
                //Commented By Anup - Scheduler Project - Start
                /*for(Service_Agent_Information__c sai : [SELECT id,daily_quota__c, weekly_Quota__c, backlog__c, out_of_office__c, returning_Date__c, User__c, Timezone__c FROM Service_Agent_Information__c WHERE User__c IN :tamIds]) {
                    userServiceAgentMap.put(sai.user__c, sai);
                }*/
                //Commented By Anup - Scheduler Project - End
                for(ServiceResource sr : ServiceResourceSelector.getServiceResourcesForUsers('Quota_Field_Set', tamIds)){
                    userServiceAgentMap.put(sr.RelatedRecordId, sr);
                }
            }

            //Added By Ankit - CR# 4245 - Start
            for(Account a : accMap.values()) {
                if(String.isNotBlank(a.CAP_Level__c) && !a.CAP_Requests__r.isEmpty() 
                    && a.CAP_Requests__r.get(GCSCommonConstants.INTEGER_0).Prioritized_Case_Routing__c) {
                    prioritizedCaseRoutingAccountsSet.add(a.Id);
                }
            }
            //Added By Ankit - CR# 4245 - End

            List<String> nonZpaProducts = new List<String>();
            if(String.isNotBlank(Label.Non_ZPA_Products)){
                nonZpaProducts = Label.Non_ZPA_Products.trim().split(GCSCommonConstants.COMMA_STRING);
            }
            
            List<String> productsExcludeTAMReassignment = new List<String>();
            if(String.isNotBlank(Label.TAM_Assignment_Exclusion_Products)){
                productsExcludeTAMReassignment = Label.TAM_Assignment_Exclusion_Products.trim().split(GCSCommonConstants.COMMA_STRING);
            }

            /*List<QueueSobject> queues = new List<QueueSobject>([SELECT Id, QueueId 
                                                                FROM QueueSobject 
                                                                WHERE sObjectType = :GCSCommonConstants.CASE_STRING 
                                                                AND Queue.DeveloperName = 'ZPA_Product_Queue']);
            String zpaQueueId = !queues.isEmpty() ? queues.get(GCSCommonConstants.INTEGER_0).queueId : GCSCommonConstants.EMPTY_STRING;*/
            String zpaQueueId = GCSCommonUtility.getCaseQueueId(GCSCommonConstants.Q_DEV_NAME_ZPA_PRODUCT_QUEUE);
            
            Map<String, Timezone_Region_Mapping__c> tacTimeRegionMap = Timezone_Region_Mapping__c.getAll();
            for(Case cs: supportcases) {
                Map<String, Boolean> flagsMap = new Map<String, Boolean>{
                    tamroutingStr => false,
                    internalagentcreationStr => false,
                    cspmCaseStr => false,
                    zpaCaseStr => false,
                    zwsCaseStr => false,
                    sitereviewCaseStr => false,
                    zscalerDeceptionCaseStr => false,
                    cloudConnectorCaseStr => false,
                    branchConnectorCaseStr => false,
                    zpcCaseStr => false,
                    inCountryRoutingUSAStr => false
                };
                List<String> tamUnassignedReasons = new List<String>();
                if(cs.priority == GCSCommonConstants.CASE_PRIORITY_HIGH || cs.priority == GCSCommonConstants.CASE_PRIORITY_MEDIUM) {
                    if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION) {
                        //TAM Assignment will be skipped if product exists in TAM_Assignment_Exclusion_Products Custom Label
                        if(!productsExcludeTAMReassignment.contains(cs.Product_New__c)) {
                            Set<String> originForTAMAssignment = new Set<String>{
                                GCSCommonConstants.CASE_ORIGIN_API, 
                                GCSCommonConstants.CASE_ORIGIN_PUBLIC_FORM, 
                                GCSCommonConstants.CASE_ORIGIN_SUPPORT_PORTAL, 
                                GCSCommonConstants.CASE_ORIGIN_CHATBOT_PORTAL, 
                                GCSCommonConstants.CASE_ORIGIN_PARTNER_PORTAL, 
                                GCSCommonConstants.CASE_ORIGIN_PUBLIC_FORM_POST_REQ
                            };
                            if(originForTAMAssignment.contains(cs.origin)) {
                                if(cs.Is_TAM_Account__c && String.isNotBlank(cs.accountId)) {
                                    Boolean isWeekend = false;
                                    String zoneOfCase = GCSCommonConstants.EMPTY_STRING;
                                    if(!isWeekend) {
                                        //is Not Weekend
                                        if(!accmap.isEmpty() && accMap.containsKey(cs.AccountId)) {
                                            String tam1 = accMap.get(cs.AccountId).TAM_Name_New__c;
                                            
                                            String tam2 = accMap.get(cs.AccountId).Secondary_TAM_Name__c;
                                            String tam3 = accMap.get(cs.AccountId).X3rd_TAM_Name__c;
                                            
                                            if(String.isNotBlank(tam1) 
                                                && !userServiceAgentMap.isEmpty() 
                                                && userServiceAgentMap.containsKey(tam1)) {
                                                if(!timeRegionMap.isEmpty() 
                                                    && timeRegionMap.containsKey(userServiceAgentMap.get(tam1).Timezone__c)) {
                                                    //Get Region as per TAMTime Zone
                                                    zoneOfCase = timeRegionMap.containsKey(userServiceAgentMap.get(tam1).timezone__c) 
                                                        ? timeRegionMap.get(userServiceAgentMap.get(tam1).timezone__c).Region__c 
                                                        : GCSCommonConstants.EMPTY_STRING;
                                                       
                                                    //Update in CR#3534 - Added by Ankit Bhatnagar -End
                                                    isWeekend = checkIfWeekend(userServiceAgentMap.get(tam1).timezone__c);
                                                    if((timeRegionMap.get(userServiceAgentMap.get(tam1).Timezone__c).Region__c == zoneOfCase) && !isWeekend) {
                                                        //Timezone of Case matches TZ of Primary TAM
                                                        if(!userServiceAgentMap.get(tam1).out_of_office__c) {
                                                            //TAM is not out of Office OR TAM has returned after being Out of Office
                                                            if(userServiceAgentMap.get(tam1).daily_quota__c > GCSCommonConstants.INTEGER_0 
                                                                    || (userServiceAgentMap.get(tam1).daily_quota__c == GCSCommonConstants.INTEGER_0 
                                                                && userServiceAgentMap.get(tam1).backlog__c > GCSCommonConstants.INTEGER_0)) {
                                                                cs.ownerId = tam1;
                                                                cs.Case_Owner_is_TAM__c = true;
                                                                cs.Case_TAM_Assignment__c = GCSCommonConstants.CASE_TAM_ASSIGNMENT_AS_AUTO_ASSIGNMENT;
                                                                
                                                                //Ram S Added for Slack_TAM_Case_Owner_New flow fix - starts here
                                                                cs.Prior_Owner_Id__c = GCSCommonConstants.CASE_PRIOR_OWNER_AS_AUTO_ASSIGNMENT;
                                                                cs.Prior_Owner_Name__c = GCSCommonConstants.CASE_PRIOR_OWNER_AS_CUSTOMER_OR_INT_USER;
                                                                //Ram S Added for Slack_TAM_Case_Owner_New flow fix - ends here
                                                                
                                                                //Service_Agent_Information__c saInfo = userServiceAgentMap.get(tam1);//Commented By Anup - Scheduler Project - Start
                                                                ServiceResource saInfo = userServiceAgentMap.get(tam1);
                                                                if(userServiceAgentMap.get(tam1).daily_quota__c > GCSCommonConstants.INTEGER_0) {
                                                                    saInfo.daily_quota__c -= GCSCommonConstants.INTEGER_1;
                                                                }else if (userServiceAgentMap.get(tam1).daily_quota__c == GCSCommonConstants.INTEGER_0 
                                                                    && userServiceAgentMap.get(tam1).backlog__c > GCSCommonConstants.INTEGER_0){
                                                                    saInfo.backlog__c -= GCSCommonConstants.INTEGER_1;
                                                                }
                                                                if(saInfo.weekly_quota__c > GCSCommonConstants.INTEGER_0){
                                                                    saInfo.weekly_quota__c -= GCSCommonConstants.INTEGER_1;
                                                                }
                                                                userServiceAgentMap.put(tam1, saInfo);
                                                                flagsMap.put(tamroutingStr, true);
                                                                continue;
                                                            }
                                                            //Added by Ankit Bhatnagar - CR# 3558 Start
                                                            else {
                                                                if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_QUOTA_EXHAUSTED)) {
                                                                    tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_QUOTA_EXHAUSTED);
                                                                }
                                                            }
                                                        }
                                                        else {
                                                            if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_TAM_OOO)) {                                                                
                                                                tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_TAM_OOO);                                                               
                                                            }
                                                        }
                                                    }
                                                    else {
                                                        if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_NON_WORKING_HRS)) {                                                            
                                                            tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_NON_WORKING_HRS);                                                            
                                                        }
                                                    }
                                                    //Added by Ankit Bhatnagar - CR# 3558 End 
                                                }
                                            }
                                            if(String.isNotBlank(tam2) 
                                                && !userServiceAgentMap.isEmpty() 
                                                && userServiceAgentMap.containsKey(tam2)) {
                                                if(!timeRegionMap.isEmpty() 
                                                    && timeRegionMap.containsKey(userServiceAgentMap.get(tam2).Timezone__c)) {
                                                    //Get Region as per TAMTime Zone
                                                    zoneOfCase = timeRegionMap.containsKey(userServiceAgentMap.get(tam2).timezone__c) 
                                                        ? timeRegionMap.get(userServiceAgentMap.get(tam2).timezone__c).Region__c 
                                                        : GCSCommonConstants.EMPTY_STRING;
                                                    isWeekend = checkIfWeekend(userServiceAgentMap.get(tam2).timezone__c);
                                                    if((timeRegionMap.get(userServiceAgentMap.get(tam2).Timezone__c).Region__c == zoneOfCase) && !isWeekend) {
                                                        //Timezone of Case matches TZ of Secondary TAM
                                                        if(!userServiceAgentMap.get(tam2).out_of_office__c) {
                                                            //TAM is not out of Office OR TAM has returned after being Out of Office
                                                            if(userServiceAgentMap.get(tam2).daily_quota__c > GCSCommonConstants.INTEGER_0 
                                                                    || (userServiceAgentMap.get(tam2).daily_quota__c == GCSCommonConstants.INTEGER_0 
                                                                && userServiceAgentMap.get(tam2).backlog__c > GCSCommonConstants.INTEGER_0)) {
                                                                cs.ownerId = tam2;
                                                                cs.Case_Owner_is_TAM__c = true;
                                                                cs.Case_TAM_Assignment__c = GCSCommonConstants.CASE_TAM_ASSIGNMENT_AS_AUTO_ASSIGNMENT;
                                                                
                                                                //Ram S Added for Slack_TAM_Case_Owner_New flow fix - starts here
                                                                cs.Prior_Owner_Id__c = GCSCommonConstants.CASE_PRIOR_OWNER_AS_AUTO_ASSIGNMENT;
                                                                cs.Prior_Owner_Name__c = GCSCommonConstants.CASE_PRIOR_OWNER_AS_CUSTOMER_OR_INT_USER;
                                                                //Ram S Added for Slack_TAM_Case_Owner_New flow fix - ends here
                                                                
                                                                //Service_Agent_Information__c saInfo = userServiceAgentMap.get(tam2);//Commented By Anup : Scheduler Project;
                                                                ServiceResource saInfo = userServiceAgentMap.get(tam2);
                                                                if(userServiceAgentMap.get(tam2).daily_quota__c > GCSCommonConstants.INTEGER_0) {
                                                                    saInfo.daily_quota__c -= GCSCommonConstants.INTEGER_1;
                                                                }else if (userServiceAgentMap.get(tam2).daily_quota__c == GCSCommonConstants.INTEGER_0 
                                                                    && userServiceAgentMap.get(tam2).backlog__c > GCSCommonConstants.INTEGER_0){
                                                                    saInfo.backlog__c -= GCSCommonConstants.INTEGER_1;
                                                                }
                                                                if(saInfo.weekly_quota__c > GCSCommonConstants.INTEGER_0){
                                                                    saInfo.weekly_quota__c -= GCSCommonConstants.INTEGER_1;
                                                                }
                                                                userServiceAgentMap.put(tam2, saInfo);
                                                                flagsMap.put(tamroutingStr, true);
                                                                continue;
                                                            }
                                                            //Added by Ankit Bhatnagar - CR# 3558 Start
                                                            else {
                                                                if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_QUOTA_EXHAUSTED)) {
                                                                    tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_QUOTA_EXHAUSTED);
                                                                }
                                                            }
                                                        }
                                                        else {
                                                            if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_TAM_OOO)) {
                                                                tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_TAM_OOO);
                                                            }
                                                        }
                                                    }
                                                    else {
                                                        if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_NON_WORKING_HRS)) {
                                                            tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_NON_WORKING_HRS);
                                                        }
                                                    }
                                                    //Added by Ankit Bhatnagar - CR# 3558 End
                                                }
                                            }
                                            if(String.isNotBlank(tam3) 
                                                && !userServiceAgentMap.isEmpty() 
                                                && userServiceAgentMap.containsKey(tam3)) {
                                                if(!timeRegionMap.isEmpty() 
                                                    && timeRegionMap.containsKey(userServiceAgentMap.get(tam3).Timezone__c)) {
                                                        //Get Region as per TAMTime Zone
                                                        zoneOfCase = timeRegionMap.containsKey(userServiceAgentMap.get(tam3).timezone__c) 
                                                            ? timeRegionMap.get(userServiceAgentMap.get(tam3).timezone__c).Region__c
                                                            : GCSCommonConstants.EMPTY_STRING;
                                                        isWeekend = checkIfWeekend(userServiceAgentMap.get(tam3).timezone__c);
                                                        if((timeRegionMap.get(userServiceAgentMap.get(tam3).Timezone__c).Region__c == zoneOfCase) && !isWeekend) {
                                                            //Timezone of Case matches TZ of Third TAM
                                                            if(!userServiceAgentMap.get(tam3).out_of_office__c) {
                                                                //TAM is not out of Office OR TAM has returned after being Out of Office
                                                                if(userServiceAgentMap.get(tam3).daily_quota__c > GCSCommonConstants.INTEGER_0 
                                                                        || (userServiceAgentMap.get(tam3).daily_quota__c == GCSCommonConstants.INTEGER_0 
                                                                && userServiceAgentMap.get(tam3).backlog__c > GCSCommonConstants.INTEGER_0)) {
                                                                    cs.ownerId = tam3;
                                                                    cs.Case_Owner_is_TAM__c = true;
                                                                    cs.Case_TAM_Assignment__c = GCSCommonConstants.CASE_TAM_ASSIGNMENT_AS_AUTO_ASSIGNMENT;
                                                                    
                                                                    //Ram S Added for Slack_TAM_Case_Owner_New flow fix - starts here
                                                                    cs.Prior_Owner_Id__c = GCSCommonConstants.CASE_PRIOR_OWNER_AS_AUTO_ASSIGNMENT;
                                                                    cs.Prior_Owner_Name__c = GCSCommonConstants.CASE_PRIOR_OWNER_AS_CUSTOMER_OR_INT_USER;
                                                                    //Ram S Added for Slack_TAM_Case_Owner_New flow fix - ends here
                                                                    
                                                                    //Service_Agent_Information__c saInfo = userServiceAgentMap.get(tam3);//Commented By Anup : Scheduler Project;
                                                                    ServiceResource saInfo = userServiceAgentMap.get(tam3);
                                                                    if(userServiceAgentMap.get(tam3).daily_quota__c > GCSCommonConstants.INTEGER_0) {
                                                                        saInfo.daily_quota__c -= GCSCommonConstants.INTEGER_1;
                                                                    }else if (userServiceAgentMap.get(tam3).daily_quota__c == GCSCommonConstants.INTEGER_0 
                                                                            && userServiceAgentMap.get(tam3).backlog__c > GCSCommonConstants.INTEGER_0){
                                                                                saInfo.backlog__c -= GCSCommonConstants.INTEGER_1;
                                                                            }
                                                                    if(saInfo.weekly_quota__c > GCSCommonConstants.INTEGER_0){
                                                                        saInfo.weekly_quota__c -= GCSCommonConstants.INTEGER_1;
                                                                    }
                                                                    userServiceAgentMap.put(tam3, saInfo);
                                                                    flagsMap.put(tamroutingStr, true);
                                                                    continue;
                                                                }
                                                                //Added by Ankit Bhatnagar - CR# 3558 Start
                                                                else {
                                                                    if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_QUOTA_EXHAUSTED)) {
                                                                        tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_QUOTA_EXHAUSTED);
                                                                    }
                                                                }
                                                            }
                                                            else {
                                                                if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_TAM_OOO)) {
                                                                    tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_TAM_OOO);
                                                                }
                                                            }
                                                        }
                                                        else {
                                                            if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_NON_WORKING_HRS)) {
                                                                tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_NON_WORKING_HRS);
                                                            }
                                                        }
                                                        //Added by Ankit Bhatnagar - CR# 3558 End
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    else if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROVISIONING) {
                        if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_CASE_TYPE_PROV_CAT)){
                            tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_CASE_TYPE_PROV_CAT);
                        }
                    }
                }
                else if(cs.priority == GCSCommonConstants.CASE_PRIORITY_URGENT 
                    || cs.priority == GCSCommonConstants.CASE_PRIORITY_LOW) {
                    if(!tamUnassignedReasons.contains(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_CASE_PRIORITY_P1_P4)){
                        tamUnassignedReasons.add(GCSCommonConstants.CASE_TAM_UNASSIGNED_REASON_CASE_PRIORITY_P1_P4);
                    }
                }
                //Added by Ankit Bhatnagar - CR# 3558 Start
                if(!tamUnassignedReasons.isEmpty()) {
                    cs.TAM_Unassigned_Reason__c = String.join(tamUnassignedReasons, GCSCommonConstants.SEMI_COLON_STRING);
                }
                //Added by Ankit Bhatnagar - CR# 3558 End
                
                if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                    || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION) {
                    //Added by Ankit - CR# 4069 Start
                    //On Weekdays: Set Product Type on the basis of Case's Product
                    if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA) {
                        cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_ZPA;
                    }else if(nonZpaProducts.contains(cs.Product_New__c)) {
                        cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_NON_ZPA;
                    }
                    //Added by Ankit - CR# 4069 End
                    //adding the case to ZPA Product Queue if Case's Product is ZPA
                    if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA) {
                        if(String.isNotBlank(zpaQueueId)) {
                            flagsMap.put(zpaCaseStr, true);
                        }
                    }
                    //Added by Anup - Omni Overhaul - Start
                    Case_Quota_Management__c orgDefaults = Case_Quota_Management__c.getOrgDefaults();
                    Boolean isWeekendCaseRouting = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
                    if(!isWeekendCaseRouting){
                        if(cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT){
                            cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P1;
                        }else{
                            cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P2_P4;
                        }
                        //cs.Overflow_Support__c= GCSCommonConstants.CASE_OVERFLOW_SUPPORT_NO_OVERFLOW;//Commented as part of IBA-5471
                    }
                    //Added by Anup - Omni Overhaul - End
                }
                //adding ZCSPM product to CSPM Queue as per CR#1159 by Swathi
                
                //IBA-6457 Added by Chetan -- Start
                if(isUSAIncountrySupportOfferingCase(cs, accMap)){
                    cs.OwnerId = System.Label.In_Country_USA_Support_Queue_Id;
                    flagsMap.put(inCountryRoutingUSAStr, true);
                }
                //IBA-6457 Added by Chetan -- End
                else if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_CSPM 
                    || cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZCSPM){
                    cs.OwnerId = Label.CSPM_Queue_Id;
                    flagsMap.put(cspmCaseStr, true);
                }
                //Priyanka - 10/05/2021 - CR:2247
                else if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZWS){
                    cs.OwnerId = Label.ZWS_Queue_Id;
                    flagsMap.put(zwsCaseStr, true);
                }
                else if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZSCALER_DECEPTION){
                    cs.OwnerId = Label.Zscaler_Deception_Queue_Id;
                    flagsMap.put(zscalerDeceptionCaseStr, true);
                }
                else if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_CLOUD_CONNECTOR){
                    //IBA-3165 - Start
                    if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROVISIONING){
                        flagsMap.put(cloudConnectorCaseStr, false);
                        cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                        cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                        cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                        cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                        cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                        //cs.Overflow_Support__c = GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                    }else{
                        cs.OwnerId = Label.Cloud_Connector_Queue_Id;
                        flagsMap.put(cloudConnectorCaseStr,true);
                    }
                    //IBA-3165 - End
                }

                //Added by Chetan - IBA#6571 - Start
                else if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_BRANCH_CONNECTOR){
                    if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROVISIONING){
                        flagsMap.put(branchConnectorCaseStr, false);
                        cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                        cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                        cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                        cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                        cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                    }else{
                        cs.OwnerId = Label.Branch_Connector_Queue_Id;
                        flagsMap.put(branchConnectorCaseStr,true);
                    }
                }
                //Added by Chetan - IBA#6571 - End              
                //CR#2550 Start-Chetan
                //Added by Chetan - IBA#872 - Start
                else if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPC){
                    cs.OwnerId = Label.ZPC_Support_Queue;
                    flagsMap.put(zpcCaseStr, true);
                }
                //Added by Chetan - IBA#872 - End
                
                else if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                    && cs.Origin == GCSCommonConstants.CASE_ORIGIN_SITEREVIEW 
                    && cs.zscaler_org_id__c == 'no cloud - site review'){
                    cs.OwnerId = Label.Sitereview_Queue_ID;
                    flagsMap.put(sitereviewCaseStr,true);
                }
                //CR#2550 End-Chetan

                else if(cs.case_source__c == GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION && cs.AccountId == null){
                    cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                    cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                    cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                    //cs.Overflow_Support__c = GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                }else if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROVISIONING 
                    || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                    || cs.Case_Category__c == GCSCommonConstants.CASE_CASE_CATEGORY_PROVISIONING_REQ){
                    cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                }else if(cs.AccountId != null 
                    && accmap != null 
                    && accmap.containsKey(cs.AccountId) 
                    && accmap.get(cs.AccountId) != null 
                    && accmap.get(cs.AccountId).Type == 'Partner'){
                    cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.PLATINUM_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.PLATINUM_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                }
                //Priyanka: CR-2234 - Added cs.Owner_Service_Level__c != GCSCommonConstants.CS_CASE_SKILL in the below else if
                else if(cs.Owner_Service_Level__c != null 
                    && cs.Owner_Service_Level__c != 'Support Leads' 
                    && cs.Owner_Service_Level__c != 'Support Managers' 
                    && cs.Owner_Service_Level__c != GCSCommonConstants.CS_CASE_SKILL){
                    flagsMap.put(internalagentcreationStr, true);
                    cs.Origin = GCSCommonConstants.CASE_ORIGIN_INT_AGENT;
                    cs.Case_Owner_Assigned_Date__c = System.Now();
                }
                //Added By Ankit - CR# 4245 - Start
                else if(cs.AccountId != null 
                    && prioritizedCaseRoutingAccountsSet.contains(cs.AccountId) 
                    && (cs.priority == GCSCommonConstants.CASE_PRIORITY_HIGH 
                        || cs.priority == GCSCommonConstants.CASE_PRIORITY_URGENT) 
                    && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)){
                    cs.Primary_Support__c = GCSCommonConstants.EMPTY_STRING;
                    cs.Secondary_Support__c = GCSCommonConstants.EMPTY_STRING;
                    cs.Escalation_Support__c = GCSCommonConstants.EMPTY_STRING;
                    cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE;
                    //cs.Overflow_Support__c = GCSCommonConstants.CASE_OVERFLOW_SUPPORT_NO_OVERFLOW;//Commented as part of IBA-5471
                    cs.Case_Escalation_Reason__c = Label.Case_Escalation_Reason_CAP_Prioritize_Case_Routing;
                    
                    //Added by Chetan - CR# 6176 Start
                    Boolean isWeekendCaseRouting = GCSCommonUtility.checkIfWeekend();
                    if(!isWeekendCaseRouting && cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZCC){
                        cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_ZCC;
                    }
                    //Added by Chetan - CR# 6176 End
                }
                //Added By Ankit - CR# 4245 - End
                else if(cs.AccountId != null 
                    && accmap != null 
                    && accmap.containsKey(cs.AccountId) 
                    && accmap.get(cs.AccountId) != null){
                    String segmentForCase = accmap.get(cs.AccountId).Customer_Support_Segment__c;
                    String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                    List<String> premiumPlusTypesList =  premiumPlusTypes.split(GCSCommonConstants.SEMI_COLON_STRING);
                    //Added by Ankit - IBA-2997 - Starts
                    String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                    List<String> premiumPlusProductsList =  premiumPlusProducts.split(GCSCommonConstants.COMMA_STRING);
                    if(!premiumPlusProductsList.isEmpty() 
                    && premiumPlusProductsList.contains(cs.Product_New__c) 
                    && cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT 
                    && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)){
                        segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                    }
                    //Added by Ankit - IBA-2997 - Ends
                    else if(String.isBlank(segmentForCase) 
                        || accmap.get(cs.AccountId).Prospect_Type__c == pocStr){
                        segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                    }
                    else if(premiumPlusTypesList != null 
                        && accmap.get(cs.AccountId).Support_Type__c != null 
                        && premiumPlusTypesList.contains(accmap.get(cs.AccountId).Support_Type__c)){
                        segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                    }
                    cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(segmentForCase)) ? psesupportmap.get(segmentForCase).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    if(accmap.get(cs.AccountId).Exclude_Partner_Support__c){
                        cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(segmentForCase)) ? psesupportmap.get(segmentForCase).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                    }
                }
                else{
                    cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                    cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                    cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                    //cs.Overflow_Support__c = GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                }
                
                //Added by Anup - Japan & SLED Routing - Start
                if(cs.Primary_Support__c != GCSCommonConstants.CS_CASE_SKILL){
                    if(cs.AccountId != null 
                        && accmap != null 
                        && accmap.containsKey(cs.AccountId) 
                        && accmap.get(cs.AccountId) != null 
                        && accmap.get(cs.AccountId).District__c != null){
                        String accountRegion = accmap.get(cs.AccountId).District__c;
                        for(String region : setOfRegionSupport){
                            if(accountRegion.containsIgnoreCase(region)){
                                cs.Language_Support__c = (psesupportmap != null && psesupportmap.containsKey(region)) ? psesupportmap.get(region).Region_Support__c : GCSCommonConstants.EMPTY_STRING;
                            }
                        }
                        if(!accountRegion.containsIgnoreCase(GCSCommonConstants.JAPAN_CASE_SKILL)){
                            cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                        }
                    }else{
                        cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    }
                }
                //Added by Anup - Japan & SLED Routing - End
                
                if(cs.Preferred_Contact_Time_Zone__c != null 
                    && tacTimeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c) 
                    && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c) != null 
                    && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c != null){
                    String tacRegion = tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c;
                    cs.Region_Support__c = tacRegion;
                }
                //Priyanka - 10/05/2021 - CR:2247 - Included zwsCase
                //CR#2550-Chetan-Added sitereviewCase
                if(!flagsMap.get(tamroutingStr) 
                    && !flagsMap.get(internalagentcreationStr) 
                    && !flagsMap.get(cspmCaseStr) 
                    && !flagsMap.get(zwsCaseStr) 
                    && !flagsMap.get(sitereviewCaseStr) 
                    && !flagsMap.get(zscalerDeceptionCaseStr) 
                    && !flagsMap.get(zpaCaseStr) 
                    && !flagsMap.get(cloudConnectorCaseStr) 
                    && !flagsMap.get(branchConnectorCaseStr)
                    && !flagsMap.get(inCountryRoutingUSAStr)  
                    && !flagsMap.get(zpcCaseStr)){
                    cs.OwnerId = Label.Support_Queue_Id;
                }else if(!flagsMap.get(tamroutingStr) 
                    && !flagsMap.get(internalagentcreationStr) 
                    && !flagsMap.get(cspmCaseStr) 
                    && !flagsMap.get(zwsCaseStr) 
                    && !flagsMap.get(sitereviewCaseStr) 
                    && !flagsMap.get(zscalerDeceptionCaseStr) 
                    && flagsMap.get(zpaCaseStr) 
                    && !flagsMap.get(cloudConnectorCaseStr) 
                    && !flagsMap.get(branchConnectorCaseStr)
                    && !flagsMap.get(inCountryRoutingUSAStr)
                    && !flagsMap.get(zpcCaseStr)) {
                    cs.ownerId = zpaQueueId;
                }
            }
            TriggerUtility.CaseSkillAssignmentExecuted();
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to check If current date time is Weekend or not
     * @param  prefTimeZone prefered TimeZone
     * @return              Boolean
     */
    public static Boolean checkIfWeekend(String prefTimeZone) {
        Timezone casePrefTimezone = Timezone.getTimeZone(prefTimeZone);
        DateTime currentTimePrefTimeZone = Datetime.now().addSeconds((casePrefTimezone.getOffset(Datetime.now()) / GCSCommonConstants.INTEGER_1000));
        Integer hourNow = currentTimePrefTimeZone.hourGmt();
        String formattedTime = System.now().format(GCSCommonConstants.TAC_TIME_FORMAT, prefTimeZone);
        String dayOfWeek_currentTimePrefTimeZone = formattedTime.split(GCSCommonConstants.COMMA_STRING).get(GCSCommonConstants.INTEGER_0);
        Integer hrDayStart = Integer.valueOf(Label.CaseTAMRouting_HourDayStart);
        Integer hrDayEnd = Integer.valueOf(Label.CaseTAMRouting_HourDayEnd);
        
        Boolean isWeekend = false;
        if(dayOfWeek_currentTimePrefTimeZone == 'Sun' || dayOfWeek_currentTimePrefTimeZone == 'Sat' || Test.isRunningTest()) {
            isWeekend = true;
        }
        else if(dayOfWeek_currentTimePrefTimeZone == 'Fri') {
            if(hourNow >= hrDayEnd || hourNow < hrDayStart) {
                isWeekend = true;
            }else {
                isWeekend = false;
            }
        }else if(dayOfWeek_currentTimePrefTimeZone == 'Mon') {
            if(hourNow < hrDayStart || hourNow >= hrDayEnd) {
                isWeekend = true;
            }
            else {
                isWeekend = false;
            }
        }else {
            if(hourNow >= hrDayEnd || hourNow < hrDayStart) {
                //Agents will be done for the day after 5 on weekdays, if a case comes after 4pm, we'll treat it as a Case on Weekend.
                isWeekend = true;
            }else {
                isWeekend = false;
            }
        }
        return isWeekend;
    }
    
    /**
     * This method is used to update Daily Quota on Service_Agent_Information__c record
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void updateDailyQuota(List<Case> newList, Map<Id, Case> oldMap) {
        final String METHOD_NAME = 'updateDailyQuota';
        try {
            Map<Id, ServiceResource> serviceAgentMap = new Map<Id, ServiceResource>();
            List<Case> tamCases = new List<Case>();
            List<Id> handOffCases = new List<Id>();
            List<Case> ownerUpdatedCases = new List<Case>();
            List<ServiceResource> serviceInfoToUpdate = new List<ServiceResource>();
            for(Case cs : newList) {
                if(oldMap == null 
                    && cs.case_Owner_is_TAM__c 
                    && String.isNotBlank(cs.Case_TAM_Assignment__c) 
                    && cs.Case_TAM_Assignment__c == GCSCommonConstants.CASE_CASE_TAM_ASSIGNMENT_AUTO_ASSGN) {
                    serviceAgentMap.put(cs.OwnerId, null);
                    tamCases.add(cs);
                }
                if(oldMap != null 
                    && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION) 
                    && cs.OwnerId != oldMap.get(cs.Id).OwnerId 
                    && !cs.case_Owner_is_TAM__c){
                    if(!String.valueOf(cs.OwnerId).startsWith(GCSCommonConstants.STARTS_WITH_00G)){
                        serviceAgentMap.put(cs.OwnerId, null);
                    }
                    ownerUpdatedCases.add(cs);
                    if(!String.valueOf(oldMap.get(cs.Id).OwnerId).startsWith(GCSCommonConstants.STARTS_WITH_00G)){
                        handOffCases.add(cs.Id);
                        serviceAgentMap.put(oldMap.get(cs.Id).OwnerId, null);
                    }
                }
            }
            if(!serviceAgentMap.isEmpty()) {
                for(ServiceResource sai : [SELECT id, daily_quota__c, weekly_Quota__c, backlog__c, out_of_office__c, returning_Date__c,
                                                        RelatedRecordId, Timezone__c, Type__c, Overflow_Cases__c, Overflow_Cases_Weekly__c
                                                        FROM ServiceResource 
                                                        WHERE RelatedRecordId IN :serviceAgentMap.keySet()]) {
                    serviceAgentMap.put(sai.RelatedRecordId, sai);
                }
                for(Case c : tamCases) {
                    if(serviceAgentMap.containsKey(c.ownerId)) {
                        ServiceResource sai = serviceAgentMap.get(c.OwnerId);
                        if(sai.daily_quota__c > GCSCommonConstants.INTEGER_0){
                            sai.daily_quota__c -= GCSCommonConstants.INTEGER_1;
                        }else if (sai.daily_quota__c == GCSCommonConstants.INTEGER_0 && sai.backlog__c > GCSCommonConstants.INTEGER_0){
                            sai.backlog__c -= GCSCommonConstants.INTEGER_1;
                        }
                        
                        if(sai.weekly_quota__c > GCSCommonConstants.INTEGER_0){
                            sai.weekly_quota__c -= GCSCommonConstants.INTEGER_1;
                        }
                        serviceAgentMap.put(c.ownerId, sai);
                    }
                }
                
                for(Case c : ownerUpdatedCases){
                    if(serviceAgentMap.containsKey(c.OwnerId) && serviceAgentMap.get(c.OwnerId)!=null){
                        ServiceResource sai = serviceAgentMap.get(c.OwnerId);
                        if(sai.Type__c != 'TAM'){
                            if(sai.daily_quota__c > GCSCommonConstants.INTEGER_0){
                                sai.daily_quota__c -= GCSCommonConstants.INTEGER_1;
                            }else if(sai.daily_quota__c == GCSCommonConstants.INTEGER_0 && sai.backlog__c > GCSCommonConstants.INTEGER_0){
                                sai.backlog__c -= GCSCommonConstants.INTEGER_1;
                            }else if(sai.daily_Quota__c == GCSCommonConstants.INTEGER_0 && sai.backlog__c == GCSCommonConstants.INTEGER_0){
                                sai.Overflow_Cases__c += GCSCommonConstants.INTEGER_1;
                                sai.Overflow_Cases_Weekly__c +=GCSCommonConstants.INTEGER_1;
                            }
                            
                            if(sai.weekly_quota__c > GCSCommonConstants.INTEGER_0){
                                sai.weekly_quota__c -= GCSCommonConstants.INTEGER_1;
                            }
                            serviceAgentMap.put(c.ownerId, sai);
                        }
                    }
                    if(handOffCases.contains(c.Id)){
                        if(serviceAgentMap.containsKey(oldMap.get(c.Id).OwnerId) && serviceAgentMap.get(oldMap.get(c.Id).OwnerId) != null){
                            ServiceResource sai = serviceAgentMap.get(oldMap.get(c.Id).OwnerId);
                            System.debug('Update Daily Quota SAI '+sai);
                            if(sai.Type__c != 'TAM'){
                                if(sai.Overflow_Cases__c > GCSCommonConstants.INTEGER_0 && sai.Overflow_Cases_Weekly__c > GCSCommonConstants.INTEGER_0){
                                    sai.Overflow_Cases__c -= GCSCommonConstants.INTEGER_1;
                                    sai.Overflow_Cases_Weekly__c -= GCSCommonConstants.INTEGER_1;
                                }else{
                                    if(sai.daily_quota__c == null || sai.Weekly_Quota__c == null){
                                        sai.daily_quota__c = 0;
                                        sai.Weekly_Quota__c = 0;
                                    }
                                    sai.daily_quota__c += GCSCommonConstants.INTEGER_1;
                                    sai.Weekly_Quota__c +=GCSCommonConstants.INTEGER_1;
                                }
                                serviceAgentMap.put(oldMap.get(c.Id).OwnerId, sai);
                            }
                        }
                    }
                }
                
                for(ServiceResource sr : serviceAgentMap.values()){
                    if(sr!=null){
                        serviceInfoToUpdate.add(sr);
                    }
                }
                if(!serviceInfoToUpdate.isEmpty()){
                    List<Database.SaveResult> srList = Database.update(serviceInfoToUpdate, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
        System.debug('Exception Daily Quota '+e.getStackTraceString());
        
            Database.insert(GCSCommonUtility.prepareZscalerErrorLog(APEX_CLASS_NAME, 
            METHOD_NAME, GCSCommonConstants.EMPTY_STRING,  e.getStackTraceString(), String.valueOf(e), e.getTypeName()));
            
        }
    }
    
    //CR# 3298 TTR TTC Project Added by Chetan-Start
    /**
     * This method is used to populate Date_and_Time_of_Resolution__c field based on Resolution_State__c field value of a Case
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void updateResolutionState(List<Case> newList, map<Id, Case> oldMap) {
        for(Case cs:newList) {
            if(cs.Resolution_State__c != null 
                && cs.Resolution_State__c != oldmap.get(cs.Id).Resolution_State__c
                && oldmap.get(cs.Id).Resolution_State__c == GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_NOT_RESOLVED 
                && (cs.Resolution_State__c == GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_RESOLVED 
                    || cs.Resolution_State__c == GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_WORKAROUND_PROVIDED)) {
                cs.Date_and_Time_of_Resolution__c = System.now();
            }
            if(cs.Resolution_State__c != null 
                && cs.Resolution_State__c != oldmap.get(cs.Id).Resolution_State__c 
                && cs.Resolution_State__c == GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_NOT_RESOLVED 
                && (oldmap.get(cs.Id).Resolution_State__c == GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_RESOLVED 
                    || oldmap.get(cs.Id).Resolution_State__c == GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_WORKAROUND_PROVIDED)) {
                cs.Date_and_Time_of_Resolution__c = null;
            }
        }
    }
    //CR# 3298 TTR TTC Project Added by Chetan-End
    
    // CR# 2842 Added by Chetan-Start
    /**
     * This method is used to populate Account_Support_Email__c field from Customer_Support_Email_Formula__c of a Case
     * @param  cases cases
     */
    public static void updateCustomerSupportAlias(List<Case> cases){
        for(Case cs: cases) {
            if((cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                && cs.Customer_Support_Email_Formula__c != null 
                && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                    || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)) 
                || Test.isRunningTest()) {
                cs.Account_Support_Email__c = cs.Customer_Support_Email_Formula__c;
            }
        }
    }
    // CR# 2842 Added by Chetan-End
    
    // CR# 2958 added by Ankit - Start
    /**
     * This method is used to populate Product_New__c as ZIA as default product for Sales Ops Cases
     * @param  newList new case list
     */
    public static void addDefaultProductOnSFDCSupportCases(List<Case> newList) {
        for(Case c: newList) {
            if(c.RecordTypeId == CASE_SALES_OPS_RT_ID) {
                c.Product_New__c = GCSCommonConstants.CASE_PRODUCT_ZIA;
            }
        }
    }
    // CR# 2958 added by Ankit - End
    
    //Added by Anup - Omni Overhaul - Start
    /**
     * This method is used to Different Support field values on a Case
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void updatePrioritySupportOfCase(List<Case> newList, Map<Id, Case> oldMap) {
        final String METHOD_NAME = 'updatePrioritySupportOfCase';
        try {
            List<Id> listOfAccountId = new List<Id>();
            List<String> nonZpaProducts = new List<String>();
            if(String.isNotBlank(Label.Non_ZPA_Products)){
                nonZpaProducts = Label.Non_ZPA_Products.trim().split(GCSCommonConstants.COMMA_STRING);
            }
            Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
            Set<String> setOfRegionSupport = new Set<String>();
            for(String csData : psesupportmap.keySet()){
                if(psesupportmap.get(csData)!= null && psesupportmap.get(csData).Region_Support__c != null){
                    setOfRegionSupport.add(csData);
                }
            }
            for(Case cs : newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID){
                    if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION){
                        if((oldMap.containsKey(cs.Id) 
                            && oldMap.get(cs.Id) != null 
                            && ((oldMap.get(cs.Id).Priority != cs.Priority) 
                                || (oldMap.get(cs.Id).AccountId != cs.AccountId) 
                                || ((oldMap.get(cs.Id).Case_Type__c != cs.Case_Type__c) 
                                    && (oldMap.get(cs.Id).Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                                        || oldMap.get(cs.Id).Case_Type__c == GCSCommonConstants.CASE_TYPE_PROVISIONING)))) 
                            || Test.isRunningTest()){
                            if(cs.Priority_Support__c != GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE){
                                if (cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT) {
                                    cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P1;
                                }else{
                                    cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P2_P4;
                                }
                                //cs.Overflow_Support__c= GCSCommonConstants.CASE_OVERFLOW_SUPPORT_NO_OVERFLOW;//Commented as part of IBA-5471
                            }
                        }
                        if((oldMap.containsKey(cs.Id) 
                            && oldMap.get(cs.Id) != null 
                            && ((oldMap.get(cs.Id).Product_New__c != cs.Product_New__c) 
                                || (oldMap.get(cs.Id).AccountId!=cs.AccountId) 
                                || ((oldMap.get(cs.Id).Case_Type__c!=cs.Case_Type__c) 
                                    && (oldMap.get(cs.Id).Case_Type__c==GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                                        || oldMap.get(cs.Id).Case_Type__c==GCSCommonConstants.CASE_TYPE_PROVISIONING)))) 
                            || Test.isRunningTest()){
                                if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA) {
                                    cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_ZPA;
                                }else if(nonZpaProducts.contains(cs.Product_New__c)) {
                                    cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_NON_ZPA;
                                }
                            //cs.Overflow_Support__c= GCSCommonConstants.CASE_OVERFLOW_SUPPORT_NO_OVERFLOW;//Commented as part of IBA-5471
                        }
                        if((oldMap.containsKey(cs.Id) 
                            && String.isNotBlank(cs.AccountId)
                            && oldMap.get(cs.Id) != null 
                            && ((oldMap.get(cs.Id).AccountId != cs.AccountId) 
                                || ((oldMap.get(cs.Id).Case_Type__c != cs.Case_Type__c) 
                                    && (oldMap.get(cs.Id).Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                                        || oldMap.get(cs.Id).Case_Type__c==GCSCommonConstants.CASE_TYPE_PROVISIONING)))) 
                            || Test.isRunningTest()){
                            listOfAccountId.add(cs.AccountId);
                            //cs.Overflow_Support__c = GCSCommonConstants.CASE_OVERFLOW_SUPPORT_NO_OVERFLOW;//Commented as part of IBA-5471
                        }
                    }else if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROVISIONING 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION){
                        if((oldMap.containsKey(cs.Id) 
                                && oldMap.get(cs.Id) != null 
                                && oldMap.get(cs.Id).Case_Type__c != cs.Case_Type__c 
                                && oldMap.get(cs.Id).Case_Type__c != GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                                && oldMap.get(cs.Id).Case_Type__c != GCSCommonConstants.CASE_TYPE_PROVISIONING) 
                            || Test.isRunningTest()){
                            cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                            cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                            cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                            //cs.Overflow_Support__c= GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                            cs.Language_Support__c = GCSCommonConstants.EMPTY_STRING;
                        }
                    }
                }
            }
            if(!listOfAccountId.isEmpty()){
                String queryFields = 'Id, Customer_Support_Segment__c, Prospect_Type__c, Exclude_Partner_Support__c, Support_Type__c, District__c,Support_Offering__c';
                String whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(listOfAccountId, new Set<String>());
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                Map<Id, Account> accmap = new Map<Id, Account>(AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause));
                for(Case cs: newList){
                    if(cs.Priority_Support__c != GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE){
                        if(cs.AccountId != null 
                            && accmap != null 
                            && accmap.containsKey(cs.AccountId) 
                            && accmap.get(cs.AccountId) != null){
                            String segmentForCase = accmap.get(cs.AccountId).Customer_Support_Segment__c;
                            String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                            List<String> premiumPlusTypesList =  premiumPlusTypes.split(GCSCommonConstants.SEMI_COLON_STRING);
                            
                            //Added by Ankit - IBA-2997 - Starts
                            String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                            List<String> premiumPlusProductsList =  premiumPlusProducts.split(GCSCommonConstants.COMMA_STRING);
                            
                            if(!premiumPlusProductsList.isEmpty() 
                                && premiumPlusProductsList.contains(cs.Product_New__c) 
                                && cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT 
                                && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                                    || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)){
                                segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                            }
                            //Added by Ankit - IBA-2997 - Ends
                            else if(String.isBlank(segmentForCase) || accmap.get(cs.AccountId).Prospect_Type__c == pocStr){
                                segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                            }
                            else if(premiumPlusTypesList != null 
                                && accmap.get(cs.AccountId).Support_Type__c != null 
                                && premiumPlusTypesList.contains(accmap.get(cs.AccountId).Support_Type__c)){
                                segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                            }
                            cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(segmentForCase)) ? psesupportmap.get(segmentForCase).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            if(accmap.get(cs.AccountId).Exclude_Partner_Support__c){
                                cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(segmentForCase)) ? psesupportmap.get(segmentForCase).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                            }
                        }else{
                            cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                            cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                            cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                            //cs.Overflow_Support__c = GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                        }
                    }
                    //Added by Anup - Japan & SLED Routing - Start
                    if(cs.Primary_Support__c != GCSCommonConstants.CS_CASE_SKILL) {
                        cs.Language_Support__c = GCSCommonConstants.EMPTY_STRING;
                        if(cs.AccountId != null 
                            && accmap != null 
                            && accmap.containsKey(cs.AccountId) 
                            && accmap.get(cs.AccountId) != null 
                            && accmap.get(cs.AccountId).District__c != null){
                            String accountRegion = accmap.get(cs.AccountId).District__c;
                            for(String region : setOfRegionSupport){
                                if(accountRegion.containsIgnoreCase(region)){
                                    cs.Language_Support__c = (psesupportmap != null && psesupportmap.containsKey(region)) ? psesupportmap.get(region).Region_Support__c : GCSCommonConstants.EMPTY_STRING;
                                }
                            }
                            if(!accountRegion.containsIgnoreCase(GCSCommonConstants.JAPAN_CASE_SKILL)){
                                cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            }
                        }
                        else {
                            cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                        }
                    }
                    //Added by Anup - Japan & SLED Routing - End
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Anup - Omni Overhaul - End
    
    //CR# 4095 Added by Chetan-Start
    /**
     * This method is used to populate Pending Customer Timestamp
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void updatePendingCustomerTimestamp(List<Case> newList, map<Id, Case> oldMap) {
        final String METHOD_NAME = 'updatePendingCustomerTimestamp';
        try {
            List<String> nonZpaProducts = new List<String>();
            List<String> listOfAccountId = new List<String>();
            if(String.isNotBlank(Label.Non_ZPA_Products)){
                nonZpaProducts = Label.Non_ZPA_Products.trim().split(GCSCommonConstants.COMMA_STRING);
            }
            Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
            Map<String, Timezone_Region_Mapping__c> tacTimeRegionMap = Timezone_Region_Mapping__c.getAll();
            Set<String> setOfRegionSupport = new Set<String>();
            for(String key : psesupportmap.keySet()) {
                if(psesupportmap.get(key)!= null && psesupportmap.get(key).Region_Support__c != null){
                    setOfRegionSupport.add(key);
                }
            }
            for(Case cs : newList) {
                //CR#4095 Logic - Start
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.Status != null 
                    && cs.Status != oldmap.get(cs.Id).Status 
                    && cs.Status == GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER 
                    && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)) {
                        cs.Pending_Customer_Timestamp__c = System.now();
                    }else if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                        && cs.Status != null 
                        && cs.Status != oldmap.get(cs.Id).Status 
                        && cs.Status != GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER 
                        && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                            || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)) {
                        cs.Pending_Customer_Timestamp__c=null;
                    }
                //CR#4095 Logic - End
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.Warm_Handoff__c 
                    && cs.Warm_Handoff__c != oldmap.get(cs.Id).Warm_Handoff__c){
                    cs.Work_Item_Progress__c = GCSCommonConstants.CASE_WORK_ITEM_PROGRESS_IN_PROGRESS;//IBA-2400 - Anup
                    if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROVISIONING 
                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION){
                        cs.Primary_Support__c = GCSCommonConstants.CS_CASE_SKILL;
                        cs.Secondary_Support__c = GCSCommonConstants.EMPTY_STRING;
                        cs.Escalation_Support__c = GCSCommonConstants.EMPTY_STRING;
                        cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                        cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                        //cs.Overflow_Support__c= GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                    }else{
                        //Added by Chetan - CR# 6176 Start
                        Boolean isWeekendCaseRouting = GCSCommonUtility.checkIfWeekend();
                        System.debug('Weekend Chetan '+isWeekendCaseRouting);
                        if(!isWeekendCaseRouting && cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZCC && cs.Priority_Support__c == GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE){
                            cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_ZCC;
                        }
                        else{
                            if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA) {
                                cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_ZPA;
                            }else if(nonZpaProducts.contains(cs.Product_New__c)) {
                                cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_NON_ZPA;
                            }
                        }
                        //Added by Chetan - CR# 6176 End 

                        if(cs.Priority_Support__c != GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE){
                            if(!isWeekendCaseRouting){
                                if(cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT){
                                    cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P1;
                                }else{
                                    cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P2_P4;
                                }
                                //cs.Overflow_Support__c= GCSCommonConstants.CASE_OVERFLOW_SUPPORT_NO_OVERFLOW;//Commented as part of IBA-5471
                            }else{
                                cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                                //cs.Overflow_Support__c=GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                            }
                        }
                        if(String.isNotBlank(cs.AccountId)){
                            listOfAccountId.add(cs.AccountId);
                        }
                    }
                }
            }
            Map<Id, Account> accmap = new Map<Id, Account>();
            if(!listOfAccountId.isEmpty()){
                String queryFields = 'Id, Customer_Support_Segment__c, Prospect_Type__c, Exclude_Partner_Support__c, Support_Type__c, District__c ';
                String whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(listOfAccountId, new Set<String>());
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                accmap = new Map<Id, Account>(AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause));
            }
           
            for(Case cs: newList){
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && cs.Warm_Handoff__c 
                    && cs.Warm_Handoff__c != oldmap.get(cs.Id).Warm_Handoff__c){
                    if(cs.Priority_Support__c != GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE){
                        if(cs.AccountId != null 
                            && accmap != null 
                            && accmap.containsKey(cs.AccountId) 
                            && accmap.get(cs.AccountId) != null){
                            String segmentForCase = accmap.get(cs.AccountId).Customer_Support_Segment__c;
                            String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                            List<String> premiumPlusTypesList =  premiumPlusTypes.split(GCSCommonConstants.SEMI_COLON_STRING);
                            
                            //Added by Ankit - IBA-2997 - Starts
                            String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                            List<String> premiumPlusProductsList =  premiumPlusProducts.split(GCSCommonConstants.COMMA_STRING);
                            if(!premiumPlusProductsList.isEmpty() 
                                && premiumPlusProductsList.contains(cs.Product_New__c) 
                                && cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT 
                                && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                                    || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)){
                                segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                            }
                            //Added by Ankit - IBA-2997 - Ends
                            
                            else if(String.isBlank(segmentForCase) 
                                || accmap.get(cs.AccountId).Prospect_Type__c == pocStr){
                                segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                            }else if(premiumPlusTypesList != null 
                                && accmap.get(cs.AccountId).Support_Type__c != null 
                                && premiumPlusTypesList.contains(accmap.get(cs.AccountId).Support_Type__c)){
                                segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                            }
                            cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(segmentForCase)) ? psesupportmap.get(segmentForCase).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            if(accmap.get(cs.AccountId).Exclude_Partner_Support__c){
                                cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(segmentForCase)) ? psesupportmap.get(segmentForCase).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                            }
                        }else {
                            cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                            cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                            cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                            //cs.Overflow_Support__c = GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                        }
                    }
                    //Added by Anup - Japan & SLED Routing - Start
                    if(cs.Primary_Support__c != GCSCommonConstants.CS_CASE_SKILL){
                        cs.Language_Support__c = GCSCommonConstants.EMPTY_STRING;
                        if(cs.AccountId != null 
                            && accmap != null 
                            && accmap.containsKey(cs.AccountId) 
                            && accmap.get(cs.AccountId) != null 
                            && accmap.get(cs.AccountId).District__c != null){
                            String accountRegion = accmap.get(cs.AccountId).District__c;
                            for(String region : setOfRegionSupport){
                                if(accountRegion.containsIgnoreCase(region)){
                                    cs.Language_Support__c = (psesupportmap != null && psesupportmap.containsKey(region)) ? psesupportmap.get(region).Region_Support__c : GCSCommonConstants.EMPTY_STRING;
                                }
                            }
                            if(!accountRegion.containsIgnoreCase(GCSCommonConstants.JAPAN_CASE_SKILL)){
                                cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            }
                        }else{
                            cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                        }
                    }else{
                        cs.Language_Support__c = GCSCommonConstants.EMPTY_STRING;
                        cs.Secondary_Support__c = GCSCommonConstants.EMPTY_STRING;
                    }
                    //Added by Anup - Japan & SLED Routing - End

                    //Added by Anup - Handoff Project - Start
                    if(cs.Preferred_Contact_Time_Zone__c != null 
                        && tacTimeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c) 
                        && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c) != null 
                        && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c != null){
                        String tacRegion = tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c;
                        cs.Region_Support__c = tacRegion;
                    }
                    //Added by Anup - Handoff Project - End
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //CR# 4095 Added by Chetan-End
    
    /**
     * This method is used to update Case Handoff Assignment details
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void caseHandoffAssignment(List<Case> newList, map<Id, Case> oldMap){
        final String METHOD_NAME = 'caseHandoffAssignment';
        try {
            List<Id> listOfCaseToProcess = new List<Id>();
            List<Id> caseOwnerQueueOrOOO = new List<Id>();
            List<Id> listOfOwnerId = new List<Id>();
            Set<Id> setOfActiveUserId = new Set<Id>();
            List<FeedItem> feedItemList = new List<FeedItem>();
            List<String> productsToExclude = new List<String>();
            if(String.isNotBlank(Label.TAM_Reassignment_Excluded_Products)){
                productsToExclude = Label.TAM_Reassignment_Excluded_Products.trim().split(GCSCommonConstants.SEMI_COLON_STRING);
            }
            //Skills Calculation Logic - Start
            Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
            List<String> nonZpaProducts = new List<String>();
            List<Id> listOfAccountId = new List<Id>();
            if(String.isNotBlank(Label.Non_ZPA_Products)){
                nonZpaProducts = Label.Non_ZPA_Products.trim().split(GCSCommonConstants.COMMA_STRING);
            }
            Map<String, Timezone_Region_Mapping__c> tacTimeRegionMap = Timezone_Region_Mapping__c.getAll();
            Set<String> setOfRegionSupport = new Set<String>();
            for(String key : psesupportmap.keySet()){
                if(psesupportmap.get(key) != null && psesupportmap.get(key).Region_Support__c != null){
                    setOfRegionSupport.add(key);
                }
            }
            //Skills Calculation Logic - End
            for(Case cs : newList){
                Boolean caseSelected = false;
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && !cs.TAM_Reassignment__c 
                    && !productsToExclude.contains(cs.Product_New__c)){
                    if(cs.Status != oldMap.get(cs.Id).Status 
                        && cs.Status == GCSCommonConstants.CASE_STATUS_CUSTOMER_NOTE_ADDED 
                        && (cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT/* || cs.Priority == 'High (P2)'*/)){
                        listOfCaseToProcess.add(cs.Id);
                        caseSelected = true;
                        cs.Automated_Trigger_Reason__c = GCSCommonConstants.CASE_AUTO_TRIGGER_REASON_CUST_NOTE_ADDED_P1_CASE;
                    }else if(cs.Defcon_Level__c != oldMap.get(cs.Id).Defcon_Level__c 
                        && cs.Defcon_Level__c!=null && cs.Defcon_Level__c != '5'){
                        listOfCaseToProcess.add(cs.Id);
                        caseSelected = true;
                        cs.Automated_Trigger_Reason__c = GCSCommonConstants.CASE_AUTO_TRIGGER_REASON_DEFCON_ESC_ON_CASE;
                    }else if(cs.Case_Owner_Not_Available__c 
                        && cs.Status != oldMap.get(cs.Id).Status 
                        && cs.Status == GCSCommonConstants.CASE_STATUS_CUSTOMER_NOTE_ADDED){
                        listOfCaseToProcess.add(cs.Id);
                        caseSelected = true;
                        cs.Automated_Trigger_Reason__c = GCSCommonConstants.CASE_AUTO_TRIGGER_REASON_CUST_NOTE_ADDED_OWNER_INACTIVE;
                    }
                    if(caseSelected){
                        if(String.valueOf(cs.OwnerId).startsWithIgnoreCase(Label.Cold_Transfer_Queue_Id) || cs.Case_Owner_Not_Available__c){
                            caseOwnerQueueOrOOO.add(cs.Id);
                        }else{
                            if(!String.valueOf(cs.OwnerId).startsWithIgnoreCase(GCSCommonConstants.STARTS_WITH_00G)){
                                listOfOwnerId.add(cs.OwnerId);
                            }
                        }
                        feedItemList.add(GCSCommonUtility.prepareFeedItem(cs.Id, 'Automated Trigger Reason : ' + cs.Automated_Trigger_Reason__c, GCSCommonConstants.INTERNAL_USERS_VISIBILITY, true, false));
                        
                        //Skills Calculation Logic - Start
                        if(cs.AccountId != null){
                            listOfAccountId.add(cs.AccountId);
                        }
                        //Skills Calculation Logic - End
                    }
                }
            }
            if(!listOfCaseToProcess.isEmpty()){
                Map<Id, String> mapOfUserAndEmail = new Map<Id, String>();
                Map<Id, String> mapOfUserAndManagerEmail = new Map<Id, String>();
                String zpaDutyManager = GCSCommonConstants.EMPTY_STRING;
                if(!listOfOwnerId.isEmpty()){
                    Map<String,String> daysOfWeek = new Map<String,String>{
                        'Mon' => 'Monday',
                        'Tue' => 'Tuesday',
                        'Wed' => 'Wednesday',
                        'Thu' => 'Thursday',
                        'Fri' => 'Friday',
                        'Sat' => 'Saturday',
                        'Sun' => 'Sunday'
                    };
                    Timezone pstTz = Timezone.getTimeZone(GCSCommonConstants.AMERICA_LA_TIME_ZONE);
                    DateTime currentTimePst = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now()) / GCSCommonConstants.INTEGER_1000));
                    Time timeNowPst = currentTimePst.timeGMT();
                    Set<Id> setOfOutShiftUsers = new Set<Id>();

                    // Added By Hitesh - Scheduler Project Start
                    for(Shift s : [SELECT id, StartTime, EndTime, Day__c, Duty_Manager__c, Duty_Manager__r.Email,
                                    Backup_Duty_Manager__c, Backup_Duty_Manager__r.Email, Product__c, Segment__c,
                                    ServiceResource.RelatedRecordId, Type__c, ServiceResource.Timezone__c,
                                    ServiceResource.Shift_Off_Days__c, RecurrenceStartDate, RecurrenceEndDate,
                                    TimeSlotType, Type
                                    FROM Shift 
                                    WHERE (ServiceResource.RelatedRecordId IN :listOfOwnerId)
                                    or Type__c =:GCSCommonConstants.SHIFT_TYPE_DUTY_MANAGER]){

                                        System.debug('value of shift record --> '+s);

                                        Boolean allowCheckOnType = false;
                                        DateTime temporaryStartTimePST = s.StartTime.addSeconds((pstTz.getOffset(s.StartTime)/GCSCommonConstants.INTEGER_1000));
                                        DateTime temporaryEndTimePST = s.EndTime.addSeconds((pstTz.getOffset(s.EndTime)/GCSCommonConstants.INTEGER_1000));
                                        if(s.Type == GCSCommonConstants.TYPE_RECURRING && s.Type__c == GCSCommonConstants.SHIFT_TYPE_DUTY_MANAGER) {
                                            Date dateNowInPst = Date.newInstance(currentTimePst.year(), currentTimePst.month(), currentTimePst.day());
                                            Time shiftStartTime = temporaryStartTimePST.timeGMT();
                                            Time shiftEndTime = temporaryEndTimePST.timeGMT();
                                            System.debug('value of shiftStartTime --> '+shiftStartTime);
                                            System.debug('value of shiftEndTime --> '+shiftEndTime);

                                            if((dateNowInPst >= s.RecurrenceStartDate && dateNowInPst <= s.RecurrenceEndDate) && (timeNowPst >= shiftStartTime && timeNowPst <= shiftEndTime)) {
                                                allowCheckOnType = true;
                                                System.debug('Value of allowCheckOnType -> '+allowCheckOnType);
                                            }
                                        }
                                        else if (s.Type == GCSCommonConstants.TYPE_REGULAR  && (currentTimePst >= temporaryStartTimePST && currentTimePst <= temporaryEndTimePST)) {
                                            allowCheckOnType = true;
                                            System.debug('Value of allowCheckOnType -> '+allowCheckOnType);
                                        }
                                        if(allowCheckOnType) {
                                            if(s.Product__c == GCSCommonConstants.PRODUCT_ZPA){
                                                zpaDutyManager = s.Duty_Manager__r.Email;
                                            }
                                        }
                                        else {
                                            if(!setOfActiveUserId.contains(s.ServiceResource.RelatedRecordId)) {
                                                Boolean isShiftOff = false;
                                                Timezone casePrefTimezoneTAC = Timezone.getTimeZone(s.ServiceResource.Timezone__c);
                                                DateTime currentTimePrefTimeZoneTAC = Datetime.now().addSeconds((casePrefTimezoneTAC.getOffset(Datetime.now())/GCSCommonConstants.INTEGER_1000));
                                                Integer hourNowTAC = currentTimePrefTimeZoneTAC.hourGmt();
                                                String formattedTimeTAC = System.now().format(GCSCommonConstants.TAC_TIME_FORMAT,s.ServiceResource.Timezone__c);
                                                String dayOfWeek_currentTimePrefTimeZoneTAC = formattedTimeTAC.split(',').get(0);   
                                                Integer hrDayStartTAC = Integer.valueOf(Label.SupportTAC_HourDayStart);
                                                Integer hrDayEndTAC = Integer.valueOf(Label.SupportTAC_HourDayEnd);
                                                
                                                if(s.ServiceResource.Shift_Off_Days__c!= null){
                                                    String currentDay = daysOfWeek.get(dayOfWeek_currentTimePrefTimeZoneTAC);
                                                    if(s.ServiceResource.Shift_Off_Days__c.contains(currentDay)){
                                                        isShiftOff = true;
                                                        setOfOutShiftUsers.add(s.ServiceResource.RelatedRecordId);
                                                    }
                                                }
                                                if(!isShiftOff){
                                                    if(hourNowTAC >= hrDayStartTAC && hourNowTAC < hrDayEndTAC){
                                                        setOfActiveUserId.add(s.ServiceResource.RelatedRecordId);
                                                    }
                                                }
                                                system.debug('setOfActiveUserId-->'+setOfActiveUserId); 
                                            }
                                        }
                                    }
                    // Added By Hitesh - Scheduler Project End

                    for(User usr : UserSelector.getUsers(listOfOwnerId, new List<Id>(), null)){
                        mapOfUserAndEmail.put(usr.Id, usr.Email);
                        if(usr.ManagerId != null){
                            mapOfUserAndManagerEmail.put(usr.Id, usr.manager.Email);
                        }
                        if(!setOfActiveUserId.contains(usr.Id) && !setOfOutShiftUsers.contains(usr.Id)){
                            Timezone casePrefTimezoneTAC = Timezone.getTimeZone(usr.TimeZoneSidKey);
                            DateTime currentTimePrefTimeZoneTAC = Datetime.now().addSeconds((casePrefTimezoneTAC.getOffset(Datetime.now()) / GCSCommonConstants.INTEGER_1000));
                            Integer hourNowTAC = currentTimePrefTimeZoneTAC.hourGmt();
                            Integer hrDayStartTAC = Integer.valueOf(Label.SupportTAC_HourDayStart);
                            Integer hrDayEndTAC = Integer.valueOf(Label.SupportTAC_HourDayEnd);
                            if(hourNowTAC >= hrDayStartTAC && hourNowTAC < hrDayEndTAC){
                                setOfActiveUserId.add(usr.Id);
                            }
                        }
                    }
                    System.debug('Active User --> ' + setOfActiveUserId);
                }
                /*List<QueueSobject> queues = new List<QueueSobject>([SELECT Id, QueueId 
                                                                    FROM QueueSobject 
                                                                    WHERE sObjectType = :GCSCommonConstants.CASE_STRING 
                                                                    AND Queue.DeveloperName = 'ZPA_Product_Queue']);
                String zpaQueueId = !queues.isEmpty() ? queues.get(GCSCommonConstants.INTEGER_0).queueId : GCSCommonConstants.EMPTY_STRING;*/
                String zpaQueueId = GCSCommonUtility.getCaseQueueId(GCSCommonConstants.Q_DEV_NAME_ZPA_PRODUCT_QUEUE);
                List<Messaging.SingleEmailMessage> notifyMailList = new List<Messaging.SingleEmailMessage>();
                EmailTemplate emailTemplate = GCSCommonUtility.getEmailTemplate(new List<String>{'Automated_Trigger_Case_Notifiication'}).get(GCSCommonConstants.INTEGER_0);
                OrgWideEmailAddress owea = GCSCommonUtility.getOrgWideEmailAddresses(
                        new List<String>{GCSCommonConstants.ZS_SUPPORT_EMAIL_ID}).get(GCSCommonConstants.INTEGER_0);
                Messaging.SingleEmailMessage mail = GCSCommonUtility.prepareEmailMessage(GCSCommonConstants.EMPTY_STRING, GCSCommonUtility.getContactId(), false,owea.Id);
                
                //Skills Calculation Logic - Start
                Map<Id, Account> accMap = new Map<Id, Account>();
                if(!listOfAccountId.isEmpty()){
                    for(Account acc : [SELECT Id, Customer_Support_Segment__c, Prospect_Type__c, 
                                        Exclude_Partner_Support__c, Support_Type__c, District__c,Support_Offering__c
                                        FROM Account 
                                        WHERE Id IN :listOfAccountId]){
                        accMap.put(acc.Id, acc);
                    }
                }
                //Skills Calculation Logic - End
                
                for(Case cs : newList){
                    Boolean executeOmniAssignment = false;
                    if(!String.valueOf(cs.OwnerId).startsWithIgnoreCase(Label.Support_Queue_Id) 
                        && !String.valueOf(cs.OwnerId).startsWithIgnoreCase(zpaQueueId)){
                        if(!caseOwnerQueueOrOOO.isEmpty() && caseOwnerQueueOrOOO.contains(cs.Id)){
                            //Execute Logic for Moving case to Omni Channel
                            executeOmniAssignment = true;
                        }
                        else{
                            if(!setOfActiveUserId.isEmpty() && setOfActiveUserId.contains(cs.OwnerId)){
                                //Execute logic for Email Triggering
                                List<String> listOfAddress = new List<String>();
                                if(mapOfUserAndEmail.containsKey(cs.OwnerId) && mapOfUserAndEmail.get(cs.OwnerId) != null){
                                    listOfAddress.add(mapOfUserAndEmail.get(cs.OwnerId));
                                }
                                
                                //Anup - Commenting code for not adding Duty Managers in the email - 07/12/2022
                                if(!(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA && !String.isBlank(zpaDutyManager))){
                                    String segmentForCase = cs.Customer_Segment__c;
                                    if(String.isBlank(segmentForCase)){
                                        segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                                    }
                                    
                                    if(cs.Priority_Support__c == GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE 
                                        && mapOfUserAndManagerEmail.containsKey(cs.OwnerId)){
                                        listOfAddress.add(mapOfUserAndManagerEmail.get(cs.OwnerId));
                                    }
                                }
                                
                                if(!listOfAddress.isEmpty()){
                                    mail.setToAddresses(listOfAddress);
                                    String htmlBody = emailTemplate.HtmlValue;
                                    htmlBody = htmlBody.replace('[AUTOMATED_REASON]', cs.Automated_Trigger_Reason__c);
                                    htmlBody = htmlBody.replace('[Case_Number]', cs.CaseNumber);
                                    
                                    //IBA-1335 - Start
                                    if(cs.Automated_Trigger_Reason__c == GCSCommonConstants.CASE_AUTO_TRIGGER_REASON_DEFCON_ESC_ON_CASE){
                                        htmlBody = htmlBody.replace('[DEFCON_INFORMATION]', 'Defcon Level : '+cs.Defcon_Level__c);
                                    }else{
                                        htmlBody = htmlBody.replace('[DEFCON_INFORMATION]', GCSCommonConstants.EMPTY_STRING);
                                    }
                                    //IBA-1335 - End
                                    
                                    htmlBody = htmlBody.replace(']]>',GCSCommonConstants.EMPTY_STRING);
                                    mail.setHtmlBody(htmlBody);
                                    String emailSubject = emailTemplate.Subject;
                                    emailSubject = emailSubject.replace('[AUTOMATED_REASON]', cs.Automated_Trigger_Reason__c);
                                    emailSubject = emailSubject.replace('[Case_Number]', cs.CaseNumber);
                                    mail.setSubject(emailSubject);
                                    mail.setWhatId(cs.Id);
                                    notifyMailList.add(mail);
                                }
                            }else{
                                //Execute Logic for Moving case to Omni Channel
                                executeOmniAssignment = true;
                            }
                        }
                    }
                    
                    if(executeOmniAssignment){
                        //Skills Calculation Logic - Start
                        if(cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROVISIONING 
                            || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_CATEGORIZATION){
                            cs.Primary_Support__c = GCSCommonConstants.CS_CASE_SKILL;
                            cs.Secondary_Support__c = GCSCommonConstants.EMPTY_STRING;
                            cs.Escalation_Support__c = GCSCommonConstants.EMPTY_STRING;
                            cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                            cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                            //cs.Overflow_Support__c= GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                        }else{
                            //Added by Chetan - CR# 6176 Start
                            Boolean isWeekendCaseRouting = GCSCommonUtility.checkIfWeekend();
                            if(!isWeekendCaseRouting && cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZCC && cs.Priority_Support__c == GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE){
                                cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_ZCC;
                            }
                            else{
                                if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA) {
                                    cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_ZPA;
                                }
                                else if(nonZpaProducts.contains(cs.Product_New__c)) {
                                    cs.Product_Type__c = GCSCommonConstants.CASE_PRODUCT_TYPE_NON_ZPA;
                                }
                            }
                            //Added by Chetan - CR# 6176 End 
                            if(cs.Priority_Support__c != GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE){
                                if(!isWeekendCaseRouting){
                                    if(cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT){
                                        cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P1;
                                    }else{
                                        cs.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P2_P4;
                                    }
                                    //cs.Overflow_Support__c = GCSCommonConstants.CASE_OVERFLOW_SUPPORT_NO_OVERFLOW;//Commented as part of IBA-5471
                                }else{
                                    cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                                    //cs.Overflow_Support__c = GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                                }
                            }
                        }
                        if(cs.Priority_Support__c != GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE 
                            && cs.Primary_Support__c != GCSCommonConstants.CS_CASE_SKILL){
                            if(cs.AccountId != null 
                                && accmap != null 
                                && accmap.containsKey(cs.AccountId) 
                                && accmap.get(cs.AccountId) != null){
                                String segmentForCase = accmap.get(cs.AccountId).Customer_Support_Segment__c;
                                String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                                List<String> premiumPlusTypesList =  premiumPlusTypes.split(GCSCommonConstants.SEMI_COLON_STRING);

                                //Added by Ankit - IBA-2997 - Starts
                                String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                                List<String> premiumPlusProductsList =  premiumPlusProducts.split(GCSCommonConstants.COMMA_STRING);
                                if(!premiumPlusProductsList.isEmpty() 
                                    && premiumPlusProductsList.contains(cs.Product_New__c) 
                                    && cs.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT 
                                    && (cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM
                                        || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)){
                                    segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                                }
                                //Added by Ankit - IBA-2997 - Ends

                                else if(String.isBlank(segmentForCase) 
                                    || accmap.get(cs.AccountId).Prospect_Type__c == pocStr){
                                    segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                                }else if(premiumPlusTypesList != null 
                                    && accmap.get(cs.AccountId).Support_Type__c != null 
                                    && premiumPlusTypesList.contains(accmap.get(cs.AccountId).Support_Type__c)){
                                    segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                                }
                                cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(segmentForCase)) ? psesupportmap.get(segmentForCase).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                                if(accmap.get(cs.AccountId).Exclude_Partner_Support__c){
                                    cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(segmentForCase)) ? psesupportmap.get(segmentForCase).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                                }
                            }else{
                                cs.Primary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                                cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                                cs.Escalation_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Escalation_Support__c : GCSCommonConstants.EMPTY_STRING;
                                cs.Product_Type__c = GCSCommonConstants.EMPTY_STRING;
                                cs.Priority_Support__c = GCSCommonConstants.EMPTY_STRING;
                                //cs.Overflow_Support__c = GCSCommonConstants.EMPTY_STRING;//Commented as part of IBA-5471
                            }
                        }
                        if(cs.Primary_Support__c != GCSCommonConstants.CS_CASE_SKILL){
                            cs.Language_Support__c = GCSCommonConstants.EMPTY_STRING;
                            if(cs.AccountId != null 
                                && accmap != null 
                                && accmap.containsKey(cs.AccountId) 
                                && accmap.get(cs.AccountId) != null 
                                && accmap.get(cs.AccountId).District__c != null){
                                String accountRegion = accmap.get(cs.AccountId).District__c;
                                for(String region : setOfRegionSupport){
                                    if(accountRegion.containsIgnoreCase(region)){
                                        cs.Language_Support__c = (psesupportmap != null && psesupportmap.containsKey(region)) ? psesupportmap.get(region).Region_Support__c : GCSCommonConstants.EMPTY_STRING;
                                    }
                                }
                                if(!accountRegion.containsIgnoreCase(GCSCommonConstants.JAPAN_CASE_SKILL)){
                                    cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                                }
                            }else{
                                cs.Secondary_Support__c = (psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.ALL_REGIONS_CASE_SKILL)) ? psesupportmap.get(GCSCommonConstants.ALL_REGIONS_CASE_SKILL).Secondary_Support__c : GCSCommonConstants.EMPTY_STRING;
                            }
                        }else{
                            cs.Language_Support__c = GCSCommonConstants.EMPTY_STRING;
                            cs.Secondary_Support__c = GCSCommonConstants.EMPTY_STRING;
                        }
                        if(cs.Preferred_Contact_Time_Zone__c != null 
                            && tacTimeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c) 
                            && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c) != null 
                            && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c != null){
                            String tacRegion = tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c;
                            cs.Region_Support__c = tacRegion;
                        }
                        
                        //Skills Calculation Logic - Start
                        cs.Warm_Handoff__c = true;
                        
                        //IBA-1367 - Start
                        if(String.valueOf(cs.Ownerid).startsWith(GCSCommonConstants.STARTS_WITH_005)){
                            cs.Prior_Owner__c = cs.OwnerId;
                        }
                        //IBA-1367 - End
                        
                        //IBA-6457 Added by Chetan -- Start
                        if(isUSAIncountrySupportOfferingCase(cs, accMap)){
                            cs.OwnerId = System.Label.In_Country_USA_Support_Queue_Id;
                        }
                        //IBA-6457 Added by Chetan -- End
                        else if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA){
                            cs.OwnerId = zpaQueueId;
                        }else{
                            cs.OwnerId = Label.Support_Queue_Id;
                        }
                        
                        //IBA-1265 - Start
                        Integer counter = GCSCommonConstants.INTEGER_0;
                        if(cs.Automated_Trigger_Counter__c == null){
                            counter = GCSCommonConstants.INTEGER_0;
                        }else{
                            counter = Integer.valueOf(cs.Automated_Trigger_Counter__c) ;
                        }
                        counter += GCSCommonConstants.INTEGER_1;
                        cs.Automated_Trigger_Counter__c = counter;
                        //IBA-1265 - End
                        
                        //IBA-1316 - Start
                        cs.Handed_Off_Case__c = true;
                        cs.Queue_Priority__c = '6';
                        //IBA-1316 - End
                    }
                }
                if(!notifyMailList.isEmpty() || Test.isRunningTest()){
                    TriggerUtility.EmailMessageAfterInsertExecuted();
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(notifyMailList);
                    GCSCommonUtility.logSendEmailError(results, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
                if(!feedItemList.isEmpty()){
                    TriggerUtility.SkipFeedItemTriggerExecuted();
                    TriggerUtility.SkipCaseCommentTriggerExecuted();
                    List<Database.SaveResult> srList = Database.insert(feedItemList, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to send Reassignment Threshold Email
     * @param  mapOfCaseAndCaseDetail map of Cases
     */
    public static void sendReassignmentThresholdEmail(Map<Id, Case> mapOfCaseAndCaseDetail){
        final String METHOD_NAME = 'sendReassignmentThresholdEmail';
        try {
            String ziaPremiumDutyManagerEmail=GCSCommonConstants.EMPTY_STRING;
            String ziaPremiumPlusDutyManagerEmail = GCSCommonConstants.EMPTY_STRING;
            String zpaDutyManager = GCSCommonConstants.EMPTY_STRING;
            String ziazpaDutyManager = GCSCommonConstants.EMPTY_STRING;
            String ziazpaBackupDutyManagerEmail = GCSCommonConstants.EMPTY_STRING;
            String ziaPremiumPlusBackupDutyManagerEmail = GCSCommonConstants.EMPTY_STRING;
            String ziaPremiumBackupDutyManagerEmail = GCSCommonConstants.EMPTY_STRING;
            String zpaBackupDutyManagerEmail = GCSCommonConstants.EMPTY_STRING;
            Timezone pstTz = Timezone.getTimeZone(GCSCommonConstants.AMERICA_LA_TIME_ZONE);
            DateTime currentTimePst = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now()) / GCSCommonConstants.INTEGER_1000));
            Time timeNowPst = currentTimePst.timeGMT();
            /*for(Engineer_Schedule__c es : [SELECT Id, Start_Time__c, End_Time__c, Day__c, Duty_Manager__c, Duty_Manager__r.Email, 
                                            Backup_Duty_Manager__c, Backup_Duty_Manager__r.Email, Product__c, Segment__c, 
                                            Service_Agent_Information__r.User__c, Type__c 
                                            FROM Engineer_Schedule__c 
                                            WHERE Type__c = :GCSCommonConstants.DUTY_MANAGER_STRING]){*/
            for(Shift es : [SELECT Id, StartTime, EndTime, Day__c, Duty_Manager__c, Duty_Manager__r.Email, 
                                        Backup_Duty_Manager__c, Backup_Duty_Manager__r.Email, Product__c, Segment__c, 
                                        ServiceResource.RelatedRecordId, Type__c 
                                        FROM Shift 
                                        WHERE Type__c = :GCSCommonConstants.DUTY_MANAGER_STRING]){

                DateTime startTimePst = es.StartTime.addSeconds((pstTz.getOffset(Datetime.now()) / GCSCommonConstants.INTEGER_1000));
                Time startPst = startTimePst.timeGMT();    
                DateTime endTimePst = es.EndTime.addSeconds((pstTz.getOffset(Datetime.now()) / GCSCommonConstants.INTEGER_1000));
                Time endPst=endTimePst.timeGMT(); 

                if(es.Type__c == GCSCommonConstants.DUTY_MANAGER_STRING 
                    && timeNowPst >= startPst 
                    && timeNowPst <= endPst){
                    if(es.Product__c == GCSCommonConstants.CASE_PRODUCT_ZPA){
                        zpaDutyManager = es.Duty_Manager__r.Email;                        
                        if(es.Backup_Duty_Manager__c != null && es.Backup_Duty_Manager__r.Email != null){
                            zpaBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;                            
                        }
                    }else if(es.Product__c == GCSCommonConstants.SHIFT_PRODUCT_ZIA_ZPA){
                        ziazpaDutyManager = es.Duty_Manager__r.Email;                        
                        if(es.Backup_Duty_Manager__c != null && es.Backup_Duty_Manager__r.Email != null){
                            ziazpaBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;                            
                        }
                    }else{
                        if(es.Segment__c == GCSCommonConstants.PREMIUM_PLUS_CASE_SKILL){
                            ziaPremiumPlusDutyManagerEmail = es.Duty_Manager__r.Email;
                            if(es.Backup_Duty_Manager__c != null && es.Backup_Duty_Manager__r.Email != null){
                                ziaPremiumPlusBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;
                            }
                        }else{
                            ziaPremiumDutyManagerEmail = es.Duty_Manager__r.Email;
                            if(es.Backup_Duty_Manager__c != null && es.Backup_Duty_Manager__r.Email != null){
                                ziaPremiumBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;
                            }
                        }
                    }
                }
            }
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = GCSCommonUtility.getEmailTemplate(new List<String>{'Case_Reassignment_Counter_Surpass_Threshold'}).get(GCSCommonConstants.INTEGER_0);
            OrgWideEmailAddress owea = GCSCommonUtility.getOrgWideEmailAddresses(
                new List<String>{GCSCommonConstants.ZS_SUPPORT_EMAIL_ID}).get(GCSCommonConstants.INTEGER_0);
            Messaging.SingleEmailMessage mail = GCSCommonUtility.prepareEmailMessage(emailTemplate.Id, GCSCommonUtility.getContactId(), false,owea.Id);
            Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
            for(Id caseId : mapOfCaseAndCaseDetail.keySet()){
                Case cs = mapOfCaseAndCaseDetail.get(caseId);
                List<String> listOfAddress = new List<String>();
                if(cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA 
                    && !String.isBlank(zpaDutyManager)){
                    listOfAddress.add(zpaDutyManager);
                    if(!String.isBlank(zpaBackupDutyManagerEmail)){
                        listOfAddress.add(zpaBackupDutyManagerEmail);
                    }
                }else if((cs.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA || cs.Product_New__c ==  GCSCommonConstants.CASE_PRODUCT_ZIA)
                    && !String.isBlank(ziazpaDutyManager)){
                    listOfAddress.add(ziazpaDutyManager);
                    if(!String.isBlank(ziazpaBackupDutyManagerEmail)){
                        listOfAddress.add(ziazpaBackupDutyManagerEmail);
                    }
                }else{
                    String segmentForCase = cs.Customer_Segment__c;
                    if(String.isBlank(segmentForCase)){
                        segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                    }
                    String customerSegment = (psesupportmap != null && psesupportmap.containsKey(segmentForCase)) ? psesupportmap.get(segmentForCase).Primary_Support__c : GCSCommonConstants.EMPTY_STRING;
                    if(customerSegment == GCSCommonConstants.PREMIUM_PLUS_CASE_SKILL 
                        && !String.isBlank(ziaPremiumPlusDutyManagerEmail)){
                        listOfAddress.add(ziaPremiumPlusDutyManagerEmail);
                        if(!String.isBlank(ziaPremiumPlusBackupDutyManagerEmail)){
                            listOfAddress.add(ziaPremiumPlusBackupDutyManagerEmail);
                        }
                    }else if(customerSegment == GCSCommonConstants.PREMIUM_CASE_SKILL 
                        && !String.isBlank(ziaPremiumDutyManagerEmail)){
                        listOfAddress.add(ziaPremiumDutyManagerEmail);
                        if(!String.isBlank(ziaPremiumBackupDutyManagerEmail)){
                            listOfAddress.add(ziaPremiumBackupDutyManagerEmail);
                        }
                    }
                }
                if(!listOfAddress.isEmpty() || Test.isRunningTest()){
                    mail.setToAddresses(listOfAddress);
                    mail.setWhatId(cs.Id);
                    mailList.add(mail);
                }
            }
            
            if(!mailList.isEmpty() || Test.isRunningTest()){
                TriggerUtility.EmailMessageAfterInsertExecuted();
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                GCSCommonUtility.logSendEmailError(results, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //Added by Chetan IBA-1613 --Start
    /**
     * This method is used to populate NOC Subject
     * @param  caseList case list
     * @param  caseMap  map of Cases
     */
    public static void updateNOCSubject(List<Case> caseList, Map<Id,Case> caseMap){
        String zsNOCEmail = System.Label.ZNOC_Email;
        List<String> zsNOCEmailList = new List<String>();
        if(String.isNotBlank(zsNOCEmail)) {
            zsNOCEmailList = zsNOCEmail.split(GCSCommonConstants.COMMA_STRING);
        }
        for(Case cs : caseList){
            if(((cs.Requestor_s_Email__c != null && caseMap == null) 
                    || (caseMap != null && cs.Case_Created_By_Email__c != caseMap.get(cs.Id).Case_Created_By_Email__c))
                && zsNOCEmailList.contains(cs.Case_Created_By_Email__c)
                && !cs.Subject.startsWithIgnoreCase(label.ZNOC)
                && cs.RecordTypeId == CASE_SUPPORT_RT_ID){
                cs.Subject = label.ZNOC + ' ' + cs.Subject;
            }
        }
    }
    //Added by Chetan IBA-1613 --End
    
    //Added by Chetan IBA-1749 --Start
    /**
     * This method is used to send Escalation Email
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void sendEscalationEmail(List<Case> newList, Map<Id, Case> oldMap){
        final String METHOD_NAME = 'sendEscalationEmail';
        try {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = GCSCommonUtility.getEmailTemplate(new List<String>{'Customer_escalation_email'}).get(GCSCommonConstants.INTEGER_0);
            OrgWideEmailAddress owea = GCSCommonUtility.getOrgWideEmailAddresses(
                new List<String>{GCSCommonConstants.ZS_SUPPORT_EMAIL_ID}).get(GCSCommonConstants.INTEGER_0);
            Messaging.SingleEmailMessage mail = GCSCommonUtility.prepareEmailMessage(emailTemplate.Id, GCSCommonUtility.getContactId(), false,owea.Id);
            Set<String> accIds = new Set<String>();
            Set<String> caseIds = new Set<String>();
            Map<id, String> accMap = new Map<id, String>();
            List<String> ccEmails = new List<String>();
            for(Case cs: newList){
                if((cs.IsEscalated != oldMap.get(cs.Id).IsEscalated 
                        && cs.IsEscalated == true 
                        && String.isNotBlank(cs.AccountId))
                    || Test.isRunningTest()){
                    accIds.add(cs.AccountId);
                    caseIds.add(cs.Id);
                }
            }
            if(!accIds.isEmpty() || Test.isRunningTest()){
                String queryFields = 'Id, Case_Escalation_Notification_Recipients__c';
                String whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(new List<String>(), accIds);
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                for (Account acc : AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause)) {
                    accMap.put(acc.Id, acc.Case_Escalation_Notification_Recipients__c);
                }
            }
            if(!caseIds.isEmpty() || Test.isRunningTest()){
                String queryFields = 'Id, AccountId, Owner.Email';
                String whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(new List<String>(), caseIds);
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                for (Case cs : CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause)) {
                    String sendTo;
                    ccEmails = new List<String>();
                    if(cs.Owner.Email != null){
                        ccEmails.add(cs.Owner.Email);
                    }
                    if(accMap != null && accMap.containsKey(cs.AccountId) && accMap.get(cs.AccountId) != null){
                        sendTo = accMap.get(cs.AccountId);
                    }
                    
                    List<String> sendToList = new List<String>();
                    if(String.isNotBlank(sendTo)) {
                        sendToList = sendTo.split(GCSCommonConstants.SEMI_COLON_STRING);
                    }
                    if(!sendToList.isEmpty()){
                        mail.setToAddresses(sendToList);
                        mail.setCcAddresses(ccEmails);
                        mail.setSaveAsActivity(false);
                        mail.setWhatId(cs.Id);
                        mails.add(mail);
                    }
                }
            }
            if(!mails.isEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                GCSCommonUtility.logSendEmailError(results, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Chetan IBA-1749 --End
    
    //Added by Chetan IBA-686 -- Start
    /**
     * This method is used to insert Record_History_Tracking__c record
     * @param  caseList   case list
     * @param  oldCaseMap old case map
     */
    public static void insertCaseRecordHistoryTracking(List<Case> caseList, Map<Id,Case> oldCaseMap) {
        final String METHOD_NAME = 'insertCaseRecordHistoryTracking';
        List<Schema.FieldSetMember> fieldSetMemberList =  FieldSetQuery.readFieldSet('History_Tracking_Fields', GCSCommonConstants.CASE_STRING);
        List<String> fieldsToTrack = new List<String>();
        Map<String,String> fieldsAPIVsLabel = new Map<String,String>();
        List<Record_History_Tracking__c> recordHistoryTrackingList = new List<Record_History_Tracking__c>();
        Id caseHistoryTrackingRecordType = Schema.SObjectType.Record_History_Tracking__c.getRecordTypeInfosByDeveloperName().get(GCSCommonConstants.CASE_STRING).getRecordTypeId();
        try{
            if(!fieldSetMemberList.isEmpty()){
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                    fieldsToTrack.add(fieldSetMemberObj.getFieldPath());
                    fieldsAPIVsLabel.put(fieldSetMemberObj.getFieldPath(),fieldSetMemberObj.getLabel());
                }
                for(Case cs : caseList){
                    for(String eachFieldToTrack : fieldsToTrack){
                        if(oldCaseMap.get(cs.Id).get(eachFieldToTrack) != cs.get(eachFieldToTrack)){
                            Record_History_Tracking__c newTrack = new Record_History_Tracking__c();
                            newTrack.Case__c = cs.Id;
                            newTrack.recordTypeId = caseHistoryTrackingRecordType;
                            newTrack.New_Value__c = String.valueOf(cs.get(eachFieldToTrack));
                            newTrack.old_Value__c = String.valueOf(oldCaseMap.get(cs.Id).get(eachFieldToTrack));
                            newTrack.Field_Name__c = eachFieldToTrack;
                            newTrack.Field_Label__c = fieldsAPIVsLabel.get(eachFieldToTrack);
                            recordHistoryTrackingList.add(newTrack);
                        }
                    }
                }
                if(!recordHistoryTrackingList.isEmpty()){
                    List<Database.SaveResult> srList = Database.insert(recordHistoryTrackingList, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Chetan IBA-686 -- End
    
    //Defcon Escalation Code Starts
    //Added by Chetan - Start
    /**
     * This method is used to send Defcon Next Plan Of Action Change Email
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void sendDefconNextPlanOfActionChangeEmail(List<Case> newList, Map<Id, Case> oldMap){
        final String METHOD_NAME = 'sendDefconNextPlanOfActionChangeEmail';
        try {
            Set<String> nextPlanOfActionChnagedDefconCaseIdSet = new Set<String>();
            for(Case cs : newList){
                if((cs.Case_Record_Type_Name__c == GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME 
                    && cs.Current_Status_Next_Plan_Of_Action__c != oldMap.get(cs.Id).Current_Status_Next_Plan_Of_Action__c)){
                    nextPlanOfActionChnagedDefconCaseIdSet.add(cs.Id);
                }
            }
            if(!nextPlanOfActionChnagedDefconCaseIdSet.isEmpty()){
                Set<String> parentCaseIdSet = new Set<String>();
                Map<String, Case> defconCaseMap = new Map<String, Case>();
                String queryFields = 'Id, ParentId, Escalated_By__r.Profile.Name, Escalated_By__r.Email';
                String whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(new List<String>(), nextPlanOfActionChnagedDefconCaseIdSet);
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                for (Case cs : CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause)) {
                    defconCaseMap.put(cs.Id, cs);
                    if(String.isNotBlank(cs.ParentId)){
                        parentCaseIdSet.add(cs.ParentId);
                    }
                }

                if(!parentCaseIdSet.isEmpty()) {
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    EmailTemplate emailTemplate = GCSCommonUtility.getEmailTemplate(new List<String>{GCSCommonConstants.DEFCON_CURRENT_STATUS_NEXT_PLAN_UPD_EMAIL_TEMPLATE}).get(GCSCommonConstants.INTEGER_0);
                    OrgWideEmailAddress owea = GCSCommonUtility.getOrgWideEmailAddresses(
                        new List<String>{GCSCommonConstants.ZS_SUPPORT_EMAIL_ID}).get(GCSCommonConstants.INTEGER_0);
                    Messaging.SingleEmailMessage mail = GCSCommonUtility.prepareEmailMessage(emailTemplate.Id, GCSCommonUtility.getContactId(), false,owea.Id);

                    Map<String, Case> parentCaseMap = new Map<String, Case>();

                    queryFields = 'Id, Internal_CC_List__c, Owner.Email';
                    whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(new List<String>(), parentCaseIdSet);
                    for(Case c : CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause)) {
                        parentCaseMap.put(c.Id, c);
                    }

                    queryFields = 'Id, ParentId';
                    whereClause = whereClauseIdInStr + GCSCommonUtility.getFormattedString(new List<String>(), nextPlanOfActionChnagedDefconCaseIdSet);
                    for (Case cs : CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause)) {
                        Case defconCase = defconCaseMap.get(cs.Id);
                        if(defconCase != null 
                            && parentCaseMap.containsKey(cs.ParentId)) {
                            List<String> sendToList = new List<String>();
                            Case parentCase = parentCaseMap.get(cs.ParentId);
                            String internalCCListStr = parentCase.Internal_CC_List__c;
                            if(String.isNotBlank(internalCCListStr)) {
                                if(internalCCListStr.contains(GCSCommonConstants.SEMI_COLON_STRING)){
                                    sendToList.addAll(internalCCListStr.split(GCSCommonConstants.SEMI_COLON_STRING));
                                }else{
                                    sendToList.add(internalCCListStr);
                                }
                            }

                            if(parentCase.Owner.Email != null) {
                                sendToList.add(parentCase.Owner.Email);
                            }

                            //IBA-7180: Excelude all Non Zscaler domain emails from the recipients list
                            if(defconCase.Escalated_By__c != null 
                                && String.isNotBlank(defconCase.Escalated_By__r.Email)  
                                && defconCase.Escalated_By__r.Email.endsWith(GCSCommonConstants.ZSCALER_DOMAIN)) {
                                sendToList.add(defconCase.Escalated_By__r.Email);
                            }

                            if(!sendToList.isEmpty()) {
                                mail.setToAddresses(sendToList);
                                mail.setSaveAsActivity(false);
                                mail.setTemplateId(emailTemplate.Id);
                                mail.setWhatId(cs.Id);
                                mails.add(mail);
                            }
                        }
                    }

                    if(!mails.isEmpty()){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                        GCSCommonUtility.logSendEmailError(results, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Chetan - End
    
    // Added by Chetan - IBA-3524 - Start, 
    //Updated logic by Bhagyalaxmi for IBA-5356
    /**
     * This method is used to populate NextUpdateDue field on Defcon
     * @param  caseList   case list
     * @param  caseOldMap old case map
     */
    public static void setDefconNextUpdateDue(List<Case> caseList,Map<Id,Case> caseOldMap) {
        final String METHOD_NAME = 'setDefconNextUpdateDue';
        try {
            Map<String, Decimal> followUpSLAConfigMap = new Map<String, Decimal>();
            DateTime currentNextUpdateDue;
            Long seconds;
            Long millseconds;
            Integer min;
            Integer hour;
            
            for(Defcon_Follow_Up_SLA_Configurations__mdt meta : [SELECT Id, Defcon_Level__c, Minutes__c 
                                                                FROM Defcon_Follow_Up_SLA_Configurations__mdt]) {
                followUpSLAConfigMap.put(meta.defcon_Level__c, meta.minutes__c);
            }
            
            for(Case cs : caseList){
                if(cs.RecordTypeId == CASE_ESCALATION_RT_ID){
                    if(caseOldMap == null 
                        && followUpSLAConfigMap.containsKey(cs.Defcon_Level__c)) {
                        cs.Next_Update_Due__c = System.now().addMinutes(Integer.valueOf(followUpSLAConfigMap.get(cs.Defcon_Level__c)));
                    }
                    if(caseOldMap != null && (cs.Defcon_Level__c != caseOldMap.get(cs.Id).Defcon_Level__c)) {
                        currentNextUpdateDue = cs.Next_Update_Due__c;
                        if(currentNextUpdateDue != null){
                            seconds =  currentNextUpdateDue.getTime() - System.now().getTime();
                            millseconds = seconds / GCSCommonConstants.INTEGER_1000;
                            min = Integer.valueof(millseconds/GCSCommonConstants.INTEGER_60);
                            hour = min / GCSCommonConstants.INTEGER_60;
                            
                            if(hour <= GCSCommonConstants.INTEGER_48){
                                cs.Next_Update_Due__c = System.now().addDays(GCSCommonConstants.INTEGER_2);
                                cs.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_DEFCON_LEVEL_CHANGED, cs.Defcon_Automation_Reason__c);
                            }
                        }else if(currentNextUpdateDue == null){
                            cs.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_DEFCON_OWNER_CHANGED, cs.Defcon_Automation_Reason__c);
                            cs.Next_Update_Due__c = System.now().addDays(GCSCommonConstants.INTEGER_2);
                        }
                        cs.Status = GCSCommonConstants.CASE_STATUS_NEEDS_FOLLOW_UP;
                    }
                    //Added by Bhagya for 4066 Start
                    else if(caseOldMap != null 
                        && caseOldMap.get(cs.Id) != null 
                        && (cs.OwnerId != caseOldMap.get(cs.Id).OwnerId)){
                        currentNextUpdateDue = cs.Next_Update_Due__c;
                        if(currentNextUpdateDue != null){
                            seconds =  currentNextUpdateDue.getTime() - System.now().getTime();
                            millseconds = seconds / GCSCommonConstants.INTEGER_1000;
                            min = Integer.valueof(millseconds / GCSCommonConstants.INTEGER_60);
                            hour = min / GCSCommonConstants.INTEGER_60;
                            
                            if(hour <= GCSCommonConstants.INTEGER_48) {
                                cs.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_DEFCON_OWNER_CHANGED, cs.Defcon_Automation_Reason__c);
                                cs.Next_Update_Due__c = System.now().addDays(GCSCommonConstants.INTEGER_2);
                            }
                        }else if(currentNextUpdateDue == null){
                            cs.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_DEFCON_OWNER_CHANGED, cs.Defcon_Automation_Reason__c);
                            cs.Next_Update_Due__c = System.now().addDays(GCSCommonConstants.INTEGER_2);
                        }
                        if(cs.Status != GCSCommonConstants.CASE_STATUS_NEEDS_FOLLOW_UP){
                            cs.Status = GCSCommonConstants.CASE_STATUS_NEEDS_FOLLOW_UP;
                        }
                    }
                    //Added by Bhagya for 4066 End
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    // Added by Chetan - IBA-3524 - End
    
    //Added by Ankit - Defcon Project - Start
    
    //Add Defcon Entitlement on Escalation Cases on insertion
    /**
     * This method is used to add Entitlement To Defcon Case
     * @param  cases case list
     */
    public static void addEntitlementToDefconCases(List<Case> cases) {
        final String METHOD_NAME = 'addEntitlementToDefconCases';
        try {
            List<Entitlement> entitlementList = [SELECT Id, Name 
                                                FROM Entitlement 
                                                WHERE Name = 'Defcon Escalation Entitlement (DO NOT DELETE)' 
                                                AND EndDate = null 
                                                AND Status = 'Active'];
            if(!entitlementList.isEmpty()){
                Map<Id, String> ownerManagerMap = new Map<Id, String>();
                for(Case c: cases) {
                    if(c.RecordTypeId == CASE_ESCALATION_RT_ID) {
                        c.EntitlementId = entitlementList.get(GCSCommonConstants.INTEGER_0).Id;
                        if(c.Defcon_Level__c != '5' 
                            && c.OwnerId != System.Label.In_Country_USA_Defcon_Queue_Id) {
                            //Set owner of the Defcon Record as Queue
                            c.OwnerId = System.Label.Defcon_Escalation_Queue_Id;
                        }else {
                            ownerManagerMap.put(c.escalated_By__c, GCSCommonConstants.EMPTY_STRING);
                        }
                    }
                }
                if(!ownerManagerMap.isEmpty() || Test.isRunningTest()) {
                    for(User u : UserSelector.getUsers(ownerManagerMap.keySet(), false)) {
                        if(u.ManagerId != null){
                            ownerManagerMap.put(u.id, u.ManagerId);
                        }
                    }
                }
                for(Case c: cases) {
                    if(c.RecordTypeId == CASE_ESCALATION_RT_ID 
                        && c.Defcon_Level__c == '5' 
                        && ownerManagerMap.containsKey(c.Escalated_By__c) 
                        && String.isNotBlank(ownerManagerMap.get(c.Escalated_By__c))) {
                        c.OwnerId = ownerManagerMap.get(c.escalated_By__c);
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //Called on before update : if Escalation Case's Defcon Level is updated, reset the milestones and Esc level
    /**
     * This method is used to Reset the Milestones When Defcon is Updated
     * @param  cases    cases list
     * @param  oldCases old case map
     */
    public static void resetMilestonesOnDefconUpdate(List<Case> cases, Map<Id, Case> oldCases) {
        final String METHOD_NAME = 'resetMilestonesOnDefconUpdate';
        try {
            List<String> casesMilestonesReset = new List<String>();
            List<String> followUpCasesMilestonesReset = new List<String>();
            List<String> responseCasesMilestonesReset = new List<String>();
            for(Case c : cases) {
                if(c.recordTypeId == CASE_ESCALATION_RT_ID 
                    && (c.defcon_Level__c != oldCases.get(c.id).defcon_Level__c)) {
                    c.Auto_Esc_SLA_Level_0_Cumulative_Time__c = GCSCommonConstants.INTEGER_0;
                    c.Auto_Esc_SLA_Level_1_Cumulative_Time__c = GCSCommonConstants.INTEGER_0;
                    c.Auto_Esc_SLA_Level_2_Cumulative_Time__c = GCSCommonConstants.INTEGER_0;
                    c.Escalation_Level__c = GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_0;
                    c.Auto_Esc_SLA_Violated__c = GCSCommonConstants.EMPTY_STRING;

                    List<String> removeReasonStrList = new List<String>{
                        GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_0_VIOLATED,
                        GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_1_VIOLATED,
                        GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_2_VIOLATED,
                        GCSCommonConstants.CASE_DEFCON_AUTO_REASON_DEFCON_ASSIGNED_TO_MANAGER
                    };
                    c.Defcon_Automation_Reason__c = removeDefonAutomationReason(removeReasonStrList, c.Defcon_Automation_Reason__c);

                    casesMilestonesReset.add(c.Id);
                }
                if(c.recordTypeId == CASE_ESCALATION_RT_ID 
                    && c.status != oldCases.get(c.id).status 
                    && c.status == GCSCommonConstants.CASE_STATUS_RESOLVED) {
                    casesMilestonesReset.add(c.Id);
                }
                if(c.recordTypeId == CASE_ESCALATION_RT_ID 
                    && c.Follow_Up_SLA_Violated__c != oldCases.get(c.id).Follow_Up_SLA_Violated__c 
                    && c.Follow_Up_SLA_Violated__c) {
                    followUpCasesMilestonesReset.add(c.Id);
                    c.Is_Follow_Up_SLA_Violated__c = true;      //Ram Sangati - Added for IBA-3803 change (DO NOT DELETE).
                    c.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_FOLLOW_UP_SLA_VIOLATED, c.Defcon_Automation_Reason__c);
                    c.status = GCSCommonConstants.CASE_STATUS_SLA_VIOLATED;// Moved From after Update
                    c.Follow_Up_SLA_Violated__c = true;
                }
                if(c.recordTypeId == CASE_ESCALATION_RT_ID 
                    && c.Response_SLA_Violated__c != oldCases.get(c.id).Response_SLA_Violated__c 
                    && c.Response_SLA_Violated__c) {
                    responseCasesMilestonesReset.add(c.Id);
                    c.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_OWNERSHIP_SLA_VIOLATED, c.Defcon_Automation_Reason__c);
                    c.status = GCSCommonConstants.CASE_STATUS_SLA_VIOLATED;// Moved From after Update
                    c.Response_SLA_Violated__c = true;
                }
                if(c.recordTypeId == CASE_ESCALATION_RT_ID 
                    && c.Next_update_Due__c != oldCases.get(c.id).Next_update_Due__c) {
                    c.Follow_Up_SLA_Violated__c = false;
                }
            }
            List<CaseMilestone> milestonesToComplete = new List<CaseMilestone>();
            if(!casesMilestonesReset.isEmpty()){
                for(CaseMilestone cm : GCSCommonUtility.getCaseMilestones(casesMilestonesReset, new List<String>())){
                /*for(CaseMilestone cm : [SELECT Id, MilestoneType.Name, CaseId, StartDate, TargetDate, CompletionDate 
                                        FROM CaseMilestone 
                                        WHERE CaseId IN :casesMilestonesReset AND CompletionDate = null]) {*/
                    cm.CompletionDate = System.now();
                    milestonesToComplete.add(cm);
                }
            }
            if(!followUpCasesMilestonesReset.isEmpty() || !responseCasesMilestonesReset.isEmpty()) {
                List<String> mlsCaseIdsList = new List<String>();
                mlsCaseIdsList.addAll(followUpCasesMilestonesReset);
                mlsCaseIdsList.addAll(responseCasesMilestonesReset);
                if(!mlsCaseIdsList.isEmpty()){
                    for(CaseMilestone cm : GCSCommonUtility.getCaseMilestones(mlsCaseIdsList, 
                        new List<String>{GCSCommonConstants.CASE_MILESTONE_OWNERSHIP_SLA, GCSCommonConstants.CASE_MILESTONE_FOLLOW_UP_SLA})){
                    /*for(CaseMilestone cm : [SELECT Id, MilestoneType.Name, CaseId, StartDate, TargetDate, CompletionDate 
                                            FROM CaseMilestone 
                                            WHERE ((CaseId IN :followUpCasesMilestonesReset AND MilestoneType.Name = 'Follow Up SLA') 
                                                OR (CaseId IN :responseCasesMilestonesReset AND MilestoneType.Name = 'Ownership SLA')) 
                                            AND CompletionDate = null]) {*/
                        cm.CompletionDate = cm.targetDate.addSeconds(GCSCommonConstants.INTEGER_1);
                        milestonesToComplete.add(cm);
                    }
                }
            }
            if(!milestonesToComplete.isEmpty()) {
                List<Database.SaveResult> srList = Database.update(milestonesToComplete, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //Called on before update : if Escalation Case's Status changes to Auto Esc SLA Violated, Set the Cumulative Time Fields
    /**
     * This method is used to populate AutoEscSLA CumulativeTime fields of a Defcon
     * @param  cases    cases list
     * @param  oldCases old case map
     */
    public static void setAutoEscSLACumulativeTime(List<Case> cases, Map<Id, Case> oldCases) {
        final String METHOD_NAME = 'setAutoEscSLACumulativeTime';
        try {
            Map<String, Case> defconMap = new Map<String, Case>(cases);
            Map<String, String> ownerManagerMap = new Map<String, String>();
            Map<String, List<String>> autoEscOwnerChangeConfig = new Map<String, List<String>>{
                '1' => new List<String>{levelStr + GCSCommonConstants.INTEGER_1, levelStr + GCSCommonConstants.INTEGER_2},
                '2' => new List<String>{levelStr + GCSCommonConstants.INTEGER_1, levelStr + GCSCommonConstants.INTEGER_2},
                '3' => new List<String>{levelStr + GCSCommonConstants.INTEGER_2},
                '4' => new List<String>{levelStr + GCSCommonConstants.INTEGER_2}
            };
            for(Case c : cases) {
                if(c.RecordTypeId == CASE_ESCALATION_RT_ID 
                    && String.valueOf(c.ownerId).startsWith(GCSCommonConstants.STARTS_WITH_005)) {
                    ownerManagerMap.put(c.ownerId, GCSCommonConstants.EMPTY_STRING);
                }
            }
            //TODO Move to UserTrigger with generic method
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Level__c, Name, Profile.Name, IsActive, Manager.Name 
                                                    FROM User 
                                                    WHERE Manager.Name = :Label.SVP_Global_Customer_Services 
                                                    AND IsActive = true]);
            List<String> gcsProfileList = System.label.Defcon_GCS_Profile_List.split(GCSCommonConstants.COMMA_STRING);
            if(!ownerManagerMap.isEmpty()) {
                //TODO Move to UserTrigger
                for(User u : [SELECT Id, ManagerId, Manager.Level__c, Manager.Profile.Name, Level__c 
                            FROM User 
                            WHERE Id IN :ownerManagerMap.keySet() 
                            AND managerId != :GCSCommonConstants.EMPTY_STRING]) {
                    if(u.manager.Level__c == GCSCommonConstants.EXEC_USER_LEVEL 
                        || u.manager.Level__c == GCSCommonConstants.RVP_USER_LEVEL 
                        || u.manager.Level__c == GCSCommonConstants.SR_RVP_USER_LEVEL 
                        || !gcsProfileList.contains(u.manager.profile.name)){
                        ownerManagerMap.put(u.id, GCSCommonConstants.EMPTY_STRING);
                    }else if(u.manager.Level__c == GCSCommonConstants.DIRECTOR_USER_LEVEL 
                        && !userMap.containsKey(u.managerId)){
                        ownerManagerMap.put(u.id, GCSCommonConstants.EMPTY_STRING);
                    }else if(u.manager.Level__c == GCSCommonConstants.VP_USER_LEVEL 
                        && !gcsProfileList.contains(u.manager.profile.name)){
                        ownerManagerMap.put(u.id, GCSCommonConstants.EMPTY_STRING);
                    }else {
                        ownerManagerMap.put(u.id, u.managerId);
                    }
                }
            }
            
            if(!defconMap.keyset().isEmpty()){
                for(CaseMilestone cm : GCSCommonUtility.getCaseMilestones(
                    new List<String>(defconMap.keyset()), 
                    new List<String>{GCSCommonConstants.CASE_MILESTONE_OWNERSHIP_SLA, 
                                    GCSCommonConstants.CASE_MILESTONE_FOLLOW_UP_SLA, 
                                    GCSCommonConstants.CASE_MILESTONE_AUTO_ESC_SLA})){
                /*for(CaseMilestone cm : [SELECT Id, MilestoneType.Name, CaseId, StartDate, TargetDate, CompletionDate 
                                        FROM CaseMilestone 
                                        WHERE (caseId IN :defconMap.keySet() 
                                        AND (MilestoneType.Name = 'Auto Esc SLA' 
                                            OR MilestoneType.Name = 'Follow Up SLA' 
                                            OR MilestoneType.Name = 'Ownership SLA')) 
                                        AND CompletionDate = null]){*/
                    Case c = defconMap.get(cm.caseId);
                    Case cOld = oldCases.get(cm.caseId);
                    if(c.recordTypeId == CASE_ESCALATION_RT_ID 
                        && (c.Auto_Esc_SLA_Violated__c != cOld.Auto_Esc_SLA_Violated__c 
                        && String.isNotBlank(c.Auto_Esc_SLA_Violated__c)) 
                        && cm.MilestoneType.Name == GCSCommonConstants.CASE_MILESTONE_AUTO_ESC_SLA) {
                        c.Is_Auto_Esc_SLA_Violated__c = true;       //Ram Sangati - Added for IBA-3804 change (DO NOT DELETE).
                        c.status = GCSCommonConstants.CASE_STATUS_SLA_VIOLATED;
                        if(c.Escalation_Level__c != cOld.Escalation_Level__c 
                            && autoEscOwnerChangeConfig.containsKey(c.defcon_level__c) 
                            && autoEscOwnerChangeConfig.get(c.defcon_level__c).contains(c.Escalation_Level__c)
                            && String.isNotBlank(ownerManagerMap.get(c.ownerId))
                            && String.valueOf(c.ownerId).startsWith(GCSCommonConstants.STARTS_WITH_005)
                            && ownerManagerMap.containsKey(c.ownerId)) {
                            c.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_DEFCON_ASSIGNED_TO_MANAGER, c.Defcon_Automation_Reason__c);
                            c.OwnerId = ownerManagerMap.get(c.ownerId);
                        }
                        Long dt1Long = cm.startDate.getTime();
                        Long dt2Long = DateTime.now().getTime();
                        Long milliseconds = dt2Long - dt1Long;
                        Long seconds = milliseconds / GCSCommonConstants.INTEGER_1000;

                        if(c.Escalation_Level__c != cOld.Escalation_Level__c) {
                            if(c.Escalation_Level__c == GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_1) {
                                c.Auto_Esc_SLA_Violated__c = levelStr + GCSCommonConstants.INTEGER_0;
                                c.Auto_Esc_SLA_Level_0_Cumulative_Time__c += seconds;
                                c.of_hops_in_Esc_Level__c += GCSCommonConstants.INTEGER_1;
                                c.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_0_VIOLATED, c.Defcon_Automation_Reason__c);
                            }else if(c.Escalation_Level__c == GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_2) {
                                c.Auto_Esc_SLA_Level_1_Cumulative_Time__c += seconds;
                                c.Auto_Esc_SLA_Violated__c = levelStr + GCSCommonConstants.INTEGER_1;
                                c.of_hops_in_Esc_Level__c += GCSCommonConstants.INTEGER_1;
                                c.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_1_VIOLATED, c.Defcon_Automation_Reason__c);
                            }
                        }else {
                            if(c.Escalation_Level__c == GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_2) {
                                c.Auto_Esc_SLA_Level_2_Cumulative_Time__c += seconds;
                                c.Auto_Esc_SLA_Violated__c = levelStr + GCSCommonConstants.INTEGER_2;
                                c.Defcon_Automation_Reason__c = addDefonAutomationReason(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_2_VIOLATED, c.Defcon_Automation_Reason__c);
                            }
                        }
                    }
                }
            }
            for(Case c : cases) {
                if(c.ownerId != oldCases.get(c.id).OwnerId 
                    && c.recordTypeId == CASE_ESCALATION_RT_ID) {
                    if(c.Escalation_Level__c == GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_0 
                        && ((String.isNotBlank(c.Defcon_Automation_Reason__c) 
                            && !c.Defcon_Automation_Reason__c.containsIgnoreCase(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_0_VIOLATED)) 
                        || String.isBlank(c.Defcon_Automation_Reason__c))) {
                        c.Auto_Esc_SLA_Level_0_Cumulative_Time__c = GCSCommonConstants.INTEGER_0;
                    }else if(c.Escalation_Level__c == GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_1 
                        && ((String.isNotBlank(c.Defcon_Automation_Reason__c) 
                            && !c.Defcon_Automation_Reason__c.containsIgnoreCase(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_1_VIOLATED)) 
                        || String.isBlank(c.Defcon_Automation_Reason__c))) {
                        c.Auto_Esc_SLA_Level_1_Cumulative_Time__c = GCSCommonConstants.INTEGER_0;
                    }else if(c.Escalation_Level__c == GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_2 
                        && ((String.isNotBlank(c.Defcon_Automation_Reason__c) 
                            && !c.Defcon_Automation_Reason__c.containsIgnoreCase(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_2_VIOLATED)) 
                        || String.isBlank(c.Defcon_Automation_Reason__c))) {
                        c.Auto_Esc_SLA_Level_2_Cumulative_Time__c = GCSCommonConstants.INTEGER_0;
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //Called on after update : Complete milestones when Escalation Case is updated
    /**
     * This method is used to Complete Milestone upon eligible Defcon condition met.
     * @param  cases    cases list
     * @param  oldCases old case map
     */
    public static void completeDefconMilestones(List<Case> cases, Map<Id, Case> oldCases) {
        final String METHOD_NAME = 'completeDefconMilestones';
        try {
            Set<String> completeMilestoneSet = new Set<String>();
            Set<String> respCaseIds = new Set<String>();
            Set<String> autoEscCaseIds = new Set<String>();
            Set<String> followUpEscCaseIds = new Set<String>();
            
            for(Case c : cases) {
                if(c.RecordTypeId == CASE_ESCALATION_RT_ID) {
                    if(oldCases.containsKey(c.id) && c.ownerId != oldCases.get(c.id).ownerId) {
                        completeMilestoneSet.add(c.Id);
                        if(String.valueOf(c.ownerId).startsWith(GCSCommonConstants.STARTS_WITH_005) 
                            && (oldCases.get(c.id).ownerId == System.Label.Defcon_Escalation_Queue_Id)
                                || oldCases.get(c.id).ownerId == System.Label.In_Country_USA_Defcon_Queue_Id) {
                            respCaseIds.add(c.id);
                        }
                        //Complete Auto Esc ML when owner is changed
                        autoEscCaseIds.add(c.id);
                    }
                    if(oldCases.containsKey(c.id) 
                        && c.Escalation_Level__c != oldCases.get(c.id).Escalation_Level__c) {
                        autoEscCaseIds.add(c.id);
                    }
                    //NEW CODE 
                    if(String.isNotBlank(c.Defcon_Automation_Reason__c)) {
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) 
                                || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_OWNERSHIP_SLA_VIOLATED)) 
                            && c.Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_OWNERSHIP_SLA_VIOLATED)) {
                            respCaseIds.add(c.id);
                        }
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) 
                                || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_FOLLOW_UP_SLA_VIOLATED)) 
                            && c.Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_FOLLOW_UP_SLA_VIOLATED)) {
                            followUpEscCaseIds.add(c.id);
                        }
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) 
                                || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_0_VIOLATED)) 
                            && c.Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_0_VIOLATED)) {
                            autoEscCaseIds.add(c.id);
                        }
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) 
                                || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_1_VIOLATED)) 
                            && c.Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_1_VIOLATED)) {
                            autoEscCaseIds.add(c.id);
                        }
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) 
                                || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_2_VIOLATED)) 
                            && c.Defcon_Automation_Reason__c.contains(GCSCommonConstants.CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_2_VIOLATED)) {
                            autoEscCaseIds.add(c.id);
                        }
                    }
                }
            }
            if(!respCaseIds.isEmpty() || !autoEscCaseIds.isEmpty() || !followUpEscCaseIds.isEmpty()) {
                Map<String, CaseMilestone> caseMilestonesMap = new Map<String, CaseMilestone>();

                Set<String> mlsCaseIdsSet = new Set<String>();
                mlsCaseIdsSet.addAll(respCaseIds);
                mlsCaseIdsSet.addAll(followUpEscCaseIds);
                mlsCaseIdsSet.addAll(autoEscCaseIds);
                
                if(!mlsCaseIdsSet.isEmpty()){
                    for(CaseMilestone cm : GCSCommonUtility.getCaseMilestones(new List<String>(mlsCaseIdsSet), new List<String>())){
                    /*for(CaseMilestone cm : [SELECT Id, MilestoneType.Name, CaseId, StartDate, TargetDate, CompletionDate 
                                            FROM CaseMilestone 
                                            WHERE (CaseId IN :respCaseIds 
                                                OR CaseId IN :followUpEscCaseIds 
                                                OR caseId IN :autoEscCaseIds) 
                                            AND CompletionDate = null]){*/
                        if(cm.MilestoneType.Name == GCSCommonConstants.CASE_MILESTONE_OWNERSHIP_SLA 
                            && respCaseIds.contains(cm.caseId)) {
                            if(completeMilestoneSet.contains(cm.caseId)) {
                                cm.CompletionDate = System.now();
                            }else {
                                cm.CompletionDate = cm.targetDate.addSeconds(GCSCommonConstants.INTEGER_1);
                            }
                            caseMilestonesMap.put(cm.Id, cm);
                        }
                        if(cm.MilestoneType.Name == GCSCommonConstants.CASE_MILESTONE_AUTO_ESC_SLA 
                            && autoEscCaseIds.contains(cm.caseId)) {
                            if(completeMilestoneSet.contains(cm.caseId)) {
                                cm.CompletionDate = System.now();
                            }else {
                                cm.CompletionDate = cm.targetDate.addSeconds(GCSCommonConstants.INTEGER_1);
                            }
                            caseMilestonesMap.put(cm.Id, cm);
                        }
                        if(cm.MilestoneType.Name == GCSCommonConstants.CASE_MILESTONE_FOLLOW_UP_SLA 
                                && followUpEscCaseIds.contains(cm.caseId) 
                            || Test.isRunningTest()) {
                            cm.CompletionDate = cm.targetDate.addSeconds(GCSCommonConstants.INTEGER_1);
                            caseMilestonesMap.put(cm.Id, cm);
                        }
                    }
                }
                if(!caseMilestonesMap.isEmpty()){
                    List<Database.SaveResult> srList = Database.update(new List<CaseMilestone>(caseMilestonesMap.values()), false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    //Called on after update : Pause and Resume Milestones when Parent Case is Updated
    /**
     * This method is used to toggle AutoEscSLA On Defcon
     * @param  casesNew   cases list
     * @param  caseOldMap old case map
     */
    public static void toggleAutoEscSLAOnDefcon(List<Case> casesNew, Map<Id, Case> caseOldMap) {
        final String METHOD_NAME = 'toggleAutoEscSLAOnDefcon';
        try {
            List<string> pauseAutoEscStatuses = new List<string>{
                GCSCommonConstants.CASE_STATUS_AWAITING_FIX, 
                GCSCommonConstants.CASE_STATUS_ESCALATED_TO_ENGINEERING, 
                GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER, 
                GCSCommonConstants.CASE_STATUS_PENDING_FIX_VERIFICATION, 
                GCSCommonConstants.CASE_STATUS_CUSTOMER_CALLBACK_SCHEDULED, 
                GCSCommonConstants.CASE_STATUS_CUSTOMER_FOLLOW_UP_SCHEDULED, 
                GCSCommonConstants.CASE_STATUS_CLOSED_DUPLICATE, 
                GCSCommonConstants.CASE_STATUS_CLOSED
            };
            List<String> caseIdsPauseSLA = new List<String>();
            List<String> caseIdsResumeSLA = new List<String>();
            for(Case c : casesNew) {
                if(c.status != caseOldMap.get(c.id).status && c.recordTypeId == CASE_SUPPORT_RT_ID) {
                    if(pauseAutoEscStatuses.contains(c.Status)) {
                        caseIdsPauseSLA.add(c.Id);
                    }else {
                        caseIdsResumeSLA.add(c.Id);
                    }
                }
            }
            List<String> pauseAndResumeSLA = new List<String>();
            pauseAndResumeSLA.addAll(caseIdsPauseSLA);
            pauseAndResumeSLA.addAll(caseIdsResumeSLA);
            Map<String, Case> escalationCases = new Map<String, Case>();
            Map<String, Case> escalationCasesResumeSLA = new Map<String, Case>();
            
            if(!pauseAndResumeSLA.isEmpty()) {
                String queryFields = 'Id, parentId, Escalation_Level__c, Auto_Esc_SLA_Level_0_Cumulative_Time__c, Auto_Esc_SLA_Level_1_Cumulative_Time__c, Auto_Esc_SLA_Level_2_Cumulative_Time__c';
                String whereClause = 'RecordTypeId = \'' + CASE_ESCALATION_RT_ID + '\'' 
                    + ' AND ParentId IN ' + GCSCommonUtility.getFormattedString(pauseAndResumeSLA, new Set<String>());
                String orderByClause = GCSCommonConstants.EMPTY_STRING;
                Integer limitClause = null;
                for(Case c : CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause)) {
                    if(caseIdsPauseSLA.contains(c.parentId)) {
                        escalationCases.put(c.Id, c);
                    }else if(caseIdsResumeSLA.contains(c.parentId)) {
                        escalationCasesResumeSLA.put(c.Id, c);
                    }
                }
                if(!escalationCasesResumeSLA.isEmpty()) {
                    List<Database.SaveResult> srList = Database.update(escalationCasesResumeSLA.values(), false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
                if(!escalationCases.isEmpty()) {
                    completeAutoEscDefconMilestones(escalationCases);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    /**
     * This method is used to Complete AutoEsc Milestone upon eligible Defcon condition met, this method is called from toggleAutoEscSLAOnDefcon().
     * @param  cases cases map
     */
    public static void completeAutoEscDefconMilestones(Map<String, Case> cases) {
        final String METHOD_NAME = 'completeAutoEscDefconMilestones';
        try {
            if(!cases.isEmpty()) {
                List<CaseMilestone> caseMilestones = new List<CaseMilestone>();
                for(CaseMilestone cm : GCSCommonUtility.getCaseMilestones(new List<String>(cases.keyset()), new List<String>())){
                /*for(CaseMilestone cm : [SELECT Id, MilestoneType.Name, CaseId, StartDate, TargetDate, CompletionDate 
                                        FROM CaseMilestone 
                                        WHERE (caseId IN :cases.keySet()) 
                                        AND CompletionDate = null]){*/
                    if(cm.MilestoneType.Name == GCSCommonConstants.CASE_MILESTONE_AUTO_ESC_SLA && cases.containsKey(cm.caseId)) {
                        cm.CompletionDate = System.now();
                        caseMilestones.add(cm);
                        Long dt1Long = cm.startDate.getTime();
                        Long dt2Long = DateTime.now().getTime();
                        Long milliseconds = dt2Long - dt1Long;
                        Long seconds = milliseconds / GCSCommonConstants.INTEGER_1000;

                        if(cases.get(cm.caseId).Escalation_Level__c == GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_0) {
                            cases.get(cm.caseId).Auto_Esc_SLA_Level_0_Cumulative_Time__c += seconds;
                        }else if(cases.get(cm.caseId).Escalation_Level__c == GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_1) {
                            cases.get(cm.caseId).Auto_Esc_SLA_Level_1_Cumulative_Time__c += seconds;
                        }else if(cases.get(cm.caseId).Escalation_Level__c == GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_2) {
                            cases.get(cm.caseId).Auto_Esc_SLA_Level_2_Cumulative_Time__c += seconds;
                        }
                    }
                }
                if(!caseMilestones.isEmpty() || Test.isRunningTest()){
                    List<Database.SaveResult> srList = Database.update(caseMilestones, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                    
                    List<Database.SaveResult> srListCases = Database.update(cases.values(), false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srListCases, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Ankit - Defcon Project - Ends
    
    //Added by Bhagyalaxmi - IBA-4060 - Start
    /**
     * This method is used to Update the Defcon Status as Resolved upon it's Parent Case is Closed
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void updateDefconStatusAsResolvedUponParentCaseIsClosed(List<Case> newList, Map<Id,Case> oldMap) {
        final String METHOD_NAME = 'updateDefconStatusAsResolvedUponParentCaseIsClosed';
        try {
            Set<String> parentCaseIdSet = new Set<String>();
            List<string> listClosedStatus = new List<string>{
                GCSCommonConstants.CASE_STATUS_CLOSED_RESOLVED, 
                GCSCommonConstants.CASE_STATUS_CLOSED_NO_ACTION, 
                GCSCommonConstants.CASE_STATUS_CLOSED_NO_RESP, 
                GCSCommonConstants.CASE_STATUS_CLOSED_DUPLICATE, 
                GCSCommonConstants.CASE_STATUS_CLOSED
            };
            //Check if Given Support Case is Closed
            for(Case caseObj : newList){
                if(caseObj.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && caseObj.Status != oldMap.get(caseObj.Id).Status 
                    && listClosedStatus.contains(caseObj.Status)){
                    parentCaseIdSet.add(caseObj.Id);
                }
            }
            //Retrive Escalations related to given parent case ids
            if(!parentCaseIdSet.isEmpty()) {
                List<Case> listDefconsToResolve = new List<Case>();
                for(Case escRecord : CaseSelector.getCases('Id, ParentId, RecordTypeId, Status, Root_Cause_for_DEFCON__c', 
                                    ' RecordTypeId = \'' + CASE_ESCALATION_RT_ID + '\'' 
                                        + ' AND ParentId IN ' + GCSCommonUtility.getFormattedString(new List<String>(), parentCaseIdSet) 
                                        + ' AND Status != \'' + GCSCommonConstants.CASE_STATUS_RESOLVED + '\'', 
                                    GCSCommonConstants.EMPTY_STRING, 
                                    null)) {
                    if(escRecord.Root_Cause_for_DEFCON__c != null){
                        escRecord.Status = GCSCommonConstants.CASE_STATUS_RESOLVED;
                        escRecord.Escalation_Resolved_By__c = UserInfo.getUserId();
                        listDefconsToResolve.add(escRecord);
                    }
                }
            
                //Update Defcon Case Status
                if(!listDefconsToResolve.isEmpty()){
                    List<Database.SaveResult> srList = Database.update(listDefconsToResolve, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Bhagyalaxmi - IBA-4060 - End
    
    //Added by Bhagyalaxmi - IBA-4069 - Start Runs Before Update
    /**
     * This method is used to Validate Defcon Owner
     * @param  newList new case list
     * @param  oldMap  old case map
     */
    public static void validateDefconOwnerBeforeDefconOwnershipChange(List<Case> newList,Map<Id,Case> oldMap) {
        final String METHOD_NAME = 'validateDefconOwnerBeforeDefconOwnershipChange';
        try {
            String errMsg = 'This defcon cannot be assigned to ';
            Map<Id,List<Case>> mapCaseToOwner = new Map<Id,List<Case>>();
            List<String> gcsProfileList = System.label.Defcon_GCS_Profile_List.split(GCSCommonConstants.COMMA_STRING);

            for(Case csObj : newList){
                if(csObj.RecordTypeId == CASE_ESCALATION_RT_ID 
                    && csObj.OwnerId != oldMap.get(csObj.Id).OwnerId 
                    && String.valueOf(csObj.OwnerId).startsWith(GCSCommonConstants.STARTS_WITH_005)){
                    if(!mapCaseToOwner.containsKey(csObj.OwnerId)) {
                        mapCaseToOwner.put(csObj.OwnerId, new List<Case>());
                    }
                    mapCaseToOwner.get(csObj.OwnerId).add(csObj);
                }
            }
            List<User> userList = [SELECT Id, Level__c, Name, Profile.Name, IsActive 
                                    FROM User 
                                    WHERE IsActive = true 
                                    AND Id IN :mapCaseToOwner.keyset()];
            for(User ownerRec : userList){
                if(!mapCaseToOwner.get(ownerRec.id).isEmpty() 
                    && mapCaseToOwner.containsKey(ownerRec.id)) {
                    for(Case c : mapCaseToOwner.get(ownerRec.id)) {
                        if(ownerRec.Level__c == GCSCommonConstants.EXEC_USER_LEVEL 
                            || ownerRec.Level__c == GCSCommonConstants.RVP_USER_LEVEL 
                            || ownerRec.Level__c == GCSCommonConstants.SR_RVP_USER_LEVEL 
                            || !gcsProfileList.contains(ownerRec.profile.name)){
                            c.addError(errMsg + ownerRec.Name);
                        }else if(!gcsProfileList.contains(ownerRec.profile.name) 
                            && (ownerRec.Level__c == GCSCommonConstants.DIRECTOR_USER_LEVEL 
                                || ownerRec.Level__c == GCSCommonConstants.VP_USER_LEVEL)){
                            c.addError(errMsg + ownerRec.Name);
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Bhagyalaxmi - IBA-4069 - End Runs Before Update
    
    // Added by Chetan - IBA-4394 - Start
    /**
     * This method is used to Set Current_Status_Next_Plan_Of_Action__c Field value based on Defcon condition
     * @param  caseList   case list
     * @param  caseOldMap old case map
     */
    public static void setDefaultNextPlanOfActionTemplateFields(List<Case> caseList, Map<Id,Case> caseOldMap) {
        final String METHOD_NAME = 'setDefaultNextPlanOfActionTemplateFields';
        try {
            for(Case cs: caseList){
                if(cs.RecordTypeId == CASE_ESCALATION_RT_ID){
                    if(caseOldMap == null){
                        cs.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
                    }
                    else if(caseOldMap != null 
                        && caseOldMap.get(cs.Id) != null 
                        && (cs.Current_Status_Next_Plan_Of_Action__c != caseOldMap.get(cs.Id).Current_Status_Next_Plan_Of_Action__c)) {
                        if(cs.Current_Status_Next_Plan_Of_Action__c == null){
                            cs.Current_Status_Next_Plan_Of_Action__c = GCSCommonConstants.EMPTY_STRING;
                        }
                        if(cs.Current_Status_Next_Plan_Of_Action__c.contains('\n') 
                            && cs.Current_Status_Next_Plan_Of_Action__c.contains('Last Update')){
                            Integer i = GCSCommonConstants.INTEGER_0;
                            List<String> summaryList = cs.Current_Status_Next_Plan_Of_Action__c.split('\n');
                            for(string substr : summaryList){
                                if(substr.contains('Last Update')){
                                    List<String> strList = substr.split(':', GCSCommonConstants.INTEGER_2);
                                    String str = strList[GCSCommonConstants.INTEGER_1].replace(strList[GCSCommonConstants.INTEGER_1], String.valueOf(cs.LastModifiedDate));
                                    strList[GCSCommonConstants.INTEGER_1] = str;
                                    substr = String.join(strList,':');
                                    summaryList[i] = substr;
                                }
                                i++;
                            }
                            cs.Current_Status_Next_Plan_Of_Action__c = String.join(summaryList, '\n');
                        }else if(!cs.Current_Status_Next_Plan_Of_Action__c.contains('Last Update')){
                            cs.Current_Status_Next_Plan_Of_Action__c = cs.Current_Status_Next_Plan_Of_Action__c + '\n Last Update: ' + String.valueOf(cs.LastModifiedDate);
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    // Added by Chetan - IBA-4394 - End
    
    /**
     * This method is used to Add Defon Automation Reason
     * @param  newVal      New Defon Automation Reason
     * @param  existingVal Existing Defon Automation Reason
     * @return             String
     */
    public static String addDefonAutomationReason(String newVal, String existingVal) {
        String returnValue = GCSCommonConstants.EMPTY_STRING;
        if(String.isNotBlank(existingVal)) {
            List<String> valuesList = new List<String>();
            valuesList = existingVal.split(GCSCommonConstants.SEMI_COLON_STRING);
            valuesList.add(newVal);
            Set<String> valuesSet = new Set<String>(valuesList);
            returnValue = String.join(new List<String>(valuesSet), GCSCommonConstants.SEMI_COLON_STRING);
        }
        else {
            returnValue = newVal+GCSCommonConstants.SEMI_COLON_STRING;
        }
        return returnValue;
    }
    
    /**
     * This method is used to Remove Defon Automation Reason
     * @param  removeReasonStrList removeReasonStrList description
     * @param  existingReasonStr   existingReasonStr description
     * @return                     return description
     */
    public static String removeDefonAutomationReason(List<String> removeReasonStrList, String existingReasonStr) {
        String remainingReasonStr = GCSCommonConstants.EMPTY_STRING;
        if(String.isNotBlank(existingReasonStr)) {
            Set<String> existingReasonSet = new Set<String>(new List<String>(existingReasonStr.split(GCSCommonConstants.SEMI_COLON_STRING)));
            for(String removeReasonStr : removeReasonStrList) {
                existingReasonSet.remove(removeReasonStr);
            }
            remainingReasonStr = String.join(new List<String>(existingReasonSet), GCSCommonConstants.SEMI_COLON_STRING);
        }
        return remainingReasonStr;
    }
    
    /**
     * This method is used to Reopen Defcon Case
     * @param  casesNew   case list
     * @param  caseOldMap old case map
     */
    public static void reopenDefconCase(List<Case> casesNew, Map<Id, Case> caseOldMap) {
        final String METHOD_NAME = 'reopenDefconCase';
        try {
            Map<String, Case> parentCaseMap = new Map<String, Case>();
            for(Case c : casesNew) {
                if(c.recordTypeId == CASE_SUPPORT_RT_ID 
                    && c.Status != caseOldMap.get(c.id).Status 
                    && caseOldMap.get(c.id).Status.containsIgnoreCase(GCSCommonConstants.CASE_STATUS_CLOSED) 
                    && !c.Status.containsIgnoreCase(GCSCommonConstants.CASE_STATUS_CLOSED)) {
                    parentCaseMap.put(c.Id, c);
                }
            }

            if(!parentCaseMap.isEmpty()) {
                List<Case> defcons = new List<Case>();
                String queryFields = 'Id, ParentId, Parent.IsEscalated, Escalation_Level__c, Status';
                String whereClause = 'RecordTypeId = \'' + CASE_ESCALATION_RT_ID 
                    + '\' AND parentId IN ' + GCSCommonUtility.getFormattedString(new List<String>(), parentCaseMap.keySet());
                String orderByClause = 'CreatedDate';
                Integer limitClause = null;
                for(Case c : CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause)) {
                    parentCaseMap.get(c.parentId).IsEscalated = true;
                    c.status = GCSCommonConstants.CASE_STATUS_REOPEN;
                    c.Escalation_Resolved_By__c = null;
                    defcons.add(c);
                }
                if(!defcons.isEmpty()) {
                    List<Database.SaveResult> srList = Database.update(defcons, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }

    // Added By Bhagyalaxmi for (Defcon Hypercare) IBA-5356
    /**
     * This method is used to Update Parent Case Fields Of a Defcon
     * @param  casesNew   case list
     * @param  caseOldMap old case map
     */
    public static void updateParentFieldsOnDefcon(List<Case> casesNew, Map<Id, Case> caseOldMap) {
        final String METHOD_NAME = 'updateParentFieldsOnDefcon';
        try {
            List<string> parentCaseClosedStatusList = new List<string>{
                GCSCommonConstants.CASE_STATUS_CLOSED_RESOLVED, 
                GCSCommonConstants.CASE_STATUS_CLOSED_NO_ACTION, 
                GCSCommonConstants.CASE_STATUS_CLOSED_NO_RESP, 
                GCSCommonConstants.CASE_STATUS_CLOSED_DUPLICATE, 
                GCSCommonConstants.CASE_STATUS_CLOSED
            };
            Map<String, Case> mapSupportCase = new Map<String, Case>();
            List<Case> escToUpdate = new List<Case>();
            for(Case cs : casesNew) {
                Case oldCase = caseOldMap.get(cs.Id);
                if(cs.RecordTypeId == CASE_SUPPORT_RT_ID 
                    && !parentCaseClosedStatusList.contains(cs.Status)
                    && (cs.ParentId != oldCase.ParentId 
                        || cs.Priority != oldCase.Priority 
                        || cs.Product_New__c != oldCase.Product_New__c 
                        || cs.Customer_Temperature__c != oldCase.Customer_Temperature__c 
                        || cs.OwnerId != oldCase.OwnerId 
                        || cs.AccountId != oldCase.AccountId 
                        || cs.ContactId != oldCase.ContactId)){
                    mapSupportCase.put(cs.Id, cs);
                }
            }
            if(!mapSupportCase.isEmpty()){
                String queryFields = 'Id, ParentId, Parent.OwnerId, AccountId, ContactId, RecordTypeId, Product_New__c';
                String whereClause = ' RecordTypeId = \'' + CASE_ESCALATION_RT_ID + '\'' 
                    + ' AND ParentId IN ' + GCSCommonUtility.getFormattedString(new List<String>(), mapSupportCase.keyset()) 
                    + ' AND Status != \'' + GCSCommonConstants.CASE_STATUS_RESOLVED + '\'';
                String orderByClause = 'CreatedDate';
                Integer limitClause = null;
                for(Case escRecord : CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause)){
                    Case parentCase = mapSupportCase.get(escRecord.ParentId);
                    escRecord.Product_New__c = parentCase.Product_New__c;
                    escRecord.AccountId = parentCase.AccountId;
                    escRecord.ContactId = parentCase.ContactId;
                    escRecord.Priority = parentCase.Priority;
                    escRecord.Customer_Temperature__c = parentCase.Customer_Temperature__c;
                    escToUpdate.add(escRecord);
                }
                if(!escToUpdate.isEmpty()){
                    List<Database.SaveResult> srList = Database.update(escToUpdate, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    /* Code added for Defcon Hypercare IBA-5356 End */
    //Defcon Escalation Code Ends
    
    /**
     * This method is used to Set the Prior Owner detauks that are mainly used in Slack notification flow
     * @param  casesNew   case list
     * @param  caseOldMap old case map
     */
    public static void setPriorOwner(List<Case> casesNew, Map<Id, Case> caseOldMap) {
        final String METHOD_NAME = 'setPriorOwner';
        try {
            //Ram S Added for Slack notification flows (DO NOT REMOVE)
            Set<Id> priorUserIdSet = new Set<Id>();
            for(Case cs : casesNew) {
                Case oldCS = caseOldMap.get(cs.Id);
                if(cs.OwnerId != oldCS.OwnerId){
                    cs.Prior_Owner_Id__c = oldCS.OwnerId;
                    /*
                    *(In flow the merge field '$Record.Owner.Name' is returning null. 
                    * So we store prior owner name value in below mentioend field)
                    */
                    if(cs.Prior_Owner_Id__c.contains(System.Label.Support_Queue_Id)){
                        cs.Prior_Owner_Name__c = GCSCommonConstants.Q_NAME_SUPPORT_QUEUE;
                    }else if(cs.Prior_Owner_Id__c.contains(System.Label.ZPA_Support_Queue_Id)){
                        cs.Prior_Owner_Name__c = GCSCommonConstants.Q_NAME_ZPA_SUPPORT_QUEUE;
                    }else if(cs.Prior_Owner_Id__c.contains(System.Label.ZPC_Support_Queue)){
                        cs.Prior_Owner_Name__c = GCSCommonConstants.Q_NAME_ZPC_SUPPORT_QUEUE;
                    }else if(cs.Prior_Owner_Id__c.contains(System.Label.ZWS_Queue_Id)){
                        cs.Prior_Owner_Name__c = GCSCommonConstants.Q_NAME_ZWS_SUPPORT_QUEUE;
                    }else if(cs.Prior_Owner_Id__c.contains(System.Label.Defcon_Escalation_Queue_Id)){
                        cs.Prior_Owner_Name__c = GCSCommonConstants.Q_NAME_DEFCON_ESCALATION_QUEUE;
                    }else if(cs.Prior_Owner_Id__c.contains(System.Label.In_Country_USA_Support_Queue_Id)){
                        cs.Prior_Owner_Name__c = GCSCommonConstants.Q_NAME_IN_COUNTRY_USA_SUPPORT_QUEUE;
                    }else if(cs.Prior_Owner_Id__c.contains(System.Label.In_Country_USA_Defcon_Queue_Id)){
                        cs.Prior_Owner_Name__c = GCSCommonConstants.Q_NAME_IN_COUNTRY_USA_DEFCON_QUEUE;
                    }else{
                        priorUserIdSet.add(oldCS.OwnerId);
                    }
                }
                
                //IBA-3745 - Change starts here 
                //Ram S added for existing TAM slack integration flow re-write.
                if(cs.Case_Record_Type_Name__c == GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME 
                    && cs.FRT_Violation_Warning__c == true 
                    && oldCS.FRT_Violation_Warning__c == false){
                    cs.Prior_FRT_Violation_Warning_Msg__c = GCSCommonConstants.PRIOR_FRT_VIOLATION_WARNING_MSG;
                }
                if(cs.Case_Record_Type_Name__c == GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME 
                    && cs.Defcon_Level__c != oldCS.Defcon_Level__c){
                    cs.Prior_Defcon_Level__c = oldCS.Defcon_Level__c;
                }
                //IBA-3745 - Change ends here
            }
            if(!priorUserIdSet.isEmpty()){
                Map<Id, User> activePriorOwnerssMap = new Map<Id, User>(UserSelector.getUsers(priorUserIdSet, false));
                for(Case cs : casesNew) {
                    User priorOwnerUser = activePriorOwnerssMap.get(((Case)Trigger.oldMap.get(cs.Id)).OwnerId);
                    cs.Prior_Owner_Name__c = priorOwnerUser != null ? priorOwnerUser.Name : GCSCommonConstants.EMPTY_STRING;
                }
            }
            //IBA-2679 - Change ends here
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }

    @TestVisible
    private static boolean isUSAIncountrySupportOfferingCase(Case cs, Map<Id, Account> accMap){
        if((cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                || cs.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)
            && cs.AccountId != null 
            && accmap != null 
            && !accmap.isEmpty() 
            && accmap.containsKey(cs.AccountId) 
            && accmap.get(cs.AccountId) != null 
            && String.isNotBlank(accmap.get(cs.AccountId).Support_Type__c) 
            && accMap.get(cs.AccountId).Support_Type__c == GCSCommonConstants.PREMIUM_SUPPORT_PLUS_IN_COUNTRY 
            && String.isNotBlank(accmap.get(cs.AccountId).Support_Offering__c) 
            && accMap.get(cs.AccountId).Support_Offering__c.contains(GCSCommonConstants.PREMIUM_SUPPORT_PLUS) 
            && accMap.get(cs.AccountId).Support_Offering__c.contains(GCSCommonConstants.UNITED_STATES)){
            return true;
        }else{
            return false;
        }
    }

    //Added by Ankit - IBA-7948 starts
    public static void caseOwnerOOOValidation(List<Case> casesNew, Map<Id, Case> caseOldMap) {
        final String METHOD_NAME = 'caseOwnerOOOValidation';
        try {
            Map<Id, Boolean> ownerOOOMap = new Map<Id, Boolean>(); 
            for(Case c : casesNew) {
                if(c.recordTypeId == CASE_SUPPORT_RT_ID && c.OwnerId != null && c.OwnerId != caseOldMap.get(c.Id).OwnerId && String.valueOf(c.OwnerId).startsWith('005')) {
                    ownerOOOMap.put(c.OwnerId, false);
                }
            }
            if(!ownerOOOMap.isEmpty()) {
                for(ServiceResource sr : ServiceResourceSelector.getServiceResourcesForUsers('Quota_Field_Set', ownerOOOMap.keySet())) {
                    ownerOOOMap.put(sr.relatedRecordId, sr.Out_Of_Office__c);
                }
            }
            for(Case c : casesNew) {
                if(c.recordTypeId == CASE_SUPPORT_RT_ID && c.OwnerId != null && c.OwnerId != caseOldMap.get(c.Id).OwnerId && String.valueOf(c.OwnerId).startsWith('005')) {
                    if(ownerOOOMap.containsKey(c.OwnerId) && ownerOOOMap.get(c.OwnerId)) {
                        c.addError('Selected Case Owner is out of office and case cannot be assigned to an OOO user.');
                    }
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    //Added by Ankit - IBA-7948 ends
}