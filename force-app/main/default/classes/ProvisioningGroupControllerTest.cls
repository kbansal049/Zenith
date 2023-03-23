/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-11-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public class ProvisioningGroupControllerTest {
    @testSetup
    public static void testSetup(){
        Triggerhandler.bypass('OpportunityTriggerHandler');
        Triggerhandler.bypass('AccountTriggerHandler');
        TriggerUtility.SkipOppTriggerExecuted();
        TriggerUtility.OpptySplitTriggerFCexecuted();
        TriggerUtility.SkipAccTriggerExecuted();
        
        Product2 crossProd = new Product2(Name='TestProduct', product_line__c='Cross Platform', poc_products__c='Regular', IsActive=True,
                                      SKU_Type__c='GA', Provisioning_Product_Family__c='Bundles', Is_Applicable_for_POC__c=true,
                                      ProductCode='Z-TLZ-TI-PRE',Provisioning_Broker_Eligible__c=false, isBundle__c=true,Provisioning_Sub_Product_Line__c='CBI', provisioning_Contact_Type__c='BUSINESS_PRIMARY;EC_CONTACT');
        insert crossProd;

        Product2 crossProd2 = new Product2(Name='TestProduct2', product_line__c='Cross Platform', poc_products__c='Regular', IsActive=True,
                                      SKU_Type__c='GA', Provisioning_Product_Family__c='AddOn', Is_Applicable_for_POC__c=true,
                                      ProductCode='Z-TLZ-TI-PRE', isBundle__c=true, provisioning_Contact_Type__c='BUSINESS_PRIMARY;EC_CONTACT');
        insert crossProd2;
       
        product_license__c prodLicense=new Product_license__c(product__c=crossProd.id, provisioning_License__c='Z_ZDX_STD',cross_platform_bundle__c=true,Cross_Platform_Exception__c=true);
        insert prodLicense;
        
        Account acc = new account();
        acc.Name = 'TestAccount';
        acc.Type='Customer';
        acc.Prospect_Type__c='Pipeline';
        insert acc;

        Contact con = new Contact();
        con.LastName = 'test12';
        con.email = 'test11@gmail.com';
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];

        User us = new user();
        us.LastName = 'Test Code Welcome';
        us.Email = 'test11@gmail.com';
        us.Alias = 'Tcode';
        us.Username = 'Test.gsfcd223@test.com';
        us.ManagerId = '0054u0000075Jn0AAE';
        us.CommunityNickname = 'test1211';
        us.LocaleSidKey = 'en_US';
        us.TimeZoneSidKey = 'GMT';
        us.ProfileID = p.id;
        us.LanguageLocaleKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        insert us;
        
        DefaultData__c Dff = new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = acc.id, Category__c='Provisioning Request',Priority__c='Medium (P3)',
                                                Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning');
        insert Dff;
        
        Zscaler_cloud_Id__c zci=new Zscaler_cloud_Id__c(name='testZCI', Zscaler_Cloud_Domain__c='allweiler.de',account__c=acc.Id, status__c='Provisioned');
        insert zci;

        Zscaler_cloud_Id__c zci2=new Zscaler_cloud_Id__c(name='testZCI2', Zscaler_Cloud_Domain__c='allweiler.de',account__c=acc.Id, status__c='Provisioned');
        insert zci2;
		
		SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Domain__c ='Test';
        insert quote;
        
        Opportunity opp = new Opportunity();
        opp.Name='Testopp';
        opp.StageName = '3 - Sponsorship';
        opp.CloseDate = system.today()+100;
        opp.SE_Manager__c = 'jwatkins@zscaler.com.invalid';
        opp.SBQQ__PrimaryQuote__c=quote.id;
        insert opp;
        
         opportunity opp1 = new opportunity(Name = 'Test opportunity', 
                                          AccountId = acc.Id, 
                                          StageName = '1 - Discovery & Qualification', 
                                          CloseDate = system.Today()+30);

        Id recordTypeIdpr = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();

        List<Provisioning_Request__c> ListPR= new List<Provisioning_Request__c>();
        Provisioning_Request__c testPR1 = new Provisioning_Request__c(Organization_Domain__c = 'test1.domain.com', 
        Preferred_Cloud__c = 'Zscaler.net', 
        Send_Initial_l__c = 'SE',
        SE__c = us.Id,
        Zscaler_Cloud_ID__c=zci2.id,
        Account__c = acc.Id,
        Opportunity__c=opp1.Id, 
        RecordTypeId = recordTypeIdpr);
        ListPR.add(testPR1);
        insert ListPR;
        
        Id recordtypeId2 = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Provisioning_Group__c pgroup2 = new Provisioning_Group__c();
        pgroup2.Comments__c ='Test3';
        pgroup2.Provisioning_Broker_Eligible__c= false;
        pgroup2.Product_Line__c='ZIA';
        pgroup2.Provisioning_Process__c='New Tenant';
        pgroup2.Organization_Domain__c ='uoflhealthcare.org';
        pgroup2.Status__c='Provisioned';
        pgroup2.Approval_Status__c='Submitted';
        pgroup2.Sub_Status__c='';
        pgroup2.PG_Request_Type__c='Create';
        pgroup2.Provisioning_Type__c='Auto';
        pgroup2.Preferred_Cloud__c='Zscaler.net';
        pgroup2.Start_Date__c = System.today();
        pgroup2.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup2.Number_of_Extensions__c = 6;
        pgroup2.RecordTypeId = recordtypeId2;
        pgroup2.Provisioning_Process__c = 'Decommission';
        pgroup2.Zscaler_Cloud_ID__c=zci.id;
        pgroup2.opportunity__c=opp.id;
        insert pgroup2;
		
		Provisioning_Product__c provprod2 = new Provisioning_Product__c();
        provprod2.Name = 'Test2';
        provprod2.Product__c=crossProd2.id;
        provprod2.Quantity__c = 5;
        provprod2.Provisioning_Group__c=pgroup2.id;
        provprod2.Start_Date__c = system.today();
        provprod2.End_Date__c=system.today()+360;
        insert provprod2;        
        
        Provisioning_Contact__c pcon2 = new Provisioning_Contact__c();
        pcon2.Type__c = 'SALES_ENGINEER';
        pcon2.Provisioning_Group__c=pgroup2.Id;
        insert pcon2;
        
        Id recordtypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Provisioning_Group__c pgroup = new Provisioning_Group__c();
         pgroup.Provisioning_Broker_Eligible__c= false;
        pgroup.Comments__c ='Test3';
        pgroup.Product_Line__c='ZIA';
        pgroup.Provisioning_Process__c='New Tenant';
        pgroup.Organization_Domain__c ='uoflhealthcare.org';
        pgroup.Status__c='Initiated';
        pgroup.Approval_Status__c='Submitted';
        pgroup.Sub_Status__c='';
        pgroup.PG_Request_Type__c='Create';
        pgroup.Provisioning_Type__c='Auto';
        pgroup.Preferred_Cloud__c='Zscaler.net';
        pgroup.Start_Date__c = System.today();
        pgroup.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup.Number_of_Extensions__c = 6;
        pgroup.RecordTypeId = recordtypeId;
        pgroup.Provisioning_Process__c = 'Decommission';
        pgroup.Zscaler_Cloud_ID__c=zci.id;
        pgroup.opportunity__c=opp.id;
        insert pgroup;
		
		Provisioning_Product__c provprod = new Provisioning_Product__c();
        provprod.Name = 'Test2';
        provprod.Product__c=crossProd.id;
        provprod.Quantity__c = 5;
        provprod.Provisioning_Group__c=pgroup.id;
        provprod.Start_Date__c = system.today();
        provprod.End_Date__c=system.today()+360;
        Insert provprod;        
        
        Provisioning_Contact__c pcon = new Provisioning_Contact__c();
        pcon.Type__c = 'SALES_ENGINEER';
        pcon.Provisioning_Group__c=pgroup.Id;
        Insert pcon;
        
        product_license__c pl=new product_license__c(provisioning_license__c='ZS_WFA_BUS_EDITION',cross_platform_bundle__c=true, product__c=crossProd.id);
        insert pl;
        
        id priceBookId=Test.getStandardPriceBookId();
        PriceBookEntry pbe=new PriceBookEntry(priceBook2Id=priceBookId, Product2Id=crossProd.Id, unitPrice=100.00, isActive=true);
        insert pbe;
        
        OpportunityLineItem oli=new OpportunityLineItem(OpportunityId=opp.id, Quantity=5, PriceBookEntryId=pbe.id, TotalPrice=pbe.unitPrice);
        insert oli;
        
        PriceBookEntry pbe2=new PriceBookEntry(priceBook2Id=priceBookId, Product2Id=crossProd2.Id, unitPrice=100.00, isActive=true);
        insert pbe2;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name='Testopp2';
        opp2.StageName = '3 - Sponsorship';
        opp2.CloseDate = system.today()+100;
        opp2.SE_Manager__c = 'jwatkins@zscaler.com.invalid';
        insert opp2;
        
        OpportunityLineItem oli2=new OpportunityLineItem(OpportunityId=opp2.id, Quantity=5, PriceBookEntryId=pbe2.id, TotalPrice=pbe.unitPrice);
        insert oli2;
    }
    
    @isTest
    public static void testproductsInThisCrossPlatform(){
        String crossProd=[select id,productCode from product2 where name='TestProduct' limit 1].productCode;
        Test.startTest();
        	ProvisioningGroupController.productsInThisCrossPlatform(crossProd);
        Test.stopTest();
    }
    
    @isTest
    public static void testcheckifPrimaryQuoteExist(){
        String oppId=[select id from opportunity where name='testOpp' limit 1].id;
        Test.startTest();
        	ProvisioningGroupController.checkifPrimaryQuoteExist(oppid);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetAccountData(){
        String accId=[select id from account where name='TestAccount' limit 1].id;
        Test.startTest();
        	ProvisioningGroupController.getAccountData(accId);
        Test.stopTest();
    }
   
    @isTest
    public static void testgetPOVProductList(){
        Test.startTest();
        	ProvisioningGroupController.getPOVProductList('Cross Platform','FY22 Single Tier Price List');
        	ProvisioningGroupController.getPOVProductListCrossPlatform('ZIA','FY22 Single Tier Price List');
        	ProvisioningGroupController.getPOVProductListCrossPlatform('ZDX','FY22 Single Tier Price List');
        Test.stopTest();
    }
    
    @isTest
    public static void testElseCheckifDraftexists(){
        string oppId=[select id from opportunity where name='testOpp' limit 1].id;
        Test.startTest();
        	ProvisioningGroupController.checkifDraftexists(oppid);
        Test.stopTest();
    }
    
    @isTest
    public static void testcheckifDraftexists(){
        string oppId=[select id from opportunity where name='testOpp' limit 1].id;
        Test.startTest();
        ProvisioningGroupController.checkifDraftexists('abc');
        Test.stopTest();
    }
    
    @isTest
    public static void testgetALLProductSKUforTable(){
        string prodLine=[select id,product_Line__c from product2 where name='testProduct' limit 1].product_Line__c;
        Test.startTest();
        	ProvisioningGroupController.getALLProductSKUforTable(new List<string>{prodLine},'getALLProductSKUforTable');
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateProvisioningDetails(){
        String accId = [SELECT id FROM Account LIMIT 1].id;
        String oppId = [SELECT id FROM Opportunity LIMIT 1].id;
        List<string> selProd = new List<string>{'ZIA','ZPA','ZDX','Posture Control'};
        
        //String Json ='{"domain": "uoflhealthcare.org","opportunityId":"'+oppId+'","accountId": "0017000001CnQkVAAV","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": true,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": true,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": true,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        //String json = '{"domain":"tenpo1212.cl","opportunityId":"'+oppId+'","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","crossPlatformSelected":false,"postureControlSelected":false,"selectedPostureControlProducts":[],"selectedPostureControlProdAddOn":[],"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":false,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';
		//String json = '{"domain":"tenpo1212.cl","opportunityId":"'+oppId+'","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","crossPlatformSelected":false,"postureControlSelected":false,"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":false,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":true,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","productAddonnID":"01t4u00000dIW86AAG","isCBI":false,"isDeception":true,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';     
		String json = '{"domain":"tenpo1212.cl","opportunityId":"'+oppId+'","additionalDomain":"testDomain.com","preferedZIAReason":"Test Reason","comments":"Test comments","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","crossPlatformSelected":false,"postureControlSelected":false,"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":false,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":true,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","productAddonnID":"01t4u00000dIW86AAG","isCBI":false,"isDeception":true,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';     
        String json2 = '{"domain":"tenpo1212.cl","opportunityId":"'+oppId+'","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","crossPlatformSelected":true,"postureControlSelected":true,"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":true,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';     

		String json3 = '{"domain":"tenpo1212.cl","opportunityId":"'+oppId+'","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","crossPlatformSelected":false,"postureControlSelected":false,"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":true,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZS-WFA-Business-Edition","productCode":"ZS-WFA-Business-Edition","prodline":"Cross Platform","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';        Test.startTest();
            try{
                TriggerHandler.bypass('ProvisioningGroupTriggerHandler');
                ProvisioningGroupController.createProvisioningDetails(json, selProd);
                TriggerHandler.clearByPass('ProvisioningGroupTriggerHandler');
                //ProvisioningGroupController.createProvisioningDetails(json2, selProd);
                //TriggerHandler.bypass('ProvisioningGroupTriggerHandler');

               //ProvisioningGroupController.createProvisioningDetails(json3, selProd);
            }
            catch(exception e){
            }
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateProvisioningDetails2(){
        String accId = [SELECT id FROM Account LIMIT 1].id;
        String oppId = [SELECT id FROM Opportunity LIMIT 1].id;
        List<string> selProd = new List<string>{'ZIA','ZPA','ZDX','Posture Control'};
        
        //String Json ='{"domain": "uoflhealthcare.org","opportunityId":"'+oppId+'","accountId": "0017000001CnQkVAAV","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": true,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": true,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": true,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        //String json = '{"domain":"tenpo1212.cl","opportunityId":"'+oppId+'","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","crossPlatformSelected":false,"postureControlSelected":false,"selectedPostureControlProducts":[],"selectedPostureControlProdAddOn":[],"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":false,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';
		String json = '{"domain":"tenpo1212.cl","opportunityId":"'+oppId+'","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","crossPlatformSelected":false,"postureControlSelected":false,"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":false,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":true,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","productAddonnID":"01t4u00000dIW86AAG","isCBI":false,"isDeception":true,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';     
        String json2 = '{"domain":"tenpo1212.cl","opportunityId":"'+oppId+'","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","crossPlatformSelected":true,"postureControlSelected":true,"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":true,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';     
		String json3 = '{"domain":"tenpo1212.cl","workloadCommunicationOnly":true,"opportunityId":"'+oppId+'","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","crossPlatformSelected":false,"postureControlSelected":false,"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":true,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZS-WFA-Business-Edition","productCode":"ZS-WFA-Business-Edition","prodline":"Cross Platform","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';
        Test.startTest();
            try{
                //ProvisioningGroupController.createProvisioningDetails(json, selProd);
                //ProvisioningGroupController.createProvisioningDetails(json2, selProd);
                ProvisioningGroupController.createProvisioningDetails(json3, selProd);
            }
            catch(exception e){
            }
        Test.stopTest();
    }
    
    @isTest
    public static void testElsecreateProvisioningDetails(){
        String accId = [SELECT id FROM Account LIMIT 1].id;
        string oppId = [select id from opportunity limit 1].id;
        //String Json = '{"domain": "uoflhealthcare.org","opportunityId":"'+oppId+'","accountId": "0017000001CnQkVAAV","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": true, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        String Json = '{"domain": "uoflhealthcare.org","opportunityId":"'+oppId+'","accountId": "'+accId+'","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": true,"postureControlSelected":true ,"selectedPostureControlProducts": "ZPC-ADV-PRE", "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        List<string> selProd = new List<string>{'ZIA'};
        test.startTest();
        ProvisioningGroupController.createProvisioningDetails(json, selProd);
        ProvisioningGroupController.getCrossPlatformProductsToShow();
        test.stopTest();
    }
    
    @isTest
    public static void testgetZIAcloud(){
        string accId=[select id from account where name='TestAccount' limit 1].id;
        Test.startTest();
        	ProvisioningGroupController.getZIAcloud(accId);
        Test.stopTest();
    }

    @isTest
    public static void testgetZIAcloudfromPRG(){
        string accId=[select id from account where name='TestAccount' limit 1].id;
        Test.startTest();
        	ProvisioningGroupController.getZIAcloudfromPRG(accId);
        Test.stopTest();
    }
    @isTest
    public static void testgetZIAcloudfromPR(){
        string accId=[select id from account where name='TestAccount' limit 1].id;
        Test.startTest();
        	ProvisioningGroupController.getZIAcloudfromPR(accId);
        Test.stopTest();
    }
    
    @istest
    public static void testupdateProvisioningDetail(){
        test.startTest();
        string selTenant=[select id from zscaler_cloud_Id__c where name='testZCI' limit 1].id;
        string oppId=[select id from opportunity where name='testOpp' limit 1].id;
        string pgId=[select id from provisioning_group__c where status__c='Provisioned' limit 1].id;
        System.debug('selTenant :'+selTenant+' oppId :'+oppId+' pgId :'+pgId);
        System.debug('>>>>> :'+[select id from provisioning_group__c where status__c='Provisioned' limit 1]);
        ProvisioningGroupController.updateProvisioningDetail(selTenant, pgId, oppId);
        ProvisioningGroupController.fetchPGRelatedListsToClone(selTenant);
        test.stopTest();
    }
    @isTest
    public static void testgetDraftJSON(){//done
        Id recordtypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Provisioning_Group__c pgroup = new Provisioning_Group__c();
         pgroup.Provisioning_Broker_Eligible__c= false;
        pgroup.Comments__c ='Test3';
        pgroup.Product_Line__c='ZIA';
        pgroup.Provisioning_Process__c='New Tenant';
        pgroup.Organization_Domain__c ='uoflhealthcare.org';
        pgroup.Status__c='Archived';
        pgroup.Approval_Status__c='Submitted';
        pgroup.Sub_Status__c='';
        pgroup.PG_Request_Type__c='Create';
        pgroup.Provisioning_Type__c='Auto';
        pgroup.Preferred_Cloud__c='Zscaler.net';
        pgroup.Start_Date__c = System.today();
        pgroup.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup.Number_of_Extensions__c = 6;
        pgroup.RecordTypeId = recordtypeId;
        pgroup.Provisioning_Process__c = 'Decommission';
        insert pgroup;
        string random='random';
        
        Test.startTest();
        	Provisioning_Group__c pg=ProvisioningGroupController.getDraftJSON(pgroup.Id, random);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetRequiredContacts(){//done
        List<string> selectedProduct=new List<string>();
        selectedProduct.add('Z-TLZ-TI-PRE');
        Test.startTest();
        	ProvisioningGroupController.getRequiredContacts(selectedProduct);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetTenantDetails(){
        string zscalerId=[select id from zscaler_cloud_ID__c where name='testZCI' limit 1].id; 
        Test.startTest();
        	ProvisioningGroupController.getTenantDetails(zscalerId);
        Test.stopTest();
    }

    @isTest
    public static void testGetTenantDetailsPR(){
        string zscalerId=[select id from zscaler_cloud_ID__c where name='testZCI2' limit 1].id; 
        Test.startTest();
        	ProvisioningGroupController.getTenantDetailsfromPR(zscalerId);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateDraftProvisioningRecords(){//done
        String accId = [SELECT id FROM Account LIMIT 1].id;
        string oppId = [select id from opportunity where name='testOpp' limit 1].id;
        //String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId": "'+oppId+'","accountId": "0017000001CnQkVAAV","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId": "'+oppId+'","accountId": "'+accId+'","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        Id recordtypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Provisioning_Group__c pgroup = new Provisioning_Group__c();
         pgroup.Provisioning_Broker_Eligible__c= false;
        pgroup.Comments__c='Test3';
        pgroup.Product_Line__c='ZIA';
        pgroup.Provisioning_Process__c='New Tenant';
        pgroup.Organization_Domain__c ='uoflhealthcare.org';
        pgroup.Status__c='Archived';
        pgroup.Approval_Status__c='Submitted';
        pgroup.Sub_Status__c='';
        pgroup.PG_Request_Type__c='Create';
        pgroup.Provisioning_Type__c='Auto';
        pgroup.Preferred_Cloud__c='Zscaler.net';
        pgroup.Start_Date__c = System.today();
        pgroup.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup.Number_of_Extensions__c = 6;
        pgroup.RecordTypeId = recordtypeId;
        pgroup.Provisioning_Process__c = 'Decommission';
        insert pgroup;
        
        Test.startTest();
            ProvisioningGroupController.createDraftProvisioningRecords(jsonStr, null, oppId);
            ProvisioningGroupController.createDraftProvisioningRecords(jsonStr, pgroup.id, oppId);
        Test.stopTest();
    }
    
    @isTest
    public static void testElseCreateDraftProvisioningRecords(){
        String accId = [SELECT id FROM Account LIMIT 1].id;
        string oppId = [select id from opportunity where name='testOpp' limit 1].id;
        //String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId": "'+oppId+'","accountId": "0017000001CnQkVAAV","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId": "'+oppId+'","accountId": "'+accId+'","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        Id recordtypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Provisioning_Group__c pgroup = new Provisioning_Group__c();
         pgroup.Provisioning_Broker_Eligible__c= false;
        pgroup.Comments__c='Test3';
        pgroup.Product_Line__c='ZIA';
        pgroup.Provisioning_Process__c='New Tenant';
        pgroup.Organization_Domain__c='uoflhealthcare.org';
        pgroup.Status__c='Archived';
        pgroup.Approval_Status__c='Submitted';
        pgroup.Sub_Status__c='';
        pgroup.PG_Request_Type__c='Create';
        pgroup.Provisioning_Type__c='Auto';
        pgroup.Preferred_Cloud__c='Zscaler.net';
        pgroup.Start_Date__c = System.today();
        pgroup.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup.Number_of_Extensions__c = 6;
        pgroup.RecordTypeId = recordtypeId;
        pgroup.Provisioning_Process__c = 'Decommission';
        insert pgroup;
        
        Test.startTest();
        	ProvisioningGroupController.createDraftProvisioningRecords(jsonStr,pgroup.Id, oppId);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetCrossPlatformProduct(){//done
        Test.startTest();
        	ProvisioningGroupController.getCrossPlatformProduct('Z-TLZ-TI-PRE');
        Test.stopTest();
    }
    
    @isTest 
    public static void testDomainCheckWithExistingCloud(){//partially done
       	string domain='allweiler.de';
        string preferredZIA='Zscloud.net';//confusion in this part
        Account acc = [Select id from Account limit 1];
 		Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c=acc.Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',Zscaler_Cloud_Domain__c='allweiler.de',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
		insert ZSc1;
        Test.startTest();
        	ProvisioningGroupController.domainCheckWithExistingCloud(domain, preferredZIA);
        Test.stopTest();
    }
    
    @isTest
    public static void testSearchAndCreateContactRecord(){//partially done
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];

        User umanager = new user();
        umanager.LastName = 'Test Manager Welcome';
        umanager.Email = 'Test.manager@test.com';
        umanager.Alias = 'Tmanager';
        umanager.Username = 'Test.gsfcd@test.com';
        umanager.CommunityNickname = 'managertest';
        umanager.LocaleSidKey = 'en_US';
        umanager.TimeZoneSidKey = 'GMT';
        umanager.ProfileID = p.id;
        umanager.LanguageLocaleKey = 'en_US';
        umanager.EmailEncodingKey = 'UTF-8';
        insert umanager;

        User u = new user();
        u.LastName = 'Test Code Welcome';
        u.Email = 'Test.gsfcd@test.com';
        u.Alias = 'Tcodffe';
        u.Username = 'Test.gsfcd667@test.com';
        u.ManagerId = umanager.id;
        u.CommunityNickname = 'test1dsa211';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
		string accId=[select id from account where name='TestAccount' limit 1].id;
        
        Test.startTest();
        	ProvisioningGroupController.searchAndCreateContactRecord(u.Id,accId);
        Test.stopTest();   
    }
    
    @isTest
    public static void testPreparePGRecord(){
        String accId = [SELECT id FROM Account LIMIT 1].id;
        string oppId = [select id from opportunity where name='testOpp' limit 1].id;
        String conId=[Select id from Contact where name='test12' limit 1 ].id;
		//String jsonStr ='{"domain": "uoflhealthcare.org","opportunityId": "'+oppId+'","accountId": "0017000001CnQkVAAV","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId": "'+oppId+'","accountId": "'+accId+'","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false,"selectedContactIntProv":"'+conId+'", "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        ProvisioningGroupController.provisioningDetailsWrapper provWrapper=(ProvisioningGroupController.provisioningDetailsWrapper)JSON.deserialize(jsonStr,ProvisioningGroupController.provisioningDetailsWrapper.class);
        string productLineSelected = 'ZIA';
        List<string> selProd = new List<string>{'abc'};

        Test.startTest();
            ProvisioningGroupController.preparePGRecord(provWrapper,productLineSelected, selProd, true);
            ProvisioningGroupController.preparePGRecord(provWrapper,productLineSelected, selProd, false);
        Test.stopTest();
    }
   
    @isTest
    public static void testPrepareSpecialCasePGRecord(){
        String accId = [SELECT id FROM Account LIMIT 1].id;
        string oppId = [select id from opportunity where name='testOpp' limit 1].id;
        //String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId": "'+oppId+'","accountId": "0017000001CnQkVAAV","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId": "'+oppId+'","accountId": "0017000001CnQkVAAV","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        ProvisioningGroupController.provisioningDetailsWrapper provWrapper=(ProvisioningGroupController.provisioningDetailsWrapper)JSON.deserialize(jsonStr,ProvisioningGroupController.provisioningDetailsWrapper.class);
        Id recordtypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Provisioning_Group__c pgroup = new Provisioning_Group__c();
         pgroup.Provisioning_Broker_Eligible__c= false;
        pgroup.Comments__c ='Test3';
        pgroup.Product_Line__c='ZIA';
        pgroup.Provisioning_Process__c='New Tenant';
        pgroup.Organization_Domain__c ='uoflhealthcare.org';
        pgroup.Status__c='Archived';
        pgroup.Approval_Status__c='Submitted';
        pgroup.Sub_Status__c='';
        pgroup.PG_Request_Type__c='Create';
        pgroup.Provisioning_Type__c='Auto';
        pgroup.Preferred_Cloud__c='Zscaler.net';
        pgroup.Start_Date__c = System.today();
        pgroup.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup.Number_of_Extensions__c = 6;
        pgroup.RecordTypeId = recordtypeId;
        pgroup.Provisioning_Process__c = 'Decommission';
        insert pgroup;
        
        String productLineForPG='ZIA';
        
        Test.startTest();
        	provisioningGroupController.prepareSpecialCasePGRecord(provWrapper, pgroup, productLineForPG);
        Test.stopTest();
    }
    
   	@isTest
    public static void testcreateInternalProvisioningDetails(){
        Test.startTest();
        account ac=new account(name='Zscaler Internal Employee Tenant Requests',Type='Customer', Prospect_type__c='Pipeline');
        insert ac;
        String conId=[Select id from Contact where name='test12' limit 1 ].id;
       
        Contact con1 = new Contact();
        con1.LastName = 'jwatkins';
        con1.email = 'jwatkins@zscaler.com.invalid';
        insert con1;

        Contact con2 = new Contact();
        con2.LastName = 'jwatkins2';
        con2.email = 'jwatkins2@zscaler.com.invalid';
        insert con2;
        
		String jsonStr='{"domain": "uoflhealthcare.org","accountId": "'+ac.Id+'","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false,"selectedContactIntProv":"'+conId+'","crossPlatformSelected":true,"crossPlatformProductId":"01t4u00000dIW7mAAG","crossPlatformProductName":"WFA Bus-Edition", "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "Workload Protection","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productSKUId": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true},{"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "'+con1.id+'","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId":"'+con2.id+'","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        List<string> selProd=new List<string>{'ZIA'};
        ProvisioningGroupController.createInternalProvisioningDetails(jsonStr, selProd);
        Test.stopTest();
    }
    
    @isTest
    public static void testElseCreateInternalProvisioningDetails(){
        String accId = [SELECT id FROM Account LIMIT 1].id;
        string oppId = [select id from opportunity where name='testOpp' limit 1].id;
        String conId=[Select id from Contact where name='test12' limit 1 ].id;

        //String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId":"'+oppId+'","accountId": "0017000001CnQkVAAV","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": true, "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId":"'+oppId+'","accountId": "'+accId+'","preferredZIA": "zscalertwo.net","pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": true, "selectedContactIntProv":"'+conId+'","provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        List<string> selProd = new List<string>{'ZIA','ZDX','ZPA'};
        Test.startTest();
        	ProvisioningGroupController.createInternalProvisioningDetails(jsonStr, selProd);
        Test.stopTest();
    }
    
    @isTest
    public static void testfillProductLineForPrimaryQuote(){//done forContact && fillProductListFromPrimary
        String OppId=[select id from opportunity where name='Testopp' limit 1].id;
        System.debug('OppId :'+OppId);
        Test.startTest();
        	ProvisioningGroupController.fillProductLineForPrimaryQuote(oppId);
        Test.stopTest();
    }
    
    @isTest
    public static void testfillProductListFromPrimaryQuoteforContact(){//done forContact && fillProductListFromPrimary
        string OppId=[select id from opportunity where name='Testopp' limit 1].id;
        test.startTest();
        ProvisioningGroupController.fillProductListFromPrimaryQuoteforContact(oppId);
        ProvisioningGroupController.getAllProductLineForPrimaryQuote(oppId);
        ProvisioningGroupController.getPriceListFromOpp(oppId);
        test.stopTest();
    }
    
    @isTest
    public static void testProvisioningProductOLI(){
        Test.startTest();
        	opportunityLineItem oli=[select id,sbqq__quoteline__r.SBQQ__startDate__c , product2.productCode, product2.Product_Line__c, product2.name, product2Id, Product2.Provisioning_Sub_Product_Line__c, Product2.Provisioning_Broker_Eligible__c from opportunityLineItem limit 1];
        	new ProvisioningGroupController.ProvisioningProducts(oli);
        Test.stopTest();
    }
    
    @isTest
    public static void testProvisioningProductProduct(){
        Test.startTest();
        	product2 prod=[select id, productCode, product_line__c, name, Provisioning_Sub_Product_Line__c, Provisioning_Broker_Eligible__c from product2 where name='testProduct2' limit 1];
        	new ProvisioningGroupController.ProvisioningProducts(prod);
        Test.stopTest();
    }
    
    @isTest
    public static void testfillProductListFromPostureControl(){
        String prodCode = [select id,ProductCode,Product_Line__c, Provisioning_Sub_Product_Line__c,
                       Provisioning_Broker_Eligible__c from product2 where name='testProduct' limit 1].ProductCode;
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@'+prodCode);
        Test.startTest();
        	ProvisioningGroupController.fillProductListFromPostureControl(new List<string>{'Zscaler Posture Control Essentials'});
        Test.stopTest();
    }
    
    @isTest
    public static void testgetDefaultContact(){
        Test.startTest();
            Contact cont = new Contact();
            cont.LastName = 'test12';
            cont.email = 'test11@gmail.com';
            insert cont;
            ProvisioningGroupController.getDefaultContact(cont.email);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetConsumerUser(){
        Test.startTest();
            Contact con = new Contact();
            con.LastName = 'test12';
            con.email = 'test11@gmail.com';
            insert con;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
            
            User u = new user();
            u.LastName = 'Test Code Welcome';
            u.Email = 'test11@gmail.com';
            u.Alias = 'Tcodsde';
            u.Username = 'Test.gsfcd@test.com';
            u.ManagerId = '0054u0000075Jn0AAE';
            u.CommunityNickname = 'testfds1211';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.ProfileID = p.id;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            insert u;
            ProvisioningGroupController.getConsumerUser(con.Id);
        Test.stopTest();
    }
    //US Changes(Start)=================================================
  /*  @isTest
    public static void testCreateProvisioningDetails3(){
        String accId = [SELECT id FROM Account LIMIT 1].id;
        String oppId = [Select id from opportunity where name='testOpp' limit 1].id;
        String conId=[Select id from Contact where name='test12' limit 1 ].id;

		Product2 crossProd2 = new Product2(Name='TestProduct2', product_line__c='Cross Platform', poc_products__c='Regular', IsActive=True,
                                      SKU_Type__c='GA', Provisioning_Product_Family__c='AddOn', Is_Applicable_for_POC__c=true,
                                      ProductCode='Z-TLZ-TI-PRE', isBundle__c=true, provisioning_Contact_Type__c='BUSINESS_PRIMARY;EC_CONTACT');
        insert crossProd2;
        
        Id recordtypeId2 = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Provisioning_Group__c pgroup2 = new Provisioning_Group__c();
        pgroup2.Comments__c ='Test3';
        pgroup2.Provisioning_Broker_Eligible__c= false;
        pgroup2.Product_Line__c='ZIA';
        pgroup2.Provisioning_Process__c='New Tenant';
        pgroup2.Organization_Domain__c ='uoflhealthcare.org';
        pgroup2.Status__c='Provisioned';
        pgroup2.Approval_Status__c='Submitted';
        pgroup2.Sub_Status__c='';
        pgroup2.PG_Request_Type__c='Create';
        pgroup2.Provisioning_Type__c='Auto';
        pgroup2.Preferred_Cloud__c='Zscaler.net';
        pgroup2.Start_Date__c = System.today();
        pgroup2.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup2.Number_of_Extensions__c = 6;
        pgroup2.RecordTypeId = recordtypeId2;
        pgroup2.Provisioning_Process__c = 'Decommission';
        pgroup2.opportunity__c=oppId;
        insert pgroup2;
        
        Provisioning_Product__c provprod2 = new Provisioning_Product__c();
        provprod2.Name = 'Test2';
        provprod2.Product__c=crossProd2.id;
        provprod2.Quantity__c = 5;
        provprod2.Provisioning_Group__c=pgroup2.id;
        provprod2.Start_Date__c = system.today();
        provprod2.End_Date__c=system.today()+360;
        insert provprod2;  
        
        String jsonStr = '{"domain": "uoflhealthcare.org","opportunityId": "'+oppId+'","accountId": "'+accId+'","preferredZIA": "zscalertwo.net","selectedPostureControlProducts":[],"selectedPostureControlProdAddOn":[],"pgForSubscription": false,"preferredZPA": "ZPA Production","assignedToCred": "SALES_ENGINEER","withPrimaryQuoteProducts": false,"selectedContactIntProv":"'+conId+'", "provProdWrapper": [{"productName": "ZIA Transformation Edition","productCode": "ZIA-TRANS-EDITION","prodline": "ZIA","productSKUId": "01t4u00000dIW7mAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "ZIA Education Data Loss Prevention","productCode": "EDU-ZIA-SVC-EDGE-DLP","prodline": "ZIA","productAddonnID": "01t0g00000bmThHAAU","isCBI": false,"isDeception": false,"brokerEligibility": true}, {"productName": "Cloud Apps Control","productCode": "ZIA-CLD-APP-CTRL","prodline": "ZIA","productAddonnID": "01t4u00000dIW7rAAG","isCBI": false,"isDeception": false,"brokerEligibility": true}],"provContactWrapper": [{"contactId": "0038J000004JlpvQAC","contactType": "BUSINESS_PRIMARY","email": "jwatkins@zscaler.com.invalid"}, {"contactId": "0038J000004JlpvQAC","contactType": "ZDX_CONTACT","email": "jwatkins@zscaler.com.invalid"}, {"userId": "0054u0000075Jn0AAE","contactType": "SALES_ENGINEER","email": "jwatkins@zscaler.com.invalid"}]}';
        ProvisioningGroupController.provisioningDetailsWrapper provWrapper=(ProvisioningGroupController.provisioningDetailsWrapper)JSON.deserialize(jsonStr,ProvisioningGroupController.provisioningDetailsWrapper.class);
        provWrapper.workloadCommunicationOnly = 'true';
        provWrapper.associatedcloud = 'Request New ZIA Tenant';
        provWrapper.withPrimaryQuoteProducts = false;
        System.debug('provWrapper: '+provWrapper);
        List<string> selProd = new List<string>{'ZIA','ZPA','ZDX','Posture Control'};
        String json3 = '{"domain":"tenpo1212.cl","workloadCommunicationOnly":true,"opportunityId":"'+oppId+'","accountId":"'+accId+'","preferredZIA":"zscalertwo.net","selectedPostureControlProducts":[],"selectedPostureControlProdAddOn":[],"withPrimaryQuoteProducts": false,"crossPlatformSelected":false,"postureControlSelected":false,"numberOfWorkloads":0,"pgForSubscription":false,"preferredZPA":"ZPA Production","associatedcloud":"Request New ZIA Tenant","assignedToCred":"SALES_ENGINEER","withPrimaryQuoteProducts":false,"provProdWrapper":[{"productName":"ZIA Business Edition","productCode":"ZIA-BUS-EDITION","prodline":"ZIA","productSKUId":"01t4u00000dIVyAAAW","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZPA Business Edition","productCode":"ZPA-BUS-EDITION","prodline":"ZPA","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZS-WFA-Business-Edition","productCode":"ZS-WFA-Business-Edition","prodline":"Cross Platform","productSKUId":"01t4u00000dIW86AAG","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"ZDX Advanced","productCode":"ZDX-ADVANCED","prodline":"ZDX","productSKUId":"01t4u00000dIweiAAC","isCBI":false,"isDeception":false,"brokerEligibility":true},{"productName":"Zscaler Workload Segmentation","productCode":"ZT-WLP-SERVER","prodline":"Workload Protection","productSKUId":"01t4u00000dIW8NAAW","isCBI":false,"isDeception":false,"brokerEligibility":false}],"provContactWrapper":[{"contactId":"0038J000006npy9QAA","contactType":"BUSINESS_PRIMARY","email":"rsangati@zscaler.com"},{"contactId":"0038J000006npy9QAA","contactType":"ZDX_CONTACT","email":"rsangati@zscaler.com"},{"userId":"0058J000000EqV5QAK","contactType":"SALES_ENGINEER","email":"rsangati@zscaler.com"}],"initialLoginCredentialsReceiverEmail":"rsangati@zscaler.com"}';
        Test.startTest();
        try{
            ProvisioningGroupController.createProvisioningDetails(jsonStr, selProd);
        }
        catch(exception e){
        }
        Test.stopTest(); 
    }*/
    //US Changes(End)=================================================
}