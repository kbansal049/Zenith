@istest
public class EgressLocationPageControllerTest {
    @testSetup
    static void makeData()
    {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type='Prospect');
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 200000,
                                          CloseDate = system.Today().addDays(+30),
                                          StageName = Label.Stage_2_Qualified_Budgeted,
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() , SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        Egress_Location__c EgressLoc = new Egress_Location__c(Name = 'Test',Egress_Location__c = opp.Id, Account__c=account.Id, Internet_Egree_Location__c = 'Test',Egress_Location_Country__c = 'USA',Number_of_users__c = 10,Nearest_Zscaler_Datacenter__c = 'Abu Dhabi');
        insert EgressLoc;
    }
    
    public Static testMethod void EgrStndControllerTest(){
        test.startTest();
		Opportunity optyObj=[Select id from Opportunity limit 1];
        Egress_Location__c egressLocObj = new  Egress_Location__c();
        egressLocObj=[select id from Egress_Location__c limit 1];
			ApexPages.StandardController sc = new ApexPages.StandardController(egressLocObj);
			EgressLocationPageController  testEgrLoc = new EgressLocationPageController(sc);
			EgressLocationPageController.getAccount(optyObj.Id);
		test.stopTest();
    }
}