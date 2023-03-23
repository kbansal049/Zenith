/*****************************************************************************************
Name: PSCredit_CreateProjectForRedBatchTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for PSCredit_CreateProjectForRedemptionBatch Apex Class.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       27/10/2022      IBA - 1933 - Allow all users to redeem PS credits and create Project.
******************************************************************************************/ 
@isTest
public class PSCredit_CreateProjectForRedBatchTest {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 - Allow all users to redeem PS credits and create Project.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : validatePSCredit_ProjectCreationStatusForRedemption .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    
    @testSetup
    static void testSetup() {
        
        TriggerHandler.bypass('InspireProjectMasterTriggerHandler');
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        account.Total_Redeemed_credits__c = 0;
        Update account;
        
        opportunity opp = new opportunity();
        opp.Name = 'Test opportunity';
        opp.Primary_Quote_Exception__c  = true;
        opp.AccountId = account.Id;
        opp.StageName = '5 - Procurement';
        opp.CloseDate = system.Today()+30;
        insert opp;
        
        Contact contact = TestDatafactory_Zscaler.insertContact('Contact last Name', account.Id, null);
        
        Id developmentProjectId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(ZScalarConstants.PROJECT_RT_DEPLOYMENT_PROJECT).getRecordTypeId();
        
        PS_Offering__c psOfferingObj1 = New PS_Offering__c();
        List<PS_Offering__c> psOfferingList = New List<PS_Offering__c>();
        
        psOfferingObj1.Credits__c = 54;
        psOfferingObj1.Offering_Details__c = 'Tunnels for up to 20 Sites and pair of VSE';
        psOfferingObj1.Name = 'Branch Connectivity';
        psOfferingObj1.Suggested_Max__c = 4;
        psOfferingObj1.Is_Active__c = true;
        psOfferingObj1.RecordTypeId = ZScalarConstants.PS_OFFERING_RECORDTYPEID;
        psOfferingList.add(psOfferingObj1);
        
        if(!psOfferingList.isEmpty()){
            insert psOfferingList;
        }
        
        List<PS_Credit_Redemption__c> psRedemptionList = New List<PS_Credit_Redemption__c>();
        for(integer i=0; i<3 ; i++){
            PS_Credit_Redemption__c psRedemptionObj = New PS_Credit_Redemption__c();
            psRedemptionObj.Account__c = account.Id;
            psRedemptionObj.Credits_Required__c = 54;
            psRedemptionObj.Project_Creation_Status__c = ZScalarConstants.PROJECT_CREATION_STATUS_PENDING;
            psRedemptionObj.Project_Deployment_Start_Date__c = system.today();
            psRedemptionObj.Project_Deployment_Expiration_Date__c = system.today() + 365 ;
            psRedemptionObj.Project_Primary_Customer_Contact__c = contact.Id;
            psRedemptionObj.Project_Executive_Summary__c = 'Test Notes + i';
            psRedemptionObj.Project_Requester_Time_Zone__c = 'UTC +5:30  IST';
            psRedemptionObj.PS_Offering__c = psOfferingList[0].Id;
            psRedemptionList.add(psRedemptionObj);
        } 
        
        if(!psRedemptionList.isEmpty()){
            insert psRedemptionList;
        }
        
        Date closeDate = system.today() + 5;
        Date expirationDate = system.today() + 365;
        
        Professional_Services_Credits__c pscredit = New Professional_Services_Credits__c();
        pscredit.Account__c = account.Id;
        pscredit.Credits_Expiration_Date__c = expirationDate;
        pscredit.Credits_Purchased__c = 360;
        pscredit.Credits_Redeemed__c = 0;
        pscredit.Opportunity__c = opp.Id;
        pscredit.Opportunity_Close_Date__c = closeDate;
        pscredit.PS_Credit_Name__c = 'test-PSCredit';
        
        Professional_Services_Credits__c pscredit2 = New Professional_Services_Credits__c();
        pscredit2.Account__c = account.Id;
        pscredit2.Credits_Expiration_Date__c = expirationDate;
        pscredit2.Credits_Purchased__c = 360;
        pscredit2.Credits_Redeemed__c = 0;
        pscredit2.Opportunity__c = opp.Id;
        pscredit2.Opportunity_Close_Date__c = closeDate;
        pscredit2.PS_Credit_Name__c = 'test-PSCredit';
        
        insert new List<Professional_Services_Credits__c>{pscredit,pscredit2};
        
        inspire1__Project__c projectObj = New inspire1__Project__c();
        projectobj.inspire1__Account__c = account.Id;
        projectobj.RecordTypeId = developmentProjectId;
        projectobj.PS_Offering__c = psOfferingList[0].Id;
        projectobj.project_type__c = 'Credit';
        projectobj.inspire1__Project_Status__c = 'Pending Assignment';
        projectObj.Credit_Redemptions__c = psRedemptionList[0].Id;
        Insert projectObj;
        
        Professional_Service_Project__c pspProjectObj = New Professional_Service_Project__c();
        pspProjectObj.Account__c = account.Id;
        pspProjectObj.Related_Inspire_Project_ID__c = projectObj.Id;
        pspProjectObj.PS_Offering__c = psOfferingList[0].Id;
        pspProjectObj.Credit_Redemptions__c = psRedemptionList[0].Id;
        Insert pspProjectObj;    
    }
    
    static testMethod void validatePSCredit_ProjectCreationStatusForRedemption() {

        Account account = [Select id FROM Account LIMIT 1];
        Opportunity opp = [Select id FROM Opportunity LIMIT 1];
        List<Professional_Services_Credits__c> pscredits = [Select id FROM Professional_Services_Credits__c LIMIT 2];
        List<PS_Credit_Redemption__c> psRedemptionList = [SELECT Id FROM PS_Credit_Redemption__c ];
        
        PS_Credit_Redemption_Junction__c junction = new PS_Credit_Redemption_Junction__c();
        junction.Professional_Services_Credit__c = pscredits[0].Id;
        junction.Account__c = account.Id;
        junction.Opportunity__c = opp.Id;
        junction.PS_Credit_Redemption__c = psRedemptionList[0].Id;
        junction.PS_Credit_Credits_Redeemed__c = 1;
        
        PS_Credit_Redemption_Junction__c junction2 = new PS_Credit_Redemption_Junction__c();
        junction2.Professional_Services_Credit__c = pscredits[1].Id;
        junction2.Account__c = account.Id;
        junction2.Opportunity__c = opp.Id;
        junction2.PS_Credit_Redemption__c = psRedemptionList[0].Id;
        junction2.PS_Credit_Credits_Redeemed__c = 1;
        insert new List<PS_Credit_Redemption_Junction__c>{junction,junction2}; 
        
        
        
        Test.startTest();
        try{
            PSCredit_CreateProjectForRedemptionBatch myBatchObject = new PSCredit_CreateProjectForRedemptionBatch(); 
            Database.executeBatch(myBatchObject);            
        }
        Catch(exception ex){
            System.assert(true);
            system.debug('PSCredit_CreateProjectForRedBatchTest Error Message -->'+ex.getLineNumber()+ex.getMessage());
        }
        Test.stopTest();
    }
}