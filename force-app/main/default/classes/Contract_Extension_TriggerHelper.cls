public class Contract_Extension_TriggerHelper{
    public static void beforeupdate(List<Contract_Extension_Request__c> newlist, Map<Id, Contract_Extension_Request__c > oldmap){
        Map<ID, Contract_Extension_Request__c> opptyIdtoCR = new Map<ID, Contract_Extension_Request__c>();
        
        for(Contract_Extension_Request__c cr: newlist){
            if((cr.Approval_Status__c == 'Approved' || cr.Approval_Status__c =='Rejected' || cr.Approval_Status__c == 'Recalled') && oldmap.containskey(cr.Id) && oldmap.get(cr.Id).Approval_Status__c != cr.Approval_Status__c  && cr.Extension_Request_No__c == cr.Opportunity_Extension_Number__c){                
                opptyIdtoCR.put(cr.Opportunity__c, cr);
            }
        }
        
        setOpptyCRStatusandExtensionDate(opptyIdtoCR);
    }
    
    public static void AfterInsert(List<Contract_Extension_Request__c> newlist){
        Set<Id> OppIdSet = New Set<Id>();
        for(Contract_Extension_Request__c cr: newlist){
            OppIdSet.add(cr.Opportunity__c);
        }
        Map<ID,Opportunity> OppMap = new Map<ID,Opportunity>([Select id,Name,Owner.Name,Contract_End_Date_New__c,Account.Name,Account.CSM_Name_New__r.Email,Account.Sales_Engineer__r.Email,Account.Channel_Manager__r.Email,Account.Account_Manager__r.Email,Account.Geo__c,Account.Customer_Advocate__r.Email from Opportunity where Id In :OppIdSet]);
        EmailTemplate emailTemplate = [select Id, HTMLValue, DeveloperName,Subject  from EmailTemplate where DeveloperName = 'Contract_Extension_Request_Emails'];
        for(Contract_Extension_Request__c cr: newlist){
			String emailTemplatebody = emailTemplate.HTMLValue;
            String emailTemplatesubject = emailTemplate.Subject;
            String OppName = '';
            String OppOwnername = '';
            String ContractDate = '';
            String AccName = '';
            String ContReqEnddate = '';
            String ExtensionReqDate = '';
            String Reason = '';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            List<String> CCList = new List<String>();
            if(OppMap.containsKey(cr.Opportunity__c)){
            	Opportunity current_Opp = OppMap.get(cr.Opportunity__c);
                if(current_Opp.Account.CSM_Name_New__c !=null && current_Opp.Account.CSM_Name_New__r.Email != null){
                    sendTo.add(current_Opp.Account.CSM_Name_New__r.Email);
            	}
                if(current_Opp.Account.Account_Manager__c !=null && current_Opp.Account.Account_Manager__r.Email != null){
                    sendTo.add(current_Opp.Account.Account_Manager__r.Email);
            	}
                if(current_Opp.Account.Sales_Engineer__c !=null && current_Opp.Account.Sales_Engineer__r.Email != null){
                    sendTo.add(current_Opp.Account.Sales_Engineer__r.Email);
            	}
                if(current_Opp.Account.Channel_Manager__c !=null && current_Opp.Account.Channel_Manager__r.Email != null){
                    sendTo.add(current_Opp.Account.Channel_Manager__r.Email);
            	}
                if(current_Opp.Account.Geo__c !=null && current_Opp.Account.Geo__c == 'International'){
                    if(runningInASandbox())
                		CCList.add('Z-International-Sales-Ops@zscaler.com.invalid');
                	else
                        CCList.add('Z-International-Sales-Ops@zscaler.com');
                }
                else if(current_Opp.Account.Geo__c !=null && (current_Opp.Account.Geo__c == 'Americas' || current_Opp.Account.Geo__c =='Public Sector')){
                    if(runningInASandbox())
                    	CCList.add('Z-AMS-Sales-Ops@zscaler.com.invalid');
                    else
                        CCList.add('Z-AMS-Sales-Ops@zscaler.com');
                }
                else if(current_Opp.Account.Geo__c !=null && current_Opp.Account.Geo__c == 'Channel'){
                    if(runningInASandbox())
                    	CCList.add('z-channel-sales-ops@zscaler.com.invalid');
                    else
                        CCList.add('z-channel-sales-ops@zscaler.com');
                }
                if(current_Opp.Name!=null){
                    OppName = current_Opp.Name;
                }
                if(current_Opp.Owner.Name!=null){
                    OppOwnername = current_Opp.Owner.Name;
                }
                if(cr.Opportunity_Contract_End_date__c !=null){
                    ContractDate = (cr.Opportunity_Contract_End_date__c).format();
                }
                if(cr.Contract_Extension_Date__c!=null){
                    ContReqEnddate = (cr.Contract_Extension_Date__c).format();
                }
                if(current_Opp.Account.Name !=null){
                    AccName = current_Opp.Account.Name;
                }
                if(cr.Extension_Request_Date__c!=null){
                    ExtensionReqDate = (cr.Extension_Request_Date__c).format();
                }
                if(cr.Detailed_Reason_for_Contract_Extension__c!=null){
                    Reason = cr.Detailed_Reason_for_Contract_Extension__c;
                }
            }
            emailTemplatesubject = emailTemplatesubject.replace('[**Account_Name**]',AccName);
            emailTemplatebody = emailTemplatebody.replace('[**Account_Name**]',AccName);
            emailTemplatebody = emailTemplatebody.replace('[**Opp_Name**]','<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+OppMap.get(cr.Opportunity__c).Id+'">'+OppName+'</a>');
            emailTemplatebody = emailTemplatebody.replace('[**Opp_Owner_Name**]',OppOwnername);
            emailTemplatebody = emailTemplatebody.replace('[**Cont_End_Date**]',ContractDate);
            emailTemplatebody = emailTemplatebody.replace('[**req_Ext_Date**]',ContReqEnddate);
            emailTemplatebody = emailTemplatebody.replace('[**Ext_req_Date**]',ExtensionReqDate);
            emailTemplatebody = emailTemplatebody.replace('[**cont_Ext_Reason**]',Reason);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'Z-RenewalOps@zscaler.com'];
            if (owea.size() > 0 ) {
            	mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            //mail.setsenderDisplayName('Zscaler Renewals Team');
            mail.setToAddresses(sendTo);
			mail.setCcAddresses(CCList);
            mail.setSubject(emailTemplatesubject);
            mail.setHtmlBody(emailTemplatebody);
            
            if(!Test.isRunningTest()){
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        	}
            system.debug('---Mail Sent----'+mail);
        }
        TriggerUtility2.contractExtensionEmailSentExecuted();
    }
    
    public static void setOpptyCRStatusandExtensionDate(Map<ID, Contract_Extension_Request__c> opptyIdtoCR){
        List<Opportunity> opptoupdate = new List<Opportunity>();
        for(Id oppId: opptyIdtoCR.keyset()){
            opptoupdate.add(new Opportunity(Id = oppId, Extension_Approval_Status__c = opptyIdtoCR.get(oppId).Approval_Status__c , New_Extended_Contract_Date__c = opptyIdtoCR.get(oppId).Approval_Status__c == 'Approved' ? opptyIdtoCR.get(oppId).Contract_Extension_Date__c : null));
        }
        update opptoupdate;
    }
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}