/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* OpportunityClosedLostSendEmailHelper
* @description    This class will be used to send the closed lost emails
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-09-29
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class OpportunityClosedLostSendEmailHelper {
    private static OpportunityClosedLostSendEmailHelper instance;
    public static OpportunityClosedLostSendEmailHelper getInstance() {
        if (instance == NULL) {
            instance = new OpportunityClosedLostSendEmailHelper();
        }
        
        return instance;
    }
    
    private Map<Id, Opportunity> oldOppMap;
    
    public void setOldOppMap(Map<Id, Opportunity> oldOppMap) {
        this.oldOppMap = oldOppMap;
    }
    
    private List<Opportunity> oppList;
    public void setOppList(List<Opportunity> oppList) {
        
        List<Opportunity> filteredOppList = new List<Opportunity> ();
        
        for (Opportunity opp : oppList) {
            System.debug('-=- opp.StageName -=- '+opp.StageName);
            
            if ((opp.StageName != oldOppMap.get(opp.Id).StageName) 
                && (opp.StageName.equalsIgnoreCase(System.Label.Stage_7_Closed_Lost) 
                && ((String.isNotBlank(opp.Geo_Account__c)) 
                && (opp.Geo_Account__c.equalsIgnoreCase('EMEA'))))
                && (!opp.Type.equalsIgnoreCase(ZScalarConstants.Opp_Type_Existing_Customer_Renewal))) {
                
                filteredOppList.add(opp);
            }
        }
        
        System.debug('-=- filteredOppList -=- '+filteredOppList);
        
        
        this.oppList = [
            SELECT
            	Id,
            	OwnerId, 
            	Owner.ManagerId, 
	            Owner.Manager.Name, 
            	Owner.Manager.ManagerId, 
            	Owner.Manager.Manager.ManagerId,
	            Opportunity_Sales_Territory__c,
	            Opportunity_Sales_Territory__r.Sales_Engineer__c,
	            Opportunity_Sales_Territory__r.Sales_Engineer__r.ManagerId,
                StageName,
                Geo_Account__c,
                Owner.Id,
                Sub_Stage__c,
                Region_Account__c,
                Area__c
            FROM
            	Opportunity
            WHERE
            	Id IN :filteredOppList
        ];
    }
    
    private Map<Id, Churn__c> oppChurnMap;
    
    private void retrieveOppChurnMap() {
        oppChurnMap = new Map<Id, Churn__c> ();
        
        for (Churn__c churn : [
            SELECT 
            	Id, 
            	Opportunity__r.Name,
	            Opportunity__r.Id,
	            Opportunity__r.Owner.Name,
	            Opportunity__r.SE_Name__r.Name,
	            Opportunity__r.Sub_Stage__c,
	            Opportunity__r.CloseDate,
            	Competitor__c,
            	Reason_Categorisations__c,
	            Detail__c
            FROM Churn__c
        	WHERE 
        		Opportunity__c IN :oppList]) {
            oppChurnMap.put(churn.Opportunity__c, churn);
        }
    }
    
    private Map<Id, Opportunity_Extension__c> oppOppExtMap;
    
    private void retrieveOppOppExtMap() {
        oppOppExtMap = new Map<Id, Opportunity_Extension__c> ();
        
        for (Opportunity_Extension__c oppExt : [
            SELECT 
            	Id,
            	Opportunity__c, 
            	Duplicate_Opportunity__c,
            	Opportunity__r.Id,
            	Opportunity__r.Name,
            	Opportunity__r.Owner.Name,
            	Opportunity__r.SE_Name__r.Name,
            	Opportunity__r.Sub_Stage__c,
            	Opportunity__r.CloseDate,
            	Duplicate_Opportunity__r.Id,
            	Duplicate_Opportunity__r.Name
            FROM 
            	Opportunity_Extension__c
        	WHERE 
        		Opportunity__c IN :oppList]) {
                    
        	oppOppExtMap.put(oppExt.Opportunity__c, oppExt);    
        }
    }
    
    private final Map<String, String> REGIONAL_SALES_REGION_MAP = new Map<String, String> {
        'CEUR' => System.Label.Regional_Sales_Ops_CEUR,
        'SEUR' => System.Label.Regional_Sales_Ops_SEUR,
        'UK&I' => System.Label.Regional_Sales_Ops_UK_I_NEUR,
        'NEUR' => System.Label.Regional_Sales_Ops_UK_I_NEUR   
    };
    
    
    private Map<Id, Set<String>> oppManagerSetMap;
    
    private void retrieveOppManagerSetMap() {
        oppManagerSetMap = new Map<Id, Set<String>> ();
        
        for (Opportunity opp : oppList) {
            
			Set<String> managerIdSet = oppManagerSetMap.containsKey(opp.Id) ? oppManagerSetMap.get(opp.Id) : new Set<String> ();
    		
            Boolean isRDAvailable = (opp.Owner.ManagerId != NULL);
            Boolean isRVPAvailable = isRDAvailable && (opp.Owner.Manager.ManagerId != NULL);
            Boolean isAVPAvailable = isRVPAvailable && (opp.Owner.Manager.Manager.ManagerId != NULL);
            
            Boolean isSEMAvailable = (opp.Opportunity_Sales_Territory__c != NULL) && (opp.Opportunity_Sales_Territory__r.Sales_Engineer__c != NULL);
            Boolean isSEDAvailable = isSEMAvailable && (opp.Opportunity_Sales_Territory__r.Sales_Engineer__r.ManagerId != NULL);
            
            
            if (isRDAvailable) {
				managerIdSet.add(opp.Owner.ManagerId);
            }
            
            if (isRVPAvailable) {
                managerIdSet.add(opp.Owner.Manager.ManagerId);
            }
            
            if (isRVPAvailable) {
                managerIdSet.add(opp.Owner.Manager.Manager.ManagerId);
            }
            
            if (isSEMAvailable) {
				managerIdSet.add(opp.Opportunity_Sales_Territory__r.Sales_Engineer__c);
            }
            
            if (isSEDAvailable) {
				managerIdSet.add(opp.Opportunity_Sales_Territory__r.Sales_Engineer__r.ManagerId);
            }
            
            managerIdSet.add(System.Label.VP_Sales_EMEA);
            managerIdSet.add(System.Label.VP_Sales_Engineering_EMEA);
            managerIdSet.add(System.Label.Sr_ManagerEMEA_Sales_Ops);
            
            if (REGIONAL_SALES_REGION_MAP.containsKey(opp.Area__c)) {
                managerIdSet.add(REGIONAL_SALES_REGION_MAP.get(opp.Area__c));
            }
            
            //managerIdSet.add(UserInfo.getUserId());
            
            if (!managerIdSet.isEmpty()) {
                oppManagerSetMap.put(opp.Id, managerIdSet);
            }
        }
    }
    
    public void process() {
        
        if (!oppList.isEmpty()) {
            retrieveOppChurnMap();
            retrieveOppOppExtMap();
            retrieveOppManagerSetMap();
            
            fetchOpportunityEmailTemplate();
            
            sendEmail();
        }
        
    }
    
    private final Set<String> CLOSED_OPP_EMAIL_TEMPLATESET = new Set<String> {
        'Email_On_Opp_Sub_Stage_Closed_Lost',
        'Email_On_Opp_Sub_Stage_Closed_Delete'
	};
        
    private Map<String, EmailTemplate> emailTemplateMap;
    
    
    private void fetchOpportunityEmailTemplate() {
        
        emailTemplateMap = new Map<String, EmailTemplate> ();
        
        for (EmailTemplate eTemp : [
            SELECT 
                Id,
                DeveloperName,
                HtmlValue,
	            Body
            FROM
                EmailTemplate
            WHERE
                DeveloperName = :CLOSED_OPP_EMAIL_TEMPLATESET
            LIMIT 2
        ]) {
            
            String type = eTemp.DeveloperName.containsIgnorecase('Delete') ? 'closed delete' : 'churn';
            
            emailTemplateMap.put(type, eTemp);
        }
        
        System.debug('-=- emailTemplateMap -=- '+emailTemplateMap);
        
    }
    
    
    private void sendEmail() {
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage> ();
                
        for (Opportunity opp : oppList) {
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            
            Id targetObjectId;
            
            String type = '';
            if (opp.Sub_Stage__c == 'Closed: Delete Duplicate') {
                type = 'closed delete';
                
                if (oppOppExtMap.containsKey(opp.Id)) {
                    targetObjectId = oppOppExtMap.get(opp.Id).Id;
                }
                
            } else if ((opp.Sub_Stage__c == 'Closed With No Decision') || (opp.Sub_Stage__c == 'Closed Lost')) {
                type = 'churn';
                
                if (oppChurnMap.containsKey(opp.Id)) {
                    targetObjectId = oppChurnMap.get(opp.Id).Id;
                }
                
            }
            
            EmailTemplate emailTemp;
            
            
            if (emailTemplateMap.containsKey(type)) {
                emailTemp = emailTemplateMap.get(type);
            }
            
            if (emailTemp == NULL) {
                continue;
            }
            
            List<String> userList = new List<String> (oppManagerSetMap.get(opp.Id));
            
            if (targetObjectId == NULL) {
                continue;
            }
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(String.valueOf(emailTemp.Id), String.valueOf(userList.get(0)), String.valueOf(targetObjectId));

            email.setSubject(email.getSubject());
            email.setPlainTextBody(email.getPlainTextBody());
            
            email.setSaveAsActivity(FALSE);
            email.setTreatTargetObjectAsRecipient(FALSE);
            
            email.setToAddresses(new List<String>(oppManagerSetMap.get(opp.Id)));
        
            
            emailList.add(email);
        }
        
        System.debug('-=- emailList -=- '+emailList);
        
        if(!emailList.isEmpty()){
            List<Messaging.SendEmailResult> emailResponseList = Messaging.sendEmail(emailList);
        }
        
    }

}