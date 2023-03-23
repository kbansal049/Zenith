/*****************************************************************************************
Name: SkilljarTrainingCreditCodeTriggerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex test class for skilljar__Training_Credit_Code__c Trigger and it's helper and handler class.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       13/10/2022      IBA-3769      Training Credits Redemption Process.
******************************************************************************************/ 
@isTest
public class SkilljarTrainingCreditCodeTriggerTest {
    
    @isTest
    public static void testSkilljarTrainingCreditCodeTrigger(){
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        
        List<Professional_Services_Credits__c> psCredList = new List<Professional_Services_Credits__c>();
        List<Professional_Services_Credits__c> psCreditListExisting = New List<Professional_Services_Credits__c>();
        List<skilljar__Training_Credit_Code__c> trainingCreditCodeList = new List<skilljar__Training_Credit_Code__c>();
        List<skilljar__Training_Credit_Code__c> trainingCreditCodeListExisting = new List<skilljar__Training_Credit_Code__c>();
        List<skilljar__Training_Credit_Code__c> trainingCreditCodeListToUpdate = new List<skilljar__Training_Credit_Code__c>();
        
        for(integer i=0; i<2 ; i++){
            Professional_Services_Credits__c psCred = new Professional_Services_Credits__c();
            psCred.Opportunity_Close_Date__c = date.today()+360;
            psCred.Credits_Purchased__c = 900;
            psCred.Credits_Redeemed__c = 70;
            psCred.Credits_Expiration_Date__c = date.today()+i;
            psCred.Account__c = acc.id;
            psCred.PS_Credit_SKU__c = 'Z-CFWZPA-Credit';
            pscred.RecordTypeId = ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID;
            psCredList.add(psCred);
        }
        
        if(psCredList.size() > 0){
            insert psCredList;
        }
        
        psCreditListExisting = [SELECT Id,Opportunity_Close_Date__c,Credits_Purchased__c,Credits_Redeemed__c,
                                Credits_Expiration_Date__c,Account__c,PS_Credit_SKU__c,RecordTypeId,Credit_Code__c 
                                FROM Professional_Services_Credits__c
                                WHERE Account__c =: acc.Id LIMIT 1];
        
        for(Professional_Services_Credits__c psCreditObj : psCreditListExisting){
            skilljar__Training_Credit_Code__c trainingCreditObj = new skilljar__Training_Credit_Code__c();
            trainingCreditObj.Name = 'test training credit record';
            trainingCreditObj.skilljar__Code__c = psCreditObj.Credit_Code__c;
            trainingCreditObj.skilljar__Credits_Total__c = psCreditObj.Credits_Purchased__c;
            trainingCreditObj.skilljar__Credits_Used__c = 12;
            trainingCreditObj.skilljar__Expiration_Date__c = psCreditObj.Credits_Expiration_Date__c;
            trainingCreditObj.skilljar__Obfuscated_Id__c = psCreditObj.Id;
            trainingCreditCodeList.add(trainingCreditObj);
        }
        
        if(trainingCreditCodeList.size() > 0){
            insert trainingCreditCodeList;
        }
        
        trainingCreditCodeListExisting = [SELECT Id, Name, skilljar__Code__c, skilljar__Credits_Total__c, 
                                          skilljar__Credits_Used__c 
                                          FROM skilljar__Training_Credit_Code__c];
        
        for(skilljar__Training_Credit_Code__c trainingCreditCodeObj : trainingCreditCodeListExisting){
            trainingCreditCodeObj.skilljar__Credits_Used__c = trainingCreditCodeObj.skilljar__Credits_Used__c + 6;
            trainingCreditCodeListToUpdate.add(trainingCreditCodeObj);
        }
        
        if(trainingCreditCodeListToUpdate.size() > 0){
            update trainingCreditCodeListToUpdate;
        }
        
    }
    
}