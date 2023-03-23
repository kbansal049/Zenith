/*
* @description       : 
* Modifications Log 
* Ver   Date         Author            Modification
* 1.0   09-02-2022   Mayank Bansal     Initial Version
*/
public without sharing class AddOpportunityTeamMember {
    
    @AuraEnabled(cacheable=true)
    public static String fetchMetaData(){
        
        Id profileId = userinfo.getProfileId();
        Profile prf = [Select name from profile where id = :profileId];
        List<AddOpportunityTeamMemberMetadata__mdt> metaData = [Select id, isEnabledForSEUsers__c, isEnabledForTeam__c, Team_Member_Role__c from AddOpportunityTeamMemberMetadata__mdt where MasterLabel like :prf.name limit 1];
        
        String teamRoleListInStr = metaData.get(0).Team_Member_Role__c;
        List<String> teamRoleList = teamRoleListInStr.split(';');
        String jsonOfTeamRole = null;
        for(String str: teamRoleList){
            if(jsonOfTeamRole == null){
                jsonOfTeamRole = '[';
            }else{
                jsonOfTeamRole = jsonOfTeamRole + '{"label":"'+ str+ '","value":"' + str + '"},';
            }
        }
        jsonOfTeamRole = jsonOfTeamRole.removeEnd(',');
        jsonOfTeamRole = jsonOfTeamRole + ']';
        return jsonOfTeamRole;
    }
    
    @AuraEnabled
    public static OTMWrapper checkIfItsAllowed(Id oppId){
        Id loggedInUSer = UserInfo.getUserId();
        Id profileId = userinfo.getProfileId();
        Profile prf = [Select name from profile where id = :profileId];
        OTMWrapper wrp = new OTMWrapper();
        boolean isAllowed = false;
        Opportunity opp = [Select id, SE_Name__c from Opportunity where id = :oppId];
        List<OpportunityTeamMember> otmList = [Select id, UserId from OpportunityTeamMember where OpportunityId = :oppId];
        List<AddOpportunityTeamMemberMetadata__mdt> metaData = [Select id, isEnabledForSEUsers__c, isEnabledForTeam__c from AddOpportunityTeamMemberMetadata__mdt where MasterLabel like :prf.name limit 1];
        
        if(System.Label.Profile_System_Administrator.contains(userInfo.getProfileId())){
            isAllowed = true;
        }
        else if(System.FeatureManagement.checkPermission('Create_Opportunity_Team_Member')){
            isAllowed = true;
        }
        else if(metaData.get(0).isEnabledForSEUsers__c && opp.SE_Name__c == loggedInUSer){
            isAllowed = true;
        }
        // For Opp Team Members
        else if(metaData.get(0).isEnabledForTeam__c){
            for(OpportunityTeamMember otm: otmList){
                if(otm.UserId == loggedInUSer){
                    isAllowed = true;
                    break;
                }
            }
        }
        
        if(isAllowed){
            wrp.isAllowed = true;
            wrp.oppTeamList = fetchAllOppTeamMembers(oppId);
            return wrp;
        }else{
            wrp.isAllowed = false;
            wrp.oppTeamList = null;
            return wrp;
        }
    }
    
    @AuraEnabled
    public static string saveOppTeamMember(String oppTeamId, String userId, String tagList, String role){
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.id = oppTeamId;
        otm.TAG__c = tagList;
        otm.TeamMemberRole = role;
        try{
            update otm;
        }catch(Exception e){
            return 'Error: '+e.getMessage();
        }
        return 'updated';
        
    }
    
    @AuraEnabled
    public static string deleteOppTeamMember(String oppTeamId){
        OpportunityTeamMember oppTeam = new OpportunityTeamMember();
        oppTeam.id = oppTeamId;
        delete oppTeam;
        return 'deleted';
    }
    
    public static List<OpportunityTeamMember> fetchAllOppTeamMembers(Id oppId){
        Id loggedInUSer = UserInfo.getUserId();
        List<OpportunityTeamMember> oppTeamList = [Select id, TeamMemberRole, UserId, User.Name, TAG__c from OpportunityTeamMember where OpportunityId = :oppId and TAG__c != null];
        return oppTeamList;
    }
    
    @AuraEnabled
    public static String createOpportunityTeamMember(String jsonStr){
        System.System.debug('Mayank, jsonStr:'+jsonStr);
        List<LWCWrapper> wrapperList = (List<LWCWrapper>) JSON.deserialize(jsonStr, List<LWCWrapper>.class);
        System.System.debug('Mayank, wrapperList:'+wrapperList);
        List<OpportunityTeamMember> existingOtmList = [Select id, UserId, TAG__c, TeamMemberRole from OpportunityTeamMember where OpportunityId = :wrapperList.get(0).oppId];
        Map<Id, OpportunityTeamMember> idToOTMMap = new Map<Id, OpportunityTeamMember>();
        for(OpportunityTeamMember otm: existingOtmList){
            idToOTMMap.put(otm.UserId, otm);
        }
        List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();
        for(LWCWrapper wrapper: wrapperList){
            
            OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
            
            if(idToOTMMap.containsKey(wrapper.user)){
                OpportunityTeamMember existingOTM = idToOTMMap.get(wrapper.user);
                oppTeamMember.OpportunityId = wrapper.oppId;
                oppTeamMember.UserId = wrapper.user; 
                String tags;
                if(existingOTM.TAG__c !=null)
                    tags = wrapper.tagList +';'+ existingOTM.TAG__c;
                else
                    tags = wrapper.tagList;
                oppTeamMember.TAG__c = tags;
                oppTeamMember.TeamMemberRole = wrapper.role;
            }else{
                oppTeamMember.OpportunityId = wrapper.oppId;
                oppTeamMember.UserId = wrapper.user; 
                oppTeamMember.TAG__c = wrapper.tagList;
                oppTeamMember.TeamMemberRole = wrapper.role;
            }
            oppTeamMemberList.add(oppTeamMember);
        }
        
        upsert oppTeamMemberList;
        return 'success';
    }
    
    public class LWCWrapper{
        @auraEnabled   
        public string user;
        @auraEnabled
        public String tagList;
        @auraEnabled
        public integer index;
        @auraEnabled
        public String oppId;
        @auraEnabled
        public String role;
        
        public LWCWrapper(){}
    }
    
    public class OTMWrapper{
        @auraEnabled   
        public boolean isAllowed;
        @auraEnabled
        public List<OpportunityTeamMember> oppTeamList;
        
        public OTMWrapper(){}
    }
 }