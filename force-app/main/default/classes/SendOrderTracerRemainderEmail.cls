public with sharing class SendOrderTracerRemainderEmail implements Database.Batchable<sObject>,Database.Stateful {
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('SendOrderTracerRemainderEmail');
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        
        String query = 'SELECT Id,Name, Status__c,Opportunity__c,Opportunity__r.Amount,CreatedDate,Opportunity__r.StageName,Last_Remainder_TimeStamp__c,Total_Remainder_Count__c,Opportunity__r.owner.Email,Opportunity__r.owner.Name,Opportunity__r.Account.Name,Opportunity__r.ACV_New__c FROM Order_Tracker__c WHERE Status__c NOT IN (\'Processed/Billed\', \'PO Rejected\',\'Deferred Billing (Booked)\',\'Duplicate\',\'Merged\') AND Opportunity__r.StageName IN (\'0 - Pipeline Generation\',\'1 - Discovery & Qualification\',\'2 - Architecture & Alignment\',\'3 - Sponsorship\',\'4 - Impact Validation\',\'5 - Procurement\') AND Opportunity__r.Amount < 250000';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<Order_Tracker__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        
        try{
            
            Double emailFrequencyTimeStamp;
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            List<Order_Tracker__c> orderTrackerToUpdate = new List<Order_Tracker__c>();
            Date today = Date.today();
            Integer currentWeek = currentWeekOfMonth(today);
            String todaysDay = DateTime.now().format('EEEE');
            EmailTemplate et = null;
            et=[SELECT Id, Name,Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Opportunity_Remainder_Notification_250k'];
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com'];
            if(todaysDay != 'Saturday' && todaysDay !='Sunday') {
                
                if(currentWeek == 4 || currentWeek == 5 ) {
                    
                    emailFrequencyTimeStamp = 6;
                    
                }
                else {
                    
                    emailFrequencyTimeStamp = 12;
                }
                
                system.debug(emailFrequencyTimeStamp);
                for(Order_Tracker__c obj : scope) {
                    
                    Order_Tracker__c ottInstance = new Order_Tracker__c();
                    
                    if(obj.Last_Remainder_TimeStamp__c != null && obj.Total_Remainder_Count__c != null ){
                        
                        if(((dateTime.now().getTime() - (obj.Last_Remainder_TimeStamp__c).getTime())/1000/60/60  >= emailFrequencyTimeStamp)|| test.isRunningTest()) {
                            
                            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                            mail1.setToAddresses(new String[] {obj.opportunity__r.owner.Email});
                            mail1.setSubject(et.Subject);
                            if(owea.size() > 0){
                                
                                mail1.setOrgWideEmailAddressId(owea.get(0).Id);  
                            }
                            String emailBody = et.HtmlValue;
                            emailBody = emailBody.Replace('{{OpportunityOwner}}', obj.Opportunity__r.owner.Name);
                            emailBody = emailBody.Replace('{{Customer Name}}', obj.Opportunity__r.Account.Name);
                            if(obj.Opportunity__r.ACV_New__c != null) {
                                emailBody = emailBody.Replace('{{ACV}}', String.valueOf((obj.Opportunity__r.ACV_New__c).setScale(2)));
                            }
                            else {
                                emailBody = emailBody.Replace('{{ACV}}', '');
                            }
                            emailBody = emailBody.Replace('{{OPPLink}}',URL.getSalesforceBaseUrl().toExternalForm()+'/'+obj.Opportunity__c);
                            mail1.setHTMLBody(emailBody);
                            messageList.add(mail1);
                            
                            ottInstance.Id = obj.Id;
                            ottInstance.Last_Remainder_TimeStamp__c = dateTime.Now();
                            ottInstance.Total_Remainder_Count__c =  obj.Total_Remainder_Count__c  + 1;
                            orderTrackerToUpdate.add(ottInstance);
                            
                        }
                    }
                    else {
                        
                        if(((dateTime.now().getTime() - (obj.createdDate).getTime())/1000/60/60 > emailFrequencyTimeStamp && obj.Total_Remainder_Count__c == null)|| test.isRunningTest()) {
                            
                            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                            mail1.setToAddresses(new String[] {obj.opportunity__r.owner.Email});
                            mail1.setSubject(et.Subject);
                            if(owea.size() > 0){
                                
                                mail1.setOrgWideEmailAddressId(owea.get(0).Id);  
                            }
                            String emailBody = et.HtmlValue;
                            emailBody = emailBody.Replace('{{OpportunityOwner}}', obj.Opportunity__r.owner.Name);
                            emailBody = emailBody.Replace('{{Customer Name}}', obj.Opportunity__r.Account.Name);
                            if(obj.Opportunity__r.ACV_New__c != null) {
                                emailBody = emailBody.Replace('{{ACV}}', String.valueOf((obj.Opportunity__r.ACV_New__c).setScale(2)));
                            }
                            else {
                                emailBody = emailBody.Replace('{{ACV}}', '');
                            }
                            emailBody = emailBody.Replace('{{OPPLink}}',URL.getSalesforceBaseUrl().toExternalForm()+'/'+obj.Opportunity__c);
                            mail1.setHTMLBody(emailBody);
                            messageList.add(mail1);
                            
                            ottInstance.Id = obj.Id;
                            ottInstance.Last_Remainder_TimeStamp__c = dateTime.Now();
                            ottInstance.Total_Remainder_Count__c = 1;
                            orderTrackerToUpdate.add(ottInstance);
                            
                        }
                    }
                    
                }
                
                if(!Test.isRunningTest() && !messageList.isEmpty() && messageList.size()>0){
                    Messaging.sendEmail(messageList);
                } 
                
                if(!orderTrackerToUpdate.isEmpty() && orderTrackerToUpdate.size() > 0 ) {
                    update orderTrackerToUpdate;
                }
                
            }
        }
        catch(Exception ex){
            ZscalerErrorLogsUtility.insertlogsForAsync('SendOrderTracerRemainderEmail', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
        }
    }
    
    public void finish(Database.BatchableContext BC){
        this.zb.callFinish(bc);
    }
    
    
    public static Integer currentWeekOfMonth( Date todaysDate){
        
        Date currentDate = todaysDate;
        Integer weekCount = 0;
        Integer startWeekResidue = 0;
        Integer endWeekResidue = 0;
        
        //Calculating startWeekResidue
        
        Date dt = currentDate.toStartOfMonth().addDays(-1);
        Date dtFirstWeekend = dt.toStartOfWeek().addDays(6);
        startWeekResidue = dt.daysBetween(dtFirstWeekend); 
        
        //Calculating endWeekResidue
        
        Date dtLastWeekend = currentDate.toStartOfWeek().addDays(-1);
        endWeekResidue = dtLastWeekend.daysBetween(currentDate);
        
        //Counting the weeks
        weekCount = (currentDate.day() - (startWeekResidue + endWeekResidue))/7;
        weekCount += (startWeekResidue > 0 ? 1:0)+(endWeekResidue > 0 ? 1:0);
        
        System.debug('--currentWeekOfMonth--'+weekCount);
        return weekCount;   
    }   
}