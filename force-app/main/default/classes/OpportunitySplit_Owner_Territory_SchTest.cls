@ISTest
public class OpportunitySplit_Owner_Territory_SchTest {
    
    public static testmethod void opportunitysplitcoverage(){
        
        //End User
        Account a = new Account();
        a.Name = 'test acc';
        a.Type='Prospect';
        a.RecordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        insert a;    
        
        opportunity oppobj  = new opportunity();
        oppobj.Name = 'Test Opp';
        oppobj.StageName = Label.Stage_5_Contracts_Complete;
        oppobj.CloseDate = system.today();
        oppobj.AccountId = a.Id; 
        insert oppobj;
        
        Id overlayOpportunitySplitTypeId = [ SELECT Id, MasterLabel FROM OpportunitySplitType WHERE MasterLabel = 'Overlay' ].Id;
        
        OpportunitySplit oppSplitObj = new OpportunitySplit(); 
        oppSplitObj.OpportunityId = oppobj.Id;
        oppSplitObj.SplitOwnerId = [select OwnerId from Opportunity where Id=:oppobj.Id][0].OwnerId;
        oppSplitObj.SplitPercentage = 100;
        oppSplitObj.SplitTypeId = overlayOpportunitySplitTypeId;
        oppSplitObj.Owner_Sales_Territory__c=Null;
        insert oppSplitObj;
        //opportunitySplitToInsert.add( oppSplitObj );
        
        PatchTeam__c PatchTeamobj = new PatchTeam__c();
		PatchTeamobj.Sales_Territory_Year__c='Current';
        Insert PatchTeamobj;
		
		PatchTeamMember__c PatchTeamMemberobj = new PatchTeamMember__c();
        PatchTeamMemberobj.User__c=oppSplitObj.SplitOwnerId;
        PatchTeamMemberobj.PatchTeam__c = PatchTeamobj.Id;
        insert PatchTeamMemberobj;
        
        test.startTest();
        
        OpportunitySplit_Owner_Territory_Sch OpportunitySplit_Owner_Territory_Schobj = new OpportunitySplit_Owner_Territory_Sch();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, OpportunitySplit_Owner_Territory_Schobj);
        
        Test.stopTest();  
        
        
    }

}