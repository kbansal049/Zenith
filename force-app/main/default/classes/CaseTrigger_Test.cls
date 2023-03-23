@isTest
public class CaseTrigger_Test {

    @testSetup static void setup() {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        List<Triggers_Switch__c> trlist = new List<Triggers_Switch__c>();
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Id supportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        trlist.add(new Triggers_Switch__c(name = 'Execute_UpdateNOCSubject', Execute__c = true));
        trlist.add(new Triggers_Switch__c(name = 'Execute_SendEscalationEmail', Execute__c = true));
        insert trlist;
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '23xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');

        Case_Quota_Management__c cs = new Case_Quota_Management__c();
        cs.SetupOwnerId=UserInfo.getOrganizationId();
        cs.Backline_Daily_Quota__c=2;
        cs.Backline_Weekly_Quota__c=10;
        cs.Frontline_Daily_Quota__c=3;
        cs.Frontline_Weekly_Quota__c=15;
        cs.Online_Omni_Status__c='Quota_Met;Overflow';
        cs.Profiles_Allowed__c='';
        cs.Skills_to_Skip__c='CS;TAM';
        cs.Timezone__c='America/Los_Angeles';
        cs.Weekday_End_Time__c=0;
        cs.Weekday_Start_Time__c=7;
        cs.Weekend_End_Day__c='Sun';
        cs.Weekend_End_Time__c=16;
        cs.Weekend_Start_Day__c	='Fri';
        cs.Weekend_Start_Time__c=19;
        insert cs;
        
        Account testSetacct = new Account();
        testSetacct.name = 'Test Account Service Cloud Test Class';
        testSetacct.Type = 'Customer';
        testSetacct.RecordTypeId = '01270000000EAFsAAO';
        testSetacct.Case_Escalation_Notification_Recipients__c = 'bdeshmukh77@z.com';
        insert testSetacct;
        System.debug('**testsetup Account : '+testSetacct);

        Contact testSetcon = new Contact();
        testSetcon.AccountId = testSetacct.Id;
        testSetcon.LastName = 'Test Contact Service Cloud GCS POD Test Class';
        testSetcon.Email = 'testServiceCloudIgnoreEmailgcspod@gmail.com';
        insert testSetcon;
        System.debug('**testsetup contact : '+testSetcon);

        /*Entitlement entitle = new Entitlement();
        entitle.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        entitle.AccountId = testSetacct.Id;        
        entitle.StartDate=date.today();        
        Insert entitle;
        System.debug('**entitle : '+[Select Id, Name,Status from Entitlement WHERE Name Like '%Defcon%' AND EndDate = null and Status = 'Active']);
        //Creating Group
        Group testGroup = new Group(Name='Defcon_Escalation_Queue', Type='Queue');
        insert testGroup;
        

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
         //Associating queue with group AND to the Case object
         QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
         insert testQueue;
        }*/
         //Support Case
        Case csSupport = new Case();
        csSupport.Subject = 'Test Support Case';
        csSupport.Product_New__c = 'ZIA';
        csSupport.Status = 'New';
        csSupport.Priority = 'Medium (P3)';
        csSupport.Case_Type__c = 'Problem';
        csSupport.Preferred_Contact_Time_Zone__c = 'Pacific/Chatham';
        csSupport.Preferred_Method_of_Contact__c = 'Phone';  
        csSupport.RecordTypeId = supportRecordTypeId;     
        csSupport.OwnerId =  ur.Id;
        csSupport.contactId = testSetcon.Id;
        
        Insert csSupport;

        /* //Escalation Case
         Case csEsc = new Case();
         csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
         csEsc.Case_Escalated_per_Defcon_Process__c = true;
         csEsc.Status = 'New';
         csEsc.Escalation_Reason__c = 'Test Escalation';
         csEsc.Escalation_Category__c = 'Unsatisfied with current support';
         csEsc.ParentId = csSupport.Id;
         csEsc.EntitlementId = entitle.Id;
         csEsc.Escalated_By__c = UserInfo.getUserId();
         csEsc.Defcon_Level__c = '4';
         csEsc.Auto_Esc_SLA_Violated__c = '';
         csEsc.RecordTypeId = escalationRecordTypeId;
         csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
         csEsc.Next_Update_Due__c = Datetime.now().addMinutes(30);
         csEsc.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
         csEsc.OwnerId = [select id,SobjectType,Queue.ID  from QueueSobject where SobjectType='Case' AND QueueID=:testGroup.Id limit 1].Queue.Id;
         Insert csEsc;   */      
        
        System.debug('que query** : '+[SELECT Id, QueueId, Queue.DeveloperName, SobjectType FROM QueueSobject WHERE Queue.DeveloperName = 'Defcon_Escalation_Queue']);
         Service_Agent_Information__c sai = new Service_Agent_Information__c(user__c=ur.id,daily_Quota__c = 1, weekly_quota__c = 5, backlog__c = 1);
         insert sai;

