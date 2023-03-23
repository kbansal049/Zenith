@isTest
public class ShowDutyManagerDetailsControllerTest {
    
    @TestSetup
    static void setupData(){
        //User
        User sysUser = TestDatafactory_Zscaler.insertAdminUser('puser000@amamama.com', 'Admin', 'System', 'alias', 
                    'puser000@amamama.com' + System.currentTimeMillis(), 'America/Los_Angeles', 'en_US', 'UTF-8', 'en_US');

        //Account
        String accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
        Account accObj = TestDatafactory_Zscaler.insertAccount('Test Account', null, 'Customer', accRecordTypeId, null, 300);

        //Case
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = TestDatafactory_Zscaler.insertCase('New', 'Test Subject', 'Test Commment',accObj.Id , null, null, caseRecordTypeId);
        cs.Priority='Urgent (P1)';
        cs.Case_type__c = 'Problem';
        cs.Product_New__c='ZPA';
        update cs;

        //Time zone calculations
        Timezone pstTz = Timezone.getTimeZone(GCSCommonConstants.AMERICA_LA_TIME_ZONE);
        DateTime currentTimePst1 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000));
        DateTime currentTimePst2 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000)).addHours(8);

        //Service Resource
        ServiceResource resource = TestDatafactory_Zscaler.insertServiceResource('Agent x', sysUser.Id, 1, 5, 0, 0, 0, 'Frontline');
        resource.IsActive = true;
        update resource;

        //Operating Hours
        OperatingHours oh = new OperatingHours();
		oh.name = 'Test oh';
		oh.TimeZone = 'America/Los_Angeles';
		insert oh;

        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'Zscaler Service Territory';
        st.IsActive = true;
        st.OperatingHoursId = oh.id;
        insert st;

        //Service Territory Member
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
		stm.ServiceResourceId = resource.id;
		stm.ServiceTerritoryId = st.id;
		stm.OperatingHoursId = oh.id;
		stm.EffectiveStartDate = currentTimePst1.addDays(-2);
		stm.EffectiveEndDate = currentTimePst2.addDays(10);
		insert stm;        

        //Shift
        Datetime targetDate = System.today();
        String dayOfWeek = targetDate.format('EEEE');
        
        DateTime startPst = System.now().addHours(-2).addSeconds((pstTz.getOffset(Datetime.now())/1000));
        DateTime endPst = System.now().addHours(2).addSeconds((pstTz.getOffset(Datetime.now())/1000));
        Shift shiftObj = TestDatafactory_Zscaler.insertShift(resource.Id, 'P1',dayOfWeek, startPst,endPst,'Extended',st.Id ,'Regular' );
        shiftObj.Type__c = 'Duty Manager';
        shiftObj.Duty_Manager__c = sysUser.Id;
        shiftObj.Backup_Duty_Manager__c = sysUser.Id;
        shiftObj.Product__c = 'ZIA+ZPA';
        update shiftObj;
    }

    @isTest
    public static void test(){
        //Case cs = [SELECT Id, Product_New__c, IsEscalated, Customer_Segment__c FROM Case LIMIT 1];
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = GCSTestDataFactory.createCase('Test Experience Case', GCSCommonConstants.CASE_PRODUCT_ZPA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_URGENT,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_PROBLEM, 'America/Los_Angeles', 'Email', caseRecordTypeId, UserInfo.getUserId(), null);
        insert cs;
        Test.startTest();
            ShowDutyManagerDetailsController.getDetails(cs.Id);
            ShowDutyManagerDetailsController.checkEscalation(cs.Id);
        	ShowDutyManagerDetailsController.getDetails(null);
        	ShowDutyManagerDetailsController.checkEscalation(null);
        	Shift sf = [select id, Product__c, Segment__c from Shift limit 1];
        	sf.Product__c = 'ZPA';
        	update sf;
        	ShowDutyManagerDetailsController.getDetails(cs.Id);
        	sf.Segment__c = 'Premium Plus';
        	sf.Product__c = 'ZIA';
        	update sf;
        	cs.Product_New__c = 'ZIA';
        	update cs;
        	ShowDutyManagerDetailsController.getDetails(cs.Id);
        Test.StopTest();
    }
}