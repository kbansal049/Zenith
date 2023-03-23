@isTest
public with sharing class Test_Slack_GCS {
    static final String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
    static final String CASE_ESCALATION_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME);

    static Slack.App slackApp;
    static Slack.TestHarness testHarness;
    static Slack.TestHarness.State slackState;
    static Slack.TestHarness.UserSession userSession;
    static String teamId;
    static String memberId;
    static User crrUsrRep;
    static User crrUsrVP;

    static {
        //Setup test harness and user session
        slackApp = Slack_Utilities.getCurrentOrgSlackApp();
        testHarness = new Slack.TestHarness();
        slackState = testHarness.getNewSlackState();
        userSession = slackState.createUserSession();
        Slack.TestHarness.Team slackTestTeam = slackState.createTeam('Test-Slack-Zscaler-Apex-SDK');
        Slack.TestHarness.User slackTeamUser = slackState.createUser('slackZS@zssf.com', 'Test Class User', slackTestTeam);
        crrUsrRep = [SELECT Id, Level__c, Service_Level__c, Profile.name FROM User WHERE (Level__c = 'Rep' AND isActive = True) LIMIT 1];
        crrUsrVP = [SELECT Id, Level__c, Service_Level__c, Profile.name FROM User WHERE  (Level__c = 'VP' AND isActive = True) LIMIT 1];
        teamId = slackTestTeam.getId();
        memberId = slackTeamUser.getId();
    }

    @testSetup static void setup() {
        Case supportCase = new Case(Product_New__c = 'ZDX',
                                    Subject = 'Support Test',
                                    Priority = 'Medium (P3)',
                                    Case_Type__c = 'Problem',
                                    Status = GCSCommonConstants.CASE_STATUS_NEW,
                                    Preferred_Contact_Time_Zone__c = 'Pacific/Tongatapu',
                                    Preferred_Method_of_Contact__c = 'Email',
                                    RecordTypeId = CASE_SUPPORT_RT_ID);
        insert supportCase;
        
        Case supportCase2 = new Case(Product_New__c = 'ZPA',
                                     Subject = 'Support Test2',
                                     Priority = 'Medium (P3)',
                                     Case_Type__c = 'Question',
                                     Status = GCSCommonConstants.CASE_STATUS_NEW,
                                     Preferred_Contact_Time_Zone__c = 'Pacific/Tongatapu',
                                     Preferred_Method_of_Contact__c = 'Phone',
                                     RecordTypeId = CASE_SUPPORT_RT_ID);
        insert supportCase2;
        
        Case defconCase = new Case(Escalation_Level__c = 'Level 0',
                                   Subject = 'Defcon Test',
                                   Escalation_category__c = 'Responsiveness of assigned Engineer',
                                   Escalation_Reason__c = 'Problem',
                                   Status = GCSCommonConstants.CASE_STATUS_NEW,
                                   OwnerId = UserInfo.getUserId(),
                                   Escalation_Start_Time__c = System.now(),
                                   Escalated_By__c = UserInfo.getUserId(),
                                   RecordTypeId = CASE_ESCALATION_RT_ID,
                                   ParentId = supportCase.Id, 
                                   Defcon_Level__c = '4', 
                                   Case_Escalated_per_Defcon_Process__c = true);
        insert defconCase;
        
        Case emptyCase = new Case(Product_New__c = 'ZDX',
                                  Subject = 'EMPTY', 
                                  IsEscalated = True,
                                  Priority = 'Medium (P3)',
                                  Case_Type__c = 'Problem',
                                  Status = GCSCommonConstants.CASE_STATUS_NEW,
                                  Preferred_Contact_Time_Zone__c = 'Pacific/Tongatapu',
                                  Preferred_Method_of_Contact__c = 'Email',
                                  RecordTypeId = CASE_SUPPORT_RT_ID);
        insert emptyCase;
        
        insert new List<DEFCON_ReEscalation_Mapping__c>{
            new DEFCON_ReEscalation_Mapping__c(Name = '3', Level__c = 'Rep'),
            new DEFCON_ReEscalation_Mapping__c(Name = '5', Level__c = 'VP')};
    }

    @isTest
    static void testSlack_Utilities() {
        Slack_Utilities.getMessageModalView('Err', new List<String>{'a','b',''});
        System.assertEquals(URL.getOrgDomainUrl().toExternalForm(), Slack_Utilities.testOrgDomain, 'Org Domain set correctly for Utility');
        Slack_Utilities.testOrgDomain = System.Label.zs_production_sfdc_base_url;
        Slack_Utilities.getCurrentOrgSlackApp();
        
        Slack_Utilities.testOrgDomain = System.Label.zs_stage_sbx_sfdc_base_url;
        Slack_Utilities.getCurrentOrgSlackApp();
        
        Slack_Utilities.testOrgDomain = System.Label.zs_uat_sbx_sfdc_base_url;
        Slack_Utilities.getCurrentOrgSlackApp();
        
        Slack_Utilities.testOrgDomain = System.Label.zs_qa_sbx_sfdc_base_url;
        Slack_Utilities.getCurrentOrgSlackApp();
        
        Slack_Utilities.testOrgDomain = System.Label.zs_sbdev36_sbx_sfdc_base_url;
        Slack_Utilities.getCurrentOrgSlackApp();
        
        Slack_Utilities.testOrgDomain = System.Label.zs_sbdev28_sbx_sfdc_base_url;
        Slack_Utilities.getCurrentOrgSlackApp();

        Slack.BotClient botClient = Slack_Utilities.getSlackBotClient(Test_Slack_GCS.teamId);
        Map<String, List<Slack.ViewReference>> viewRefMap = new Map<String, List<Slack.ViewReference>>();
        Slack.ViewReference viewRef = Slack.View.case_escalation_alert_message.get();
        viewRefMap.put(Test_Slack_GCS.memberId, new List<Slack.ViewReference>{viewRef});
        Slack_Utilities.sendMessages(botClient, new List<Slack.ViewReference>{viewRef} , Test_Slack_GCS.memberId);
        Slack_Utilities.sendMessages(botClient, viewRefMap);
    }

    @isTest
    static void testAppHomeOpened() {
        // open app home and assert the content
        Slack.TestHarness.Home home = userSession.openAppHome(slackApp);
        System.assert(home.getComponentCount() > 0, 'Home Page Loaded!');
        
        Slack.TestHarness.Button escalateButton = home.getButtonByLabel('Escalate Case');
        escalateButton.click();
    }

    @isTest
    static void testCaseSearch() {
        Test.startTest();
            userSession.executeSlashCommand('/escalate-case', slackApp);
            Slack.TestHarness.Modal modal = userSession.getTopModal();
            Slack.TestHarness.Input caseInput = modal.getInputByLabel('Please Enter Case Number');
            Slack.TestHarness.TextInput caseInText = (Slack.TestHarness.TextInput) caseInput.getComponent(Slack.TestHarness.TextInput.class);
            caseInText.setValue('12345678');
            modal.submit();
            
            caseInText.setValue('EXCEPTION');
            modal.submit();
            Case supportCase =[SELECT caseNumber,IsEscalated FROM Case WHERE RecordType.DeveloperName = :GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME AND Subject = 'Support Test'];
            Case defconCase = [SELECT caseNumber, ParentId, IsEscalated FROM Case WHERE RecordType.DeveloperName = :GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME AND Subject = 'Defcon Test'];
            
            caseInText.setValue(supportCase.CaseNumber);
            modal.submit();
    
            supportCase.IsEscalated = True;
            update supportCase;
            
            caseInText.setValue(supportCase.CaseNumber);
            modal.submit();
            
            supportCase.Status = 'Closed';
            update supportCase;
            
            caseInText.setValue(supportCase.CaseNumber);
            modal.submit();
            System.assertEquals(supportCase.Id, defconCase.ParentId, 'Parent Id matching');
            
            System.runAs(Test_Slack_GCS.crrUsrRep) {
                caseInText.setValue(defconCase.CaseNumber);
                modal.submit();
            }
    
            System.runAs(Test_Slack_GCS.crrUsrVP) {
                caseInText.setValue(defconCase.CaseNumber);
                modal.submit();
            }
    
            Case emptyCase = [SELECT CaseNumber, IsEscalated FROM Case WHERE RecordType.DeveloperName = :GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME AND Subject = 'EMPTY'];
            caseInText.setValue(emptyCase.CaseNumber);
            modal.submit();
            userSession.closeAllModals();
        Test.stopTest();
    }

    @isTest
    static void testCaseEscalation(){
        Slack_GCS_CaseEscalation escCase = new Slack_GCS_CaseEscalation();
        Map<String, Object> parameters = new Map<String, Object>();
        Map<String, Object> formData = new Map<String, Object>();

        Case supportCase = [SELECT Id, caseNumber,IsEscalated FROM Case WHERE RecordType.DeveloperName = :GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME AND Subject = 'Support Test2'];
        
        parameters.put('caseNumber',supportCase.caseNumber);
        parameters.put('caseId',supportCase.Id);
        parameters.put('recordTypeName',GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
        parameters.put('isEscalated',True);

        formData.put('Escalation_Category__c', 'Unsatisfied with current support');
        formData.put('Escalatation_Notes__c', 'Test Notes by test class');
        formData.put('Escalation_Reason__c', 'Test Reason by tes class');
        formData.put('Escalation_on_behalf_of_Customer__c', True);

        Slack.RequestContext context = new Slack.RequestContext.Builder()
            .teamId(Test_Slack_GCS.teamId)
            .userId(Test_Slack_GCS.memberId)
            .formData(formData)
            .build();

        escCase.invoke(parameters, context);
        //Unable to call inner values in return modal, need to explore more
        //Slack_GCS_CaseEscalation.Handler escHandle = new Slack_GCS_CaseEscalation.Handler(parameters, context);
        //Slack.ModalView escResp = escHandle.call();
        //System.assertEquals(True, String.valueOf(escResp).contains('title=Escalated'), 'Checking Title of retrun Resp');

        parameters.put('isEscalated',False);
        Slack_GCS_CaseEscalation.Handler escHandle2 = new Slack_GCS_CaseEscalation.Handler(parameters, context);
        escHandle2.call();

        parameters.put('caseNumber','EXCEPTION');
        Slack_GCS_CaseEscalation.Handler escHandle3 = new Slack_GCS_CaseEscalation.Handler(parameters, context);
        escHandle3.call();

        formData.put('Escalation_Category__c', 'Restricted Picklist');
        Slack.RequestContext context3 = new Slack.RequestContext.Builder()
            .teamId(Test_Slack_GCS.teamId)
            .userId(Test_Slack_GCS.memberId)
            .formData(formData)
            .build();
        Slack_GCS_CaseEscalation.Handler escHandle4 = new Slack_GCS_CaseEscalation.Handler(parameters, context3);
        escHandle4.call();

        Slack_GCS_CaseEscalation.postCaseMsg(GCSCommonConstants.EMPTY_STRING, GCSCommonConstants.EMPTY_STRING, GCSCommonConstants.EMPTY_STRING, GCSCommonConstants.EMPTY_STRING);
    }
}