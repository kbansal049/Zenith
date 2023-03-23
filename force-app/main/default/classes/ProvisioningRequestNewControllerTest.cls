@isTest
public class ProvisioningRequestNewControllerTest { 
    @isTest
    static void testCntrl(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, 
                                          StageName = Label.Stage_1_Alignment, CloseDate = system.Today()+30);
        insert opp;
        Test.startTest();
        ProvisioningRequestNewController.getRecTypeId('FeVa Cloud');
        ProvisioningRequestNewController.fetchRecordTypeValues();        
        ProvisioningRequestNewController.getUserRole();
        ProvisioningRequestNewController.getOpp(opp.Id);
        Test.stopTest();
    }  
}