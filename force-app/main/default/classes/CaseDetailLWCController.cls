public without sharing class CaseDetailLWCController {
    @AuraEnabled
    public static Case updateCase(String caseDetailId) {
        if(String.isNotBlank(caseDetailId)) {
            Case cse = [select id from case where id =: caseDetailId];
            cse.Status = 'Closed - Resolved';
            update cse;
            return cse;
        }
        else {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static list<Case> fetchCase(String strObjectName) {
        if(String.isNotBlank(strObjectName)) {
            return Database.query('SELECT Id, Account.Name,Account.Id, Contact.Name,Priority,Priority_Deception__c, Case_Type__c, Case_Category__c,Case_Sub_Category__c,Product_New__c, '+
            'CaseNumber,Subject,Status,CreatedById,CreatedBy.name,LastModifiedDate,'+
            'Community_url__c,Owner.Name,CreatedDate,Requester__r.Name,Preferred_Contact_Number__c,'+
            'Preferred_Contact_Time_Zone__c, Zendesk_Reference_Id__c, (select id, CreatedBy.name,CommentBody from '+
            'CaseComments) From Case where Id = :strObjectName');
        }
        else {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getCustomerCCList(String strObjectName) {
        if(String.isNotBlank(strObjectName)) {
            Set<String> emailset = new Set<String>();
            List<Case> cslst = [Select id, customer_cc_list__c from case where id = :strObjectName];
            if(!cslst.isEmpty()){
                if(cslst[0].customer_cc_list__c != null){
                    for(String s: cslst[0].customer_cc_list__c.trim().split(';')){
                        if(!s.contains(GCSCommonConstants.ZSCALER_DOMAIN)){
                            emailset.add(s);
                        }
                    }
                }
            }
            List<String> emailIds = new List<String>(emailset);
            return emailIds;
        }
        else {
            return null;
        }
    }
    @AuraEnabled
    public static void updateCustomerCCList(String caseId, String custcclist) {
        if(String.isNotBlank(caseId)) {
            Case cs = new Case(id=caseId, Customer_cc_list__c = custcclist);
            update cs;
            Set<String> emailsfinal = new Set<String>();
            for(String s: custcclist.split(';')){
                if(s != '' && s != null){
                    emailsfinal.add(s.trim());
                }
            }
            List<CaseTeamMember> ctmlst = [Select ID from caseTeamMember where parentId = :caseId and teamrole.name = 'Customer' and memberid not in (Select Id from contact where email in :emailsfinal)];
            if(!ctmlst.isEmpty()){
                database.delete(ctmlst, false);
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getUserDetails() {
        user ur = [select id,Profile.UserLicense.Name from User where id =: UserInfo.getUserId()];
        return  ur.Profile.UserLicense.Name;
    }
    @AuraEnabled(cacheable=true)
    public static list<String> getDomains() {
            Map<String, Email_Domains_to_Exclude__c> mapemaildomains = Email_Domains_to_Exclude__c.getAll();
            return new List<String>(mapemaildomains.keySet());
    }
    @AuraEnabled
    public static Contact updateContact(Contact objCt, Id caseId) {
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerUtility.realignPatch();
        update objCt;
        List<Case> cslst = [Select Id, Case_CC_List__c, Internal_CC_List__c, Customer_CC_List__c from case where Id = :caseId];
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return objCt;
    }
    @AuraEnabled
    public static String addContact(String email,Id caseId) {
        String status = '';
        Set<Id> contIds = new Set<Id>();
        List<String> emailList = new List<String>();
        List<Case> cslst = [Select Id, Case_CC_List__c, Internal_CC_List__c, Customer_CC_List__c from case where Id = :caseId];
        List<CaseTeamMember> ctmlst = [Select Id, MemberId, Member.Email, ParentId from CaseTeamMember where ParentId =: caseId];
        for(CaseTeamMember ctr: ctmlst){
            contIds.add(ctr.MemberId);
        }
        for(Contact con: [Select Id, Email from Contact where Id in :contIds]){
            emailList.add(con.Email);
        }
	    for(User ur: [Select Id, Email from User where Id in :contIds]){
            emailList.add(ur.Email);
        }
    
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(email);

        if(!emailMatcher.matches()){
            status = 'invalidEmail';
        }
        else if(!email.contains(GCSCommonConstants.ZSCALER_DOMAIN) && !emailList.contains(email)){
            if(cslst[0].Customer_CC_List__c!=null){
                cslst[0].Customer_CC_List__c += email;
            }
            else{
                cslst[0].Customer_CC_List__c = email;
            }
            status = 'success';
        }
        else if(!emailList.contains(email)){
            List<User> usr = [Select Id,Email from User where Email = :email];
            if(!usr.isEmpty()){
                if(cslst[0].Internal_CC_List__c!=null){
                    cslst[0].Internal_CC_List__c += email;
                }
                else{
                    cslst[0].Internal_CC_List__c = email;
                }
                status = 'success';
            }
            else{
                status = 'zscalerError';
            }
        }
        else{
                status = 'duplicateError';
        }
        if(status == 'success'){
            update cslst;
        }
        return status;
    }
    @AuraEnabled
    public static void deleteContact(String objCtId, Id caseId) {
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerUtility.realignPatch();
        List<CaseTeamMember> lst1 = [select id from CaseTeamMember where ParentId =:caseId and MemberId =: objCtId];
        if(!lst1.isEmpty()){
            database.delete(lst1, false);
        }
        List<Case> cslst = [Select Id, Case_CC_List__c, Internal_CC_List__c, Customer_CC_List__c from case where Id = :caseId];
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
    }
    
    @AuraEnabled                                           
    public static CaseTeamMember addUserToCaseTeamMember(String objCtId,String caseId) {
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerUtility.realignPatch();
        System.debug('Here:-'+caseId);
        System.debug('objCt:-'+objCtId);
        String teamRoleId = '';
        List<Case> cslst = [Select Id, Case_CC_List__c, Internal_CC_List__c, Customer_CC_List__c from case where Id = :caseId];
        User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
        CaseTeamMember cseMember = null;
        if(objCtId != null) {
            if(ur != null && ur.ContactId != null){
                teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
            }else if(ur != null){
                teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Internal Agent' limit 1].Id;
            }
            cseMember = new CaseTeamMember();
            cseMember.MemberId = objCtId;
            cseMember.ParentId = caseId;
            cseMember.TeamRoleId = teamRoleId;
            insert csemember;
        }
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return csemember;
    }
    @AuraEnabled                                           
    public static List<CaseTeamMember> addMultiContactToCaseTeamMember(List<String> objCtId,String caseId) {
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerUtility.realignPatch();
        System.debug('Here:-'+caseId);
        System.debug('objCt:-'+objCtId);
        String teamRoleId = '';
        List<Case> cslst = [Select Id, Case_CC_List__c, Internal_CC_List__c, Customer_CC_List__c from case where Id = :caseId];
       
        //User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
       // CaseTeamMember cseMember = null;
       List<CaseTeamMember> lstCaseTeams = new List<CaseTeamMember>();
        if(objCtId != null) {
           // List<String> obj1 = objCtId.split(',');
            teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
            List<CaseTeamMember> lst1 = [select id from CaseTeamMember where ParentId =:caseId and TeamRoleId =: teamRoleId];
            System.debug(lst1.size());
            delete lst1;
            //System.debug(obj1.size());
            for(String s : objCtId)  {
                System.debug(s);
                CaseTeamMember cseMember = new CaseTeamMember();
                cseMember.MemberId = s;
                cseMember.ParentId = caseId;
                cseMember.TeamRoleId = teamRoleId;
                lstCaseTeams.add(cseMember);
            }
            System.debug(lstCaseTeams.size());
            Database.insert(lstCaseTeams,true);
        }
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return lstCaseTeams;
    }

    @AuraEnabled                                           
    public static List<CaseTeamMember> addMultiUserToCaseTeamMember(List<String> objCtId,String caseId) {
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerUtility.realignPatch();
        String teamRoleId = '';
        List<Case> cslst = [Select Id, Case_CC_List__c, Internal_CC_List__c, Customer_CC_List__c from case where Id = :caseId];
       
        //User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
       List<CaseTeamMember> lstCaseTeams = new List<CaseTeamMember>();
        if(objCtId != null) {
            teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Internal Agent' limit 1].Id;
            List<CaseTeamMember> lst1 = [select id from CaseTeamMember where ParentId =:caseId and TeamRoleId =: teamRoleId];
            System.debug(lst1.size());
            delete lst1;
            for(String s : objCtId)  {
                System.debug(s);
                CaseTeamMember cseMember = new CaseTeamMember();
                cseMember.MemberId = s;
                cseMember.ParentId = caseId;
                cseMember.TeamRoleId = teamRoleId;
                lstCaseTeams.add(cseMember);
            }
            System.debug(lstCaseTeams.size());
            Database.insert(lstCaseTeams,true);
        }
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return lstCaseTeams;
    }

    @AuraEnabled
    public static CaseTeamMember addContactToCaseTeamMember(String objCtId,String caseId) {
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerUtility.realignPatch();
        System.debug('Here:-'+caseId);
        System.debug('objCt:-'+objCtId);
        String teamRoleId = '';
        List<Case> cslst = [Select Id, Case_CC_List__c, Internal_CC_List__c, Customer_CC_List__c from case where Id = :caseId];
        User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
        CaseTeamMember cseMember = null;
        if(objCtId != null) {
            if(ur != null && ur.ContactId != null){
                teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
            }else if(ur != null){
                teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Internal Agent' limit 1].Id;
            }
            cseMember = new CaseTeamMember();
            cseMember.MemberId = objCtId;
            cseMember.ParentId = caseId;
            cseMember.TeamRoleId = teamRoleId;
            insert csemember;
        }
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return csemember;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<CaseTeamMember> fetchUserCaseTeamMember(String csId) {
        if(String.isNotBlank(csId)) {
            String teamrole = 'Internal Agent';
            List<CaseTeamMember> userCaseMembers = [select id, MemberId from CaseTeamMember where ParentId =: csId and TeamRole.Name=: teamrole order by Member.name];
            return userCaseMembers;
        }
        else {
            return null;
        }
    }
    /*@AuraEnabled(cacheable=true)
    public static list<Contact> fetchAccountContacts(String csId) {
        String accountId = '0017000000RYGPtAAP';
        System.debug('strObjectName:-'+csId);
        if(String.isNotBlank(csId)) {
            Case cs = [select id, AccountId from Case where id =:csId];
            if(cs.AccountId != null && cs.AccountID != accountId ){
                List<Contact> ctList = [SELECT Id, Email, FirstName, LastName, Name FROM Contact where AccountId =: cs.AccountId order by Firstname];
                return ctList;
            }else{
                return null;
            }
        }
        else {
            return null;
        }
    }*/
    @AuraEnabled(cacheable=true)
    public static list<User> fetchUsers(String csId) {
        List<User> userList = [SELECT Id, Email, FirstName, LastName, Name FROM User where IsActive = true AND Profile.UserLicense.name = 'Salesforce' order by FirstName];
        return userList;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<emailwrapper> fetchEmailList(String csId) {
        list<emailwrapper> lsttoreturn = new list<emailwrapper> ();
        if(String.isNotBlank(csId)) {
            String teamrole = '';
            User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
            if(ur != null && ur.ContactId != null){
                teamrole = 'Customer';
            }
            List<CaseTeamMember> lstc = new List<CaseTeamMember>();
            if(teamrole != ''){
                lstc = [select id, MemberId from CaseTeamMember where ParentId =: csId and TeamRole.Name=: teamrole order by Member.name];
            }else{
                lstc = [select id, MemberId from CaseTeamMember where ParentId =: csId order by Member.name];
            }
            List<Id> lstIds = new List<Id>();
            for(CaseTeamMember ct : lstc) {
                lstIds.add(ct.MemberId);
            }
            for(Contact u: [SELECT Id, Email, FirstName, LastName FROM Contact where Id in : lstIds order by name]){
                lsttoreturn.add(new emailwrapper(u.Id, u.FirstName,  u.LastName, u.Email, true));
            }
            for(User u: [SELECT Id, Email, FirstName, LastName FROM User where Id in : lstIds order by Name]){
                lsttoreturn.add(new emailwrapper(u.Id, u.FirstName,  u.LastName, u.Email, false));
            }
            
            return lsttoreturn;
        }
        else {
            return null;
        }
    }
    public static void updatecaseCCList(List<case> cslst) {
        Map<Id, String> cclstmap = new Map<Id, String>();
        Map<Id, String> conIdtoemailMap = new Map<Id, String>();
        Map<Id, String> userIdtoemailMap = new Map<Id, String>();
        Set<Id> contIds = new Set<Id>();
        Set<String> intlst = new Set<String>();
        Set<String> extlst = new Set<String>();
        List<CaseTeamMember> lstCaseTeamMember = [Select Id, MemberId, Member.Email, ParentId from CaseTeamMember where ParentId in :cslst];
        for(CaseTeamMember ctr: lstCaseTeamMember){
            contIds.add(ctr.MemberId);
        }
        for(Contact con: [Select Id, Email from Contact where Id in :contIds]){
            conIdtoemailMap.put(con.Id, con.Email);
        }
	    for(User ur: [Select Id, Email from User where Id in :contIds]){
            userIdtoemailMap.put(ur.Id, ur.Email);
        }
        updateCaseMember(lstCaseTeamMember, cclstmap, conIdtoemailMap, userIdtoemailMap);
        updateCase(cslst, cclstmap, intlst, extlst);
        
        TriggerUtility.SkipCaseTriggerExecuted();
        update cslst;
            }
    public static void updateCase(List<case> cslst, Map<Id, String> cclstmap, Set<String> intlst, Set<String> extlst){
        for(Case cs: cslst){
            cs.Internal_CC_List__c = null;
            cs.Customer_CC_List__c = null;
            if(cclstmap.containsKey(cs.Id) && cclstmap.get(cs.Id) != null){
                for(String s: cclstmap.get(cs.Id).split(';')){
                    checkEmail(cs, s, intlst, extlst);
                }
            }
        }
    }
    public static void checkEmail(Case cs, String s, Set<String> intlst, Set<String> extlst){
                    if(s != null && s != '' && s.trim() != ''){
                        if(s.contains(GCSCommonConstants.ZSCALER_DOMAIN) && !intlst.contains(s)){
                setInternalList(cs, s);
            }else if (!s.contains(GCSCommonConstants.ZSCALER_DOMAIN) && !extlst.contains(s)){
                setCustomerList(cs, s);
            }
        }
    }
    public static void setInternalList(Case cs, String s){
                            if(cs.Internal_CC_List__c != null){
                                cs.Internal_CC_List__c += s + ';';
                            }else{
                                cs.Internal_CC_List__c = s + ';';
                            }
    }
    public static void setCustomerList(Case cs, String s){
                            if(cs.Customer_CC_List__c != null){
                                cs.Customer_CC_List__c += s + ';';
                            }else{
                                cs.Customer_CC_List__c = s + ';';
                            }
                        }
    public static void updateCaseMember(List<CaseTeamMember> lstCaseTeamMember, Map<Id, String> cclstmap, Map<Id, String> conIdtoemailMap, Map<Id, String> userIdtoemailMap){
        for(CaseTeamMember ctr: lstCaseTeamMember){
            if(cclstmap.containsKey(ctr.ParentId)){
                String emails = cclstmap.get(ctr.ParentId);
                emails += conIdtoemailMap.containsKey(ctr.MemberId) ? conIdtoemailMap.get(ctr.MemberId) + ';' : (userIdtoemailMap.containsKey(ctr.MemberId) ? userIdtoemailMap.get(ctr.MemberId) + ';' : '');
                    cclstmap.put(ctr.ParentId, emails);
            }else{
                cclstmap.put(ctr.ParentId, conIdtoemailMap.containsKey(ctr.MemberId) ? conIdtoemailMap.get(ctr.MemberId) + ';' : (userIdtoemailMap.containsKey(ctr.MemberId) ? userIdtoemailMap.get(ctr.MemberId) + ';' : ''));
                    }
                }
    }
    public class emailwrapper{
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String FirstName {get; set;}
        @AuraEnabled
        public String LastName {get; set;}
        @AuraEnabled
        public String Email {get; set;}
        @AuraEnabled
        public Boolean isCustomer {get; set;}
        public emailwrapper(String i, string fn, string ln, String e, boolean cust){
            Id = i;
            FirstName = fn;
            LastName = ln;
            Email = e;
            isCustomer = cust;
        }
    }
}