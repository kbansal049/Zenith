/*
 * @description       : 
 * Modifications Log 
 * Ver   	Date(MM-DD-YYYY)      Author        		Modification
 * 1.0   	NA           		  Udit Jain.    		Initial Version
 * 2.0   	12-08-2022         	  Mahesh T              IBA-5143 
 * 
*/
global without sharing class sendEmailForOpportunityCreation {
	// Start - IBA-2848
    @InvocableMethod(label='sendEmailForOpportunityCreation')
    global static void sendEmailsToBusiness(List<String> oppIds){
        Map<String,OpportunityContactRole> ocrMap = new Map<String,OpportunityContactRole>();
        List<OpportunityContactRole> ocrList = [Select Id,OpportunityId,ContactId,Contact.IsIncludeRSM__c,Contact.Most_Recent_Campaign__c,Contact.Most_Recent_Campaign__r.Name,
                                                Contact.Partner_Level__c,Contact.Campaign_TAM_Email__c
                                                from OpportunityContactRole where OpportunityId IN: oppIds order by createddate desc limit 10000];
        if(!ocrList.isEmpty()){
            for(OpportunityContactRole ocr : ocrList){
                if(ocr.ContactId != null && ocr.OpportunityId!=null){
                    if(!ocrMap.containsKey(ocr.OpportunityId)){
                        ocrMap.put(ocr.OpportunityId,ocr);
                    }
                }
            }
        }
        List<Opportunity> oppList = [SELECT Id,AccountId,CreatedById,Area__c,District_Account__c,CampaignId,Account.Name,Name,
                                    Campaign.Partner_company__c,Campaign.Partner_company__r.Name,Owner.Email,CreatedBy.Email,Amount,
                                    Opportunity_Creator_Manager_Email__c,Opportunity_Owner_Manager_Email__c,Customer_Contact__c,CloseDate,
                                    Owner.FirstName,Owner.LastName,CreatedBy.FirstName,CreatedBy.LastName,CreatedDate,
                                    Opportunity_Sales_Territory__r.Regional_Tech_Alliance_Manager__r.Email__c
                                    FROM Opportunity 
                                    WHERE Id IN: oppIds 
                                    LIMIT 10000];
        if(!oppList.isEmpty()){
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Stage_0_Opportunity_Creation_1'];
            List<Messaging.SingleEmailMessage> mailLst = new List<Messaging.SingleEmailMessage>();
            Map<String,String> regionVsEmails = new Map<String,String>();
            List<Opportunity_Include_RSM__mdt> regionAndEmail = [SELECT Region__c,Sub_Region__c,Email1__c,Email2__c from Opportunity_Include_RSM__mdt];
            for(Opportunity_Include_RSM__mdt regionEmailRec : regionAndEmail){
                 string regionAndSubregion = regionEmailRec.Region__c.toLowerCase() +','+regionEmailRec.Sub_Region__c.toLowerCase();
                 string emails = (regionEmailRec.Email1__c).toLowercase() +','+(regionEmailRec.Email2__c).toLowercase();
                 regionVsEmails.put(regionAndSubregion,emails);
            }
            
            
            for(Opportunity opp : oppList){
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                Boolean isCampaignNameInclude = false;
                String campaignNameHtmlString = '';
                if(!ocrMap.isEmpty() ){
                   //Mahesh T--To send email to RTAM and TAM  for Tier 2 Partners-- Start IBA-5143
                    List<String> sendToCC = new List<String>();   
                    if(ocrMap.containsKey(opp.Id) && 
                       ocrMap.get(opp.Id).Contact.Partner_Level__c){
                           if(opp.Opportunity_Sales_Territory__r.Regional_Tech_Alliance_Manager__r.Email__c != null){
                           		sendToCC.add(opp.Opportunity_Sales_Territory__r.Regional_Tech_Alliance_Manager__r.Email__c);
                               // System.debug('opp RTAM'+opp.Opportunity_Sales_Territory__r.Regional_Tech_Alliance_Manager__r.Email__c);
                           }
                           if(ocrMap.get(opp.Id).Contact.Campaign_TAM_Email__c != null) {
                             	sendToCC.add(ocrMap.get(opp.Id).Contact.Campaign_TAM_Email__c);
                              //  System.debug('Campaign  TAM'+ocrMap.get(opp.Id).Contact.Campaign_TAM_Email__c);
                           }  
                           if(!sendToCC.isEmpty()){
                               isCampaignNameInclude = true;
                               campaignNameHtmlString = 'Campaign Name: <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ocrMap.get(opp.Id).Contact.Most_Recent_Campaign__c+'">'+ocrMap.get(opp.Id).Contact.Most_Recent_Campaign__r.Name+'</a><br>';
                               mail.setCcAddresses(sendToCC);
                           }
                          // End IBA-5143
                       }else if(ocrMap.containsKey(opp.Id) && ocrMap.get(opp.Id).Contact.IsIncludeRSM__c && !regionVsEmails.isEmpty()){
                           if(opp.Area__c != null && opp.District_Account__c != null){
                               String  keyForMap =  (opp.Area__c).toLowerCase() +','+(opp.District_Account__c).toLowerCase();
                               if(regionVsEmails.containsKey(keyForMap)){
                                   List<String> sendToCCList = regionVsEmails.get(keyForMap).split(',');
                                   sendToCC.add(sendToCCList[0]);
                                   sendToCC.add(sendToCCList[1]);
                               }
                               if(!sendToCC.isEmpty()){
                                   isCampaignNameInclude = true;
                                   campaignNameHtmlString = 'Campaign Name: <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ocrMap.get(opp.Id).Contact.Most_Recent_Campaign__c+'">'+ocrMap.get(opp.Id).Contact.Most_Recent_Campaign__r.Name+'</a><br>';
                                   mail.setCcAddresses(sendToCC);
                               }
                           }
                       }
                }
                String htmlBodyString = 'Hi '+opp.Owner.FirstName+' '+opp.Owner.LastName+',<br><br>';
                htmlBodyString = htmlBodyString + 'A stage 0 opportunity has been created in your name by '+opp.CreatedBy.FirstName+' '+opp.CreatedBy.LastName+'. You will have 5 weeks to complete a Discovery Meeting to move this opportunity to Stage 1. If no action is taken after 5 weeks, the opportunity will be auto-closed to Closed Lost.<br><br>';
                htmlBodyString = htmlBodyString + 'Account Name: '+opp.Account.Name+'<br>';
                htmlBodyString = htmlBodyString + 'Opportunity Name: <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'">'+opp.Name+'</a><br>';
                if(isCampaignNameInclude){
                    htmlBodyString = htmlBodyString + campaignNameHtmlString;
                }
                htmlBodyString = htmlBodyString + 'Opportunity Owner: '+opp.Owner.FirstName+' '+opp.Owner.LastName+'<br>';
                htmlBodyString = htmlBodyString + 'Created Date: '+opp.CreatedDate.date().format()+'<br>';
                htmlBodyString = htmlBodyString + 'Created By: '+opp.CreatedBy.FirstName+' '+opp.CreatedBy.LastName+'<br>';
                if(opp.Amount!=null){
                    htmlBodyString = htmlBodyString + 'Amount: '+opp.Amount+'<br>';
                }else{
                    htmlBodyString = htmlBodyString + 'Amount: '+'<br>';
                }
                htmlBodyString = htmlBodyString + 'Close Date: '+opp.CloseDate.format();
                mail.setHtmlBody(htmlBodyString);
                mail.setSubject(emailTemplate.Subject);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setWhatId(opp.Id);
                mail.setSaveAsActivity(false);
                List<String> sendTo = new List<String>{opp.Owner.Email,opp.CreatedBy.Email};
                if(opp.Opportunity_Creator_Manager_Email__c != null){
                    sendTo.add(opp.Opportunity_Creator_Manager_Email__c);
                }
                if(opp.Opportunity_Owner_Manager_Email__c != null){
                    sendTo.add(opp.Opportunity_Owner_Manager_Email__c);
                }
                mail.setToAddresses(sendTo);
                mailLst.add(mail);
            }
            if(!mailLst.isEmpty()){
                Messaging.sendEmail(mailLst);
            }
        }
    }
    // End - IBA-2848
}