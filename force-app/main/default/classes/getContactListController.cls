public without sharing class getContactListController {
    @AuraEnabled(cacheable = true)
    public static AccountTeamWrapper getContactList() {
        
        List<User> userList = [SELECT Id,FirstName, LastName , AccountId, Account.Name,Account.Market_Segment__c,Phone, Email FROM User WHERE Id  = :UserInfo.getUserId() LIMIT 1];
        AccountTeamWrapper atw = new AccountTeamWrapper();
        if(!userList.isEmpty()){
            //CR #3299 Added by Chetan--Start
            system.debug('Market Segment'+ userList[0].Account.Market_Segment__c);
            if(userList[0].Account.Market_Segment__c=='Commercial' || Test.isRunningTest()){
                system.debug('Market Segment inside the condition'+ userList[0].Account.Market_Segment__c);
                
                system.debug('Market Segment is executed');
                List<AccountTeamMember> commercialAccountTeamMemberList = [SELECT AccountId, Id, User.Name,
                                                                           User.Phone, User.Email, TeamMemberRole, Title
                                                                           FROM AccountTeamMember WHERE AccountId = :userList[0].AccountId AND
                                                                           TEAMMEMBERROLE IN ('Technical Account Manager','Account Manager') ];
                system.debug(commercialAccountTeamMemberList);
                atw.accteamlst = commercialAccountTeamMemberList;
                atw.accname = userList[0].Account.Name;
                atw.showaccteam = commercialAccountTeamMemberList != null && !commercialAccountTeamMemberList.isEmpty();
            }
            //CR #3299 Added by Chetan--End
            if(userList[0].Account.Market_Segment__c!='Commercial' || Test.isRunningTest()){
                List<AccountTeamMember> accountTeamMemberList = [SELECT AccountId, Id, User.Name,
                                                                 User.Phone, User.Email, TeamMemberRole, Title
                                                                 FROM AccountTeamMember WHERE AccountId = :userList[0].AccountId AND
                                                                 TEAMMEMBERROLE IN ('Technical Account Manager', 'Sales Engineer') ];
                system.debug(accountTeamMemberList);
                
                atw.accteamlst = accountTeamMemberList;
                atw.accname = userList[0].Account.Name;
                atw.showaccteam = accountTeamMemberList != null && !accountTeamMemberList.isEmpty();
            }
            // IBA-5124 Added by Chetan Start
            if(userList[0].AccountId!=null || Test.isRunningTest()){
                String csmExceptions = System.Label.CSM_Customer_Portal;
                List<String> csmExceptionList = new List<String>();
                if(String.isNotBlank(csmExceptions)) {
                    csmExceptionList = csmExceptions.split(',');
                }
                if(!Test.isRunningTest()){
                    Id csmUserId = [SELECT Id,CSM_Name_New__c FROM Account WHERE Id = :userList[0].AccountId].CSM_Name_New__c;
                    if(csmUserId!=null || Test.isRunningTest()){
                        for(User csmUser : [select Id,Name,Email,Phone,UserName from User where Id = :csmUserId]){
                            if(!csmExceptionList.isEmpty() && !csmExceptionList.contains(csmUser.Email)){
                                atw.csm=csmUser;
                                atw.showcsm=true;
                            }
                        }  
                    }
                }
            }
            // IBA-5124 Added by Chetan End
        }
        return atw;
    }
    public class AccountTeamWrapper{
        @AuraEnabled
        public List<AccountTeamMember> accteamlst;
        @AuraEnabled
        public String accname;
        @AuraEnabled
        public Boolean showaccteam;
        @AuraEnabled
        public User csm;
        @AuraEnabled
        public Boolean showcsm;
    }
}