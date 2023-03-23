global class BatchSendInternalHandoffEmail implements Database.Batchable<sObject>, Database.Stateful {
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchSendInternalHandoffEmail');
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        set<string> filterOpportunityStages = new set<string>{
            label.Stage_5A_Opportunity,   //Added by Swathi: CR2973 // Replaceable value for 10b - PO recd, pending finance approval
                label.Stage_6_Closed_Won   // Replaceable value for 13 - Closed & Approved By Finance
                };
                    //query is edited as part of CR#3616 by Ayush kangar --- now sending email if amount is greater than 50k
                    String query = 'SELECT Id,Account.Name,Amount,AccountId,SE_Name__c, Premium_Support__c, SE_Name__r.Email,SE_Name__r.Name, Architect__c, Architect__r.Name, Architect__r.Email, Hand_off_Email_Sent__c,name, X3_Why__c,Value_Pyramid__c,Account.Architecture_Workshop_Link__c   from opportunity where StageName IN: filterOpportunityStages AND type = \'New Business\' AND Hand_off_Email_Sent__c = false and Amount >= 200000 and (CloseDate = NEXT_N_DAYS:14 OR CloseDate = TODAY OR CloseDate = YESTERDAY)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Opportunity> scope){
        
        this.zb.callExecute(scope[0]?.Id, scope.size());
        List<Opportunity> opportunitylist = (list<Opportunity>) scope;
        Set<Id> Opp_idlist = new Set<Id>();
        Map<Id,List<Account>> account_map =  new Map<Id,List<Account>>();
        for(Integer i=0;i<opportunitylist.size();i++){
            Opp_idlist.add(opportunitylist[i].AccountId);
        }
        
        Map<Id,Account> accdetails = new Map<Id,Account>([SELECT Id,Name,Account_Manager__r.Email,Account_Manager__r.Name,
                                                          Channel_Manager__r.Email,Customer_Advocate__r.Email,
                                                          Area_Director__r.Email,  CSM_Name_New__r.Email,CSM_Name_New__r.Manager.Email,
                                                          CSM_Name_New__r.Full_Name__c,TAM_Name_New__r.Email,
                                                          Solution_Architect__c,Solution_Architect__r.Name,
                                                          Solution_Architect__r.Email,
                                                          TAM_Name_New__r.Full_Name__c,
                                                          Secondary_TAM_Name__r.Email,X3rd_TAM_Name__r.Email,
                                                          Assigned_DAS_Engr__c,Assigned_TPC_DOR__c,District__c,
                                                          DAS_Engineer__r.Full_Name__c,Geo__c,Area__c FROM Account WHERE Id In :Opp_idlist]);
        
        EmailTemplate emailTemplate = [select Id, HTMLValue, DeveloperName,Subject  from EmailTemplate where DeveloperName = 'Hand_Off_Email_JIT_Training'];
        if(!opportunitylist.isEmpty()){
            try{
                for(Opportunity opport : opportunitylist) {
                    String emailTemplatebody = emailTemplate.HTMLValue;
                    String emailTemplatesubject = emailTemplate.Subject;
                    String SEname = '';
                    String Accountname = '';
                    String AccountId = '';
                    String GEO = '';
                    String Area = '';
                    String ACVAmount = '';
                    String PSAmount = '';
                    String Solution_architect_name = '[Solution_Architect_Name]';
                    String CSMname = '[CSM_Name]';
                    String TAMname = '[TAM_Name]';
                    String Assigned_DAS_Engr = '[Assigned_DAS_Engineer]';
                    String Assigned_TPC_DOR = '[Assigned_DAS_TPC]';
                    String DAS_Engineer = '[Assigned_DAS_Engineer]';
                    String RSMName = '[RSM_Name]';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> sendTo = new List<String>();
                    //Added by Swathi : CR2253 Start
                    List<String> CCList = new List<String>();
                    List<String> BCCList = new List<String>();
                    if(Label.z_cs_leaders_alias != null){
                        BCCList.addall(Label.z_cs_leaders_alias.split(','));
                    }
                    //Added by Swathi : CR2253 End
                    if(accdetails.containsKey(opport.AccountId)){
                        Account current_acc = accdetails.get(opport.AccountId);
                        if(opport.SE_Name__r!= null && opport.SE_Name__r.Email != null){
                            sendTo.add(opport.SE_Name__r.Email);
                        }
                        if(current_acc.Account_Manager__r!= null && current_acc.Account_Manager__r.Email != null){
                            sendTo.add(current_acc.Account_Manager__r.Email);
                        }
                        if(current_acc.Channel_Manager__r != null && current_acc.Channel_Manager__r.Email != null){
                            sendTo.add(current_acc.Channel_Manager__r.Email);
                        }
                        if(current_acc.Customer_Advocate__r != null && current_acc.Customer_Advocate__r.Email != null){
                            sendTo.add(current_acc.Customer_Advocate__r.Email);
                        }
                        if(current_acc.Area_Director__r!= null && current_acc.Area_Director__r.Email != null){
                            sendTo.add(current_acc.Area_Director__r.Email);
                        }
                        if(current_acc.Solution_Architect__c !=null && current_acc.Solution_Architect__r.Email != null){
                            sendTo.add(current_acc.Solution_Architect__r.Email);                                    
                        }
                        if(current_acc.CSM_Name_New__r !=null  && current_acc.CSM_Name_New__r.Email != null){
                            sendTo.add(current_acc.CSM_Name_New__r.Email);
                        }
                        if(current_acc.TAM_Name_New__r !=null && current_acc.TAM_Name_New__r.Email != null){
                            sendTo.add(current_acc.TAM_Name_New__r.Email);
                        }
                        if(current_acc.Secondary_TAM_Name__r !=null && current_acc.Secondary_TAM_Name__r.Email != null){
                            sendTo.add(current_acc.Secondary_TAM_Name__r.Email);
                        }
                        if(current_acc.X3rd_TAM_Name__r !=null && current_acc.X3rd_TAM_Name__r.Email != null){
                            sendTo.add(current_acc.X3rd_TAM_Name__r.Email);
                        }
                        //Added by Swathi : CR2253 Start
                        if(current_acc.CSM_Name_New__r.Manager !=null && current_acc.CSM_Name_New__r.Manager.Email != null){
                            CCList.add(current_acc.CSM_Name_New__r.Manager.Email);
                        }
                        //Added by Swathi : CR2253 End
                        if(current_acc.Name!= null){
                            Accountname = current_acc.Name;
                            AccountId = current_acc.Id;
                        }
                        if(current_acc.Geo__c!= null){
                            GEO = current_acc.Geo__c;
                        }
                        if(current_acc.Area__c!= null){
                            Area = current_acc.Area__c;
                        }
                        if(opport.Amount!= null){
                            ACVAmount = '$' + String.valueOf(opport.Amount.setScale(2));
                        }
                        if(opport.Premium_Support__c != null){
                            PSAmount = '$' + String.valueOf(opport.Premium_Support__c.setScale(2));
                        }
                        if(current_acc.CSM_Name_New__r != null && current_acc.CSM_Name_New__r.Full_Name__c != null){
                            CSMname = current_acc.CSM_Name_New__r.Full_Name__c;
                        }
                        
                        if(current_acc.TAM_Name_New__r != null && current_acc.TAM_Name_New__r.Full_Name__c != null){
                            TAMname = current_acc.TAM_Name_New__r.Full_Name__c;
                        }
                        if(current_acc.Solution_Architect__c != null){
                            Solution_architect_name = current_acc.Solution_Architect__r.Name;
                        }
                        if(current_acc.Assigned_DAS_Engr__c != null){
                            Assigned_DAS_Engr = current_acc.Assigned_DAS_Engr__c;
                        }
                        if(current_acc.Assigned_TPC_DOR__c != null){
                            Assigned_TPC_DOR = current_acc.Assigned_TPC_DOR__c;
                        }
                        if(current_acc.DAS_Engineer__r != null && current_acc.DAS_Engineer__r.Full_Name__c != null){
                            DAS_Engineer = current_acc.DAS_Engineer__r.Full_Name__c;
                        }
                        if(current_acc.Account_Manager__r.Name != null){
                            RSMName = current_acc.Account_Manager__r.Name;
                        }
                        
                        
                        emailTemplatesubject = emailTemplatesubject.replace('[**Account_Name**]',Accountname);
                        emailTemplatesubject = emailTemplatesubject.replace('[**GEO**]',GEO);
                        emailTemplatesubject = emailTemplatesubject.replace('[**Area**]',Area);
                        emailTemplatesubject = emailTemplatesubject.replace('[**ACV_Amount**]',ACVAmount);
                        emailTemplatesubject = emailTemplatesubject.replace('[**PS_Amount**]', 'Premium Support - ' + PSAmount);
                        
                        emailTemplatebody = emailTemplatebody.replace('[**Account_Name**]',  '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+AccountId+'">'+Accountname+'</a>');
                        emailTemplatebody = emailTemplatebody.replace('[**Opp_Name**]','<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+opport.Id+'">'+opport.name+'</a>');
                        
                        if(opport.X3_Why__c != null)
                            emailTemplatebody = emailTemplatebody.replace('[**why_Name**]',opport.X3_Why__c);
                        else 
                            emailTemplatebody = emailTemplatebody.replace('[**why_Name**]', '');
                        
                        if(opport.Value_Pyramid__c != null)
                            emailTemplatebody = emailTemplatebody.replace('[**value_Name**]',opport.Value_Pyramid__c);
                        else 
                            emailTemplatebody = emailTemplatebody.replace('[**value_Name**]','');
                        
                        
                        if(opport.Account.Architecture_Workshop_Link__c  != null)
                            emailTemplatebody = emailTemplatebody.replace('[**Arch_link**]',opport.Account.Architecture_Workshop_Link__c);
                        else 
                            emailTemplatebody = emailTemplatebody.replace('[**Arch_link**]','');
                        
                        emailTemplatebody = emailTemplatebody.replace('[**CSM_Name**]', CSMname);
                        emailTemplatebody = emailTemplatebody.replace('[**Primary_TAM_Name**]',TAMname);
                        emailTemplatebody = emailTemplatebody.replace('[**Solution_Architect_Name**]',Solution_architect_name);
                        emailTemplatebody = emailTemplatebody.replace('[**Assigned_DAS_Engineer**]',Assigned_DAS_Engr);
                        emailTemplatebody = emailTemplatebody.replace('[**Assigned_DAS_TPC**]', Assigned_TPC_DOR);
                        emailTemplatebody = emailTemplatebody.replace('[**RSM_Name**]', RSMName);
                        
                        if(opport.SE_Name__r != null && opport.SE_Name__r.name != null){
                            SEname = opport.SE_Name__r.name;
                        }
                        emailTemplatebody = emailTemplatebody.replace('[**OpportunitySE_Name**]',SEname);
                        
                        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'Z-NewCustomerHandoff@zscaler.com'];//Modifed by Swathi : CR2973
                        if (owea.size() > 0 ) {
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        //CR# 5142 START
                        if(String.isNotBlank(current_acc.District__c) && current_acc.District__c.contains('Japan')) {
                            sendTo.add('ysato@zscaler.com');
                        }
                        //CR# 5142 END
                        if(runningInASandbox()){
                            sendTo.add('snag@zscaler.com');
                            sendTo.add('smittal@zscaler.com');
                            sendTo.add('sgoudar@zscaler.com');
                        }
                        if(runningInASandbox()){
                            mail.setReplyTo('Z-NewCustomerHandoff@zscaler.com.sandbox'); //Modifed by Swathi : CR2973
                        }
                        else{
                            mail.setReplyTo('Z-NewCustomerHandoff@zscaler.com'); //Modifed by Swathi : CR2973
                        }
                        mail.setToAddresses(sendTo);
                        mail.setCcAddresses(CCList);//Added by Swathi : CR2253
                        mail.setBccAddresses(BCCList);//Added by Swathi : CR2253
                        mail.setSubject(emailTemplatesubject);
                        mail.setHtmlBody(emailTemplatebody);
                        opport.Hand_off_Email_Sent__c = true;
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                        
                    }
                    //IBA-6520-Start
                    TriggerHandler.bypass('OpportunityTriggerHandler');
                    update opportunitylist;
                    TriggerHandler.clearByPass('OpportunityTriggerHandler');
                    //IBA-6520-End
                }
            }
            catch(Exception exp){   
                System.debug('The following exception has occurred: ' + exp.getMessage() + exp.getLineNumber());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}