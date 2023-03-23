/**
 * Name : CAPRequestTriggerHandler
 * Description : Handler class for CAPRequestTrigger
 * Test Class : CAPRequestTriggerHandlerTest
 * Initial Author : Ankit Bhatnagar
 */

public class CAPRequestTriggerHandler extends TriggerHandler  {
    
    public override void beforeUpdate(){
        //Update Region Email Alias
        populateRegionAliasEmail((List<CAP_Request__c>)Trigger.new,(Map<Id,CAP_Request__c>)Trigger.oldMap);
        //Insert CAP Request Interactions whenever changes are made to Next Steps or Current Status field on CAP Request
        insertCAPInteractions((List<CAP_Request__c>)Trigger.new,(Map<Id,CAP_Request__c>)Trigger.oldMap);
        sendCustomerEmailUpdate((List<CAP_Request__c>)Trigger.new);
        //Send email Notifications on CAP Status Changes
        sendEmailNotifications((List<CAP_Request__c>)Trigger.new,(Map<Id,CAP_Request__c>)Trigger.oldMap);
        //update CAP Level on Parent Account
        updateCAPLevelOnAccount((List<CAP_Request__c>)Trigger.New, (Map<Id,CAP_Request__c>)Trigger.oldMap);
    }

    public override void afterInsert() {
        //update CAP Level on Parent Account
        updateCAPLevelOnAccount((List<CAP_Request__c>)Trigger.New, null);
    }

    public override void beforeInsert() {
        Set<String> capAccountSet = new Set<String>();
        for(CAP_Request__c cap : (List<CAP_Request__c>)Trigger.New) {
            capAccountSet.add(cap.Account__c);
        }
        Map<Id,Account> capAccounts = new Map<Id,Account>([SELECT id,Account_Special_Instructions__c,TAM_Name_New__c,createdById,TAM_Name_New__r.Manager.Email,createdBy.Manager.Email FROM Account WHERE Id IN :capAccountSet]);
        Map<Id, String> managerEmailMap = new Map<Id, String>();

        for(CAP_Request__c cpr : (List<CAP_Request__c>)Trigger.New) {
            managerEmailMap.put(System.UserInfo.getUserId(), '');
            if(String.isNotBlank(cpr.Primary_TAM__c)) {
                managerEmailMap.put(cpr.Primary_TAM__c, '');
            }
        }

        if(!managerEmailMap.isEmpty()) {
            for(User u : [SELECT id,managerId,Manager.Email FROM User WHERE id IN : managerEmailMap.keySet()]) {
                managerEmailMap.put(u.id, u.manager.Email);
            }
        }

        //Update Account Special Instructions on CAP Request
        for(CAP_Request__c cap : (List<CAP_Request__c>)Trigger.New) {
            String ins = capAccounts.get(cap.Account__c).Account_Special_Instructions__c;
            updateAccountSpecialInstruction(cap,ins);
            String tamManagerEmail = managerEmailMap.containsKey(cap.Primary_TAM__c)?managerEmailMap.get(cap.Primary_TAM__c):'';
            String requestorManagerEmail = managerEmailMap.containsKey(System.UserInfo.getUserId())?managerEmailMap.get(System.UserInfo.getUserId()):'';
            populateManagerEmail(cap,tamManagerEmail,requestorManagerEmail);
        }
        //Update Region Email Alias
        populateRegionAliasEmail((List<CAP_Request__c>)Trigger.new,null);
    }

    public override void afterUpdate() {
        //Added by Ankit - CR#4499 CAP 2.0 changes - Start
        handleCAPMilestones((List<CAP_Request__c>)Trigger.New, (Map<Id,CAP_Request__c>)Trigger.oldMap);
        //Added by Ankit - CR#4499 CAP 2.0 changes - End
    }

