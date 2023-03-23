/*****************************************************************************************
Name: RenewalOppClosedLostSendEmailHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex Controller for Send Churn Initiation Emails once the Renewal Opportunity is closed Lost.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Varun Dua            12/10/2021      CR# 2948      Churn Initiation Email Alert.
2.0                Harish Gowda N       03/03/2023      IBA-5447      "A Churn Request has been initiated" Email are going out blank.
******************************************************************************************/ 

public class RenewalOppClosedLostSendEmailHelper { 
    
    public static final string APEX_CLASS_NAME = 'RenewalOppClosedLostSendEmailHelper';
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-7403 : A Churn Request has been initiated" Email are going out blank .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : sendChurnInitiationEmails .
* @param    NAME : List<Opportunity> OptyListToSendChurnInitiationEmails .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void sendChurnInitiationEmails(List<Opportunity> optyListToSendChurnInitiationEmails){
        try {
            List<Opportunity> optyListToSendChurnInitiationEmailsNew = new List<Opportunity>();
            Map<Id, Churn__c> optyIdToChurnMap = new  Map<Id, Churn__c>();
            Map<Id, List<String>> optyManagerEmailListMap = new Map<Id, List<String>>();
            //Calling the helper methods to get the Opportunity List, Prepare optyIdToChurnMap, optyManagerEmailListMap and to send the Email.
            optyListToSendChurnInitiationEmailsNew = getOpportunityList(optyListToSendChurnInitiationEmails);
            optyIdToChurnMap = prepareOptyIdToChurnMap(optyListToSendChurnInitiationEmails);
            optyManagerEmailListMap = prepareToAdressList(optyListToSendChurnInitiationEmailsNew);
            sendChurnInitiationForOpportunityEmail(optyListToSendChurnInitiationEmailsNew, optyManagerEmailListMap, optyIdToChurnMap);
        }
        catch (Exception e) {
            ZscalerErrorLogsUtility.insertlogs(APEX_CLASS_NAME, 'sendChurnInitiationEmails', L2O_Constants.ErrorLog.ERROR_IN, 
                                               UserInfo.getUserId(), L2O_Constants.ErrorLog.BIZ_AREA, e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-7403 : A Churn Request has been initiated" Email are going out blank .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getOpportunityList .
* @param    NAME : List<Opportunity> optyListToSendChurnInitiationEmails .
* @return   TYPE : List<Opportunity> opportunityListToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static List<Opportunity> getOpportunityList (List<Opportunity> optyListToSendChurnInitiationEmails) {
        List<Opportunity> opportunityListToReturn = new List<Opportunity>();
        //This Query is required as we need to refer some related fields from Account and Churn related to opportunity which can't be used from the original list. 
        opportunityListToReturn = [SELECT
                                   Id,Name,Owner.name,Account.name,OwnerId,Account.CSM_Name_New__c, Account.Channel_Manager__c,
                                   Account.Account_Manager__c,Account.Area_Director__c,Owner.Email,Account.CSM_Name_New__r.Email,
                                   Account.Channel_Manager__r.Email,Account.Account_Manager__r.Email,Account.Area_Director__r.Email
                                   FROM
                                   Opportunity
                                   WHERE
                                   Id IN :optyListToSendChurnInitiationEmails];
        return opportunityListToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-7403 : A Churn Request has been initiated" Email are going out blank .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareOptyIdToChurnMap .
* @param    NAME : List<Opportunity> optyListToSendChurnInitiationEmails .
* @return   TYPE : Map<Id, Churn__c> optyIdToChurnMapToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Map<Id, Churn__c> prepareOptyIdToChurnMap (List<Opportunity> optyListToSendChurnInitiationEmails) {
        Map<Id, Churn__c> optyIdToChurnMapToReturn = new  Map<Id, Churn__c>();
        //This Query is get all churn related to the Opportunity. 
        for (Churn__c churnObj : [SELECT Id,Name,Opportunity__c,Name__c,Type__c,Reason_Categorisations__c,
                                  Churn_Reason__c,Churn_Details__c,Detail__c
                                  FROM Churn__c
                                  WHERE Opportunity__c IN :optyListToSendChurnInitiationEmails]) {
                                      optyIdToChurnMapToReturn.put(churnObj.Opportunity__c, churnObj);
                                  }
        return optyIdToChurnMapToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-7403 : A Churn Request has been initiated" Email are going out blank .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareToAdressList .
* @param    NAME : List<Opportunity> opportunityListForToAdressList .
* @return   TYPE : Map<Id, List<String>> optyManagerEmailListMapToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Map<Id, List<String>> prepareToAdressList (List<Opportunity> opportunityListForToAdressList) {
        Map<Id, List<String>> optyManagerEmailListMapToReturn = new Map<Id, List<String>>();
        for (Opportunity toAddressOptyobj : opportunityListForToAdressList) {
            List<String> managerIdList = optyManagerEmailListMapToReturn.containsKey(toAddressOptyobj.Id) ? optyManagerEmailListMapToReturn.get(toAddressOptyobj.Id) : new List<String> ();
            //To check and add Account CSM to the managerIdList to send emails.
            if (toAddressOptyobj.Account.CSM_Name_New__c != null) {
                managerIdList.add(toAddressOptyobj.Account.CSM_Name_New__r.Email);
            }
            //To check and add Account Channel Managers to the managerIdList to send emails.
            if (toAddressOptyobj.Account.Channel_Manager__c != null) {
                managerIdList.add(toAddressOptyobj.Account.Channel_Manager__r.Email);
            }
            //To check and add Account Managers to the managerIdList to send emails.
            if (toAddressOptyobj.Account.Account_Manager__c != null) {
                managerIdList.add(toAddressOptyobj.Account.Account_Manager__r.Email);
            }
            //To check and add Account Area Directors to the managerIdList to send emails.
            if (toAddressOptyobj.Account.Area_Director__c != null) {
                managerIdList.add(toAddressOptyobj.Account.Area_Director__r.Email);
            }
            if (toAddressOptyobj.OwnerId != null) {
                managerIdList.add(toAddressOptyobj.Owner.Email);
            }
            if (!managerIdList.isEmpty()) {
                optyManagerEmailListMapToReturn.put(toAddressOptyobj.Id, managerIdList);
            }
        }
        return optyManagerEmailListMapToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-7403 : A Churn Request has been initiated" Email are going out blank.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : sendChurnInitiationForOpportunityEmail .
* @param    NAME : List<Opportunity> opportunityListForToSendEmail, Map<Id, List<String>> optyManagerEmailListMap, Map<Id, Churn__c> optyIdToChurnMap .
* @return   TYPE : Void .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void sendChurnInitiationForOpportunityEmail (List<Opportunity> opportunityListForToSendEmail, Map<Id, List<String>> optyManagerEmailListMap, Map<Id, Churn__c> optyIdToChurnMap) {
        String emailConfig = 'Opportunity_Churn_Initiation_Email';
        String subject;
        String emailTemplateBody;
        Churn__c churnObj = new Churn__c();
        List<String> toAdressList = new List<String>();
        List<String> ccAdressList = new List<String>();
        List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
        EmailUtility emailUtility = new EmailUtility(emailConfig);
        emailTemplateBody = emailUtility.template.HtmlValue;
        //Looping trough the Opportunities passed to send emails for each of the Opportuity .
        for(Opportunity opportunityObjToSendEmail : opportunityListForToSendEmail){
            if(optyManagerEmailListMap.containsKey(opportunityObjToSendEmail.Id)){
                toAdressList = optyManagerEmailListMap.get(opportunityObjToSendEmail.Id);
            }
            churnObj = optyIdToChurnMap.get(opportunityObjToSendEmail.Id);
            subject = emailUtility.template.Subject +' '+'-'+'"'+opportunityObjToSendEmail.Account.name+'"'+' '+'-'+'"'+opportunityObjToSendEmail.Name+'"';
            String accountLink = '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+opportunityObjToSendEmail.AccountId+'">'+opportunityObjToSendEmail.Account.Name+'</a>';
            emailTemplateBody = emailTemplateBody.replace('Account Name',accountLink);
            if(churnObj != null){
                if(churnObj.Name != null && churnObj.Id != null){
                    String churnLink = '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+churnObj.Id+'">'+churnObj.Name+'</a>';
                    emailTemplateBody = emailTemplateBody.replace('Churn Number String',churnLink);
                }
                if(churnObj.Type__c != null){
                    emailTemplateBody = emailTemplateBody.replace('Type String',churnObj.Type__c);
                }
                if(churnObj.Reason_Categorisations__c != null){
                    emailTemplateBody = emailTemplateBody.replace('Reason Categorisation String',churnObj.Reason_Categorisations__c);
                }
                if(churnObj.Churn_Reason__c != null){
                    emailTemplateBody = emailTemplateBody.replace('Churn Reason String',churnObj.Churn_Reason__c);
                }
                else{
                    emailTemplateBody = emailTemplateBody.replace('Churn Reason String',''); 
                }
                if(churnObj.Detail__c != null){
                    emailTemplateBody = emailTemplateBody.replace('Detail String',churnObj.Detail__c);
                }
            }
            else{
                emailTemplateBody = emailTemplateBody.replace('Churn Number String','');
                emailTemplateBody = emailTemplateBody.replace('Type String',''); 
                emailTemplateBody = emailTemplateBody.replace('Reason Categorisation String','');
                emailTemplateBody = emailTemplateBody.replace('Churn Reason String','');
                emailTemplateBody = emailTemplateBody.replace('Detail String','');
            }
            emailUtility.htmlBody = emailTemplateBody;
            emailsToBeSent.add(emailUtility.prepareEmailWithCustomSubject(toAdressList,ccAdressList,opportunityObjToSendEmail.Id,subject));
        }
        if(!emailsToBeSent.isEmpty()){
            emailUtility.sendEmails(emailsToBeSent);
        }
    }
}