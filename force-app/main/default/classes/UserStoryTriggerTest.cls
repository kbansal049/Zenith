@isTest
public class UserStoryTriggerTest {
    @IsTest
    static void test1(){
        Test.startTest();
        Triggers_Switch__c ts = new Triggers_Switch__c(name = 'Execute_US_Trigger', Execute__c = true);
        insert ts;      
        User u = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Update u;
        
        copado__Project__c P = new copado__Project__c();
        P.name = 'Test';
        P.OwnerId = u.Id;
        Insert P;
        
        copado__Environment__c E = new copado__Environment__c();
        E.Name = 'SBDEV25';
        E.copado__Platform__c = 'Salesforce';
        E.copado__Type__c = 'Sandbox';
        Insert E;
        
        copado__Org__c O = new copado__Org__c();
        O.Name='SBDEV25';
        O.copado__Environment__c = E.Id;
        Insert O;     
        
        copado__User_Story__c US = new copado__User_Story__c(copado__User_Story_Title__c = 'Test US', OwnerId = u.Id, copado__Project__c = P.Id, copado__Environment__c = E.id,copado__Org_Credential__c = O.Id);
        Insert US;
        US.copado__Promote_and_Deploy__c = True;
        US.copado__Metadata_Types_in_Selection__c='ApexClass';
        
        try{        
            Update US;
            CalloutException msg = new CalloutException();
            msg.setMessage('An exception should have been thrown by the trigger but was not.');
            system.debug(msg);       
        }
        
        catch(Exception exp){
            system.debug(exp);    
        } 
        
        Test.stopTest();
    }   
	@IsTest 
    static void test2(){
        Test.startTest();
        Triggers_Switch__c ts = new Triggers_Switch__c(name = 'Execute_US_Trigger', Execute__c = true);
        insert ts;      
        User u = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Update u;
        
        copado__Project__c P = new copado__Project__c();
        P.name = 'Test';
        P.OwnerId = u.Id;
        Insert P;
        
        copado__Environment__c E = new copado__Environment__c();
        E.Name = 'SBDEV25';
        E.copado__Platform__c = 'Salesforce';
        E.copado__Type__c = 'Sandbox';
        Insert E;
        
        copado__Org__c O = new copado__Org__c();
        O.Name='SBDEV25';
        O.copado__Environment__c = E.Id;
        Insert O;     
        
        copado__User_Story__c US = new copado__User_Story__c(copado__User_Story_Title__c = 'Test US', OwnerId = u.Id, copado__Project__c = P.Id, copado__Environment__c = E.Id,copado__Org_Credential__c = O.Id);
        Insert US;
        system.debug(US);      
        US.copado__Promote_and_Deploy__c = True;
        US.copado__Metadata_Types_in_Selection__c='ApexClass';

        id CodescanResultId = Schema.getGlobalDescribe().get('copado__Static_Code_Analysis_Result__c').getDescribe().getRecordTypeInfosByName().get('CodeScan').getRecordTypeId();
        copado__Static_Code_Analysis_Result__c SCA = new copado__Static_Code_Analysis_Result__c(RecordTypeId = CodescanResultId, copado__User_Story__c = US.Id, copado__Org_Credential__c = O.Id); 
		Insert SCA;
        
        try{        
            Update US;
            CalloutException msg = new CalloutException();
            msg.setMessage('An exception should have been thrown by the trigger but was not.');
            system.debug(msg);       
        }
        
        catch(Exception exp){
            system.debug(exp);    
        } 

        id CodescanViolationId = Schema.getGlobalDescribe().get('copado__Static_Code_Analysis_Violation__c').getDescribe().getRecordTypeInfosByName().get('CodeScan').getRecordTypeId();
        copado__Static_Code_Analysis_Violation__c SCV = new copado__Static_Code_Analysis_Violation__c(RecordTypeId = CodescanViolationId, copado__Static_Code_Analysis_Result__c = SCA.Id, copado__Priority__c = 2);
		Insert SCV;

        try{        
            Update US;
            CalloutException msg = new CalloutException();
            msg.setMessage('An exception should have been thrown by the trigger but was not.');
            system.debug(msg);       
        }
        
        catch(Exception exp){
            system.debug(exp);    
        } 
        
        Test.stopTest();
    }    
}