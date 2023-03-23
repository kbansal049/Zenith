public class AssociatedAccountAndOpportunityLinks {
    @AuraEnabled
    public static void AccountsAndOpportunityLink(String accountIds,String opportunityIds,String userIds, id recId){
        try{
            String userEmail = UserInfo.getUserEmail();
            accountIds = accountIds.replaceAll('\"(?=[^\\[]*])','').replace('[','').replace(']','');
            opportunityIds = opportunityIds.replaceAll('\"(?=[^\\[]*])','').replace('[','').replace(']','');
            userIds = userIds.replaceAll('\"(?=[^\\[]*])','').replace('[','').replace(']','');
            
            Transformation_Team_Speaker_Request__c speakerRequest = new Transformation_Team_Speaker_Request__c();
            speakerRequest.id = recId;
            set<id> accIdsSet = new set<id>();
            if(accountIds !=''){
            List<String> accIds = accountIds.split(',');
            speakerRequest.Account_Link_Ids__c=String.join(accIds,',');           
                for(string accIdSet : accIds){
                    accIdsSet.add(accIdSet);
                }
            
            
                if(accIdsSet != null){
                    for(Account acc : [Select id,Name from account where Id IN :accIdsSet]){
                        if(speakerRequest.Associated_Accounts_Links__c == null){
                            speakerRequest.Associated_Accounts_Links__c = '<a href = '+System.URL.getSalesforceBaseURL().toExternalForm()+'/'+acc.Id +'>'+acc.Name+'</a> <br/>';
                        }
                        else{
                            speakerRequest.Associated_Accounts_Links__c = speakerRequest.Associated_Accounts_Links__c + '<a href = '+System.URL.getSalesforceBaseURL().toExternalForm()+'/'+acc.Id +'>'+acc.Name+'</a> <br/>';
                        }
                    }
                }
            }
        
            if(opportunityIds != ''){
                List<String> oppIds = opportunityIds.split(',');
                speakerRequest.Opportunity_Link_Ids__c=String.join(oppIds,',');
                set<id> oppIdsSet = new set<id>();
                for(String oppIdSet : oppIds){
                    oppIdsSet.add(oppIdSet);
                }
                if(oppIdsSet != null){
                    for(opportunity opp : [Select id,Name from opportunity where Id IN :oppIds AND AccountId IN :accIdsSet]){
                            if(speakerRequest.Opportunity_Link_s__c == null){
                            speakerRequest.Opportunity_Link_s__c = '<a href = '+System.URL.getSalesforceBaseURL().toExternalForm()+'/'+opp.Id +'>'+opp.Name+'</a> <br/>';
                        }
                        else{
                            speakerRequest.Opportunity_Link_s__c = speakerRequest.Opportunity_Link_s__c + '<a href = '+System.URL.getSalesforceBaseURL().toExternalForm()+'/'+opp.Id +'>'+opp.Name+'</a> <br/>';
                        }
                    }
                }
            }
        
            if(userIds != ''){
                List<String> usrIds = userIds.split(',');
                speakerRequest.avp_link_ids__c=String.join(usrIds,',');
                set<id> usrIdsSet = new set<id>();
                for(String usrIdSet : usrIds){
                    usrIdsSet.add(usrIdSet);
                }
                if(usrIdsSet != null){
                    for(User usr : [Select id,Name from User where Id IN :usrIds]){
                        if(speakerRequest.AVP_s_Link__c == null){
                            speakerRequest.AVP_s_Link__c = '<a href = '+System.URL.getSalesforceBaseURL().toExternalForm()+'/'+usr.Id +'>'+usr.Name+'</a> <br/>';
                        }
                        else{
                            speakerRequest.AVP_s_Link__c = speakerRequest.AVP_s_Link__c + '<a href = '+System.URL.getSalesforceBaseURL().toExternalForm()+'/'+usr.Id +'>'+usr.Name+'</a> <br/>';
                        }
                    }
                }
            }
            update speakerRequest;  
        }catch(Exception ee){
            System.debug('Error-->'+ee.getMessage()+'at line : '+ee.getLineNumber());
        }
    }

    @AuraEnabled
    public static List<String> accountNames(String accountIds){
        accountIds = accountIds.replaceAll('\"(?=[^\\[]*])','').replace('[','').replace(']','');
        List<String> accIds = accountIds.split(',');
        set<String> accId = new Set<String>();
        for(string acc : accIds){
            accId.add(acc);
        }
        
        List<Account> accList = new List<Account>();
        accList = [select Name from Account where Id IN :accId];
        
        List<String> strList = new List<String>();
        for(Account acc : accList){
            strList.add(acc.Name);
        }
        return strList;
    }
    
    @AuraEnabled
    public static List<String> opportunityNames(String opportunityIds, String accountIds){
        opportunityIds = opportunityIds.replaceAll('\"(?=[^\\[]*])','').replace('[','').replace(']','');
        List<String> oppIds = opportunityIds.split(',');
        set<String> oppId = new Set<String>();
        for(string opp : oppIds){
            oppId.add(opp);
        }
        accountIds = accountIds.replaceAll('\"(?=[^\\[]*])','').replace('[','').replace(']','');
        List<String> accIds = accountIds.split(',');
        set<String> accId = new Set<String>();
        for(string acc : accIds){
            accId.add(acc);
        }
        
        List<opportunity> oppList = new List<opportunity>();
        oppList = [select Name from opportunity where Id=:oppId AND accountId IN :accId];
        
        List<String> strList = new List<String>();
        for(opportunity opp : oppList){
            strList.add(opp.Name);
        }
        /*if(!oppList.isEmpty()){
            return oppList[0].Name;
        }else{
            return 'Not Found';
        }*/
        
        return strList;
        
        
    }
    
    @AuraEnabled
    public static List<opportunity> opportunityRemovedNames(String opportunityIds, String accountIds){
        opportunityIds = opportunityIds.replaceAll('\"(?=[^\\[]*])','').replace('[','').replace(']','');
        List<String> oppIds = opportunityIds.split(',');
        set<String> oppId = new Set<String>();
        for(string opp : oppIds){
            oppId.add(opp);
        }
        accountIds = accountIds.replaceAll('\"(?=[^\\[]*])','').replace('[','').replace(']','');
        List<String> accIds = accountIds.split(',');
        set<String> accId = new Set<String>();
        for(string acc : accIds){
            accId.add(acc);
        }
        
        List<opportunity> oppList = new List<opportunity>();
        oppList = [select Id from opportunity where Id IN :oppId AND accountId Not IN :accId];
        
        /*List<opportunity> strList = new List<opportunity>();
        for(opportunity opp : oppList){
            strList.add(opp.Id);
        }*/
        System.debug('>>>>strList'+oppList);
        
        return oppList;
    }
    
        
    @AuraEnabled
    public static List<String> userNames(String userIds){
        userIds = userIds.replaceAll('\"(?=[^\\[]*])','').replace('[','').replace(']','');
        List<String> usrIds = userIds.split(',');
        set<String> usrId = new Set<String>();
        for(string usr : usrIds){
            usrId.add(usr);
        }
        List<user> usrList = new List<user>();
        usrList = [select Name from user where Id IN :usrId];
        List<String> strList = new List<String>();
        for(user usr : usrList){
            strList.add(usr.Name);
        }
        return strList;
    }

    @AuraEnabled
    public static linkWrapper fetchAVPLinks(String recsId){
        linkWrapper linkWrapperObj = new linkWrapper();
        set<id> accountIds = new set<id>();
        if(recsId != null){
            Transformation_Team_Speaker_Request__c speakerRequest = [Select Id,avp_link_ids__c,Account_Link_Ids__c,Opportunity_Link_Ids__c from Transformation_Team_Speaker_Request__c Where Id =: recsId];
            if(speakerRequest != null){
                if(String.isNotBlank(speakerRequest.avp_link_ids__c)){
                    List<String> usrIds = speakerRequest.avp_link_ids__c.split(',');
                    set<String> usrId = new Set<String>();
                    for(string usr : usrIds){
                        usrId.add(usr);
                    }
                    List<User> usrList = [Select Id,Name From User Where Id IN: usrId];
                    linkWrapperObj.usrList=usrList;
                }
                if(String.isNotBlank(speakerRequest.Account_Link_Ids__c)){
                    List<String> accIds = speakerRequest.Account_Link_Ids__c.split(',');
                    set<String> acId = new Set<String>();
                    for(string acc : accIds){
                        acId.add(acc);
                        accountIds.add(acc);
                    }
                    List<Account> accList = [Select Id,Name From Account Where Id IN: acId];
                    linkWrapperObj.accList=accList;
                }
                if(String.isNotBlank(speakerRequest.Opportunity_Link_Ids__c)){
                    List<String> oppIds = speakerRequest.Opportunity_Link_Ids__c.split(',');
                    set<String> opId = new Set<String>();
                    for(string opp : oppIds){
                        opId.add(opp);
                    }
                    List<Opportunity> oppList = [Select Id,Name From Opportunity Where Id IN: opId AND accountId IN :accountIds];
                    linkWrapperObj.oppList=oppList;
                }
            }
        }
        return linkWrapperObj;
    }

    public class linkWrapper{
        @AuraEnabled public List<User> usrList;
        @AuraEnabled public List<Account> accList;
        @AuraEnabled public List<Opportunity> oppList;
    }
}