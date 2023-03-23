// Added by Abhijit for CR851
public class CXOAdvisorRequestTriggerUtility {
    public static void populateCXOAdvisor(List<CXO_Advisor_Request__c> triggerNew, Map<Id, CXO_Advisor_Request__c> oldMap){
        
        Map<Id, String> openOpptyIdsCXOAdvisor = new Map<Id, String>();
        List<Id> opptyIdsResetCXOAdvisor = new List<Id>();        
        if(oldMap == null){
            for(CXO_Advisor_Request__c cxoAdvisorRequest: triggerNew){
                if(cxoAdvisorRequest.CXO_Request_Status__c == Label.CXO_Status_4_Meeting_Completed && cxoAdvisorRequest.Opportunity__c != null){
                    openOpptyIdsCXOAdvisor.put(cxoAdvisorRequest.Opportunity__c, cxoAdvisorRequest.Zscaler_CXO_Advisor__c);
                }
            }
        }
        
        if(oldMap != null){
            for(CXO_Advisor_Request__c cxoAdvisorRequest: triggerNew){
                if(((oldMap.get(cxoAdvisorRequest.Id).CXO_Request_Status__c != cxoAdvisorRequest.CXO_Request_Status__c) || (oldMap.get(cxoAdvisorRequest.Id).Zscaler_CXO_Advisor__c != cxoAdvisorRequest.Zscaler_CXO_Advisor__c)) && cxoAdvisorRequest.CXO_Request_Status__c == Label.CXO_Status_4_Meeting_Completed && cxoAdvisorRequest.Opportunity__c != null){
                    openOpptyIdsCXOAdvisor.put(cxoAdvisorRequest.Opportunity__c, cxoAdvisorRequest.Zscaler_CXO_Advisor__c);
                }
            }
        }
        
        if(!openOpptyIdsCXOAdvisor.isEmpty()){
            List<Opportunity> openOpportunities = new List<Opportunity>(); 
            openOpportunities = [select id from Opportunity where id in: openOpptyIdsCXOAdvisor.keySet() and StageName not in ('6 - Closed Won', '7 - Closed Lost')];
            
            if(openOpportunities != null && !openOpportunities.isEmpty()){
                for(Opportunity openOpportunity: openOpportunities){
                    openOpportunity.CXO_Sourced__c = true;
                    openOpportunity.CXO_Advisor__c = openOpptyIdsCXOAdvisor.get(openOpportunity.Id);                
                }
                
                TriggerUtility.skipOpportunityTrigger();                
                update openOpportunities;
            }
        }  
        
    }
    
    // Added by Ayush Kangar as part of CR# 3856 - Start
    public static void populateTeamAdvisor(List<CXO_Advisor_Request__c> triggerNew){
        List<User> teamAdviserUSer =  new List<User>();
        Set<String> usernameSet = new Set<String>();
        Map<String,User> userNameUserRecordMap = new Map<String,User>();
        for(CXO_Advisor_Request__c advisor: triggerNew){
            usernameSet.add(advisor.Zscaler_CXO_Advisor__c);
        }
        List<User> userList = [select id,name from user where name IN :usernameSet];
        for(User usr : userList){
            userNameUserRecordMap.put(usr.Name,usr);
        }
        for(CXO_Advisor_Request__c advisor: triggerNew){
            if(!userNameUserRecordMap.isEmpty() && userNameUserRecordMap.containsKey(advisor.Zscaler_CXO_Advisor__c)){
                advisor.Team_Advisor__c = userNameUserRecordMap.get(advisor.Zscaler_CXO_Advisor__c).Id;
            }
        }
    }
    public static void populateRequestType(List<CXO_Advisor_Request__c> triggerNew,Map<Id, CXO_Advisor_Request__c> oldMap){
        for(CXO_Advisor_Request__c advisor: triggerNew){
            if(oldMap.get(advisor.Id).RecordTypeId != advisor.RecordTypeId){
                if(Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosById().get(advisor.RecordTypeId).getname()!=null){
                    advisor.Request_Type__c = Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosById().get(advisor.RecordTypeId).getname();
                }
            }
        }
    }
    // Added by Ayush Kangar as part of CR# 3856 - End
    
