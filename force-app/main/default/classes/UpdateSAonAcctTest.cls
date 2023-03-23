@isTest
public class UpdateSAonAcctTest {
    
    
    @isTest static void testmethod1() {
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id,Name FROM UserRole WHERE Name like '%Solution%' limit 1];
        
        User  SA1 = new User(
            FirstName = 'SA1',
            LastName = 'CAM',
            Email = 'camuser1@zscaler.com',
            Username = 'camuser1@zscaler.com',
            Alias = 'sa1cam',
            EmailEncodingKey = 'ISO-8859-1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = sysAdminProfile.Id,
            UserRoleId = r.Id
        );
        insert SA1;
        
        User  SA2 = new User(
            FirstName = 'SA2',
            LastName = 'CAM',
            Email = 'camuser2@zscaler.com',
            Username = 'camuser2@zscaler.com',
            Alias = 'sa2cam',
            EmailEncodingKey = 'ISO-8859-1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = sysAdminProfile.Id,
            UserRoleId = r.Id
        );
        insert SA2;
        
        User accountManager = new User(
            FirstName = 'Account Manager',
            LastName = 'RSM',
            Email = 'rsmuser@zscaler.com',
            Username = 'rsmuser@zscaler.com',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = 'rsmusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = sysAdminProfile.Id
        );
        insert accountManager;
        
        User areaDirector = new User(
            FirstName = 'Area Director',
            LastName = 'AD',
            Email = 'aduser@zscaler.com',
            Username = 'areaduser@zscaler.com',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = 'adusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = sysAdminProfile.Id
        );
        insert areaDirector;
        
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(me) {
            
            Test.startTest();
            
            //Create Accounts
            Account testAccount1 = new Account(
                Name = 'Test Account1'
            );
            insert testAccount1;
            
            Account testAccount2 = new Account(
                Name = 'Test Account2');
            insert testAccount2;
            
            //Create Contacts
            Contact con1 = new Contact();
            con1.FirstName = 'Test1';
            con1.LastName = 'Test1';
            con1.AccountId = testAccount1.Id;
            
            Contact con2 = new Contact();
            con2.FirstName = 'Test2';
            con2.LastName = 'Test2';
            con2.AccountId = testAccount1.Id;
            
            Contact con3 = new Contact();
            con3.FirstName = 'Test3';
            con3.LastName = 'Test3';
            con3.AccountId = testAccount2.Id;
            
            Contact con4 = new Contact();
            con4.FirstName = 'Test4';
            con4.LastName = 'Test4';
            con4.AccountId = testAccount2.Id;
            insert new List<Contact> { con1, con2, con3, con4};
                
                
                Map<String, Id> mapSCIRecordTypes = new Map<String, Id>();
            
            for (RecordType rtype : [SELECT Id, Name, DeveloperName FROM RecordType WHERE IsActive = true AND SObjectType = 'Significant_Customer_Interaction__c']) {
                mapSCIRecordTypes.put(rtype.Name, rtype.Id);
            }
            Significant_Customer_Interaction__c sci1 = new Significant_Customer_Interaction__c(
                Date__c = Date.today(),
                RecordTypeId = mapSCIRecordTypes.get('Regular Meeting'),
                Next_Steps__c = 'Test',
                Interaction_With__c = 'Customer',
                Meeting_Notes__c = 'Test',
                Account_Name__c = testAccount1.Id
            );
            
            Significant_Customer_Interaction__c sci2 = new Significant_Customer_Interaction__c(
                Date__c = Date.today(),
                RecordTypeId = mapSCIRecordTypes.get('QBR'),
                Next_Steps__c = 'Test',
                Interaction_With__c = 'Customer',
                Meeting_Notes__c = 'Test',
                Account_Name__c = testAccount2.Id
            );
            insert new List<Significant_Customer_Interaction__c> { sci1, sci2 };
            
            
            TriggerUtility.manageZscalerAttendeeExecuted();
            
            SCI_Zscaler_Attendee__c attendee1 = new SCI_Zscaler_Attendee__c(
                Significant_Customer_Interaction__c = sci1.Id,
                Attendee_Name__c = SA1.Id,
                Organizer__c = true,
                Participation__c = 'In Person'
            );
            
            SCI_Zscaler_Attendee__c attendee2 = new SCI_Zscaler_Attendee__c(
                Significant_Customer_Interaction__c = sci1.Id,
                Attendee_Name__c = areaDirector.Id,
                Organizer__c = false,
                Participation__c = 'In Person'
            );
            
            SCI_Zscaler_Attendee__c attendee3 = new SCI_Zscaler_Attendee__c(
                Significant_Customer_Interaction__c = sci2.Id,
                Attendee_Name__c = areaDirector.Id,
                Organizer__c = true,
                Participation__c = 'In Person'
            );
            
            insert new List<SCI_Zscaler_Attendee__c> { attendee1, attendee2, attendee3 };
                
                
             String attendee3Name = [Select Name from SCI_Zscaler_Attendee__c where id = :attendee3.id].Name;
            
            //Update SCI [NONSA --> SA]
            attendee3.Attendee_Name__c = SA2.Id;
            update attendee3;
            
            //Update SCI Again [SA --> NONSA]
            attendee3.Attendee_Name__c = areaDirector.Id;
            update attendee3;
            
            
            //Update SCI [NONSA --> SA]
            attendee3.Attendee_Name__c = SA2.Id;
            update attendee3;
            
            //Delete SCI
            DELETE attendee3;
            
            //Undelete
            SCI_Zscaler_Attendee__c[] allSCI = [SELECT Id, Name FROM SCI_Zscaler_Attendee__c where name = :attendee3Name ALL ROWS]; 
            
            undelete allSCI;
            
            Test.stopTest();
        }
        
    }
    
}