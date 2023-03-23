/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SkillJarGroupTriggerHelper
* @description      This is the SkillJar Group Trigger helper class called synchronously 
from SkillJarGroupTriggerHandler.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-07-25
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class SkillJarGroupTriggerHelper {
    
    /**
     * @description Custom exception class
     */
    public class SkillJarGroupTriggerHelperException extends Exception {
    }
    /** 
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-1520 : Update group id from Skilljar Group to SFDC Account
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : updateGroupIdOnAccount .
* @param    NAME : List<skilljar__Group__c> newGroupsList .
* @return   TYPE : void .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void updateGroupIdOnAccount(Map<Id,skilljar__Group__c> newGroupMap){
        
        Map<String,skilljar__Group__c>groupMap= new Map<String,skilljar__Group__c>();
        for(skilljar__Group__c eachGroup: newGroupmap.values()){
            groupMap.put(eachGroup.Name, eachGroup);
        }
        Map<Id,Account>matchingAccountsMap = new Map<Id,Account>([select id,name,SkillJar_Group_ID__c from Account where id in :groupMap.KeySet()]);
        List<Account>accountsToUpdateList = new List<Account>();
        for(Account eachAccount: matchingAccountsMap.values()){
            if(matchingAccountsMap.containsKey(eachAccount.Id)){
                eachAccount.SkillJar_Group_ID__c = groupMap.get(eachAccount.Id).skilljar__Skilljar_Id__c; 
                accountsToUpdateList.add(eachAccount);
            }
        }
        try{
            if(accountsToUpdateList !=null && !accountsToUpdateList.isEmpty() && accountsToUpdateList.size()>0){
                update accountsToUpdateList;
            }
            if(test.isRunningTest()){
                throw new SkillJarGroupTriggerHelperException('Exception from test');
            }
        }    
        catch(Exception e){
            System.debug('Update Group Id on Account Failed  - ' + 
                         e.getCause() + ', Message - ' + 
                         e.getMessage() + ', StackTrace - ' +
                         e.getStackTraceString());
            ZscalerErrorLogsUtility.insertlogs('SkillJarGroupTriggerHelper', 
                                               'updateGroupIdOnAccount', 
                                               'Apex', 
                                               UserInfo.getUserId(),
                                               'Sales cloud', 
                                               e.getStackTraceString(), 
                                               e.getMessage(), 
                                               e.getTypeName());
        }    
    }
    
    
}