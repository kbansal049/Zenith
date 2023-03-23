@isTest
public class UpdateOpptyShowInImpartnerBatchTest {
    
    @isTest
    public static void testUpdateOpptyShowInImpartnerBatch(){
        ZscalerSetting__c setting = new ZscalerSetting__c(Name = 'UpdateOpportunityShowInImpartnerSize',value__c = '200');
        insert setting;
        
        String recType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.Renewal_Opportunity).getRecordTypeId();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        List<Opportunity> opptyToInsert = new List<Opportunity>();
        opportunity opp = new opportunity(Name = 'Test opportunity 1', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365',Contract_End_Date_New__c = null,
                                          RecordTypeId  = recType);
        opptyToInsert.add(opp);
        
        opp = new opportunity(Name = 'Test opportunity 2', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365', Contract_End_Date_New__c = Date.valueOf('2021-3-5'),
                                          RecordTypeId  = recType);
        opptyToInsert.add(opp);
        
        opp = new opportunity(Name = 'Test opportunity 2', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment, 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365', Contract_End_Date_New__c = Date.valueOf('2021-6-3'),
                                          RecordTypeId  = recType);
        opptyToInsert.add(opp);
        
        insert opptyToInsert;
        
        Deal_Reg__c reg = new Deal_Reg__c(Renewal_Opportunity__c = opptyToInsert[0].Id);
        TriggerUtility.DealRegBeforeInsertExecuted();
        TriggerUtility.DealRegAfterInsertExecuted();
        insert reg;
        
        opptyToInsert[0].Deal_Reg__c = reg.Id;
        update opptyToInsert;
        
        Test.StartTest();
        UpdateOpportunityShowInImpartnerSchedule sh1 = new UpdateOpportunityShowInImpartnerSchedule();
        String sch = '0 6 * * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
        Test.StopTest(); 
        
        
        
    }

}