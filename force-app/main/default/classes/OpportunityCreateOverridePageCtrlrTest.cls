@isTest
private class OpportunityCreateOverridePageCtrlrTest {
    
    @isTest static void testRedirect() {
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        User me = [SELECT Id, Username, Email, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        User nonAdminUser = new User(FirstName = 'Non Admin', LastName = 'User', Alias = 'nau', ProfileId = ProfileId, UserRoleId = UserInfo.getUserRoleId(),
                                     Username = 'nonadmin@zscaler.test.com', Email = 'nonadmin@zscaler.test.com', CommunityNickname = 'nau', TimeZoneSidKey = me.TimeZoneSidKey,
                                     EmailEncodingKey = me.EmailEncodingKey, LanguageLocaleKey = me.LanguageLocaleKey, LocaleSidKey = me.LocaleSidKey);
        
        System.runAs(nonAdminUser) {
            Account acc = new Account(Name='Test', Type='Reseller',BillingCity = 'San Jose',
                                      BillingCountry = 'United States',
                                      BillingPostalCode = '95134',
                                      BillingState = 'California',
                                      BillingStreet = '110 Rose Orchard Way',
                                      Fax = '',
                                      Phone = '+1 408.533.0288');
            insert acc;
            Contact con = new Contact(Lastname = 'Test');
            insert con;
            Test.setCurrentPage(Page.OpportunityCreateOverridePage);
            ApexPages.currentPage().getParameters().put('retUrl', EncodingUtil.urlEncode('/006/o', 'UTF-8'));
            ApexPages.currentPage().getParameters().put('conId', con.Id);
            ApexPages.currentPage().getParameters().put('accId', acc.Id);
            
            
            Opportunity oppty = new Opportunity();
            ApexPages.StandardController stdController = new ApexPages.StandardController(oppty);
            OpportunityCreateOverridePageController ctrlr = new OpportunityCreateOverridePageController(stdController);
            System.debug('>>>> ' + ctrlr.showError);
            
            ctrlr.redirect();
            ctrlr.goBack();
        }
    }
    
    @isTest static void testOverrideErrorMessage() {
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        User me = [SELECT Id, Username, Email, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        User nonAdminUser = new User(FirstName = 'Non Admin', LastName = 'User', Alias = 'nau', ProfileId = ProfileId, UserRoleId = UserInfo.getUserRoleId(),
                                     Username = 'nonadmin@zscaler.test.com', Email = 'nonadmin@zscaler.test.com', CommunityNickname = 'nau', TimeZoneSidKey = me.TimeZoneSidKey,
                                     EmailEncodingKey = me.EmailEncodingKey, LanguageLocaleKey = me.LanguageLocaleKey, LocaleSidKey = me.LocaleSidKey);
        
        System.runAs(nonAdminUser) {
            Account acc = new Account(Name='Test', Type='Reseller',BillingCity = 'San Jose',
                                      BillingCountry = 'United States',
                                      BillingPostalCode = '95134',
                                      BillingState = 'California',
                                      BillingStreet = '110 Rose Orchard Way',
                                      Fax = '',
                                      Phone = '+1 408.533.0288');
            insert acc;
            Test.setCurrentPage(Page.OpportunityCreateOverridePage);
            ApexPages.currentPage().getParameters().put('retUrl', EncodingUtil.urlEncode('/006/o', 'UTF-8'));
            ApexPages.currentPage().getParameters().put('accId', acc.Id);
            Opportunity oppty = new Opportunity();
            Contact con = new Contact(Lastname = 'Test');
            ApexPages.StandardController stdController = new ApexPages.StandardController(oppty);
            OpportunityCreateOverridePageController ctrlr = new OpportunityCreateOverridePageController(stdController);
            System.debug('>>>> ' + ctrlr.showError);
            
            ctrlr.redirect();
        }
    }
    
    @isTest static void testIncreaseCoverage() {
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        User me = [SELECT Id, Username, Email, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        User nonAdminUser = new User(FirstName = 'Non Admin', LastName = 'User', Alias = 'nau', ProfileId = ProfileId, UserRoleId = UserInfo.getUserRoleId(),
                                     Username = 'nonadmin@zscaler.test.com', Email = 'nonadmin@zscaler.test.com', CommunityNickname = 'nau', TimeZoneSidKey = me.TimeZoneSidKey,
                                     EmailEncodingKey = me.EmailEncodingKey, LanguageLocaleKey = me.LanguageLocaleKey, LocaleSidKey = me.LocaleSidKey);
        
        System.runAs(nonAdminUser) {
            Account acc = new Account(Name='Test', Type='Partner',
                                      Program_Type__c = 'Reseller',
                                      BillingCity = 'San Jose',
                                      BillingCountry = 'United States',
                                      BillingPostalCode = '95134',
                                      BillingState = 'California',
                                      BillingStreet = '110 Rose Orchard Way',
                                      Fax = '',
                                      Phone = '+1 408.533.0288');
            insert acc;
            OpportunityCreateOverridePageController obj = new OpportunityCreateOverridePageController(); 
            obj.showPartnerError = FALSE;
            obj.showClassicError = FALSE;
            obj.showLightningError = FALSE;
            Test.setCurrentPage(Page.OpportunityCreateOverridePage);
            ApexPages.currentPage().getParameters().put('retUrl', EncodingUtil.urlEncode('/006/o', 'UTF-8'));
            ApexPages.currentPage().getParameters().put('accId', acc.Id);
            Opportunity oppty = new Opportunity();
            Contact con = new Contact(Lastname = 'Test');
            ApexPages.StandardController stdController = new ApexPages.StandardController(oppty);
            OpportunityCreateOverridePageController ctrlr = new OpportunityCreateOverridePageController(stdController);
            System.debug('>>>> ' + ctrlr.showError);
            
            ctrlr.redirect();
        }
    }
}