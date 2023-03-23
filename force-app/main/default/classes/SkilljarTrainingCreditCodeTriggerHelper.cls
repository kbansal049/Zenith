/*****************************************************************************************
Name: SkilljarTrainingCreditCodeTriggerHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex trigger helper for skilljar__Training_Credit_Code__c.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       13/10/2022      IBA-3769      Training Credits Redemption Process.
******************************************************************************************/ 

public class SkilljarTrainingCreditCodeTriggerHelper {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-3769 : Training Credits Redemption Process.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : populateTrainingCodeTrainingCredit .
* @param    NAME : List<skilljar__Training_Credit_Code__c> newTraininCodeList .
* @return   TYPE : void .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void populateTrainingCodeTrainingCredit(List<skilljar__Training_Credit_Code__c> newTraininCodeList, Map<Id,skilljar__Training_Credit_Code__c> oldTraininCodeMap){
        
        Set<String> creditCodeSet = New Set<String>();
        Decimal creditsToBeRedeemed;
        Map<String,String> creditCodeAndTrainingCodeIdMap = New Map<String,String>();
        Map<String,Decimal> creditCodeAndCreditsusedMap = New Map<String,Decimal>();
        skilljar__Training_Credit_Code__c olCreditCodeObj = New skilljar__Training_Credit_Code__c();
        List<Professional_Services_Credits__c> trainingCreditsList = new List<Professional_Services_Credits__c>();
        List<Professional_Services_Credits__c> trainingCreditsListToUpdate = new List<Professional_Services_Credits__c>();
        
        for(skilljar__Training_Credit_Code__c newTrainingCodeObj : newTraininCodeList){
            creditCodeSet.add(newTrainingCodeObj.skilljar__Code__c);
            creditCodeAndTrainingCodeIdMap.put(newTrainingCodeObj.skilljar__Code__c, newTrainingCodeObj.Id);
            if(trigger.isInsert){
                creditCodeAndCreditsusedMap.put(newTrainingCodeObj.skilljar__Code__c, newTrainingCodeObj.skilljar__Credits_Used__c);
            }
            
            if(trigger.isUpdate){
                olCreditCodeObj = oldTraininCodeMap.get(newTrainingCodeObj.Id);
                if(olCreditCodeObj != Null){
                    creditCodeAndCreditsusedMap.put(newTrainingCodeObj.skilljar__Code__c, newTrainingCodeObj.skilljar__Credits_Used__c - olCreditCodeObj.skilljar__Credits_Used__c);
                }
            }
        }
        
        trainingCreditsList = [Select Id, Name, Credits_Purchased__c, Credits_Redeemed__c, Credits_Remaining__c,
                               CreatedDate, PS_Credit_Name__c, RecordTypeId, Credit_Code__c,
                               Training_Credit_Code__c 
                               FROM Professional_Services_Credits__c
                               WHERE Credit_Code__c IN: creditCodeSet
                               AND RecordTypeId =: ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID
                               ORDER BY CreatedDate asc];
        
        for(Professional_Services_Credits__c trainingCreditObj : trainingCreditsList){
            
            if(trainingCreditObj.Training_Credit_Code__c == Null){
                trainingCreditObj.Id = trainingCreditObj.Id;
                trainingCreditObj.Training_Credit_Code__c = creditCodeAndTrainingCodeIdMap.get(trainingCreditObj.Credit_Code__c);
            }
            
            creditsToBeRedeemed = creditCodeAndCreditsusedMap.get(trainingCreditObj.Credit_Code__c);
            
            if(trainingCreditObj.Credits_Remaining__c >= creditsToBeRedeemed && creditsToBeRedeemed != 0 && creditsToBeRedeemed >= 0){
                trainingCreditObj.Credits_Redeemed__c = trainingCreditObj.Credits_Redeemed__c + creditsToBeRedeemed;
                trainingCreditObj.Id = trainingCreditObj.Id;
                creditCodeAndCreditsusedMap.put(trainingCreditObj.Credit_Code__c,0);
                creditsToBeRedeemed = 0;
            }
            else if(trainingCreditObj.Credits_Remaining__c < creditsToBeRedeemed && creditsToBeRedeemed != 0  && creditsToBeRedeemed >= 0){
                creditsToBeRedeemed = creditsToBeRedeemed - trainingCreditObj.Credits_Remaining__c;
                trainingCreditObj.Credits_Redeemed__c = trainingCreditObj.Credits_Redeemed__c + trainingCreditObj.Credits_Remaining__c;
                trainingCreditObj.Id = trainingCreditObj.Id;
                creditCodeAndCreditsusedMap.put(trainingCreditObj.Credit_Code__c,creditsToBeRedeemed);
            }
            trainingCreditsListToUpdate.add(trainingCreditObj);
        }
        
        if(trainingCreditsListToUpdate.size() > 0){
            Update trainingCreditsListToUpdate;  
        }
    }
    
}