    //Insert CAP Request Interactions whenever changes are made to Next Steps or Current Status field on CAP Request
    public void insertCAPInteractions(List<CAP_Request__c> newCAPList, Map<Id,CAP_Request__c> oldCAPMap) {
        List<CAP_Request_Interaction__c> capInteractions = new List<CAP_Request_Interaction__c>();
        Map<String, Schema.SObjectField> fieldMap = CAP_Request__c.sObjectType.getDescribe().fields.getMap();
        for(CAP_Request__c cap : newCAPList) {
            //Added by Ankit - CR#4499 CAP 2.0 changes - Start
            if(cap.Status__c != oldCAPMap.get(cap.id).Status__c && cap.Status__c == 'In Progress') {
                cap.CAP_In_Progress_Timestamp__c = System.now();
                cap.Next_In_Progress_Update__c = System.now().addHours(24);
            }
            if(cap.Next_In_Progress_Update__c != oldCAPMap.get(cap.id).Next_In_Progress_Update__c && fieldMap.containsKey('Next_In_Progress_Update__c')) {
                capInteractions.add(new CAP_Request_Interaction__c(field_Name__c = 'Next_In_Progress_Update__c',field_Label__c = fieldMap.get('Next_In_Progress_Update__c').getDescribe().getLabel(),CAP_Request__c = cap.id, new_Value__c = String.valueOf(cap.Next_In_Progress_Update__c), old_Value__c = String.valueOf(oldCAPMap.get(cap.id).Next_In_Progress_Update__c)));
                cap.In_Progress_Updates_Missed__c = false;
            }
            //Added by Ankit - CR#4499 CAP 2.0 changes - End
            if(cap.next_Steps__c != oldCAPMap.get(cap.id).next_Steps__c && fieldMap.containsKey('Next_Steps__c')) {
                capInteractions.add(new CAP_Request_Interaction__c(field_Name__c = 'Next_Steps__c',field_Label__c = fieldMap.get('Next_Steps__c').getDescribe().getLabel(),CAP_Request__c = cap.id, new_Value__c = cap.next_Steps__c, old_Value__c = oldCAPMap.get(cap.id).next_Steps__c));
                cap.In_Progress_Updates_Missed__c = false;
                cap.CAP_In_Progress_Timestamp__c = System.now();
            }
            if(cap.current_Status__c != oldCAPMap.get(cap.id).current_Status__c && fieldMap.containsKey('Current_Status__c')) {
                capInteractions.add(new CAP_Request_Interaction__c(field_Name__c = 'Current_Status__c', field_Label__c=fieldMap.get('Current_Status__c').getDescribe().getLabel(), CAP_Request__c = cap.id, new_Value__c = cap.current_Status__c, old_Value__c = oldCAPMap.get(cap.id).current_Status__c));
                cap.In_Progress_Updates_Missed__c = false;
                cap.CAP_In_Progress_Timestamp__c = System.now();

                //Added By Bhagyalaxmi for IBA-3069 - Start
                cap.Last_Current_Status_Update__c = System.now();                
                //Added By Bhagyalaxmi for IBA-3069 - End
                
            }
            if(cap.Additional_Technical_Details__c != oldCAPMap.get(cap.id).Additional_Technical_Details__c && fieldMap.containsKey('Additional_Technical_Details__c')) {
                capInteractions.add(new CAP_Request_Interaction__c(field_Name__c = 'Additional_Technical_Details__c', field_Label__c=fieldMap.get('Additional_Technical_Details__c').getDescribe().getLabel(), CAP_Request__c = cap.id, new_Value__c = cap.Additional_Technical_Details__c, old_Value__c = oldCAPMap.get(cap.id).Additional_Technical_Details__c));
                cap.In_Progress_Updates_Missed__c = false;
                cap.CAP_In_Progress_Timestamp__c = System.now();
            }
            if(cap.Exec_Summary__c != oldCAPMap.get(cap.id).Exec_Summary__c && fieldMap.containsKey('Exec_Summary__c')) {
                capInteractions.add(new CAP_Request_Interaction__c(field_Name__c = 'Exec_Summary__c', field_Label__c=fieldMap.get('Exec_Summary__c').getDescribe().getLabel(), CAP_Request__c = cap.id, new_Value__c = cap.Exec_Summary__c, old_Value__c = oldCAPMap.get(cap.id).Exec_Summary__c));
                cap.In_Progress_Updates_Missed__c = false;
                cap.CAP_In_Progress_Timestamp__c = System.now();
            }

            
            
            //Add Error if Approved/Rejected from Approval History
            addErrorApproval(cap);
            //Set Slack Channel Status to Creation Pending when Status is Set to Planning
            setSlackChannelStatus(cap);
            //Add Error when only 12 Hrs remain from CAP Call
            //addErrorRaiseForCAPCall(cap);
        }
        if(!capInteractions.isEmpty()) {
            insert capInteractions;
        }
    }

