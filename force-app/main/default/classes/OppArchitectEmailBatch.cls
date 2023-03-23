global class OppArchitectEmailBatch implements Database.Batchable<sObject>,  Database.Stateful{ 
    
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('OppArchitectEmailBatch');   
    
    public Set<Id> recIds = new Set<Id>(); 
    global OppArchitectEmailBatch(Set<Id> ids){
        recIds = ids;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callStart();
        
        Date dt = system.today().addDays(-180);
        String stage2 = Label.Stage_2_Qualified_Budgeted;
        String query = 'Select ID,Amount,StageName,Type,Account.Solution_Architect__c,Account.Solution_Architect__r.Email__c,Architect__r.Email__c,Opportunity_Account_Manager__r.Email__c,SE_Name__r.Email__c,Opportunity_Area_Director__r.Email__c,Account.Last_Architecture_Workshop_Date__c,Account.Type,Flexible_Identifier__c from Opportunity where Flexible_Identifier__c = null AND Amount > 150000 AND Account.Type IN (\'Customer\',\'Prospect\')   AND Type IN (\'New Business\',\'Existing Customer (Add On)\') ANd StageName IN (:stage2) AND ( Account.Last_Architecture_Workshop_Date__c <=:dt OR Account.Last_Architecture_Workshop_Date__c=null) AND Stage_2_Architecture_Email_Sent__c=false AND Opportunity_Territory_Type__c in (\'Major\', \'Large Enterprise\') ' +  ( recIds.isEmpty() ? '' : ' AND Id IN  :recIds');
        
        if(Test.isRunningTest()){
            query = 'Select ID,Amount,StageName,Type,Account.Solution_Architect__c,Account.Solution_Architect__r.Email__c,Architect__r.Email__c,Opportunity_Account_Manager__r.Email__c,SE_Name__r.Email__c,Opportunity_Area_Director__r.Email__c,Account.Last_Architecture_Workshop_Date__c,Account.Type from Opportunity where Amount > 150000 AND Account.Type IN (\'Customer\',\'Prospect\')   AND Type IN (\'New Business\',\'Existing Customer (Add On)\') ANd StageName IN (:stage2) AND ( Account.Last_Architecture_Workshop_Date__c <=:dt OR Account.Last_Architecture_Workshop_Date__c=null) AND Stage_2_Architecture_Email_Sent__c=false ' +  ( recIds.isEmpty() ? '' : ' AND Id IN  :recIds');
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Opportunity> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> theTemplate = [SELECT Id,HtmlVAlue,Subject FROM EmailTemplate WHERE DeveloperName='Automated_Solution_Architect'];
        
        for(Opportunity o : scope){
            
            List<String> toSend = new List<String>();
            
            if(o.Account.Solution_Architect__c != null && o.Architect__c != o.Account.Solution_Architect__c){
                o.Architect__c = o.Account.Solution_Architect__c;  
            }
            
            if(o.Account.Solution_Architect__c != null){
                toSend.add(o.Account.Solution_Architect__r.Email__c);
            }
            
            if(o.Opportunity_Account_Manager__c != null && String.isNotBlank(o.Opportunity_Account_Manager__r.Email__c)){
                toSend.add(o.Opportunity_Account_Manager__r.Email__c);
            }            
            if(o.SE_Name__c != null && String.isNotBlank(o.SE_Name__r.Email__c) ) {
                toSend.add(o.SE_Name__r.Email__c);
            }
            
            String leadeShipTeamEmail = System.Label.Cc_label;
            List<String> toCc = new List<String>();
            If(leadeShipTeamEmail != null && String.isNotEmpty(leadeShipTeamEmail)){
                toCc.add(System.Label.Cc_label);
                if(o.Opportunity_Area_Director__c != Null && String.isNotBlank(o.Opportunity_Area_Director__r.Email__c)){
                    toCc.add(o.Opportunity_Area_Director__r.Email__c);
                }
            }
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(theTemplate[0].Id), Null, String.valueOf(o.Id));
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            mail.setToAddresses(toSend);
            if(toCc.size()>0){
                mail.setCcAddresses(toCc);    
            }
            if(!toSend.isEmpty()){
                emails.add(mail);
            }
            
            o.Stage_2_Architecture_Email_Sent__c = true;  
        }
        
        if(!Test.isRunningTest()){
            Messaging.sendEmail(emails);    
        }
        //IBA-6429-Start
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Database.update(scope);
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        //IBA-6429-End
        
    }
    
    global void finish(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callFinish(BC);
    }
}