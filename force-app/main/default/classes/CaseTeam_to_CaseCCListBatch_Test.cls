@istest
public class CaseTeam_to_CaseCCListBatch_Test {
    @IsTest
    static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        
        Test.startTest();
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        String teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
        CaseTeamMember ct = new CaseTeamMember(parentid=cs.id, memberid=Userinfo.getuserid(), teamroleid=teamRoleId);
        insert ct;
        user usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        CaseTeamMember ct2 = new CaseTeamMember(parentid=cs.id, memberid=usr.Id, teamroleid=teamRoleId);
        insert ct2;
        CaseTeam_to_CaseCCListBatch batch;
        batch = new CaseTeam_to_CaseCCListBatch('Select Id, Internal_CC_List__c, Customer_CC_List__c from Case limit 1', false);
        batch.errorlst.add('abc');
        batch.successlst.add('abc');
        Database.executeBatch(batch,200);
        Test.stopTest();
        CaseTeam_to_CaseCCListBatch.runningInASandbox();
        
        
    }
}