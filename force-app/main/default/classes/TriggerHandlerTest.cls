@IsTest
private class TriggerHandlerTest {
    
    @testSetup 
    static void setup() {       
        
        PatchTeam__c emeaPatchTeam1 = new PatchTeam__c();
        emeaPatchTeam1.Area__c = 'EMEA';
        emeaPatchTeam1.Region__c = 'EMEA';
        emeaPatchTeam1.Territory_Type__c = 'Catch All';
        emeaPatchTeam1.Theater__c = 'EMEA';
        emeaPatchTeam1.Sales_Engineer__c = System.UserInfo.getUserId();
        
        TriggerUtility.realignPatchReset();
        INSERT emeaPatchTeam1;
        
        PatchFieldMapping__c mapping = new PatchFieldMapping__c(Name='EMEA', Object__c='Lead', Type__c='Field', Field__c='Name', Value__c='Company');
        INSERT mapping;
        PatchFieldMapping__c mapping2 = new PatchFieldMapping__c(Name='EMEA acc', Object__c='Account', Type__c='Field', Field__c='Name', Value__c='Company');
        INSERT mapping2;
        

        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=emeaPatchTeam1.Id, Role__c='EMEA', User__c=UserInfo.getUserId());
        INSERT member;
        
        Patch__c patch = new Patch__c(PatchName__c='EMEA', Active__c=true,PatchTeam__c=emeaPatchTeam1.Id);
        INSERT patch;
        
        System.debug('-=-= emeaPatchTeam1 -=- '+emeaPatchTeam1);
        
        Account acc = new Account(Name = 'Test Account', Type='Prospect', Patch__c = patch.Id,PatchLocked__c = true);
        INSERT acc;    
    }    
    
    @isTest 
    static void testChurnForm(){
        
        By_Pass_Trigger_For_User__mdt bypassForUser = new By_Pass_Trigger_For_User__mdt();
        bypassForUser.DeveloperName = 'OpenPriseIntegration';
        bypassForUser.MasterLabel = 'OpenPriseIntegration';
        bypassForUser.Label = 'OpenPriseIntegration';
        bypassForUser.Object_Name__c = 'Opportunity';
        bypassForUser.User_Name__c = UserInfo.getUserName();//'openpriseintegration@zscaler.com.sbdev26';
        bypassForUser.Deactivate_Components__c = FALSE;
        
        
        TriggerUtility.skipOppBeforeUpdateTriggerReset();
        Triggers_Switch__c ts1 = new Triggers_Switch__c(Name='Execute_Opp_Trigger',Execute__c=True);
        INSERT ts1;
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        
        Opportunity opp = new Opportunity(Name='Test Opportunity 1',AccountId = acc.Id,Type='New Business', StageName = label.Stage_1_Alignment,CloseDate = System.Today()+10,Has_Technology_Partner__c=true );
        INSERT opp;
        
        Test.startTest();
        opp.Reason_for_5C__c = 'Test1';
        opp.StageName = System.Label.Stage_5C_Opportunity;
        
        //UPDATE opp;
        
        opp.Stagename = Label.Stage_7_Closed_Lost;
        opp.Sub_Stage__c = System.Label.SubStage_Closed_Lost;
        opp.CloseDate = Date.Today().addDays(20);
        
        //UPDATE opp;
        
        opp.Sub_Stage__c = 'Closed: Delete Duplicate';
        opp.CloseDate = Date.Today().addDays(20);
        
        //UPDATE opp;
        
        TriggerUtility.skipOppBeforeUpdateTriggerExecuted();
        Test.stopTest();
        
        DELETE opp;
    }
       
    @IsTest
    static void testLoopMethods() {
        TriggerHandler th = new TriggerHandler();
        th.setMaxLoopCount(5);
        th.clearMaxLoopCount();
        TriggerHandler.LoopCount thlpNoMax = new TriggerHandler.LoopCount();
        TriggerHandler.LoopCount thlp = new TriggerHandler.LoopCount(5);
        thlp.increment();
        thlp.exceeded();
        System.assertEquals(5,thlp.getMax(),'sb same as input');
        thlp.setMax(7);
        System.assertEquals(7,thlp.getMax(),'sb same as input');
        Integer iCount = thlp.getCount();
    }
        
    @isTest
    static void testStaticMethods() {
        TriggerHandler.bypass('OrderTriggerHandler');
        TriggerHandler.clearBypass('OrderTriggerHandler');
        TriggerHandler.isBypassed('OrderTriggerHandler');
        TriggerHandler.clearAllBypasses();
    }
    
    @IsTest
    static void testCoverageForOtherMethods() {
        
        TriggerHandler trigHandler = new TriggerHandler();
        trigHandler.setMaxLoopCount(1);
        trigHandler.clearMaxLoopCount();
        trigHandler.beforeInsert();
        trigHandler.beforeUpdate();
        trigHandler.beforeDelete();
        trigHandler.afterInsert();
        trigHandler.afterUpdate();
        trigHandler.afterDelete();
        trigHandler.afterUndelete();
    }
    
    @isTest
    static void byPassTriggerForUserClassTest(){
        
        User usr = [SELECT Id, Name, UserName FROM User WHERE Username LIKE '%OpenPriseIntegration%'];        
        System.runAs(usr){
            ByPassTriggerForUserClass.userCustomMap('Opportunity');
        }
    }
    
}