/*****************************************************************************************
Name: PSCredit_UpdateCreditsOnAccountBatchTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for PSCredit_UpdateCreditsOnAccountBatch Apex Class.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       17/05/2022      CR#4744      PS Credits Redemption Process && PS Credits Redemption Validation.
******************************************************************************************/ 

@isTest
public class PSCredit_UpdateCreditsOnAccountBatchTest {
    @isTest
    public static void isRedemptionTest(){
        
        Account acc = new Account();
        acc.Name  = 'Test Account';
        insert acc;
        
        
        List<Professional_Services_Credits__c> psCredList = new List<Professional_Services_Credits__c>();
        for(integer i=0; i<3 ; i++){
            Professional_Services_Credits__c psCred = new Professional_Services_Credits__c();
            psCred.Opportunity_Close_Date__c = date.today()+360;
            psCred.Credits_Purchased__c = 900;
            psCred.Credits_Redeemed__c = 70;
            psCred.Credits_Expiration_Date__c = date.today()-i;
            psCred.Account__c = acc.id;
            psCred.RecordTypeId = ZScalarConstants.PS_CREDIT_RECORDTYPEID;
            psCredList.add(psCred);
        }
        
        insert psCredList;

        List<Professional_Services_Credits__c> trainingCredList = new List<Professional_Services_Credits__c>();
        for(integer i=0; i<3 ; i++){
            Professional_Services_Credits__c trainingCred = new Professional_Services_Credits__c();
            trainingCred.Opportunity_Close_Date__c = date.today()+360;
            trainingCred.Credits_Purchased__c = 900;
            trainingCred.Credits_Redeemed__c = 70;
            trainingCred.Credits_Expiration_Date__c = date.today()-i;
            trainingCred.Account__c = acc.id;
            trainingCred.PS_Credit_SKU__c = 'ZCES-EDU-CREDIT';
            trainingCred.RecordTypeId = ZScalarConstants.Training_CREDIT_RECORDTYPEID;
            trainingCredList.add(trainingCred);
        }
        
        insert trainingCredList;
        
        set<Professional_Services_Credits__c> psSet = new set<Professional_Services_Credits__c>();
        
        Test.startTest();
        Database.executeBatch(new PSCredit_UpdateCreditsOnAccountBatch(),250);
        Test.stopTest();
    }   
}