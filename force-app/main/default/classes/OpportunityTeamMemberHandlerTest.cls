@isTest
public class OpportunityTeamMemberHandlerTest{
    
    static testmethod void test1(){
        List<user> users = [select id from user where IsActive = true AND Profile.Name = 'System Administrator' ];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment , CloseDate = system.Today()+30);
        insert opp;
        
        List<OpportunityTeamMember> opptyMember = new List<OpportunityTeamMember>();
        OpportunityTeamMember mem = new OpportunityTeamMember();
        mem.OpportunityId = opp.Id;
        opptyMember.add(mem);
        
        OpportunityTeamMemberHandler handler = new OpportunityTeamMemberHandler();
        handler.afterInsert(opptyMember);
        handler.afterDelete(opptyMember);
    }
    
}