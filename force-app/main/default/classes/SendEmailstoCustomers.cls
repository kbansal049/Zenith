public class SendEmailstoCustomers implements Queueable {
    
    private ID Caseid;
    private String CaseCmnt;
    
    public SendEmailstoCustomers(ID id,String CaseComments) {
        this.Caseid = id;
        this.CaseCmnt = CaseComments;
    }
    public void execute(QueueableContext context) {
        sendEmail();
        
    }
    
    public void sendEmail()  {
        Set<id> CCEmailidlist= new Set<id>();
        Set<String> CCEmaillist= new Set<String>();
        String MasterCaseEmailSubject= ZscalerCustomSetting__c.getInstance('MasterCaseEmailSubject')!=null && ZscalerCustomSetting__c.getInstance('MasterCaseEmailSubject').Value__c!=null ? ZscalerCustomSetting__c.getInstance('MasterCaseEmailSubject').Value__c:'Zscaler Support Ticket Update'; 
        
        String MasterCaseEmailSender= ZscalerCustomSetting__c.getInstance('MasterCaseEmailSender')!=null && ZscalerCustomSetting__c.getInstance('MasterCaseEmailSender').Value__c!=null ? ZscalerCustomSetting__c.getInstance('MasterCaseEmailSender').Value__c:'Zscaler Support';
        
        if(Caseid!=null){           
            Map<id,Case> CaseMap= new Map<id,Case>([Select id,Master_Case__c,ContactId,Contact.email,Case_CC_List__c,Customer_CC_List__c,Internal_CC_List__c from Case where Master_Case__c=:Caseid]);
            system.debug('CaseMap '+CaseMap);
            
            for(Case cs:CaseMap.values()){
                CCEmaillist.add(cs.Contact.email);                       
                /*if(cs.Case_CC_List__c!=null && cs.Case_CC_List__c!=''){
                    CCEmaillist.addall(cs.Case_CC_List__c.split(';'));
                }*/
                
                if(cs.Case_CC_List__c!=null && cs.Case_CC_List__c!=''){
                    String []s = cs.Case_CC_List__c.split(';');
                    
                    for(String s1 : s)  {
                        if(s1 !=null && s1 != '' ){
                            System.debug('Emails:-'+s1);
                            CCEmaillist.add(s1);
                        }
                    }
                }
                /*
                if(cs.Customer_CC_List__c!=null && cs.Customer_CC_List__c!=''){
                    String []s = cs.Customer_CC_List__c.split(';');
                    
                    for(String s1 : s)  {
                        if(s1 !=null && s1 != '' ){
                            System.debug('Emails:-'+s1);
                            CCEmaillist.add(s1);
                        }
                    }
                }
                if(cs.Internal_CC_List__c!=null && cs.Internal_CC_List__c!=''){
                    String []s = cs.Internal_CC_List__c.split(';');
                    for(String s1 : s)  {
                        if(s1 !=null && s1 != '' ){
                            System.debug('Emails:-'+s1);
                            CCEmaillist.add(s1);
                        }
                    }
                }
                */
            }
            system.debug('CCEmaillist  '+CCEmaillist);
            //CCEmaillist.add('manngurjinder2@gmail.com');
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com'];
            
            list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] sendingToAdd = new String[]{Userinfo.getUserEmail()};
                //mail.setToAddresses(sendingToAdd);      
                mail.setTargetObjectId(UserInfo.getUserId());
            if( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{ 
                mail.setsenderDisplayName(MasterCaseEmailSender);
            }
            //mail.setbccAddresses(CCEmaillist);
            mail.setSubject(MasterCaseEmailSubject);
            String messageBody = '<html><body>Dear Customer, ' + '<br><br>Please find the Latest Comments Added for your Case:-  <br><br>' +CaseCmnt +'<br><br> Thank You<br><br>Zscaler Support</body></html>';
            mail.setHtmlBody(messageBody);
            mail.setSaveAsActivity(false);
            //mail.targetobjectid
            System.debug(mail);
            messageList.add(mail);
            //Messaging.sendEmail(messageList);  
            Map<String,Id> targetIdMap = new Map<String,Id>();
            if(CCEmaillist.size()>0){
                List<Contact> ctList = [select id, Email from Contact where email in :CCEmaillist];
                List<User> urList = [select id, Email from User where email in : CCEmaillist];
                System.debug('ctList:-'+ctList);
                System.debug('urList:-'+urList);
                for(Contact ct : ctList){
                    targetIdMap.put(ct.Email,ct.Id);
                }
                for(User ur:urList){
                    targetIdMap.put(ur.Email,ur.Id);
                }
                for(String email:targetIdMap.keyset()){
                    System.debug('mail2:---'+email);
                    if(email !=null && email != '' && targetIdMap.containskey(email.trim()) && targetIdMap.get(email.trim()) != null){
                        Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
                        mail2.setTargetObjectId(targetIdMap.get(email));
                        if( owea.size() > 0 ) {
                            mail2.setOrgWideEmailAddressId(owea[0].Id);
                        }else{ 
                            mail2.setsenderDisplayName(MasterCaseEmailSender);
                        }
                        mail2.setSubject(MasterCaseEmailSubject);
                        mail2.setHtmlBody(messageBody);
                        mail2.setSaveAsActivity(false);
                        System.debug(mail2);
                        messageList.add(mail2);
                    }
                }
            } 
            System.debug('messageList:--'+messageList.size());
            if(messageList.size()>0){
                System.debug('getTargetObjectId:--'+messageList[0].getTargetObjectId());
                Messaging.sendEmail(messageList,false);  
                Task tk = new Task();
                tk.WhatId = Caseid;
                tk.Description = messageBody;
                tk.Subject = MasterCaseEmailSubject;
                insert tk;
            }
        }           
    }
    
}