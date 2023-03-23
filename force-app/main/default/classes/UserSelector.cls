/**
 * @description       : This class will contains over loaded selector methods User object
 * @author            : Ram Sangati
 * @last modified on  : 01-15-2023
 * @last modified by  : Ram Sangati
**/
public without sharing class UserSelector {
    /**
     * This method is used to retrieve list of User records with given fields and filter criteria
     * @param  listOfUserId     List of user id's
     * @param  listOfProfileId  List of profile id's
     * @param  returningDate    Returning_date__c field value
     * @return                  List of Users
     */
    public static List<User> getUsers(List<Id> listOfUserId, List<Id> listOfProfileId, Date returningDate){
        System.debug('3030 ===>> Entered into 1st getUsers() ...!!');
        System.debug('3030(A) ===>> listOfUserId val is: ' + listOfUserId);
        System.debug('3030(B) ===>> listOfProfileId val is: ' + listOfProfileId);
        System.debug('3030(C) ===>> returningDate val is: ' + returningDate);
        if(!listOfUserId.isEmpty()){
            if(!listOfProfileId.isEmpty() && returningDate == null){
                return [SELECT Id, Name, Email, ManagerId, Manager.Email, TimeZoneSidKey, Skills__c FROM User WHERE isActive = true AND Id IN :listOfUserId AND profileId IN :listOfProfileId];
            }else if(listOfProfileId.isEmpty() && returningdate != null){
                return [SELECT Id, Name, Email, ManagerId, Manager.Email, TimeZoneSidKey, Skills__c FROM User WHERE isActive = true AND Id IN :listOfUserId AND Out_Of_office__c = true AND Returning_date__c > :returningDate];
            }else{
                return [SELECT Id, Name, Email, ManagerId, Manager.Email, TimeZoneSidKey, Skills__c FROM User WHERE isActive = true AND Id IN :listOfUserId];
            }
        }else if(!listOfProfileId.isEmpty()){
            return [SELECT Id, Name, Email, ManagerId, Manager.Email, TimeZoneSidKey, Skills__c FROM User WHERE isActive = true AND profileId IN :listOfProfileId];
        }else{
            return new List<User>();
        }
    }
    
    /**
     * This method is used to retrieve list of User records with given fields and filter criteria
     * @param  setOfUserId Set of user id's
     * @param  isSkillNull Is Skill should be check or not?
     * @return           List of Users
     */
    public static List<User> getUsers(Set<Id> setOfUserId, Boolean isSkillNull){
        System.debug('3131 ===>> Entered into 2nd getUsers() ...!!');
        System.debug('3131(A) ===>> setOfUserId val is: ' + setOfUserId);
        System.debug('3131(B) ===>> isSkillNull val is: ' + isSkillNull);
        if(!setOfUserId.isEmpty() && isSkillNull){
            return [SELECT Id, Name, Email, ManagerId, Manager.Email, TimeZoneSidKey, Skills__c FROM User WHERE isActive = true AND Id IN :setOfUserId AND Skills__c != null];
        }else if(!setOfUserId.isEmpty()) {
            return [SELECT Id, Name, Email, ManagerId, Manager.Email, TimeZoneSidKey, Skills__c FROM User WHERE isActive = true AND Id IN :setOfUserId];
        }else{
            return new List<User>();
        }
    }
    
    /**
     * This method is used to retrieve list of User records with given fields and filter criteria
     * @param  fields        fields
     * @param  whereClause   whereClause
     * @param  orderByClause orderByClause
     * @param  limitClause   limitClause
     * @return               List of User / null
     */
    public static List<User> getUsers(String fields, String whereClause, String orderByClause, Integer limitClause){
        System.debug('3232 ===>> Entered into 3rd getUsers() ...!!');
        List<User> userList = new List<User>();
        String soql = GCSCommonUtility.getSOQL('User', fields, whereClause, orderByClause, limitClause);
        System.debug('3232(B) ===>> User soql val is: ' + soql);
        if(String.isNotBlank(soql)){
            userList = Database.query(soql);
        }
        System.debug('3232(C) ===>> userList val is: ' + userList);
        return userList;
    }
}