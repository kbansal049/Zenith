/*************************************************************************************************************************
 @Name: APTS_OpportunityTriggerHandler_Test
 @Author: Anay Bhande
 @Created Date: 22/12/2016
 @Descripton: Test Class for APTS_OpportunityTriggerHandler 
 @Used By: 
*************************************************************************************************************************/
@isTest
public class APTS_OpportunityTriggerHandler_Test 
{
        @testSetup static void dataSetup() {
            Map<String, SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> mapSKUs = SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getAll();
            List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skuscs = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
            if(!mapSKUs.containsKey('CFW_CSB_SKUs')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_CSB_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZSEC-WEB-ABA');
                skuscs.add(rec1);
            }
            if(!mapSKUs.containsKey('CFW_ZPA_SKUs')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_ZPA_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE');
                skuscs.add(rec2);
            }
            if(!mapSKUs.containsKey('Credit_SKUs')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Credit_SKUs', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT');
                skuscs.add(rec3);
            }
            if(!mapSKUs.containsKey('One_Time_SKU')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec4 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;ZCES-Onetime-ZPA-INT');
                skuscs.add(rec4);
            }
            if(!mapSKUs.containsKey('Recurring_SKU')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec5 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Recurring_SKU', SKU_Codes__c = 'ZCES-SUP-PREM;ZCES-SUP-PREM-SP;ZCES-SUP-TAMT');
                skuscs.add(rec5);
            }
            if(!mapSKUs.containsKey('SKUs_not_To_ADD')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec6 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_not_To_ADD', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
                skuscs.add(rec6);
            }
            if(!mapSKUs.containsKey('SKUs_to_SKIP_ACV')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec7 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_to_SKIP_ACV', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT;ZCR-UPY4;ZCR-UPY5');
                skuscs.add(rec7);
            }
            if(!mapSKUs.containsKey('Uplift_SKUs')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec8 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Uplift_SKUs', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
                skuscs.add(rec8);
            }
            if(!mapSKUs.containsKey('ZPA_Deployment_SKUs')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec9 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs', SKU_Codes__c = 'ZCES-DAS-FED1;ZCES-DAS-FED2;ZCES-DAS-FED3;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG4;ZCES-DAS-PKG6;ZCES-DAS-UNIT;ZCES-DEP-ADV;ZCES-DEP-ENT;ZCES-DEP-ENTPLUS;ZCES-DEP-ESS;ZCES-PRO-SVC');
                skuscs.add(rec9);
            }
            if(!mapSKUs.containsKey('One_Time_SKU1')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec10 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
                skuscs.add(rec10);
            }
            if(!mapSKUs.containsKey('ZPA_Deployment_SKUs1')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
                skuscs.add(rec11);
            }
            if(!mapSKUs.containsKey('Included_DAS_Package_SKUs1')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs1', SKU_Codes__c = 'ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG4;ZCES-DAS-PKG6;ZCES-DAS-PKG0;ZCES-DEP-ADV;ZCES-DEP-ENT;ZCES-DEP-ENTPLUS;ZCES-DEP-ESS;ZCES-PRO-HEALTH;ZCES-DAS-FED1;ZCES-DAS-FED2;ZCES-DAS-FED3');
                skuscs.add(rec11);
            }
            if(!mapSKUs.containsKey('Included_DAS_Package_SKUs2')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs2', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-PRO-OPTADV;ZCES-PRO-OPTESS;ZCES-PRO-DZX;ZCES-PRO-OPTENT;ZCES-PRO-POL-PRE;ZCES-PRO-PMI-PRE;ZCES-PRO-SVC-CUST');
                skuscs.add(rec11);
            }
            if(!mapSKUs.containsKey('ZIA_Contract_Date')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec12 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date', SKU_Codes__c = 'ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP');
                skuscs.add(rec12);
            }
            if(!mapSKUs.containsKey('ZIA_Contract_Date1')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec13 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date1', SKU_Codes__c = 'ZS-WFA-BUS-EDITION');
                skuscs.add(rec13);
            }
            if(!mapSKUs.containsKey('ZPA_Contract_Date')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec14 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZS-WFA-BUS-EDITION');
                skuscs.add(rec14);
            }
            if(!mapSKUs.containsKey('ZDX_Contract_Date')){
                SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec15 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZDX_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION');
                skuscs.add(rec15);
            }
        
        if(!skuscs.isEmpty())
            insert skuscs;
  }
        static testMethod void autoreneOpportunity() {
            
            Account acc = new Account ();
        	acc.Name = 'Test Account';
        	acc.APTS_Platform_Subscription_End_Date__c = Date.today();
            TriggerUtility.isSkipAccTriggerExecuted();
            insert acc;
           // Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
           // pricelist.Name = 'ZScaler Price List';
            //pricelist.Apttus_Config2__Active__c = true;
            //insert pricelist;
            //Pricebook2 pricebook=new Pricebook2(Name='Apttus Default Price Book');
            //insert pricebook;
            //Admin Entries
           /* Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;*/
            List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
            Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Opp_Trigger', Execute__c = true);
            trlst.add(tr1);
            insert trlst;
            Test.startTest();
            TriggerUtility.isopportunityfieldupdateReset();
            Opportunity opp = new Opportunity ();
            opp.Name = 'test opportunity';
            opp.closedate =  Date.today();
            opp.Start_Date__c  =  Date.today();
            opp.accountId = acc.Id;
            //opp.Price_List__c = pricelist.Id;
            opp.type ='Existing Customer (Renewal)';
            //opp.type='Renewal';
            opp.Stagename = label.Stage_4_Economic_Buyer_Signoff;
            //Apttus_Config2__AssetLineItem__c asl=new Apttus_Config2__AssetLineItem__c(Name='Test Asset Line Item',Apttus_Config2__AccountId__c=acc.Id,Apttus_Config2__AssetStatus__c='Activated');
            //insert asl;
            TriggerUtility.realignPatchReset();
            insert opp;
            TriggerUtility.realignPatchReset();
            TriggerUtility.isopportunityfieldupdateReset();
            update opp;
            TriggerUtility.isopportunityfieldupdateReset();
            opp.Stagename = Label.Stage_7_Closed_Lost;
            opp.Sub_Stage__c = 'Closed Lost';
            update opp;
            Test.stopTest();
        }

        static testMethod void createNewBusinesOpp() {
            Test.startTest();
            Account acc=APTS_TestUtil.createAccount();
           /* Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
            pricelist.Name = 'ZScaler Price List';
            pricelist.Apttus_Config2__Active__c = true;
            insert pricelist;
            Pricebook2 pricebook=new Pricebook2(Name='Apttus Default Price Book');
            insert pricebook;
            //Admin Entries
            Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;*/
            
            Opportunity opp = new Opportunity ();
            opp.Name = 'test opportunity';
            opp.closedate =  Date.today();
            opp.Start_Date__c  =  Date.today();
            opp.accountId = acc.Id;
            //opp.Price_List__c = pricelist.Id;
            opp.type ='New Business';
            opp.Stagename = label.Stage_4_Economic_Buyer_Signoff;
            //Apttus_Config2__AssetLineItem__c asl=new Apttus_Config2__AssetLineItem__c(Name='Test Asset Line Item',Apttus_Config2__AccountId__c=acc.Id,Apttus_Config2__AssetStatus__c='Activated');
            //insert asl;
            TriggerUtility.realignPatchReset();
            insert opp;
            TriggerUtility.realignPatchReset();
            update opp;

            Test.stopTest();
        }

        static testMethod void createUpsellOpp() {
            Test.startTest();
            /*Account acc=APTS_TestUtil.creatAccount();
            Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
            pricelist.Name = 'ZScaler Price List';
            pricelist.Apttus_Config2__Active__c = true;
            insert pricelist;
            Pricebook2 pricebook=new Pricebook2(Name='Apttus Default Price Book');
            insert pricebook;
            //Admin Entries
            Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;*/
            
            Opportunity opp = new Opportunity ();
            opp.Name = 'test opportunity';
            opp.closedate =  Date.today();
            opp.Start_Date__c  =  Date.today();
            //opp.accountId = acc.Id;
            //opp.Price_List__c = pricelist.Id;
            opp.type ='Existing Customer (Renewal)';
            opp.Stagename = label.Stage_4_Economic_Buyer_Signoff;
            //Apttus_Config2__AssetLineItem__c asl=new Apttus_Config2__AssetLineItem__c(Name='Test Asset Line Item',Apttus_Config2__AccountId__c=acc.Id,Apttus_Config2__AssetStatus__c='Activated');
            //insert asl;
            TriggerUtility.realignPatchReset();
            insert opp;
            TriggerUtility.realignPatchReset();
            update opp;
            Test.stopTest();
        }

}