    public void addErrorApproval(CAP_Request__c capReq) {
        CAP_Request__c capOld = (CAP_Request__c)Trigger.oldMap.get(capReq.id);
        if((capReq.status__c == 'Planning' || capReq.status__c == 'Rejected') && capReq.status__c != capOld.status__c) {
            if(!capReq.Approval_Action_from_cmp__c) {
                capReq.addError('You can only Approve/Reject a CAP Request from the Edit CAP Request Page.');
            }
            else {
                capReq.Approval_Action_from_Cmp__c = false;
            }
        }
    }

    public void setSlackChannelStatus(CAP_Request__c capReq) {
        CAP_Request__c capOld = (CAP_Request__c)Trigger.oldMap.get(capReq.id);
        if(capReq.status__c == 'Planning' && capReq.status__c != capOld.status__c) {
            capReq.slack_Channel_Status__c = 'Creation Pending';
        }
    }

    public static void sendCustomerEmailUpdate(List<CAP_Request__c> requests) {
        String emailTemplate = [SELECT Id, Name, DeveloperName, IsActive, HtmlValue, Body, Subject FROM EmailTemplate WHERE DeveloperName = 'CAP_Req_Customer_Update_Notification' AND isActive= true LIMIT 1].id;
        List< Messaging.SingleEmailMessage> emails = new List< Messaging.SingleEmailMessage>();
        List<String> requestIds = new List<String>();
        Set<String> capsToBeUpdated = new Set<String>();
        for(CAP_Request__c cr: requests) {
            if(cr.send_Customer_email_Update__c) {
                List<String> ccList = new List<String>();
                if(String.isNotBlank(cr.CAP_CC_List__c)) {
                    ccList = cr.CAP_CC_List__c.split(',');
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(emailTemplate);
                mail.setWhatId(cr.id);
                mail.setTargetObjectId(cr.Customer_Main_POC_for_Communication__c);
                mail.setTreatTargetObjectAsRecipient(true);
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                mail.setCCAddresses(ccList);
                emails.add( mail );
                requestIds.add(cr.id);
            }
        }
        Messaging.SendEmailResult[] result = Messaging.sendEmail(emails);
        Integer index = 0;
        for(Messaging.SendEmailResult res : result) {
            if(res.isSuccess()) {
                capsToBeUpdated.add(requestIds.get(index));
            }
            index++;
        }
        for(CAP_Request__c cp : requests) {
            if(capsToBeUpdated.contains(cp.id)) {
                cp.send_Customer_email_Update__c = false;
                cp.Last_Email_Sent__c = System.now();
            }
        }
    }  
    
    public static void updateCAPLevelOnAccount(List<CAP_Request__c> capRequests, Map<Id,CAP_Request__c> oldMapCapRequests) {
        Map<String,Account> accMap = new Map<String,Account>();
        for(CAP_Request__c cap : capRequests) {
            if(oldMapCapRequests==null || (!oldMapCapRequests.isEmpty() && cap.CAP_Level__c != oldMapCapRequests.get(cap.id).cap_Level__c )) {
                accMap.put(cap.Account__c,new Account(Id = cap.Account__c, CAP_Level__c = cap.CAP_Level__c));
            }
            if(cap.Status__c == 'Closed') {
                accMap.put(cap.Account__c,new Account(Id = cap.Account__c, CAP_Level__c = ''));
            }
        }
        if(!accMap.isEmpty()) {
           update accMap.values();
        }
    }

    /*public void addErrorRaiseForCAPCall(CAP_Request__c capReq) {
        CAP_Request__c capOld = (CAP_Request__c)Trigger.oldMap.get(capReq.id);
        if(capReq.Raise_For_CAP_Call__c != capOld.Raise_For_CAP_Call__c && capReq.Raise_For_CAP_Call__c) {
            if(isErrorRaiseForCAPCall() && !Test.isRunningTest()) {
                capReq.addError('There is less than 12 hours before the CAP Review Meeting and you cannot update the flag now');
            }
        }
    }*/

    public static Boolean isErrorRaiseForCAPCall() {
        Boolean result = false;
        Timezone pstTz = Timezone.getTimeZone('America/Los_Angeles');
        DateTime currentTimePstTz = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000));
        Integer hourNow = currentTimePstTz.hourGmt();
        String formattedTime = System.now().format('EEE, yyyy-MM-dd HH:mm:ss','America/Los_Angeles');
        String dayOfWeek_currentTimePstTz = formattedTime.split(',').get(0);  
        if(dayOfWeek_currentTimePstTz == 'Tue' || Test.isRunningTest()) {
            DateTime twelveHrsFromNow =  Datetime.now().addHours(12).addSeconds((pstTz.getOffset(Datetime.now())/1000));
            String twelveHrsFromNow_formattedTime =System.now().addHours(12).format('EEE, yyyy-MM-dd HH:mm:ss','America/Los_Angeles');
            String dayOfWeek_twelveHrsFromNow = twelveHrsFromNow_formattedTime.split(',').get(0); 
            Integer hour_twelveHrsFromNow = twelveHrsFromNow.hourGmt();
            if(dayOfWeek_twelveHrsFromNow == 'Wed' && hour_twelveHrsFromNow < 8) {
                result = true;
            }
        }
        else if(dayOfWeek_currentTimePstTz == 'Wed'){
            if(hourNow < 8) {
                result = true;
            }
        }
        return result;    
    }

    public void updateAccountSpecialInstruction(CAP_Request__c cap, String ins) {
       cap.Account_Special_Instructions__c = ins;
    }

    public void populateManagerEmail(CAP_Request__c cap, String tamManagerEmail, String requestorManagerEmail) {
        cap.Primary_TAM_Manager_s_Email__c = String.isNotBlank(tamManagerEmail)?tamManagerEmail:'';
        cap.Requestor_Manager_s_Email__c = String.isNotBlank(requestorManagerEmail)?requestorManagerEmail:'';
    }

    public void populateRegionAliasEmail(List<CAP_Request__c> capRequests, Map<Id,CAP_Request__c> oldMapCapRequests) {
        //Region from CAP Region Alias Config 
        List<CAP_Request_Region_Alias_Configuration__mdt> capReqRegionAliasConfigs = new List<CAP_Request_Region_Alias_Configuration__mdt>([SELECT id,DeveloperName,MasterLabel,Email_Address__c FROM CAP_Request_Region_Alias_Configuration__mdt]); 
        Map<String,String> regionAliasEmailMap = new Map<String,String>();
        if(!capReqRegionAliasConfigs.isEmpty()) {
            for(CAP_Request_Region_Alias_Configuration__mdt cmt : capReqRegionAliasConfigs) {
                regionAliasEmailMap.put(cmt.MasterLabel, cmt.Email_Address__c);
            }
        }
        //Region from CAP Region Alias Config 

        for(CAP_Request__c cap : capRequests) {
             //Populate Region Alias Email on CAP 
             if(!regionAliasEmailMap.isEmpty()) {
                if(oldMapCapRequests==null || (!oldMapCapRequests.isEmpty() && cap.Region__c != oldMapCapRequests.get(cap.id).Region__c )) {
                    if(String.isNotBlank(cap.Region__c) && regionAliasEmailMap.containsKey(cap.Region__c)) {
                        cap.CAP_Region_Alias__c = regionAliasEmailMap.get(cap.Region__c);
                    }
                    else {
                        cap.CAP_Region_Alias__c = '';
                    }
                }
            }
            //Populate Region Alias Email on CAP 
        }
    }
    
    //Send Email Notifications on CAP Status Changes
    public static void sendEmailNotifications(List<CAP_Request__c> requests, Map<Id,CAP_Request__c> oldCAPMap) {
        List<String> templateNames = new List<String>{'CAP_Req_CAP_Status_change_In_Progress','CAP_Req_CAP_Progress_Update','CAP_Req_CAP_Request_Resolved','CAP_Req_CAP_Exec_Update_CAP_1_Account_Resolved'};
        String tamDirectorVP = System.Label.TAM_Director_VP_List_for_CAP;
        String supportDirectorVP = System.Label.Support_Director_VP_List_for_CAP;
        List<String> tamDirectorVPList = new List<String>();
        List<String> supportDirectorVPList = new List<String>();

        if(String.isNotBlank(tamDirectorVP)) {
            tamDirectorVPList = tamDirectorVP.split(',');
        }
        if(String.isNotBlank(supportDirectorVP)) {
            supportDirectorVPList = supportDirectorVP.split(',');
        }

        Map<String,String> emailTemplates = new Map<String, String>();
        for(EmailTemplate et : [SELECT Id, Name, DeveloperName, IsActive, HtmlValue, Body, Subject 
                                FROM EmailTemplate 
                                WHERE DeveloperName IN :templateNames AND isActive= true]) {
            emailTemplates.put(et.DeveloperName, et.Id);
        }

        List<OrgWideEmailAddress> orgEmails = new List<OrgWideEmailAddress>([SELECT id,address FROM OrgWideEmailAddress WHERE address = 'z-salesforce@zscaler.com']);
        List< Messaging.SingleEmailMessage> emails = new List< Messaging.SingleEmailMessage>();
        
        for(CAP_Request__c cr: requests) {
            List<String> ccList = new List<String>();
            if(String.isNotBlank(cr.CAP_CC_List__c)) {
                ccList = cr.CAP_CC_List__c.split(',');
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setWhatId(cr.id);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(cr.Customer_Main_POC_for_Communication__c);
            mail.setTreatTargetObjectAsRecipient(false);
            if(!orgEmails.isEmpty()) {
                mail.setOrgWideEmailAddressId(orgEmails.get(0).Id);
            }
            if(cr.Status__c == 'In Progress') {
                if(cr.Status__c != oldCAPMap.get(cr.Id).Status__c) {
                    //Status changed to In Progress
                    String templateId = emailTemplates.containsKey('CAP_Req_CAP_Status_change_In_Progress')?emailTemplates.get('CAP_Req_CAP_Status_change_In_Progress'):'';
                    mail.setTemplateId(templateId);
                    mail.setToAddresses(new List<String>{cr.CreatedById, cr.CAP_Manager__c});
                    mail.setCCAddresses(ccList);
                    emails.add( mail);
                }
                else if(cr.next_Steps__c != oldCAPMap.get(cr.id).next_Steps__c ||
                        cr.current_Status__c != oldCAPMap.get(cr.id).current_Status__c || 
                        cr.Additional_Technical_Details__c != oldCAPMap.get(cr.id).Additional_Technical_Details__c|| 
                        cr.Exec_Summary__c != oldCAPMap.get(cr.id).Exec_Summary__c) {
                    String templateId = emailTemplates.containsKey('CAP_Req_CAP_Progress_Update')?emailTemplates.get('CAP_Req_CAP_Progress_Update'):'';
                    mail.setTemplateId(templateId);
                    mail.setToAddresses(new List<String>{cr.CreatedById, cr.CAP_Manager__c});
                    if(cr.CAP_Level__c == 'Level 2') {
                        List<String> completeCCList = new List<String>();
                        completeCCList.addAll(ccList);
                        if(String.isNotBlank(cr.Requestor_Manager_s_Email__c)) {
                            completeCCList.add(cr.Requestor_Manager_s_Email__c);                            
                        }
                        mail.setCCAddresses(completeCCList);
                    }
                    else if(cr.CAP_Level__c == 'Level 1') {
                        List<String> completeCCList = new List<String>();
                        completeCCList.addAll(ccList);
                        if(String.isNotBlank(cr.Requestor_Manager_s_Email__c)) {
                            completeCCList.add(cr.Requestor_Manager_s_Email__c);                            
                        }
                        if(cr.is_TAM_Account__c && !tamDirectorVPList.isEmpty()) {
                            completeCCList.addAll(tamDirectorVPList);                            
                        }
                        if(!cr.is_TAM_Account__c && !supportDirectorVPList.isEmpty()) {
                            completeCCList.addAll(tamDirectorVPList);                            
                        }
                        mail.setCCAddresses(completeCCList);
                    }
                    else if(cr.CAP_Level__c == 'Level 3') {
                        mail.setCCAddresses(ccList);
                    }
                    emails.add( mail);
                }
            }
            if(cr.Resolution_Summary__c != oldCAPMap.get(cr.Id).Resolution_Summary__c) {
                //Status changed to Resolved
                String templateId = emailTemplates.containsKey('CAP_Req_CAP_Request_Resolved')?emailTemplates.get('CAP_Req_CAP_Request_Resolved'):'';
                String cap1TemplateId = emailTemplates.containsKey('CAP_Req_CAP_Exec_Update_CAP_1_Account_Resolved')?emailTemplates.get('CAP_Req_CAP_Exec_Update_CAP_1_Account_Resolved'):'';
                mail.setToAddresses(new List<String>{cr.CreatedById, cr.CAP_Manager__c});
                if(cr.CAP_Level__c == 'Level 2') {
                    List<String> completeCCList = new List<String>();
                    completeCCList.addAll(ccList);
                    if(String.isNotBlank(cr.Requestor_Manager_s_Email__c)) {
                        completeCCList.add(cr.Requestor_Manager_s_Email__c);                            
                    }
                    mail.setCCAddresses(completeCCList);
                    mail.setTemplateId(templateId);   
                }
                else if(cr.CAP_Level__c == 'Level 1') {
                    List<String> completeCCList = new List<String>();
                    completeCCList.addAll(ccList);
                    if(String.isNotBlank(cr.Requestor_Manager_s_Email__c)) {
                        completeCCList.add(cr.Requestor_Manager_s_Email__c);                            
                    }
                    if(cr.is_TAM_Account__c && !tamDirectorVPList.isEmpty()) {
                        completeCCList.addAll(tamDirectorVPList);                            
                    }
                    if(!cr.is_TAM_Account__c && !supportDirectorVPList.isEmpty()) {
                        completeCCList.addAll(tamDirectorVPList);                            
                    }
                    mail.setCCAddresses(completeCCList);
                    mail.setTemplateId(cap1TemplateId);
                }
                else if(cr.CAP_Level__c == 'Level 3') {
                    mail.setCCAddresses(ccList);
                    mail.setTemplateId(templateId);
                }
                emails.add( mail);
            }
        }
        if(!emails.isEmpty() && !Test.isRunningTest()) {
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emails);
        }
    } 

    //Added by Ankit - CR#4499 CAP 2.0 changes - Start
    public static void handleCAPMilestones(List<CAP_Request__c> requests, Map<Id,CAP_Request__c> oldCAPMap) {
        Map<String,List<Milestone__c>> capMilestoneMap = new Map<String, List<Milestone__c>>();
        Id capReqRecordTypeId = Schema.SObjectType.Milestone__c.getRecordTypeInfosByDeveloperName().get('CAP_Request').getRecordTypeId();
        Datetime targetTimestamp;
        String milestoneType = '';
        for(Milestone__c m : [  SELECT id,CAP_Request__c,Completion_Datetime__c,is_Completed__c,
                                is_Violated__c,Milestone_Type__c,Start_Datetime__c,Target_Datetime__c 
                                FROM Milestone__c WHERE CAP_Request__c IN : oldCAPMap.keySet() AND RecordType.DeveloperName = 'CAP_Request' 
                                AND Completion_Datetime__c = null]) {
            if(!capMilestoneMap.containsKey(m.CAP_Request__c)) {
                capMilestoneMap.put(m.CAP_Request__c, new List<Milestone__c>());
            }                           
            capMilestoneMap.get(m.CAP_Request__c).add(m);
        }

        //CAP Status is changed
        List<Milestone__c> newMilestones = new List<Milestone__c>();
        List<Milestone__c> existingMilestones = new List<Milestone__c>();
        for(CAP_Request__c req : requests) {
            if(req.status__c != oldCAPMap.get(req.id).status__c) { 
                milestoneType = req.status__c;
                
                if(capMilestoneMap.containsKey(req.id)) {
                    for(Milestone__c m : capMilestoneMap.get(req.id)) {
                        if(m.Milestone_Type__c == oldCAPMap.get(req.id).status__c) {
                            m.Completion_Datetime__c = System.now();
                            existingMilestones.add(m);
                        }
                        else if(m.Milestone_Type__c == 'Resolved') {
                            m.Completion_Datetime__c = System.now();
                            existingMilestones.add(m);
                        }
                    }
                }
                if(req.CAP_Level__c == 'Level 3') {
                    if(req.Status__c == 'Submitted') {
                        targetTimestamp = System.now().addHours(4);
                        //targetTimestamp = System.now().addMinutes(20);
                    }
                    else if(req.Status__c == 'Planning') {
                        targetTimestamp = System.now().addHours(24);
                        //targetTimestamp = System.now().addMinutes(5);
                    }
                    else if(req.Status__c == 'Post Mortem') {
                        targetTimestamp = System.now().addHours(48);
                        //targetTimestamp = System.now().addMinutes(5);
                    }

                }
                else if(req.CAP_Level__c == 'Level 2') {
                    if(req.Status__c == 'Submitted') {
                        targetTimestamp = System.now().addHours(2);
                        //targetTimestamp = System.now().addMinutes(5);
                    }
                    else if(req.Status__c == 'Planning') {
                        targetTimestamp = System.now().addHours(24);
                        //targetTimestamp = System.now().addMinutes(5);
                    }
                    else if(req.Status__c == 'Post Mortem') {
                        targetTimestamp = System.now().addHours(48);
                        //targetTimestamp = System.now().addMinutes(5);
                    }
                }
                else if(req.CAP_Level__c == 'Level 1') {
                    if(req.Status__c == 'Submitted') {
                        targetTimestamp = System.now().addHours(1);
                        //targetTimestamp = System.now().addMinutes(5);
                    }
                    else if(req.Status__c == 'Planning') {
                        targetTimestamp = System.now().addHours(24);
                        //targetTimestamp = System.now().addMinutes(5);
                    }
                    else if(req.Status__c == 'Post Mortem') {
                        targetTimestamp = System.now().addHours(48);
                        //targetTimestamp = System.now().addMinutes(5);
                    }
                }
                if(targetTimestamp != null) {
                    Milestone__c newMilestone = new Milestone__c(Milestone_Type__c = milestoneType, 
                                                CAP_Request__c = req.id,
                                                Start_Datetime__c = System.now(),
                                                Target_Datetime__c = targetTimestamp,
                                                RecordTypeId = capReqRecordTypeId,
                                                CAP_Current_Situation_Summary__c = req.Current_Situation_Summary__c,
                                                CAP_Owner__c = req.CAP_Manager__c,
                                                CAP_Products__c = req.Products__c);
                    newMilestones.add(newMilestone);
                }
                if(milestoneType == 'In Progress') {
                    Integer estimatedEngagementTime = 30;
                    if(req.Estimated_Engagement_Time__c != null) {
                        estimatedEngagementTime = Integer.valueOf(req.Estimated_Engagement_Time__c);
                    }
                    Milestone__c resolvedMilestone = new Milestone__c(Milestone_Type__c = 'Resolved', 
                                            CAP_Request__c = req.id,
                                            Start_Datetime__c = System.now(),
                                            Target_Datetime__c = System.now().addDays(estimatedEngagementTime),
                                            RecordTypeId = capReqRecordTypeId,
                                            CAP_Current_Situation_Summary__c = req.Current_Situation_Summary__c,
                                            CAP_Owner__c = req.CAP_Manager__c,
                                            CAP_Products__c = req.Products__c);
                    newMilestones.add(resolvedMilestone);
                }
            }
        }
        if(!existingMilestones.isEmpty()) {
            update existingMilestones;
        }
        if(!newMilestones.isEmpty()) {  
            insert newMilestones;
        }
    }
    //Added by Ankit - CR#4499 CAP 2.0 changes - End
}