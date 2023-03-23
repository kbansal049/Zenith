/**
 * Name : TAMEngagementTriggerHandler
 * Description : Handler class for TAMEngagementTrigger
 * Test Class : TAMEngagementTriggerHandlerTest
 * Initial Author : Ankit Bhatnagar
 */

public class TAMEngagementTriggerHandler extends TriggerHandler  {
    
    public override void beforeInsert(){
        //Set value of CSM on TAM Engagement from parent Account
        setCSMonTAMEngagement((List<TAM_Engagement__c>)Trigger.new);
    }

    public override void beforeUpdate(){
        for(TAM_Engagement__c engagement : (List<TAM_Engagement__c>)Trigger.new) {
            addErrorApproval(engagement,(TAM_Engagement__c)Trigger.oldMap.get(engagement.id));
        }
    }

    public override void afterInsert() {
        /*Map<String,Account> accountsOnboardingDetails = new Map<String,Account>();
        for(TAM_Engagement__c engagement : (List<TAM_Engagement__c>)Trigger.new) {
            Account acc = setOnboardingDetailsOnAccount(engagement, null);
            if(acc!=null) {
                accountsOnboardingDetails.put(acc.Id,acc);
            }
        }
        if(!accountsOnboardingDetails.isEmpty()) {
            update accountsOnboardingDetails.values();
        }*/
    }

    public override void afterUpdate() {
        /*Map<String,Account> accountsOnboardingDetails = new Map<String,Account>();
        for(TAM_Engagement__c engagement : (List<TAM_Engagement__c>)Trigger.new) {
            Account acc = setOnboardingDetailsOnAccount(engagement, (TAM_Engagement__c)Trigger.oldMap.get(engagement.id));
            if(acc!=null) {
                accountsOnboardingDetails.put(acc.Id,acc);
            }
        }
        if(!accountsOnboardingDetails.isEmpty()) {
            update accountsOnboardingDetails.values();
        }*/
    }

    /*public Account setOnboardingDetailsOnAccount(TAM_Engagement__c engagement, TAM_Engagement__c engagementOld) {
        Account acc;
        if(engagementOld == null || (engagementOld != null && 
            (engagement.Customer_s_Business_Objectives__c != engagementOld.Customer_s_Business_Objectives__c ||
            engagement.Customer_Next_Steps__c != engagementOld.Customer_Next_Steps__c ||
            engagement.CS_Management_Notes__c != engagementOld.CS_Management_Notes__c))) {
            acc = new Account(
                Id = engagement.Account__c,
                Summarize_the_Value_to_the_Customer__c = engagement.Customer_s_Business_Objectives__c, 
                Customer_Next_Steps__c = engagement.Customer_Next_Steps__c,
                CS_Management_Notes__c = engagement.CS_Management_Notes__c
            );
        }
        return acc;
    }*/

    public void addErrorApproval(TAM_Engagement__c engagement, TAM_Engagement__c engagementOld) {
        if((engagement.tam_engagement_status__c == 'Work in Progress' || engagement.tam_engagement_status__c == 'Rejected') && engagement.tam_engagement_status__c != engagementOld.tam_engagement_status__c) {
            if(!engagement.Approval_Action_from_cmp__c) {
                engagement.addError('You can only Approve/Reject a TAM Engagement from the Edit TAM Engagement Page.');
            }
            else {
                engagement.Approval_Action_from_Cmp__c = false;
            }
        }
    }

    public void setCSMonTAMEngagement(List<TAM_Engagement__c> engagements) {
        Map<String, String> accCSMMap = new Map<String, String>();
        for(TAM_Engagement__c eng : engagements) {
            accCSMMap.put(eng.Account__c,'');
        }
        for(Account a : [SELECT id,CSM_Name_New__c FROM Account WHERE Id IN : accCSMMap.keySet()]) {
            accCSMMap.put(a.id, a.CSM_Name_New__c);
        }
        for(TAM_Engagement__c eng : engagements) {
            eng.CSM__c = accCSMMap.get(eng.Account__c)!=''?accCSMMap.get(eng.Account__c):UserInfo.getUserId();
        }
    }
}