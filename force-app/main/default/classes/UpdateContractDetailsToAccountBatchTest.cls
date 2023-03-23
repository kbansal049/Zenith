/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   NA           NA            Initial Version
 * 2.0   11-24-2021   Mayank B.     Incremental fix CR# 3665
 * 3.0   2-21-2021    Swathi G.     CR#4250
*/
@IsTest(SeeAllData=false)
public class UpdateContractDetailsToAccountBatchTest {

    @TestSetup static void setup() {
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> csLst = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs.Name = 'ZDX_Contract_Date';
        cs.SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZDX-ADVANCED';
        csLst.add(cs);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs1.Name = 'ZDX_Adv';
        cs1.SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZDX-ADVANCED;ZDX-ADV;ZS-USER-TFORM-EDITION;ZS-USER-TFORM-EDITION-LU';
        csLst.add(cs1);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs2.Name = 'ZDX_Standard';
        cs2.SKU_Codes__c = 'ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION';
        csLst.add(cs2);
        
         
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs3.Name = 'ZDX_Standard2';
        cs3.SKU_Codes__c = 'ZIA-TFORM-EDITION-LU;ZIA-TRANS-EDITION-LU;ZIA-TRANS-EDITION-US-GCH;ZIA-TRANS-EDITION-US-GCM';
        csLst.add(cs3);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs4 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs4.Name = 'ZDX_Standard3';
        cs4.SKU_Codes__c = 'ZPA-BUS-EDITION-US-GCM;ZPA-PRO-EDITION-US-GCH;ZPA-PRO-EDITION-US-GCM;';
        csLst.add(cs4);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs5 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs5.Name = 'ZDX_Standard4';
        cs5.SKU_Codes__c = 'ZS-USER-BIZ-EDITION;ZS-USER-BIZ-EDITION-LU;ZS-WFA-BUS-BUYBACK;ZS-WFA-BUS-EDITION';
        csLst.add(cs5);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs6 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs6.Name = 'ZDX_Adv_Plus';
        cs6.SKU_Codes__c = 'ZDX-ADV-PLUS;ZS-USER-ELA-EDITION;ZS-USER-ELA-EDITION-LU;ZS-USER-ELA-PRE';
        csLst.add(cs6);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs7 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs7.Name = 'ZDX_M365';
        cs7.SKU_Codes__c = 'ZDX-M-365;ZDX-M365';
        csLst.add(cs7);
        
        INSERT csLst;
        
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'System',
                          lastname='Admin',
                          Alias='sysAdmin',
                          email = 'test'+System.now().getTime()+'@zscaler.com',
                          username= 'test'+System.now().getTime()+'@zscaler.com',
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;	 
        
        //IBA-4095 - Start
        List<Contract_Date_SKUs__c> contractDateSKUs = new List<Contract_Date_SKUs__c>();
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZDX_SKUs_1',Family__c='ZDX',SKU_Codes__c='ZIA-TRANS-EDITION-LU;ZIA-TFORM-EDITION;ZIA-TFORM-EDITION-LU;ZDX-M-365;ZDX-ADV-PLUS;ZS-USER-BIZ-EDITION;ZS-USER-TFORM-EDITION;ZS-USER-ELA-EDITION;ZS-USER-BIZ-EDITION-LU;ZS-USER-TFORM-EDITION-LU;ZS-USER-ELA-EDITION-LU;'));
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZIA_SKUs_1',Family__c='ZIA',SKU_Codes__c='ZIA-O365-PRE;ZIA-ESS-EDITION;ZIA-ESS-EDITION-LU;ZIA-BIZ-EDITION;ZIA-FED-ELA-EDITION;ZIA-FED-ELA-EDITION-LU;ZIA-PRO-EDITION-LU;ZIA-PROF-EDITION-LU;ZIA-TFORM-EDITION;ZIA-TFORM-EDITION-LU;ZIA-UNLTD-EDITION;ZIA-UNLTD-EDITION-LU;EDU-ZIA-SVC-EDGE-TRANS;'));
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZIA_SKUs_2',Family__c='ZIA',SKU_Codes__c='ZIA-PRO-EDITION-LU;ZIA-BUS-EDITION-LU;ZIA-TRANS-EDITION-LU;ZIA-ELA-EDITION-LU;ZS-USER-BIZ-EDITION;ZS-USER-TFORM-EDITION;ZS-USER-ELA-EDITION;ZS-USER-BIZ-EDITION-LU;ZS-USER-TFORM-EDITION-LU;ZS-USER-ELA-EDITION-LU;'));
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZPA_SKUs_1',Family__c='ZPA',SKU_Codes__c='ZPA-INTERNET-PRE;ZPA-BUS-100USERS-PROMO;ZPA-ESS-EDITION;ZPA-UNLTD-EDITION;ZPA-ESS-EDITION-LU;ZPA-UNLTD-EDITION-LU;ZPA-TFORM-EDITION-LU;ZPA-TFORM-EDITION;ZPA-TRANS-EDITION-LU;ZPA-BIZ-EDITION-LU;ZPA-BIZ-EDITION;ZPA-PRO-EDITION-LU;'));
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZPA_SKUs_2',Family__c='ZPA',SKU_Codes__c='	ZPA-BUS-EDITION-100USERS-PROMO;ZS-USER-BIZ-EDITION;ZS-USER-TFORM-EDITION;ZS-USER-ELA-EDITION;ZS-USER-BIZ-EDITION-LU;ZS-USER-TFORM-EDITION-LU;ZS-USER-ELA-EDITION-LU;'));
        
        insert contractDateSKUs;
        //IBA-4095 - End     
    }
    
