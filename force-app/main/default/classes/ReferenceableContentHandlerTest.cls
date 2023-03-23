//Added by Ayush Kangar as part of CR#4238 - Start
@IsTest 
private class ReferenceableContentHandlerTest {
    @isTest
    private static void UpdateFieldsFromAccountsTest() {
        Account acc = new Account(Name = 'Test Account',
                                  Type='Prospect',
                                  BillingCountry = '',
                                  BillingState = '',
                                  BillingPostalCode = '',
                                  Domain__c = '',
                                  Industry = 'Advertising',
                                  Market_Segment__c = '',
                                  Platform_deployed__c = 'Business Web Suite');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity',
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_6_Closed_Won,
                                          Competitors__c='iBoss',
                                          ZPA_Competitor__c='F5',
                                          CloseDate = system.Today()+30);
        insert opp;
        Account acc2 = new Account(Name = 'Test Account2',
                                   Type='Prospect',
                                   BillingCountry = '',
                                   BillingState = '',
                                   BillingPostalCode = '',
                                   Domain__c = '',
                                   Industry = 'Advertising',
                                   Market_Segment__c = '',
                                   Platform_deployed__c = 'ZIA Secure Transformation Bundle');
        insert acc2;
        crwd__Evidence__c ref = new crwd__Evidence__c(crwd__EvidenceAccount__c=acc.id);
        insert ref;
        ref.crwd__EvidenceAccount__c=acc2.id;
        update ref;
    }
}
//Added by Ayush Kangar as part of CR#4238 - End