/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* OpportunitySplitOwnerEmailService
* @description    This class is being called from the Opportunity trigger which sends email to 
* 					OpportunitySplit owner's when the stage is 5C
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-09-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class OpportunitySplitOwnerEmailService {
    
    public static Boolean sendOpportunitySplitOwnerEmails = FALSE;
    
    private final Boolean BOOLEAN_TRUE = TRUE;
    
    private static OpportunitySplitOwnerEmailService instance;
    public static OpportunitySplitOwnerEmailService getInstance() {
        if (instance == NULL) {
            instance = new OpportunitySplitOwnerEmailService();
        }
        
        return instance;
    }

    public void process() {

        if (!newOpportunityList.isEmpty()) {
            retrieveOpportunitySplit(); 
        }

        if ((opportunitySplitOwnerMap != NULL) && (!opportunitySplitOwnerMap.isEmpty())) {
            setOpportunityEmailTemplate();
            setOrgWideEmailAddr();
            for (Opportunity opp : newOpportunityList) {
            	sendEmail(opp);    
            }
            
            OpportunitySplitOwnerEmailService.sendOpportunitySplitOwnerEmails = TRUE;
            
        }
        
        
    }
    
    private List<Opportunity> newOpportunityList;
    public void setNewOpportunityList(List<Opportunity> newOpportunityList) {
        List<Opportunity> newOpportunityFilteredList = new List<Opportunity> ();

        for (Opportunity opp : newOpportunityList) {
            if (opp.StageName.equalsIgnoreCase(System.Label.Stage_5C_Opportunity)) {
                newOpportunityFilteredList.add(opp);
            }
        }

        this.newOpportunityList = newOpportunityFilteredList;
    }

    private Map<Id, Set<Id>> opportunitySplitOwnerMap;
    private void setOpportunitySplitOwnerMap(Map<Id, Set<Id>> opportunitySplitOwnerMap) {
        this.opportunitySplitOwnerMap = opportunitySplitOwnerMap;
    }
    
    private void retrieveOpportunitySplit() {

        Map<Id, Set<Id>> opportunitySplitOwnerMap = new Map<Id, Set<Id>> ();
        
        for (OpportunitySplit oppSplit : [
            SELECT
                Id,
                SplitOwnerId,
                OpportunityId
            FROM 
                OpportunitySplit
            WHERE
                OpportunityId IN : newOpportunityList
        ]) {

            Set<Id> ownerIdSet = opportunitySplitOwnerMap.containsKey(oppSplit.OpportunityId)
                ? opportunitySplitOwnerMap.get(oppSplit.OpportunityId)
                : new Set<Id> ();
            
            ownerIdSet.add(oppSplit.SplitOwnerId);

            opportunitySplitOwnerMap.put(oppSplit.OpportunityId, ownerIdSet);

        }
        
        setOpportunitySplitOwnerMap(opportunitySplitOwnerMap);

    }
    
    private final String OPP_HITS_5C = 'Opportunity_hits_5C_stage';
    
    private EmailTemplate opportunityEmailTemplate;
    
    private void setOpportunityEmailTemplate() {
        List<EmailTemplate> emailTemplateList = [
            SELECT 
                Id,
                DeveloperName,
                HtmlValue
            FROM
                EmailTemplate
            WHERE
                DeveloperName = :OPP_HITS_5C
            LIMIT 1
        ];
        
        if (!emailTemplateList.isEmpty()) {
        	this.opportunityEmailTemplate = emailTemplateList.get(0);    
        }
        
    }
    
    private OrgWideEmailAddress orgWideEmailAddr;
    private void setOrgWideEmailAddr() {
        orgWideEmailAddr = [SELECT Id, Address, DisplayName, Purpose, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE DisplayName='Salesforce Admin'];
    }

    private void sendEmail(Opportunity opp) {
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage> ();
        
        List<Id> emailAddressList;
        Set<Id> splitOwnerIdSet = opportunitySplitOwnerMap.containsKey(opp.Id) ? opportunitySplitOwnerMap.get(opp.Id) : new Set<Id>();
                
        if ((splitOwnerIdSet.isEmpty()) || (opportunityEmailTemplate == NULL)) {
            return;
        }

        emailAddressList = new List<Id> ();
        emailAddressList.addAll(splitOwnerIdSet);
        
        System.debug('-=- emailAddressList -=- '+emailAddressList);
        
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate (String.valueOf(opportunityEmailTemplate.Id), String.valueOf(emailAddressList.get(0)), String.valueOf(opp.Id));
        
		email.setSubject(email.getSubject());
        email.setPlainTextBody(email.getPlainTextBody());
        
        email.setSaveAsActivity(!BOOLEAN_TRUE);
        email.setTreatTargetObjectAsRecipient(!BOOLEAN_TRUE);
        
        email.setToAddresses(emailAddressList);
        
        email.setOrgWideEmailAddressId(orgWideEmailAddr.Id);
        
        emailList.add(email);
        
        List<Messaging.SendEmailResult> emailResponseList = new List<Messaging.SendEmailResult>();
        
        if (!Test.isRunningTest()) {
            emailResponseList = Messaging.sendEmail(emailList);
        }
        
        for (Messaging.SendEmailResult res : emailResponseList) {
            
            System.debug('-=-=- res -=- '+res);
            
            if (res.success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + res.errors[0].message);
            }
        }
        
    }
}