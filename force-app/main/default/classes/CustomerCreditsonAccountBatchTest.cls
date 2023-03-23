/*****************************************************************************************
Name: CustomerCreditsonAccountBatchTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for CustomerCreditsonAccountBatch Apex Class.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       17/05/2022      CR#4744      PS Credits Redemption Process && PS Credits Redemption Validation.
2.0                Karthik Pullagurla   10/18/2022      IBA-3842     Training Credits Rollup
******************************************************************************************/ 

@isTest
public class CustomerCreditsonAccountBatchTest {
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
        
        CustomerCreditsonAccountBatch myBatchObject = new CustomerCreditsonAccountBatch(); 
        Test.startTest();
        myBatchObject.execute(null,psCredList);
        myBatchObject.start(null);
        myBatchObject.finish(null);
        Account_Extension__c accExt = [SELECT Id,Total_Available_Training_Credits__c FROM Account_Extension__c WHERE Account__c =: acc.Id];
        system.assertEquals(accExt.Total_Available_Training_Credits__c, 0, 'Account Extension Record Not Updated');
        Test.stopTest();
    }
    
}