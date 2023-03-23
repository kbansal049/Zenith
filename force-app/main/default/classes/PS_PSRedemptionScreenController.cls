/*****************************************************************************************
Name: PS_PSRedemptionScreenController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex Controller for PS Credit Redemption Process.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        17/05/2022      CR#4745      PS Credits Redemption Process && PS Credits Redemption Validation.
2.0                Harish Gowda N       17/05/2022      CR#4744      PS Credits Redemption Process && PS Credits Redemption Validation.
3.0                Harish Gowda N       21/06/2022      CR#4994      Adding Deployment Service project link on redemption record.
4.0                Harish Gowda N       21/06/2022      CR#4995      Deployment Package should be populated dynamically on project.
5.0                Sachin Tandon        21/06/2022      CR#4883      Populate Start Date ,Time Zone and Contact on Project 
6.0                Harish Gowda N       29/07/2022      IBA-1098     Allow CSM's to redeem PS credits for Training.
7.0                Harish Gowda N       13/09/2022      IBA-2878     New PS Credits Offering - Attack Surface Discovery Report.
8.0                Harish Gowda N       06/10/2022      IBA-3300     New PS Credits Offering for redemption (CR# 5222).
9.0                Harish Gowda N       25/10/2022      IBA-1933     Allow all users to redeem PS credits and create Project.
******************************************************************************************/ 

