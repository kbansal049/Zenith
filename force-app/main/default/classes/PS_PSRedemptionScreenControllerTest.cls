/*****************************************************************************************
Name: PS_PSRedemptionScreenController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for PS_PSRedemptionScreenController Apex Class.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       17/05/2022      CR#4744      PS Credits Redemption Process && PS Credits Redemption Validation.
2.0                Harish Gowda N       17/05/2022      CR#4833      PS Credit redemption screen Update.
3.0                Harish Gowda N       25/10/2022      IBA-1933     Allow all users to redeem PS credits and create Project.
******************************************************************************************/ 
@isTest
private class PS_PSRedemptionScreenControllerTest {
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4743 : Test Class for PS_PSRedemptionScreenController Apex Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : validatePS_PSRedemptionScreenController .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    static testMethod void validatePS_PSRedemptionScreenController() {
        
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        account.Total_Redeemed_credits__c = 0;
        Update account;
        
        Contact contact = TestDatafactory_Zscaler.insertContact('Contact last Name', account.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, account.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        
        Professional_Services_Credits__c pscreditObj1 = New Professional_Services_Credits__c();
        Professional_Services_Credits__c pscreditObj2 = New Professional_Services_Credits__c();
        Professional_Services_Credits__c pscreditObj3 = New Professional_Services_Credits__c();
        List<Professional_Services_Credits__c> psCreditList = New List<Professional_Services_Credits__c>();
        
        PS_Offering__c psOfferingObj1 = New PS_Offering__c();
        PS_Offering__c psOfferingObj2 = New PS_Offering__c();
        PS_Offering__c psOfferingObj3 = New PS_Offering__c();
        PS_Offering__c psOfferingObj4 = New PS_Offering__c();
        List<PS_Offering__c> psOfferingList = New List<PS_Offering__c>();
        List<PS_Offering__c> psOfferingListNew = New List<PS_Offering__c>();
        
        //Map<String, Object> psOffByOffId = New Map<String, Object>();
        Map<String, String> psOfferingIdUnitsmap = New Map<String, String>();
        Map<String, Map<String, Object>> psOfferingByOfferingId = New Map<String, Map<String, Object>>();
        String units = '3';
        String totalCreditsRequired = '354';
        
        Date expirationDate = system.today() + 365;
        pscreditObj1.Account__c = account.Id;
        pscreditObj1.Credits_Expiration_Date__c = expirationDate;
        pscreditObj1.Credits_Purchased__c = 360;
        pscreditObj1.Credits_Redeemed__c = 0;
        pscreditObj1.Opportunity__c = opp.Id;
        pscreditObj1.Opportunity_Close_Date__c = closeDate;
        pscreditObj1.PS_Credit_Name__c = 'test-PSCredit';
        psOfferingObj1.RecordTypeId = ZScalarConstants.PS_OFFERING_RECORDTYPEID;
        psCreditList.add(pscreditObj1);
        
        pscreditObj2.Account__c = account.Id;
        pscreditObj2.Credits_Expiration_Date__c = expirationDate;
        pscreditObj2.Credits_Purchased__c = 230;
        pscreditObj2.Credits_Redeemed__c = 0;
        pscreditObj2.Opportunity__c = opp.Id;
        pscreditObj2.Opportunity_Close_Date__c = closeDate;
        pscreditObj2.PS_Credit_Name__c = 'test-PSCredit';
        psCreditList.add(pscreditObj2);
        
        pscreditObj3.Account__c = account.Id;
        pscreditObj3.Credits_Expiration_Date__c = expirationDate;
        pscreditObj3.Credits_Purchased__c = 120;
        pscreditObj3.Credits_Redeemed__c = 0;
        pscreditObj3.Opportunity__c = opp.Id;
        pscreditObj3.Opportunity_Close_Date__c = closeDate;
        pscreditObj3.PS_Credit_Name__c = 'test-PSCredit';
        psCreditList.add(pscreditObj3);
        
        if(!psCreditList.isEmpty()){
            Insert psCreditList;
        }
        
        psOfferingObj1.Credits__c = 54;
        psOfferingObj1.Offering_Details__c = 'Tunnels for up to 20 Sites and pair of VSE';
        psOfferingObj1.Name = 'Branch Connectivity';
        psOfferingObj1.Suggested_Max__c = 4;
        psOfferingObj1.Is_Active__c = true;
        psOfferingObj1.RecordTypeId = ZScalarConstants.PS_OFFERING_RECORDTYPEID;
        psOfferingList.add(psOfferingObj1);
        
        psOfferingObj2.Credits__c = 34;
        psOfferingObj2.Offering_Details__c = 'Up to 5000 Windows/Mac and 500 iOS/Android Users ( Enroll with ZIA/ZPA or Both)';
        psOfferingObj2.Name = 'Client Connectivity';
        psOfferingObj2.Suggested_Max__c = 8;
        psOfferingObj2.Is_Active__c = true;
        psOfferingObj2.RecordTypeId = ZScalarConstants.PS_OFFERING_RECORDTYPEID;
        psOfferingList.add(psOfferingObj2);
        
        psOfferingObj3.Credits__c = 30;
        psOfferingObj3.Offering_Details__c = 'Up to 2 EUN Templates, Review 100 Policies across 4 areas';
        psOfferingObj3.Name = 'User Experience';
        psOfferingObj3.Suggested_Max__c = 6;
        psOfferingObj3.Is_Active__c = true;
        psOfferingObj3.RecordTypeId = ZScalarConstants.TRAINING_OFFERING_RECORDTYPEID;
        psOfferingList.add(psOfferingObj3);
        
        psOfferingObj4.Credits__c = 12;
        psOfferingObj4.Offering_Details__c = 'Attack Surface Discovery Report';
        psOfferingObj4.Name = 'Attack Surface Discovery Report';
        psOfferingObj4.Suggested_Max__c = 6;
        psOfferingObj4.Is_Active__c = true;
        psOfferingObj4.RecordTypeId = ZScalarConstants.PS_OFFERING_RECORDTYPEID;
        psOfferingList.add(psOfferingObj4);
        
        if(!psOfferingList.isEmpty()){
            Insert psOfferingList;
        }
        
        psOfferingListNew = [SELECT Id, RecordTypeId, Credits__c, Offering_Details__c, Project_template__c, Name, Suggested_Max__c  FROM PS_Offering__c];
        
        for(PS_Offering__c offeringobj : psOfferingListNew){
            Map<String, Object> mapOfMap = New Map<String, Object>();
            psOfferingIdUnitsmap.put(offeringobj.id,units);
            mapOfMap.put('Id',offeringobj.id);
            mapOfMap.put('CreditsRequired',offeringobj.Credits__c);
            mapOfMap.put('Units',units);
            mapOfMap.put('Credits__c',offeringobj.Credits__c);
            mapOfMap.put('DeploymentStartDate',system.today());
            mapOfMap.put('Name',offeringobj.Name);
            mapOfMap.put('RecordTypeId',offeringobj.RecordTypeId);
            mapOfMap.put('Offering_Details__c',offeringobj.Offering_Details__c);
            mapOfMap.put('RequesterTimeZone','UTC -5  CDT');
            mapOfMap.put('Suggested_Max__c',offeringobj.Suggested_Max__c);
            mapOfMap.put('contact',contact.Id);
            psOfferingByOfferingId.put(offeringobj.id,mapOfMap);
        }
        
        Test.startTest();
        try{
            PS_PSRedemptionScreenController.getPSCredits(account.Id);
            PS_PSRedemptionScreenController.getPSOfferings();
            PS_PSRedemptionScreenController.createPSCreditRedemptionrecord(account.Id, account.Name, totalCreditsRequired, psOfferingIdUnitsmap,psOfferingByOfferingId,false);
        }Catch(exception ex){
            system.debug('PS_PSRedemptionScreenControllerTest Error Message -->'+ex.getLineNumber()+ex.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetDevelopmentProjectRecordTypeId() {
        Test.startTest();
        Id recordTypeId = PS_PSRedemptionScreenController.getDevelopmentProjectRecordTypeId();
        Test.stopTest();
        System.assertEquals(ZScalarConstants.PS_REDEMPTION_RECORDTYPEID, recordTypeId);
    }
}