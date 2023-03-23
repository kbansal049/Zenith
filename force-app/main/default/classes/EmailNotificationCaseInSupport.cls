global class EmailNotificationCaseInSupport implements Schedulable {
global void execute(SchedulableContext SC) {
    Id supportQueueId = [SELECT Id FROM Group where type = 'Queue'  and DeveloperName = 'Support_Queue'].Id;
    DateTime nowD = System.now();
    nowD = nowD.addMinutes(-5);

    List<Case> lstCases = [select id,Case_Assign_to_Support_Queue__c,ContactId,Account_Name__c ,CaseNumber,Account.name,Is_TAM_Account__c  ,Priority,Customer_Score__c ,Primary_Support__c  from Case where OwnerId =:supportQueueId and Case_Assign_to_Support_Queue__c  <= : nowD order by Case_Assign_to_Support_Queue__c asc];
    if(Test.isRunningTest())  {
        lstCases = [select id,Case_Assign_to_Support_Queue__c,ContactId,Account_Name__c ,CaseNumber,Account.name,Is_TAM_Account__c  ,Priority,Customer_Score__c ,Primary_Support__c  from Case  order by Case_Assign_to_Support_Queue__c asc];
    }
    if(lstCases.size() == 0)  {
        return;
    }
    EmailTemplate case5mnt = [select id,HtmlValue,subject from EmailTemplate where DeveloperName = 'case_in_support_queue_for_5_minute'];
    
    OrgWideEmailAddress ow = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where address = 'support@zscaler.com'];
    List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
    List<String> lstTo = new List<String>(); 
    
    Email_in_Support_Queue__mdt[] emailIds = [SELECT Email_Id__c  FROM Email_in_Support_Queue__mdt where Email_Id__c  != null and Is_Active__c =true ];
    if(emailIds.size() > 0)  {
        for(Email_in_Support_Queue__mdt ed : emailIds)  {
            lstTo.add(ed.Email_Id__c);
        }
    }else  {
        lstTo.add('z-gcs-tac-leaders@zscaler.com');
        lstTo.add('z-tac-ind-leads@zscaler.com');    
    }
    
    String htmlBody = case5mnt.HtmlValue;
    String replaceMe = '<table border=\'1\' width=\'80%\'> <tr> <td>Case # </td> <td>Account </td> <td> TAM Account</td> <td> Priority </td> <td> Case Score </td><td>  Primary Skills </td> <td> Waiting (in mins) </td> </tr>';
    Boolean sendEmail = false;
    for(Case c :  lstCases)  {
        sendEmail = true;
        Long dt1Long = c.Case_Assign_to_Support_Queue__c.getTime();
        Long dt2Long = DateTime.now().getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        
        replaceMe += '<tr> <td> '+c.CaseNumber +' </td> <td> '+ (c.Account_Name__c != null ? c.Account_Name__c : '' )+' </td> <td> '+ (c.Is_TAM_Account__c?'Yes':'No')  +' </td> <td> '+ ( c.Priority != null ? c.Priority : ''  )+' </td> <td> '+ (c.Customer_Score__c !=null ? c.Customer_Score__c+'' :'')  +' </td> <td> '+(c.Primary_Support__c != null?c.Primary_Support__c:'')  +' </td> <td> '+minutes+' </td> </tr> '; 
    }
    
    replaceMe += '</table>';
    
    if(sendEmail)  {
        htmlBody = htmlBody.replace('[CASE_TABLE]', replaceMe);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(ow.id);
        mail.setHtmlBody(htmlBody);
        mail.setSubject(case5mnt.subject);
        mail.setToAddresses(lstTo);
        mail.setSaveAsActivity(false);
        messageList.add(mail);
        if(messageList.size()>0){
            if(!Test.isRunningTest())
            Messaging.sendEmail(messageList); 
        }
    }
    //Reset the Session Id
    /*Customer_Portal_Session_Id__c cp = Customer_Portal_Session_Id__c.getOrgDefaults();
    Integer len = 11;
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String sessionId = key.substring(0,len);
    if(cp.Last_Reset_Timestamp__c==null){
        cp.Session_Id__c=sessionId;
        cp.Last_Reset_Timestamp__c=DateTime.now();
    }
    else{
        Long resetTimestamp = cp.Last_Reset_Timestamp__c.getTime();
        Long currentTime = DateTime.now().getTime();
        Long timeDifference = (currentTime-resetTimestamp)/60000;
        if(timeDifference>Integer.ValueOf(System.Label.Timestamp_Expire) || cp.Last_Reset_Timestamp__c==null){
        cp.Session_Id__c=sessionId;
        cp.Last_Reset_Timestamp__c=DateTime.now();
        }
    }
    update cp;*/      
}
}