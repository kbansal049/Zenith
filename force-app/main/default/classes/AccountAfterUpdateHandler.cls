public class AccountAfterUpdateHandler {
    public static Set<Id> processIds = new Set<Id>();
    public static void process(Map<Id,Account> triggerNewMap,Map<Id,Account>triggerOldMap){
        
        List<Account> changedAccounts = new List<Account>();
        Map<Id,Opportunity> oppMapToUpdate = new Map<Id,Opportunity>();
        List<Opportunity> oppsToEmailList  = new List<Opportunity>();
        
        for(Account a  : processIds.isEmpty() ? triggerNewMap.values() : new List<Account>()){
            system.debug('#### acc archi ' + a.Solution_Architect__c + triggerOldMap.get(a.Id).Solution_Architect__c );
            system.debug('#### acc last aw date' + a.Last_Architecture_Workshop_Date__c + ' Prev date =>' + triggerOldMap.get(a.Id).Last_Architecture_Workshop_Date__c);
            system.debug('### account SA changed'+ hasSAchanged(a,triggerOldMap.get(a.Id)));
            system.debug('### account hasAccfieldChange changed'+ hasAccfieldChange(a,triggerOldMap.get(a.Id)));
            if(Trigger.isUpdate && (hasAccfieldChange(a,triggerOldMap.get(a.Id)) || hasSAchanged(a,triggerOldMap.get(a.Id)))){
                changedAccounts.add(a);
            }
        }
        system.debug('Account%%' + changedAccounts);
        Map<Id,List<Opportunity>> accOppMap = processIds.isEmpty() ?  getAccountOpps(changedAccounts) : new  Map<Id,List<Opportunity>>();
        
        for(Account a : processIds.isEmpty() ? triggerNewMap.values() : new List<Account>()){
            for(Opportunity opp : (accOppMap.containsKey(a.Id) && hasSAchanged(a,triggerOldMap.get(a.Id))) ? accOppMap.get(a.Id) : new List<Opportunity>()){
                opp.Architect__c = a.Solution_Architect__c;
                oppMapToUpdate.put(opp.Id,opp);    
            }
            for(Opportunity opp : (accOppMap.containsKey(a.Id) && hasAccfieldChange(a,triggerOldMap.get(a.Id))) ? accOppMap.get(a.Id) : new List<Opportunity>()){
                if(conditionsMeet(opp) && !opp.Stage_2_Architecture_Email_Sent__c)
                    oppsToEmailList.add(opp);    
            }
            processIds.add(a.Id);
        }
        
        
        Database.update(oppMapToUpdate.values(),false);
        if(!oppsToEmailList.isEmpty())
            SendEmail(oppsToEmailList);
        
        
        
    }
    @TestVisible
    private static Boolean conditionsMeet(Opportunity opp){
        return (opp.Amount >=150000 && 
            opp.StageName.equalsIgnoreCase('2 - Qualified & Budgeted') && 
            (opp.Type.equalsIgnoreCase('New Business') || opp.Type.equalsIgnoreCase('Existing Customer (Add On)')) &&
            opp.Flexible_Identifier__c==NULL  );
    }
    
    @TestVisible
    private static Map<Id,List<Opportunity>> getAccountOpps(List<Account> accs){
        Map<Id,List<Opportunity>> accOppMap = new Map<Id,List<Opportunity>>();
        for(Opportunity opp : [SELECT id,Architect__c,AccountId,Amount,Type,StageName,Flexible_Identifier__c,
                               Opportunity_Account_Manager__c, SE_Name__c,Opportunity_Area_Director__c,Architect__r.Email,
                               Opportunity_Account_Manager__r.Email,SE_Name__r.Email,Opportunity_Area_Director__r.Email,
                               Stage_2_Architecture_Email_Sent__c
                                FROM Opportunity
                                WHERE AccountId IN: accs                                       
                                        ]){
                                            if(!accOppMap.containsKey(opp.AccountId)){
                accOppMap.put(opp.AccountId,new List<Opportunity>());
                                            }
            List<Opportunity> opps = accOppMap.get(opp.AccountId);
            opps.add(opp);
            accOppMap.put(opp.AccountId,opps);  
        }
        system.debug('$$$'+accOppMap);
        return accOppMap;
    }
    
    
    @testVisible
    private static Boolean hasAccfieldChange(Account aNew,Account aOld){
        Date dt = system.today().addDays(-180);
        return((aNew.Type != aOld.Type && (aNew.Type.equalsIgnoreCase('Prospect') || aNew.Type.equalsIgnoreCase('Customer')) && (aNew.Last_Architecture_Workshop_Date__c <=dt || aNew.Last_Architecture_Workshop_Date__c == null ) ) ||
               (aNew.Last_Architecture_Workshop_Date__c != aOld.Last_Architecture_Workshop_Date__c) && (aNew.Last_Architecture_Workshop_Date__c <=dt || aNew.Last_Architecture_Workshop_Date__c == null && (aNew.Type.equalsIgnoreCase('Prospect') || aNew.Type.equalsIgnoreCase('Customer')) ) ||
               (aNew.Solution_Architect__c != aOld.Solution_Architect__c && aNew.Solution_Architect__c!=NULL)
              );
        
    }
    @testVisible
    private static Boolean hasSAchanged(Account aNew,Account aOld){
        return(aNew.Solution_Architect__c != aOld.Solution_Architect__c && aNew.Solution_Architect__c!=NULL);
        
    }
    @testVisible
    private static void SendEmail(List<Opportunity> oppList){
         List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> theTemplate = (oppList!=null && !oppList.isEmpty()) ? [SELECT Id,HtmlVAlue,Subject FROM EmailTemplate WHERE DeveloperName='Automated_Solution_Architect'] : new List<EmailTemplate>();
        for(Opportunity o : oppList){
            List<String> toSend = new List<String>();
            if(o.Architect__c != null && String.isNotBlank(o.Architect__r.Email)){
               toSend.add(o.Architect__r.Email) ;
            }
            if(o.Opportunity_Account_Manager__c != null  && String.isNotBlank(o.Opportunity_Account_Manager__r.Email)){
                toSend.add(o.Opportunity_Account_Manager__r.Email);
            }           
            if(o.SE_Name__c != null && String.isNotBlank(o.SE_Name__r.Email)) {
                toSend.add(o.SE_Name__r.Email);
            }
           List<String> toCc = new List<String>();
           if(o.Opportunity_Area_Director__c != Null && String.isNotBlank(o.Opportunity_Area_Director__r.Email)){
                toCc.add(o.Opportunity_Area_Director__r.Email);
            }
                toCc.add(System.Label.Cc_label);            
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(theTemplate[0].Id), Null, String.valueOf(o.Id));
             mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            mail.setToAddresses(toSend);
            mail.setCcAddresses(toCc);
             if(!toSend.isEmpty())
                emails.add(mail);
            o.Stage_2_Architecture_Email_Sent__c = true; 
               
        }
        if(!emails.isEmpty())
            Messaging.sendEmail(emails);
        Database.update(oppList,false);
    }
}