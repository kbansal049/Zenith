@isTest
public class LegalTriggerHandlerTest {

  @isTest static void test(){
        test.starttest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
		
		Triggers_Switch__c ts1 = new Triggers_Switch__c(Name='LegalUpdateSalesOrder',Execute__c=true);
		insert ts1;
		
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        TriggerUtility.realignPatchReset();
        insert opp;

        Legal__c LE= new Legal__c(Opportunity__c=opp.id,Contract_Type__c='EUSA',Initial_Request_Date__c=system.Today());
        
        insert LE;
        Legal__c LE1= new Legal__c(Opportunity__c=opp.id,Contract_Type__c='Test',Initial_Request_Date__c=system.Today());
        LegalTriggerHandler.UpdateSalesOrder(new List<Legal__c>{LE1,LE});
        system.debug('CE '+LE);

        test.stoptest();
    }

}