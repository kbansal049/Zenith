/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SkillJarGroupTriggerHelperTest
* @description      This is the test class for SkillJarGroup Trigger helper class
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
@isTest
public class SkillJarGroupTriggerHelperTest {

    @TestSetup
    static void prepareTestData() {
                
        Account testAccount = new account();
        testAccount.Name = 'Test Data';
        testAccount.Domain__c = 'abc.com';
        testAccount.Partner_Type__c = 'Partner-Reseller';
        testAccount.Sales_Engineer__c = UserInfo.getUserId();
        insert testAccount;
        
        skilljar__Group__c newGroup = new skilljar__Group__c ();
        newGroup.Name = testAccount.id;
        newGroup.skilljar__Skilljar_Id__c = '1naa6k6r3sl8';
        newGroup.skilljar__Name__c = testAccount.Id;
        insert newGroup;
    }
    
    @isTest static void testUpdateGroupIdOnAccount(){
        Account getAccount = [select id,name,SkillJar_Group_ID__c from Account limit 1];
        skilljar__Group__c getGroup = [select id,name,skilljar__Skilljar_Id__c,skilljar__Name__c from skilljar__Group__c limit 1];
    } 
}