    // Added by Ayush Kangar as part of CR# 4587 - Start
    public static void populateCisoCtoFromAccountExt(List<CXO_Advisor_Request__c> triggerNew){
        
        Map<Id,Id> cxoAccountMap = new Map<Id,Id>();
        Map<Id,Account_Extension__c> AccIdAccountExtMap = new Map<Id,Account_Extension__c>();
        for(CXO_Advisor_Request__c advisor: triggerNew){
            if(advisor.Account_Name__c != null){
                cxoAccountMap.put(advisor.Id,advisor.Account_Name__c);
            }
        }
        
        for(Account_Extension__c accExList : [select id,Account__r.Area__c, Account__r.Region__c,Account__c,Field_CTO__c,Field_CISO__c from Account_Extension__c where Account__c in:cxoAccountMap.values()]){
            AccIdAccountExtMap.put(accExList.Account__c,accExList);
        }
        for(CXO_Advisor_Request__c advisor: triggerNew){
            if(!AccIdAccountExtMap.isEmpty() && AccIdAccountExtMap.containsKey(advisor.Account_Name__c)){
                system.debug('---'+advisor.Zscaler_CXO_Advisor__c);
                String Record_Type_Name = Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosById().get(advisor.RecordTypeId).getDeveloperName();
                if(advisor.Field_CISO__c==null){
                    advisor.Field_CISO__c = AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CISO__c;
                }
                if(advisor.Field_CTO__c==null){
                    advisor.Field_CTO__c = AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CTO__c;
                }
                if(Record_Type_Name == 'Field_CTO' && advisor.Zscaler_CXO_Advisor__c==null){
                    List<user> CTO_user = [select full_name__c from user where id =: AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CTO__c]; 
                    advisor.Zscaler_CXO_Advisor__c = CTO_user[0].full_name__c;
                }else if(Record_Type_Name == 'Field_CISO' && advisor.Zscaler_CXO_Advisor__c==null){
                    List<user> CISO_user = [select full_name__c from user where id =: AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CISO__c]; 
                    advisor.Zscaler_CXO_Advisor__c = CISO_user[0].full_name__c;
                }
            }
        }
    }
    // Added by Ayush Kangar as part of CR# 4587 - End
    
    // Added by Ayush Kangar as part of CR# 4587 - Start
    public static void updateCisoCtoFromAccountExt(List<CXO_Advisor_Request__c> triggerNew,Map<Id, CXO_Advisor_Request__c> oldMap){
        
        Map<Id,Id> cxoAccountMap = new Map<Id,Id>();
        Map<Id,Account_Extension__c> AccIdAccountExtMap = new Map<Id,Account_Extension__c>();
        for(CXO_Advisor_Request__c advisor: triggerNew){
            if(oldMap.get(advisor.id).Account_Name__c !=advisor.Account_Name__c && advisor.Account_Name__c != null){
                cxoAccountMap.put(advisor.Id,advisor.Account_Name__c);
            }
        }
        
        for(Account_Extension__c accExList : [select id,Account__r.Area__c, Account__r.Region__c,Account__c,Field_CTO__c,Field_CISO__c from Account_Extension__c where Account__c in:cxoAccountMap.values()]){
            AccIdAccountExtMap.put(accExList.Account__c,accExList);
        }
        for(CXO_Advisor_Request__c advisor: triggerNew){
            if(!AccIdAccountExtMap.isEmpty() && AccIdAccountExtMap.containsKey(advisor.Account_Name__c)){
                system.debug('---'+advisor.Zscaler_CXO_Advisor__c);
                system.debug('--'+advisor.Account_Name__c);
				system.debug('-'+AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CTO__c);
                String Record_Type_Name = Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosById().get(advisor.RecordTypeId).getDeveloperName();
                advisor.Field_CISO__c = AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CISO__c;
                advisor.Field_CTO__c = AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CTO__c;
                if(Record_Type_Name == 'Field_CTO' && AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CTO__c!=null){
                    List<user> CTO_user = [select full_name__c from user where id =: AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CTO__c]; 
                    advisor.Zscaler_CXO_Advisor__c = CTO_user[0].full_name__c;
                }else if(Record_Type_Name == 'Field_CISO' && AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CISO__c!=null){
                    List<user> CISO_user = [select full_name__c from user where id =: AccIdAccountExtMap.get(advisor.Account_Name__c).Field_CISO__c]; 
                    advisor.Zscaler_CXO_Advisor__c = CISO_user[0].full_name__c;
                }
            }
        }
    }
    // Added by Ayush Kangar as part of CR# 4587 - End
}