public without sharing class PS_PSRedemptionScreenController {
    
    private static Map<Id,Integer> offeringCreditByofferingId = new Map<Id,Integer>();
    private static Map<Id,PS_Offering__c> offeringByofferingId = new Map<Id,PS_Offering__c>();
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4743 : to get the List of PS Credit records Associated with the Account.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getPSCredits .
* @param    NAME : string accountId .
* @return   TYPE : List<PsCreditWrapper>  psCreditWrapperList .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    @AuraEnabled
    public static List<PsCreditWrapper> getPSCredits(string accountId) {
        try {
            List<PsCreditWrapper> psCreditWrapperList = New List<PsCreditWrapper>();
            Boolean hasEarlyEngagement = doesUserhaveEarlyEngagementPermission();
            
            for(Professional_Services_Credits__c psCreditObj : [SELECT  Id, 
                                                                Account__c, 
                                                                Opportunity__c, 
                                                                Name, 
                                                                Account__r.name, 
                                                                Opportunity__r.Name, 
                                                                Credits_Expiration_Date__c, 
                                                                Credits_Purchased__c, 
                                                                Credits_Redeemed__c, 
                                                                Credits_Remaining__c, 
                                                                Opportunity_Close_Date__c, 
                                                                Account__r.Total_Available_credits__c, 
                                                                PS_Credit_Name__c,
                                                                EE_Credit__c, 
                                                                RecordType.Name 
                                                                FROM Professional_Services_Credits__c 
                                                                WHERE Account__c =: accountId 
                                                                AND Is_Redemption_Valid__c = true 
                                                                AND RecordType.Name =: ZScalarConstants.PS_CREDIT_RECORDTYPENAME 
                                                                ORDER BY Credits_Expiration_Date__c asc]) { 
                                                                    
                                                                    if(hasEarlyEngagement || !psCreditObj.EE_Credit__c) {
                                                                        psCreditWrapperList.add(new PsCreditWrapper(psCreditObj)); 
                                                                    }
                                                                } 
            if(!psCreditWrapperList.isEmpty()){
                return psCreditWrapperList;
            }
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4743 : to get the List of PS Offering records Associated with the Account.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getPSOfferings .
* @param    NAME : NIL .
* @return   TYPE : List<PS_Offering__c>  psOfferingsList .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/    
    @AuraEnabled
    public static List<PS_Offering__c> getPSOfferings() {
        try {
            return retrievePSOfferings();
        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    private static List<PS_Offering__c> retrievePSOfferings() {
        User csmUser = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
        List<String> psOfferingUsersList = New List<String>();
        psOfferingUsersList = System.Label.PS_Offering_Users.split(';');
        Boolean showPSOfferingUser  = false;
        List<PS_Offering__c> psOfferingsList = new List<PS_Offering__c>();
        
        if(psOfferingUsersList != null){
            if(psOfferingUsersList.contains(csmUser.Name)){
                showPSOfferingUser = true;
            }
        }
        //to show the PS Offering only for the users in the above mentioned custom label .
        if(showPSOfferingUser == true){
            psOfferingsList = [SELECT Id, Credits__c,Offering_Details__c, Project_template__c, Name, 
                               Suggested_Max__c, RecordType.Name, RecordTypeId  
                               FROM PS_Offering__c 
                               WHERE Is_Active__c = true 
                               AND (RecordType.Name =: ZScalarConstants.PS_OFFERING_RECORDTYPENAME 
                                    OR RecordType.Name =: ZScalarConstants.TRAINING_OFFERING_RECORDTYPENAME) ORDER BY Name asc];
        }
        else{
            psOfferingsList = [SELECT Id, Credits__c,Offering_Details__c, Project_template__c, Name, 
                               Suggested_Max__c, RecordType.Name, RecordTypeId  
                               FROM PS_Offering__c 
                               WHERE Name != 'PS Offering' 
                               AND Is_Active__c = true 
                               AND (RecordType.Name =: ZScalarConstants.PS_OFFERING_RECORDTYPENAME 
                                    OR RecordType.Name =: ZScalarConstants.TRAINING_OFFERING_RECORDTYPENAME) ORDER BY Name asc];    
        }
        
        for (PS_Offering__c offering : psOfferingsList) {
            offeringCreditByofferingId.put(offering.Id,Integer.valueOf(offering.Credits__c));
            offeringByofferingId.put(offering.Id,offering);
        }
        return psOfferingsList;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of Jira IBA - 1933: Allow all users to redeem PS credits and create Project.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getDevelopmentProjectRecordTypeId .
* @return   TYPE : String .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    @AuraEnabled(cacheable=true)
    public static String getDevelopmentProjectRecordTypeId() { 
        return ZScalarConstants.PS_REDEMPTION_RECORDTYPEID;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4744 : This Method would be invoked on click of Save button from LWC .
* This Method would call the other child methods which would create PS Credit Redemption , Project and PS Credit Junction Object records .
* This Method would also call the child methods to update the PS Credit records and account record with Credits reedemed and Credits remaining values .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : createPSCreditRedemptionrecord .
* @param    NAME : String accountId, String accountName, String totalCreditsRequired, Map<String, String> psOfferingIdUnitsmap .
* @return   TYPE : List,String> Success /or/ Error .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/        
    @AuraEnabled
    public static List<String> createPSCreditRedemptionrecord(String accountId, String accountName, String totalCreditsRequired, Map<String, String> psOfferingIdUnitsmap, Map<String,Object> psOfferingByOfferingId, Boolean shouldRedeemEECredit ) { 
        List<String> result = new List<String>();
        //Creating a Database SavePoint to which we can Rollback. If any Error occurs.
        Savepoint sp = Database.setSavepoint(); 
        try {
            result = redeemPSCredits(accountId, accountName, totalCreditsRequired, psOfferingIdUnitsmap, psOfferingByOfferingId, shouldRedeemEECredit);
        }catch(Exception ex) {
            Database.rollback(sp);
            ZscalerErrorLogsUtility.insertLogs(L2O_Constants.ErrorLog.CLASS_PS_PSREDEMPTIONSCREENCONTROLLER, 'createPSCreditRedemptionrecord',
                                               L2O_Constants.ErrorLog.Apex, UserInfo.getUserId(),
                                               'Sales Cloud', ex.getStackTraceString(), 
                                               'PS Credit redemption process failed' + ex.getMessage(), ex.getTypeName());
            throw new AuraHandledException('Something Went Wrong During Redemption Process!'+ ex.getMessage());
        }
        return result;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4744 : this is the container class that holds all the child methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : redeemPSCredits .
* @param    NAME : String accountId, String accountName, String totalCreditsRequired, Map<String, String> psOfferingIdUnitsmap .
* @return   TYPE : List<String>  Success .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    private static List<String> redeemPSCredits(String accountId, String accountName, String totalCreditsRequired, Map<String, String> psOfferingIdUnitsmap, Map<String,Object> psOfferingByOfferingId, Boolean shouldRedeemEECredit) {
        
        List<PS_Credit_Redemption__c> creditRedemptionListToInsert = new List<PS_Credit_Redemption__c>();
        List<String> newCreditRedemptionIdList = new List<String>();
        List<Professional_Services_Credits__c> psCreditListNew = new List<Professional_Services_Credits__c>();
        Map<String, String> trainingOfferingIdUnitsMapNew = New Map<String, String>();
        Map<String,Object> trainingOfferingByOfferingIdNew = New Map<String,Object>();
        List<Professional_Services_Credits__c> trainingCreditRecordsListToInsert = new List<Professional_Services_Credits__c>();
        
        for (String psOfferingRecordId : psOfferingIdUnitsmap.keySet()) {
            
            if(Integer.valueOf(psOfferingIdUnitsmap.get(psOfferingRecordId)) != 0){
                ModalModule offeringDetailsNew = (ModalModule)JSON.deserialize(JSON.serialize(psOfferingByOfferingId.get(psOfferingRecordId)), ModalModule.class);
                
                if(offeringDetailsNew.RecordTypeId == ZScalarConstants.TRAINING_OFFERING_RECORDTYPEID){
                    trainingOfferingIdUnitsMapNew.put(offeringDetailsNew.Id, String.valueOf(offeringDetailsNew.Units));
                    trainingOfferingByOfferingIdNew.put(offeringDetailsNew.Id, psOfferingByOfferingId.get(offeringDetailsNew.Id));
                }
            }
        }
        
        //To instantiate static maps
        getPSOfferings();
        
        //To get PS Credit records related to Account where Is_Redemption_Valid__c = true 
        psCreditListNew = getPSCreditRecords(accountId,shouldRedeemEECredit);
        
        //To get total number of Training Credits already existing on the account
        Integer availableTrainingCreditsCount = getAvailableTrainingCreditsCount(accountId);
        
        if( !(psOfferingIdUnitsmap.isEmpty() && psOfferingByOfferingId.isEmpty()) ){
            
            //Create PS Credit Redemption record for insertion
            creditRedemptionListToInsert = createCreditRedemptions(psOfferingIdUnitsmap,accountId,psOfferingByOfferingId);
            
            // To insert the PS redemption records for the Account.
            if(!creditRedemptionListToInsert.isEmpty()){
                Database.insert(creditRedemptionListToInsert);
            }
            
            //To create PS Credit Redemption Records and update PS Credit
            createPSCreditAndPSCreditJundtionRecords(creditRedemptionListToInsert,psCreditListNew);
        } 
        
        //IBA- 1098 - PS Credit redemptition to Training Credit process.
        if( !(trainingOfferingIdUnitsMapNew.isEmpty() && trainingOfferingByOfferingIdNew.isEmpty()) ){
            trainingCreditRecordsListToInsert = createTrainingCreditRecords(trainingOfferingIdUnitsMapNew,accountId,psCreditListNew,availableTrainingCreditsCount);
            
            //To insert the Training Credit records for the Account.
            if(!trainingCreditRecordsListToInsert.isEmpty()){
                Database.insert(trainingCreditRecordsListToInsert);
            }
        }
        
        //To return suceess message after process is succesfully completed.
        newCreditRedemptionIdList.add('Success');
        return newCreditRedemptionIdList;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 - Allow all users to redeem PS credits and create Project.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : createCreditRedemptions .
* @param    NAME : Map<String,String> psOfferingIdUnitsmap, String accountId, Map<String,Object> psOfferingByOfferingId) .
* @return   TYPE : List<PS_Credit_Redemption__c>  CreditRedemptionListToInsert .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/      
    private static List<PS_Credit_Redemption__c> createCreditRedemptions(Map<String,String> psOfferingIdUnitsmap, String accountId, Map<String,Object> psOfferingByOfferingId) {
        
        List<PS_Credit_Redemption__c> CreditRedemptionListToInsert = new List<PS_Credit_Redemption__c>();
        String psOfferingToSkipProjectCreation = Skip_PS_Offering_For_Project_Creation__mdt.getInstance(ZScalarConstants.ATTACK_SURFACE_DISCOVERY_REPORT_PS_OFFERING).Zscaler_Offering_Name__c;
        
        for (String zscalerOfferingRecordId : psOfferingIdUnitsmap.keySet()) {
            
            if(Integer.valueOf(psOfferingIdUnitsmap.get(zscalerOfferingRecordId)) != 0){    
                ModalModule offeringDetails = (ModalModule)JSON.deserialize(JSON.serialize(psOfferingByOfferingId.get(zscalerOfferingRecordId)), ModalModule.class);
                
                PS_Credit_Redemption__c creditRedemptionObj = New PS_Credit_Redemption__c(); 
                creditRedemptionObj.Account__c = accountId;
                creditRedemptionObj.PS_Offering__c = zscalerOfferingRecordId;
                creditRedemptionObj.Units_Redeemed__c = Integer.valueOf(psOfferingIdUnitsmap.get(zscalerOfferingRecordId));
                creditRedemptionObj.Credits_Required__c = offeringByofferingId.get(zscalerOfferingRecordId).Credits__c;
                
                //Mapping the Project field values from the UI to the PS Redemption field for PS Redemption record .
                if(offeringDetails.RecordTypeId == ZScalarConstants.PS_OFFERING_RECORDTYPEID){
                    creditRedemptionObj.RecordTypeId = ZScalarConstants.PS_REDEMPTION_RECORDTYPEID;
                    
                    if(offeringDetails.Name != psOfferingToSkipProjectCreation){
                        creditRedemptionObj.Project_Creation_Status__c = ZScalarConstants.PROJECT_CREATION_STATUS_PENDING;
                        creditRedemptionObj.Project_Requester_Time_Zone__c = offeringDetails.RequesterTimeZone;
                        creditRedemptionObj.Project_Deployment_Start_Date__c = Date.valueOf(offeringDetails.DeploymentStartDate);
                        creditRedemptionObj.Project_Deployment_Expiration_Date__c = Date.valueOf(offeringDetails.DeploymentStartDate) + 90;
                        creditRedemptionObj.Project_Primary_Customer_Contact__c = offeringDetails.contact;
                        creditRedemptionObj.Project_Executive_Summary__c = offeringDetails.notes;
                    }else if(offeringDetails.Name == psOfferingToSkipProjectCreation){
                        sendEmailForAttackSurfaceDiscoveryOffering(accountId);
                        creditRedemptionObj.Project_Creation_Status__c = ZScalarConstants.PROJECT_CREATION_STATUS_NOT_APPLICABLE;
                    }
                }
                
                if(offeringDetails.RecordTypeId == ZScalarConstants.TRAINING_OFFERING_RECORDTYPEID){
                    creditRedemptionObj.RecordTypeId = ZScalarConstants.TRAINING_REDEMPTION_RECORDTYPEID;
                    creditRedemptionObj.Project_Creation_Status__c = ZScalarConstants.PROJECT_CREATION_STATUS_NOT_APPLICABLE;
                }
                CreditRedemptionListToInsert.add(creditRedemptionObj);
            }
        }
        return CreditRedemptionListToInsert;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1098 : this method is to Allow CSM's to redeem PS credits for Training.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : createTrainingCreditRecords .
* @param    NAME : Map<String,String> trainingOfferingIdUnitsMapNew, String accountId .
* @return   TYPE : List<PS_Credit_Redemption__c>  trainingCreditRecordsListToInsert .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/      
    private static List<Professional_Services_Credits__c> createTrainingCreditRecords(Map<String,String> trainingOfferingIdUnitsMapNew, String accountId, List<Professional_Services_Credits__c> psCreditListNew, Integer availableTrainingCreditsCount ) {
        List<Professional_Services_Credits__c> trainingCreditRecordsListToInsert = new List<Professional_Services_Credits__c>();
        
        for (String trainingOfferingRecordId : trainingOfferingIdUnitsMapNew.keySet()) {
            
            if(Integer.valueOf(trainingOfferingIdUnitsMapNew.get(trainingOfferingRecordId)) != 0){
                availableTrainingCreditsCount = availableTrainingCreditsCount + 1;
                Integer trainingCreditsRedemmed = Integer.valueOf(Integer.valueOf(trainingOfferingIdUnitsMapNew.get(trainingOfferingRecordId)) * offeringCreditByofferingId.get(trainingOfferingRecordId));
                Integer trainingCreditsRedemmedlocal = Integer.valueOf(Integer.valueOf(trainingOfferingIdUnitsMapNew.get(trainingOfferingRecordId)) * offeringCreditByofferingId.get(trainingOfferingRecordId));
                Professional_Services_Credits__c trainingCreditObj = New Professional_Services_Credits__c(); 
                trainingCreditObj.RecordTypeId = ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID;
                trainingCreditObj.Account__c = accountId;
                trainingCreditObj.PS_Credit_SKU__c = ZScalarConstants.ZCES_EDU_CREDIT_SKU;
                
                //looping trough the existing PS credit records to get the ps credit information and map it on the newly created record.
                for(Professional_Services_Credits__c psCreditObj : psCreditListNew) {
                    Integer availableTrainingCredits = (Integer)(psCreditObj.Credits_Purchased__c - psCreditObj.Credits_Redeemed__c);
                    
                    if(trainingCreditsRedemmed == 0) {break;}
                    
                    if( trainingCreditsRedemmed > 0 && availableTrainingCredits> 0 && availableTrainingCredits >=  trainingCreditsRedemmed) {
                        trainingCreditsRedemmed = trainingCreditsRedemmed - trainingCreditsRedemmed ;
                        trainingCreditObj.Opportunity__c = psCreditObj.Opportunity__c;
                        trainingCreditObj.Opportunity_Close_Date__c = psCreditObj.Opportunity_Close_Date__c;
                        trainingCreditObj.Credits_Expiration_Date__c = psCreditObj.Credits_Expiration_Date__c;
                        trainingCreditObj.Credits_Purchased__c = trainingCreditsRedemmedlocal;
                        trainingCreditObj.PS_Credit_Name__c = psCreditObj.Opportunity__r.name + '-' + ZScalarConstants.ZCES_EDU_CREDIT_SKU + '-' + 'RF' + availableTrainingCreditsCount;
                    }else if(trainingCreditsRedemmed > 0 && availableTrainingCredits > 0 && availableTrainingCredits < trainingCreditsRedemmed) {
                        trainingCreditsRedemmed = trainingCreditsRedemmed - availableTrainingCredits ;
                    }
                }
                trainingCreditRecordsListToInsert.add(trainingCreditObj);
            }
        }
        return trainingCreditRecordsListToInsert;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-2878 : this method is to send emails to the Account CSM whenever Attack Surface Discovery Report offerings are redeemed.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : sendEmailForAttackSurfaceDiscoveryOffering .
* @param    NAME : String accountId .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/                  
    public static void sendEmailForAttackSurfaceDiscoveryOffering(String accountId) {
        try{
            
            Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;// To set the setTargetObjectId
            Account accountObj = [SELECT Id, Name, CSM_Name_New__c, OwnerId
                                  FROM Account
                                  WHERE Id =: accountId];
            
            EmailTemplate attackSurfaceDiscoveryReportEmailTemplate = [SELECT Id, Subject, Body, HtmlValue, DeveloperName  
                                                                       FROM EmailTemplate 
                                                                       WHERE DeveloperName =: ZScalarConstants.ATTACK_SURFACE_DISCOVERY_REPORT_EMAIL_TEMPLATE];
            
            OrgWideEmailAddress[] fromAddress = [select Id from OrgWideEmailAddress where Address =: Label.TrainingCreditsInsertEmailFromAddress];
            
            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            
            String htmlBody = '';
            String plainTextBody = '';
            Messaging.SingleEmailMessage emailMessageObj = new Messaging.SingleEmailMessage();
            Set<String> toAddressesSet = new Set<String>();
            
            if (accountObj.CSM_Name_New__c != null) {
                toAddressesSet.add(accountObj.CSM_Name_New__c);
            }
            if (accountObj.OwnerId != null) {
                toAddressesSet.add(accountObj.OwnerId);
            }
            
            htmlBody = attackSurfaceDiscoveryReportEmailTemplate.HtmlValue;
            plainTextBody = attackSurfaceDiscoveryReportEmailTemplate.Body;
            emailMessageObj.setTemplateId(attackSurfaceDiscoveryReportEmailTemplate.Id);
            emailMessageObj.setSubject(String.isBlank(attackSurfaceDiscoveryReportEmailTemplate.Subject) ? 'Attack Surface Discovery report was redeemed' : attackSurfaceDiscoveryReportEmailTemplate.Subject);
            emailMessageObj.setTargetObjectId(contactId);
            emailMessageObj.setWhatId(accountObj.Id);
            emailMessageObj.setOrgWideEmailAddressId(fromAddress.get(0).Id);
            emailMessageObj.setHtmlBody(htmlBody);
            emailMessageObj.setPlainTextBody(plainTextBody);
            emailMessageObj.setToAddresses(new List<String> (toAddressesSet));
            emailMessageObj.setCCAddresses(new String[]{'z-ps-ops-team@zscaler.com'});
            emailMessageObj.setBccAddresses(new String[]{'Z-PSCRDT-ATTACK-SRFC@zscaler.com'});
            emailMessageObj.setTreatBodiesAsTemplate(TRUE);
            emailMessageObj.setTreatTargetObjectAsRecipient(FALSE);
            emailMessageList.add(emailMessageObj);
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessageList);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
                ZscalerErrorLogsUtility.insertlogs(L2O_Constants.ErrorLog.CLASS_PS_PSREDEMPTIONSCREENCONTROLLER, 
                                                   'sendEmailForAttackSurfaceDiscoveryOffering', 
                                                   L2O_Constants.ErrorLog.Apex, 
                                                   UserInfo.getUserId(),
                                                   'Sales cloud', 
                                                   results[0].errors[0].message, 
                                                   results[0].errors[0].message, 
                                                   'Email Send Failed');
            }
        }catch(Exception e){
            System.debug('The email failed to send: Exception Cause - ' + 
                         e.getCause() + ', Message - ' + 
                         e.getMessage() + ', StackTrace - ' +
                         e.getStackTraceString());
            ZscalerErrorLogsUtility.insertlogs(L2O_Constants.ErrorLog.CLASS_PS_PSREDEMPTIONSCREENCONTROLLER, 
                                               'sendEmailForAttackSurfaceDiscoveryOffering', 
                                               L2O_Constants.ErrorLog.Apex, 
                                               UserInfo.getUserId(),
                                               'Sales cloud', 
                                               e.getStackTraceString(), 
                                               e.getMessage(), 
                                               e.getTypeName());
        }
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4744 : this method is to create the PS Credit Redemption Junction Objectrecords.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : createPSCreditRedemptionJunctionRecord .
* @param    NAME : Professional_Services_Credits__c psCredit,PS_Credit_Redemption__c psRedemption,Integer units .
* @return   TYPE : List<PS_Credit_Redemption_Junction__c>  psCreditRedemptionJunction .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/          
    private static PS_Credit_Redemption_Junction__c createPSCreditRedemptionJunctionRecord(Professional_Services_Credits__c psCredit,PS_Credit_Redemption__c psRedemption,Integer units) {
        PS_Credit_Redemption_Junction__c psCreditRedemptionJunction = new PS_Credit_Redemption_Junction__c();
        
        psCreditRedemptionJunction.PS_Credit_Redemption__c =  psRedemption.id;
        psCreditRedemptionJunction.Professional_Services_Credit__c = psCredit.id;
        psCreditRedemptionJunction.Account__c = psCredit.Account__c;
        psCreditRedemptionJunction.Opportunity__c = psCredit.Opportunity__c;
        psCreditRedemptionJunction.Project__c = psRedemption.Project__c;
        psCreditRedemptionJunction.PS_Credit_Credits_Redeemed__c = units;
        
        return psCreditRedemptionJunction;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4744 : this method is to create the PS Credit Redemption Junction Objectrecords.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : createPSCreditAndPSCreditJundtionRecords .
* @param    NAME : List<PS_Credit_Redemption__c> psCreditRedemptionListToInsert, List<Professional_Services_Credits__c> psCreditListNew .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/              
    public static void createPSCreditAndPSCreditJundtionRecords(List<PS_Credit_Redemption__c> psCreditRedemptionListToInsert, List<Professional_Services_Credits__c> psCreditListNew) {
        
        Map<Id,Professional_Services_Credits__c> psCreditTobeUpdatedWithCreditsRedeemed = new Map<Id,Professional_Services_Credits__c>();
        List<PS_Credit_Redemption_Junction__c> psCreditRedemptionJunctionRecords = new List<PS_Credit_Redemption_Junction__c>();
        Set<PS_Credit_Redemption__c> earlyEngagementPSRedemptions = new Set<PS_Credit_Redemption__c>();
        
        for(PS_Credit_Redemption__c creditRedemption : psCreditRedemptionListToInsert) {
            Integer creditsToBeRedemmed = Integer.valueOf(creditRedemption.Units_Redeemed__c * offeringCreditByofferingId.get(creditRedemption.PS_Offering__c));
            
            for(Professional_Services_Credits__c psCredit : psCreditListNew) {
                Integer availableCredits = (Integer)(psCredit.Credits_Purchased__c - psCredit.Credits_Redeemed__c);
                
                if(creditsToBeRedemmed == 0) {break;}
                
                if( creditsToBeRedemmed > 0 && availableCredits> 0 && availableCredits >=  creditsToBeRedemmed) {
                    psCredit.Credits_Redeemed__c  = psCredit.Credits_Redeemed__c + creditsToBeRedemmed;
                    psCreditRedemptionJunctionRecords.add (createPSCreditRedemptionJunctionRecord(psCredit,creditRedemption,creditsToBeRedemmed));
                    psCreditTobeUpdatedWithCreditsRedeemed.put(psCredit.Id,psCredit);
                    creditsToBeRedemmed = creditsToBeRedemmed - creditsToBeRedemmed ;
                    updateIsEarlyEngagementRedemption(psCredit,creditRedemption);
                }else if(creditsToBeRedemmed > 0 && availableCredits > 0 && availableCredits < creditsToBeRedemmed) {
                    psCredit.Credits_Redeemed__c  = psCredit.Credits_Redeemed__c + availableCredits;
                    psCreditRedemptionJunctionRecords.add(createPSCreditRedemptionJunctionRecord(psCredit,creditRedemption,availableCredits));
                    creditsToBeRedemmed = creditsToBeRedemmed - availableCredits ;
                    psCreditTobeUpdatedWithCreditsRedeemed.put(psCredit.Id,psCredit);
                    updateIsEarlyEngagementRedemption(psCredit,creditRedemption);
                }   
            }
            
            earlyEngagementPSRedemptions.add(creditRedemption);
        }
        
        if(!psCreditRedemptionJunctionRecords.isEmpty() && !psCreditTobeUpdatedWithCreditsRedeemed.isEmpty()) {
            Database.insert(psCreditRedemptionJunctionRecords);
            Database.update(psCreditTobeUpdatedWithCreditsRedeemed.values());
            if(!earlyEngagementPSRedemptions.isEmpty()) {
                DMLManager.updateAsSystem(new List<PS_Credit_Redemption__c>(earlyEngagementPSRedemptions),L2O_Constants.ErrorLog.CLASS_PS_PSREDEMPTIONSCREENCONTROLLER);
            }
        }
    }
    
    /** IBA- 5448
* @description : To update Credit Redemption field - "Is Early Engagement Redemption?" if PS credit of type EE is redeemed.
* @param : Professional_Services_Credits__c 
* @param : PS_Credit_Redemption__c 
* @return : PS_Credit_Redemption__c
*/
    private static PS_Credit_Redemption__c updateIsEarlyEngagementRedemption(Professional_Services_Credits__c psCredit, PS_Credit_Redemption__c creditRedemption) {
        if(psCredit.EE_Credit__c) {
            creditRedemption.IsEarlyEngagementRedemption__c = true;  
        }
        return creditRedemption;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# IBA - 1098 : this method calculates and returns the Number(i.e. RF number) that the Project record should be named with.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getAvailableTrainingCreditsCount .
* @param    NAME : String accountId .
* @return   TYPE : Integer - RF count for the Project records .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    private static Integer getAvailableTrainingCreditsCount(String accountId) {
        List<AggregateResult> trainingCreditAggrResult = [ SELECT COUNT(Id) existingTrainingCreditsCount 
                                                          FROM Professional_Services_Credits__c 
                                                          WHERE Account__c =: accountId 
                                                          AND RecordTypeId =: ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID
                                                          AND PS_Credit_Name__c LIKE '%-RF%'];
        Integer count = Integer.valueOf(trainingCreditAggrResult[0].get('existingTrainingCreditsCount'));                                            
        
        return count;                                               
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4744 : this is a generic method to return the PS credit records for the given Account Id.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getPSCreditRecords .
* @param    NAME : String accountId .
* @return   TYPE : List<Professional_Services_Credits__c> .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    private static List<Professional_Services_Credits__c> getPSCreditRecords(String accountId,Boolean shouldRedeemEECredit) { 
        //Boolean hasEarlyEngagement = doesUserhaveEarlyEngagementPermission();
        List<Professional_Services_Credits__c> customerCredits = new List<Professional_Services_Credits__c>();
        
        for( Professional_Services_Credits__c customerCredit : [SELECT   Id,
                                                                Account__c,
                                                                Credits_Remaining__c,
                                                                Credits_Purchased__c,
                                                                Credits_Expiration_Date__c,
                                                                Credits_Redeemed__c,
                                                                PS_Credit_SKU__c,
                                                                Opportunity__c,
                                                                Opportunity_Close_Date__c,
                                                                RecordTypeId,
                                                                EE_Credit__c,
                                                                Opportunity__r.Name
                                                                FROM Professional_Services_Credits__c 
                                                                WHERE Account__c =: accountId
                                                                AND Is_Redemption_Valid__c = true
                                                                AND RecordTypeId =: ZScalarConstants.PS_CREDIT_RECORDTYPEID
                                                                ORDER BY Credits_Expiration_Date__c asc]) {
                                                                    
                                                                    if(shouldRedeemEECredit == customerCredit.EE_Credit__c) {
                                                                        customerCredits.add(customerCredit);
                                                                    }
                                                                }
        
        return customerCredits;
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4744 : this is the Wrapper class for PS Credit Object.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : PsCreditWrapper .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    public class PsCreditWrapper{  
        @AuraEnabled  
        public string psCreditId,psCreditName,opportunityName,opportunityId,accountName; 
        @AuraEnabled  
        public decimal creditsPurchased,creditsRemaining,creditsRedeemed,totalAvailableCredits; 
        @AuraEnabled 
        public DateTime opportunityCloseDate,creditsExpirationDate;
        @AuraEnabled 
        public Boolean isEarlyEngagementCredit; //IBA-5448
        
        public PsCreditWrapper(Professional_Services_Credits__c psCreditObj){  
            this.psCreditName = psCreditObj.PS_Credit_Name__c; 
            this.opportunityId = psCreditObj.Opportunity__c;
            this.opportunityName = psCreditObj.Opportunity__r.Name;
            this.psCreditId = psCreditObj.Id;
            this.creditsPurchased = psCreditObj.Credits_Purchased__c;
            this.creditsRemaining = psCreditObj.Credits_Remaining__c;
            this.creditsRedeemed = psCreditObj.Credits_Redeemed__c;
            this.opportunityCloseDate = psCreditObj.Opportunity_Close_Date__c;
            this.creditsExpirationDate = psCreditObj.Credits_Expiration_Date__c;
            this.totalAvailableCredits = psCreditObj.Account__r.Total_Available_credits__c; 
            this.accountName = psCreditObj.Account__r.Name;
            this.isEarlyEngagementCredit = psCreditObj.EE_Credit__c; //IBA-5448
        }  
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 - Allow all users to redeem PS credits and create Project.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : ModalModule .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/     
    public class ModalModule {
        public String contact;
        public String DeploymentStartDate;
        public String RequesterTimeZone;
        public String filterClause;
        public Integer CreditsRequired;
        public Integer Units;
        public String Name;
        public String Id;
        public String RecordTypeId;
        public String notes;
    }
    
    private static Boolean doesUserhaveEarlyEngagementPermission() {
        return FeatureManagement.checkPermission('Early_Engagement_Customer_Credit');
        
    }
}