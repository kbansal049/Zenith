/*****************************************************************************************
Name: PSCredit_PSCreditTriggerHelper
Copyright © Zscaler
------------------------------------------------------------------------------------------
Purpose:
--------
1. Apex trigger helper for Professional_Services_Credits__c to update Total Purchased Credits
On Account of valid Professional_Services_Credits__c
------------------------------------------------------------------------------------------
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        17/05/2022      CR#4745      PS Credits Redemption Process && PS Credits Redemption Validation.
2.0                Harish Gowda N       13/07/2022      IBA-1099     Create Training credits when opportunity with Training Credit SKU is closed won.
3.0                Harish Gowda N       13/10/2022      IBA-3769     Training Credits Redemption Process.
4.0                Harish Gowda N       23/10/2022      IBA-4122     Move PS Credits from Account to Account Extension.
5.0                Sachin Tandon        27/12/2022      CR#5449     Added capability to support Total Available PS Credits On Account Extension
6.0                Karthik Pullagurla	13/12/2022      IBA-5630     Additional Code Check to handle in Sandbox environments.
******************************************************************************************/ 
public class PSCredit_PSCreditTriggerHelper {
    
    public static Boolean isSandbox {
        get {
            if(isSandbox == null){
               String sandboxName = DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName();  
                if(!String.isEmpty(sandboxName) && !Test.isRunningTest()){ 
                    isSandbox = true;
                }else{
                    isSandbox = false;
                } 
            }
            return isSandbox;
        }
        set;}
    
    public static void updateTotalPurchasedCreditsOnAccount(Map<Id,Professional_Services_Credits__c> oldPSCreditsByPSCreditId , Map<Id,Professional_Services_Credits__c> newPSCreditsByPSCreditId){
        
        List<Professional_Services_Credits__c> validPSCredits = new List<Professional_Services_Credits__c>();
        for(Professional_Services_Credits__c newPSCredit : newPSCreditsByPSCreditId.values()) {
            Professional_Services_Credits__c oldPSCredit = oldPSCreditsByPSCreditId.get(newPSCredit.Id);
            //IBA-6122 : Early Engagement Project : Start
            if(oldPSCredit.Credits_Expiration_Date__c != newPSCredit.Credits_Expiration_Date__c || oldPSCredit.EE_Credit__c != newPSCredit.EE_Credit__c) {
                validPSCredits.add(newPSCredit);
            } 
        }
        
        if(!validPSCredits.isEmpty()) {
            updateTotalPurchasedCreditsOnAccount(validPSCredits);
        }
    }
    