    @IsTest static void testSchedule(){
        User sysAdmin = [SELECT Id FROM User LIMIT 1];
        System.runAs(sysAdmin) {
            
            List<Account> accList = new List<Account>();
            Account acc = new Account();
            acc.Name = 'Account Historical 7';
            acc.BillingCity = 'Test city';
            acc.BillingCountry = 'Test country';
            acc.BillingStreet = 'Test street';
            acc.type = 'Customer';
            accList.add(acc);
            Account acc1 = new Account();
            acc1.Name = 'Account Historical 8';
            acc1.BillingCity = 'Test city';
            acc1.BillingCountry = 'Test country';
            acc1.BillingStreet = 'Test street';
            acc1.type = 'Ex-Customer';
            accList.add(acc1);
            insert accList;
            
            
            /*List<Account_Extension__c> extList = new List<Account_Extension__c>();
            Account_Extension__c ext = new Account_Extension__c();
            ext.Account__c = accList.get(0).Id;        
            extList.add(ext);
            insert extList; */
            
            List<Product2> productsIns = new List<Product2>();
            Product2 product1 = new Product2(ProductCode = 'ZIA-TRANS-EDITION', Name = 'Zscaler Internet Security Platform', Family = 'ZIA',
                                             IsActive = true);
            productsIns.add(product1);
            Product2 product2 = new Product2(ProductCode = 'ZDX-ADVANCED', Name = 'ZDX Advanced', Family = 'ZDX',
                                             IsActive = true);
            productsIns.add(product2);
            Product2 product3 = new Product2(ProductCode = 'ZS-USER-ELA-PRE', Name = 'Zscaler User ELA Edition', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform', isBundle__c= true);
            productsIns.add(product3);

            Product2 product4 = new Product2(ProductCode = 'ZS-USER-ELA-PRE', Name = 'Test Premium Support', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform', isBundle__c= true);
            productsIns.add(product4);
            
            Product2 product5 = new Product2(ProductCode = 'ZIA-BUS-EDITION', Name = 'Test Premium Support', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform', isBundle__c= true);
            productsIns.add(product5);
                       
            insert productsIns;

            //Custom Settings:
            insert new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'ZDX_Contract_Date', SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZDX-ADVANCED;ZDX-ADV;ZDX-M365');
            insert new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZPA-Remote-PRE;ZS-WFA-BUS-EDITION;ZPA-FED-BUNDLE;ZPA-ZFED-MODERATE');
            Order sorder = new Order(name = 'Test Order 1', AccountId = accList[0].Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(100), Status = 'Draft', Location__c = 'Americas');
            insert sorder;
            
            List<Contract_Detail__c> conDetail = new List<Contract_Detail__c>();
            Contract_Detail__c con = new Contract_Detail__c();
            con.Account_Name__c = accList.get(0).Id;        
            con.Start_Date__c = Date.today();
            con.Product_SKU__c = 'ZIA-TRANS-EDITION';
            con.Is_Bundle_SKU__c  = TRUE;
            
            
            Contract_Detail__c  contract = new Contract_Detail__c();
            contract.Name = 'Test Contract';
            contract.Account_Name__c = accList.get(0).Id;        
            contract.Quantity__c = 5000;
            contract.Contract_Detail_Status__c = 'Active';
            contract.Product_Name__c = productsIns.get(0).Id;
            contract.Do_not_Aggregate__c = false;
            contract.Override_Contract_Detail_Status__c = false;
            contract.Start_Date__c = Date.today().addDays(-100);
            contract.End_Date__c = Date.today().addDays(100);
            contract.Amount_USD__c = 50000.00;
            contract.ZScaler_Product_Family__c = 'ZIA';
            contract.Is_Bundle_SKU__c = true;
            contract.Sales_Order__c = sorder.id;
            contract.Product_SKU__c='ZIA-SANDBOX';
            contract.Price_Per_User__c=500.00;
            conDetail.add(contract);

            Contract_Detail__c  contract1 = new Contract_Detail__c();
            contract1.Name = 'Test Contract1';
            contract1.Account_Name__c = accList.get(1).Id;        
            contract1.Quantity__c = 10000;
            contract1.Contract_Detail_Status__c = 'Active';
            contract1.Product_Name__c = productsIns.get(1).Id;
            contract1.Do_not_Aggregate__c = false;
            contract1.Override_Contract_Detail_Status__c = false;
            contract1.Start_Date__c = Date.today().addDays(-90);
            contract1.End_Date__c = Date.today().addDays(100);
            contract1.Amount_USD__c = 50000.00;
            contract1.ZScaler_Product_Family__c = 'ZDX';
            contract1.Is_Bundle_SKU__c = true;
            contract1.Sales_Order__c = sorder.id;
            conDetail.add(contract1);

            Contract_Detail__c  contract2 = new Contract_Detail__c();
            contract2.Name = 'Test contract2';
            contract2.Account_Name__c = accList.get(1).Id;        
            contract2.Quantity__c = 10000;
            contract2.Contract_Detail_Status__c = 'Active';
            contract2.Product_Name__c = productsIns.get(2).Id;
            contract2.Do_not_Aggregate__c = false;
            contract2.Override_Contract_Detail_Status__c = false;
            contract2.Start_Date__c = Date.today().addDays(-90);
            contract2.End_Date__c = Date.today().addDays(100);
            contract2.Amount_USD__c = 50000.00;
            contract2.ZScaler_Product_Family__c = 'ZIA';
            contract2.Is_Bundle_SKU__c = true;
            contract2.Sales_Order__c = sorder.id;
            contract2.Product_SKU__c='ZIA-FIREWALL';
            contract2.Price_Per_User__c=500.00;
            conDetail.add(contract2);

            Contract_Detail__c  contract3 = new Contract_Detail__c();
            contract3.Name = 'Test contract2';
            contract3.Account_Name__c = accList.get(1).Id;        
            contract3.Quantity__c = 10000;
            contract3.Contract_Detail_Status__c = 'Active';
            contract3.Product_Name__c = productsIns.get(3).Id;
            contract3.Do_not_Aggregate__c = false;
            contract3.Override_Contract_Detail_Status__c = false;
            contract3.Start_Date__c = Date.today().addDays(-90);
            contract3.End_Date__c = Date.today().addDays(100);
            contract3.Amount_USD__c = 50000.00;
            contract3.ZScaler_Product_Family__c = 'ZIA';
            contract3.Is_Bundle_SKU__c = true;
            contract3.MRR_USD__c = 100;
            contract3.Sales_Order__c = sorder.id;
            contract3.Product_SKU__c='ZIA-BW-CTRL';
            contract3.Price_Per_User__c=500.00;
            conDetail.add(contract3);

            Contract_Detail__c  contract4 = new Contract_Detail__c();
            contract4.Name = 'Test contract2';
            contract4.Account_Name__c = accList.get(1).Id;        
            contract4.Quantity__c = 10000;
            contract4.Contract_Detail_Status__c = 'Active';
            contract4.Product_Name__c = productsIns.get(3).Id;
            contract4.Do_not_Aggregate__c = false;
            contract4.Override_Contract_Detail_Status__c = false;
            contract4.Start_Date__c = Date.today().addDays(-90);
            contract4.End_Date__c = Date.today().addDays(100);
            contract4.Amount_USD__c = 50000.00;
            contract4.ZScaler_Product_Family__c = 'ZIA';
            contract4.Is_Bundle_SKU__c = true;
            contract4.Product_SKU__c = 'ZDX-BUS-PRE';
            contract4.MRR_USD__c = 500;
            contract4.Sales_Order__c = sorder.id;
            conDetail.add(contract4);

            Contract_Detail__c  contract5 = new Contract_Detail__c();
            contract5.Name = 'Test contract3';
            contract5.Account_Name__c = accList.get(1).Id;        
            contract5.Quantity__c = 10000;
            contract5.Contract_Detail_Status__c = 'Active';
            contract5.Product_Name__c = productsIns.get(3).Id;
            contract5.Do_not_Aggregate__c = false;
            contract5.Override_Contract_Detail_Status__c = false;
            contract5.Start_Date__c = Date.today().addDays(-90);
            contract5.End_Date__c = Date.today().addDays(100);
            contract5.Amount_USD__c = 50000.00;
            contract5.ZScaler_Product_Family__c = 'ZPA';
            contract5.Is_Bundle_SKU__c = true;
            contract5.Product_SKU__c = 'ZPA-BBA';
            contract5.Sales_Order__c = sorder.id;
            contract5.MRR_USD__c = 900.00;
            conDetail.add(contract5);
            
            Contract_Detail__c  contract6 = new Contract_Detail__c();
            contract6.Name = 'Test contract3';
            contract6.Account_Name__c = accList.get(1).Id;        
            contract6.Quantity__c = 10000;
            contract6.Contract_Detail_Status__c = 'Active';
            contract6.Product_Name__c = productsIns.get(4).Id;
            contract6.Do_not_Aggregate__c = false;
            contract6.Override_Contract_Detail_Status__c = false;
            contract6.Start_Date__c = Date.today().addDays(-90);
            contract6.End_Date__c = Date.today().addDays(100);
            contract6.Amount_USD__c = 50000.00;
            contract6.ZScaler_Product_Family__c = 'ZIA';
            contract6.Is_Bundle_SKU__c = true;
            contract6.Product_SKU__c = 'ZIA-BUS-EDITION';
            contract6.Sales_Order__c = sorder.id;
            contract6.MRR_USD__c = 900.00;
            conDetail.add(contract6);
            
            Contract_Detail__c  contract7 = new Contract_Detail__c();
            contract7.Name = 'Test contract7';
            contract7.Account_Name__c = accList.get(1).Id;        
            contract7.Quantity__c = 10000;
            contract7.Contract_Detail_Status__c = 'Active';
            contract7.Product_Name__c = productsIns.get(4).Id;
            contract7.Do_not_Aggregate__c = false;
            contract7.Override_Contract_Detail_Status__c = false;
            contract7.Start_Date__c = Date.today().addDays(-90);
            contract7.End_Date__c = Date.today().addDays(100);
            contract7.Amount_USD__c = 50000.00;
            contract7.ZScaler_Product_Family__c = 'ZIA';
            contract7.Is_Bundle_SKU__c = true;
            contract7.Product_SKU__c = 'ZIA-DLP-ENT';
            contract7.Sales_Order__c = sorder.id;
            contract7.MRR_USD__c = 900.00;
            contract7.Price_Per_User__c=500.00;
            conDetail.add(contract7);
            
            insert conDetail;
            
            List<Contract_Detail__c> contractDetails1 = [SELECT Id, Account_Name__c, Start_Date__c, Product_SKU__c 
                                                         FROM Contract_Detail__c ];
            ZDX_Cloud_Usage__c zdx = new ZDX_Cloud_Usage__c();	
            zdx.Incident_Count__c=10;	
            zdx.L30_Device_Count__c=12;	
            zdx.L30D_User_Count__c=14;	
            zdx.Account__c=acc.Id;	
            zdx.External_ID__c='zscalerid123';	
            insert zdx;	
                        	
            Zscaler_Cloud_ID__c zsc =new Zscaler_Cloud_ID__c();	
            zsc.Account__c=acc.Id;	
            zsc.Latest_ZDX_Cloud_Usage__c=zdx.Id;	
            insert zsc;
            
            Test.startTest();
            
            UpdateContractDetailsToAccountBatchSch Schedule = new UpdateContractDetailsToAccountBatchSch();
            String sch = '0 0 23 * * ?';
            system.schedule('Test', sch, Schedule);
            
            /*UpdateContractDetailsToAccountBatch instance = new UpdateContractDetailsToAccountBatch();
            Id jobid = Database.executeBatch(instance);
            system.debug('-=-=- jobid -=- '+jobid);*/
            Test.stopTest();
        }
        
    }
    @IsTest static void testSchedule1(){
        User sysAdmin = [SELECT Id FROM User LIMIT 1];
        System.runAs(sysAdmin) {
            
            List<Account> accList = new List<Account>();
            Account acc = new Account();
            acc.Name = 'Account Historical 7';
            acc.BillingCity = 'Test city';
            acc.BillingCountry = 'Test country';
            acc.BillingStreet = 'Test street';
            acc.type = 'Customer';
            //acc.Account_Renewable_ACV__c=60000;
            accList.add(acc);
            insert accList;
            
            List<Product2> productsIns = new List<Product2>();
           /* Product2 product2 = new Product2(ProductCode = 'ZDX-ADVANCED', Name = 'ZDX Advanced', Family = 'ZDX',
                                             IsActive = true);
            productsIns.add(product2);*/
            
            Product2 product5 = new Product2(ProductCode = 'ZIA-BUS-EDITION', Name = 'Test Premium Support', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform');
            productsIns.add(product5);
            Product2 product6 = new Product2(ProductCode = 'ZPA-BUS-EDITION', Name = 'Test Premium Support', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform', isBundle__c= true);
            productsIns.add(product6);     
            
            Product2 product7 = new Product2(ProductCode = 'ZS-USER-ELA-PRE', Name = 'Zscaler User ELA Edition', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform', isBundle__c= true);
            productsIns.add(product7);
                       
            Product2 product8 = new Product2(ProductCode = 'ZPA-BUS', Name = 'ZPA Business Bundle', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform', isBundle__c= true);
            productsIns.add(product8);
                       
            insert productsIns;

            SBQQ__LookupData__c lookupData = new SBQQ__LookupData__c(SBQQ__Product__c = productsIns[3].Id,Price_List__c='FY23 Upsell Price List',List_Price__c=66.73);
            insert lookupData;

            //Custom Settings:
            insert new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'ZDX_Contract_Date', SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZDX-ADVANCED;ZDX-ADV;ZDX-M365');
            insert new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZPA-Remote-PRE;ZS-WFA-BUS-EDITION;ZPA-FED-BUNDLE;ZPA-ZFED-MODERATE');
            Order sorder = new Order(name = 'Test Order 1', AccountId = accList[0].Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(100), Status = 'Draft', Location__c = 'Americas');
            insert sorder;

            List<Contract_Detail__c> conDetail = new List<Contract_Detail__c>();
            
            /*Contract_Detail__c  contract = new Contract_Detail__c();
            contract.Name = 'Test Contract';
            contract.Account_Name__c = accList.get(0).Id;        
            contract.Quantity__c = 5000;
            contract.Contract_Detail_Status__c = 'Active';
            contract.Product_Name__c = productsIns.get(0).Id;
            contract.Do_not_Aggregate__c = false;
            contract.Override_Contract_Detail_Status__c = false;
            contract.Start_Date__c = Date.today().addDays(-100);
            contract.End_Date__c = Date.today().addDays(100);
            contract.Amount_USD__c = 50000.00;
            contract.ZScaler_Product_Family__c = 'ZIA';
            contract.Is_Bundle_SKU__c = true;
            contract.Sales_Order__c = sorder.id;
            conDetail.add(contract);  */
            /*
            Contract_Detail__c  contract1 = new Contract_Detail__c();
            contract1.Name = 'Test Contract1';
            contract1.Account_Name__c = accList.get(0).Id;        
            contract1.Quantity__c = 10000;
            contract1.Contract_Detail_Status__c = 'Active';
            contract1.Product_Name__c = productsIns.get(2).Id;
            contract1.Do_not_Aggregate__c = false;
            contract1.Override_Contract_Detail_Status__c = false;
            contract1.Start_Date__c = Date.today().addDays(-90);
            contract1.End_Date__c = Date.today().addDays(100);
            contract1.Amount_USD__c = 50000.00;
            contract1.ZScaler_Product_Family__c = 'ZDX';
            contract1.Is_Bundle_SKU__c = true;
            contract1.Sales_Order__c = sorder.id;
            conDetail.add(contract1);  */

            Contract_Detail__c  contract2 = new Contract_Detail__c();
            contract2.Name = 'Test contract2';
            contract2.Account_Name__c = accList.get(0).Id;        
            contract2.Quantity__c = 10000;
            contract2.Contract_Detail_Status__c = 'Active';
            contract2.Product_Name__c = productsIns.get(0).Id;
            contract2.Do_not_Aggregate__c = false;
            contract2.Override_Contract_Detail_Status__c = false;
            contract2.Start_Date__c = Date.today().addDays(-90);
            contract2.End_Date__c = Date.today().addDays(100);
            contract2.Amount_USD__c = 50000.00;
            contract2.ZScaler_Product_Family__c = 'ZIA';
            contract2.Is_Bundle_SKU__c = true;
            contract2.Sales_Order__c = sorder.id;
            conDetail.add(contract2);

            Contract_Detail__c  contract3 = new Contract_Detail__c();
            contract3.Name = 'Test contract2';
            contract3.Account_Name__c = accList.get(0).Id;        
            contract3.Quantity__c = 10000;
            contract3.Contract_Detail_Status__c = 'Active';
            contract3.Product_Name__c = productsIns.get(0).Id;
            contract3.Do_not_Aggregate__c = false;
            contract3.Override_Contract_Detail_Status__c = false;
            contract3.Start_Date__c = Date.today().addDays(-90);
            contract3.End_Date__c = Date.today().addDays(100);
            contract3.Amount_USD__c = 50000.00;
            contract3.ZScaler_Product_Family__c = 'ZIA';
            contract3.Is_Bundle_SKU__c = true;
            contract3.MRR_USD__c = 100;
            contract3.Sales_Order__c = sorder.id;
            conDetail.add(contract3);

            Contract_Detail__c  contract4 = new Contract_Detail__c();
            contract4.Name = 'Test contract2';
            contract4.Account_Name__c = accList.get(0).Id;        
            contract4.Quantity__c = 10000;
            contract4.Contract_Detail_Status__c = 'Active';
            contract4.Product_Name__c = productsIns.get(0).Id;
            contract4.Do_not_Aggregate__c = false;
            contract4.Override_Contract_Detail_Status__c = false;
            contract4.Start_Date__c = Date.today().addDays(-90);
            contract4.End_Date__c = Date.today().addDays(100);
            contract4.Amount_USD__c = 50000.00;
            contract4.ZScaler_Product_Family__c = 'ZIA';
            contract4.Is_Bundle_SKU__c = true;
            contract4.Product_SKU__c = 'ZDX-BUS-PRE';
            contract4.MRR_USD__c = 500;
            contract4.Sales_Order__c = sorder.id;
            conDetail.add(contract4);
            
            Contract_Detail__c  contract5 = new Contract_Detail__c();
            contract5.Name = 'Test contract2';
            contract5.Account_Name__c = accList.get(0).Id;        
            contract5.Quantity__c = 10000;
            contract5.Contract_Detail_Status__c = 'Active';
            contract5.Product_Name__c = productsIns.get(1).Id;
            contract5.Do_not_Aggregate__c = false;
            contract5.Override_Contract_Detail_Status__c = false;
            contract5.Start_Date__c = Date.today().addDays(-90);
            contract5.End_Date__c = Date.today().addDays(100);
            contract5.Amount_USD__c = 50000.00;
            contract5.ZScaler_Product_Family__c = 'ZPA';
            contract5.Is_Bundle_SKU__c = true;
            contract5.Product_SKU__c = 'ZPA-BUS-EDITION';
            contract5.MRR_USD__c = 100;
            contract5.Sales_Order__c = sorder.id;
            conDetail.add(contract5);

            Contract_Detail__c  contract6 = new Contract_Detail__c();
            contract6.Name = 'Test contract6';
            contract6.Account_Name__c = accList.get(0).Id;        
            contract6.Quantity__c = 10000;
            contract6.Contract_Detail_Status__c = 'Active';
            contract6.Product_Name__c = productsIns.get(3).Id;
            contract6.Do_not_Aggregate__c = false;
            contract6.Override_Contract_Detail_Status__c = false;
            contract6.Start_Date__c = Date.today().addDays(-90);
            contract6.End_Date__c = Date.today().addDays(100);
            contract6.Amount_USD__c = 50000.00;
            contract6.ZScaler_Product_Family__c = 'ZPA';
            contract6.Is_Bundle_SKU__c = true;
            contract6.Product_SKU__c = 'ZPA-BUS';
            contract6.MRR_USD__c = 100;
            contract6.Sales_Order__c = sorder.id;
            conDetail.add(contract6);

            insert conDetail;
            //conflict
            List<Contract_Detail__c> contractDetails1 = [SELECT Id, Account_Name__c, Start_Date__c, Product_SKU__c 
                                                         FROM Contract_Detail__c ];
            ZDX_Cloud_Usage__c zdx = new ZDX_Cloud_Usage__c();
            zdx.Incident_Count__c=10;
            zdx.L30_Device_Count__c=12;
            zdx.L30D_User_Count__c=14;
            zdx.Account__c=acc.Id;
            zdx.External_ID__c='zscalerid123';
            insert zdx;
            
            Zscaler_Cloud_ID__c zsc =new Zscaler_Cloud_ID__c();
            zsc.Account__c=acc.Id;
            zsc.Latest_ZDX_Cloud_Usage__c=zdx.Id;
            insert zsc;
            
            Test.startTest();
            
            UpdateContractDetailsToAccountBatchSch Schedule = new UpdateContractDetailsToAccountBatchSch();
            String sch = '0 0 23 * * ?';
            system.schedule('Test', sch, Schedule);
            Set<Id> Idset = new Set<Id>();
            Idset.add(accList.get(0).Id);
            UpdateContractDetailsToAccountBatch rollup = new UpdateContractDetailsToAccountBatch(Idset);   
        	Database.executeBatch(rollup,1);
            Test.stopTest();
        }
    }
    
    //testMethod
    @IsTest static void testSchedule2(){ 
    
          User sysAdmin = [SELECT Id FROM User LIMIT 1];
          System.runAs(sysAdmin) {
            
            List<Account> accList = new List<Account>();
            Account acc = new Account();
            acc.Name = 'Account Historical 7';
            acc.BillingCity = 'Test city';
            acc.BillingCountry = 'Test country';
            acc.BillingStreet = 'Test street';
            acc.type = 'Customer';
            //acc.Account_Renewable_ACV__c=60000;
            accList.add(acc); 
              
            Account acc1 = new Account();
            acc1.Name = 'Account Historical 8';
            acc1.BillingCity = 'Test city';
            acc1.BillingCountry = 'Test country';
            acc1.BillingStreet = 'Test street';
            acc1.type = 'Customer';
            //acc.Account_Renewable_ACV__c=60000;
            accList.add(acc1);
            
            Account acc2 = new Account();
            acc2.Name = 'Account Historical 9';
            acc2.BillingCity = 'Test city';
            acc2.BillingCountry = 'Test country';
            acc2.BillingStreet = 'Test street';
            acc2.type = 'Customer';
            //acc.Account_Renewable_ACV__c=60000;
            accList.add(acc2);
            
            Account acc3 = new Account();
            acc3.Name = 'Account Historical 10';
            acc3.BillingCity = 'Test city';
            acc3.BillingCountry = 'Test country';
            acc3.BillingStreet = 'Test street';
            acc3.type = 'Customer';
            accList.add(acc3);

            insert accList;
            
            List<Product2> productsIns = new List<Product2>();
           /* Product2 product2 = new Product2(ProductCode = 'ZDX-ADVANCED', Name = 'ZDX Advanced', Family = 'ZDX',
                                             IsActive = true');
            productsIns.add(product2);*/
            
            
            Product2 product1 = new Product2(ProductCode = 'ZS-USER-ELA-PRE', Name = 'Zscaler User ELA Edition', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform', isBundle__c= true);
            productsIns.add(product1);
            
            Product2 prod2 = new Product2(ProductCode = 'ZDX-M365', Name = 'Zscaler M365', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform', isBundle__c= true);
            productsIns.add(prod2);
            
            Product2 prod3 = new Product2(ProductCode = 'ZIA-TFORM-EDITION-LU', Name = 'Zscaler TFORM  Edition', Family = 'Zscaler Products',
                                             IsActive = true, Product_Family__c='Bundle Platforms', Product_Line__c='Cross Platform', isBundle__c= true);
            productsIns.add(prod3);
                       
            insert productsIns;

            //Custom Settings:
            insert new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'ZDX_Contract_Date', SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZDX-ADVANCED;ZDX-ADV;ZDX-M365');
            insert new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZPA-Remote-PRE;ZS-WFA-BUS-EDITION;ZPA-FED-BUNDLE;ZPA-ZFED-MODERATE');
            Order sorder = new Order(name = 'Test Order 1', AccountId = accList[0].Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(100), Status = 'Draft', Location__c = 'Americas');
           	insert sorder;
            Order sorder2 = new Order(name = 'Test Order 2', AccountId = accList[1].Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24868', EffectiveDate = date.today(), EndDate=date.today().adddays(100), Status = 'Draft', Location__c = 'Americas');
            insert sorder2;
            Order sorder3 = new Order(name = 'Test Order 3', AccountId = accList[2].Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24869', EffectiveDate = date.today(), EndDate=date.today().adddays(100), Status = 'Draft', Location__c = 'Americas');
            insert sorder3;

            List<Contract_Detail__c> conDetail = new List<Contract_Detail__c>();
            
            Contract_Detail__c  contract4 = new Contract_Detail__c();
            contract4.Name = 'Test contract2';
            contract4.Account_Name__c = accList.get(0).Id;        
            contract4.Quantity__c = 10000;
            contract4.Contract_Detail_Status__c = 'Active';
            contract4.Product_Name__c = productsIns.get(0).Id;
            contract4.Do_not_Aggregate__c = false;
            contract4.Override_Contract_Detail_Status__c = false;
            contract4.Start_Date__c = Date.today().addDays(-90);
            contract4.End_Date__c = Date.today().addDays(100);
            contract4.Amount_USD__c = 50000.00;
            contract4.ZScaler_Product_Family__c = 'ZDX';
            contract4.Is_Bundle_SKU__c = true;
            contract4.Product_SKU__c = 'ZS-USER-ELA-PRE';
            contract4.MRR_USD__c = 500;
            contract4.Sales_Order__c = sorder.id;
            conDetail.add(contract4);
              
            Contract_Detail__c  contract5 = new Contract_Detail__c();
            contract5.Name = 'Test contract3';
            contract5.Account_Name__c = accList.get(1).Id;        
            contract5.Quantity__c = 20000;
            contract5.Contract_Detail_Status__c = 'Active';
            contract5.Product_Name__c = productsIns.get(1).Id;
            contract5.Do_not_Aggregate__c = false;
            contract5.Override_Contract_Detail_Status__c = false;
            contract5.Start_Date__c = Date.today().addDays(-90);
            contract5.End_Date__c = Date.today().addDays(100);
            contract5.Amount_USD__c = 50000.00;
            contract5.ZScaler_Product_Family__c = 'ZDX';
            contract5.Is_Bundle_SKU__c = true;
            contract5.Product_SKU__c = 'ZDX-M365';
            contract5.MRR_USD__c = 500;
            contract5.Sales_Order__c = sorder2.id;
            conDetail.add(contract5);
            
             Contract_Detail__c  contract6 = new Contract_Detail__c();
            contract6.Name = 'Test contract4';
            contract6.Account_Name__c = accList.get(2).Id;        
            contract6.Quantity__c = 30000;
            contract6.Contract_Detail_Status__c = 'Active';
            contract6.Product_Name__c = productsIns.get(2).Id;
            contract6.Do_not_Aggregate__c = false;
            contract6.Override_Contract_Detail_Status__c = false;
            contract6.Start_Date__c = Date.today().addDays(-90);
            contract6.End_Date__c = Date.today().addDays(100);
            contract6.Amount_USD__c = 50000.00;
            contract6.ZScaler_Product_Family__c = 'ZDX';
            contract6.Is_Bundle_SKU__c = true;
            contract6.Product_SKU__c = 'ZIA-TFORM-EDITION-LU';
            contract6.MRR_USD__c = 500;
            contract6.Sales_Order__c = sorder3.id;
            conDetail.add(contract6);
            
            insert conDetail;
            System.debug('**Id : '+conDetail);
            Test.startTest();
            
            Set<Id> Idset = new Set<Id>();
            Idset.add(accList.get(0).Id);
            Idset.add(accList.get(1).Id);
            Idset.add(accList.get(2).Id);
            Idset.add(accList.get(3).Id);
            UpdateContractDetailsToAccountBatch rollup = new UpdateContractDetailsToAccountBatch(Idset);   
        	Database.executeBatch(rollup);
            Test.stopTest();
              
    }
	}
}