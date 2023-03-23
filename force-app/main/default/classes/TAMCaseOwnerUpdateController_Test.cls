/*****************************************************************************************
Name: TAMCaseOwnerUpdateController_Test
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for TAMCaseOwnerUpdateController Class.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR                   DATE            DETAIL              
1.0                Adarsh Pidaparthy        02/20/2023      
******************************************************************************************/ 
@isTest
public class TAMCaseOwnerUpdateController_Test {
    
    @TestSetup
    static void testDataSetUp(){
        
        Id supportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Case newCase1 = new Case(recordTypeId= supportCaseRecordTypeId,Subject = 'TestCase1',Preferred_Method_of_Contact__c = 'Email',Preferred_Contact_Time_Zone__c = 'Australia/Adelaide',Priority = 'Medium (P3)',Status = 'New',Product__c = 'ZIA',Case_Type__c = 'Problem');
        caseList.add(newCase1);
        Case newCase2 = new Case(recordTypeId= supportCaseRecordTypeId,Subject = 'TestCase2',Priority = 'Medium (P3)',Case_Type__c = 'Problem');
        caseList.add(newCase2);
        insert caseList;
    }
    static testMethod void testCasePriorOwnerIdUpdate(){
        List<Case>getCasesList = [select id,Subject,status from Case limit 10];
        List<Id>caseIdList = new List<id>();
        for(Case eachCase: getCasesList){
            caseIdList.add(eachCase.Id);
        }
        system.assert(caseIdList!=null);
        Test.startTest();
        TAMCaseOwnerUpdateController.updateCasePriorOwnerId(caseIdList);
        Test.stopTest();
    }
    
}