    public static void updateTotalPurchasedCreditsOnAccount(List<Professional_Services_Credits__c> newPSCredits){
        
        Set<Id> accountIds = getAccountIds(newPSCredits);
        if(accountIds.isEmpty()) {return;}
        List<Account_Extension__c> accountExtensionsToBeUpdated = getAccountExtensionsToBeUpdated(accountIds);
        
        //This is to update total purchased training credits on Account extension related to Account.
        MAP<Id,Account_Extension__c> accountExtensionMap = new MAP<Id,Account_Extension__c>();
        accountExtensionMap.putall(accountExtensionsToBeUpdated);
        if(!accountExtensionMap.isEmpty()){
            update accountExtensionMap.values();
        }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA Ticket - IBA-3769     Training Credits Redemption Process.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : updateTotalRedeemedCreditsOnAccount .
* @param    NAME : Map<Id,Professional_Services_Credits__c> oldPSCreditsByPSCreditId , Map<Id,Professional_Services_Credits__c> newPSCreditsByPSCreditId .
* @return   TYPE : void .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void updateTotalRedeemedCreditsOnAccount(Map<Id,Professional_Services_Credits__c> oldPSCreditsByPSCreditId , Map<Id,Professional_Services_Credits__c> newPSCreditsByPSCreditId){
        
        List<Professional_Services_Credits__c> redeemedTrainingCredits = new List<Professional_Services_Credits__c>();
        for(Professional_Services_Credits__c newPSCredit : newPSCreditsByPSCreditId.values()) {
            Professional_Services_Credits__c oldPSCredit = oldPSCreditsByPSCreditId.get(newPSCredit.Id);
            if(oldPSCredit.Credits_Redeemed__c != newPSCredit.Credits_Redeemed__c || oldPSCredit.EE_Credit__c != newPSCredit.EE_Credit__c) {
                redeemedTrainingCredits.add(newPSCredit);
            } 
        }
        
        if(!redeemedTrainingCredits.isEmpty()) {
            updateTotalRedeemedTrainingCreditsOnAccount(redeemedTrainingCredits);
        }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of  JIRA Ticket - IBA-3769     Training Credits Redemption Process.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : updateTotalRedeemedTrainingCreditsOnAccount .
* @param    NAME : List<Professional_Services_Credits__c> newPSCredits .
* @return   TYPE : void .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/    
    public static void updateTotalRedeemedTrainingCreditsOnAccount(List<Professional_Services_Credits__c> newPSCredits){
        
        Set<Id> accountIds = getAccountIds(newPSCredits);
        if(accountIds.isEmpty()) {return;}
        List<Account_Extension__c> accountExtensionsToBeUpdated = getAccountExtensionsToBeUpdated(accountIds);
        MAP<Id,Account_Extension__c> accountExtensionMap = new MAP<Id,Account_Extension__c>();
        accountExtensionMap.putall(accountExtensionsToBeUpdated);
        if(!accountExtensionMap.isEmpty()){
            update accountExtensionMap.values();
        } 
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-1431 : Send email notification to customer when 
*                                                     training credits are purchased.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : sendTrainingCreditsInsertEmail .
* @param    NAME : List<Professional_Services_Credits__c> newPSCreditsToSendEmail .
* @return   TYPE : void .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void sendTrainingCreditsInsertEmail(List<Professional_Services_Credits__c> newPSCreditsToSendEmail){
        
        try{
            Set<Id> trainingCreditsRecordIdSet = New Set<Id>();
            List<Professional_Services_Credits__c> trainingCreditsRecordsToSendEmail = New List<Professional_Services_Credits__c>();
            List<Account_Extension__c> accountExtensionList = New List<Account_Extension__c>();
            Set<Id> accountIdSet = New  Set<Id>();
            Map<Id, String> accountIdWithServiceOwnerContactMap = new Map<Id, String>(); 

            // IBA-6010 START
            List<String> ccAddressesList = new List<String>();
            EmailUtility fedAccountsEmailUtility = new EmailUtility(L2O_Constants.EmailTemplateInfo.TRAINING_CREDITS_CREATED_FOR_FED_ACCOUNT_EMAIL_CONFIG);
            EmailUtility nonFedAccountsEmailUtility = new EmailUtility(L2O_Constants.EmailTemplateInfo.TRAINING_CREDITS_CREATED_EMAIL_CONFIG);
            // IBA-6010 END
            
            for(Professional_Services_Credits__c trainingRecordObj :newPSCreditsToSendEmail){
                trainingCreditsRecordIdSet.add(trainingRecordObj.Id);
                accountIdSet.add(trainingRecordObj.Account__c);
            }
            //Querying the records to get the to and cc address properly via query as they are relationship fields.
            trainingCreditsRecordsToSendEmail = [Select Id,Opportunity__r.Service_Owner_Contact__c,Account__r.OwnerId,Account__c,
                                                 Sync_To_Skilljar__c, Account__r.CSM_Name_New__c, Account__r.CSM_Name_New__r.Email,
                                                 Account__r.Name, Opportunity__c, Is_Public_Sector_Account__c
                                                 From Professional_Services_Credits__c
                                                 Where Id IN: trainingCreditsRecordIdSet];
            //Querying the records to get the to and cc address properly via query as they are relationship fields.
            accountExtensionList = [Select Id,Account__c,Service_Owner__c,Service_Owner__r.Email
                                    From Account_Extension__c
                                    Where Account__c IN: accountIdSet];
            if(!accountExtensionList.isEmpty()){
                for(Account_Extension__c accExtObj : accountExtensionList){
                    accountIdWithServiceOwnerContactMap.put(accExtObj.Account__c, accExtObj.Service_Owner__r.Email);
                }
            }
            
            // OrgWideEmailAddress[] fromAddress = [select Id from OrgWideEmailAddress where Address =: Label.TrainingCreditsInsertEmailFromAddress];
            
            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            
            for(Professional_Services_Credits__c psRecordToSendEmail : trainingCreditsRecordsToSendEmail){
                if ((psRecordToSendEmail.Sync_To_Skilljar__c && !psRecordToSendEmail.Is_Public_Sector_Account__c) || 
                   	(!psRecordToSendEmail.Sync_To_Skilljar__c && System.Label.Allow_Email_Notification_for_Fed_Account == ZScalarConstants.TRUE_STRING) || 
                    (psRecordToSendEmail.Is_Public_Sector_Account__c && System.Label.Allow_Email_Notification_for_Public_Sector_Account == ZScalarConstants.TRUE_STRING)) {
                 	Set<String> toAddressesSet = new Set<String>();
                
                    // IBA-6010 START Getting the valid email utility based on whether the account is Federal or not
                    EmailUtility emailUtilityToUse = (psRecordToSendEmail.Sync_To_Skilljar__c ? nonFedAccountsEmailUtility : fedAccountsEmailUtility);
    
                    if (psRecordToSendEmail.Sync_To_Skilljar__c) {
                        if (psRecordToSendEmail.Opportunity__c != null && psRecordToSendEmail.Opportunity__r.Service_Owner_Contact__c != null) {
                            toAddressesSet.add(psRecordToSendEmail.Opportunity__r.Service_Owner_Contact__c);
                        }
                        if (psRecordToSendEmail.Account__c != null && accountIdWithServiceOwnerContactMap.get(psRecordToSendEmail.Account__c) != null) {
                            toAddressesSet.add(accountIdWithServiceOwnerContactMap.get(psRecordToSendEmail.Account__c));
                        }
                    } else {
                        if (psRecordToSendEmail.Account__c != null && psRecordToSendEmail.Account__r.CSM_Name_New__c != null) {
                            toAddressesSet.add(psRecordToSendEmail.Account__r.CSM_Name_New__r.Email);
                        }
                    }
                    if (psRecordToSendEmail.Account__c != null && psRecordToSendEmail.Account__r.OwnerId != null) {
                        toAddressesSet.add(psRecordToSendEmail.Account__r.OwnerId);
                    }
                    // IBA-6010 END
    
                    // IBA-6010 START
                    String customSubject = String.isBlank(emailUtilityToUse.template.Subject) ? 'Zscaler email verification' : emailUtilityToUse.template.Subject;
    
                    String htmlBody = emailUtilityToUse.template.HtmlValue;
                    htmlBody = htmlBody.replace(L2O_Constants.EmailTemplateInfo.PROFESSIONAL_SERVICE_CREDITS_ACCOUNT_MERGE_FIELD, 
                        (psRecordToSendEmail.Account__c != null ? psRecordToSendEmail.Account__r.Name : ZScalarConstants.EMPTY_STRING));
                    
                    Messaging.SingleEmailMessage preparedEmailMessage = emailUtilityToUse.prepareEmail(new List<String> (toAddressesSet), ccAddressesList, 
                        psRecordToSendEmail.Id);
                    // Setting custom subject and replaced htmlBody
                    preparedEmailMessage.setSubject(customSubject);
                    preparedEmailMessage.setHtmlBody(htmlBody);
    
                    emailMessageList.add(preparedEmailMessage);
                    // IBA-6010 END   
                }
            }
            if(System.Label.ZS_Academy_Send_Training_Credit_Email.toLowerCase() == 'yes' && !emailMessageList.isEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessageList);
                
                if (!results.isEmpty() && !results[0].success) {
                    ZscalerErrorLogsUtility.insertlogs('PSCredit_PSCreditTriggerHelper', 
                                                       'sendTrainingCreditsInsertEmail', 
                                                       'Apex', 
                                                       UserInfo.getUserId(),
                                                       'Sales cloud', 
                                                       results[0].errors[0].message, 
                                                       results[0].errors[0].message, 
                                                       'Email Send Failed');
                }
            }
            
        }catch(Exception e){
            insertErrorLog('sendTrainingCreditsInsertEmail', e);
        }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of Jira IBA_1099 : to generate Credit Coded on the Newly Created Training Credit records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : generateCreditCodesOnTrainingCredits .
* @param    NAME : List<Professional_Services_Credits__c> newTrainingCreditsList .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/    
    public static void generateCreditCodesOnTrainingCredits(List<Professional_Services_Credits__c> newTrainingCreditsList){
        
        List<Professional_Services_Credits__c> trainingCreditsListExisting = New list<Professional_Services_Credits__c>();
        List<Professional_Services_Credits__c> trainingCreditsListToUpdate = New list<Professional_Services_Credits__c>();
        Set<Id> updateTrainingCreditId = New Set<Id>();
        Set<Id> accountIdSet = New Set<Id>();
        Map<String,Professional_Services_Credits__c> trainigCreditMapWithExpirationDate = New Map<String,Professional_Services_Credits__c>();
        
        //looping trough the training Credits to get the Account Id's and Newly created record Id's.
        for(Professional_Services_Credits__c newTrainingCreditObj: newTrainingCreditsList){
            updateTrainingCreditId.add(newTrainingCreditObj.Id);
            accountIdSet.add(newTrainingCreditObj.Account__c);
        }
        
        //Querying all the existing Training Credits in the same account to check if there are any existing Credits with same Expiration date.
        trainingCreditsListExisting = [SELECT Id,Credit_Code__c,PS_Credit_SKU__c,
                                       Account__c,Account__r.SkillJar_Group_ID__c,Credits_Purchased__c,
                                       Credits_Expiration_Date__c,RecordTypeId,Skilljar_Group_Id__c,SkillJar_Training_Code_ID__c 
                                       FROM Professional_Services_Credits__c 
                                       WHERE Account__c IN: accountIdSet 
                                       AND Id NOT IN: updateTrainingCreditId 
                                       AND RecordTypeId =: ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID ];
        
        //Creating a Map of Expiration date and Training credit record to check if there are any existing Credits with same Expiration date.
        if(!trainingCreditsListExisting.isEmpty()){
            for(Professional_Services_Credits__c existingTrainingCreditObj: trainingCreditsListExisting){
                trainigCreditMapWithExpirationDate.put(String.valueOf(existingTrainingCreditObj.Credits_Expiration_Date__c)+existingTrainingCreditObj.Account__c,existingTrainingCreditObj);
            }
        }
        
        // IBA-6010 START
        Set<Id> accountIdsSet = new Set<Id>();
        for (Professional_Services_Credits__c customerCredit : newTrainingCreditsList) {
            if (customerCredit.Account__c != null) {
                accountIdsSet.add(customerCredit.Account__c);
            }
        }
        
        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>([SELECT Id, Is_Federal_Account_Sync__c FROM Account 
                                                                       WHERE Id IN :accountIdsSet]);
        // IBA-6010 END
        
        //looping trough the records to populate the credit code on each record respectively.
        for(Professional_Services_Credits__c updateTrainingCreditObj: newTrainingCreditsList){
            Professional_Services_Credits__c updateTrainingCreditLocalObj = New Professional_Services_Credits__c();
            updateTrainingCreditLocalObj.Id = updateTrainingCreditObj.Id;
            updateTrainingCreditLocalObj.Account__c = updateTrainingCreditObj.Account__c;
            updateTrainingCreditLocalObj.PS_Credit_SKU__c = updateTrainingCreditObj.PS_Credit_SKU__c;
            updateTrainingCreditLocalObj.Credits_Expiration_Date__c = updateTrainingCreditObj.Credits_Expiration_Date__c;
            updateTrainingCreditLocalObj.Credits_Purchased__c = updateTrainingCreditObj.Credits_Purchased__c;
            // IBA-6010 START
            updateTrainingCreditLocalObj.Sync_To_Skilljar__c = accountIdToAccountMap.containsKey(updateTrainingCreditLocalObj.Account__c) ? 
                !accountIdToAccountMap.get(updateTrainingCreditLocalObj.Account__c).Is_Federal_Account_Sync__c : true;
            // IBA-6010 END
            
            //to copy the credit code from the training credit record when expiration date matches.   
            if(trainigCreditMapWithExpirationDate.containsKey(String.valueOf(updateTrainingCreditObj.Credits_Expiration_Date__c)+updateTrainingCreditObj.Account__c)){
                updateTrainingCreditLocalObj.Credit_Code__c = trainigCreditMapWithExpirationDate.get(String.valueOf(updateTrainingCreditObj.Credits_Expiration_Date__c)+updateTrainingCreditObj.Account__c).Credit_Code__c;
                updateTrainingCreditLocalObj.SkillJar_Training_Code_ID__c = trainigCreditMapWithExpirationDate.get(String.valueOf(updateTrainingCreditObj.Credits_Expiration_Date__c)+updateTrainingCreditObj.Account__c).SkillJar_Training_Code_ID__c;
            }
            else{
                String psCreditSkuString = updateTrainingCreditObj.PS_Credit_SKU__c;
                Integer psCreditSkuLength = psCreditSkuString.length();
                String psCreditSkuStringNew = psCreditSkuLength > 21 ? psCreditSkuString.substring(0, 21) : psCreditSkuString;
                String creditCodeString = psCreditSkuStringNew+ '_' +updateTrainingCreditObj.Id;
                updateTrainingCreditLocalObj.Credit_Code__c = creditCodeString.toLowerCase(); 
                trainigCreditMapWithExpirationDate.put(String.valueOf(updateTrainingCreditLocalObj.Credits_Expiration_Date__c)+updateTrainingCreditLocalObj.Account__c,updateTrainingCreditLocalObj);
            }
            trainingCreditsListToUpdate.add(updateTrainingCreditLocalObj);
        }
        //Calling the sub method to insert the log records and publish platform event.
        if(!trainingCreditsListToUpdate.isEmpty()){
            UPDATE trainingCreditsListToUpdate;
            insertTrainingCreditsLogrecords(trainingCreditsListToUpdate);
        }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of Jira IBA_1099 : to insert ZSA Integration Log Object records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : insertTrainingCreditsLogrecords .
* @param    NAME : List<Professional_Services_Credits__c> newTrainingCredits.
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/    
    public static void insertTrainingCreditsLogrecords(List<Professional_Services_Credits__c> newTrainingCredits){
        Formula.recalculateFormulas(newTrainingCredits);
        List<ZSA_Integration_Log__c> existingLogs = new List<ZSA_Integration_Log__c>();
        Map<String, ZSA_Integration_Log__c> creditCodeToNewIntegrationLogRecordMap = new Map<String, ZSA_Integration_Log__c>();
        Map<String, ZSA_Integration_Log__c> existingLogsListWithCreditCodeMap = new Map<String, ZSA_Integration_Log__c>();
        Set<String> creditCodeSet = New Set<String>();
        
        //looping trough the list of recieved Training Credits to get all the credit code into a set.
        for(Professional_Services_Credits__c logtrainingCreditObj: newTrainingCredits){
            creditCodeSet.add(logtrainingCreditObj.Credit_Code__c);
        }
        //Querying all the existing logs belonging to the same account so as to sum up the credits purchased if there are previous logs with same credit code.
        existingLogs = [SELECT Id,Training_Credit__c,Account__c,SkillJar_Group_ID__c,
                        Credit_Code__c,Credit_SKU__c,Training_Credits_Purchased__c,Expiration_Date__c,
                        Status__c,Process__c,SkillJar_Training_Code_ID__c 
                        FROM ZSA_Integration_Log__c 
                        WHERE Credit_Code__c IN: creditCodeSet  
                        AND Credit_Code__c != '' ORDER BY CreatedDate DESC];
        
        //Preparing a map of Credit Code and Training Credits Purchased from the log records.
        for (ZSA_Integration_Log__c existingLog : existingLogs) {
            if (!existingLogsListWithCreditCodeMap.containsKey(existingLog.Credit_Code__c)) {
                existingLogsListWithCreditCodeMap.put(existingLog.Credit_Code__c, existingLog);
            }
        }
        
        //looping trough the list of Training credits to generate one log record each for training credit record.
        for(Professional_Services_Credits__c trainingCreditObj: newTrainingCredits){
            // IBA-6010 START Added Sync to skilljar condition
            if (trainingCreditObj.Sync_To_Skilljar__c) {
                // IBA-6010 END
                if (creditCodeToNewIntegrationLogRecordMap.containsKey(trainingCreditObj.Credit_Code__c)) {
                    ZSA_Integration_Log__c logObj = creditCodeToNewIntegrationLogRecordMap.get(trainingCreditObj.Credit_Code__c);
                    logObj.Training_Credits_Purchased__c += trainingCreditObj.Credits_Purchased__c;
                } else if (existingLogsListWithCreditCodeMap.containsKey(trainingCreditObj.Credit_Code__c)) {
                    ZSA_Integration_Log__c existingLogObj = existingLogsListWithCreditCodeMap.get(trainingCreditObj.Credit_Code__c);      
                    ZSA_Integration_Log__c logObj = new ZSA_Integration_Log__c();
                    logObj.Training_Credit__c = trainingCreditObj.Id;
                    logObj.Account__c = trainingCreditObj.Account__c;
                    logObj.SkillJar_Group_ID__c = trainingCreditObj.Skilljar_Group_Id__c;
                    logObj.Credit_Code__c = trainingCreditObj.Credit_Code__c;
                    logObj.Credit_SKU__c = trainingCreditObj.PS_Credit_SKU__c;
                    logObj.Training_Credits_Purchased__c = existingLogObj.Training_Credits_Purchased__c + trainingCreditObj.Credits_Purchased__c;
                    DateTime expirationdateStr = DateTime.newInstance(trainingCreditObj.Credits_Expiration_Date__c.year(), trainingCreditObj.Credits_Expiration_Date__c.month(),trainingCreditObj.Credits_Expiration_Date__c.day(),0,0,0);
                    logObj.Expiration_Date__c = expirationdateStr;
                    logObj.Status__c = ZScalarConstants.ZS_ERROR_LOG_INPROGRESS_STATUS_VALUE;
                    logObj.Process__c = ZScalarConstants.TRAINING_CODE_UPDATE_STRING;
                    logObj.SkillJar_Training_Code_ID__c = existingLogObj.SkillJar_Training_Code_ID__c;
                    creditCodeToNewIntegrationLogRecordMap.put(logObj.Credit_Code__c, logObj);
                } else {
                    ZSA_Integration_Log__c logObj = new ZSA_Integration_Log__c();
                    logObj.Training_Credit__c = trainingCreditObj.Id;
                    logObj.Account__c = trainingCreditObj.Account__c;
                    logObj.SkillJar_Group_ID__c = trainingCreditObj.Skilljar_Group_Id__c;
                    logObj.Credit_Code__c = trainingCreditObj.Credit_Code__c;
                    logObj.Credit_SKU__c = trainingCreditObj.PS_Credit_SKU__c;
                    logObj.Training_Credits_Purchased__c = trainingCreditObj.Credits_Purchased__c;
                    logObj.Expiration_Date__c = trainingCreditObj.Credits_Expiration_Date__c;
                    logObj.Status__c = ZScalarConstants.ZS_ERROR_LOG_INPROGRESS_STATUS_VALUE;
                    logObj.Process__c = ZScalarConstants.TRAINING_CODE_STRING;
                    creditCodeToNewIntegrationLogRecordMap.put(logObj.Credit_Code__c, logObj);
                }
            }
        }
        
        if(!creditCodeToNewIntegrationLogRecordMap.isEmpty()){
            insert creditCodeToNewIntegrationLogRecordMap.values();
            if(!isSandbox){
               publishTrainingCreditCalloutEvent(creditCodeToNewIntegrationLogRecordMap.values());
            }
            
        }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of Jira IBA_1099 : to Publish the Platform Events to workato with the informationfrom the Log records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : publishTrainingCreditCalloutEvent .
* @param    NAME : List<ZSA_Integration_Log__c> logs.
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    @InvocableMethod(label='Publish Training Credit Callout Event' description='Publishes the platform event to workato')
    public static void publishTrainingCreditCalloutEvent(List<ZSA_Integration_Log__c> logs){
        List<ZSA_Callout__e> eventsToPublish = new List<ZSA_Callout__e>();
        for(ZSA_Integration_Log__c log: logs){
            Request_Body obj = new Request_Body(log.SkillJar_Group_ID__c,log.Account__c,log.Training_Credits_Purchased__c,log.Expiration_Date__c,log.Training_Credit__c,
                                                log.Credit_Code__c,log.Credit_SKU__c,log.Id,log.Status__c,log.Status_Message__c,log.SkillJar_Training_Code_ID__c);
            String jsonFormattedString = JSON.serialize(obj);
            ZSA_Callout__e calloutEvent = new ZSA_Callout__e(
                Process__c = log.Process__c,
                Request_Body__c=jsonFormattedString);
            eventsToPublish.add(calloutEvent);
        }
        
        // Call method to publish events
        List<Database.SaveResult> sr = EventBus.publish(eventsToPublish);
        // Inspect publishing result
        if (sr[0].isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr[0].getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of Jira IBA_1099 : generic method to generate request body for the Platform event.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : Request_Body .
* @param    NAME : NIL.
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    public class Request_Body{
        
        public string group_Id;
        public string accountId;
        public Decimal credit_Value;
        public DateTime expiration_date;
        public string trainingCreditId;
        public string training_credit_code;
        public string creditSKU;
        public string integration_Log_Id;
        public string status;
        public string status_Message;
        public string skilljar_Training_Code_Id;
        
        public Request_Body(string groupId, string accountId, Decimal creditsPurchased, DateTime expirationDate, string trainingCreditId,
                            string creditCode, string creditSKU, string logId, string status, string status_Message, string skilljar_Training_Code_Id){
                                
                                this.group_Id = groupId;
                                this.accountId = accountId;
                                this.credit_Value = creditsPurchased;
                                this.expiration_date = expirationDate;
                                this.trainingCreditId = trainingCreditId;
                                this.training_credit_code = creditCode;
                                this.creditSKU = creditSKU;
                                this.integration_Log_Id = logId;
                                this.status = status;
                                this.status_Message = status_Message;
                                this.skilljar_Training_Code_Id = skilljar_Training_Code_Id;
                                
                            }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of Jira IBA_2069 : Send Email Notification when Opportunity Closed with PS credits.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : sendPSCreditsNotificationEmail .
* @param    NAME : List<Professional_Services_Credits__c>
* @return   TYPE : void .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void sendPSCreditsNotificationEmail(List<Professional_Services_Credits__c> psCustomerCredits) {
        try {
            sendPSCreditsEmail(psCustomerCredits);
        }catch(Exception e) {
            insertErrorLog('sendPSCreditsNotificationEmail', e);
        }
    }
    
    public static void sendPSCreditsEmail(List<Professional_Services_Credits__c> psCustomerCredits) {
        
        //Get set of PS Credits Ids
        Set<Id> customerCreditIds = New Set<Id>();
        for(Professional_Services_Credits__c psCustomerCredit :psCustomerCredits){
            customerCreditIds.add(psCustomerCredit.Id);
        }
        
        //Prepare a Map of OpportunityId By PSCredits 
        Map<Id,List<Professional_Services_Credits__c>> psCreditByOpportunityId = getPsCreditByOpportunityId(customerCreditIds);
        
        if(!psCreditByOpportunityId.isEmpty()) {
            
            EmailTemplate emailTemplate = getEmailTemplate(ZScalarConstants.PS_CREDIT_INSERT_EMAIL_TEMPLATE);
            Id defaultOWDSenderId = getSendersEmailId(Label.PSCredit_OpportunityClosedWithPSCreditSendersEmailAddress);
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            
            for(Id opportunityId : psCreditByOpportunityId.keySet()) {
                
                List<Professional_Services_Credits__c> psCredits = psCreditByOpportunityId.get(opportunityId);
                Professional_Services_Credits__c psCredit = psCredits.get(0);
                //Get total PSCredits Purchased on Opportunity Closed
                Integer totalPSCredit = getTotalPsCredits(psCredits);
                
                //to get Email addresses of Users to Send Emails
                List<String> toEmailAddresses = getToEmailAddresses(psCredit);
                
                //To Replace EmailBody
                String emailTemplateHtmlBody = emailTemplate.HtmlValue;
                emailTemplateHtmlBody = emailTemplateHtmlBody.replace('{totalPSCredits}',  String.valueOf(totalPSCredit));
                emailTemplateHtmlBody = emailTemplateHtmlBody.replace('{OpportunityName}','<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+psCredit.Opportunity__c+'">'+psCredit.Opportunity__r.Name+'</a>');
                emailTemplateHtmlBody = emailTemplateHtmlBody.replace(']]>','');
                emailTemplateHtmlBody = emailTemplateHtmlBody.replace('width="550"','width="100%"');
                
                //Prepare Emails To Be Sent
                Messaging.SingleEmailMessage emails = prepareEmail(emailTemplateHtmlBody,toEmailAddresses,defaultOWDSenderId,psCredit.Id,emailTemplate.Id);
                emailMessages.add(emails);
            }
            
            //Send Emails
            sendEmails(emailMessages);
        }
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA Ticket - IBA-3769     Training Credits Redemption Process.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getAccountExtensionsToBeUpdated .
* @param    NAME : Set<Id> accountIds .
* @return   TYPE : List<Account_Extension__c> accountextensionsToBeUpdated .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/      
    private static List<Account_Extension__c> getAccountExtensionsToBeUpdated(Set<Id> accountIds) {
        Map<Id,Integer> creditPurchasedByAccountId = getTotalCreditPurchasedByAccountId(accountIds);
        Map<Id,Integer> creditRedeemedByAccountId = getTotalPSCreditRedeemedByAccountId(accountIds);
        Map<Id,Integer> TrainingCreditPurchasedByAccountId = getTotalTrainingCreditPurchasedByAccountId(accountIds);
        Map<Id,Integer> TrainingCreditRedeemedByAccountId = getTotalTrainingCreditRedeemedByAccountId(accountIds);
        
        List<Account_Extension__c> accountextensionsToBeUpdated = new List<Account_Extension__c>();
        List<Account_Extension__c> accountextensionsList = new List<Account_Extension__c>();
        
        accountextensionsList = [Select Id, Name, Active_Training_Credits__c, Active_Training_Credits_Used__c,
                                 Total_Available_Training_Credits__c, Total_Expired_PS_Credits__c, 
                                 Total_Expired_Training_Credits__c, Total_Purchased_PS_Credits__c, Total_Purchased_Training_Credits__c,
                                 Total_Available_PS_Credits__c,Total_Redeemed_PS_Credits__c, 	Total_Redeemed_Training_Credits__c, Training_Credits_All_Time__c,
                                 Training_Credits_Used_All_Time__c, Account__c
                                 FROM Account_Extension__c
                                 WHERE Account__c IN: accountIds];
        
        for(Account_Extension__c accExtensionObj : accountextensionsList) {
            if (creditPurchasedByAccountId.containsKey(accExtensionObj.Account__c)) {
                accExtensionObj.Total_Purchased_PS_Credits__c = creditPurchasedByAccountId.get(accExtensionObj.Account__c);
            } 
            if (creditRedeemedByAccountId.containsKey(accExtensionObj.Account__c)) {
                accExtensionObj.Total_Redeemed_PS_Credits__c = creditRedeemedByAccountId.get(accExtensionObj.Account__c);
            } 
            if (TrainingCreditPurchasedByAccountId.containsKey(accExtensionObj.Account__c)) {
                accExtensionObj.Total_Purchased_Training_Credits__c = TrainingCreditPurchasedByAccountId.get(accExtensionObj.Account__c);
            }
            if (TrainingCreditRedeemedByAccountId.containsKey(accExtensionObj.Account__c)) {
                accExtensionObj.Total_Redeemed_Training_Credits__c = TrainingCreditRedeemedByAccountId.get(accExtensionObj.Account__c);
            }
            //IBA-6122 Start
            if (creditPurchasedByAccountId.containsKey(accExtensionObj.Account__c) && creditRedeemedByAccountId.containsKey(accExtensionObj.Account__c)) {
                Integer creditsRedeemed = accExtensionObj.Total_Redeemed_PS_Credits__c == null ? 0 : (Integer)accExtensionObj.Total_Redeemed_PS_Credits__c;
                Integer creditsPurchased = accExtensionObj.Total_Purchased_PS_Credits__c == null ? 0 : (Integer)accExtensionObj.Total_Purchased_PS_Credits__c;
            	accExtensionObj.Total_Available_PS_Credits__c = creditsPurchased - creditsRedeemed < 0 ? 0 : creditsPurchased - creditsRedeemed ;
            }else if(creditPurchasedByAccountId.containsKey(accExtensionObj.Account__c)) {
                accExtensionObj.Total_Available_PS_Credits__c = accExtensionObj.Total_Purchased_PS_Credits__c;
            }
            //IBA-6122 END
            accountextensionsToBeUpdated.add(accExtensionObj);   
        }
        return accountextensionsToBeUpdated;
    }
    
    private static Set<Id> getAccountIds(List<Professional_Services_Credits__c> newPSCredits) {
        Set<Id> accountIds = new Set<Id>();
        for(Professional_Services_Credits__c psCredit: newPSCredits) {
            if(psCredit.Account__c != null && psCredit.Opportunity_Close_Date__c.addDays(365) > Date.today()) {
                accountIds.add(psCredit.Account__c);
            }
        }
        return accountIds;
    }
    
    private static Map<Id,Integer> getTotalCreditPurchasedByAccountId(Set<Id> accountIds) {
        
        Date todaysDate = Date.today();
        Map<Id,Integer> totalCreditPurchasedByAccountId = new Map<Id,Integer>();
        List<AggregateResult> pscreditAggregrateResults = [SELECT SUM(Credits_Purchased__c)availableCredits,Account__c 
                                                           FROM Professional_Services_Credits__c 
                                                           WHERE Credits_Expiration_Date__c >=: todaysDate 
                                                           AND Account__c IN:accountIds 
                                                           AND RecordTypeId =: ZScalarConstants.PS_CREDIT_RECORDTYPEID
                                                           AND EE_Credit__c = false
                                                           Group by Account__c];
        
        if(pscreditAggregrateResults.isEmpty()) {return totalCreditPurchasedByAccountId;}
        Integer availableCredits;
        for(AggregateResult psCreditResults: pscreditAggregrateResults ) {
            availableCredits = Integer.valueOf(psCreditResults.get('availableCredits'));
            totalCreditPurchasedByAccountId.put((Id)psCreditResults.get(ZScalarConstants.ACCOUNT_CUSTOM_FIELD_API_NAME),availableCredits );
        }
        
        return totalCreditPurchasedByAccountId;
    }
    
    private static Map<Id,Integer> getTotalTrainingCreditPurchasedByAccountId(Set<Id> accountIds) {
        
        Date todaysDate = Date.today();
        Map<Id,Integer> totalTrainingCreditPurchasedByAccountId = new Map<Id,Integer>();
        List<AggregateResult> trainingcreditAggregrateResults = [SELECT SUM(Credits_Purchased__c)availableTrainingCredits,Account__c 
                                                                 FROM Professional_Services_Credits__c 
                                                                 WHERE Credits_Expiration_Date__c >=: todaysDate 
                                                                 AND Account__c IN:accountIds
                                                                 AND RecordTypeId =: ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID
                                                                 Group by Account__c];
        
        if(trainingcreditAggregrateResults.isEmpty()) {return totalTrainingCreditPurchasedByAccountId;}
        Integer availableTrainingCredits;
        for(AggregateResult trainingCreditResults: trainingcreditAggregrateResults ) {
            availableTrainingCredits = Integer.valueOf(trainingCreditResults.get('availableTrainingCredits'));
            totalTrainingCreditPurchasedByAccountId.put((Id)trainingCreditResults.get(ZScalarConstants.ACCOUNT_CUSTOM_FIELD_API_NAME),availableTrainingCredits );
        }
        
        return totalTrainingCreditPurchasedByAccountId;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA Ticket - IBA-3769     Training Credits Redemption Process.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getTotalTrainingCreditRedeemedByAccountId .
* @param    NAME : Set<Id> accountIds .
* @return   TYPE : Map<Id,Integer> totalTrainingCreditRedeemedByAccountId .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    private static Map<Id,Integer> getTotalTrainingCreditRedeemedByAccountId(Set<Id> accountIds) {
        
        Date todaysDate = Date.today();
        Map<Id,Integer> totalTrainingCreditRedeemedByAccountId = new Map<Id,Integer>();
        List<AggregateResult> trainingcreditAggregrateResults = [SELECT SUM(Credits_Redeemed__c)redeemedTrainingCredits,Account__c 
                                                                 FROM Professional_Services_Credits__c 
                                                                 WHERE Credits_Expiration_Date__c >=: todaysDate 
                                                                 AND Account__c IN:accountIds
                                                                 AND RecordTypeId =: ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID
                                                                 Group by Account__c];
        
        if(trainingcreditAggregrateResults.isEmpty()) {return totalTrainingCreditRedeemedByAccountId;}
        Integer redeemedTrainingCredits;
        for(AggregateResult trainingCreditResults: trainingcreditAggregrateResults ) {
            redeemedTrainingCredits = Integer.valueOf(trainingCreditResults.get('redeemedTrainingCredits'));
            totalTrainingCreditRedeemedByAccountId.put((Id)trainingCreditResults.get(ZScalarConstants.ACCOUNT_CUSTOM_FIELD_API_NAME),redeemedTrainingCredits );
        }
        
        return totalTrainingCreditRedeemedByAccountId;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA Ticket - IBA-4122 Move PS Credits from Account to Account Extension.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getTotalPSCreditRedeemedByAccountId .
* @param    NAME : Set<Id> accountIds .
* @return   TYPE : Map<Id,Integer> totalPSCreditRedeemedByAccountId .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/      
    private static Map<Id,Integer> getTotalPSCreditRedeemedByAccountId(Set<Id> accountIds) {
        
        Date todaysDate = Date.today();
        Map<Id,Integer> totalPSCreditRedeemedByAccountId = new Map<Id,Integer>();
        List<AggregateResult> pscreditAggregrateResults = [SELECT SUM(Credits_Redeemed__c)redeemedCredits,Account__c 
                                                           FROM Professional_Services_Credits__c 
                                                           WHERE Credits_Expiration_Date__c >=: todaysDate 
                                                           AND Account__c IN:accountIds 
                                                           AND RecordTypeId =: ZScalarConstants.PS_CREDIT_RECORDTYPEID
                                                           AND EE_Credit__c = false
                                                           Group by Account__c];
        
        if(pscreditAggregrateResults.isEmpty()) {return totalPSCreditRedeemedByAccountId;}
        Integer redeemedCredits;
        for(AggregateResult psCreditResults: pscreditAggregrateResults ) {
            redeemedCredits = Integer.valueOf(psCreditResults.get('redeemedCredits'));
            totalPSCreditRedeemedByAccountId.put((Id)psCreditResults.get(ZScalarConstants.ACCOUNT_CUSTOM_FIELD_API_NAME),redeemedCredits );
        }
        
        return totalPSCreditRedeemedByAccountId;
    }
    
    private static Map<Id,List<Professional_Services_Credits__c>> getPsCreditByOpportunityId(Set<Id> customerCreditIds) {
        
        Map<Id,List<Professional_Services_Credits__c>> psCreditByOpportunityId = new Map<Id,List<Professional_Services_Credits__c>>();
        for(Professional_Services_Credits__c credit :  [SELECT id,
                                                        Account__r.Owner.Email,
                                                        Account__r.CSM_Name_New__r.Email,
                                                        Opportunity__r.Owner.Email,
                                                        Opportunity__r.Name,
                                                        Opportunity__c,
                                                        Credits_Purchased__c
                                                        FROM Professional_Services_Credits__c 
                                                        WHERE Id IN:customerCreditIds 
                                                        AND Opportunity__c != null]
           ) {
               if(!psCreditByOpportunityId.containsKey(credit.Opportunity__c)) {
                   psCreditByOpportunityId.put(credit.Opportunity__c,new List<Professional_Services_Credits__c> {credit});  
               }else if(psCreditByOpportunityId.containsKey(credit.Opportunity__c)) {        
                   List<Professional_Services_Credits__c> existingPScredit = psCreditByOpportunityId.get(credit.Opportunity__c);
                   existingPScredit.add(credit);
                   psCreditByOpportunityId.put(credit.Opportunity__c,existingPScredit);
               }
           }
        
        return psCreditByOpportunityId;
    }
    
    private static Integer getTotalPsCredits(List<Professional_Services_Credits__c> psCredits) {
        Integer totalPSCredits = 0;
        for(Professional_Services_Credits__c psCredit : psCredits) {
            totalPSCredits = totalPSCredits + (Integer)psCredit.Credits_Purchased__c;
        }
        return totalPSCredits;
    }
    
    private static EmailTemplate getEmailTemplate(String templateName) {
        return [SELECT Id, Subject, Body, HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName =: templateName];
    }
    
    private static Id getSendersEmailId(String addressId) {
        return  [SELECT id, Address,IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Address =: addressId].Id;
    }
    
    private static List<String> getToEmailAddresses(Professional_Services_Credits__c psCredit) {
        
        Set<String> userEmailAddresses = new Set<String>();
        if(String.isNotBlank(psCredit.Account__r.Owner.Email)) {
            userEmailAddresses.add(psCredit.Account__r.Owner.Email);
        }
        if(String.isNotBlank(psCredit.Account__r.CSM_Name_New__r.Email)) {
            userEmailAddresses.add(psCredit.Account__r.CSM_Name_New__r.Email);
        }
        if(String.isNotBlank(psCredit.Opportunity__r.Owner.Email)) {
            userEmailAddresses.add(psCredit.Opportunity__r.Owner.Email);
        }      
        
        return new List<String>(userEmailAddresses);                                                   
    }
    
    private static void sendEmails(List<Messaging.SingleEmailMessage> emailsToBeSend) {
        if(!emailsToBeSend.isEmpty()) {
            Messaging.sendEmail(emailsToBeSend);
        }
    }
    
    public static Messaging.SingleEmailMessage prepareEmail(
        String emailTemplateHtmlBody,
        List<String> toEmailAddresses,
        String defaultOWDSenderId, 
        Id sObjectId,
        String templateId
    ){
        
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(templateId), Null, String.valueOf(sObjectId));
        mail.setToAddresses(toEmailAddresses);
        mail.setOrgWideEmailAddressId(defaultOWDSenderId);
        mail.setHtmlBody(emailTemplateHtmlBody);
        mail.setTreatBodiesAsTemplate(true);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setsaveAsActivity(false);
        
        return mail;
    }
    
    // IBA-6010 START
    @TestVisible
    private static void insertErrorLog(String methodName, Exception exceptionInfo) {
        ZscalerErrorLogsUtility.insertlogs(
            'PSCredit_PSCreditTriggerHelper', 
            methodName, 
            'Apex', 
            UserInfo.getUserId(),
            'Sales cloud', 
            exceptionInfo.getStackTraceString(), 
            exceptionInfo.getMessage(), 
            exceptionInfo.getTypeName()
        );
    }
    
    public class PSCredit_PSCreditTriggerHelperException extends Exception {}
    // IBA-6010 END
}