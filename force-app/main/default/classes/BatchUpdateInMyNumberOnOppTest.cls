@isTest
public class BatchUpdateInMyNumberOnOppTest {
    
    @testSetup 
    static void setup() {
         Account acc = new Account();
       acc.Name='testacc';
       acc.Type ='Prospect';
       insert acc;
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
         Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
         opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id,Type='New Business' ,StageName =  label.Stage_6_Closed_Won,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Forecast_Category__c='Commit',Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        
         opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id,Type='Existing Customer(Renewals)' ,StageName =  label.Stage_6_Closed_Won,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                            CloseDate = system.Today()+30,Forecast_Category__c='Commit', Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
    
        insert opp;
       
        
      
              
    }
    
    @isTest static void testMethod1() {
        Database.executeBatch(new BatchUpdateInMyNumberOnOpp(),1);
        
        BatchUpdateInMyNumberOnOpp m = new BatchUpdateInMyNumberOnOpp();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('CFQ Upd', sch, m);
        
    }
    
     
   


}