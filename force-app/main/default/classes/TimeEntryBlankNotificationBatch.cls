//Added by Varun for CR 1108
global class TimeEntryBlankNotificationBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('TimeEntryBlankNotificationBatch');
    
    String batchSoql;
    List<Id> lstIdOfOwnerIds= new List<Id>();
    Map<Id,User> mapOfUsers = new Map<Id,User>();
    Map<Id,String> idMail = new Map<Id,String>();

    public TimeEntryBlankNotificationBatch(String soql){     
        batchSoql =soql;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        return  Database.getQueryLocator(batchSoql);     
    }
    global void execute(Database.BatchableContext bc, List<User> scope){
		this.zb.callExecute(scope[0]?.Id, scope.size());
        Map<Id, Decimal> ownerWithEfforts = new Map<Id,Decimal>();
        AggregateResult[] curProdCount;
        if(Test.isRunningTest()){
        	curProdCount = [Select OwnerId,SUM(inspire1__Efforts__c) efforts FROM  inspire1__Time_Entry__c where inspire1__Date__c  >=LAST_N_DAYS:6 and  CreatedBy.profile.name='Deployment Services v2'  group by OwnerId limit 10];
        }
        else{
            curProdCount = [Select OwnerId,SUM(inspire1__Efforts__c) efforts FROM  inspire1__Time_Entry__c where inspire1__Date__c  >=LAST_N_DAYS:6 and  CreatedBy.profile.name='Deployment Services v2'  group by OwnerId];
        }
            for(AggregateResult ar : curProdCount){
            ownerWithEfforts.put((Id)ar.get('OwnerId'), (Decimal)ar.get('efforts'));
        }
        
        for(User usr : scope){
            if(ownerWithEfforts.containsKey(usr.Id)){
                if(ownerWithEfforts.get(usr.Id)<1){
                    idMail.put(usr.Id, usr.Email);
                }
            }else{
                idMail.put(usr.Id, usr.Email);
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'projects@zscaler.com'];
        
        List<User> lstUser= [Select Id,Name,Email,Manager.Email from User where Id in:idMail.keySet()];
        List<Messaging.SingleEmailMessage>  myEmails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplateList = [SELECT Id,Subject,HtmlVAlue FROM EmailTemplate where DeveloperName='Email_notification_for_Zero_weekly_Project_Timesheet_hours' limit 1];      
        
        for(User objUser:lstUser){
            String body = emailTemplateList.HtmlVAlue;
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(emailTemplateList.Id),null,null);
            
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }        
            if(objUser.Manager!=null && objUser.Manager.Email!=null ){
                mail.setToAddresses(new String []{objUser.Email,objUser.Manager.Email});
            }
            body = body.replace('{!User.Name}', objUser.Name);
            body = body.replace(']]>', '');
            mail.setHtmlBody(body);
            mail.setSubject('ACTION REQUIRED: '+ objUser.Name +' has 0 hours submitted for week of '+ date.today().format());
            mail.setSaveAsActivity(false);
            myEmails.add(mail);
            
        }
        
		if(!Test.isRunningTest()){
			 Messaging.sendEmail(myEmails);
		}
       
    }
}