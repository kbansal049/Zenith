@isTest
public class EgressLocationRestServiceTest 
{
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

    @isTest static void methodName()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/EgressLocation/fullload';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        EgressLocationRestService.doGet();
        
    }
}