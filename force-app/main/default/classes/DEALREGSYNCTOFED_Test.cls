/////This test class tests the sync between commercial to Fed 5 Account fields. 
@isTest
public class DEALREGSYNCTOFED_Test {
    
        //// This test is for get method
        @IsTest
        static void dealRegTriggerTest1() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        triggerUtility.DRRemovalfromOppReset();        
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_DR_Removal_from_Opp', Execute__c = true);
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
		Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner11.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;
        insert acc1;
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();
        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'US';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'US';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'US';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Pending Review';
        deal2.Federal_Deal_Approved_OP__c = true;
        dealRegInsertList.add(deal2);
        insert deal2;
        System.debug('deal2.Id'+deal2.Id);
        System.debug('deal2.Name'+deal2.Name );

            
        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        Test.startTest();
        Map<Id, Deal_Reg__c> oldMap = new Map<Id, Deal_Reg__c>();
        oldMap.put(dealReg.Id, dealReg);
        dealReg.Status__c = 'Pending Expiration';
        System.debug('Pending Expiration'+dealReg.Status__c);
        TriggerUtility.DRRemovalfromOppReset();
       // update dealReg;
        List<Deal_Reg__c> listDealReg = new List<Deal_Reg__c>();
        listDealReg.add(dealReg);
        System.debug('listDealReg'+listDealReg);
        System.debug('oldMap'+oldMap);
            
        //DealRegTriggerHelper.removeDRfromOpp(oldMap,listDealReg);
        DealRegTriggerHelper.RejectDRinApproval(oldMap,listDealReg);
        DealRegTriggerHelper.submitDRforFinalReview(oldMap,listDealReg);
            
        ////DEALREGSYNCTOFEDtest///
        System.debug('deal2'+ deal2);
        System.debug('deal2.Name'+ deal2.Name);
        List<Deal_Reg__c> acclst = [SELECT  Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Account_Manager_Phone__c, Account_Manager__c, Approval_Status__c, Area_Director__c, Area__c, Channel_Manager_Phone__c, Channel_Manager__c, Comments__c, Contact__c, DS_Review_Status__c, Deal_Description__c, End_Customer_Contact_Last_Name__c, End_Customer_Contact_Name__c, End_Customer_Country__c, End_Customer_Domain__c, End_Customer_Email__c, End_Customer_Name__c, End_Customer_Phone__c, End_Customer_State__c, Estimated_Amount__c, Expected_Close_Date__c, Expiration_Date__c, GEO__c, Lead__c, Market_Segment__c, Number_of_Users__c, Partner_Account__c, Partner_Company_Name__c, Partner_Contact_Email__c, Partner_Contact_Last_Name__c, Partner_Contact_Name__c, Partner_Country__c, Partner_Domain__c, Partner_Phone__c, Partner_State__c, Region__c, Sales_Territory__c, Source__c, Status__c, Territory_Type__c, Customer_Role_And_Title__c, Partner_Alternate_Email_1__c, Partner_Alternate_Email_2__c, Partner_Alternate_Email_3__c, Product_Areas__c, End_Customer_City__c, End_Customer_Postal_Code__c, End_Customer_Street_Address__c, Security_ISA_Email__c, Security_ISA_Name__c, Partner_Account_Owner_Email__c, Partner_Account_SE_Email__c, GEO_VP__c, Learn_how_to_Convert_Deal_Registration__c,  Channel_Manager_2__c, Channel_Manager_3__c, Send_to_FedRAMP_Date__c, Send_to_FedRAMP__c, Territory_Name__c,  Approved_Date__c, Partner_Type__c, Partner_Category__c, Sub_Region__c, Partner_Account_Program__c, Partner_Account_Owner__c, Tech_Partner_Geo_Email__c, AW_Partner_Intent__c, Deal_Reg_Type__c, End_Customer_TC_Street_Address__c, POV_Partner_Intent__c, Partner_Contact__c, Regional_VP__c, Deal_Reg_Expiration_Date__c, Discovery_Meeting_Date__c, Expiration_Requested_By__c, Expiration_Requested_Date__c, NBM_Meeting_Date__c, Reason_for_Expiration__c, Partner_Account_Id__c,  Renewal_Opportunity_Owner__c, Renewal_Opportunity__c, Channel_Manager_4__c FROM Deal_Reg__c];      
        System.debug('acclst'+ acclst);
        
