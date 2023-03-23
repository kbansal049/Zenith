public class KBRemindersBatch implements Database.Batchable<sObject>, Database.Stateful{
ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('KBRemindersBatch');
String query;    
List<KB__kav> draftReminderEmail=new List<KB__kav>();
List<KB__kav> draftFinalEmail=new List<KB__kav>();
List<KB__kav> rftReminderEmail=new List<KB__kav>();
List<KB__kav> rftFinalReminderEmail=new List<KB__kav>();
List<KB__kav> reassignEmail=new List<KB__kav>();


public KBRemindersBatch(String query){
this.query=query;
}
public Database.QueryLocator start(Database.BatchableContext context){
this.zscalerBatchFrameWorkObj.callStart();
return Database.getQueryLocator(query);
}
public void execute(Database.BatchableContext context, List<KB__kav> scope){
this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
System.debug('Execute Run');
for(KB__kav knowledge:scope){
Long currentTime=DateTime.now().getTime();
if(knowledge.validationStatus=='Draft'){
Long createdDate=knowledge.CreatedDate.getTime();
Long millisecondsDraft = currentTime - createdDate;
Long daysDraft = millisecondsDraft / (1000*60*60*24);
System.debug('Days between '+daysDraft);
if(daysDraft==Integer.ValueOf(System.Label.X1DraftReminder)||daysDraft==Integer.ValueOf(System.Label.X2DraftReminder)||daysDraft==Integer.ValueOf(System.Label.X3DraftReminder) || Test.isRunningTest()){
System.debug('3 Days Run');
draftReminderEmail.add(knowledge);
}
if(daysDraft==Integer.ValueOf(System.Label.FinalDraftReminder) || Test.isRunningTest()){
draftFinalEmail.add(knowledge);
}
if(daysDraft==Integer.ValueOf(System.Label.ReassignmentTime) || Test.isRunningTest()){
    if(knowledge.Owner_s_Manager__c!=null){
        knowledge.ownerID=knowledge.Owner_s_Manager__c;
    }
    knowledge.Reassigned_To_Manager__c=true;
reassignEmail.add(knowledge);
}
}
if(knowledge.validationStatus=='Ready for Tech Review' && knowledge.ready_for_Tech_review_Timestamp__c!=null){
Long rftDate=knowledge.ready_for_Tech_review_Timestamp__c.getTime();
Long millisecondsRFT = currentTime - rftDate;
Long daysRFT = millisecondsRFT / (1000*60*60*24);
System.debug('Days between '+daysRFT);
if(daysRFT==Integer.ValueOf(System.Label.X1RFTReminder)||daysRFT==Integer.ValueOf(System.Label.X2RFTReminder)){
rftReminderEmail.add(knowledge);
}
if(daysRFT==Integer.ValueOf(System.Label.X3RFTReminder)){
    rftFinalReminderEmail.add(knowledge);
    }
}
}
}
public void finish(Database.BatchableContext bc){
this.zscalerBatchFrameWorkObj.callFinish(bc);
List<String> templateNames = new List<String>{'KB_Draft_Reminder_Notification','KB_Draft_Final_Reminder_Notification','KB_Ready_for_tech_Reminder_Notification','Unattended_Draft_Articles'};
Map<String,String> emailTemplates = new Map<String, String>();
        for(EmailTemplate et : [SELECT Id, Name, DeveloperName, IsActive, HtmlValue, Body, Subject 
                                FROM EmailTemplate 
                                WHERE DeveloperName IN :templateNames AND isActive= true]) {
                                    emailTemplates.put(et.DeveloperName, et.Id);
                                }
String emailDraftReminder = emailTemplates.containsKey('KB_Draft_Reminder_Notification')?emailTemplates.get('KB_Draft_Reminder_Notification'):'';
String emailDraftFinal = emailTemplates.containsKey('KB_Draft_Final_Reminder_Notification')?emailTemplates.get('KB_Draft_Final_Reminder_Notification'):'';
String emailRFT = emailTemplates.containsKey('KB_Ready_for_tech_Reminder_Notification')?emailTemplates.get('KB_Ready_for_tech_Reminder_Notification'):'';
String emailReassign = emailTemplates.containsKey('Unattended_Draft_Articles')?emailTemplates.get('Unattended_Draft_Articles'):'';
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support-noreply@zscaler.com'];
Id contactId=[select id from Contact limit 1].Id;

List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
List<String> idListEditor = new List<String>();
List<String> mailCCAddressesEditor = new List<String>();
List<String> tempEmailList = new List<String>();
Group gpEditor = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = 'KBApprovers'];
for (GroupMember gm : gpEditor.GroupMembers) {
idListEditor.add(gm.UserOrGroupId);
}
List<User> userListEditor = [SELECT Email FROM User WHERE Id IN :idListEditor];
for(User u : userListEditor) {
mailCCAddressesEditor.add(u.email);
} 
if(!draftReminderEmail.isEmpty()){
for(KB__kav kb:draftReminderEmail){
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
email.setToAddresses(new String[] {kb.CreatedBy.Email});
if(owea.size() > 0){
email.setOrgWideEmailAddressId(owea.get(0).Id);  
}
email.setSaveAsActivity(false);
email.setTargetObjectId(contactId);
email.setTreatTargetObjectAsRecipient(false);
email.setTemplateId(emailDraftReminder);
email.setWhatId(kb.Id);
mails.add(email);
System.debug('Reminder Email Run');
}
}
if(!draftFinalEmail.isEmpty()){
for(KB__kav kb:draftFinalEmail){
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
tempEmailList = new List<String>();
email.setToAddresses(new String[] {kb.CreatedBy.Email});
if(owea.size() > 0){
email.setOrgWideEmailAddressId(owea.get(0).Id);  
}
tempEmailList.add(kb.Owner_s_Manager_Email__c);
tempEmailList.addAll(mailCCAddressesEditor);
if(tempEmailList.size() > 0){
email.setCcAddresses(tempEmailList);  
}
email.setSaveAsActivity(false);
email.setTargetObjectId(contactId);
email.setTreatTargetObjectAsRecipient(false);
email.setTemplateId(emailDraftFinal);
email.setWhatId(kb.Id);
mails.add(email);
}
}
if(!rftReminderEmail.isEmpty()){
for(KB__kav kb:rftReminderEmail){
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
email.setToAddresses(new String[] {kb.Owner_s_Manager_Email__c});  
if(owea.size() > 0){
email.setOrgWideEmailAddressId(owea.get(0).Id);  
}
email.setSaveAsActivity(false);
email.setTargetObjectId(contactId);
email.setTreatTargetObjectAsRecipient(false);
email.setTemplateId(emailRFT);
email.setWhatId(kb.Id);
mails.add(email);
}
}
if(!rftFinalReminderEmail.isEmpty()){
    for(KB__kav kb:rftFinalReminderEmail){
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(new String[] {kb.Owner_s_Manager_Email__c});  
    if(owea.size() > 0){
    email.setOrgWideEmailAddressId(owea.get(0).Id);  
    }
    email.setSaveAsActivity(false);
    email.setTargetObjectId(contactId);
    email.setTreatTargetObjectAsRecipient(false);
    email.setTemplateId(emailRFT);
    email.setWhatId(kb.Id);
    mails.add(email);
    }
    }
if(!reassignEmail.isEmpty()){
    for(KB__kav kb:reassignEmail){
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(new String[] {kb.Owner_s_Manager_Email__c});
    email.setCCAddresses(new String[] {kb.Owner.Email});
    if(owea.size() > 0){
    email.setOrgWideEmailAddressId(owea.get(0).Id);  
    }
    email.setSaveAsActivity(false);
    email.setTargetObjectId(contactId);
    email.setTreatTargetObjectAsRecipient(false);
    email.setTemplateId(emailReassign);
    email.setWhatId(kb.Id);
    mails.add(email);
    }
    }
if(!mails.isEmpty()){
System.debug('Email Sent Run');
if(!Test.isRunningTest()){
    Messaging.sendEmail(mails);
}
}
update reassignEmail;
// execute any post-processing operations
}
}