@IsTest
private with sharing class CloseProcessTrackingReportingHandlerTest {
    
    private final static Map<String, Schema.RecordTypeInfo> RECORD_TYPE_INFO_MAP = Schema.SObjectType.Account.getRecordTypeInfosByName();
    
    @IsTest static void testAssociateTargetCustomer(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id, 'Enterprise', 1);
		Account partner = TestDatafactory_Zscaler.insertAccount('Test Partner', null, 'Partner', RECORD_TYPE_INFO_MAP.get('Partner').getRecordTypeId(), null, null);
        Account prospect = TestDatafactory_Zscaler.insertAccount('Test Customer', null, 'Prospect', RECORD_TYPE_INFO_MAP.get('End User').getRecordTypeId(), null, null);
        prospect.Domain__c = 'testcust1.com';
        UPDATE prospect;
            
        List<Target_Customer__c> targetCustomerList = DealRegTestDataFactory.createTargetCustomer(1, partner.Id, prospect.Id);
        INSERT targetCustomerList;
        
        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('test@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
		System.debug('>>>>dealReg ' + dealReg);
        Deal_Reg__c dealReg2 = DealRegTestDataFactory.createDealReg('test@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        System.debug('>>>>dealReg2 ' + dealReg2);
        
        System.assert(String.isNotBlank(dealReg.End_Customer_Domain__c));
        
        Test.startTest();
        
        dealReg.Partner_Account__c = partner.Id;
        UPDATE dealReg;
        Test.stopTest();
    }
    
    @IsTest static void testAssociateTargetCustomerNegative(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id, 'Enterprise', 1);
		Account partner = TestDatafactory_Zscaler.insertAccount('Test Partner', null, 'Partner', RECORD_TYPE_INFO_MAP.get('Partner').getRecordTypeId(), null, null);
        
        
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = 'AMERICAS';
        amerPatchTeam1.Region__c = 'AMERICAS';
        amerPatchTeam1.Territory_Type__c = 'Commercial';
        amerPatchTeam1.Theater__c = 'International';
        INSERT amerPatchTeam1;
        
        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('test@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
		System.debug('>>>>dealReg ' + dealReg);
        Deal_Reg__c dealReg2 = DealRegTestDataFactory.createDealReg('test@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        System.debug('>>>>dealReg2 ' + dealReg2);
        
        
        
        
        Test.startTest();
        
        dealReg.Partner_Account__c = partner.Id;
        dealReg.End_Customer_Domain__c = '';
        UPDATE dealReg;
        
        System.assert(String.isBlank(dealReg.End_Customer_Domain__c));
        Test.stopTest();
    }
}