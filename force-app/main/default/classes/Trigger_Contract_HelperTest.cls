/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-14-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Trigger_Contract_HelperTest {
    
    @testSetup static void setup(){
    List<Account> testAccts = new List<Account>();        
        testAccts.add(new Account(Name = 'TestAcct1'));
        insert testAccts; 
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> listofSkuCustomSetting = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
		    SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zpaContractEndate = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zpaContractEndate.Name='ZPA_Contract_Date';
        zpaContractEndate.SKU_Codes__c='ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZPA-Remote-PRE;ZS-WFA-BUS-EDITION;ZPA-FED-BUNDLE;ZPA-ZFED-MODERATE';
        listofSkuCustomSetting.add(zpaContractEndate);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaContractEndate = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaContractEndate.Name='ZIA_Contract_Date';
        ziaContractEndate.SKU_Codes__c='ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP;ZIA-PRO-EDITION;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZIA-PRO-EDITION-LU;';
        listofSkuCustomSetting.add(ziaContractEndate);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaContractEndate1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaContractEndate1.Name='ZIA_Contract_Date1';
        ziaContractEndate1.SKU_Codes__c='ZIA-BUS-EDITION-LU;ZIA-TRANS-EDITION-LU;ZIA-ELA-EDITION-LU;ZSC-RET-KIOSK;Z-O365-PRE;ZS-WFA-BUS-EDITION;EDU-ZIA-SVC-EDGE-BUS;ZIA-FED-BUNDLE;ZIA-ZFED-MODERATE';
        listofSkuCustomSetting.add(ziaContractEndate1);
        insert listofSkuCustomSetting;
   
        Contract contract = new Contract(
        AccountId = testAccts[0].Id,  
        ContractTerm = 12,
        StartDate = Date.today(),
        EndDate = Date.today(),
        Migrated_Contract__c = true,
        Has_Non_Co_Termed_Lines__c = true);        
        insert contract;
            
     /* Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive = true,ProductCode = 'E03-SHR4-100');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;*/
        
        /*Account acc = new Account(Name='TestAccount');
        insert acc;

        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Suspect', Pricebook2Id=customPB.Id);
        insert opp;*/
 
       /* Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp1';
        opp.CloseDate = system.Today() + 30;
        opp.AccountId = testAccts[0].Id;
        opp.Amount = 123456;
        opp.Type = 'Existing Customer (Renewal)';
        opp.Forecast_Category__c = 'Best Case';
        opp.Stagename = 'Suspect';
        opp.Custom_Renewal__c = false;
        opp.SBQQ__RenewedContract__c = contract.Id;
        opp.Pricebook2Id = customPB.Id;
        insert opp;     
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 5, PricebookEntryId = customPrice.Id, TotalPrice = 500);
        insert oli;*/
        
     /* List<PriceBookEntry> pbes = [SELECT Id, PriceBook2Id, UnitPrice FROM PriceBookEntry WHERE IsActive  = true AND PriceBook2.isStandard = true];
        if(!pbes.isEmpty()){
            Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(1),
                PriceBook2Id = pbes[0].PriceBook2Id
            );
         insert opp;

        List<OpportunityLineItem> olis = new List<OpportunityLineItem >();
        for(PriceBookEntry pbe : pbes){
        olis.add(new OpportunityLineItem(
        UnitPrice = pbe.UnitPrice,
        Quantity = 1,
        OpportunityId = opp.Id,
        PriceBookEntryId = pbe.Id
        ));
        }
        insert olis;
        System.assertEquals([SELECT Count() FROM OpportunityLineItem WHERE OpportunityId =:opp.Id],pbes.size());*/
       

        Date cd = date.parse('10/10/2018');
        Opportunity o = new Opportunity();
        o.Name='opp1';
        o.AccountId = testAccts[0].Id;
        o.Amount = 123456;
        o.Type = 'Existing Customer (Renewal)';
        o.Forecast_Category__c = 'Best Case';
        o.Custom_Renewal__c = false;
        o.SBQQ__RenewedContract__c = contract.Id;
        o.CloseDate=cd;
        o.StageName='Needs Analysis';
        o.Pricebook2Id=Test.getStandardPricebookId();
        insert o;
        
        Pricebook2 pb = new Pricebook2(Name='Testbook');
        insert pb;
    
        Product2 p1 = new Product2();
        p1.Name='product1';
        p1.Family='Card Present';
        insert p1;
        
      // List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
    	SBQQ__Quote__c q1 = new SBQQ__Quote__c();
        q1.SBQQ__Opportunity2__c=o.id;
        q1.SBQQ__Account__c = testAccts[0].Id;
        q1.SBQQ__StartDate__c = cd.addDays(1);
        q1.SBQQ__EndDate__c = cd.addDays(10);
        q1.SBQQ__PriceBook__c = Test.getStandardPricebookId();
        q1.SBQQ__PricebookId__c = Test.getStandardPricebookId(); 
        insert q1;
        //  quoteList.add(q1);
        // q1.Shell_Quote__c = true;
        // update quoteList; */
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = p1.id,
            UnitPrice = 10000, 
            IsActive = true);
        insert standardPrice;
        
        SBQQ__QuoteLine__c objQline = new SBQQ__QuoteLine__c();
        objQline.SBQQ__Quote__c = q1.id;
        objQline.SBQQ__PricebookEntryId__c = standardPrice.Id; 
        objQline.SBQQ__Product__c = p1.id;
        objQline.SBQQ__Quantity__c = 5;
        objQline.SBQQ__Number__c = 10;
        // objQline.SBQQ__PricingMethod__c = ;
        // objQline.SBQQ__RenewedSubscription__c = objSub.Id;
        objQline.SBQQ__StartDate__c = cd.addDays(1);
        objQline.SBQQ__EndDate__c = cd.addDays(15);
        //objQline.SBQQ__ListPrice__c = objSub.SBQQ__ListPrice__c;
        insert objQline;
        
        SBQQ__Subscription__c sb = new SBQQ__Subscription__c(
            SBQQ__contract__c = contract.Id,
            Non_Co_Term_Line__c = true,
            SBQQ__Product__c = p1.id,    
            SBQQ__Quantity__c = 1,
            SBQQ__QuoteLine__c= objQline.id  
        );
        insert sb;
        
   /*   PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id=pricebookId;
        pbe.Product2Id=p1.id;
        pbe.UnitPrice=3000;
        pbe.UseStandardPrice=false;
        pbe.IsActive = true;
        
        insert pbe;
     OpportunityLineItem oli = new OpportunityLineItem();
        oli.Quantity=1;
        oli.UnitPrice=100;
        oli.OpportunityId=o.id;
        oli.PricebookEntryId=pbe.Id;
        oli.Quantity = 5;
        oli.SBQQ__QuoteLine__c = objQline.id;
        insert oli; */
    }
    
    private static testmethod void createCustomRenewalsMainTest(){   
        List<Contract> contract = [Select AccountId, ContractTerm, StartDate, EndDate, SBQQ__opportunity__c, Migrated_Contract__c, Has_Non_Co_Termed_Lines__c from Contract  LIMIT 1];        
		contract[0].Migrated_Contract__c = false;        
        Set<Id> contractId = new Set<Id>();
        contractId.add(contract[0].Id);
        Test.startTest();        
        	Trigger_Contract_Helper.createCustomRenewalsMain(contractId);
        Test.stopTest();
    }
     private static testmethod void Test1(){   
        List<Contract> contract = [Select AccountId, ContractTerm, StartDate, EndDate, SBQQ__opportunity__c, Migrated_Contract__c, Has_Non_Co_Termed_Lines__c from Contract  LIMIT 1];        
		contract[0].Migrated_Contract__c = false;        

        Test.startTest();        
        	Update contract;
        Test.stopTest();
    }
    
}