         Timezone pstTz = Timezone.getTimeZone('America/Los_Angeles');
         DateTime currentTimePst1 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000));
         DateTime currentTimePst2 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000)).addHours(8);
         System.debug('**1 -->'+currentTimePst1);
         System.debug('**2 -->'+currentTimePst2);
         Time timeNowPst1 = currentTimePst1.timeGMT();
         Time timeNowPst2 = currentTimePst2.timeGMT();
        Engineer_Schedule__c  es = new Engineer_Schedule__c();
        es.Type__c='Duty Manager';
        es.Start_Time__c = timeNowPst1;
        es.End_Time__c = timeNowPst1;
        es.Product__c = 'ZPA';
        es.Duty_Manager__c =ur.Id;
        es.Backup_Duty_Manager__c = ur.Id;
        es.Service_Agent_Information__c =sai.Id;        
        es.Segment__c = 'Premium Plus';
        es.Priority__c ='P1-P4';
        Insert es;
    }
    
    @IsTest
    static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        //Added by Anup-Start
        //ur.Skills__c = 'Silver';
        ur.Skills__c = 'Premium';
        update ur;
        //Added by Anup-End
        System.runAs(ur){
            
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            TriggerUtility2.setPartnerDiscountExecuted();
            TriggerHandler.bypass('AccountTriggerHandler');
            insert acct;
            
            //Insert Products
            List<Product2> listProduct = new list<Product2>();
            listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
            listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
            insert listProduct;
            
            //Create Contractdetails
            List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
            Contract_Detail__c contractDetail1 = new Contract_Detail__c();
            contractDetail1.Name = 'Migrate as is';
            contractDetail1.Account_Name__c = acct.Id;
            contractDetail1.Product_Name__c = listProduct[0].Id;
            contractDetail1.Start_Date__c = Date.Today();
            contractDetail1.End_Date__c = Date.Today() + 365;
            contractDetail1.Quantity__c = 100;
            contractDetail1.Amount_USD__c = 1000;
            contractDetail1.Contract_No__c = '100';
            contractDetail1.MRR_USD__c = 100;
            contractDetail1.List_Price__c = 100;
            contractDetail1.Discount__c = 10;
            contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
            contractDetailList.add(contractDetail1);
            
            //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' and isActive = true limit 1];
            Contract_Detail__c contractDetail2 = new Contract_Detail__c();
            contractDetail2.Name = 'Split';
            contractDetail2.Account_Name__c = acct.Id;
            contractDetail2.Product_Name__c = listProduct[1].Id;
            contractDetail2.Start_Date__c = Date.Today();
            contractDetail2.End_Date__c = Date.Today() + 365;
            contractDetail2.Quantity__c = 100;
            contractDetail2.Amount_USD__c = 1000;
            contractDetail2.Contract_No__c = '100';
            contractDetail2.MRR_USD__c = 100;
            contractDetail2.List_Price__c = 100;
            contractDetail2.Discount__c = 10;
            contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
            contractDetailList.add(contractDetail2);
            insert contractDetailList;
            
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;
            
            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            cs.Status = 'Researching';
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            //Added by Anup-Start
            TriggerUtility.skipCaseEscalationReset();
            //Added by Anup-End
            Test.startTest();
            try{
                update cs;
                
            }catch(Exception ex){
                
            }
            Test.stopTest();
            //           CaseTriggerUtility.booster();
            TriggerUtility.booster();
        }
    }
    @IsTest
    static void test2(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        System.runAs(ur){
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            TriggerUtility2.setPartnerDiscountExecuted();
            TriggerHandler.bypass('AccountTriggerHandler');
            insert acct;
            
            //Insert Products
            List<Product2> listProduct = new list<Product2>();
            listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
            listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
            insert listProduct;
            
            //Create Contractdetails
            List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
            Contract_Detail__c contractDetail1 = new Contract_Detail__c();
            contractDetail1.Name = 'Migrate as is';
            contractDetail1.Account_Name__c = acct.Id;
            contractDetail1.Product_Name__c = listProduct[0].Id;
            contractDetail1.Start_Date__c = Date.Today();
            contractDetail1.End_Date__c = Date.Today() + 365;
            contractDetail1.Quantity__c = 100;
            contractDetail1.Amount_USD__c = 1000;
            contractDetail1.Contract_No__c = '100';
            contractDetail1.MRR_USD__c = 100;
            contractDetail1.List_Price__c = 100;
            contractDetail1.Discount__c = 10;
            contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
            contractDetailList.add(contractDetail1);
            
            //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' and isActive = true limit 1];
            Contract_Detail__c contractDetail2 = new Contract_Detail__c();
            contractDetail2.Name = 'Split';
            contractDetail2.Account_Name__c = acct.Id;
            contractDetail2.Product_Name__c = listProduct[1].Id;
            contractDetail2.Start_Date__c = Date.Today();
            contractDetail2.End_Date__c = Date.Today() + 365;
            contractDetail2.Quantity__c = 100;
            contractDetail2.Amount_USD__c = 1000;
            contractDetail2.Contract_No__c = '100';
            contractDetail2.MRR_USD__c = 100;
            contractDetail2.List_Price__c = 100;
            contractDetail2.Discount__c = 10;
            contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
            contractDetailList.add(contractDetail2);
            
            insert contractDetailList;
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;
            
            
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            cs.Status = 'Closed';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
    }
    @IsTest
    static void test3(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        //ur.skills__c = 'Platinum';
       
        ur.Skills__c = 'Premium Plus';
        update ur;
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.TAM_Name_New__c = UserInfo.getUserId();
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
       
        System.runAs(ur){
            
            
            //Added by Anup-Start
            TriggerUtility.skipCaseEscalationReset();
            TriggerUtility.SyncBAOnCrReset();
            TriggerUtility.CaseCCtoTeamReset();
            TriggerUtility.UpdateTAMemailReset();
            TriggerUtility.UpdateSEonCaseReset();
            TriggerUtility.startUpdateCaseAccountExtension();
            TriggerUtility.caseCloseCompleteActionPlanSetFalse();
            TriggerUtility.TAMAgentWorkReset();
            TriggerUtility.CaseTAMNotesHistoryReset();
            TriggerUtility.startUpdateAccountDataTime();
            TriggerUtility.ManualCaseAssignReset();
            TriggerUtility.UpdateCSMonCaseReset();
            TriggerUtility.CaseSkillAssignmentReset();
           
            
            //Added by Anup-End
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem', Customer_CC_List__c='test@test.com;test2@test2.com',Status='Closed');
            insert cs;
            //Added by Anup - Start
            Case_Integration__c cInt = new Case_Integration__c();
            cInt.Case__c = cs.Id;
            cInt.Case_Origin__c = 'Siemens';
            cInt.Incident_Type__c='Incident';
            insert cInt;
            
            EmailMessage emsg = new EmailMessage();
            emsg.RelatedToId = cs.Id;
            emsg.ParentId=cs.Id;
            emsg.Incoming = false;
            emsg.TextBody = 'testbody';
            emsg.FromAddress= 'test@test.com';
            insert emsg;
            //Added By Anup- End
            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            cs.Status = 'Researching';
            cs.Case_Type__c = 'Problem';
            //Added by Anup-Start
            cs.Internal_CC_List__c = 'testMail@mail.com';
            cs.Customer_CC_List__c = 'testMail2@mail.com';
            cs.origin = 'API';
            cs.External_Reference__c = 'testRef';
            //Added by Anup-End
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            TriggerUtility.executeCaseAfterUpdateCaseIntegartionSetFalse();
            Test.StartTest();
            try{
                update cs;
                
            }catch(Exception ex){
                
            }
            Test.StopTest();
        }
    }
    @IsTest
    static void test4(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Id accEnddUserRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        //ur.Skills__c = 'Bronze';
        ur.Skills__c = 'Premium';
        update ur;
        System.runAs(ur){
            TriggerUtility2.setPartnerDiscountExecuted();
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = accEnddUserRT;//'01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            TriggerHandler.bypass('AccountTriggerHandler');
            insert acct;
            
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;
            
            
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            TriggerUtility.skipCaseEscalationReset();
            cs.Status = 'Closed';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            
            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
    }
    
    
    @IsTest
    static void test5(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        //Added by Anup-Start
        //ur.Skills__c = 'Gold';
        ur.Skills__c = 'Premium';
        update ur;
        //Added by Anup-End
        System.runAs(ur){
            
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;
            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            cs.Status = 'Researching';
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            //Added by Anup-Start
            TriggerUtility.skipCaseEscalationReset();
            //Added by Anup-End
            Test.startTest();
            try{
                
                update cs;
            }catch(Exception ex){
                
            }
            Test.StopTest();
        }
    }
    @IsTest
    static void test6(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        System.runAs(ur){
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',case_source__c='Integration');
            insert cs;
            
            
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            TriggerUtility.skipCaseEscalationReset();
            cs.Status = 'Closed';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
    }
    
    @IsTest
    static void test7(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        ur.Skills__c = 'TAM';
        update ur;
        System.runAs(ur){
            TriggerUtility2.setPartnerDiscountExecuted();
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            TriggerHandler.bypass('AccountTriggerHandler');
            insert acct;
            
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;
            
            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            cs.Status = 'Researching';
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            TriggerUtility.skipCaseEscalationReset();
            Test.StartTest();
            try{
                update cs;
            }catch(Exception ex){
                
            }
            Test.StopTest();
        }
    }
   /* @IsTest
    static void test8(){
    insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
    insert TestDatafactory_Zscaler.getpriorityscore();
    insert TestDatafactory_Zscaler.getdefconcasescore();
    insert TestDatafactory_Zscaler.getprimsecescmap();
    insert TestDatafactory_Zscaler.getserviceteamtoskill();
    Test.startTest();
    Test.stopTest();
    Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
    User ur = [Select Id from User where ContactId != null and isActive = true limit 1];
    System.runAs(ur){
    
    Account acct = new Account();
    acct.name = 'Test Account';
    acct.Type = 'Customer';
    acct.RecordTypeId = '01270000000EAFsAAO';
    acct.X3rd_TAM_Name__c = UserInfo.getUserId();
    insert acct;
    
    Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
    insert cs;
    
    
    TriggerUtility.CaseBeforeUpdateReset();
    TriggerUtility.CaseAfterUpdateReset();
    cs.Status = 'Closed';
    cs.Case_category__c = 'APIs';
    cs.Case_Sub_Category__c = 'Assets Fix';
    cs.Resolution_Type__c = 'Resolved by KB';
    cs.Resolution_Summary__c = 'Resolved';
    try{
    update cs;
    }catch(Exception ex){
    
    }
    }
    }*/
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
        return productSO;
    }
    
    @isTest 
    static void test9(){    
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = UserInfo.getUserId();
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', status = 'New',case_source__c='Integration',RecordTypeId=caseSupportRT);
        insert cs;
        
        
        // action_plan starus-->completed then case will close.,
        // //for code coverage status is new         
        Action_Plan__c ac1 =new Action_Plan__c();
        ac1.Case__c = cs.Id;
        ac1.Status__c = 'Completed';  
        insert ac1;
        
        Action_Plan__c ac2 =new Action_Plan__c();
        ac2.Case__c = cs.Id;
        ac2.Status__c = 'Completed';
        insert ac2;
        
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();
        TriggerUtility.caseCloseCompleteActionPlanSetFalse();
        
        cs.Status = 'Closed';
        Test.startTest();
        update cs;
        Test.stopTest();
    }
    
    
    
    
    //Added by Varun for CR 1058 - Start
    @IsTest
    static void testCaseTriggers(){
        TriggerUtility.CaseSkillAssignmentReset();
        TriggerUtility.CaseEntitlementReset();
        TriggerUtility.UpdateSEonCaseReset();
        TriggerUtility.UpdateOriginalTAMexecuted();
        TriggerUtility.startUpdateCaseAccountExtension();
        TriggerUtility.CaseCCtoTeamReset();
        TriggerUtility.TAMAgentWorkReset();
        TriggerUtility.CaseDesctoCommentReset();
        TriggerUtility.CaseTAMNotesHistoryReset();
        TriggerUtility.startUpdateAccountDataTime();
        TriggerUtility.skipCaseEscalationReset();
        TriggerUtility.UpdateTAMemailReset();
        TriggerUtility.startUpdateCaseAccountExtension();
        TriggerUtility.ManualCaseAssignReset();
        TriggerUtility.CaseCCtoTeamReset();
        TriggerUtility.CaseEscalationNotesReset();
        TriggerUtility.CaseEscalationHistoryReset();
        TriggerUtility.CaseStatusHistoryReset();
        TriggerUtility.ManualSLAReset();
        Test.startTest();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        System.runAs(ur) {
        	TriggerUtility2.setPartnerDiscountExecuted();
            TriggerHandler.bypass('AccountTriggerHandler');
            Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'josepadin@zscaler.com', 'test', null, null, 5);
            Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
            account.TAM_Name_New__c = UserInfo.getUserId();
            account.Secondary_TAM_Name__c = UserInfo.getUserId();
            account.X3rd_TAM_Name__c = UserInfo.getUserId();
            
            Case  cs = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, null, account.Id, caseSupportRT);        
            //          cs2.Owner = ur.Id;
            Case  cs5 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, null, account.Id, caseSupportRT);        
            cs.Business_Analyst__c=UserInfo.getUserId();
            cs.HandOff_Cases__c= False;
            cs5.HandOff_Cases__c= False;
            cs.Case_Owner_is_TAM__c = true;           
            cs.Internal_CC_List__c = 'true;false';
            cs.Customer_CC_List__c = 'true;false';
            cs.Internal_CC_List__c = 'true;false';
            cs.Customer_CC_List__c = 'true;false';     
            cs.Manual_SLA_Timestamp__c= datetime.newInstance(2016, 9, 15, 12, 30, 0);
            cs5.Manual_SLA_Timestamp__c= datetime.newInstance(2015, 9, 15, 12, 30, 0);
            List<Case> caseList = new List<Case>();
            caseList.add(cs);
            caseList.add(cs5);
            Map<Id,Case> caseMap = new Map<Id,Case>();  
            caseMap.put(cs.Id, cs);
            caseMap.put(cs5.Id, cs5); 
            CaseTriggerUtility.escalateCase(caseList, caseMap);
            cs.HandOff_Cases__c= true; 
            CaseTriggerUtility.escalateCase(caseList, caseMap);
            CaseTriggerUtility.createAgentWorkforTAM(caseList);
            
            CaseTriggerUtility.UpdateTAMemail(caseList);
            
            CaseTriggerUtility.UpdateSEonCase(caseList);
            
            CaseTriggerUtility.cctoCaseTeamafterUpdate(caseList, caseMap);
            
            CaseTriggerUtility.cctoCaseTeamafterInsert(caseList);
            
            CaseTriggerUtility.fillTAMDetails(caseList);       
            
            CaseTriggerUtility.createCaseTeam(caseList);
            
            CaseTriggerUtility.updateTAMWeeklyDateTime(caseList, caseMap);
            
            CaseTriggerUtility.updateExtentison(caseList, caseMap);
            
            CaseTriggerUtility.updateExtentison(caseList, null);
            //Added by Anup-Start
            CaseTriggerUtility.escalateCase(caseList, caseMap);
            CaseTriggerUtility.UpdateTAMemail(caseList);
            CaseTriggerUtility.UpdateSEonCase(caselist);
            
            //Added by Anup-End
            //    CaseTriggerUtility.createTAMNotesHistory(caseList, caseMap);
            
            CaseTriggerUtility.SyncBusinessAnalystWithCR(caseList, caseMap);
            CaseTriggerUtility.UpdateManualRoutingOfCase(caseList, caseMap);
            
            //CaseTriggerUtility.assignTamAsOwner(caseList,caseMap);
            //CaseTriggerUtility.SyncBusinessAnalystWithCR(caselist,caseMap2);
            //CaseTriggerUtility.checkTAMReassignment(caseList,caseMap);
            
            Case  cs2 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, null, account.Id, caseSupportRT);
            cs2.Product_New__c = 'CSPM';
            Case  cs3 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, null, account.Id, caseSupportRT);
            cs3.Product_New__c = 'ZSW';
            Case  cs4 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  null, null, account.Id, caseSupportRT);
            Case  cs6 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, account.Id, account.Id, caseSupportRT);
            Case  cs7 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  null, account.Id, account.Id, caseSupportRT);
            Case  cs8 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  null, account.Id, account.Id, caseSupportRT);
            Case  cs9 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, null, account.Id, caseSupportRT);
            cs9.Product_New__c = 'ZWS';
            Case  cs10 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, null, account.Id, caseSupportRT);
            cs10.Product_New__c = 'Somescreen';
            Case  cs11 = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, null, account.Id, caseSupportRT);
            cs11.case_source__c = 'Integration';
            cs11.Case_Type__c = 'Provisioning';
            cs11.accountId = null;
            List<Case> caseList2 = new List<Case>();  
            List<Case> caseList3 = new List<Case>();
            caseList3.add(cs7);
            cs3.case_source__c = 'Integration';
            cs6.case_source__c = 'Integration'; 
            cs4.Case_Type__c = 'Provisioning';
            cs8.Case_Type__c = 'Categorization';
            cs8.Origin='Sitereview';
            cs8.zscaler_org_id__c='no cloud - site review';
            cs3.Manual_SLA_Timestamp__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
            cs6.Manual_SLA_Timestamp__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
            cs4.Manual_SLA_Timestamp__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
            caseList2.add(cs2);
            caseList2.add(cs3);
            caseList2.add(cs4);
            caseList2.add(cs6);
            caseList2.add(cs8);
            caseList2.add(cs9);
            caseList2.add(cs10);
            caseList2.add(cs11);
            
            
            
            Map<Id,Case> caseMap2 = new Map<Id,Case>(); 
            
            caseMap2.put(cs7.Id, cs7);
            cs7.Manual_SLA_Timestamp__c = datetime.newInstance(2014, 9, 15, 13, 30, 0);
            
            CaseTriggerUtility.manualSLAChange(caseList3, caseMap2);
            
            CaseTriggerUtility.assignCasesbySkill_TamRouting(caseList2);
            cs3.Case_Type__c = null;
            CaseTriggerUtility.convertIntegrationCasestoSupport(caseList2);
            CaseTriggerUtility.escalateCase(caseList2, caseMap);
            
            CaseTriggerUtility.createAgentWorkforTAM(caseList2);
            
            CaseTriggerUtility.UpdateTAMemail(caseList2);
            
            
            CaseTriggerUtility.UpdateSEonCase(caseList2);
            
            CaseTriggerUtility.cctoCaseTeamafterInsert(caseList2);
            
            CaseTriggerUtility.fillTAMDetails(caseList2);       
            
            CaseTriggerUtility.createCaseTeam(caseList2);
            
            
            
            
            
            //       CaseTriggerUtility.createTAMNotesHistory(caseList2, caseMap);
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            cs.Status = 'Closed';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            try{
                update cs;
            }catch(Exception ex){
                
            }   
        }
    }
    //Added by Varun for CR 1058 - End
    
    //Added by Swathi : CR1384 Start
    @IsTest
    static void test11(){
        
        User usr = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz.com', 'test1', 'test', 'ttest1', 'xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        Test.startTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        System.runAs(ur){
            TriggerUtility2.setPartnerDiscountExecuted();
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            acct.TAM_Name_New__c = ur.Id;
            acct.Secondary_TAM_Name__c = ur.Id;
            TriggerHandler.bypass('AccountTriggerHandler');
            insert acct;
            
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem', Status = 'New',OwnerId = usr.Id);
            insert cs;
            
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            cs.OwnerId = usr1.Id;
            cs.Status = 'New';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            cs.Business_Analyst__c=UserInfo.getUserId();
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
        Test.stopTest();
    }
    @IsTest
    static void test12(){
        
        Test.startTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Profile.name = 'System Administrator' and isActive = true limit 1];
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = usr2.Id;
        acct.TAM_Name_New__c = usr2.Id;
        acct.Secondary_TAM_Name__c = usr2.Id;
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New',Business_Analyst__c=ur.Id,case_source__c = 'Integration');
        cs.OwnerId = UserInfo.getUserId();
        list<Case> caselist = new list<Case>{cs};
            insert cs;
        CaseTriggerUtility.assignCasesbySkill_TamRouting(caselist);
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();
        
        Test.stopTest();
    }
    
    @isTest 
    static void test13(){
        
        User usr = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz.com', 'test1', 'test', 'ttest1', 'xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');    
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = UserInfo.getUserId();
        insert acct;
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct1 = new Account();
        acct1.name = 'Test Account1';
        acct1.Type = 'Customer';
        acct1.RecordTypeId = '01270000000EAFsAAO';
        acct1.X3rd_TAM_Name__c = UserInfo.getUserId();
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct1;
        
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', status = 'New',Business_Analyst__c=usr.Id,OwnerId = usr.Id);
        insert cs;
        
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();
        cs.AccountId=acct1.Id;
        cs.OwnerId = usr1.Id;
        cs.Business_Analyst__c=usr1.ID;
        Test.startTest();
        update cs;
        Test.stopTest();
    }
    
    @isTest 
    static void test14(){
        
        User usr = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz.com', 'test1', 'test', 'ttest1', 'xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');      
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = UserInfo.getUserId();
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', status = 'New',case_source__c='Integration',RecordTypeId=caseSupportRT);
        insert cs;
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();
        Test.startTest();
        update cs;
        Test.stopTest();
    }
    
    @isTest 
    static void test15(){
        
        User usr = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz.com', 'test1', 'test', 'ttest1', 'xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');      
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = UserInfo.getUserId();
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        Customer_Score_Card__c custScoreCard = new Customer_Score_Card__c();
        custScoreCard.Account__c = acct.Id;
        insert custScoreCard;
        
        List<Case> CsList = new List<Case>();
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', status = 'New',RecordTypeId=caseSupportRT,Case_Type__c = 'Problem');
        CsList.add(cs);
        Case cs1 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='High (P2)', status = 'New',RecordTypeId=caseSupportRT,Case_Type__c = 'Problem');
        CsList.add(cs1);
        Case cs2 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Low (P4)', status = 'New',RecordTypeId=caseSupportRT,Case_Type__c = 'Question',IsEscalated = True);
        CsList.add(cs2);
        insert CsList;
        Test.startTest();
        CaseTriggerUtility.UpdateCustomerScroceCard(CsList,Null);
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();
        update CsList;
        Test.stopTest();
    }
    
    //Added by Swathi : CR1384 End
    
    //Added by Anup : CR#1304 - Start
    @isTest 
    public static void testTAMReassignmentMethods(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        User usr3 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xy1z.com', 'test121', 'tes1t', 'ttest121', '2xyz@xyz.com.test1', 'GMT', 'en_US', 'UTF-8', 'en_US');
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account 1';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = usr2.Id;
        acct.TAM_Name_New__c = usr2.Id;
        acct.Secondary_TAM_Name__c = usr2.Id;
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct1 = new Account();
        acct1.name = 'Test Account 1';
        acct1.Type = 'Customer';
        acct1.RecordTypeId = '01270000000EAFsAAO';
        acct1.Secondary_TAM_Name__c = usr3.Id;
        insert acct1;
        
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New');
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        
        Case cs1 = new Case(Subject='abcd1', AccountId =  acct1.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New');
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs1;
        
        Case currentCase = [select id,Account.Secondary_TAM_Name__c,Account.Secondary_TAM_Name__r.Out_Of_Office__c, No_of_TAM_Reassignment_Attempts__c,RecordType.Name,TAM_Assignment__c, OwnerId,Next_TAM_Date__c, Is_TAM_Account__c, Is_Current_Owner_TAM__c, Priority, Product_New__c,Case_Type__c from Case where id=:cs.Id];
        
        CaseTriggerUtility.checkTAMReassignment(new List<Case>{currentCase}, null);
        currentCase.Next_TAM_Date__c = System.Now();
        currentCase.TAM_Assignment__c = 'Assigned To Support';
        update cs;
        TriggerUtility.SkipCaseTriggerReset();
        CaseTriggerUtility.checkTAMReassignment(new List<Case>{currentCase}, null);
        
        usr2.Out_Of_Office__c=  true;
        usr2.Start_Date__c = system.today();
        usr2.Returning_Date__c = system.today().addDays(1);
        update usr2;
        currentCase.TAM_Assignment__c= 'Pending TAM Assignment';
        TriggerUtility.AssignTAMOwnerReset();
        TriggerUtility.SkipCaseTriggerReset();
        //update currentCase;
        
        Map<Id, Case> mapOfIdAndCase = new Map<Id, Case>();
        mapOfIdAndCase.put(currentCase.Id, currentCase);
        //CaseTriggerUtility.assignTamAsOwner(new List<Case>{currentCase}, mapOfIdAndCase);
        
        Case currentCase2 = [select id,Account.Secondary_TAM_Name__c,Account.Secondary_TAM_Name__r.Out_Of_Office__c, No_of_TAM_Reassignment_Attempts__c,RecordType.Name,TAM_Assignment__c, OwnerId,Next_TAM_Date__c, Is_TAM_Account__c, Is_Current_Owner_TAM__c, Priority, Product_New__c from Case where id=:cs1.Id];
        Map<Id, Case> mapOfIdAndCase2 = new Map<Id, Case>();
        mapOfIdAndCase2.put(currentCase2.Id, currentCase2);
        //CaseTriggerUtility.assignTamAsOwner(new List<Case>{currentCase2}, mapOfIdAndCase2);
        
        usr2.Out_Of_Office__c=  false;
        usr2.Returning_Date__c = null;
        usr2.Start_Date__c = null;
        update usr2;
        acct1.Secondary_TAM_Name__c = null;
        acct1.X3rd_TAM_Name__c = usr2.Id;
        TriggerHandler.bypass('AccountTriggerHandler');
        update acct1;
        
        Case currentCase3 = [select id,Account.X3rd_TAM_Name__c,Account.X3rd_TAM_Name__r.Out_Of_Office__c, No_of_TAM_Reassignment_Attempts__c,RecordType.Name,TAM_Assignment__c, OwnerId,Next_TAM_Date__c, Is_TAM_Account__c, Is_Current_Owner_TAM__c, Priority, Product_New__c from Case where id=:cs1.Id];
        Map<Id, Case> mapOfIdAndCase3 = new Map<Id, Case>();
        mapOfIdAndCase3.put(currentCase3.Id, currentCase3);
        //CaseTriggerUtility.assignTamAsOwner(new List<Case>{currentCase3}, mapOfIdAndCase3);
    }
    //Added by Anup : CR#1304 - End
    
    //Added by Anup : CR#502 - Start
    @isTest 
    public static void testEmailToTAMManageMethod(){    
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        usr2.Out_of_Office__c = true;
        usr2.Start_Date__c = system.today();
        usr2.Returning_Date__c = System.today()+1;
        update usr2;
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account 1';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.TAM_Name_New__c = usr2.Id;
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        
        Contact con = new Contact();
        con.AccountId = acct.Id;
        con.LastName = 'Test Contact';
        insert con;
        
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New');
        insert cs;
        try{
            cs.OwnerId = usr2.Id;
        	cs.Case_Type__c = 'Provisioning';
        	update cs;
        
       
        TriggerUtility.SkipCaseTriggerReset();
        TriggerUtility.CaseAfterUpdateReset();
        cs.Status = 'Customer Note Added';
        update cs;
            
        }Catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
        }
        
    }
    //Added by Anup : CR#502 - End 
    //Added by Anup : CR#2195 - Start
    @isTest 
    public static void testExcludePartnerSupport(){
        Test.StartTest();
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = userInfo.getUserId();
        sk.Object_s_to_skip__c = 'Account';
        insert sk;
        
        User usr2 = new user();
        usr2.Service_Level__c = 'Support Leads';
        usr2.id= userInfo.getUserId();
        update usr2;
        
        Account acct = new Account();
        acct.name = 'Test Account 1';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.Exclude_Partner_Support__c = true;
        acct.Customer_Support_Segment__c = 'Bronze';
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New', OwnerId = usr2.Id);
        TriggerUtility.CaseSkillAssignmentReset();
        TriggerUtility.SkipCaseTriggerReset();
        insert cs;
        update cs;
        
        acct.Customer_Support_Segment__c = 'Gold';
        update acct;
        Case cs1 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New', OwnerId = usr2.Id);
        TriggerUtility.CaseSkillAssignmentReset();
        TriggerUtility.SkipCaseTriggerReset();
        TriggerUtility.CaseBeforeInsertReset();
        insert cs1;
        
        acct.Customer_Support_Segment__c = 'Silver';
        update acct;
        Case cs2 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New', OwnerId = usr2.Id);
        TriggerUtility.CaseSkillAssignmentReset();
        TriggerUtility.SkipCaseTriggerReset();
        TriggerUtility.CaseBeforeInsertReset();
        insert cs2;
        
        acct.Customer_Support_Segment__c = 'Platinum';
        acct.Exclude_Partner_Support__c = false;
        update acct;
        Case cs3 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New', OwnerId = usr2.Id);
        TriggerUtility.CaseSkillAssignmentReset();
        TriggerUtility.SkipCaseTriggerReset();
        TriggerUtility.CaseBeforeInsertReset();
        insert cs3;
        
        acct.Customer_Support_Segment__c = 'Silver';
        acct.Exclude_Partner_Support__c = false;
        update acct;
        Case cs4 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New', OwnerId = usr2.Id);
        TriggerUtility.CaseSkillAssignmentReset();
        TriggerUtility.SkipCaseTriggerReset();
        TriggerUtility.CaseBeforeInsertReset();
        insert cs4;
        
        acct.Customer_Support_Segment__c = 'Bronze';
        acct.Exclude_Partner_Support__c = false;
        update acct;
        Case cs5 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New', OwnerId = usr2.Id);
        TriggerUtility.CaseSkillAssignmentReset();
        TriggerUtility.SkipCaseTriggerReset();
        TriggerUtility.CaseBeforeInsertReset();
        insert cs5;

        Test.StopTest();
    }
    //Added by Anup : CR#2195 - End   
    //Added by Chetan : CR#2268-Start
    @isTest
    public static void testCreateContactUnderAccount()
    {
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case();
        cs.Subject='With no domain exist';
        cs.Origin='Sitereview';
        cs.Priority='Low (P4)';
        cs.RecordTypeId=caseSupportRT;
        cs.Description='With no domain exist';
        cs.Case_Type__c='Categorization';
        cs.Current_Category__c = 'Test';
        cs.Suggested_Category__c = 'Test';
        cs.Status = 'New';
        cs.Case_Created_By_Email__c='devtest@devtest.com';
        TriggerUtility.SkipCaseTriggerReset();
        insert cs;
        Account acct= new Account ();
        acct.name = 'Test Account 1';
        acct.Type = 'Customer';
        acct.Domain__c='gmail.com';
        TriggerUtility.SkipCaseTriggerReset();
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        Case cs1 = new Case();
        cs1.Subject='With domain exist';
        cs1.Accountid=acct.id;
        cs1.Origin='Sitereview';
        cs1.Priority='Low (P4)';
        cs1.RecordTypeId=caseSupportRT;
        cs1.Description='With domain exist';
        cs1.Case_Type__c='Categorization';
        cs1.Status = 'New';
        cs1.Case_Created_By_Email__c='domainexist@gmail.com';
        TriggerUtility.SkipCaseTriggerReset();
        insert cs1;
    }
    
    //Added by Chetan : CR#2268-End    
    
    //Added by Ankit : CR#2750 - Start
    @isTest
    public static void test_setRequestType()
    {
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case();
        cs.Subject='With no domain exist';
        cs.Resolution_State__c='Resolved';
        cs.Origin='Sitereview';
        cs.Priority='Low (P4)';
        cs.RecordTypeId=caseSupportRT;
        cs.Description='URL : wetransfer.com , Comment : We need this site to send files - Email to notify: lena.dumontet@siemensgamesa.com (Url 1 out of 1)';
        cs.Case_Type__c='Categorization';
        cs.Current_Category__c = 'Test';
        cs.Suggested_Category__c = 'Test';
        cs.Status = 'New';
        cs.Case_Created_By_Email__c='devtest@devtest.com';
        TriggerUtility.SkipCaseTriggerReset();
        insert cs;
        Case cs1 = new Case();
        cs.Subject='With domain exist';
        cs.Origin='Sitereview';
        cs.Priority='Low (P4)';
        cs.RecordTypeId=caseSupportRT;
        cs.Description='URL : wetransfer.com , Comment : We need this site to send files - Email to notify: lena.dumontet@siemensgamesa.com (Url 1 out of 1)';
        cs.Case_Type__c='Categorization';
        cs.Current_Category__c = 'Miscellaneous or Unknown';
        cs.Suggested_Category__c = 'Test';
        cs.Status = 'New';
        cs.Case_Created_By_Email__c='domainexist@gmail.com';
        TriggerUtility.SkipCaseTriggerReset();
        insert cs1;
    }
    //Added by Ankit : CR#2750 - End
     /*//Added by Chetan : CR#2495 - Start
     @isTest
    public static void testsendEmailForCancelledMeeting()
    {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Trigger', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_SendEmailForCancelledMeeting', Execute__c = true));
        insert trlst;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        Account acct= new Account ();
        acct.name = 'Test Account 1';
        acct.Type = 'Customer';
        TriggerUtility.SkipCaseTriggerReset();
        insert acct;
        Contact con = new Contact();
        con.AccountId = acct.Id;
        con.LastName = 'Test Contact';
        insert con;
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem');
        TriggerUtility.SkipCaseTriggerReset();
        insert cs;
        cs.OwnerId = usr2.Id;
        cs.Chili_Piper_Meeting_Status__c= 'Cancelled (If CP Meeting is cancelled)';
        TriggerUtility.SkipCaseTriggerReset();
        TriggerUtility.CaseAfterUpdateReset();
        update cs;
    }
    //Added by Chetan : CR#2495 - End*/
    @IsTest
    static void tamRoutingCase_Test(){
        Test.startTest();
        Timezone_Region_Mapping__c regionMap = new Timezone_Region_Mapping__c(name='Asia/Kolkata',Timezone__c='Asia/Kolkata',Region__c='APAC');
        insert regionMap;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Profile.name = 'System Administrator' and isActive = true limit 1];
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        usr2.TimeZoneSidKey = 'Asia/Kolkata';
        update usr2;
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
        acct.TAM_Name_New__c = usr2.id;
        acct.Customer_Support_Segment__c='Top100';
        acct.Exclude_Partner_Support__c=true;
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        Service_Agent_Information__c sai = new Service_Agent_Information__c(user__c=usr2.id,daily_Quota__c = 1, weekly_quota__c = 5, backlog__c = 1);
        insert sai;
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='High (P2)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New',Business_Analyst__c=ur.Id,case_source__c = 'Integration',origin='Public Form',Preferred_Contact_Time_Zone__c='America/Sao_Paulo');
        Case cs2 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='High (P2)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New',Business_Analyst__c=ur.Id,case_source__c = 'Integration',origin='Public Form',Preferred_Contact_Time_Zone__c='');
        insert cs;
        insert cs2;
        List<Case> csList = [SELECT Id, IsDeleted, MasterRecordId, CaseNumber, ContactId, AccountId, EntitlementId, ParentId, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, RecordTypeId, Status, Reason, Origin, Language, IsVisibleInSelfService, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, HasCommentsUnreadByOwner, HasSelfServiceComments, OwnerId, SlaStartDate, SlaExitDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ContactPhone, ContactMobile, ContactEmail, ContactFax, Comments, LastViewedDate, LastReferencedDate, DefectID__c, Enhancement_Request_ID__c, Issue__c, Product__c, Account_Name__c, Case_URL__c, ZCO_Area__c, ZCO_Sub__c, Case_Source__c, SupportArea__c, Support_Level__c, IT_Category__c, Created_or_Closed_Date__c, Urgency__c, Customer_Impact__c, Level_Difficulty__c, Escalated__c, Org_ID_from_Webform__c, No_of_Employees_Users__c, Advanced_Support_End_Date__c, Operations_ID__c, Type__c, Resolution_Summary__c, Days_to_Close__c, Add_to_KB__c, Provisioning_Request__c, CC_Email_1__c, CC_Email_2__c, Escalated_To__c, Date_and_Time_of_First_Web_Ticket_Reply__c, test_formula__c, Submitted_By_Name__c, Case_Category__c, Case_Sub_Category__c, Lead__c, Date_Accepted__c, Case_No__c, Case_Creator__c, Opportunity_Name__c, Problem_Statement__c, Deal_Reg__c, User__c, Lead_Sales_Territory__c, Disable_Close_Notification__c, bizible2__Ad_Campaign_Name_FT__c, bizible2__Ad_Campaign_Name_LC__c, bizible2__Landing_Page_FT__c, bizible2__Landing_Page_LC__c, bizible2__Marketing_Channel_FT__c, bizible2__Marketing_Channel_LC__c, bizible2__Touchpoint_Date_FT__c, bizible2__Touchpoint_Date_LC__c, bizible2__Touchpoint_Source_FT__c, bizible2__Touchpoint_Source_LC__c, DOH__c, DOT__c, LeanData__Routing_Action__c, Account_Segment_Score__c, Account_of_Support_Case__c, Apply_Manual_SLA__c, Case_Age_Score__c, Case_Age__c, Case_CC_List__c, Case_Created_By_Email__c, Case_Owner_Assigned_Date__c, Case_Owner_Manager__c, Case_Owner__c, Case_Owner_s_Service_Level__c, Case_Priority_Score__c, Case_Status__c, Case_Type__c, Case_Vitals__c, Closed_By__c, Community_url__c, Contact_Name__c, Created_By_First_name__c, Created_By_Last_Name__c, Current_Stage_Age__c, Customer_Close_Request_Reason__c, Customer_Reopen_Reason__c, Customer_Score__c, Customer_Segment__c, Customer_Temperature__c, DEFCON_Score__c, Defcon_Level__c, Email_Case_Comment_Body__c, End_Customer_Account_Name__c, Escalated_By__c, Escalation_Age__c, Escalation_End_Time__c, Escalation_Owner__c, Escalation_Reason__c, Escalation_Resolution_Notes__c, Escalation_Resolved_By__c, Escalation_Stage__c, Escalation_Start_Time__c, Escalation_Support__c, Escalation_on_behalf_of_Customer__c, FRT_Violation_time__c, First_Response_Time_Violated__c, First_Response_Timestamp__c, First_Response_Violated_Time__c, HandOff_Cases__c, Internal_Ticket_Number__c, JIRA_Project_Name__c, JIRA_Project_Status__c, Jira_ID__c, Jira_Request_ID__c, Legacy_Area__c, Legacy_Prodcut__c, Manual_SLA_Timestamp__c, Master_Case__c, Median_Score__c, Owner_Service_Level__c, Partner_ID__c, Partner_Organization_Name__c, Preferred_Contact_Number__c, Preferred_Contact_Time_Zone__c, Primary_Support__c, Product_New__c, Push_comment_to_child_cases__c, Reason_for_Case_Re_Open__c, Requester__c, Requestor_s_Email__c, Resolution_Type__c, SRT_Violated_Time__c, Secondary_Support__c, Share_with_Customer__c, Software_Version__c, Status_Start_Date__c, Subsequent_Response_Breached__c, Subsequent_Response_violation_time__c, Subsequent_Target_Time__c, Escalation_Age_Days__c, Target_time__c, Total_ARR__c, of_Cases__c, of_Top_Customers__c, zscaler_org_id__c, Customer_Response_Time__c, Time_to_Resolution_TTR__c, Leagcy_type__c, Legacy_Sub_Area__c, Case_Escalation_Reason__c, Case_Record_Type_Name__c, Raise_for_BUG_Scrub__c, Survey__c, Legacy_Case_Comment_Text__c, Case_Owner_is_TAM__c, New_Legacy__c, Logged_in_User__c, Logged_in_User_Ownership__c, Is_TAM_Account__c, Number_of_comment__c, Number_of_TeamMember__c, Number_of_link__c, New_Legacy_2__c, Del_Me__c, Legacy_Case_Status__c, Legacy_Status__c, Legacy_Owner__c, Legacy_Requester__c, Legacy_Account__c, Legacy_Comments_Count__c, Zen2SFDC_Owner_Mismatch__c, Zen2SFDC_Case_Status_Mismatch__c, Zen2SFDC_Account_Mismatch__c, Zen2SFDC_Requester_Mismatch__c, Zen2SFDC_Comment_Mismatch__c, Customer_Mismatch_Data_breach_check__c, Zen2SFDC_Account_Substring_Mismatch__c, Contact_First_Name__c, Case_Age_Hours__c, Case_Owner_Manager_Name__c, Next_SLA_Breach__c, Case_Owner_Role__c, Case_Owner_Geo__c, Primary_TAM__c, Case_Opened_Hour__c, Case_Opened_Hour_Formatted__c, Prior_Owner__c, Queue_Priority__c, Case_Owner_is_TAM_New__c, Email_Body__c, Attachment_Id__c, Is_TAM_Account_Name__c, PR_Account_Name__c, PR_Oppty_Name__c, PR_org_domain__c, Primary_TAM_Email__c, Secondary_TAM_Email__c, X3rd_TAM_Email__c, Primary_TAM_Emailformula__c, Secondary_TAM_EmailFormula__c, X3_TAM_Email__c, Logged_in_User_Profile_id__c, Parent_Account_Name__c, Parent_Case_Number__c, Parent_Case_Owner__c, Customer_CC_List__c, Internal_CC_List__c, Will_you_recommend_Zscaler__c, How_can_we_make_you_happier__c, Easy_to_handle_issue__c, Rate_your_experience__c, How_was_the_Zscaler_portal_Experience__c, One_thing_we_could_do_to_make_it_easy__c, Your_Comments__c, Assignee_Manager__c, Survey_Case_Owner_Manager__c, Case__c, Sales_Engineer__c, Account_SE_id__c, Survey_CSAT_Score__c, Survey_CES_Score__c, Survey_NPS_Promoter_Count__c, Survey_NPS_Detractor_Count__c, Survey_Sent_Count__c, Survey_Filled_Count__c, Full_TTR__c, First_Day_Resolution_FDR__c, TTR_Excluding_Pending_fix_verification__c, TTR_Excluding_Pending_customer__c, Data_Access_Authorization_Provided__c, Case_Assign_to_Support_Queue__c, TTR__c, td_case_owner__c, td_case_url__c, td_primary_tam__c, td_priority__c, td_secondary_tam__c, td_skill_1__c, td_skill_2__c, td_skill_3__c, td_skill_4__c, td_skill_5__c, td_third_tam__c, Customer_Response_Time_Mins__c, Days_since_last_activity__c, Days_since_last_public_comment__c, Full_Community_URL__c, Original_Primary_TAM__c, Original_Secondary_TAM__c, Original_Third_TAM__c, Primary_TAM_Region__c, Secondary_TAM_Region__c, Third_TAM_Region__c, DSAT_Survey_Link__c, Project__c, is_Today_Weekend__c, Account_Extension__c, ImpartnerPRM__NotifyPartner__c, ImpartnerPRM__PartnerAccount__c, ImpartnerPRM__PartnerContact__c, ImpartnerPRM__PartnerLastModifiedDate__c, Escalation_Reason_New_n__c, Auto_Routing__c, Escalation_Reason_Internal__c, Escalation_Reason_New__c, Internal_Escalation__c, Original_Case_Assigned_Date_Time__c, Did_we_meet_your_project_timeline__c, Business_Analyst__c, Change_Request__c, Areas_to_Improve_Other_Comments__c, Areas_to_Improve__c, Rate_your_experience_Full__c, TAM_Meeting_Notes__c, Visible_in_Doc__c, Einstein_Case_Escalation_Probability__c, Previous_Product_Type__c, Previous_Zscaler_Org_Id__c, CSM_Email__c, Case_Owner_is_Sec_TAM__c, Case_Owner_is_3rd_TAM__c, Case_Owner_s_Skills__c, IsEscalated__c, Chili_Queue_Name__c, User_Signature__c, FRT_Minutes__c, DefCon_Active__c, DefCon_Total__c, External_Reference__c, Primary_TAM_Timezone__c, Sec_TAM_Timezone__c, Chili_Piper_Meeting_Status__c, Is_Current_Owner_TAM__c, Next_TAM_Date__c, No_of_TAM_Reassignment_Attempts__c, TAM_Assignment__c, TAM_Reassignment__c, Internal_Esc__c, X4th_TAM_Email__c, Sensitive_Account__c, LeanData__Status_Info__c, Exclude_Partner_Support__c, Duplicate_Of_Case__c, Current_Category__c, Final_Category__c, Suggested_Category__c, Request_Type__c, Owner_OOO__c, Owner_Returning_Date__c, Create_New_Knowledge_Article__c, Resolution_Details__c, Agent_Assist_Resolution_Notes__c, Case_TAM_Assignment__c FROM Case WHERE id=: cs.id OR id=:cs2.id];
        CaseTriggerUtility.assignCasesbySkill_TamRouting(csList);
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();
        
        CaseTriggerUtility.checkIfWeekend('Asia/Kolkata');
        Test.stopTest();
    }
    @IsTest
    static void tamRoutingCase_Test2(){
        Test.startTest();
        Timezone_Region_Mapping__c regionMap = new Timezone_Region_Mapping__c(name='Asia/Kolkata',Timezone__c='Asia/Kolkata',Region__c='APAC');
        insert regionMap;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Profile.name = 'System Administrator' and isActive = true limit 1];
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        usr2.TimeZoneSidKey = 'Asia/Kolkata';
        update usr2;
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account1';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.Secondary_TAM_Name__c = usr2.id;
        acct.Customer_Support_Segment__c='Top100';
        acct.Exclude_Partner_Support__c=false;
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        Service_Agent_Information__c sai = new Service_Agent_Information__c(user__c=usr2.id,daily_Quota__c = 1, weekly_quota__c = 5, backlog__c = 1);
        insert sai;
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='High (P2)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New',Business_Analyst__c=ur.Id,case_source__c = 'Integration',origin='Public Form',Preferred_Contact_Time_Zone__c='America/Sao_Paulo');
        Case cs2 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='High (P2)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New',Business_Analyst__c=ur.Id,case_source__c = 'Integration',origin='Public Form',Preferred_Contact_Time_Zone__c='');
        insert cs;
        insert cs2;
        List<Case> csList = [SELECT Id, IsDeleted, MasterRecordId, CaseNumber, ContactId, AccountId, EntitlementId, ParentId, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, RecordTypeId, Status, Reason, Origin, Language, IsVisibleInSelfService, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, HasCommentsUnreadByOwner, HasSelfServiceComments, OwnerId, SlaStartDate, SlaExitDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ContactPhone, ContactMobile, ContactEmail, ContactFax, Comments, LastViewedDate, LastReferencedDate, DefectID__c, Enhancement_Request_ID__c, Issue__c, Product__c, Account_Name__c, Case_URL__c, ZCO_Area__c, ZCO_Sub__c, Case_Source__c, SupportArea__c, Support_Level__c, IT_Category__c, Created_or_Closed_Date__c, Urgency__c, Customer_Impact__c, Level_Difficulty__c, Escalated__c, Org_ID_from_Webform__c, No_of_Employees_Users__c, Advanced_Support_End_Date__c, Operations_ID__c, Type__c, Resolution_Summary__c, Days_to_Close__c, Add_to_KB__c, Provisioning_Request__c, CC_Email_1__c, CC_Email_2__c, Escalated_To__c, Date_and_Time_of_First_Web_Ticket_Reply__c, test_formula__c, Submitted_By_Name__c, Case_Category__c, Case_Sub_Category__c, Lead__c, Date_Accepted__c, Case_No__c, Case_Creator__c, Opportunity_Name__c, Problem_Statement__c, Deal_Reg__c, User__c, Lead_Sales_Territory__c, Disable_Close_Notification__c, bizible2__Ad_Campaign_Name_FT__c, bizible2__Ad_Campaign_Name_LC__c, bizible2__Landing_Page_FT__c, bizible2__Landing_Page_LC__c, bizible2__Marketing_Channel_FT__c, bizible2__Marketing_Channel_LC__c, bizible2__Touchpoint_Date_FT__c, bizible2__Touchpoint_Date_LC__c, bizible2__Touchpoint_Source_FT__c, bizible2__Touchpoint_Source_LC__c, DOH__c, DOT__c, LeanData__Routing_Action__c, Account_Segment_Score__c, Account_of_Support_Case__c, Apply_Manual_SLA__c, Case_Age_Score__c, Case_Age__c, Case_CC_List__c, Case_Created_By_Email__c, Case_Owner_Assigned_Date__c, Case_Owner_Manager__c, Case_Owner__c, Case_Owner_s_Service_Level__c, Case_Priority_Score__c, Case_Status__c, Case_Type__c, Case_Vitals__c, Closed_By__c, Community_url__c, Contact_Name__c, Created_By_First_name__c, Created_By_Last_Name__c, Current_Stage_Age__c, Customer_Close_Request_Reason__c, Customer_Reopen_Reason__c, Customer_Score__c, Customer_Segment__c, Customer_Temperature__c, DEFCON_Score__c, Defcon_Level__c, Email_Case_Comment_Body__c, End_Customer_Account_Name__c, Escalated_By__c, Escalation_Age__c, Escalation_End_Time__c, Escalation_Owner__c, Escalation_Reason__c, Escalation_Resolution_Notes__c, Escalation_Resolved_By__c, Escalation_Stage__c, Escalation_Start_Time__c, Escalation_Support__c, Escalation_on_behalf_of_Customer__c, FRT_Violation_time__c, First_Response_Time_Violated__c, First_Response_Timestamp__c, First_Response_Violated_Time__c, HandOff_Cases__c, Internal_Ticket_Number__c, JIRA_Project_Name__c, JIRA_Project_Status__c, Jira_ID__c, Jira_Request_ID__c, Legacy_Area__c, Legacy_Prodcut__c, Manual_SLA_Timestamp__c, Master_Case__c, Median_Score__c, Owner_Service_Level__c, Partner_ID__c, Partner_Organization_Name__c, Preferred_Contact_Number__c, Preferred_Contact_Time_Zone__c, Primary_Support__c, Product_New__c, Push_comment_to_child_cases__c, Reason_for_Case_Re_Open__c, Requester__c, Requestor_s_Email__c, Resolution_Type__c, SRT_Violated_Time__c, Secondary_Support__c, Share_with_Customer__c, Software_Version__c, Status_Start_Date__c, Subsequent_Response_Breached__c, Subsequent_Response_violation_time__c, Subsequent_Target_Time__c, Escalation_Age_Days__c, Target_time__c, Total_ARR__c, of_Cases__c, of_Top_Customers__c, zscaler_org_id__c, Customer_Response_Time__c, Time_to_Resolution_TTR__c, Leagcy_type__c, Legacy_Sub_Area__c, Case_Escalation_Reason__c, Case_Record_Type_Name__c, Raise_for_BUG_Scrub__c, Survey__c, Legacy_Case_Comment_Text__c, Case_Owner_is_TAM__c, New_Legacy__c, Logged_in_User__c, Logged_in_User_Ownership__c, Is_TAM_Account__c, Number_of_comment__c, Number_of_TeamMember__c, Number_of_link__c, New_Legacy_2__c, Del_Me__c, Legacy_Case_Status__c, Legacy_Status__c, Legacy_Owner__c, Legacy_Requester__c, Legacy_Account__c, Legacy_Comments_Count__c, Zen2SFDC_Owner_Mismatch__c, Zen2SFDC_Case_Status_Mismatch__c, Zen2SFDC_Account_Mismatch__c, Zen2SFDC_Requester_Mismatch__c, Zen2SFDC_Comment_Mismatch__c, Customer_Mismatch_Data_breach_check__c, Zen2SFDC_Account_Substring_Mismatch__c, Contact_First_Name__c, Case_Age_Hours__c, Case_Owner_Manager_Name__c, Next_SLA_Breach__c, Case_Owner_Role__c, Case_Owner_Geo__c, Primary_TAM__c, Case_Opened_Hour__c, Case_Opened_Hour_Formatted__c, Prior_Owner__c, Queue_Priority__c, Case_Owner_is_TAM_New__c, Email_Body__c, Attachment_Id__c, Is_TAM_Account_Name__c, PR_Account_Name__c, PR_Oppty_Name__c, PR_org_domain__c, Primary_TAM_Email__c, Secondary_TAM_Email__c, X3rd_TAM_Email__c, Primary_TAM_Emailformula__c, Secondary_TAM_EmailFormula__c, X3_TAM_Email__c, Logged_in_User_Profile_id__c, Parent_Account_Name__c, Parent_Case_Number__c, Parent_Case_Owner__c, Customer_CC_List__c, Internal_CC_List__c, Will_you_recommend_Zscaler__c, How_can_we_make_you_happier__c, Easy_to_handle_issue__c, Rate_your_experience__c, How_was_the_Zscaler_portal_Experience__c, One_thing_we_could_do_to_make_it_easy__c, Your_Comments__c, Assignee_Manager__c, Survey_Case_Owner_Manager__c, Case__c, Sales_Engineer__c, Account_SE_id__c, Survey_CSAT_Score__c, Survey_CES_Score__c, Survey_NPS_Promoter_Count__c, Survey_NPS_Detractor_Count__c, Survey_Sent_Count__c, Survey_Filled_Count__c, Full_TTR__c, First_Day_Resolution_FDR__c, TTR_Excluding_Pending_fix_verification__c, TTR_Excluding_Pending_customer__c, Data_Access_Authorization_Provided__c, Case_Assign_to_Support_Queue__c, TTR__c, td_case_owner__c, td_case_url__c, td_primary_tam__c, td_priority__c, td_secondary_tam__c, td_skill_1__c, td_skill_2__c, td_skill_3__c, td_skill_4__c, td_skill_5__c, td_third_tam__c, Customer_Response_Time_Mins__c, Days_since_last_activity__c, Days_since_last_public_comment__c, Full_Community_URL__c, Original_Primary_TAM__c, Original_Secondary_TAM__c, Original_Third_TAM__c, Primary_TAM_Region__c, Secondary_TAM_Region__c, Third_TAM_Region__c, DSAT_Survey_Link__c, Project__c, is_Today_Weekend__c, Account_Extension__c, ImpartnerPRM__NotifyPartner__c, ImpartnerPRM__PartnerAccount__c, ImpartnerPRM__PartnerContact__c, ImpartnerPRM__PartnerLastModifiedDate__c, Escalation_Reason_New_n__c, Auto_Routing__c, Escalation_Reason_Internal__c, Escalation_Reason_New__c, Internal_Escalation__c, Original_Case_Assigned_Date_Time__c, Did_we_meet_your_project_timeline__c, Business_Analyst__c, Change_Request__c, Areas_to_Improve_Other_Comments__c, Areas_to_Improve__c, Rate_your_experience_Full__c, TAM_Meeting_Notes__c, Visible_in_Doc__c, Einstein_Case_Escalation_Probability__c, Previous_Product_Type__c, Previous_Zscaler_Org_Id__c, CSM_Email__c, Case_Owner_is_Sec_TAM__c, Case_Owner_is_3rd_TAM__c, Case_Owner_s_Skills__c, IsEscalated__c, Chili_Queue_Name__c, User_Signature__c, FRT_Minutes__c, DefCon_Active__c, DefCon_Total__c, External_Reference__c, Primary_TAM_Timezone__c, Sec_TAM_Timezone__c, Chili_Piper_Meeting_Status__c, Is_Current_Owner_TAM__c, Next_TAM_Date__c, No_of_TAM_Reassignment_Attempts__c, TAM_Assignment__c, TAM_Reassignment__c, Internal_Esc__c, X4th_TAM_Email__c, Sensitive_Account__c, LeanData__Status_Info__c, Exclude_Partner_Support__c, Duplicate_Of_Case__c, Current_Category__c, Final_Category__c, Suggested_Category__c, Request_Type__c, Owner_OOO__c, Owner_Returning_Date__c, Create_New_Knowledge_Article__c, Resolution_Details__c, Agent_Assist_Resolution_Notes__c, Case_TAM_Assignment__c FROM Case WHERE id=: cs.id OR id=:cs2.id];
        CaseTriggerUtility.assignCasesbySkill_TamRouting(csList);
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();
        
        CaseTriggerUtility.checkIfWeekend('America/Sao_Paulo');
        Test.stopTest();
    }
    @IsTest
    static void tamRoutingCase_Test3(){
       
        Timezone_Region_Mapping__c regionMap = new Timezone_Region_Mapping__c(name='Asia/Kolkata',Timezone__c='Asia/Kolkata',Region__c='APAC');
        insert regionMap;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Profile.name = 'System Administrator' and isActive = true limit 1];
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        usr2.TimeZoneSidKey = 'Asia/Kolkata';
        update usr2;
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = usr2.id;
        acct.Customer_Support_Segment__c='Gold';
        acct.Exclude_Partner_Support__c=false;
        TriggerHandler.bypass('AccountTriggerHandler');
        insert acct;
        Service_Agent_Information__c sai = new Service_Agent_Information__c(user__c=usr2.id,daily_Quota__c = 1, weekly_quota__c = 5, backlog__c = 1);
        insert sai;
        //Anup New ES code - Start
        Engineer_Schedule__c es = new Engineer_Schedule__c(Service_Agent_Information__c = sai.Id, Priority__c='P1-P4');
        insert es;
        //Anup New ES code - End
        Test.startTest();
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='High (P2)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New',Business_Analyst__c=ur.Id,case_source__c = 'Integration',origin='Public Form',Preferred_Contact_Time_Zone__c='America/Sao_Paulo');
        Case cs2 = new Case(Subject='abcd', AccountId =  acct.Id, Priority='High (P2)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New',Business_Analyst__c=ur.Id,case_source__c = 'Integration',origin='Public Form',Preferred_Contact_Time_Zone__c='');
        insert cs;
        insert cs2;
        List<Case> csList = [SELECT Id, IsDeleted, MasterRecordId, CaseNumber, ContactId, AccountId, EntitlementId, ParentId, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, RecordTypeId, Status, Reason, Origin, Language, IsVisibleInSelfService, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, HasCommentsUnreadByOwner, HasSelfServiceComments, OwnerId, SlaStartDate, SlaExitDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ContactPhone, ContactMobile, ContactEmail, ContactFax, Comments, LastViewedDate, LastReferencedDate, DefectID__c, Enhancement_Request_ID__c, Issue__c, Product__c, Account_Name__c, Case_URL__c, ZCO_Area__c, ZCO_Sub__c, Case_Source__c, SupportArea__c, Support_Level__c, IT_Category__c, Created_or_Closed_Date__c, Urgency__c, Customer_Impact__c, Level_Difficulty__c, Escalated__c, Org_ID_from_Webform__c, No_of_Employees_Users__c, Advanced_Support_End_Date__c, Operations_ID__c, Type__c, Resolution_Summary__c, Days_to_Close__c, Add_to_KB__c, Provisioning_Request__c, CC_Email_1__c, CC_Email_2__c, Escalated_To__c, Date_and_Time_of_First_Web_Ticket_Reply__c, test_formula__c, Submitted_By_Name__c, Case_Category__c, Case_Sub_Category__c, Lead__c, Date_Accepted__c, Case_No__c, Case_Creator__c, Opportunity_Name__c, Problem_Statement__c, Deal_Reg__c, User__c, Lead_Sales_Territory__c, Disable_Close_Notification__c, bizible2__Ad_Campaign_Name_FT__c, bizible2__Ad_Campaign_Name_LC__c, bizible2__Landing_Page_FT__c, bizible2__Landing_Page_LC__c, bizible2__Marketing_Channel_FT__c, bizible2__Marketing_Channel_LC__c, bizible2__Touchpoint_Date_FT__c, bizible2__Touchpoint_Date_LC__c, bizible2__Touchpoint_Source_FT__c, bizible2__Touchpoint_Source_LC__c, DOH__c, DOT__c, LeanData__Routing_Action__c, Account_Segment_Score__c, Account_of_Support_Case__c, Apply_Manual_SLA__c, Case_Age_Score__c, Case_Age__c, Case_CC_List__c, Case_Created_By_Email__c, Case_Owner_Assigned_Date__c, Case_Owner_Manager__c, Case_Owner__c, Case_Owner_s_Service_Level__c, Case_Priority_Score__c, Case_Status__c, Case_Type__c, Case_Vitals__c, Closed_By__c, Community_url__c, Contact_Name__c, Created_By_First_name__c, Created_By_Last_Name__c, Current_Stage_Age__c, Customer_Close_Request_Reason__c, Customer_Reopen_Reason__c, Customer_Score__c, Customer_Segment__c, Customer_Temperature__c, DEFCON_Score__c, Defcon_Level__c, Email_Case_Comment_Body__c, End_Customer_Account_Name__c, Escalated_By__c, Escalation_Age__c, Escalation_End_Time__c, Escalation_Owner__c, Escalation_Reason__c, Escalation_Resolution_Notes__c, Escalation_Resolved_By__c, Escalation_Stage__c, Escalation_Start_Time__c, Escalation_Support__c, Escalation_on_behalf_of_Customer__c, FRT_Violation_time__c, First_Response_Time_Violated__c, First_Response_Timestamp__c, First_Response_Violated_Time__c, HandOff_Cases__c, Internal_Ticket_Number__c, JIRA_Project_Name__c, JIRA_Project_Status__c, Jira_ID__c, Jira_Request_ID__c, Legacy_Area__c, Legacy_Prodcut__c, Manual_SLA_Timestamp__c, Master_Case__c, Median_Score__c, Owner_Service_Level__c, Partner_ID__c, Partner_Organization_Name__c, Preferred_Contact_Number__c, Preferred_Contact_Time_Zone__c, Primary_Support__c, Product_New__c, Push_comment_to_child_cases__c, Reason_for_Case_Re_Open__c, Requester__c, Requestor_s_Email__c, Resolution_Type__c, SRT_Violated_Time__c, Secondary_Support__c, Share_with_Customer__c, Software_Version__c, Status_Start_Date__c, Subsequent_Response_Breached__c, Subsequent_Response_violation_time__c, Subsequent_Target_Time__c, Escalation_Age_Days__c, Target_time__c, Total_ARR__c, of_Cases__c, of_Top_Customers__c, zscaler_org_id__c, Customer_Response_Time__c, Time_to_Resolution_TTR__c, Leagcy_type__c, Legacy_Sub_Area__c, Case_Escalation_Reason__c, Case_Record_Type_Name__c, Raise_for_BUG_Scrub__c, Survey__c, Legacy_Case_Comment_Text__c, Case_Owner_is_TAM__c, New_Legacy__c, Logged_in_User__c, Logged_in_User_Ownership__c, Is_TAM_Account__c, Number_of_comment__c, Number_of_TeamMember__c, Number_of_link__c, New_Legacy_2__c, Del_Me__c, Legacy_Case_Status__c, Legacy_Status__c, Legacy_Owner__c, Legacy_Requester__c, Legacy_Account__c, Legacy_Comments_Count__c, Zen2SFDC_Owner_Mismatch__c, Zen2SFDC_Case_Status_Mismatch__c, Zen2SFDC_Account_Mismatch__c, Zen2SFDC_Requester_Mismatch__c, Zen2SFDC_Comment_Mismatch__c, Customer_Mismatch_Data_breach_check__c, Zen2SFDC_Account_Substring_Mismatch__c, Contact_First_Name__c, Case_Age_Hours__c, Case_Owner_Manager_Name__c, Next_SLA_Breach__c, Case_Owner_Role__c, Case_Owner_Geo__c, Primary_TAM__c, Case_Opened_Hour__c, Case_Opened_Hour_Formatted__c, Prior_Owner__c, Queue_Priority__c, Case_Owner_is_TAM_New__c, Email_Body__c, Attachment_Id__c, Is_TAM_Account_Name__c, PR_Account_Name__c, PR_Oppty_Name__c, PR_org_domain__c, Primary_TAM_Email__c, Secondary_TAM_Email__c, X3rd_TAM_Email__c, Primary_TAM_Emailformula__c, Secondary_TAM_EmailFormula__c, X3_TAM_Email__c, Logged_in_User_Profile_id__c, Parent_Account_Name__c, Parent_Case_Number__c, Parent_Case_Owner__c, Customer_CC_List__c, Internal_CC_List__c, Will_you_recommend_Zscaler__c, How_can_we_make_you_happier__c, Easy_to_handle_issue__c, Rate_your_experience__c, How_was_the_Zscaler_portal_Experience__c, One_thing_we_could_do_to_make_it_easy__c, Your_Comments__c, Assignee_Manager__c, Survey_Case_Owner_Manager__c, Case__c, Sales_Engineer__c, Account_SE_id__c, Survey_CSAT_Score__c, Survey_CES_Score__c, Survey_NPS_Promoter_Count__c, Survey_NPS_Detractor_Count__c, Survey_Sent_Count__c, Survey_Filled_Count__c, Full_TTR__c, First_Day_Resolution_FDR__c, TTR_Excluding_Pending_fix_verification__c, TTR_Excluding_Pending_customer__c, Data_Access_Authorization_Provided__c, Case_Assign_to_Support_Queue__c, TTR__c, td_case_owner__c, td_case_url__c, td_primary_tam__c, td_priority__c, td_secondary_tam__c, td_skill_1__c, td_skill_2__c, td_skill_3__c, td_skill_4__c, td_skill_5__c, td_third_tam__c, Customer_Response_Time_Mins__c, Days_since_last_activity__c, Days_since_last_public_comment__c, Full_Community_URL__c, Original_Primary_TAM__c, Original_Secondary_TAM__c, Original_Third_TAM__c, Primary_TAM_Region__c, Secondary_TAM_Region__c, Third_TAM_Region__c, DSAT_Survey_Link__c, Project__c, is_Today_Weekend__c, Account_Extension__c, ImpartnerPRM__NotifyPartner__c, ImpartnerPRM__PartnerAccount__c, ImpartnerPRM__PartnerContact__c, ImpartnerPRM__PartnerLastModifiedDate__c, Escalation_Reason_New_n__c, Auto_Routing__c, Escalation_Reason_Internal__c, Escalation_Reason_New__c, Internal_Escalation__c, Original_Case_Assigned_Date_Time__c, Did_we_meet_your_project_timeline__c, Business_Analyst__c, Change_Request__c, Areas_to_Improve_Other_Comments__c, Areas_to_Improve__c, Rate_your_experience_Full__c, TAM_Meeting_Notes__c, Visible_in_Doc__c, Einstein_Case_Escalation_Probability__c, Previous_Product_Type__c, Previous_Zscaler_Org_Id__c, CSM_Email__c, Case_Owner_is_Sec_TAM__c, Case_Owner_is_3rd_TAM__c, Case_Owner_s_Skills__c, IsEscalated__c, Chili_Queue_Name__c, User_Signature__c, FRT_Minutes__c, DefCon_Active__c, DefCon_Total__c, External_Reference__c, Primary_TAM_Timezone__c, Sec_TAM_Timezone__c, Chili_Piper_Meeting_Status__c, Is_Current_Owner_TAM__c, Next_TAM_Date__c, No_of_TAM_Reassignment_Attempts__c, TAM_Assignment__c, TAM_Reassignment__c, Internal_Esc__c, X4th_TAM_Email__c, Sensitive_Account__c, LeanData__Status_Info__c, Exclude_Partner_Support__c, Duplicate_Of_Case__c, Current_Category__c, Final_Category__c, Suggested_Category__c, Request_Type__c, Owner_OOO__c, Owner_Returning_Date__c, Create_New_Knowledge_Article__c, Resolution_Details__c, Agent_Assist_Resolution_Notes__c, Case_TAM_Assignment__c FROM Case WHERE id=: cs.id OR id=:cs2.id];
        CaseTriggerUtility.assignCasesbySkill_TamRouting(csList);
        CaseTriggerUtility.updateDailyQuota(csList, null);
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();
        cs2.Priority= 'Urgent (P1)';
        cs2.Warm_Handoff__c = true;
        cs2.Product_New__c = 'ZIA';
        cs2.Status = 'Customer Note Added';
        cs2.OwnerId = usr2.Id;
        update cs2;
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();
        cs.Warm_Handoff__c = true;
        cs.Product_New__c = 'ZPA';
        cs.Case_Type__c = 'Provisioning';
        cs.SLA_Breached_Threshold__c = true;
        update cs;
        
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseAfterUpdateReset();                    
        CaseTriggerUtility.checkIfWeekend('America/Sao_Paulo');
        Map<Id, Case> mapOfCaseAndDetails = new Map<Id, Case>();
        mapOfCaseAndDetails.put(cs2.Id, cs2);
        CaseTriggerUtility.sendReassignmentThresholdEmail(mapOfCaseAndDetails);
        Test.stopTest();
    }
    @IsTest
    static void addDefaultProductSFDCSupportCase_Test(){ 
        Id sfdcSupportCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        Test.startTest();
        Case cs = new Case(Subject='abcd', Priority='Low (P4)', RecordTypeId=sfdcSupportCaseRT, Status = 'New',origin='Email');
        insert cs;
        Test.stopTest();
    }
    @IsTest
    static void updateNOCSubject_Test(){ 
        Id sfdcSupportCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Test.startTest();
        Case cs = new Case(Subject='abcd', Priority='Low (P4)', RecordTypeId=sfdcSupportCaseRT, Status = 'New',origin='Email',Case_Created_By_Email__c='znocalerts@zscaler.com');
        insert cs;
        Test.stopTest();
    }

    @IsTest
    static void test_defconCurrentStatusUpdate() {
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Entitlement entitle = new Entitlement();
        entitle.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        entitle.AccountId = [SELECT id FROM Account].Id;        
        entitle.StartDate=date.today();   
        entitle.SlaProcessId =[SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name='Defcon Escalations Entitlement Process' Order by LastModifiedDate desc LIMIT 1].Id;

        Insert entitle;
        Case csSupport = [SELECT id,CaseNumber FROM Case WHERE RecordType.Name = 'Support' LIMIT 1];
        //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = csSupport.Id;
        csEsc.EntitlementId = entitle.Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.Escalation_Level__c = 'Level 0';
        csEsc.RecordTypeId = escalationRecordTypeId;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        csEsc.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
        Insert csEsc;   
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        Test.startTest();
        csEsc.ownerId = UserInfo.getUserId();
        csEsc.Current_Status_Next_Plan_Of_Action__c = 'Test-Updated';
        update csEsc;
        Test.stopTest();
    }

    @IsTest
    static void test_defconReescalate() {
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Entitlement entitle = new Entitlement();
        entitle.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        entitle.AccountId = [SELECT id FROM Account].Id;        
        entitle.StartDate=date.today();   
        entitle.SlaProcessId =[SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name='Defcon Escalations Entitlement Process' Order by LastModifiedDate desc LIMIT 1].Id;     
        Insert entitle;
        Case csSupport = [SELECT id,CaseNumber FROM Case WHERE RecordType.Name = 'Support' LIMIT 1];
        //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = csSupport.Id;
        csEsc.EntitlementId = entitle.Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.Escalation_Level__c = 'Level 0';
        csEsc.RecordTypeId = escalationRecordTypeId;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        csEsc.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
        Insert csEsc;   
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        Test.startTest();
        csEsc.Defcon_Level__c = '2';
        update csEsc;
        Test.stopTest();
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        Map<String, Case> caseMap = new Map<String, Case>();
        caseMap.put(csEsc.Id, csEsc);
        CaseTriggerUtility.completeAutoEscDefconMilestones(caseMap);
    }


    @IsTest
    static void test_DefconParentClosure() {
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Entitlement entitle = new Entitlement();
        entitle.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        entitle.AccountId = [SELECT id FROM Account].Id;        
        entitle.StartDate=date.today(); 
        entitle.SlaProcessId =[SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name='Defcon Escalations Entitlement Process' Order by LastModifiedDate desc LIMIT 1].Id;
        Insert entitle;
        Case csSupport = [SELECT id,CaseNumber,status FROM Case WHERE RecordType.Name = 'Support' LIMIT 1];
        //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = csSupport.Id;
        csEsc.EntitlementId = entitle.Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.Escalation_Level__c = 'Level 0';
        csEsc.Root_Cause_for_DEFCON__c = 'Unavoidable';
        csEsc.RecordTypeId = escalationRecordTypeId;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        csEsc.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
        Insert csEsc;   
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        Test.startTest();
        csSupport.status = 'Closed';
        update csSupport;
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        csSupport.status = 'New';
        update csSupport;
        Test.stopTest();
    }

    @IsTest
    static void test_Level0AutoEsc() {
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Entitlement entitle = new Entitlement();
        entitle.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        entitle.AccountId = [SELECT id FROM Account].Id;        
        entitle.StartDate=date.today(); 
        entitle.SlaProcessId =[SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name='Defcon Escalations Entitlement Process' Order by LastModifiedDate desc LIMIT 1].Id;
        Insert entitle;
        Case csSupport = [SELECT id,CaseNumber,status FROM Case WHERE RecordType.Name = 'Support' LIMIT 1];
        //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = csSupport.Id;
        csEsc.EntitlementId = entitle.Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.Escalation_Level__c = 'Level 0';
        csEsc.Root_Cause_for_DEFCON__c = 'Unavoidable';
        csEsc.RecordTypeId = escalationRecordTypeId;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        csEsc.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
        Insert csEsc;   
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        Test.startTest();
        csEsc.Response_SLA_Violated__c = true;
        csEsc.Follow_Up_SLA_Violated__c = true;
        csEsc.Escalation_Level__c = 'Level 1';
        csEsc.Auto_Esc_SLA_Violated__c = 'Level 0';
        csEsc.Current_Status_Next_Plan_Of_Action__c = 'Current Status:test\n Next Plan Of Action:test\n Exec Summary:test\n Next Steps:test \n Last Update:'+DateTime.now();
        update csEsc;
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        Map<String, Case> caseMap = new Map<String, Case>();
        caseMap.put(csEsc.Id, csEsc);
        CaseTriggerUtility.completeAutoEscDefconMilestones(caseMap);
    }

    @IsTest
    static void test_Level1AutoEsc() {
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Entitlement entitle = new Entitlement();
        entitle.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        entitle.AccountId = [SELECT id FROM Account].Id;        
        entitle.StartDate=date.today(); 
        entitle.SlaProcessId =[SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name='Defcon Escalations Entitlement Process' Order by LastModifiedDate desc LIMIT 1].Id;
        Insert entitle;
        Case csSupport = [SELECT id,CaseNumber,status FROM Case WHERE RecordType.Name = 'Support' LIMIT 1];
        //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = csSupport.Id;
        csEsc.EntitlementId = entitle.Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.Escalation_Level__c = 'Level 1';
        csEsc.Auto_Esc_SLA_Violated__c = 'Level 0';
        csEsc.Defcon_Automation_Reason__c = 'Auto Esc Lev 0 Violated';
        csEsc.Root_Cause_for_DEFCON__c = 'Unavoidable';
        csEsc.RecordTypeId = escalationRecordTypeId;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        csEsc.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
        Insert csEsc;   
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        Test.startTest();
        csEsc.Escalation_Level__c = 'Level 2';
        csEsc.Auto_Esc_SLA_Violated__c = 'Level 1';
        update csEsc;
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        Map<String, Case> caseMap = new Map<String, Case>();
        caseMap.put(csEsc.Id, csEsc);
        CaseTriggerUtility.completeAutoEscDefconMilestones(caseMap);
    }

    @IsTest
    static void test_Level2AutoEsc() {
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Entitlement entitle = new Entitlement();
        entitle.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        entitle.AccountId = [SELECT id FROM Account].Id;        
        entitle.StartDate=date.today(); 
        entitle.SlaProcessId =[SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name='Defcon Escalations Entitlement Process' Order by LastModifiedDate desc LIMIT 1].Id;
        Insert entitle;
        Case csSupport = [SELECT id,CaseNumber,status FROM Case WHERE RecordType.Name = 'Support' LIMIT 1];
        //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation Defcon';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = csSupport.Id;
        csEsc.EntitlementId = entitle.Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.Escalation_Level__c = 'Level 2';
        csEsc.Auto_Esc_SLA_Violated__c = 'Level 1';
        csEsc.Defcon_Automation_Reason__c = 'Auto Esc Lev 0 Violated;Auto Esc Lev 1 Violated';
        csEsc.Root_Cause_for_DEFCON__c = 'Unavoidable';
        csEsc.RecordTypeId = escalationRecordTypeId;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        csEsc.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
        Insert csEsc;   
        TriggerUtility.CaseBeforeUpdateReset();
        TriggerUtility.CaseBeforeInsertReset();
        TriggerUtility.CaseAfterInsertReset();
        TriggerUtility.CaseAfterUpdateReset();
        Test.startTest();
        csEsc.Escalation_Level__c = 'Level 2';
        csEsc.Auto_Esc_SLA_Violated__c = 'Level 2';
        update csEsc;
    }

    @IsTest
    static void test_updateParentFieldsonDefcon() {
        Test.StartTest();
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Case csSupport = [SELECT id,CaseNumber,status,Product_New__c FROM Case WHERE RecordType.Name = 'Support' LIMIT 1];
         //Escalation Case
         Case csEsc = new Case();
         csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
         csEsc.Case_Escalated_per_Defcon_Process__c = true;
         csEsc.Status = 'New';
         csEsc.Escalation_Reason__c = 'Test Escalation Defcon';
         csEsc.Escalation_Category__c = 'Unsatisfied with current support';
         csEsc.ParentId = csSupport.Id;         
         csEsc.Escalated_By__c = UserInfo.getUserId();
         csEsc.Defcon_Level__c = '4';
         csEsc.Escalation_Level__c = 'Level 2';
         csEsc.Auto_Esc_SLA_Violated__c = 'Level 1';
         csEsc.Defcon_Automation_Reason__c = 'Auto Esc Lev 0 Violated;Auto Esc Lev 1 Violated';
         csEsc.Root_Cause_for_DEFCON__c = 'Unavoidable';
         csEsc.RecordTypeId = escalationRecordTypeId;
         csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
         csEsc.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
         Insert csEsc;   

         csSupport.Product_New__c = 'ZPA';
         update csSupport;
        Test.StopTest();
    }
        
}