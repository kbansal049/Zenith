@isTest
public class Util_ChurnReasonMethods_Test {
    
    @TestSetup static void setuprecs(){
        TriggerUtility.prospectTypeUpdExecuted();
        Account acc = APTS_TestUtil.createAccount();
        Id RecordTypeIdContact = [SELECT Id FROM RecorDtype WHERE DeveloperName = 'Renewal_Opportunity'].Id;
        Opportunity opp = new Opportunity(RecordTypeId=RecordTypeIdContact, Name = 'test opp', 
                                          AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'Qualified'*/, CloseDate = Date.Today()
                                         );
        insert opp;

        
        Id productid = APTS_TestUtil.createProducts(1)[0].id;
        Id productid2 = APTS_TestUtil.createProducts(1)[0].id;
        Product2 prod = [SELECT Id,isBundle__c,IsActive FROM Product2 WHERE Id=: productid];
        prod.isBundle__c = true;
        prod.IsActive = true;
        prod.Zscaler_Product_Family__c = 'ZIA';
        update prod;
        List<PricebookEntry> lipri1 = new List<PricebookEntry>();
        try{
        Id pricebookId = Test.getStandardPricebookId();
        opp.Pricebook2Id = pricebookId;
        opp.Competitor__c='Barracuda';
        opp.Other_Competitors__c='Other';
        update opp;system.debug('TEST: '+opp.RecordTypeId);
        lipri1.add(new PricebookEntry(IsActive=TRUE,Pricebook2Id=pricebookId,
                                                Product2Id=productid,UnitPrice=100.0));
        lipri1.add(new PricebookEntry(IsActive=TRUE,Pricebook2Id=pricebookId, 
                                                Product2Id=productid2,UnitPrice=100.0));
        insert lipri1;
        }
        catch(Exception ex){
            system.debug('Exception Cathed for PriceBook'+ex);
        }
        
        PricebookEntry entry=new PricebookEntry(IsActive=TRUE,Pricebook2Id=opp.Pricebook2Id,
                                                Product2Id=productid,UnitPrice=100.0);
        
        List<PricebookEntry> lipri=new List<PricebookEntry>();
        lipri.add(entry);
        
        try{
            insert lipri;
            OpportunityLineItem oppol=new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=entry.Id);
            
            List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
            oppLineItems.add(oppol);
            
            insert oppLineItems;
        }
        catch(Exception ex){
            system.debug('Exception Cathed for PriceBook'+ex);
        }
        Significant_Customer_Interaction__c sig = new Significant_Customer_Interaction__c(Opportunity_Name__c=opp.Id);
        insert sig;
        Churn__c churn = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Churn', Opportunity__c =opp.Id,Competitor__c='Other',Other_Competitors__c='Test');
        insert churn;
        Churn__c churnLoss = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Loss', Opportunity__c =opp.Id);
        insert churnLoss;
        
    }
    
    static testmethod void testUtil(){
        Test.startTest();
        List<Account> acc = [Select Id from Account];
        List<Opportunity> opp = [Select Id,recordType.Name from Opportunity];
        String oppIdForMethod = opp[0].Id;
        Churn__c churn1 = [Select Id,Type__c,SCINumber__c from Churn__c Where Type__c='Churn' Limit 1];
        churn1.Competitor__c = 'No Vendor';
        update churn1;
        
        Churn__c churn = [Select Id,Type__c,SCINumber__c from Churn__c Where Type__c='Loss' Limit 1];
        List<Churn__c> churnList = [Select Id,Type__c,SCINumber__c from Churn__c Where Type__c='Loss' LIMIT 5];
        Significant_Customer_Interaction__c sciObj = [SELECT Id FROM Significant_Customer_Interaction__c 
                                                      WHERE Opportunity_Name__c =: opp[0].id];
        Apexpages.StandardController sc = new Apexpages.StandardController(opp[0]);
        Util_ChurnReasonMethods ctrlUtil = new Util_ChurnReasonMethods(sc);
        Util_ChurnReasonMethods.oppObj = opp[0];
        //Util_ChurnReasonMethods.gd = Schema.getGlobalDescribe().values();
        Util_ChurnReasonMethods.isActivePRpresentOnOpp(opp[0].Id);
        Util_ChurnReasonMethods.getSCIrecords(opp[0].Id);
        Util_ChurnReasonMethods.getDowngradeRecords();
        Util_ChurnReasonMethods.getSCIname(sciObj.Id);
        Util_ChurnReasonMethods.getSCI(opp[0].Id);
        Util_ChurnReasonMethods.getPicklistValues('Churn__c','Engagement_Primary_Reason__c');
        Util_ChurnReasonMethods.getSCIRecordTypes();
        Util_ChurnReasonMethods.getSearchSCIValues(opp[0].Id);
        //Util_ChurnReasonMethods.getProductRecords('Premium Support');
        Util_ChurnReasonMethods.isZPApresent(opp[0].Id);
        Util_ChurnReasonMethods.isZIApresent(opp[0].Id);
        Util_ChurnReasonMethods.getOpp(opp[0].Id);
        
        Util_ChurnReasonMethods.getOpportunityRecordType(opp[0].Id);
        Delete churnList;
        Test.stopTest();
    }

}