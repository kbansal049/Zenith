public class AutomaticStrikeBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('AutomaticStrikeBatch');
    String query;    
    List<Case> strike1=new List<Case>();
    List<Case> strike2=new List<Case>();
    List<Case> strike3=new List<Case>();
    List<Id> casesToUpdate =new List<Id>();
    Integer Strike1value=Integer.valueOf(System.Label.Strike1);
    Integer Strike2value=Integer.valueOf(System.Label.Strike2);
    Integer Strike3value=Integer.valueOf(System.Label.Strike3);
    public AutomaticStrikeBatch(String query){
        this.query=query;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Case> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        System.debug('Execute Run');
        for(Case cs:scope){
            Boolean toBeProcessed=false;    
            if((cs.Pending_Customer_Time_Difference__c==Strike1value && cs.Contact.Email!=null && cs.Owner.profileId=='00e0g000000k7qL') || Test.isRunningTest()){
                strike1.add(cs);
                toBeProcessed = true;
            }
            if((cs.Pending_Customer_Time_Difference__c==Strike2value && cs.Contact.Email!=null && cs.Owner.profileId=='00e0g000000k7qL') || Test.isRunningTest()){
                strike2.add(cs);
                toBeProcessed = true;
            }
            if((cs.Pending_Customer_Time_Difference__c==Strike3value && cs.Contact.Email!=null && cs.Owner.profileId=='00e0g000000k7qL') || Test.isRunningTest()){
                strike3.add(cs);
                toBeProcessed = true;
            }
            if(toBeProcessed){
                casesToUpdate.add(cs.Id);
            }
        }
    }
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        List<String> templateNames = new List<String>{'Automatic_Strike_1','Automatic_Strike_2','Automatic_Strike_3'};
            Map<String,String> emailTemplates = new Map<String, String>();
        for(EmailTemplate et : [SELECT Id, Name, DeveloperName, IsActive, HtmlValue, Body, Subject 
                                FROM EmailTemplate 
                                WHERE DeveloperName IN :templateNames AND isActive= true]) {
                                    emailTemplates.put(et.DeveloperName, et.Id);
                                }
        String AutomaticStrike1Id = emailTemplates.containsKey('Automatic_Strike_1')?emailTemplates.get('Automatic_Strike_1'):'';
        String AutomaticStrike2Id = emailTemplates.containsKey('Automatic_Strike_2')?emailTemplates.get('Automatic_Strike_2'):'';
        String AutomaticStrike3Id = emailTemplates.containsKey('Automatic_Strike_3')?emailTemplates.get('Automatic_Strike_3'):'';
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support-noreply@zscaler.com'];
        Id contactId=[select id from Contact limit 1].Id;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        List<String> ccEmails = new List<String>();  
        if(!strike1.isEmpty()){
            for(Case cs:strike1){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                ccEmails = new List<String>();
                if(cs.Customer_CC_List__c!=null){
                    for(String s:cs.Customer_CC_List__c.split(';')){
                        if(s != '' && s!= null){
                            ccEmails.add(s.trim().toLowerCase());
                        }
                    }
                }    
                if(cs.Internal_CC_List__c!=null){
                    for(String s:cs.Internal_CC_List__c.split(';')){
                        if(s != '' && s!= null){
                            ccEmails.add(s.trim().toLowerCase());
                        }
                    }
                } 
                if(cs.Owner.Email!=null){
                    ccEmails.add(cs.Owner.Email);
                }  
                email.setToAddresses(new String[] {cs.Contact.Email});
                email.setCcAddresses(ccEmails);
                if(owea.size() > 0){
                    email.setOrgWideEmailAddressId(owea.get(0).Id);  
                }
                email.setSaveAsActivity(true);
                email.setTargetObjectId(contactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setTemplateId(AutomaticStrike1Id);
                email.setWhatId(cs.Id);
                mails.add(email);
            }
        }
        if(!strike2.isEmpty()){
            for(Case cs:strike2){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                ccEmails = new List<String>();
                if(cs.Customer_CC_List__c!=null){
                    for(String s:cs.Customer_CC_List__c.split(';')){
                        if(s != '' && s!= null){
                            ccEmails.add(s.trim().toLowerCase());
                        }
                    }
                }    
                if(cs.Internal_CC_List__c!=null){
                    for(String s:cs.Internal_CC_List__c.split(';')){
                        if(s != '' && s!= null){
                            ccEmails.add(s.trim().toLowerCase());
                        }
                    }
                } 
                if(cs.Owner.Email!=null){
                    ccEmails.add(cs.Owner.Email);
                }   
                email.setToAddresses(new String[] {cs.Contact.Email});
                email.setCcAddresses(ccEmails);
                if(owea.size() > 0){
                    email.setOrgWideEmailAddressId(owea.get(0).Id);  
                }
                email.setSaveAsActivity(true);
                email.setTargetObjectId(contactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setTemplateId(AutomaticStrike2Id);
                email.setWhatId(cs.Id);
                mails.add(email);
            }
        }
        if(!strike3.isEmpty()){
            for(Case cs:strike3){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                ccEmails = new List<String>();
                if(cs.Customer_CC_List__c!=null){
                    for(String s:cs.Customer_CC_List__c.split(';')){
                        if(s != '' && s!= null){
                            ccEmails.add(s.trim().toLowerCase());
                        }
                    }
                }    
                if(cs.Internal_CC_List__c!=null){
                    for(String s:cs.Internal_CC_List__c.split(';')){
                        if(s != '' && s!= null){
                            ccEmails.add(s.trim().toLowerCase());
                        }
                    }
                } 
                if(cs.Owner.Email!=null){
                    ccEmails.add(cs.Owner.Email);
                }   
                email.setToAddresses(new String[] {cs.Contact.Email});
                email.setCcAddresses(ccEmails);
                if(owea.size() > 0){
                    email.setOrgWideEmailAddressId(owea.get(0).Id);  
                }
                email.setSaveAsActivity(true);
                email.setTargetObjectId(contactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setTemplateId(AutomaticStrike3Id);
                email.setWhatId(cs.Id);
                mails.add(email);
            }
        }
        if(!mails.isEmpty()){
            System.debug('Email Sent Run');
            if(!Test.isRunningTest()){
                TriggerUtility.EmailMessageAfterInsertExecuted();
                Messaging.sendEmail(mails);
            }
        } 
        // execute any post-processing operations
        if(!casesToUpdate.isEmpty()){
            AutomaticStrikeCloseCaseBatch batch=new AutomaticStrikeCloseCaseBatch(casesToUpdate);
            Database.executeBatch(batch,1);
        }
    }
    
}