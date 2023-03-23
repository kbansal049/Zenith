@IsTest
public class DomainCreatorClassTest {
    
    @IsTest
    static void testDomainCreator(){
        
        Test.startTest();
        String assertMsg = 'Domain not null';
        String packageName = 'sbqq';
        System.assertNotEquals(DomainCreatorClass.getAllDomains(null), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('VISUALFORCEHOSTNAME',packageName), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('CONTENTHOSTNAME',packageName), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('EXPERIENCECLOUDSITESBUILDERHOSTNAME',packageName), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('EXPERIENCECLOUDSITESHOSTNAME',packageName), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('EXPERIENCECLOUDSITESLIVEPREVIEWHOSTNAME',packageName), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('EXPERIENCECLOUDSITESPREVIEWHOSTNAME',packageName), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('LIGHTNINGCONTAINERCOMPONENTHOSTNAME',packageName), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('LIGHTNINGHOSTNAME',packageName), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('ORGMYDOMAINHOSTNAME',packageName), null,assertMsg);
        System.assertNotEquals(DomainCreatorClass.getDomain('SALESFORCESITESHOSTNAME',packageName), null,assertMsg);
        System.assertEquals(DomainCreatorClass.getDomain('SALESFORCE',packageName), null);
        Test.stopTest();        
    }

    @IsTest
    static void testgetAllDomainsException(){
        
        Test.startTest();
        String assertMsg = 'Domain not null';
        DomainCreatorClass.throwException = true;
        try {
            DomainCreatorClass.getAllDomains(null);
            system.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            system.assertNotEquals(e.getMessage(), null,assertMsg);
        }
        Test.stopTest();  
    }

    @IsTest
    static void testgetDomainException(){
        
        Test.startTest();
        String assertMsg = 'Domain not null';
        DomainCreatorClass.throwException = true;
        try {
            DomainCreatorClass.getDomain('VISUALFORCEHOSTNAME','sbqq');
        } catch (AuraHandledException e) {
            system.assertNotEquals(e.getMessage(), null,assertMsg);
        }
        Test.stopTest();  
    }
    
}