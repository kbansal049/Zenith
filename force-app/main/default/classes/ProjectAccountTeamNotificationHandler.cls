/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ProjectAccountTeamNotificationHandler
* @description    This class is used to send the email notifications to the AccountTeam:CSMs
*                 REF: CR# 2695
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2022-01-05
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class ProjectAccountTeamNotificationHandler {
    
    private final String DEPLOYMENT_PROJECT_RECORDTYPEID = Schema.SObjectType.inspire1__Project__c.RecordTypeInfosByName.get('Deployment Project').RecordTypeId;
    
    private static ProjectAccountTeamNotificationHandler instance;
    public static ProjectAccountTeamNotificationHandler getInstance() {
        
        if (instance == NULL) {
            instance = new ProjectAccountTeamNotificationHandler();
        }
        
        return instance;
        
    }
    
    private List<inspire1__Project__c> projectList;
	private Map<Id,String> oppIdRegionSubRegionMap = new Map<Id,String>(); //CR# 5113
    private Set<id> relatedOppIdset = new Set<Id>(); //CR# 5113
    
    public void setProjectList(List<inspire1__Project__c> projectList) {
        
        List<inspire1__Project__c> filteredProjectList = new List<inspire1__Project__c> ();
        set<id> relatedIds = new set<id> ();   //CR# 5113
        Set<Id> relatedAccountIdSet = new Set<Id> ();
        
        for (inspire1__Project__c project : projectList) {
            
            if (project.RecordTypeId.equals(DEPLOYMENT_PROJECT_RECORDTYPEID)) {
                
                filteredProjectList.add(project);
                relatedAccountIdSet.add(project.inspire1__Account__c);
                if(project.Opportunity__c!=null){   //CR# 5113
                    this.relatedOppIdset.add(project.Opportunity__c);       //CR# 5113
                }
            }
            
        }
        
        this.projectList = filteredProjectList;
        setRelatedAccountIdSet(relatedAccountIdSet);
    }
    
    private Set<Id> relatedAccountIdSet;
    private void setRelatedAccountIdSet(Set<Id> relatedAccountIdSet) {
        this.relatedAccountIdSet = relatedAccountIdSet;
    }
    
    public void handle() {
        retrieveAccountTeamMembers();
        generateEmailTemplate();
        
        if (!emailTemplateList.isEmpty()) {
            retrieveSpecifiedUsers();
            retrieveSpecifiedGroup();
            getRelatedOppRegionAndSubRegion();
            sendEmail();
        }
        
    }
    
    private final String TEAM_MEMBER_ROLE = 'Customer Success Manager';
    
    private Map<Id, Set<String>> accountTeamMemberMap;
    private void setAccountTeamMemberMap(Map<Id, Set<String>> accountTeamMemberMap) {
        this.accountTeamMemberMap = accountTeamMemberMap;
    }
    
    private void retrieveAccountTeamMembers() {
        
        Map<Id, Set<String>> accountTeamMemberMap = new Map<Id, Set<String>> ();
        
        for (AccountTeamMember member : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE TeamMemberRole = :TEAM_MEMBER_ROLE AND AccountId IN : relatedAccountIdSet]) {
            
            Set<String> memberSet = accountTeamMemberMap.containsKey(member.AccountId) ? accountTeamMemberMap.get(member.AccountId) : new Set<String> ();
            memberSet.add(member.UserId);
            accountTeamMemberMap.put(member.AccountId, memberSet);
            
        }
        
        setAccountTeamMemberMap(accountTeamMemberMap);
        
    }
    
    private List<EmailTemplate> emailTemplateList;
    private void setEmailTemplateList(List<EmailTemplate> emailTemplateList) {
        this.emailTemplateList = emailTemplateList;
    }
    
	//CR# 5113 Start
    //Get Map of Region,Subregion by Opportunity Id. 
    private void getRelatedOppRegionAndSubRegion(){
        for(Opportunity opp :[SELECT Id, Area__c,District_Account__c FROM Opportunity WHERE Id IN : this.relatedOppIdset]){
            oppIdRegionSubRegionMap.put(opp.Id, opp.Area__c+','+opp.District_Account__c);
        }
    }
    //CR# 5113 END

    private void generateEmailTemplate() {
        
        List<EmailTemplate> emailTemplateList = [SELECT Id, Name,htmlValue FROM EmailTemplate WHERE Name = 'New Project Creation Notification' LIMIT 1];
        setEmailTemplateList(emailTemplateList);
        
    }
    
    private Set<String> predefinedUserIdSet;
    private void setPredefinedUserIdSet(Set<String> predefinedUserIdSet) {
        this.predefinedUserIdSet = predefinedUserIdSet;
    }
    
    
    private void retrieveSpecifiedUsers() {
        List<String> predefinedMemberList = System.Label.Project_Creation_Email_Notification_Member.split(',');
        
        Set<String> predefinedUserIdSet = new Set<String>();
        for (User usr : [SELECT Id, Name FROM User WHERE IsActive = TRUE AND Email IN : predefinedMemberList LIMIT 50000]) {
            predefinedUserIdSet.add(usr.Id);
        }
        
        setPredefinedUserIdSet(predefinedUserIdSet);
    }
    
    private void retrieveSpecifiedGroup(){
        Set<String> deploymentGroupUserIdSet = new Set<String>();
        
        deploymentGroupUserIdSet.addAll(predefinedUserIdSet);
        
        List<String> mailToAddresses = new List<String>(); 
        List<User> deploymentGroupUsers = [SELECT Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name ='Deployment Operations Group' AND Group.Type = 'Regular') AND IsActive = TRUE];
        
        for (User dgUser : deploymentGroupUsers){
            deploymentGroupUserIdSet.add(dgUser.id);
        }
        
        setPredefinedUserIdSet(deploymentGroupUserIdSet);
    }
    
    private OrgWideEmailAddress orgWideEmailAdd;
    private void setOrgWideEmailAdd(OrgWideEmailAddress orgWideEmailAdd) {
        this.orgWideEmailAdd = orgWideEmailAdd; 
    }
    
    private void retrieveEmailAddress() {
        List<OrgWideEmailAddress> fromEmailAddressList = [SELECT Id FROM OrgWideEmailAddress WHERE Address ='support@zscaler.com' LIMIT 1];
        
        if(!fromEmailAddressList.isEmpty()) {
            setOrgWideEmailAdd(fromEmailAddressList.get(0)); 
        }
    }
    
    
    private void sendEmail() {
        
        retrieveEmailAddress();
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        for(inspire1__Project__c inspireProject : projectList){
            
            Set<String> memberSet = accountTeamMemberMap.containsKey(inspireProject.inspire1__Account__c) ? accountTeamMemberMap.get(inspireProject.inspire1__Account__c) : new Set<String> ();
            
            List<String> memberList = new List<String> ();
            
            if (!memberSet.isEmpty()) {
                memberList.addAll(memberSet);
            }
            
            if(!predefinedUserIdSet.isEmpty()) {
                memberList.addAll(predefinedUserIdSet);    
            }
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(emailTemplateList.get(0).Id), NULL, String.valueOf(inspireProject.Id));
            //CR# 5113 START
			String htmlValue = mail.gethtmlBody();
			if(oppIdRegionSubRegionMap.containsKey(inspireProject.Opportunity__c)) {
                
				String region = oppIdRegionSubRegionMap.get(inspireProject.Opportunity__c).split(',')[0];
            	String subRegion = oppIdRegionSubRegionMap.get(inspireProject.Opportunity__c).split(',')[1];
                htmlValue = htmlValue.replace('{replaceRegion}',String.isNotBlank(region) ? region : ' ');
            	htmlValue = htmlValue.replace('{replaceSubRegion}',String.isNotBlank(subRegion) ? subRegion : ' ');
			}  
            //CR# 5113 END  
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(FALSE);
            mail.setHtmlBody(htmlValue); 
            mail.setToAddresses(memberList);
            mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
            mailList.add(mail);
            
        } 
        
        if(!System.Test.isRunningTest()) {
            Messaging.sendEmail(mailList);            
        }
        
        
    }
    
    
}