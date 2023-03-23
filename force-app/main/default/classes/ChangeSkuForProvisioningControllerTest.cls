/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ChangeSkuForProvisioningControllerTest {
    @isTest
    private static void testChangeSkuForProvisioningController(){
        String random ='abc';
        Id recordtypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        

       
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='AMERICAS';
        pateam.Region__c ='US West';
        pateam.Area__c ='US South West';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=pateam.Id, Role__c='acme', User__c=UserInfo.getUserId());
        insert member;
        
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=pateam.Id);
        insert patch;

        Account acc = new Account();
        acc.name = 'Test6';
        acc.Patch__c = patch.Id;
        Insert acc;
        String accID = acc.Id;
        User testUser2 = new User(LastName = 'TestUser2',  Email = 'test2@zscaler.com', Username = 'testuser2@zscaler.com', alias = 'test2aaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
        testUser2.FirstName='Test2';
        insert testUser2;

        User testUser = new User(LastName = 'TestUser',  Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', ManagerId = testUser2.id, LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
        testUser.FirstName='Test';
        insert testUser;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name='Test';
        opp1.StageName = '3 - Sponsorship';
        opp1.CloseDate = system.today();
        opp1.Netsuite_Sales_Order_No__c='353200';
        opp1.Netsuite_Sales_Order_Internal_ID__c='234234';
        opp1.SE_Name__c = testUser.Id;
        //String json='{"domain":"recruitglobghty67hgt5alstaffing.com","startDate":"2022-05-30","endDate":"2023-09-27","opportunityId":"0064C00000HoNSXQA3","accountId":"0010g00001hOrRuAAK","recordTypeID":"0124C0000001LywQAE","preferredCloud":"Zscaler.net","productLine":"ZIA","seManager":"00570000005L8RvAAK","zscalerCloudId":"a3A4C000000ITbqUAG","sendInitialCredsTo":"BUSINESS_PRIMARY","provProdWrapper":[{"productName":"ZIA Professional Edition","productCode":"ZIA-PROF-EDITION","prodline":"ZIA","productAddonnID":"01t4u00000dlaSDAAY","quantity":100,"isBrokerEligible":true,"endDate":"2023-09-27","zscalerCloudId":"a3A4C000000ITbqUAG","isCBI":false,"isDeception":false},{"productName":"Priority Categorization Service","productCode":"ZSC-PRI-CAT","prodline":"ZIA","productAddonnID":"01t0g00000QK2HSAA1","isBrokerEligible":true,"quantity":100,"endDate":"2023-09-27","zscalerCloudId":"a3A4C000000ITbqUAG","isCBI":false,"isDeception":false},{"productName":"Advanced Cloud Sandbox","productCode":"ZIA-SANDBOX","prodline":"ZIA","productAddonnID":"01t4u00000dIW7uAAG","isBrokerEligible":true,"quantity":100,"endDate":"2023-09-27","zscalerCloudId":"a3A4C000000ITbqUAG","isCBI":false,"isDeception":false},{"productName":"Cloud Apps Control","productCode":"ZIA-CLD-APP-CTRL","prodline":"ZIA","productAddonnID":"01t4u00000dIW7rAAG","isBrokerEligible":true,"quantity":100,"endDate":"2023-09-27","zscalerCloudId":"a3A4C000000ITbqUAG","isCBI":false,"isDeception":false}],"provContactWrapper":[{"contactType":"BUSINESS_PRIMARY","name":"Walsh Walsh","email":"shubham.tripathi@zscaler.com","contactId":"0034C00000ZaZpzQAF"},{"contactType":"ZDX_CONTACT","name":"Walsh Walsh","email":"shubham.tripathi@zscaler.com","contactId":"0034C00000ZaZpzQAF"},{"contactType":"SALES_ENGINEER","name":"Shubham Tripathi","email":"shubham.tripathi@zscaler.com","userId":"0054u0000076JoPAAU"}],"oldPGId":"aNU4C0000004CFfWAM","pgRequestType":"Replace"}';
        Insert opp1;
        String oppId = opp1.Id;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Domain__c ='Test';
        Insert quote;
        opp1.SBQQ__PrimaryQuote__c = quote.Id; 
        Provisioning_Request__c provreq = new Provisioning_Request__c();
        provreq.Approval_Submission_Date__c =Date.newInstance(2022, 10, 10);
        Insert provreq;
        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Name='ZIA-BUS-Edition';
        prod.ProductCode='ZIA-BUS-Edition';
        prod.Product_Line__c='ZIA';
        
        Product2 prod2 = new Product2();
        prod2.Name='ZPA-BUS-Edition';
        prod2.ProductCode='ZPA-BUS-Edition';
        prod2.Product_Line__c='ZPA';
        
        prodList.add(prod);
        prodList.add(prod2);
        Insert prodList;
        Zscaler_Cloud_ID__c zscal = new Zscaler_Cloud_ID__c();
        zscal.Account__c=acc.Id;
        zscal.Org_Name__c='TestOrg';
        zscal.Name='Test88';
        Insert zscal;
        
        Provisioning_Group__c pgroup2 = new Provisioning_Group__c();
        pgroup2.Comments__c ='Test5';
        pgroup2.Product_Line__c='ZIA';
        pgroup2.Provisioning_Process__c='Change Platform SKU';
        pgroup2.Organization_Domain__c ='uoflhealthcare.org';
        pgroup2.Status__c='Provisioned';
        pgroup2.Approval_Status__c='Approved';
        pgroup2.Sub_Status__c='';
        pgroup2.PG_Request_Type__c='Create';
        pgroup2.Provisioning_Type__c='Auto';
        pgroup2.Preferred_Cloud__c='Zscaler.net';
        pgroup2.Start_Date__c = System.today();
        pgroup2.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup2.Account__c = acc.Id;
        pgroup2.Opportunity__c = opp1.Id;
        pgroup2.Provisioning_Request__c = provreq.Id;
        pgroup2.Zscaler_Cloud_ID__c=zscal.Id;
        pgroup2.Associated_ZIA_Zscaler_Cloud__c=zscal.Id;
        pgroup2.RecordTypeId = recordtypeId;
        
         Insert pgroup2;
        
        Provisioning_Group__c pgroup = new Provisioning_Group__c();
        pgroup.Comments__c ='Test3';
        pgroup.Product_Line__c='ZIA';
        pgroup.Provisioning_Process__c='Change Platform SKU';
        pgroup.Organization_Domain__c ='uoflhealthcare.org';
        pgroup.Status__c='Initiated';
        pgroup.Approval_Status__c='Submitted';
        pgroup.Sub_Status__c='';
        pgroup.PG_Request_Type__c='Create';
        pgroup.Provisioning_Type__c='Auto';
        pgroup.Preferred_Cloud__c='Zscaler.net';
        pgroup.Start_Date__c = System.today();
        pgroup.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup.Account__c = acc.Id;
        pgroup.Opportunity__c = opp1.Id;
        pgroup.Provisioning_Request__c = provreq.Id;
        pgroup.Zscaler_Cloud_ID__c=zscal.Id;
        pgroup.Associated_ZIA_Zscaler_Cloud__c=zscal.Id;
        pgroup.RecordTypeId = recordtypeId;
        
        Insert pgroup;
        
        List<Provisioning_Product__c> provProdList = new List<Provisioning_Product__c>();
        Provisioning_Product__c provprod = new Provisioning_Product__c();
        provprod.Name = 'Test2';
        provprod.Product__c=prod.id;
        provprod.Quantity__c = 5;
        provprod.Provisioning_Group__c=pgroup.id;
        provprod.Start_Date__c = system.today();
        provprod.End_Date__c=system.today()+360;
        
        Provisioning_Product__c provprod2 = new Provisioning_Product__c();
        provprod2.Name = 'Test2';
        provprod2.Product__c=prod2.id;
        provprod2.Quantity__c = 5;
        provprod2.Provisioning_Group__c=pgroup.id;
        provprod2.Start_Date__c = system.today();
        provprod2.End_Date__c=system.today()+360;
        
        provProdList.add(provprod);
        provProdList.add(provprod2);
        Insert provProdList;
        
        List<ChangeSkuForProvisioningController.ProvisioningProducts> ppList = new List<ChangeSkuForProvisioningController.ProvisioningProducts>();
        ChangeSkuForProvisioningController.ProvisioningProducts pp = new ChangeSkuForProvisioningController.ProvisioningProducts();
        pp.endDate=String.valueOf(System.today());
        pp.isBrokerEligible=true;
        pp.isCBI=false;
        pp.isDeception=false;
        pp.prodline='ZIA';
        pp.productCode='ZIA-BUS-EDITION';
        pp.productName='ZIA-BUS-Edition';
        pp.productSKUId=prod.Id;
        ppList.add(pp);
        //insert ppList;
        
        Provisioning_Contact__c pcon = new Provisioning_Contact__c();
        pcon.Provisioning_Group__c= pgroup.Id;
        pcon.Zscaler_Cloud_ID__c=zscal.Id;
        Insert pcon;

        String pgId = pgroup.Id;
        String json='{"domain":"recruitglobghty67hgt5alstaffing.com","startDate":"2022-05-30","endDate":"2023-09-27","opportunityId":"'+oppId+'","accountId":"'+accID+'"'+
        ',"recordTypeID":"'+recordtypeId+'","preferredCloud":"Zscaler.net","productLine":"ZIA","seManager":"'+testUser.Id+'","zscalerCloudId":"'+zscal.Id+'"'+
        ',"sendInitialCredsTo":"BUSINESS_PRIMARY","provProdWrapper":[{"productName":"ZIA Professional Edition","productCode":"ZIA-PROF-EDITION","prodline":"ZIA","productAddonnID":"'+prod.Id+'"'+
        ',"quantity":100,"isBrokerEligible":false,"endDate":"2023-09-27","zscalerCloudId":"'+zscal.Id+'","isCBI":false,"isDeception":false},{"productName":"Priority Categorization Service"'+
        ',"productCode":"ZSC-PRI-CAT","prodline":"ZIA","productAddonnID":"'+prod2.Id+'","isBrokerEligible":true,"quantity":100,"endDate":"2023-09-27","zscalerCloudId":"'+zscal.Id+'","isCBI":false'+
        ',"isDeception":false},{"productName":"Advanced Cloud Sandbox","productCode":"ZIA-SANDBOX","prodline":"ZIA","productAddonnID":"'+prod.Id+'","isBrokerEligible":true,"quantity":100'+
        ',"endDate":"2023-09-27","zscalerCloudId":"'+zscal.Id+'","isCBI":false,"isDeception":true},{"productName":"Cloud Apps Control","productCode":"CLOUD-NSS","prodline":"ZPA"'+
        ',"productAddonnID":"'+prod.Id+'","isBrokerEligible":true,"quantity":100,"endDate":"2023-09-27","zscalerCloudId":"'+zscal.Id+'","isCBI":true,"isDeception":false}],'+
        '"provContactWrapper":[{"contactType":"BUSINESS_PRIMARY","name":"Walsh Walsh","email":"shubham.tripathi@zscaler.com","userId":"'+testUser.Id+'"}'+
        ',{"contactType":"ZDX_CONTACT","name":"Walsh Walsh","email":"shubham.tripathi@zscaler.com","userId":"'+testUser.Id+'"}'+
        ',{"contactType":"SALES_ENGINEER","name":"Shubham Tripathi","email":"shubham.tripathi@zscaler.com","userId":"'+testUser.Id+'"}]'+
        ',"oldPGId":"'+pgId+'","pgRequestType":"Replace"}';


        String reason = 'xyz';
        String sub ='dfg';
        Test.startTest();
        ChangeSkuForProvisioningController.getALLPlatformSKUforTable(pgId);
        ChangeSkuForProvisioningController.getExistingPGFields(pgId);
        ChangeSkuForProvisioningController.getExistingSKU(pgId);
        ChangeSkuForProvisioningController.getPOVProductList('ZIA');
        
        ChangeSkuForProvisioningController.categrorizeProducts(ppList);
        ChangeSkuForProvisioningController.checkifCBIProductExist(ppList);
        ChangeSkuForProvisioningController.checkifDeceptionProductExist(ppList);
        ChangeSkuForProvisioningController.replaceProvisioningRecords(json);
        
        
        	
        Test.stopTest();
    }
}