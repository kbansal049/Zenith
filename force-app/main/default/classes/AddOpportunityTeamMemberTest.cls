@isTest
public class AddOpportunityTeamMemberTest {

    @testSetUp
    static void dataSetUp(){
        
          Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30));
        insert account;
        
       opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '	1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
    } 

    @IsTest static void testOppTeamMember(){

        User usrToExecute = [Select id from USer where profile.Name like 'System Administrator' and isActive = true limit 1];
        Test.startTest();
        System.runAs(usrToExecute){
            Opportunity opp = [Select id from Opportunity where name like 'Test opportunity' limit 1];
            AddOpportunityTeamMember.checkIfItsAllowed(opp.id);

            AddOpportunityTeamMember.LWCWrapper lwc = new AddOpportunityTeamMember.LWCWrapper();
            User usr = [Select id from USer where profile.Name = 'Core Sales - SE' and isActive = true limit 1];
            String str = '[{"Index":0,"oppId":"'+ opp.id+'","user":"'+ UserInfo.getUserId()+'","tagList":"TAG Member - ZDX","unfinished":false},{"Index":1,"oppId":"'+ opp.id+'","user":"'+ usr.id+'","tagList":"TAG Member - ZDX","unfinished":false}]';
            AddOpportunityTeamMember.createOpportunityTeamMember(str);
            AddOpportunityTeamMember.fetchMetaData();
            OpportunityTeamMember otm = [Select id from OpportunityTeamMember where OpportunityId = :opp.id and UserId = :usr.id];
            AddOpportunityTeamMember.deleteOppTeamMember(otm.id);
            List<OpportunityTeamMember> otmList = AddOpportunityTeamMember.fetchAllOppTeamMembers(opp.id);
            AddOpportunityTeamMember.saveOppTeamMember(otmList.get(0).id, usr.id, 'Account Manager', 'TAG Member - ZDX');
            AddOpportunityTeamMember.createOpportunityTeamMember(str);
            
        
        }
        Test.stopTest();
        
    }
    
    
     @IsTest static void testOppTeamMember4(){

        User usrToExecute = [Select id from USer where profile.Name like 'System Administrator' and isActive = true limit 1];
        Test.startTest();
        System.runAs(usrToExecute){
            Opportunity opp = [Select id from Opportunity where name like 'Test opportunity' limit 1];
            AddOpportunityTeamMember.checkIfItsAllowed(opp.id);

            AddOpportunityTeamMember.LWCWrapper lwc = new AddOpportunityTeamMember.LWCWrapper();
            User usr = [Select id from USer where profile.Name = 'Core Sales - SE' and isActive = true limit 1];
            String str = '[{"Index":0,"oppId":"'+ opp.id+'","user":"'+ UserInfo.getUserId()+'","tagList":"TAG Member - ZDX","unfinished":false},{"Index":1,"oppId":"'+ opp.id+'","user":"'+ usr.id+'","tagList":"TAG Member - ZDX","unfinished":false}]';
            AddOpportunityTeamMember.createOpportunityTeamMember(str);
            AddOpportunityTeamMember.fetchMetaData();
            OpportunityTeamMember otm = [Select id from OpportunityTeamMember where OpportunityId = :opp.id and UserId = :usr.id];
            AddOpportunityTeamMember.deleteOppTeamMember(otm.id);
            List<OpportunityTeamMember> otmList = AddOpportunityTeamMember.fetchAllOppTeamMembers(opp.id);
            AddOpportunityTeamMember.saveOppTeamMember(null, null, 'Account Manager', 'TAG Member - ZDX');
            AddOpportunityTeamMember.createOpportunityTeamMember(str);
            
        
        }
        Test.stopTest();
        
    }
    
  
    
    @IsTest static void testOppTeamMember3(){

       // User usrToExecute = [Select id from USer where profile.Name like 'System Administrat' and isActive = true limit 1];
        Test.startTest();
        // User usrToExecute = [Select id from USer where profile.Name = 'Core Sales - SE' and isActive = true limit 1];
      // System.runAs(usrToExecute){
            Opportunity opp = [Select id from Opportunity where name like 'Test opportunity' limit 1];
            AddOpportunityTeamMember.checkIfItsAllowed(opp.id);

            AddOpportunityTeamMember.LWCWrapper lwc = new AddOpportunityTeamMember.LWCWrapper();
           User  usr = [Select id from USer where profile.Name = 'Core Sales - SE' and isActive = true limit 1];
            String str = '[{"Index":0,"oppId":"'+ opp.id+'","user":"'+ UserInfo.getUserId()+'","tagList":"TAG Member - ZDX","unfinished":false},{"Index":1,"oppId":"'+ opp.id+'","user":"'+ usr.id+'","tagList":"TAG Member - ZDX","unfinished":false}]';
            AddOpportunityTeamMember.createOpportunityTeamMember(str);
            AddOpportunityTeamMember.fetchMetaData();
            OpportunityTeamMember otm = [Select id from OpportunityTeamMember where OpportunityId = :opp.id and UserId = :usr.id];
            AddOpportunityTeamMember.deleteOppTeamMember(otm.id);
            List<OpportunityTeamMember> otmList = AddOpportunityTeamMember.fetchAllOppTeamMembers(opp.id);
            AddOpportunityTeamMember.saveOppTeamMember(otmList.get(0).id, usr.id, 'Account Manager', 'TAG Member - ZDX');
            AddOpportunityTeamMember.createOpportunityTeamMember(str);
            
        
       // }
        Test.stopTest();
        
    }

}