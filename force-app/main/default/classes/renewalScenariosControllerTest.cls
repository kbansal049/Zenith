/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 04-28-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class renewalScenariosControllerTest {
    
    private static List<Account> accList = new List<Account>();
    private static List<Product2> productList=new List<Product2>();
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    private static List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
    private static String PROFBUNDLE='ZIA Professional Bundle';
    private static String NANOLOG='Nanolog Streaming Service';
    private static String PLABUNDLE='Platform - Bundles';
    private static String ADDON='Add-Ons';
    private static String PLADITION='Platform - Editions';
    private static String NE ='New';
    private static String FY21SINGLE='FY21 Single Tier Price List';
    private static String TES='Test';
    private static String TESTING='Testing';
    @testSetup static void setup() {
        accList = (SB_TestCPQDataUtility.createAccount(2));
        TriggerUtility.SkipAccTriggerExecuted(); //added
        insert accList;
        
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
        productList = (SB_TestCPQDataUtility.createProduct(8,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].Name ='ZIA Business Edition';
        productList[1].Name ='ZIA - Edition Products';
        productList[2].Name =PROFBUNDLE;
        productList[3].Name ='ZIA - Bundle Products';
        productList[4].Name =NANOLOG;
        productList[5].Name ='Zscaler Virtual Zen 30mbps';
        productList[6].Name ='ZIA Virtual Private Service Edge';
        productList[7].Name ='NSS Log Streaming Service';
        insert productList;
        Product_Upgrade_Mappings__c  objPUM = new Product_Upgrade_Mappings__c (Original_SKU__c =productList[5].id, Upgraded_SKU__c=productList[6].id,Price_List__c='FY22 Single Tier Price List;FY22 Single Tier Upsell Price List;FY21 Single Tier Price List;FY21 Federal Editions Price List');
        insert objPUM;
        // Product Feature
        List<SBQQ__ProductFeature__c> listFeatures = new List<SBQQ__ProductFeature__c>();
        listFeatures.add(new SBQQ__ProductFeature__c(Name = PLABUNDLE, SBQQ__Number__c = 4,SBQQ__ConfiguredSKU__c = productList[3].Id,SBQQ__Category__c = PLABUNDLE));
        listFeatures.add(new SBQQ__ProductFeature__c(Name = ADDON,SBQQ__Number__c = 5,SBQQ__ConfiguredSKU__c = productList[3].Id,SBQQ__Category__c = ADDON));
        listFeatures.add(new SBQQ__ProductFeature__c(Name = PLADITION,SBQQ__Number__c = 4,SBQQ__ConfiguredSKU__c = productList[1].Id,SBQQ__Category__c = PLADITION));
        listFeatures.add(new SBQQ__ProductFeature__c(Name = PLABUNDLE, SBQQ__Number__c = 4,SBQQ__ConfiguredSKU__c = productList[4].Id,SBQQ__Category__c = PLABUNDLE));
        listFeatures.add(new SBQQ__ProductFeature__c(Name = ADDON,SBQQ__Number__c = 5,SBQQ__ConfiguredSKU__c = productList[4].Id,SBQQ__Category__c = ADDON));
        listFeatures.add(new SBQQ__ProductFeature__c(Name = PLADITION,SBQQ__Number__c = 4,SBQQ__ConfiguredSKU__c = productList[2].Id,SBQQ__Category__c = PLADITION));
        listFeatures.add(new SBQQ__ProductFeature__c(Name = PLABUNDLE, SBQQ__Number__c = 4,SBQQ__ConfiguredSKU__c = productList[2].Id,SBQQ__Category__c = PLABUNDLE));
        listFeatures.add(new SBQQ__ProductFeature__c(Name = ADDON,SBQQ__Number__c = 5,SBQQ__ConfiguredSKU__c = productList[2].Id,SBQQ__Category__c = ADDON));
        listFeatures.add(new SBQQ__ProductFeature__c(Name = PLADITION,SBQQ__Number__c = 4,SBQQ__ConfiguredSKU__c = productList[2].Id,SBQQ__Category__c = PLADITION));
        insert listFeatures;
        
        List<SBQQ__ProductOption__c> listProdOptions = new List<SBQQ__ProductOption__c>();
        listProdOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 123,SBQQ__ConfiguredSKU__c =productList[3].Id,SBQQ__OptionalSKU__c =  productList[2].Id,SBQQ__Feature__c = listFeatures[0].Id));
        listProdOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 234,SBQQ__ConfiguredSKU__c =productList[3].Id,SBQQ__OptionalSKU__c =  productList[4].Id,SBQQ__Feature__c = listFeatures[1].Id));
        listProdOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 123,SBQQ__ConfiguredSKU__c =productList[1].Id,SBQQ__OptionalSKU__c =  productList[0].Id,SBQQ__Feature__c = listFeatures[2].Id));
        listProdOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 123,SBQQ__ConfiguredSKU__c =productList[1].Id,SBQQ__OptionalSKU__c =  productList[4].Id)); // Added by Ajith for code coverage as part of IBA-2432
        
        insert listProdOptions;
        
        SB_TestCPQDataUtility.priceBooksToBeInsertedList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        insert SB_TestCPQDataUtility.priceBooksToBeInsertedList;
        
        List<Opportunity> listOppty = (SB_TestCPQDataUtility.createOpportunity(2, 'TestOpp', accList[0].Id));
        listOppty[0].Opp_Price_List__c =FY21SINGLE;
        listOppty[1].Opp_Price_List__c =FY21SINGLE;
        TriggerUtility.SkipOpportunityTriggerExecutedSetTrue(); //added
        TriggerUtility.skipOpportunityTrigger();//added
        insert listOppty;
        
        List<Opportunity_Partner__c> listOpptyPartner = new List<Opportunity_Partner__c>();
        listOpptyPartner.add(new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = listOppty[0].Id,Partner_Type__c = 'Reseller',Account__c = accList[0].Id));
        listOpptyPartner.add(new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = listOppty[1].Id,Partner_Type__c = 'Distributor',Account__c = accList[0].Id));
        insert listOpptyPartner;
        SBQQ.TriggerControl.disable();
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();
        listQuotes = (SB_TestCPQDataUtility.createQuote(2, listOppty[0].Id, accList[0].Id, accList[1].id, accList[1].id,quoteNewBusiness));
        listQuotes[0].SBQQ__opportunity2__c = listOppty[0].id;
        listQuotes[1].Shell_Quote__c = true;
        listQuotes[1].SBQQ__opportunity2__c = listOppty[1].id;
        listQuotes[0].Price_List__c = FY21SINGLE;
        listQuotes[1].Price_List__c = FY21SINGLE;
        insert listQuotes;
        
        Date startDate = Date.today();
        Date endDate = Date.today()+50 ;
        Double quantity = 1000;
        
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        insert piList;
        
        Contract contractRec = (SB_TestCPQDataUtility.createContracts(accList[0].Id, accList[1].id, accList[1].id,piList[1],1))[0];
        
        insert contractRec;
        
        
        List<SBQQ__Subscription__c> listSubs = new List<SBQQ__Subscription__c>();
        listSubs.add(new SBQQ__Subscription__c(SBQQ__Contract__c = contractRec.Id,SBQQ__Account__c = accList[0].Id,SBQQ__Quantity__c = 1000,SBQQ__TerminatedDate__c = null,Subscription_Line_Status__c = NE,SBQQ__Product__c = productList[2].Id));
        listSubs.add(new SBQQ__Subscription__c(SBQQ__Contract__c = contractRec.Id,SBQQ__Account__c = accList[0].Id,SBQQ__Quantity__c = 1000,SBQQ__TerminatedDate__c = null,Subscription_Line_Status__c = NE,SBQQ__Product__c = productList[3].Id));
        listSubs.add(new SBQQ__Subscription__c(SBQQ__Contract__c = contractRec.Id,SBQQ__Account__c = accList[0].Id,SBQQ__Quantity__c = 1000,SBQQ__TerminatedDate__c = null,Subscription_Line_Status__c = NE,SBQQ__Product__c = productList[4].Id));
        listSubs.add(new SBQQ__Subscription__c(SBQQ__Contract__c = contractRec.Id,SBQQ__Account__c = accList[0].Id,SBQQ__Quantity__c = 1000,SBQQ__TerminatedDate__c = null,Subscription_Line_Status__c = NE,SBQQ__Product__c = productList[1].Id));
        insert listSubs;
        listSubs[0].SBQQ__RequiredById__c = listSubs[1].id;
        listSubs[2].SBQQ__RequiredById__c = listSubs[1].id;
        update listSubs;
        
        
        List<SBQQ__QuoteLine__c> quoteLines = SB_TestCPQDataUtility.createQuoteLine (6, listQuotes[0].id,productList[0].Id, startDate, endDate ,quantity);
        quoteLines[2].SBQQ__Quote__c=listQuotes[1].id;
        quoteLines[3].SBQQ__Quote__c=listQuotes[1].id;
        quoteLines[4].SBQQ__Quote__c=listQuotes[1].id;
        quoteLines[5].SBQQ__Quote__c=listQuotes[1].id;
        quoteLines[1].SBQQ__product__c=productList[1].Id;
        quoteLines[2].SBQQ__product__c=productList[2].Id;
        quoteLines[3].SBQQ__product__c=productList[3].Id;
        quoteLines[4].SBQQ__product__c=productList[4].Id;
        quotelines[5].sbqq__product__c = productList[5].id;
        quoteLines[2].SBQQ__RenewedSubscription__c = listSubs[0].id;
        quoteLines[3].SBQQ__RenewedSubscription__c = listSubs[1].id;
        quoteLines[4].SBQQ__RenewedSubscription__c = listSubs[2].id;
        quoteLines[2].SBQQ__ProductOption__c = listProdOptions[0].id;
        quoteLines[4].SBQQ__ProductOption__c = listProdOptions[1].id;
        quoteLines[0].SBQQ__ProductOption__c = listProdOptions[2].id;
        // quoteLines[2].SBQQ__ProductOption__c = po.Id;
        insert quoteLines;
        quoteLines[2].SBQQ__RequiredBy__c = quoteLines[3].Id;
        quoteLines[0].SBQQ__RequiredBy__c = quoteLines[1].Id;
        quoteLines[4].SBQQ__RequiredBy__c = quoteLines[3].Id;
        quoteLines[5].SBQQ__RequiredBy__c = quoteLines[3].Id;
        TriggerUtility.skipentireproposaltriggerExecuted(); //added
        update  quoteLines;
        
        System.debug('@@quoteLines[0]'+quoteLines[0]);
        System.debug('@@quoteLines[1]'+quoteLines[1]);
        System.debug('@@quoteLines[2]'+quoteLines[2]);
        System.debug('@@quoteLines[3]'+quoteLines[3]);
        System.debug('@@quoteLines[4]'+quoteLines[4]);
        System.debug('@@quoteLines[5]'+quoteLines[5]);
        
        List<Renewal_Scenario__c> listRenewalScnearios = new List<Renewal_Scenario__c>();
        listRenewalScnearios.add(new Renewal_Scenario__c(Active__c= TRUE ,Associated_Platform_Edition__c=TES,Installed_Base_Name__c=NANOLOG,Name=TESTING,Name_Renewed_To__c=TESTING,Original_Quote__c=listQuotes[0].Id,Type__c='Bundles Upgrade',price_list__c=FY21SINGLE ));
        listRenewalScnearios.add(new Renewal_Scenario__c(Active__c= TRUE ,Associated_Platform_Edition__c=TES,Installed_Base_Name__c=NANOLOG,Name=TESTING,Name_Renewed_To__c=TESTING,Original_Quote__c=listQuotes[1].Id,Type__c='Bundles Upgrade',price_list__c=FY21SINGLE ));
        listRenewalScnearios.add(new Renewal_Scenario__c(Active__c= TRUE ,Associated_Platform_Edition__c=TES,Installed_Base_Name__c='Zscaler Internet Access',Name=TESTING,Name_Renewed_To__c=TESTING,Original_Quote__c=listQuotes[1].Id,Type__c='Bundles Like to Like',price_list__c=FY21SINGLE ));
        listRenewalScnearios.add(new Renewal_Scenario__c(Active__c= TRUE,Associated_Platform_Edition__c=TES,Installed_Base_Name__c='Suites',Name=TES,Name_Renewed_To__c=TES,Original_Quote__c=listQuotes[1].Id,Type__c='Suites Like to Like',price_list__c=FY21SINGLE));
        listRenewalScnearios.add(new Renewal_Scenario__c(Active__c= TRUE,Associated_Platform_Edition__c='ZIA Business Edition',Installed_Base_Name__c=PROFBUNDLE,Name=TES,Name_Renewed_To__c=TES,Original_Quote__c=listQuotes[0].Id,Type__c='Bundles Upgrade',price_list__c=FY21SINGLE,InstallBaseZscalerProductFamily__c='ZIA'));
        insert listRenewalScnearios;
        
        List<Premium_support_range__c> premiumSupportrangeList = new List<Premium_support_range__c>();
        premiumSupportrangeList.add(new Premium_support_range__c(Name = 'Test Premium Support Range',IsFederalSKU__c =true, Default_Fed_SKU__c =true, Product_Code__c = 'ZCES-SUP-PREM',Minimum_Price_Range__c = 0));
        premiumSupportrangeList.add(new Premium_support_range__c(Name='ZIA - Bundle Products',IsFederalSKU__c = true, Default_Fed_SKU__c = false));
        insert premiumSupportrangeList;
        SBQQ.TriggerControl.enable();
        
        
    }
    
    private static testmethod void testgetProductsForSelectedBundle(){
        Test.startTest();
        List<SBQQ__Quote__C> listQuotes = [SELECT ID     FROM SBQQ__Quote__c LIMIT 1];
        List<renewalScenariosController.SelectedBundleData> results = renewalScenariosController.getProductsForSelectedBundle('Suite','Like to Like',listQuotes[0].id);
        System.assertNotEquals(null,results);
        Test.stopTest();
    }
    
    private static testmethod void testgetProductsForSelectedBundle2(){
        Test.startTest();
        List<SBQQ__Quote__C> listQuotes = [SELECT ID FROM SBQQ__Quote__c LIMIT 1];
        List<renewalScenariosController.SelectedBundleData> results = renewalScenariosController.getProductsForSelectedBundle(PROFBUNDLE,'Upgrade',listQuotes[0].id);
        System.assertNotEquals(null,results);
        Test.stopTest();
    }
    
    private static testmethod void testgetBundlesValuesForPicklist(){
        Test.startTest();
        SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c WHERE Shell_Quote__c=true limit 1];
        renewalScenariosController.QuoteLineWrapper results = renewalScenariosController.getBundlesValuesForPicklist(quote.Id);
        System.assertNotEquals(null,results);
        Test.stopTest();
    }
    
    private static testmethod void testgetBundlesValuesForPicklistElseCase(){
        SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c WHERE Shell_Quote__c=true limit 1];
        List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
        Test.startTest();
        for(SBQQ__QuoteLine__c qliObj : [SELECT Id, SBQQ__RenewedSubscription__c,SBQQ__UpgradedSubscription__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id Limit 1]){
            qliObj.SBQQ__UpgradedSubscription__c = qliObj.SBQQ__RenewedSubscription__c;
            qliObj.SBQQ__RenewedSubscription__c = null;
            qliList.add(qliObj);   
        }
        TriggerUtility.skipentireproposaltriggerExecuted(); // added
        update qliList;
        renewalScenariosController.QuoteLineWrapper results = renewalScenariosController.getBundlesValuesForPicklist(quote.Id);
        System.assertNotEquals(null,results);
        Test.stopTest();
    }
    
    private static testmethod void testsaveRenewalLinesToQuote(){
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
        System.runas(usr){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c WHERE Shell_Quote__c=true limit 1];
            SBQQ__Quote__c quote2 = [Select Id from SBQQ__Quote__c WHERE Shell_Quote__c=false limit 1];
            SBQQ__Subscription__c sub = [Select Id from SBQQ__Subscription__c limit 1];
            List<renewalScenariosController.RenewWrapper> lstRenewed = new List<renewalScenariosController.RenewWrapper>();
            renewalScenariosController.RenewWrapper renewWrapper = new renewalScenariosController.RenewWrapper('',String.valueOf(Date.today()),PROFBUNDLE,String.valueOf(quote2.Id),String.valueOf(sub.Id),'Upgrade','ZIA');
            lstRenewed.add(renewWrapper);
            Test.startTest();
            try
            { 
                String jsonString = JSON.serialize(lstRenewed);
                String results = renewalScenariosController.saveRenewalLinesToQuote(quote.Id,null,jsonString,new List<String>{PROFBUNDLE});
                System.assertNotEquals(null,results);
            }
            catch(exception e)
            {
            } 
            Test.stopTest();
        }
    }
    
    private static testmethod void testsaveRenewalLinesToQuote2(){
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
        System.runas(usr){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c WHERE Shell_Quote__c=true limit 1];
            SBQQ__Quote__c quote2 = [Select Id from SBQQ__Quote__c WHERE Shell_Quote__c=false limit 1];
            SBQQ__Subscription__c sub = [Select Id from SBQQ__Subscription__c limit 1];
            List<renewalScenariosController.RenewWrapper> lstRenewed = new List<renewalScenariosController.RenewWrapper>();
            renewalScenariosController.RenewWrapper renewWrapper = new renewalScenariosController.RenewWrapper('','','Suites',String.valueOf(quote2.Id),String.valueOf(sub.Id),'Like to Like','');
            lstRenewed.add(renewWrapper);
            Test.startTest();
            try{
            String jsonString = JSON.serialize(lstRenewed);
            String results = renewalScenariosController.saveRenewalLinesToQuote(quote.Id,null,jsonString,new List<String>{'Suites'});
                System.assertNotEquals(null,results);}
            catch(exception e)
            {
            }
            Test.stopTest();
        }
    }
    
    private static testmethod void testsaveRenewalLinesToQuote3(){
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
        System.runas(usr){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c WHERE Shell_Quote__c=true limit 1];
            SBQQ__Quote__c quote2 = [Select Id from SBQQ__Quote__c WHERE Shell_Quote__c=false limit 1];
            SBQQ__Subscription__c sub = [Select Id from SBQQ__Subscription__c limit 1];
            
            Product2 product = [Select Id from Product2 where name =: NANOLOG ];
            Product2 product1 = [Select Id from Product2 where name = 'NSS Log Streaming Service'];
            Product2 product11 = [Select Id from Product2 where name = 'ZIA - Bundle Products'];
            SBQQ__ProductFeature__c pf = [Select Id from SBQQ__ProductFeature__c where SBQQ__ConfiguredSKU__c =: product.Id limit 1];
            SBQQ__ProductOption__c po = new SBQQ__ProductOption__c(SBQQ__Number__c = 123,SBQQ__ConfiguredSKU__c =product.Id,SBQQ__OptionalSKU__c =  product.Id,SBQQ__Feature__c = pf.Id);
            insert po;
            
            List<renewalScenariosController.RenewWrapper> lstRenewed = new List<renewalScenariosController.RenewWrapper>();
            renewalScenariosController.RenewWrapper renewWrapper = new renewalScenariosController.RenewWrapper('',String.valueOf(Date.today()),NANOLOG,String.valueOf(quote2.Id),String.valueOf(sub.Id),'Upgrade','');
            lstRenewed.add(renewWrapper);
            String jsonString = JSON.serialize(lstRenewed);
            
            List<Product_Upgrade_Mappings__c> ProductUpgradeMappingsList= [SELECT Id,Original_SKU__c,Original_SKU__r.name,Upgraded_SKU__c, Upgraded_SKU__r.name,Cancel_the_line__c FROM Product_Upgrade_Mappings__c];
            ProductUpgradeMappingsList[0].Cancel_the_line__c=True;
            ProductUpgradeMappingsList[0].Original_SKU__c=product11.Id;
            ProductUpgradeMappingsList[0].Upgraded_SKU__c=product1.id;
            Update ProductUpgradeMappingsList;
            
            List<Premium_support_range__c> premiumSupportrangeList = [SELECT Id,Name,Default_Fed_SKU__c,Description__c,IsFederalSKU__c,Minimum_Price_Range__c,Product_Code__c,Support_Type__c From Premium_support_range__c where IsFederalSKU__c=true AND  Default_Fed_SKU__c =true ];
            system.debug('premiumSupportrangeList'+premiumSupportrangeList);
            Test.startTest();
            try{
            String results = renewalScenariosController.saveRenewalLinesToQuote(quote.Id,null,jsonString,new List<String>{NANOLOG});
            //List<renewalScenariosController.RenewWrapper> lstRenewed1 = new List<renewalScenariosController.RenewWrapper>();
            //renewalScenariosController.RenewWrapper renewWrapper1 = new renewalScenariosController.RenewWrapper('',String.valueOf(Date.today()),NANOLOG,String.valueOf(quote.Id),String.valueOf(sub.Id),'Upgrade','');
            //lstRenewed1.add(renewWrapper1);
            //String jsonString1 = JSON.serialize(lstRenewed1);
            //String results1 = renewalScenariosController.saveRenewalLinesToQuote(quote.Id,null,jsonString1,new List<String>{NANOLOG});
            System.assertNotEquals(null,results);}
            catch(exception e)
            {
            }
            Test.stopTest();
        } 
    }
    
}