@isTest
public class CaseRollUpBatchTest {
    
    @testSetup 
    static void setup() {
        Recordtype rc = [Select id,Name From RecordType where sObjectType='Case' and isActive=true and name = 'Support' LIMIT 1];
        Case cs = new Case(Subject = 'Test Case', of_Cases__c = 5, Origin = 'Salesforce.com',RecordTypeId = rc.Id);
        insert cs;
        
        Legacy_Case_Comment__c lcc = new Legacy_Case_Comment__c(Cases__c = cs.id);
        insert lcc;
        
        Survey__c survey = new Survey__c(Case__c = cs.id,NPS_Category__c = 'Promoter',Easy_to_handle_Issue__c = '1 - Strongly Disagree',Rate_your_experience__c= 5,survey_response_received__c=True);
        insert survey;   
    }
    @isTest 
    static void caseBatch(){
        Test.startTest();
        CaseRollUpBatch ob = new CaseRollUpBatch();
        String sch = '0 0 04 * * ?';
        String jobID = System.schedule('CaseBatch Job', sch, ob);
        Database.executeBatch(ob);
        Test.stopTest();
        Case cs = [Select Number_of_comment__c,Survey_Sent_Count__c,Survey_Filled_Count__c,Survey_NPS_Detractor_Count__c,Survey_NPS_Promoter_Count__c,Survey_CES_Score__c,Survey_CSAT_Score__c From Case Limit 1];
        /*
		System.assert(cs.Number_of_comment__c != NULL);
        System.assert(cs.Survey_Sent_Count__c != NULL);
        System.assert(cs.Survey_Filled_Count__c != NULL);
        System.assert(cs.Survey_NPS_Detractor_Count__c != NULL);
        System.assert(cs.Survey_NPS_Promoter_Count__c != NULL);
        System.assert(cs.Survey_CES_Score__c != NULL); 
        System.assert(cs.Survey_CSAT_Score__c != NULL);
		*/
    }  
    
}