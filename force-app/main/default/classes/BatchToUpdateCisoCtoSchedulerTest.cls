@isTest
public class BatchToUpdateCisoCtoSchedulerTest {
    @testSetup
    static void setup() {
        
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='AMERICAS';
        pateam.Region__c ='AMS Central LE+';
        pateam.Area__c ='Canada';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=pateam.Id, Role__c='acme', User__c=UserInfo.getUserId());
        insert member;
        
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=pateam.Id);
        insert patch;
        
        Account acc =new Account(Name='acme acc');
        Insert acc;
        acc.Patch__c = patch.Id;
        acc.PatchLocked__c = true;
        update acc;
        
        CTO_CISO_Transformation_Team_Member__c a = new CTO_CISO_Transformation_Team_Member__c();
        a.Area__c = 'AMS Central LE+';
        a.Linked_CISO_Team_Member__c = '0054u00000624oEAAQ';
        a.type__c = 'Field CISO';
        insert a;
        CTO_CISO_Transformation_Team_Member__c b = new CTO_CISO_Transformation_Team_Member__c();
        b.region__c = 'Canada';
        b.Linked_CTO_Team_Member__c = '0054u00000755SmAAI';
        b.type__c = 'Field CTO';
        insert b;
        
    }  
    static testMethod void testAccountPostPatch(){
            Test.startTest();
            String query = 'Select Id,Account__r.Region__c,Account__r.Area__c from Account_Extension__c';
            BatchToUpdateCisoCtoOnAccountExtention accExt = new BatchToUpdateCisoCtoOnAccountExtention(query);
            Database.executeBatch(accExt,1);
    }
    public static testMethod void testschedule() {
		Test.StartTest();
		BatchToUpdateCisoCtoScheduler testsche = new BatchToUpdateCisoCtoScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}