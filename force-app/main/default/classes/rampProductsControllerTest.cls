/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-15-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class rampProductsControllerTest {
    
    /**
    Variables declaration
    */
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static Opportunity opty;
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

    /**
    *  Description: method to create test data
    *  @name      : createTestData
    **/
    @testSetup static void createTestData(){        
        accList = (SB_TestCPQDataUtility.createAccount(2));
        insert accList;
        Test.startTest();
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        productList[0].Enable_Ramp__c = true;
        productList[1].Enable_Ramp__c = true;
        productList[2].Enable_Ramp__c = true;
        productList[3].Enable_Ramp__c = true;
        insert productList;
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        insert customPbEntryList;

        opty = (SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp', accList[0].Id))[0];
        insert opty;
        SBQQ.TriggerControl.disable();
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        quoteRec = (SB_TestCPQDataUtility.createQuote(1, opty.Id, accList[0].Id, accList[1].id, accList[1].id,quoteNewBusiness))[0];
        insert quoteRec;        
        
        SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c();
        Date qlDate = system.today() + (365*3);
        quoteLines = (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        quoteLines[1].SBQQ__Product__c = productList[1].Id;
        quoteLines[2].SBQQ__Product__c = productList[2].Id;
        quoteLines[3].SBQQ__Product__c = productList[3].Id;
        insert quoteLines;
        SBQQ.TriggerControl.enable();
        quoteLines[1].SBQQ__RequiredBy__c = quoteLines[0].Id;
        quoteLines[2].SBQQ__RequiredBy__c = quoteLines[0].Id;
        quoteLines[3].SBQQ__RequiredBy__c = quoteLines[0].Id;
        quoteLines[2].Re_Ramped__c = true;
        update quoteLines;
        Test.stopTest();
    }

    private static testmethod void testRampAllProducts() {
        List<String> quoteLineList = new List<String>();
        String segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2025-07-15","Qty":"100","disableStartDate":false,"uniqueKey":""},{"Segment":"Ramp 2","StartDate":"2025-07-16","EndDate":"2029-07-15","Qty":"5000","disableStartDate":true}]';
        SBQQ__Quote__c qtObj = [Select Id from SBQQ__Quote__c Limit 1];
        String prodCode='';
        String reqBy='';
        String phantomSkuId = '';
        for(SBQQ__QuoteLine__c ql : [Select id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:qtObj.Id]){
            quoteLineList.add(ql.Id);
            if(String.isNotBlank(ql.SBQQ__ProductCode__c)){
                prodCode=ql.SBQQ__ProductCode__c;
                reqBy=ql.SBQQ__RequiredBy__c;
            }else{
                phantomSkuId = ql.Id;
            }
        }
        
        Test.startTest();
        rampProductsController.getAllProducts(qtObj.Id);
        rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,'',true,true);
        segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2025-07-15","Qty":"1000","disableStartDate":false,"uniqueKey":""},{"Segment":"Ramp 2","StartDate":"2025-07-16","EndDate":"2030-07-15","Qty":"8000","disableStartDate":true}]';
        rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,'',true,true);
        rampProductsController.getAllProducts(qtObj.Id);
        rampProductsController.getRampedLines(qtObj.Id,'',prodCode,reqBy);
        rampProductsController.getRampedLines(qtObj.Id,phantomSkuId,'','');
        Test.stopTest();
    }
    
    private static testmethod void testRampProducts() {
        List<String> quoteLineList = new List<String>();
        String prodCode='';
        String finalKey='';
        String finalKey2='';
        SBQQ__Quote__c qtObj = [Select Id from SBQQ__Quote__c Limit 1];
        
        for(SBQQ__QuoteLine__c ql : [Select id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:qtObj.Id]){
            quoteLineList.add(ql.Id);
            if(String.isNotBlank(ql.SBQQ__ProductCode__c)){
                prodCode = ql.SBQQ__ProductCode__c;
                finalKey=ql.SBQQ__ProductCode__c+ql.Id;
            }
        }
        String segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2023-10-15","Qty":500,"disableStartDate":false,"uniqueKey":"'+finalKey+'"},{"Segment":"Ramp 2","StartDate":"2023-10-16","EndDate":"2026-01-14","Qty":"2000","disableStartDate":true}]';
        system.debug('segment in test'+segments);
        Test.startTest();
        
        rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,finalKey,false,false);
        quoteLineList = new List<String>();
        finalKey='';
        for(SBQQ__QuoteLine__c ql : [Select id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c,Ramp_Label__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:qtObj.Id order by Ramp_Label__c ASC]){
            quoteLineList.add(ql.Id);
            if(prodCode==ql.SBQQ__ProductCode__c && finalKey == ''){
                
                finalKey=ql.SBQQ__ProductCode__c+ql.Id;
            }else if(prodCode==ql.SBQQ__ProductCode__c && finalKey != ''){
                finalKey2=ql.SBQQ__ProductCode__c+ql.Id;
            }
        }
        segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2023-10-15","Qty":500,"disableStartDate":false,"uniqueKey":"'+finalKey+'"},{"Segment":"Ramp 2","StartDate":"2023-10-16","EndDate":"2026-01-14","Qty":"3000","disableStartDate":true,"uniqueKey":"'+finalKey2+'"},{"Segment":"Ramp 3","StartDate":"2026-10-15","EndDate":"2029-01-14","Qty":"4000","disableStartDate":true}]';
        rampProductsController.getAllProducts(qtObj.Id);
        rampProductsController.SegmentWrapper Wrp = new rampProductsController.SegmentWrapper( 'Ramp 1','2021-07-16','2023-10-15','500',true,'','',true);
        
        Test.stopTest();
       // rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,finalKey,false,false);
    }
    
    private static testmethod void testcreateQuoteLines() {
        List<String> quoteLineList = new List<String>();
        String prodCode='';
        String finalKey='';
        String finalKey2='';
        SBQQ__Quote__c qtObj = [Select Id from SBQQ__Quote__c Limit 1];
        
        for(SBQQ__QuoteLine__c ql : [Select id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:qtObj.Id]){
            quoteLineList.add(ql.Id);
            if(String.isNotBlank(ql.SBQQ__ProductCode__c)){
                prodCode = ql.SBQQ__ProductCode__c;
                finalKey=ql.SBQQ__ProductCode__c+ql.Id;
            }
        }
        
        
        quoteLineList = new List<String>();
        finalKey='';
        for(SBQQ__QuoteLine__c ql : [Select id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c,Ramp_Label__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:qtObj.Id order by Ramp_Label__c ASC]){
            quoteLineList.add(ql.Id);
            if(prodCode==ql.SBQQ__ProductCode__c && finalKey == ''){
                
                finalKey=ql.SBQQ__ProductCode__c+ql.Id;
            }else if(prodCode==ql.SBQQ__ProductCode__c && finalKey != ''){
                finalKey2=ql.SBQQ__ProductCode__c+ql.Id;
            }
        }
        Test.startTest();
        String segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2023-10-15","Qty":500,"disableStartDate":false,"uniqueKey":"'+finalKey+'"},{"Segment":"Ramp 2","StartDate":"2023-10-16","EndDate":"2026-01-14","Qty":"3000","disableStartDate":true,"uniqueKey":"'+finalKey2+'"},{"Segment":"Ramp 3","StartDate":"2026-10-15","EndDate":"2029-01-14","Qty":"4000","disableStartDate":true}]';
        rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,finalKey,false,false);

        List<SBQQ__QuoteLine__c> lstQLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =: qtObj.Id]; 
        delete lstQLine;
        Test.stopTest();
        rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,'[]',finalKey,false,false);

        
    }
    
    private static testmethod void testDeleteRamps() {
        List<String> quoteLineList = new List<String>();
        List<SBQQ__QuoteLine__c> deleteQL = new List<SBQQ__QuoteLine__c>();
        String prodCode='';
        String finalKey='';
        SBQQ__Quote__c qtObj = [Select Id from SBQQ__Quote__c Limit 1];
        
        for(SBQQ__QuoteLine__c ql : [Select id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c,Ramp_Label__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:qtObj.Id]){
            quoteLineList.add(ql.Id);
            if(String.isNotBlank(ql.SBQQ__ProductCode__c)){
                prodCode = ql.SBQQ__ProductCode__c;
                finalKey=ql.SBQQ__ProductCode__c+ql.Id;
            }if(String.isNotBlank(ql.Ramp_Label__c)){
                deleteQL.add(ql);
            }
        }
        
       
        if(!deleteQL.isEmpty()){
            delete deleteQL;
        }
        String segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2023-10-15","Qty":500,"disableStartDate":false,"uniqueKey":"'+finalKey+'"},{"Segment":"Ramp 2","StartDate":"2023-10-16","EndDate":"2026-01-14","Qty":"2000","disableStartDate":true}]';
        system.debug('segment in test'+segments);
        Test.startTest();
        rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,finalKey,false,false);
        Test.stopTest();
        quoteLineList = new List<String>();
        for(SBQQ__QuoteLine__c ql : [Select id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c,Ramp_Label__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:qtObj.Id]){
            quoteLineList.add(ql.Id);
        }
        //segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2023-10-15","Qty":500,"disableStartDate":false}]';
        
        //segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2023-10-15","Qty":500,"disableStartDate":false,"uniqueKey":"'+finalKey+'"}]';
        //rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,finalKey,false,false);
    }
    
    @isTest static void testAmendRampProducts() {
        List<String> quoteLineList = new List<String>();
        String prodCode='';
        String finalKey='';
        String finalKey2='';
        SBQQ__Quote__c qtObj = [Select Id from SBQQ__Quote__c Limit 1];
        Account objAcc = [select id from account limit 1 ];
        Partner_Incentive__c pi = SB_TestCPQDataUtility.createPartnerIncentive(1,objAcc.id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP')[0];
        pi.Default__c=true;
        insert pi;
        Contract contractRec = SB_TestCPQDataUtility.createContracts(objAcc.id, objAcc.id, objAcc.id,pi,1)[0];
        productList = [select id from product2 limit 2 ];
         List<SBQQ__Subscription__c> subscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractRec,productList);
        insert subscriptionList;
         Test.startTest();
        SBQQ__Quoteline__C objQL = new SBQQ__QuoteLine__c();
        for(SBQQ__QuoteLine__c ql : [Select id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:qtObj.Id]){
            quoteLineList.add(ql.Id);
            if(String.isNotBlank(ql.SBQQ__ProductCode__c)){
                prodCode = ql.SBQQ__ProductCode__c;
                finalKey=ql.SBQQ__ProductCode__c+ql.Id;
            }
            objQL.id = ql.id;
            objQL.SBQQ__UpgradedSubscription__c = subscriptionList[0].id;
        }
        update objQL;
        String segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2023-10-15","Qty":500,"disableStartDate":false,"uniqueKey":"'+finalKey+'"},{"Segment":"Ramp 2","StartDate":"2023-10-16","EndDate":"2026-01-14","Qty":"2000","disableStartDate":true}]';
        system.debug('segment in test'+segments);
    
        rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,finalKey,false,false);
        
        Test.stopTest();
       // rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,finalKey,false,false);
    }
     @isTest static void testAmendRampProductsDelete() {
         Test.startTest();
         List<String> quoteLineList = new List<String>();
        String segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2025-07-15","Qty":"100","disableStartDate":false,"uniqueKey":""},{"Segment":"Ramp 2","StartDate":"2025-07-16","EndDate":"2029-07-15","Qty":"5000","disableStartDate":true}]';
        SBQQ__Quote__c qtObj = [Select Id from SBQQ__Quote__c Limit 1];
        String prodCode='';
        String reqBy='';
        String phantomSkuId = '';
        for(SBQQ__QuoteLine__c ql : [Select id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:qtObj.Id]){
            quoteLineList.add(ql.Id);
            if(String.isNotBlank(ql.SBQQ__ProductCode__c)){
                prodCode=ql.SBQQ__ProductCode__c;
                reqBy=ql.SBQQ__RequiredBy__c;
            }else{
                phantomSkuId = ql.Id;
            }
        }
        
        
        //rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,'',true,true);
        segments = '[{"Segment":"Ramp 1","StartDate":"2021-07-16","EndDate":"2025-07-16","Qty":"1000","disableStartDate":false,"uniqueKey":""}]';
        rampProductsController.createQuoteLines(qtObj.Id,quoteLineList,segments,'',true,true);
        Test.stopTest();
    }
    }