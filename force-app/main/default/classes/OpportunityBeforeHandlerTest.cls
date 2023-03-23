@isTest
public class OpportunityBeforeHandlerTest {
    
    @testSetUp
    static void data(){
        
          Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),BillingCity = 'San Jose',
                                      BillingCountry = 'United States',
                                      BillingPostalCode = '95134',
                                      BillingState = 'California',
                                      BillingStreet = '110 Rose Orchard Way');
        insert account;
        
       opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          contract_end_date_new__c = date.today().adddays(65),StageName = '1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
    } 
    
static testMethod void run(){
       
           Opportunity opp = [Select ID,StageName,Amount FROM Opportunity LIMIT 1 ]; 
            opp.Amount = 500000;
    		opp.StageName = Label.Stage_2_Qualified_Budgeted;
            update opp;
        
         
        /* List<Opportunity> oppList =  new List<Opportunity>();
         oppList.add(opp);
         OpportunityBeforeTriggerHandler.getOppAccMap(oppList);*/
}

static testMethod void testSetDefaultOpportunityStage(){
    String profileId = [SELECT Id FROM Profile WHERE Name=: Label.Profiel_Core_Sales_LDR][0].Id;
    User SDR_User = createUser(profileId, 'SDR User');
    system.runAs(SDR_User){
        Account account = new Account(Name = 'Test Account2',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),BillingCity = 'San Jose',
                                      BillingCountry = 'United States',
                                      BillingPostalCode = '95134',
                                      BillingState = 'California',
                                      BillingStreet = '110 Rose Orchard Way');
        insert account;
        
       opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          contract_end_date_new__c = date.today().adddays(65),StageName = Label.Stage_1_Alignment,
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        try{
            insert opp;

        Opportunity oppRec = [SELECT Id,StageName FROM Opportunity WHERE Id=: opp.Id];
        system.assertEquals(oppRec.StageName, Label.Stage_0_Pipeline_Generation);
    
        }catch(exception e){
            system.debug('--exception--'+e.getMessage());
        }
   }
        
  
 
}

public static User createUser(Id profileId, String lastName){        
    String orgId=UserInfo.getOrganizationId(); 
    String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
    Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
    String uniqueName=orgId+dateString+RandomId; 
    User uu=new User(firstname = 'test', 
                     lastName = lastName, 
                     email = uniqueName + '@test' + orgId + '.org', 
                     Username = uniqueName + '@test' + orgId + '.org', 
                     EmailEncodingKey = 'ISO-8859-1', 
                     Alias = uniqueName.substring(18, 23), 
                     TimeZoneSidKey = 'America/Los_Angeles', 
                     LocaleSidKey = 'en_US', 
                     LanguageLocaleKey = 'en_US', 
                     ProfileId = profileId
                    );        
    
    insert uu;
    return uu;
}

}