        // Stsrt the test
        Map<String, String> result = DEALREGSYNCTOFED.doGet();
        System.debug('result:' + result);
        Test.stopTest();
    }
   
    //// This test is for post method
     static testMethod void dealRegTriggerTest2() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        triggerUtility.DRRemovalfromOppReset();        
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_DR_Removal_from_Opp', Execute__c = true);
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
		Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
       // insert acc;
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner11.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;
        insert acc1;
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();
        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'US';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'US';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'US';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Pending Review';
        deal2.Federal_Deal_Approved_OP__c = true;
        dealRegInsertList.add(deal2);
        insert deal2;
        System.debug('deal2.Id'+deal2.Id);
         
        System.debug('deal2.Name'+deal2.Name );

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        
        Test.startTest();
        Map<Id, Deal_Reg__c> oldMap = new Map<Id, Deal_Reg__c>();
        oldMap.put(dealReg.Id, dealReg);
        dealReg.Status__c = 'Pending Expiration';
        System.debug('Pending Expiration'+dealReg.Status__c);
        TriggerUtility.DRRemovalfromOppReset();
       // update dealReg;
        List<Deal_Reg__c> listDealReg = new List<Deal_Reg__c>();
        listDealReg.add(dealReg);
        System.debug('listDealReg'+listDealReg);
        System.debug('oldMap'+oldMap);
         
        //DealRegTriggerHelper.removeDRfromOpp(oldMap,listDealReg);
        DealRegTriggerHelper.RejectDRinApproval(oldMap,listDealReg);
        DealRegTriggerHelper.submitDRforFinalReview(oldMap,listDealReg);
         
         ////DEALREGSYNCTOFEDtest///
        System.debug('dealReg.Id'+ dealReg.Id);
         
        System.debug('dealReg.Name'+ dealReg.Name);
        System.debug('deal2.Name'+ deal2.Name);
        deal2.Status__c = 'Sales Ops Pending Review ';
        dealReg.Status__c = 'Converted';
        update dealReg;
        update    deal2;
        Deal_Reg__c dealReg1 = [select Id, Name, Approval_Status__c, Status__c, Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c from Deal_Reg__c where Id = :dealReg.Id  ];
        Deal_Reg__c deal2withname = [select Id, Name, Approval_Status__c, Status__c, Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c from Deal_Reg__c where Id = :deal2.Id  ];

        // Stsrt the test
         List<String> listName = new List<String>();
         listName.add(dealReg1.Name);
         Map<String, String> mapNameStatus = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameStatus.put(dealReg1.Name, dealReg1.Status__c);
         System.debug('mapNameStatus'+ mapNameStatus);

         Map<String, String> mapNameDealType = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameDealType.put(dealReg1.Name, dealReg1.Deal_Reg_Type__c);
         System.debug('mapNameDealType'+ mapNameDealType);

         Map<String, DateTime> mapNameDealExpire = new Map<String, DateTime>();
         System.debug('listName'+ listName);
         mapNameDealExpire.put(dealReg1.Name, dealReg1.Deal_Reg_Expiration_Date__c);
         System.debug('mapNameDealExpire'+ mapNameDealExpire);
         
         Map<String, String> mapNameDealApprovalStatus = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameDealApprovalStatus.put(dealReg1.Name, dealReg1.Approval_Status__c);
         System.debug('mapNameDealApprovalStatus'+ mapNameDealApprovalStatus);
         
         List<String> TargetCommDeal = new List<String>();
         TargetCommDeal.add(dealReg1.Id);
         List<String> TargetCommDealStatus = new List<String>();
         TargetCommDealStatus.add('Approved');

         String result = DEALREGSYNCTOFED.doPost(listName,mapNameStatus, mapNameDealType, mapNameDealExpire, mapNameDealApprovalStatus, TargetCommDeal, TargetCommDealStatus);

       //  String result = DEALREGSYNCTOFED.doPost(listName,mapNameStatus, mapNameDealType, mapNameDealExpire, mapNameDealApprovalStatus);
         System.debug('result:' + result);
         Test.stopTest();
    }
    
    //// This test is for post method
     static testMethod void dealRegTriggerTest3() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        triggerUtility.DRRemovalfromOppReset();        
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_DR_Removal_from_Opp', Execute__c = true);
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
		Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
       // insert acc;
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner11.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;
        insert acc1;
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();
        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'US';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'US';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'US';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Pending Review';
        deal2.Federal_Deal_Approved_OP__c = true;
        dealRegInsertList.add(deal2);
        insert deal2;
        System.debug('deal2.Id'+deal2.Id);
         
        System.debug('deal2.Name'+deal2.Name );

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        
        Test.startTest();
        Map<Id, Deal_Reg__c> oldMap = new Map<Id, Deal_Reg__c>();
        oldMap.put(dealReg.Id, dealReg);
        dealReg.Status__c = 'Pending Expiration';
        System.debug('Pending Expiration'+dealReg.Status__c);
        TriggerUtility.DRRemovalfromOppReset();
       // update dealReg;
        List<Deal_Reg__c> listDealReg = new List<Deal_Reg__c>();
        listDealReg.add(dealReg);
        System.debug('listDealReg'+listDealReg);
        System.debug('oldMap'+oldMap);
         
        //DealRegTriggerHelper.removeDRfromOpp(oldMap,listDealReg);
        DealRegTriggerHelper.RejectDRinApproval(oldMap,listDealReg);
        DealRegTriggerHelper.submitDRforFinalReview(oldMap,listDealReg);
         
         ////DEALREGSYNCTOFEDtest///
        System.debug('dealReg.Id'+ dealReg.Id);
         
        System.debug('dealReg.Name'+ dealReg.Name);
        System.debug('deal2.Name'+ deal2.Name);
        deal2.Status__c = 'Sales Ops Pending Review';
        dealReg.Status__c = 'Sales Ops Pending Review';
        update dealReg;
        update    deal2;
        Deal_Reg__c dealReg1 = [select Id, Name, Approval_Status__c,Status__c, Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c from Deal_Reg__c where Id = :dealReg.Id  ];
        Deal_Reg__c deal2withname = [select Id, Name, Approval_Status__c, Status__c, Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c from Deal_Reg__c where Id = :deal2.Id  ];

        // Stsrt the test
         List<String> listName = new List<String>();
         listName.add(dealReg1.Name);
         Map<String, String> mapNameStatus = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameStatus.put(dealReg1.Name, dealReg1.Status__c);
         System.debug('mapNameStatus'+ mapNameStatus);

         Map<String, String> mapNameDealType = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameDealType.put(dealReg1.Name, dealReg1.Deal_Reg_Type__c);
         System.debug('mapNameDealType'+ mapNameDealType);

         Map<String, DateTime> mapNameDealExpire = new Map<String, DateTime>();
         System.debug('listName'+ listName);
         mapNameDealExpire.put(dealReg1.Name, dealReg1.Deal_Reg_Expiration_Date__c);
         System.debug('mapNameDealExpire'+ mapNameDealExpire);
         
         Map<String, String> mapNameDealApprovalStatus = new Map<String, String>();
         System.debug('listName'+ listName);
         
         mapNameDealApprovalStatus.put(dealReg1.Name, dealReg1.Approval_Status__c);
         System.debug('mapNameDealApprovalStatus'+ mapNameDealApprovalStatus);
         
         List<String> TargetCommDeal = new List<String>();
         TargetCommDeal.add(dealReg1.Id);
         List<String> TargetCommDealStatus = new List<String>();
         TargetCommDealStatus.add('Approved');

         String result = DEALREGSYNCTOFED.doPost(listName,mapNameStatus, mapNameDealType, mapNameDealExpire, mapNameDealApprovalStatus, TargetCommDeal, TargetCommDealStatus);

       //  String result = DEALREGSYNCTOFED.doPost(listName,mapNameStatus, mapNameDealType, mapNameDealExpire, mapNameDealApprovalStatus);
         System.debug('result:' + result);
         Test.stopTest();
    }
    
    //// This test is for post method
     static testMethod void dealRegTriggerTest4() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        triggerUtility.DRRemovalfromOppReset();        
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_DR_Removal_from_Opp', Execute__c = true);
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
		Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
       // insert acc;
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner11.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;
        insert acc1;
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();
        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'US';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'US';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'US';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Pending Review';
        deal2.Federal_Deal_Approved_OP__c = true;
        dealRegInsertList.add(deal2);
        insert deal2;
        System.debug('deal2.Id'+deal2.Id);
         
        System.debug('deal2.Name'+deal2.Name );

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        
        Test.startTest();
        Map<Id, Deal_Reg__c> oldMap = new Map<Id, Deal_Reg__c>();
        oldMap.put(dealReg.Id, dealReg);
        dealReg.Status__c = 'Pending Expiration';
        System.debug('Pending Expiration'+dealReg.Status__c);
        TriggerUtility.DRRemovalfromOppReset();
       // update dealReg;
        List<Deal_Reg__c> listDealReg = new List<Deal_Reg__c>();
        listDealReg.add(dealReg);
        System.debug('listDealReg'+listDealReg);
        System.debug('oldMap'+oldMap);
         
        //DealRegTriggerHelper.removeDRfromOpp(oldMap,listDealReg);
        DealRegTriggerHelper.RejectDRinApproval(oldMap,listDealReg);
        DealRegTriggerHelper.submitDRforFinalReview(oldMap,listDealReg);
         
         ////DEALREGSYNCTOFEDtest///
        System.debug('dealReg.Id'+ dealReg.Id);
        System.debug('dealReg.Name'+ dealReg.Name);
        System.debug('deal2.Name'+ deal2.Name);
        deal2.Status__c = 'Sales Ops Pending Review';
        dealReg.Status__c = 'Sales Ops Pending Review';
        update dealReg;
        update    deal2;
        Deal_Reg__c dealReg1 = [select Id, Name, Approval_Status__c,Status__c, Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c from Deal_Reg__c where Id = :dealReg.Id  ];
        Deal_Reg__c deal2withname = [select Id, Name, Approval_Status__c, Status__c, Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c from Deal_Reg__c where Id = :deal2.Id  ];

        // Stsrt the test
         List<String> listName = new List<String>();
         listName.add(dealReg1.Name);
         Map<String, String> mapNameStatus = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameStatus.put(dealReg1.Name, dealReg1.Status__c);
         System.debug('mapNameStatus'+ mapNameStatus);

         Map<String, String> mapNameDealType = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameDealType.put(dealReg1.Name, dealReg1.Deal_Reg_Type__c);
         System.debug('mapNameDealType'+ mapNameDealType);

         Map<String, DateTime> mapNameDealExpire = new Map<String, DateTime>();
         System.debug('listName'+ listName);
         mapNameDealExpire.put(dealReg1.Name, dealReg1.Deal_Reg_Expiration_Date__c);
         System.debug('mapNameDealExpire'+ mapNameDealExpire);
         
         Map<String, String> mapNameDealApprovalStatus = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameDealApprovalStatus.put(dealReg1.Name, dealReg1.Approval_Status__c);
         System.debug('mapNameDealApprovalStatus'+ mapNameDealApprovalStatus);
         
         List<String> TargetCommDeal = new List<String>();
         TargetCommDeal.add(dealReg1.Id);
         List<String> TargetCommDealStatus = new List<String>();
         TargetCommDealStatus.add('Approved');

         String result = DEALREGSYNCTOFED.doPost(listName,mapNameStatus, mapNameDealType, mapNameDealExpire, mapNameDealApprovalStatus, TargetCommDeal, TargetCommDealStatus);


         System.debug('result:' + result);
         Test.stopTest();
    }
    
      //// This test is for post method
     static testMethod void dealRegTriggerTest5() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        triggerUtility.DRRemovalfromOppReset();        
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_DR_Removal_from_Opp', Execute__c = true);
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
		Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
       // insert acc;
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner11.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;
        insert acc1;
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();
        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'US';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'US';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'US';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Pending Review';
        deal2.Federal_Deal_Approved_OP__c = true;
        dealRegInsertList.add(deal2);
        insert deal2;
        System.debug('deal2.Id'+deal2.Id);
         
        System.debug('deal2.Name'+deal2.Name );

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        
        Test.startTest();
        Map<Id, Deal_Reg__c> oldMap = new Map<Id, Deal_Reg__c>();
        oldMap.put(dealReg.Id, dealReg);
        dealReg.Status__c = 'Pending Expiration';
        System.debug('Pending Expiration'+dealReg.Status__c);
        TriggerUtility.DRRemovalfromOppReset();
       // update dealReg;
        List<Deal_Reg__c> listDealReg = new List<Deal_Reg__c>();
        listDealReg.add(dealReg);
        System.debug('listDealReg'+listDealReg);
        System.debug('oldMap'+oldMap);
         
        //DealRegTriggerHelper.removeDRfromOpp(oldMap,listDealReg);
        DealRegTriggerHelper.RejectDRinApproval(oldMap,listDealReg);
        DealRegTriggerHelper.submitDRforFinalReview(oldMap,listDealReg);
         
         ////DEALREGSYNCTOFEDtest///
        System.debug('dealReg.Id'+ dealReg.Id);
        System.debug('dealReg.Name'+ dealReg.Name);
        System.debug('deal2.Name'+ deal2.Name);
        deal2.Status__c = 'Sales Ops Pending Review';
        dealReg.Status__c = 'Sales Ops Pending Review';
        update dealReg;
        update    deal2;
        Deal_Reg__c dealReg1 = [select Id, Name, Approval_Status__c,Status__c, Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c from Deal_Reg__c where Id = :dealReg.Id  ];
        Deal_Reg__c deal2withname = [select Id, Name, Approval_Status__c, Status__c, Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c from Deal_Reg__c where Id = :deal2.Id  ];

        // Stsrt the test
         List<String> listName = new List<String>();
         listName.add(dealReg1.Name);
         Map<String, String> mapNameStatus = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameStatus.put(dealReg1.Name, dealReg1.Status__c);
         System.debug('mapNameStatus'+ mapNameStatus);

         Map<String, String> mapNameDealType = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameDealType.put(dealReg1.Name, dealReg1.Deal_Reg_Type__c);
         System.debug('mapNameDealType'+ mapNameDealType);

         Map<String, DateTime> mapNameDealExpire = new Map<String, DateTime>();
         System.debug('listName'+ listName);
         mapNameDealExpire.put(dealReg1.Name, dealReg1.Deal_Reg_Expiration_Date__c);
         System.debug('mapNameDealExpire'+ mapNameDealExpire);
         
         Map<String, String> mapNameDealApprovalStatus = new Map<String, String>();
         System.debug('listName'+ listName);
         mapNameDealApprovalStatus.put(dealReg1.Name, dealReg1.Approval_Status__c);
         System.debug('mapNameDealApprovalStatus'+ mapNameDealApprovalStatus);
         
         List<String> TargetCommDeal = new List<String>();
         TargetCommDeal.add(dealReg1.Id);
         List<String> TargetCommDealStatus = new List<String>();
         TargetCommDealStatus.add('Rejected');

         String result = DEALREGSYNCTOFED.doPost(listName,mapNameStatus, mapNameDealType, mapNameDealExpire, mapNameDealApprovalStatus, TargetCommDeal, TargetCommDealStatus);


         System.debug('result:' + result);
         Test.stopTest();
    }
  
}