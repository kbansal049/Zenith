/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* UserTriggerUtility
* @description - This class works as handler for UserTrigger.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Bhagyalaxmi Deshmukh
* @maintainedBy   Zscaler
* @version        1.0
* @created        2020-01-29
* @modified       2023-01-24
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class UserTriggerUtility {
    static final String APEX_CLASS_NAME = 'UserTriggerUtility';

    static String createServiceAgentInformationStr = 'Execute_createServiceAgentInformation';
    static String userSkillAssignmentStr = 'Execute_User_Skill_Assignment';
    static String replaceInactiveUserOnFPRAMStr = 'Replace_Inactive_User_On_FP_RAM';

    /**
     * This method gets executed when After Insert trigger event fired
     */
    public static void afterInsert(List<User> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey(createServiceAgentInformationStr) 
            && tsmap.get(createServiceAgentInformationStr) != null 
            && tsmap.get(createServiceAgentInformationStr).Execute__c) {
            Set<Id> userSetId = new Set<Id>();
            for(User u : newList) {
                userSetId.add(u.Id);
            }
            createServiceResource(userSetId);
            createContactOnUserCreation(userSetId);
        }
        TriggerUtility.UserAfterInsertExecuted();
    }

    /**
     * This method gets executed when Before Insert trigger event fired
     */
    public static void beforeInsert(List<User> newList){
        TriggerUtility.UserBeforeInsertExecuted();
    }

    /**
     * This method gets executed when After Update trigger event fired
     */
    public static void beforeUpdate(List<User> newList, map<Id, User> oldmap){
        TriggerUtility.UserBeforeUpdateExecuted();
    }
    
    /**
     * This method gets executed when After Update trigger event fired
     */
    public static void afterUpdate(List<User> newList, Map<Id, User> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey(userSkillAssignmentStr) 
            && tsmap.get(userSkillAssignmentStr) != null 
            && tsmap.get(userSkillAssignmentStr).Execute__c 
            && !TriggerUtility.isUserSkillAssignmentUpdateExecuted()){
            updateSkillsforUsers(newList, oldmap);
        }

        //Added by Ankit - IBA-46 - Start
        if(tsmap.containsKey(createServiceAgentInformationStr) 
            && tsmap.get(createServiceAgentInformationStr) != null 
            && tsmap.get(createServiceAgentInformationStr).Execute__c) {
            Set<Id> userSetId = new Set<Id>();
            for(User u : newList) {
                if((u.profileId != oldMap.get(u.id).ProfileId) 
                        || ((u.Service_Level__c != oldMap.get(u.id).Service_Level__c) 
                    && u.Service_Level__c == 'TAM')) {
                    userSetId.add(u.Id);
                }
            }
            
            Set<Id> existingResourceIds = new Set<Id>(); 
            if(!userSetId.isEmpty()) {  
                //Modified by Bhagyalaxmi Deshmukh (IBA-5913 Scheduler Data Remodeling)
                for(ServiceResource resource : [SELECT Id, RelatedRecordId, Type__c 
                                                FROM ServiceResource 
                                                WHERE RelatedRecordId IN :userSetId 
                                                AND Type__c = :GCSCommonConstants.SERVICE_RESOURCE_TYPE_TAM]) {
                    existingResourceIds.add(resource.RelatedRecordId);
                }
                System.debug('existingResourceIds** : '+existingResourceIds);
            }
            Set<Id> finalUserIds = userSetId.clone();
            finalUserIds.removeAll(existingResourceIds);
            if(!finalUserIds.isEmpty()) {
                createServiceResource(finalUserIds);
            }
        }
        //Added by Ankit - IBA-46 - End

        if(!newList.isEmpty()){
            map<id,Boolean> mapUserStatus = new map<Id,boolean>();
            for(User us : newlist){
                if(us.IsActive != oldmap.get(us.id).IsActive){
                    mapUserStatus.put(us.id,us.IsActive);
                }
            }
            if(!mapUserStatus.isEmpty()){
                String accid = System.label.PRG_Account_Id;
                System.debug('accid'+accid);
                List<Contact> lstcon = [SELECT Id, Name, Created_From_User__c, Employee_Status__c 
                                        FROM Contact 
                                        WHERE AccountId = :accid 
                                        AND Created_From_User__c IN :mapUserStatus.keyset()];
                if(!lstcon.isEmpty()){
                    for(Contact ct : lstcon){
                        ct.Employee_Status__c = mapUserStatus.get(ct.Created_From_User__c) != null ? mapUserStatus.get(ct.Created_From_User__c) :  ct.Employee_Status__c;
                    }
                    String serialisedConlist= Json.serialize(lstcon);
                    updateContact(serialisedConlist);
                }
            }
            
        }
         //Added by Rajat for the Bug BN-00003535 - Start
        if(tsmap.get(replaceInactiveUserOnFPRAMStr) != null 
           && tsmap.containsKey(replaceInactiveUserOnFPRAMStr) 
           && tsmap.get(replaceInactiveUserOnFPRAMStr).Execute__c 
           && !TriggerUtility.isInactiveUserReplaced()){
            replaceInactiveUserWithManagerAsRAM(newList, oldmap);
        }
        //Added by Rajat for the Bug BN-00003535 - End

        TriggerUtility.UserAfterUpdateExecuted();
    }

    @future
    public static void updateContact(String serialisedConlist){
        List<Contact> conList = (List<Contact>) JSON.deserialize(serialisedConlist, List<Contact>.class);
        update conList;
    }

    //Added by Rajat for the Bug BN-00003535 - Start
    @TestVisible
    private static void replaceInactiveUserWithManagerAsRAM(List<User> newList, Map<Id, User> oldmap){
        Set<Id> inActiveUserIdSet = new Set<Id>();
        for(User newUser : newList){
            if(newUser.isActive == false){
            	User oldUser = oldMap.get(newUser.Id);
                if(newUser.Id == olduser.Id && oldUser.isActive == true){
					inActiveUserIdSet.add(newUser.Id);
				}
            }
    	}
        if(!inActiveUserIdSet.isEmpty()){
            FocusPartnerMasterTriggerHelper.replaceInactiveUserWithManagerAsRam(inActiveUserIdSet);
        }
    } 
    //Added by Rajat for the Bug BN-00003535 - End
    
    public static void updateSkillsforUsers(List<User> newlist, Map<Id, User> oldmap){
        Map<Id, User> serviceUsers = new Map<Id, User>();
        Map<String, ServiceResource> srmap = new Map<String, ServiceResource>();
        //Map<String, ServiceResource> srmapinactive = new Map<String, ServiceResource>();
        Set<String> srsetinactive = new Set<String>();
        Set<Id> skillstodelete = new set<Id>();
        Map<Id,User> usersneedsnewSkillResource = new Map<Id,User>();
        for(ServiceResource sr : [SELECT Id, RelatedRecordId, isActive 
                                    FROM ServiceResource 
                                    WHERE RelatedRecordId IN :newlist]){
            srmap.put(sr.RelatedRecordId, sr);
            if(!sr.isActive){
                srsetinactive.add(sr.Id);
            }
        }
        for(USer u: newlist){
            if((u.UserPermissionsSupportUser 
                    && u.UserPermissionsSupportUser != oldmap.get(u.Id).UserPermissionsSupportUser) 
                || (u.Skills__c != null 
                    && u.Skills__c != oldmap.get(u.Id).Skills__c)                     
                    && u.Service_Level__c != 'TAM'){
                serviceUsers.put(u.id, u);
                if(srmap.containsKey(u.Id)){
                    skillstodelete.add(u.Id);
                }else{
                    usersneedsnewSkillResource.put(u.Id, u);
                }
            }
        }
        if(!skillstodelete.isEmpty()){
            deleteSkillsforUsers(skillstodelete);
        }

        if(!usersneedsnewSkillResource.isEmpty()){           
            ServicecreateServiceResources(usersneedsnewSkillResource.keyset());            
        }
        
        if(!srsetinactive.isEmpty()){
            updateSRtoActive(srsetinactive);
        }

        if(srmap != null && !srmap.isEmpty()){
            createserviceResourceSkill(serviceUsers, srmap);
        }
        TriggerUtility.UserSkillAssignmentUpdateExecuted();
    }
    
    @future
    public static void ServicecreateServiceResources(Set<Id> userIds){
        final String METHOD_NAME = 'ServicecreateServiceResources';
        try{
            List<String> successList = new List<String>();
            Map<String, Service_Team_to_Skill_Map__c> tsmap = Service_Team_to_Skill_Map__c.getAll();
            Map<String, ServiceResource> srmap = new Map<String, ServiceResource>();
            Map<Id, User> usermap = new Map<Id,User>([SELECT Id,FirstName,LastName,Skills__c FROM User WHERE Id IN :userIds]);
            Map<String, User> userToProfileMap = new Map<String, User>([SELECT Id, Profile.Name FROM User WHERE Id IN:(usermap.keyset())]);
            List<String> profileTACList = Label.TAC_Profile_List.split(GCSCommonConstants.COMMA_STRING);
            
            for(User u: usermap.values()){
                if(tsmap != null && u.Skills__c != null){
                    string profileName = userToProfileMap.get(u.Id).Profile.Name;
                    
                    ServiceResource sr = new ServiceResource(IsActive = true);
                    sr.Name = 'Agent - ' + u.FirstName + ' ' + u.LastName;
                    sr.RelatedRecordId = u.Id;
                    sr.ResourceType = 'A';
                    sr.IsPrimary = profileTACList.contains(profileName)? true : false;

                    if(u.Skills__c.contains('Backline')){
                        sr.Type__c = 'Backline';
                    }
                    else if(u.Skills__c.contains('Frontline')){
                        sr.Type__c = 'Frontline';
                    }
                    srmap.put(u.Id, sr);
                }
            }
            if(!srmap.isEmpty()){
                //Insert srmap.values();
                List<Database.SaveResult> srList = Database.insert(srmap.values(), false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME,GCSCommonConstants.EMPTY_STRING);

                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        successList.add(sr.getId());
                    }                    
                }

                if(!successList.isEmpty()){
                    createserviceResourceSkill(usermap, srmap);
                }
            }        
        }Catch(Exception e){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }        
    }

    @Future
    public static void updateSRtoActive(Set<String> srSet){
        List<ServiceResource> srListToUpdate = new List<ServiceResource>();
        for(ServiceResource sr: [SELECT Id, IsActive FROM ServiceResource WHERE Id IN: (srSet)]){
            sr.isActive = true;
            srListToUpdate.add(sr);
        }
        update srListToUpdate;
    }

    public static void createserviceResourceSkill(Map<Id, User> usrmap, Map<String, ServiceResource> srmap){
        Map<String, Service_Team_to_Skill_Map__c> tsmap = Service_Team_to_Skill_Map__c.getAll();
        Map<String, Id> skillmap = new Map<String, Id>();
        for(Skill sk: [SELECT Id, DeveloperName FROM Skill]){
            skillmap.put(sk.DeveloperName, sk.id);
        }
        Map<String, ServiceResourceSkill> srslst = new Map<String, ServiceResourceSkill>();
        for(user u: usrmap.values()){
            if(tsmap != null && u.Skills__c != null){
                for(String s: u.Skills__c.split(';')){
                    String uskill = s.trim();
                    if(tsmap.containsKey(uskill) && tsmap.get(uskill).Skill__c != null){
                        for(String skill: tsmap.get(uskill).Skill__c.split(';')){
                            if(skill != null && !srslst.containskey('' + u.Id + skillmap.get(skill))){
                                ServiceResourceSkill srs = new ServiceResourceSkill(EffectiveStartDate = date.today().adddays(-1));
                                srs.ServiceResourceId = u.Id != null && srmap.containsKey(u.Id) && srmap.get(u.Id) != null ? srmap.get(u.Id).Id : null;
                                srs.SkillId = skill != null && skillmap.containsKey(skill) ? skillmap.get(skill): null;
                                srslst.put('' + u.Id + srs.SkillId, srs);
                            }
                        }
                    }
                }
            }
        }
        if(!srslst.isEmpty()){
            insert srslst.values();
        }
    }

    public static void deleteSkillsforUsers(Set<Id> userids){
        if(!userids.isEmpty()){
            delete [Select Id from serviceResourceSkill where ServiceResource.RelatedRecordId in :userids];
        }
    }

    /**
     * TAM Routing Implementation
     * Added by : Ankit Bhatnagar
     * Description : Create a Service Resource record every time a user record(Support Profiles) is created.
     * Modified By : Bhagyalaxmi Deshmukh (IBA-5913 Scheduler Data Remodeling)
     */
    @future
    public static void createServiceResource(Set<Id> userSetIds) {
        final String METHOD_NAME = 'createServiceResource';
        try{
            List<String> profileNames = new List<String>();
            if(String.isNotBlank(Label.ProfileNamesForServiceAgentInfo)){
                profileNames = Label.ProfileNamesForServiceAgentInfo.trim().split(',');
            }
            Map<Id, Profile> profMap = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name IN :profileNames]);        
            List<ServiceResource> resourceList = new List<ServiceResource>();
            for(User u : [SELECT Id, FirstName, LastName, ProfileId, Service_Level__c FROM User WHERE Id IN :userSetIds AND service_Level__c = :GCSCommonConstants.USER_SERVICE_LEVEL_TAM]) {
                if(profMap.containsKey(u.profileId) && String.isNotBlank(u.Service_Level__c)) {
                    //Service Resource added for IBA-5913 (replacing Service_Agent_Information__c object) by Bhagyalaxmi
                    resourceList.add(new ServiceResource(
                        Name = u.FirstName + ' ' + u.LastName,
                        RelatedRecordId = u.id,
                        Type__c = GCSCommonConstants.SERVICE_RESOURCE_TYPE_TAM,
                        Daily_Quota__c = GCSCommonConstants.INTEGER_1,
                        Backlog__c = GCSCommonConstants.INTEGER_0,
                        Weekly_Quota__c = GCSCommonConstants.INTEGER_5,
                        ResourceType = GCSCommonConstants.SERVICE_RESOURCE_RESOURCETYPE_A,
                        IsActive = true
                    ));               
                }
            }        

            if(!resourceList.isEmpty()) {                
                List<Database.SaveResult> srList = Database.insert(resourceList, false);
                GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME,GCSCommonConstants.EMPTY_STRING);
            }
        }Catch(Exception e){
            //Database.insert(GCSCommonUtility.prepareZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName()));
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }

    @future
    public static void createContactOnUserCreation( Set<Id> userSetIdst){
        List<Contact> conList= new List<Contact>();
        String zscIntAcc = System.Label.Zscaler_Internal_Account;
        Id internalAccountId = [SELECT Id FROM Account WHERE name = :zscIntAcc].Id;
        List<User> userList = [SELECT Id, Firstname, Lastname, Email FROM User WHERE Id IN :userSetIdst];
        for(User u : userList){
            Contact con = new Contact();
            con.firstName = u.firstName;
            con.lastname=u.lastname;
            con.email=u.email;
            con.Created_From_User__c=u.id;
            con.AccountId=internalAccountId;
            con.Employee_Status__c=true;
            conList.add(con);
        }
        if(!conList.isEmpty()){
            insert conList;
        }
    }
}