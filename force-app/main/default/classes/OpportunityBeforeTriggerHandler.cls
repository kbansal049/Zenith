public class OpportunityBeforeTriggerHandler{
    public static void process(List<Opportunity>triggerNew,Map<Id,Opportunity>TriggerOldMap){
        Map<Id,Opportunity> oppAccMap = getOppAccMap(triggerNew);
         List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Date dt = system.today().addDays(-180);
        List<EmailTemplate> theTemplate = Trigger.isUpdate ? [SELECT Id,HtmlVAlue,Subject FROM EmailTemplate WHERE DeveloperName='Automated_Solution_Architect'] : new List<EmailTemplate>();
 
        for(Opportunity opp : triggerNew){
            opp.Architect__c = Trigger.isInsert && oppAccMap.containsKey(opp.id) ? oppAccMap.get(opp.id).ACCOUNT.Solution_Architect__c : opp.Architect__c;
            if(Trigger.isUpdate && hasfieldChange(opp,triggerOldMap.get(opp.Id)) && !opp.Stage_2_Architecture_Email_Sent__c){
                List<String> toSend = new List<String>();
                if(opp.Architect__c != null && String.isNotBlank(oppAccMap.get(opp.Id).Architect__r.Email) )
                   toSend.add(oppAccMap.get(opp.Id).Architect__r.Email) ;
                if(opp.Opportunity_Account_Manager__c != null && String.isNotBlank(oppAccMap.get(opp.Id).Opportunity_Account_Manager__r.Email))
                    toSend.add(oppAccMap.get(opp.Id).Opportunity_Account_Manager__r.Email);                
                if(opp.SE_Name__c != null && String.isNotBlank(oppAccMap.get(opp.Id).SE_Name__r.Email) )
                    toSend.add(oppAccMap.get(opp.Id).SE_Name__r.Email);                                  
                List<String> toCc = new List<String>();
                if(opp.Opportunity_Area_Director__c != Null && String.isNotBlank(oppAccMap.get(opp.Id).Opportunity_Area_Director__r.Email))
                    toCc.add(oppAccMap.get(opp.Id).Opportunity_Area_Director__r.Email);                
                toCc.add(System.Label.Cc_label);
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(theTemplate[0].Id), null , String.valueOf(opp.Id));
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                mail.setToAddresses(toSend);               
                mail.setCcAddresses(toCc);
                if(!toSend.isEmpty()){
                    emails.add(mail);
                    opp.Stage_2_Architecture_Email_Sent__c = true;
                }    
     
            }
        }
        Messaging.sendEmail(emails);
    }
    @TestVisible
    private static Map<Id,Opportunity> getOppAccMap(List<Opportunity> opps){
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        for(Opportunity opp : [SELECT ID,ACCOUNT.Solution_Architect__c,Architect__c,Architect__r.Email,
                               Opportunity_Account_Manager__c,Opportunity_Account_Manager__r.Email,
                               SE_Name__c,SE_Name__r.Email, Opportunity_Area_Director__c,Opportunity_Area_Director__r.Email,
                               Stage_2_Architecture_Email_Sent__c
                               FROM opportunity 
                               WHERE ID IN:opps 
                               AND AccountId!=NULL]){
            oppMap.put(opp.Id,opp);
        }   
        return oppMap;
    }
    
    @TestVisible
    private static Boolean hasfieldChange(Opportunity oNew,Opportunity oOld){
        return (( oNew.StageName!=oOld.StageName && oNew.StageName.equalsIgnoreCase('2 - Qualified & Budgeted') && oOld.stageName.equalsIgnoreCase('1 - Alignment')  && oNew.Amount > 150000 && (oNew.Type.equalsIgnoreCase('New Business') || oNew.Type.equalsIgnoreCase('Existing Customer (Add On)')) && oNew.Flexible_Identifier__c == Null )
                || (oNew.Amount != oOld.Amount && oNew.Amount > 150000  && oNew.StageName.equalsIgnoreCase('2 - Qualified & Budgeted') && (oNew.Type.equalsIgnoreCase('New Business') || oNew.Type.equalsIgnoreCase('Existing Customer (Add On)') ) && oNew.Flexible_Identifier__c == Null ) 
                || 
                (oNew.Type != oOld.Type && (oNew.Type.equalsIgnoreCase('New Business') || oNew.Type.equalsIgnoreCase('Existing Customer (Add On)')) && oNew.StageName.equalsIgnoreCase('2 - Qualified & Budgeted') && oNew.Amount > 150000 && oNew.Flexible_Identifier__c == Null )
                
                || (oNew.Flexible_Identifier__c != oOld.Flexible_Identifier__c && oNew.Flexible_Identifier__c == Null && oNew.StageName.equalsIgnoreCase('2 - Qualified & Budgeted') && oNew.Amount > 150000 && (oNew.Type.equalsIgnoreCase('New Business') || oNew.Type.equalsIgnoreCase('Existing Customer (Add On)') ) ) );
    }
}