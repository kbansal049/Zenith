/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EmailMessageTriggerUtility {
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
    public static Id caseSupportE2CRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_EmailToCase').getRecordTypeId();
    public static Id salesopsRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
    public static void afterInsert(List<EmailMessage> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();

        // IBA-3557 Added by Hitesh Sachdeva - Start
        TriggerHandler.bypass('AccountTriggerHandler');			//Bypass 'AccountMasterTrigger on Account'
        TriggerHandler.bypass('ContactTriggerHandler');				//Bypass 'ContactTriggerHelper'
        // IBA-3557 Added by Hitesh Sachdeva - End

        //IBA-2887 Added by Ram Sangati - Starts here.
        TriggerHandler.bypass('AccountAsyncTriggerHandler');	    //IBA-2887 - Bypass 'AccountAsyncTrigger on AccountChangeEvent'
        TriggerHandler.bypass('AccountEventTriggerHandler');	    //IBA-2887 - Bypass 'AccountEventTrigger on Account_Event__e'
        TriggerHandler.bypass('AmberRoadAccountScreenListener');	//IBA-2887 - Bypass 'AmberRoadAccountScreenListener on Amber_Road_Screen_Account__e'
        //IBA-2887 Added by Ram Sangati - Ends here.

        if(tsmap.containsKey('UpdateCaseStatus') && tsmap.get('UpdateCaseStatus') != null && tsmap.get('UpdateCaseStatus').Execute__c){
            updateCaseStatus(newList);
        }
        if(tsmap.containsKey('Execute_EmailMessage_CaseComment') && tsmap.get('Execute_EmailMessage_CaseComment') != null && tsmap.get('Execute_EmailMessage_CaseComment').Execute__c && !TriggerUtility.isEmailMessagetoCaseCommentExecuted()){
            createCaseComment(newList);
        }
        if(tsmap.containsKey('Close_Case_FRT') && tsmap.get('Close_Case_FRT') != null && tsmap.get('Close_Case_FRT').Execute__c && !TriggerUtility.isEmailMessageFRTExecuted()){
            closeCaseFRT(newList);
        }
        if(tsmap.containsKey('Execute_Last_Public_Comment') && tsmap.get('Execute_Last_Public_Comment') != null && tsmap.get('Execute_Last_Public_Comment').Execute__c && !TriggerUtility.isexecuteUpdateLastActivityExecuted()){
            updateLastPublicCommentOnCase(newList);
        }
        //Added by Ankit - Starts
        //Email sent from Incident Object
        emailFromIncidentHandler(newList);
        //Added by Ankit - ends
        
        TriggerUtility.EmailMessageAfterInsertExecuted();
    }
    
    //Added by Anup - CR#1215 - Start
    public static void updateLastPublicCommentOnCase(List<EmailMessage> newList){
        List<Case> listOfCaseToUpdate = new List<Case>();
        //Added by Chetan CR#4536 Start
        Set<Id> setCaseIds=new Set<Id>();
        Set<Id> setOfIdsUpdated = new Set<Id>();
        for(EmailMessage em:newList){
            if(em.parentId != null){
                setCaseIds.add(em.parentId);
            }
        }
        if(!setCaseIds.isEmpty()){
            for(Case cs:[Select id,AccountId,ContactEmail from Case where id IN :setCaseIds and (ContactEmail like '%zscaler.com' OR AccountId=:System.label.Zscaler_Account_Id)]){
                listOfCaseToUpdate.add(new Case(Id=cs.Id, Days_since_last_activity__c=System.Now()));
                setOfIdsUpdated.add(cs.Id);
            }
        }
        // Added by Chetan CR #4536 End
        for(EmailMessage em : newList){
            if(em.ParentId != null && !em.Incoming && String.valueOf(em.ParentId).startsWith('500')){
                String toAddress = em.ToAddress;
                //List<String> listOfAddress = toAddress.split(';');
                List<String> listOfAddress = new List<String>();
                if(toAddress != null){
                    listOfAddress = toAddress.split(';');
                }
                //Added by Anup - CR#1700 - Start
                if(em.CcAddress != null){
                    List<String> listOfCCAddress = new List<String>();
                    listOfCCAddress = em.ccAddress.split(';');
                    listOfAddress.addAll(listOfCCAddress);
                }
                //Added by Anup - CR#1700 - End
                Boolean updateDate = false;
                for(String str:listOfAddress){
                    if(!str.contains('@zscaler.com')){
                        updateDate=true;
                        break;
                    }
                }
                if(updateDate){
                    if(!setOfIdsUpdated.contains(em.parentId)){
                        listOfCaseToUpdate.add(new Case(Id=em.ParentId, Days_since_last_activity__c=System.Now()));
                    }
                }
            }else if(em.ParentId != null && em.Incoming && String.valueOf(em.ParentId).startsWith('500')){
                String fromAddress = em.FromAddress;
                if(fromAddress.contains('@zscaler.com')){
                    if(!setOfIdsUpdated.contains(em.parentId)){ 
                    listOfCaseToUpdate.add(new Case(Id=em.ParentId, Days_since_last_activity__c=System.Now()));
                    }
                }
            }
        }
        if(!listOfCaseToUpdate.isEmpty()){
            update listOfCaseToUpdate;
        }
        TriggerUtility.executeUpdateLastActivityExecuted();
    }
    //Added By Anup - CR#1215 - End
    
    public static void createCaseComment(List<EmailMessage> newList){
        
        Map<Id, Case> cmaptoupdate = new Map<Id, Case>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        List<Case_Integration__c> caseIntToUdpate = new List<Case_Integration__c>();
        
        for (EmailMessage em : newList){
            if(em.parentId != null){
                caseIds.add(em.parentId);
            }
        }
        //CR #2749-Added Site Review related parameters in the query by Chetan
        
        if(!caseIds.isEmpty()){
            for(case cs: [Select Id,Status,Origin,Case_Type__c,Priority,Product_New__c, Customer_CC_List__c,ParentID, Internal_CC_List__c, RecordTypeId,ClosedDate,External_Reference__c,Customer_Commented__c from Case where Id in :caseIds]){
                caseMap.put(cs.Id, cs);
           //CR #3112-Added by Chetan Start     
                if(cs.Origin =='Sitereview' && cs.Case_Type__c=='Categorization' && cs.Priority=='Low (P4)')
                {
                    caseMap.remove(cs.Id);
                }
           //CR #3112-Added by Chetan End               
                System.debug('caseMap-->'+ caseMap);
            }
        }
        
        Map<String, Case_Integration__c> caseIntList = new Map<String, Case_Integration__c>();
        for(Case_Integration__c cs : [Select id,name,Case__c,Parent_Incident__c, External_ID__c from Case_integration__c 
                                      where External_ID__c != null and case__c in :caseMap.keyset() and case__c != null
                                      and Incident_Type__c = 'Incident' ])
        {
            caseIntList.put(cs.External_ID__c,cs);     
        }
        System.debug('----caseIntList----'+caseIntList);
        
        for (EmailMessage em : newList){
            Set<String> zslst = new Set<String>();
            Set<String> custlst = new Set<String>();
            String internalcc = '';
            String externalcc = '';
            
            Date todays = System.today();
            todays = todays.addDays(-15);
            //System.debug(caseMap.get(em.parentId).ClosedDate); 
            //Added By Anup : CR865 : Removed the fromAddress Condition
            if(em.Incoming && em.parentId != null && caseMap.containsKey(em.parentId) && caseMap.get(em.parentId) != null && (caseMap.get(em.parentId).RecordTypeId == caseSupportE2CRT || caseMap.get(em.parentId).RecordTypeId == caseSupportRT || caseMap.get(em.parentId).RecordTypeId == salesopsRT) && (caseMap.get(em.parentId).ClosedDate == null  ||  caseMap.get(em.parentId).ClosedDate.date().daysBetween(todays) < 0 )){
                Case cs = new Case();
                cs.Id=em.parentId;
                cs.Customer_Commented__c=true;
                cs.Status='Customer Note Added';
                cmaptoupdate.put(cs.Id, cs);      
            }else if(em.Incoming && !em.fromAddress.contains('@zscaler.com') && em.parentId != null && caseMap.containsKey(em.parentId) && caseMap.get(em.parentId) != null && (caseMap.get(em.parentId).RecordTypeId == caseSupportE2CRT || caseMap.get(em.parentId).RecordTypeId == caseSupportRT || caseMap.get(em.parentId).RecordTypeId == salesopsRT) && (caseMap.get(em.parentId).ClosedDate != null  && caseMap.get(em.parentId).ClosedDate.date().daysBetween(todays) >= 0 ))  {
                Case cs = new Case(Id = em.parentId,send_15_day_email__c  = true, send_15_day_email_to__c = em.FromAddress);
                cmaptoupdate.put(cs.Id, cs);
                
            }else if(!em.Incoming &&  em.parentId != null && caseMap.containsKey(em.parentId) && caseMap.get(em.parentId) != null && (caseMap.get(em.parentId).RecordTypeId == caseSupportRT)){
                case caseDt = caseMap.get(em.ParentId);
                if(caseDt.ParentId == null &&  caseIntList.containskey(caseDt.External_Reference__c) && em.TextBody != null &&  
                   (caseDt.status == 'Closed' || caseDt.status == 'Pending Customer' ||
                    caseDt.status == 'Researching' || caseDt.status == 'Escalated to Engineering' ||
                    caseDt.status == 'Awaiting Fix' || caseDt.status == 'Customer Callback Scheduled'))
                {
                    String timeStamp = em.MessageDate.formatGMT('yyyy-MM-dd HH:mm:ss');
                    if(caseDt.status == 'Closed'){
                        caseIntList.get(caseDt.External_Reference__c).Detailed_Solution_Description__c = timeStamp +'-'+em.FromName + ' : ' +em.TextBody.stripHtmlTags();
                        
                        caseIntList.get(caseDt.External_Reference__c).is_Detailed_Solution_Description_Changed__c = true;
                        caseIntList.get(caseDt.External_Reference__c).Assignment_Group__c = caseDt.Product_New__c == 'ZIA' ? System.label.ZIA_Assignment_Group_Siemens : System.label.Siemens_Assignment_Group;
                        caseIntList.get(caseDt.External_Reference__c).Patch_Source__c = 'Resolved';
                        //Added by Anup - CR#4177 - Start
                        if(caseDt.Product_New__c == 'ZIA'){
                            caseIntList.get(caseDt.External_Reference__c).Ticket_Status__c = 'Open';
                            caseIntList.get(caseDt.External_Reference__c).Internal_Work_Notes__c = timeStamp +'-'+em.FromName + ' : ' +em.TextBody.stripHtmlTags();
                            caseIntList.get(caseDt.External_Reference__c).IS_Work_Notes_Changed__c = true;
                        }
                        caseIntList.get(caseDt.External_Reference__c).Resolution_Code__c = 'Solved permanently';
                        //Added by Anup - CR#4177 - End    
                        
                    }else if(caseDt.status == 'Pending Customer'){
                        caseIntList.get(caseDt.External_Reference__c).Internal_Work_Notes__c = timeStamp +'-'+em.FromName + ' : ' +em.TextBody.stripHtmlTags();
                        caseIntList.get(caseDt.External_Reference__c).IS_Work_Notes_Changed__c = true;
                        caseIntList.get(caseDt.External_Reference__c).Assignment_Group__c = caseDt.Product_New__c == 'ZIA' ? System.label.ZIA_Assignment_Group_Siemens : System.label.Siemens_Assignment_Group;
                        caseIntList.get(caseDt.External_Reference__c).Patch_Source__c = 'Reassign';
                        
                    }else if(caseDt.status == 'Researching' || caseDt.status == 'Escalated to Engineering' ||
                             caseDt.status == 'Awaiting Fix' || caseDt.status == 'Customer Callback Scheduled')
                    {
                        caseIntList.get(caseDt.External_Reference__c).Internal_Work_Notes__c = timeStamp +'-'+em.FromName + ' : ' +em.TextBody.stripHtmlTags();
                        caseIntList.get(caseDt.External_Reference__c).IS_Work_Notes_Changed__c = true;
                        caseIntList.get(caseDt.External_Reference__c).Ticket_Status__c = 'Open';
                        caseIntList.get(caseDt.External_Reference__c).Patch_Source__c = 'Worknotes';
                    }
                    caseIntList.get(caseDt.External_Reference__c).Status_Code__c = '0';
                    caseIntList.get(caseDt.External_Reference__c).Integration_Status__c = 'Not Started';
                    //Added by: Ankit Bhatnagar - IBA-166 Starts
                    if(em.TextBody.containsIgnoreCase(System.Label.Siemens_Customer_Communication_Keyword)) {
                        caseIntList.get(caseDt.External_Reference__c).Customer_Communication__c = timeStamp +'-'+em.FromName + ' : ' +em.TextBody.stripHtmlTags();
                        //Added by: Ankit Bhatnagar - IBA-1245 Starts
                        caseIntList.get(caseDt.External_Reference__c).Is_Customer_Communications_Changed__c = true;
                        //Added by: Ankit Bhatnagar - IBA-1245 Ends
                        caseIntList.get(caseDt.External_Reference__c).Internal_Work_Notes__c = timeStamp +'-'+em.FromName + ' : ' +em.TextBody.stripHtmlTags();
                        caseIntList.get(caseDt.External_Reference__c).IS_Work_Notes_Changed__c = true;
                        caseIntList.get(caseDt.External_Reference__c).Assignment_Group__c = System.Label.Zscaler_Assignment_Group;
                    }
                    //Added by: Ankit Bhatnagar - IBA-166 ends
                    caseIntToUdpate.add(caseIntList.get(caseDt.External_Reference__c));
                }
                //Added by: Ankit Bhatnagar - IBA-166 Starts
                else if(caseDt.ParentId == null &&  caseIntList.containskey(caseDt.External_Reference__c) && em.TextBody != null && em.TextBody.containsIgnoreCase(System.Label.Siemens_Customer_Communication_Keyword)) {
                    //For other statuses
                    String timeStamp = em.MessageDate.formatGMT('yyyy-MM-dd HH:mm:ss');
                    caseIntList.get(caseDt.External_Reference__c).Customer_Communication__c = timeStamp +'-'+em.FromName + ' : ' +em.TextBody.stripHtmlTags();
                    //Added by: Ankit Bhatnagar - IBA-1245 Starts
                    caseIntList.get(caseDt.External_Reference__c).Is_Customer_Communications_Changed__c = true;
                    //Added by: Ankit Bhatnagar - IBA-1245 Ends
                    caseIntList.get(caseDt.External_Reference__c).Internal_Work_Notes__c = timeStamp +'-'+em.FromName + ' : ' +em.TextBody.stripHtmlTags();
                    caseIntList.get(caseDt.External_Reference__c).IS_Work_Notes_Changed__c = true;
                    caseIntList.get(caseDt.External_Reference__c).Assignment_Group__c = System.Label.Zscaler_Assignment_Group;
                    caseIntToUdpate.add(caseIntList.get(caseDt.External_Reference__c));
                }
                //Added by: Ankit Bhatnagar - IBA-166 ends
            }
            if(em.parentId != null && caseMap.containsKey(em.parentId) && caseMap.get(em.parentId) != null && caseMap.get(em.parentId).RecordTypeId == caseSupportRT){
                internalcc = caseMap.get(em.parentId).Internal_CC_List__c != null ? caseMap.get(em.parentId).Internal_CC_List__c.trim() : '';
                externalcc = caseMap.get(em.parentId).Customer_CC_List__c != null ? caseMap.get(em.parentId).Customer_CC_List__c.trim() : '';
                if(internalcc != ''){
                    for(String s: internalcc.split(';')){
                        zslst.add(s.trim());
                    }
                }
                if(externalcc != ''){
                    for(String s: externalcc.split(';')){
                        custlst.add(s.trim());
                    }
                    
                }
                if(em.fromAddress != null && !Label.Emails_to_skip_ccList.contains(em.fromAddress.trim())){
                    if(em.fromAddress.contains('@zscaler.com')){
                        if(!zslst.contains(em.fromAddress.trim())){
                            internalcc += em.fromAddress.trim() + ';';
                            zslst.add(em.fromAddress.trim());
                        }
                    }else{
                        if(!custlst.contains(em.fromAddress.trim())){
                            externalcc += em.fromAddress.trim() + ';';
                            custlst.add(em.fromAddress.trim());
                        }
                    }
                }
                if(em.toaddress != null){
                    List<String> emaillst = em.toaddress.split(';');
                    for(String s: emaillst){
                        if(!Label.Emails_to_skip_ccList.contains(s.trim())){
                            if(s.contains('@zscaler.com')){
                                if(!zslst.contains(s.trim())){
                                    internalcc += s.trim() + ';';
                                    zslst.add(s.trim());
                                }
                            }else{
                                if(!custlst.contains(s.trim())){
                                    externalcc += s.trim() + ';';
                                    custlst.add(s.trim());
                                }
                            }
                        }
                    }
                }
                if(em.ccaddress != null){
                    List<String> emaillst = em.ccaddress.split(';');
                    for(String s: emaillst){
                        if(!Label.Emails_to_skip_ccList.contains(s.trim())){
                            if(s.contains('@zscaler.com')){
                                if(!zslst.contains(s.trim())){
                                    internalcc += s.trim() + ';';
                                    zslst.add(s.trim());
                                }
                                
                            }else{
                                if(!custlst.contains(s.trim())){
                                    externalcc += s.trim() + ';';
                                    custlst.add(s.trim());
                                }
                            }
                        }
                    }
                }
                if(cmaptoupdate != null && !cmaptoupdate.isEmpty() && cmaptoupdate.containsKey(em.parentId)){
                    Case cs = cmaptoupdate.get(em.parentId);
                    cs.Customer_CC_List__c = externalcc;
                    cs.Internal_CC_List__c = internalcc;
                    cmaptoupdate.put(em.parentid, cs);
                }else{
                    Case cs = new Case(Id = em.parentid);
                    cs.Customer_CC_List__c = externalcc;
                    cs.Internal_CC_List__c = internalcc;
                    cmaptoupdate.put(em.parentid, cs);
                }
            }
        }
        if(cmaptoupdate != null && !cmaptoupdate.isEmpty()){
            TriggerUtility.executeCaseAfterUpdateCaseIntegartionSetTrue();
            database.update(cmaptoupdate.values(), false);
        }
        
        System.debug('--caseIntToUdpate--'+caseIntToUdpate);
        if(!caseIntToUdpate.isEmpty()){
            TriggerUtility.caseIntegartionExecutedSetTrue();
            update caseIntToUdpate;
        }
        
        TriggerUtility.EmailMessagetoCaseCommentExecuted();
    }
    public static void closeCaseFRT(List<EmailMessage> newList){
        Set<Id> CaseIds = new Set<Id>();
        Set<Id> usrIds = new Set<Id>();
        Set<Id> caseIdstoupdate = new Set<Id>();
        List<Case> casetoudpate = new List<case>();
        for(EmailMessage cc: newList){
            if(cc.ParentId != null && !cc.Incoming){
                CaseIds.add(cc.ParentId);
                usrIds.add(cc.CreatedById);
            }
        }
        Map<Id, case> csmap = new Map<Id, Case>([select id, status, First_Response_Timestamp__c from Case where Id in :CaseIds and Recordtype.Developername = 'Support']);
        Map<Id, User> usrinf = new Map<Id, USer>([Select Id, profile.name, service_Level__c, ContactId from User where Id = :usrIds]);
        for(EmailMessage cc: newList){
            if(usrinf != null && !usrinf.isEmpty() && usrinf.containsKey(cc.CreatedById) && usrinf.get(cc.CreatedById).Service_Level__c != null && !csmap.isEmpty() && csmap.containsKey(cc.ParentId) && csmap.get(cc.ParentId).First_Response_Timestamp__c == null){
                caseIdstoupdate.add(cc.ParentId);
            }
        }
        
        if(!caseIdstoupdate.isEmpty()){
            TriggerUtility.CaseBeforeUpdateExecuted();
            TriggerUtility.CaseAfterUpdateExecuted();
            MilestoneUtils.completeMilestone(caseIdstoupdate, 'First Response', System.now());
        }
        TriggerUtility.EmailMessageFRTExecuted();
    }
    
    //CR# 800-Added by Chetan-Start
    public static void updateCaseStatus(List<EmailMessage> newList){
        List<Case> listOfCaseToUpdate =new List<Case>();
        Set<Id> setOfIds =new Set<Id>();
        for(EmailMessage em:newList)
        {
            //CR# 3018 added by Chetan-Start--Removed one condition from CR #2979
            String toAddress = em.ToAddress;
            List<String> listOfAddress = new List<String>();
            if(toAddress != null){
                listOfAddress = toAddress.split(';');
            }
            if(em.CcAddress != null){
                List<String> listOfCCAddress = new List<String>();
                listOfCCAddress = em.ccAddress.split(';');
                listOfAddress.addAll(listOfCCAddress);
            }
            Boolean customerEmail = false;
            for(String str:listOfAddress){
                if(!str.contains('@zscaler.com')){
                    customerEmail=true;
                    break;
                }
            }
            if(em.ParentId != null && !em.Incoming && customerEmail && String.valueOf(em.ParentId).startsWith('500'))
            {
                setOfIds.add(em.ParentId);               
            }
            //CR# 3018 added by Chetan-End
            
        }
        if(!setOfIds.isEmpty())
        {
            //Added by Ankit for CR# 2750 Bug. Changes to SOQL Query to Bypass Sitereview Cases
            //Added by Chetan for CR#3751.Bypass Siemens Cases
            for(Case cs:[select id,AccountId,status, Origin, Case_Type__c, Priority from Case where Id in :setOfIds and Recordtype.Developername = 'Support'])
            {
                if((cs.Origin =='Sitereview' && cs.Case_Type__c=='Categorization' && cs.Priority=='Low (P4)')|| (cs.Origin=='API' && cs.AccountId==System.Label.Siemens_Account_ID)){
                    system.debug('Ignore this case');
                }else{
                 	if(cs.Status!='Pending Customer' )
                    {
                        cs.Status='Pending Customer';
                        listOfCaseToUpdate.add(cs);
                    }   
                }
            }
        }       
        if(!listOfCaseToUpdate.isEmpty())
        {
            update listOfCaseToUpdate;
        }       
    }
    //CR# 800-Added by Chetan-Start        

    //Added by Ankit - Incident Management - Starts
    public static void emailFromIncidentHandler(List<EmailMessage> newList) {
        Map<String, String> emailIncidentMap = new Map<String, String>();
        Map<String, String> incidentUpdateTypeMap = new Map<String, String>();
        Set<String> allIncidentIds = new Set<String>();
        Set<String> cloudIncidentIds = new Set<String>();
        for(EmailMessage mail : (List<EmailMessage>)Trigger.new) {
            if(!mail.Incoming && String.isNotBlank(mail.relatedToId) && mail.relatedToId.getSObjectType().getDescribe().getName()=='Incident' && String.isNotBlank(mail.subject)) {
                allIncidentIds.add(mail.relatedToId);
            }
        }
        for(Incident inc : [SELECT id,recordType.DeveloperName FROM Incident WHERE Id IN : allIncidentIds AND recordType.DeveloperName = 'Cloud_Incident']) {
            cloudIncidentIds.add(inc.id);
        }
        if(!cloudIncidentIds.isEmpty()) {
            for(EmailMessage mail : (List<EmailMessage>)Trigger.new) {
                if(!mail.Incoming && String.isNotBlank(mail.relatedToId) && mail.relatedToId.getSObjectType().getDescribe().getName()=='Incident' && String.isNotBlank(mail.subject) && cloudIncidentIds.contains(mail.relatedToId)) {
                    if(mail.subject.containsIgnoreCase('Z-EXT')) {
                        emailIncidentMap.put(mail.relatedToId, mail.Id);
                        incidentUpdateTypeMap.put(mail.relatedToId, 'External');
                    }
                    else {
                        incidentUpdateTypeMap.put(mail.relatedToId, 'Internal');
                    }
                }
            }
            if(!emailIncidentMap.isEmpty()) {
                NotifyCustomersOnIncidentCasesBatch b = new NotifyCustomersOnIncidentCasesBatch(emailIncidentMap); 
                Database.executeBatch(b, 1);
            }
            if(!incidentUpdateTypeMap.isEmpty()) {
                CustomNotificationFromApex.notifyUsersOnIncidentSendUpdates(incidentUpdateTypeMap);
            }   
        }
    } 
    //Added by Ankit - Incident Management - Ends

}