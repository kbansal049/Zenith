/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CustomerRenewalReminderController
* @description    This class is used to send the renewal reminder emails to CTMs (Contacts That Matters).
* 				  It will be called from the CustomerRenewalReminderBatch	
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-07-04
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public with sharing class CustomerRenewalReminderController {

    private static CustomerRenewalReminderController instance;
    public static CustomerRenewalReminderController getInstance() {
        if (instance == NULL) {
            instance = new CustomerRenewalReminderController();
        }

        return instance;
    }
    
    private final Boolean BOOLEAN_TRUE = TRUE;
    private final Boolean BOOLEAN_FALSE = FALSE;//Added by Swathi CR# 3042
    private final String RENEWAL_REMINDER_ORG_WIDE_ADDRESS_Display_Name = System.Label.Renewal_Reminder_Org_Wide_Address_Display_Name;  
    private final Set<String> EMAIL_TEMPLATE_SET = new Set<String> {'X100_Day_Renewal_Notice_to_Customer', 'X10_Day_Renewal_Notice_to_Customer', 'X270_Day_Renewal_Notice_to_Customer'};

    
    
    private List<Opportunity_Extension__c> oppExtList;
    public void setOppExtList(List<Opportunity_Extension__c> oppExtList) {
        this.oppExtList = oppExtList;
    }
    
    public void handle() {
        findRelatedData();
        retrieveRelatedCTMs();
        retrieveOrgWideAddress();
        retrieveEmailTemplates();
        sendEmail();
    }
    
    private Set<Id> relatedAccIdSet;
    private void setRelatedAccIdSet(Set<Id> relatedAccIdSet) {
        this.relatedAccIdSet = relatedAccIdSet;
    }
    
    private void findRelatedData() {
        Set<Id> relatedAccIdSet = new Set<Id> ();
        
        for(Opportunity_Extension__c oppExt : oppExtList) {
            relatedAccIdSet.add(oppExt.Opportunity__r.AccountId);
        }
        
        setRelatedAccIdSet(relatedAccIdSet);
    }
    
    private Map<Id, Set<String>> accountCTMSetMap;
    private void setAccountCTMSetMap(Map<Id, Set<String>> accountCTMSetMap) {
        this.accountCTMSetMap = accountCTMSetMap;
    }

    private void retrieveRelatedCTMs() {

        Map<Id, Set<String>> accountCTMSetMap = new Map<Id, Set<String>> ();

        for (Contact con : [
                SELECT 
                    Id,
                    AccountId
                FROM 
                    Contact
                WHERE
                    AccountId IN :relatedAccIdSet
                AND 
                    Contacts_that_matter__c = :BOOLEAN_TRUE
                AND
                    Renewal_Notification_Recipient__c = :BOOLEAN_FALSE //Added by Swathi CR# 3042
                WITH SECURITY_ENFORCED
                LIMIT 50000
            ]) {

            Set<String> conSet = accountCTMSetMap.containsKey(con.AccountId)
                ? accountCTMSetMap.get(con.AccountId)
                : new Set<String> ();

            conSet.add(con.Id);    
            accountCTMSetMap.put(con.AccountId, conSet);

        }

        setAccountCTMSetMap(accountCTMSetMap);

    }
    
	private OrgWideEmailAddress renewalReminderOrgWideAddress;
    private void setRenewalReminderOrgWideAddress(OrgWideEmailAddress renewalReminderOrgWideAddress) {
        this.renewalReminderOrgWideAddress = renewalReminderOrgWideAddress;
    }

    private void retrieveOrgWideAddress() {
        
        List<OrgWideEmailAddress> renewalReminderOrgWideAddressList = [
            SELECT
                Id,
                Address,
                DisplayName 
            FROM
                OrgWideEmailAddress
            WHERE
                DisplayName = :RENEWAL_REMINDER_ORG_WIDE_ADDRESS_Display_Name
            LIMIT 1
        ];

        if (!renewalReminderOrgWideAddressList.isEmpty()) {
            setRenewalReminderOrgWideAddress(renewalReminderOrgWideAddressList.get(0));
        }
    }

    private Map<String, EmailTemplate> emailTemplateMap;
    private void setEmailTemplateMap( Map<String, EmailTemplate> emailTemplateMap ) {
        this.emailTemplateMap = emailTemplateMap;
    }

    private void retrieveEmailTemplates() {

        Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate> (); 

        for (EmailTemplate emailTemp : [
            SELECT 
                Id,
                DeveloperName,
                HtmlValue
            FROM
                EmailTemplate
            WHERE
                DeveloperName IN :EMAIL_TEMPLATE_SET
        ]) {

            emailTemplateMap.put(emailTemp.DeveloperName, emailTemp);
        }

        setEmailTemplateMap(emailTemplateMap);
    }    
    
    
    private void sendEmail() {
        for(Opportunity_Extension__c oppExt : oppExtList) {
            String range;
            
            if ((oppExt.Renewal_Notice_to_CTMs_10d__c != NULL) && (oppExt.Renewal_Notice_to_CTMs_10d__c == System.Date.today()) && (oppExt.Opportunity__r.Number_of_Approved_Extension_Requests__c == 0)) {
                range = '10';
            } else if ((oppExt.Renewal_Notice_to_CTMs_100d__c != NULL) && (oppExt.Renewal_Notice_to_CTMs_100d__c == System.Date.today())) {
                range = '100';
            } else if ((oppExt.Renewal_Notice_to_CTMs_270d__c != NULL) && (oppExt.Renewal_Notice_to_CTMs_270d__c == System.Date.today())) {
                range = '270';
            }
            
            setRange(range);
            
            if(String.isNotBlank(range)) {
                sendRenewalReminderEmails(oppExt);
            }
            
        }
    }
    
    private String range;
    private void setRange(String range) {
        this.range = range;
    }
    
    private final Map<String, String> EMAIL_TEMPLATE_MAP = new Map<String, String> {
        '100' => 'X100_Day_Renewal_Notice_to_Customer', 
        '10'  => 'X10_Day_Renewal_Notice_to_Customer', 
        '270' => 'X270_Day_Renewal_Notice_to_Customer'
    };
    
    private void sendRenewalReminderEmails(Opportunity_Extension__c oppExt) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage> ();
        Messaging.SingleEmailMessage email;
        
        List<String> emailAddressList;
        
        Set<Id> ccAddressSet;

        Set<String> conSet = accountCTMSetMap.get(oppExt.Opportunity__r.AccountId);

        ccAddressSet = new Set<Id> ();
            
        ccAddressSet.add(oppExt.Opportunity__r.Account.OwnerId);
        
        if (oppExt.Opportunity__r.Account.CSM_Name_New__c != NULL) {
            ccAddressSet.add(oppExt.Opportunity__r.Account.CSM_Name_New__c);                
        }

        if ((range.equalsIgnoreCase('10')) && (oppExt.Opportunity__r.Account.CSM_Name_New__r.ManagerId != NULL)) {
            ccAddressSet.add(oppExt.Opportunity__r.Account.CSM_Name_New__r.ManagerId);
        }
        
        if ((range.equalsIgnoreCase('10')) && (oppExt.Opportunity__r.Account.Area_Director__c  != NULL)) {
            ccAddressSet.add(oppExt.Opportunity__r.Account.Area_Director__c );
        }


        email = new Messaging.SingleEmailMessage();

        emailAddressList = new List<String> ();
        
        if (conSet == NULL) {
            return;
        }
        
        emailAddressList.addAll(conSet);
        
        email.setWhatId(oppExt.Opportunity__r.Id);
        email.setTargetObjectId(emailAddressList.get(0));
        
        email.setSaveAsActivity(!BOOLEAN_TRUE);
        email.setTreatTargetObjectAsRecipient(!BOOLEAN_TRUE);

        String emailTempName = EMAIL_TEMPLATE_MAP.containsKey(range) ? EMAIL_TEMPLATE_MAP.get(range) : ''; 

        if (!emailTemplateMap.containsKey(emailTempName)) {
            return;
        }

        email.setTemplateId(emailTemplateMap.get(emailTempName).Id);

        if (renewalReminderOrgWideAddress != NULL) {
            email.setOrgWideEmailAddressId(renewalReminderOrgWideAddress.Id);
        }

        List<Id> ccAddressList = new List<Id> ();
            
        if (!ccAddressSet.isEmpty()) {
            ccAddressList.addAll(ccAddressSet);
            email.setCcAddresses(ccAddressList);
        }
        
        email.setToAddresses(emailAddressList);
        emailList.add(email);

        List<Messaging.SendEmailResult> emailResponseList = Messaging.sendEmail(emailList);

        if (emailResponseList[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                  + emailResponseList[0].errors[0].message);
        }
    }

    
    
}