global class EmailNotificationCaseInSupportBatch implements Database.Batchable<SObject>,  Database.Stateful {
    static final String APEX_CLASS_NAME = 'EmailNotificationCaseInSupportBatch';
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('EmailNotificationCaseInSupportBatch');

    final static String TR_START = '<tr>';
    final static String TR_END = ' </tr> ';
    final static String TD_START = '<td>';
    final static String TD_END = '</td>';

    global Database.QueryLocator start(Database.BatchableContext bc){
        this.zscalerBatchFrameWorkObj.callStart();
        
        Id supportQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Support_Queue'].Id;
        DateTime nowD = System.now();
        nowD = nowD.addMinutes(-5);
        
        String query = 'SELECT Id, Case_Assign_to_Support_Queue__c, ContactId,Account_Name__c, CaseNumber, Account.Name,' 
                        + ' Is_TAM_Account__c, Priority, Customer_Score__c, Primary_Support__c' 
                        + ' FROM Case WHERE OwnerId = :supportQueueId ' 
                        + ' AND Case_Assign_to_Support_Queue__c <= :nowD ' 
                        + ' ORDER BY Case_Assign_to_Support_Queue__c ASC';
        if (Test.isRunningTest()) {
            query = 'SELECT Id, Case_Assign_to_Support_Queue__c, ContactId,Account_Name__c, CaseNumber, Account.Name,' 
                        + ' Is_TAM_Account__c, Priority,Customer_Score__c, Primary_Support__c ' 
                        + ' FROM Case ' 
                        + ' ORDER BY Case_Assign_to_Support_Queue__c ASC';
        }
        return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext bc, List<Case> lstCases){
        final String METHOD_NAME = 'execute';
        this.zscalerBatchFrameWorkObj.callExecute(lstCases[0]?.Id, lstCases.size());
        try {
            if (!lstCases.isEmpty()) {
                EmailTemplate case5mnt = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'case_in_support_queue_for_5_minute'];
                OrgWideEmailAddress ow = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :GCSCommonConstants.ZS_SUPPORT_EMAIL_ID];
                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
                List<String> lstTo = new List<String>(); 
                
                Email_in_Support_Queue__mdt[] emailIds = [SELECT Email_Id__c 
                                                            FROM Email_in_Support_Queue__mdt 
                                                            WHERE Email_Id__c != null 
                                                            AND Is_Active__c = true];
                if(!emailIds.isEmpty()) {
                    for(Email_in_Support_Queue__mdt ed : emailIds) {
                        lstTo.add(ed.Email_Id__c);
                    }
                }else{
                    lstTo.add(GCSCommonConstants.ZS_GCS_TAC_LEADERS_EMAIL_ID);
                    lstTo.add(GCSCommonConstants.ZS_TAC_IND_LEAD_EMAIL_ID);
                }

                String htmlBody = case5mnt.HtmlValue;
                String replaceMe = '<table border=\'1\' width=\'80%\'> ' 
                                    + TR_START 
                                        + TD_START + ' Case # ' + TD_END
                                        + TD_START + ' Account ' + TD_END
                                        + TD_START + ' TAM Account ' + TD_END
                                        + TD_START + ' Priority ' + TD_END
                                        + TD_START + ' Case Score ' + TD_END
                                        + TD_START + ' Primary Skills ' + TD_END
                                        + TD_START + ' Waiting (in mins) ' + TD_END
                                    + TR_END;
                Boolean sendEmail = false;
                for(Case c : lstCases) {
                    sendEmail = true;
                    Long dt1Long = c.Case_Assign_to_Support_Queue__c.getTime();
                    Long dt2Long = DateTime.now().getTime();
                    Long milliseconds = dt2Long - dt1Long;
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    
                    replaceMe += TR_START 
                                    + TD_START + c.CaseNumber + TD_END
                                    + TD_START + (c.Account_Name__c != null ? c.Account_Name__c : GCSCommonConstants.EMPTY_STRING) + TD_END
                                    + TD_START + (c.Is_TAM_Account__c?'Yes':'No') + TD_END
                                    + TD_START + ( c.Priority != null ? c.Priority : GCSCommonConstants.EMPTY_STRING) + TD_END
                                    + TD_START + (c.Customer_Score__c != null ? c.Customer_Score__c + GCSCommonConstants.EMPTY_STRING : GCSCommonConstants.EMPTY_STRING) + TD_END
                                    + TD_START + (c.Primary_Support__c != null?c.Primary_Support__c : GCSCommonConstants.EMPTY_STRING) + TD_END
                                    + TD_START + minutes + TD_END
                                + TR_END; 
                }
                replaceMe += '</table>';

                if(sendEmail) {
                    htmlBody = htmlBody.replace('[CASE_TABLE]', replaceMe);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setOrgWideEmailAddressId(ow.id);
                    mail.setHtmlBody(htmlBody);
                    mail.setSubject(case5mnt.subject);
                    mail.setToAddresses(lstTo);
                    mail.setSaveAsActivity(false);
                    messageList.add(mail);
                }
                if(!messageList.isEmpty() && !Test.isRunningTest()){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList);
                    GCSCommonUtility.logSendEmailError(results, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }catch(Exception e) {
            //GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                //GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
            System.assert(false,'error message is -->'+e.getLineNumber()+e.getMessage());
        }
    }
  
    global void finish(Database.BatchableContext bc){
        this.zscalerBatchFrameWorkObj.callFinish(bc);
    }
}