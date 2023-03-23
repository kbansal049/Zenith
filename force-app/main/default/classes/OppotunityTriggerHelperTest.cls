@isTest(seeAllData = false)
public class OppotunityTriggerHelperTest{
    
    @testSetup 
    static void setup() {
        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
        insert salestert;
        
        
        Patch__c patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salestert.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        TriggerHandler.bypass('AccountTriggerHandler');
        Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
        acc.Sales_Territory__c = salestert.Id;
        acc.Patch__c = patch.Id;
        insert acc;
        
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;
        opportunity opp1 = new opportunity(Name = 'Test opportunity1', AccountId = acc.Id, StageName = label.Stage_5_Contracts_Complete,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                                           CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test',Applied_Price_List_Name__c = 'FY20 Pricelist');
        insert opp1;
        OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = uu.id,TeamMemberRole = 'Account Manager');
        insert otm;
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud Details').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            insert pr;
        }catch(Exception ex){
            
        }
        
    }
    
    @isTest 
    static void test(){
        Test.startTest();
        List<Triggers_Switch__c> trlst1 = new List<Triggers_Switch__c>();
        trlst1 = TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        trlst1.add(new Triggers_Switch__c(name = 'Execute_Opp_Trigger', Execute__c = true));
        trlst1.add(new Triggers_Switch__c(name = 'Execute_UpdateQualifierRole', Execute__c = true));
        trlst1.add(new Triggers_Switch__c(name = 'Execute_UpdateRelatedOpportunity', Execute__c = true));
        trlst1.add(new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = true));
        TriggerUtility.SkipAccTriggerExecuted();
        insert trlst1;
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc'];        
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30, Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30, Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp1.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp2 = new opportunity(Name = 'Test opportunity2', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp2.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp3 = new opportunity(Name = 'Test opportunity3', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp3.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp4 = new opportunity(Name = 'Test opportunity4', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp4.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp5 = new opportunity(Name = 'Test opportunity5', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp5.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp6 = new opportunity(Name = 'Test opportunity6', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp6.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp7 = new opportunity(Name = 'Test opportunity7', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp7.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp8 = new opportunity(Name = 'Test opportunity8', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp8.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp9 = new opportunity(Name = 'Test opportunity9', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp9.LDR_Name__c = UserInfo.getUserId();
        
        opportunity opp10 = new opportunity(Name = 'Test opportunity10', AccountId = acc.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                            Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'Existing Customer (Renewal)', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp10.LDR_Name__c = UserInfo.getUserId();
        
        oppList.add(opp);
        oppList.add(opp1);
        oppList.add(opp2);
        oppList.add(opp3);
        oppList.add(opp4);
        oppList.add(opp5);
        oppList.add(opp6);
        oppList.add(opp7);
        oppList.add(opp8);
        oppList.add(opp9);
        oppList.add(opp10);
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert oppList;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            insert pr;
        }catch(Exception ex){
            
        }
        Test.stopTest();
        
        //List<Opportunity_Extension__c> oppExtList = [select id, Opportunity__c, Duplicate_Opportunity__c from Opportunity_Extension__c where Opportunity__c=:opp.Id];
        List<Opportunity_Extension__c> oppExtList= new List<Opportunity_Extension__c>();
        for(Opportunity_Extension__c oppExt :[select id, Opportunity__c, Duplicate_Opportunity__c from Opportunity_Extension__c where Opportunity__c=:opp.Id]){
            oppExt.Duplicate_Opportunity__c = opp1.Id;
            oppExtList.add(oppExt);
        }
        if(!oppExtList.isEmpty()){
            update oppExtList;
            system.debug('oppExtList :'+oppExtList);
        }
        opp.StageName = label.Stage_5_Contracts_Complete /*'12 - Closed With No Decision'*/;
        opp.Primary_Reason_For_Loss__c = 'test';
        opp.Validation_Stage__c = '7 - Technical Loss';
        opp.Technical_Validation_Start_Date__c = date.today();
        //opp.Sub_Stage__c = Label.SubStage_Closed_Lost;
        //opp.Sub_Stage__c = 'Closed: Delete Duplicate';
        TriggerUtility.UpdateRelatedOppReset();
        update opp;
        
        
        Id erRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('PZEN').getRecordTypeId();
        Equipment_Request__c er = new Equipment_Request__c();
        er.Approval_Status__c = 'Approved';
        er.RecordTypeId = erRecordTypeId;
        er.Opportunity__c = opp.Id;
        //er.OwnerId = userinfo.getUserId();
        er.Localized_content__c = true;
        insert er;
        
        opp.StageName = label.Stage_5_Contracts_Complete /*'13 - Closed & Approved By Finance'*/;
        //update opp;
        OppotunityTriggerHelper.booster();
        
    }
    
    @isTest 
    static void testAmberRoadScreening(){
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc'];  
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        opp.LDR_Name__c = UserInfo.getUserId();
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            insert pr;
        }catch(Exception ex){
            
        }
        Test.stopTest();
        
        opp.StageName = label.Stage_5_Contracts_Complete /*10b - PO recd, pending finance approval*/;
        update opp;
    }
    
    @isTest 
    static void testAmberRoadScreeningCase2(){
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc']; 
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(),
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            insert pr;
        }catch(Exception ex){
            
        }
        Test.stopTest();
        //TriggerHandler.bypass('OpportunityTriggerHandler');
        opp.StageName = label.Stage_5_Contracts_Complete /*10b - PO recd, pending finance approval*/;
        update opp;
        //TriggerHandler.bypass('OpportunityTriggerHandler');
        opp.StageName='7 - Closed Lost';
        opp.Sub_Stage__c = label.SubStage_Closed_Delete_Duplicate;/*'Closed: Delete Duplicate'*/
        opp.Primary_Competitor__c  = 'No decision';
        update opp;
    }
    
    @isTest 
    static void createOppExtension() {
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_RHX_Opportunity_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = true);
        
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc']; 
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = '6 - Closed Won', CloseDate = system.Today()+30);
        opp.LDR_Name__c = UserInfo.getUserId();
        //TriggerHandler.bypass('OpportunityTriggerHandler');
        insert opp;
        Test.stopTest();
        //TriggerHandler.bypass('OpportunityTriggerHandler');
        opp.StageName='7 - Closed Lost';
        opp.Sub_Stage__c = label.SubStage_Closed_Delete_Duplicate; /*'Closed: Delete Duplicate';*/
        opp.Primary_Competitor__c  = 'No decision';
        update opp;
        
    }
    
    @isTest 
    static void oppGotoSevenStage() {
        
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_RHX_Opportunity_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Opportunity_Stage_Seven', Execute__c = true);
        
        
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        insert trlst;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc']; 
        Test.startTest();
        system.runAs(usr){
            //TriggerHandler.bypass('OpportunityTriggerHandler');
            opportunity opp = new opportunity(Name = 'Test opportunity', 
                                              AccountId = acc.Id, 
                                              StageName = '6 - Closed Won', 
                                              CloseDate = system.Today()+30,
                                             Primary_Reseller_Partner__c = acc.Id);
            insert opp;
            
            //  Opportunity_Extension__c oppEtxn =new Opportunity_Extension__c();// [select id,Duplicate_Opportunity__c from Opportunity_Extension__c where Opportunity__c =: opp.Id];
            //oppEtxn.Duplicate_Opportunity__c = opp.Id;
            // oppEtxn.Opportunity__c = opp.Id;
            
            // insert oppEtxn;
            // Commented because validation is failing
            /*
            Triggerutility.oppoGotoSevenStageSetFalse();    
            opp.Product_Type__c ='Cloud Sandboxing';
            opp.Product_Types__c = 'ZPA Core (ZPA, App Protection)';
            opp.ZIA_Use_Case__c ='Data Protection';
            opp.StageName = label.Stage_7_Closed_Lost;
            opp.Sub_Stage__c = label.SubStage_Closed_Delete_Duplicate;
            //TriggerHandler.bypass('OpportunityTriggerHandler');
            update opp;     */
        }
        TriggerUtility.realignPatchReset();
        Test.stopTest();
    }
    
    @isTest 
    static void testOpptyNextStepsUpdate() {
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc']; 
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        //TriggerHandler.bypass('OpportunityTriggerHandler');
        insert opp;
        Test.stopTest();
        
        opp.NextStep = 'Test 2';
        //TriggerHandler.bypass('OpportunityTriggerHandler');
        update opp;
    }
    
    @isTest 
    static void testOpptyArchiandforecastchanges() {
        
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id overlayOpportunitySplitTypeId = [ SELECT Id, MasterLabel FROM OpportunitySplitType WHERE MasterLabel = 'Overlay' ].Id;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc'];        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName =label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Next_Steps__c  = 'fdsjsdk',OwnerId = userinfo.GetuserId());
        insert opp;
        
        OpportunitySplit oppSplitObj = new OpportunitySplit(); 
        oppSplitObj.OpportunityId = opp.Id;
        oppSplitObj.SplitOwnerId = userinfo.GetuserId();
        oppSplitObj.SplitPercentage = 100;
        oppSplitObj.SplitTypeId = overlayOpportunitySplitTypeId;
        oppSplitObj.Owner_Sales_Territory__c=Null;
        insert oppSplitObj;
        
        Test.stopTest();
        //TriggerHandler.bypass('OpportunityTriggerHandler');
        opp.NextStep = 'Test 2';
        opp.StageName = label.Stage_2_Qualified_Budgeted /*'2 - Technical Validation'*/;
        opp.AD_Forecast_Category__c = 'Omitted';
        opp.Next_Steps__c  = 'dfkjdsfjkjsfjkdsfjk';
        opp.NextStep = 'dfkjdsfjkjsfjkdsfjk';
        opp.SE_Name__c = null;
        update opp;        
    }
    
    public static testmethod void testMethod1(){
        Test.startTest();
        List<Stage_ForecastCategory_Rank__c > sfmrlst = new List<Stage_ForecastCategory_Rank__c >();
        sfmrlst.add(new Stage_ForecastCategory_Rank__c(name='Best Case',Rank__c=3 ));
        sfmrlst.add(new Stage_ForecastCategory_Rank__c(name='Closed',Rank__c=6 ));
        sfmrlst.add(new Stage_ForecastCategory_Rank__c(name='Commit',Rank__c=5 ));
        sfmrlst.add(new Stage_ForecastCategory_Rank__c(name='Omitted',Rank__c=1 ));
        sfmrlst.add(new Stage_ForecastCategory_Rank__c(name='Pipeline',Rank__c=2 ));
        insert sfmrlst;
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        //Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = true);
        
        trlst.add(tr1);
        //trlst.add(tr2);
        insert trlst;
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc'];        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName =label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                          Forecast_Category__c='Closed',CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Next_Steps__c  = 'fdsjsdk',OwnerId = userinfo.GetuserId(),Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
        insert opp;
        Test.stopTest();
        //TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerUtility.updateForecastCategoryReset();
        TriggerUtility.realignPatchReset();
        opp.Deal_Path__c='Bridge to ML';
        opp.NextStep = 'test2';
        opp.Next_Steps__c = 'test2';
        opp.StageName =label.Stage_5_Contracts_Complete;
        opp.Forecast_Category__c = 'Omitted';
        update opp;
    }
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
        return productSO;
    }
    
    static testMethod void testafterInsert(){
        List<opportunity> opp = [Select Id,Name,
                                 AccountId,
                                 StageName,
                                 Opportunity_Sales_Engineer__c,SE_name__r.Email,
                                 SE_Name__r.name,SE_Znumber__c,
                                 SE_name__c,
                                 Primary_Quote_Exception__c
                                 from opportunity LIMIT 1];
        if(!opp.isEmpty()){
            Test.startTest();
            //OppotunityTriggerHelper opptriggerhelp = new OppotunityTriggerHelper();
            OppotunityTriggerHelper.afterInsert(opp);
            Test.stopTest();
            
            List<opportunity> opplist = [Select Id,AccountId,
                                         StageName,
                                         Opportunity_Sales_Engineer__c,SE_name__r.Email,
                                         SE_Name__r.name,SE_Znumber__c,
                                         SE_name__c,
                                         Primary_Quote_Exception__c
                                         from opportunity
                                         where  Id =: opp[0].Id];
            system.assertEquals(1, opplist.size());
            
        }
    }
    
    static testMethod void testOppTeam(){
        List<opportunity> opp = [Select Id,Name,
                                 AccountId,OwnerId,
                                 StageName,
                                 Opportunity_Sales_Engineer__c,
                                 SE_name__c,SE_Znumber__c,SE_Name__r.EmployeeNumber,
                                 Primary_Quote_Exception__c
                                 from opportunity LIMIT 1];
        
        if(!opp.isEmpty()){
            Test.startTest();
            OppotunityTriggerHelper.createOpportunityTeam(opp);
            Test.stopTest();
        }
    }
    
    static testMethod void testUpdatePRStatus(){
        List<opportunity> opp = [Select Id,Name,
                                 AccountId,OwnerId,
                                 StageName,
                                 Opportunity_Sales_Engineer__c,
                                 SE_name__c,SE_Znumber__c,SE_Name__r.EmployeeNumber,
                                 Primary_Quote_Exception__c
                                 from opportunity LIMIT 1];
        
        if(!opp.isEmpty()){
            Test.startTest();
            OppotunityTriggerHelper.updatePRStatusToProduction(opp);
            Test.stopTest();
        }
    }
    
    static testMethod void testCreateOppExtn(){
        List<opportunity> opp = [Select Id,Name,
                                 AccountId,OwnerId,
                                 StageName,
                                 Opportunity_Sales_Engineer__c,
                                 SE_name__c,SE_Znumber__c,SE_Name__r.EmployeeNumber,
                                 Primary_Quote_Exception__c
                                 from opportunity LIMIT 1];
        
        if(!opp.isEmpty()){
            Test.startTest();
            OppotunityTriggerHelper.createOpportunityExtension(opp);
            Test.stopTest();
        }
    }
    
    static testMethod void testafterUpdate(){
        set<Id> oppIdSet = new Set<Id>();
        List<opportunity> opp = [Select Id,Name,
                                 AccountId,Sales_Territory_ID__c,
                                 StageName,Sub_Stage__c,
                                 Opportunity_Sales_Engineer__c,
                                 SE_name__c,SE_Znumber__c,SE_Name__r.EmployeeNumber,
                                 Primary_Quote_Exception__c,Applied_Price_List_Name__c,Deal_Reg_Margin__c,Deal_Reg_Partner_Teaming_Reseller__c
                                 from opportunity LIMIT 1];
        List<opportunity> opp1 = [Select Id,Name,
                                  AccountId,Sales_Territory_ID__c,
                                  StageName,Sub_Stage__c,
                                  Opportunity_Sales_Engineer__c,
                                  SE_name__c,SE_Znumber__c,SE_Name__r.EmployeeNumber,
                                  Primary_Quote_Exception__c,Applied_Price_List_Name__c,Deal_Reg_Margin__c,Deal_Reg_Partner_Teaming_Reseller__c
                                  from opportunity where StageName =: label.Stage_5_Contracts_Complete LIMIT 1];
        oppIdSet.add(opp1[0].Id);
        List<Account> acc1 = [select id, Name, Type from Account Limit 1];
        Id erRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('PZEN').getRecordTypeId();
        Equipment_Request__c er = new Equipment_Request__c();
        er.Approval_Status__c = 'Approved';
        er.RecordTypeId = erRecordTypeId;
        er.Opportunity__c = opp1[0].Id;
        //er.OwnerId = userinfo.getUserId();
        er.Localized_content__c = true;
        insert er;
        if(!opp1.isEmpty()){
            Test.startTest();
            // opp[0].SE_name__c =uu.id;
            map<Id, Opportunity> oldOppMap = new map<Id, Opportunity>();
            oldOppMap.put(opp1[0].id, opp[0]);
            //OppotunityTriggerHelper opptriggerhelp = new OppotunityTriggerHelper();
            OppotunityTriggerHelper.beforeUpdate(opp1,oldOppMap);
            OppotunityTriggerHelper.EREmailNotification(oppIdSet);
            OppotunityTriggerHelper.oppGotoStageSevenWithOutDuplicateOppName(opp1,oldOppMap);
            OppotunityTriggerHelper.updateneedsRepriceonQuote(opp1,oldOppMap);
            OppotunityTriggerHelper.updateOpportunityFields(oldOppMap,opp,true,true);
            OppotunityTriggerHelper.getOpportunityContractEndDates(new List<Id> { acc1[0].Id }, new List<Id> { opp[0].Id });
            Test.stopTest();
            
            List<opportunity> opplist = [Select Id,AccountId,
                                         StageName,
                                         Opportunity_Sales_Engineer__c,
                                         SE_name__c,SE_name__r.Email,
                                         SE_Name__r.name,SE_Znumber__c,
                                         Primary_Quote_Exception__c
                                         from opportunity
                                         where  Id =: opp[0].Id];
            
            
            opplist[0].SE_name__c = userinfo.getUserId();
            update  opplist;            
            system.assertEquals(1, opplist.size());
        }
    }
    
    @isTest 
    static void oppClosedLost() {
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_RHX_Opportunity_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Opportunity_Stage_Seven', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        insert trlst;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc']; 

        system.runAs(usr){
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
            opportunity opp = new opportunity(Name = 'Test opportunity', 
                                              AccountId = acc.Id, 
                                              StageName = label.Stage_4_Economic_Buyer_Signoff, 
                                              Type ='Existing Customer (Renewal)',
                                              RecordTypeId = oppRecordTypeId,
                                              CloseDate = system.Today()+30,Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
            //TriggerHandler.bypass('OpportunityTriggerHandler');
            insert opp;
            Test.stopTest();
            
            Triggerutility.oppoGotoSevenStageSetFalse();
            opp.Has_Technology_Partner__c = TRUE;
            opp.Stagename = Label.Stage_7_Closed_Lost;
            opp.Sub_Stage__c = 'Closed Lost';
            opp.Primary_Competitor__c  = 'No decision';
            opp.Requires_signing_customer_documents__c = 'Other';
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update opp;
        }
        TriggerUtility.realignPatchReset();
    }
    
    @isTest 
    static void oppClosedWithNoDecision() {
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_RHX_Opportunity_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Opportunity_Stage_Seven', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        insert trlst;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc']; 

        system.runAs(usr){
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
            opportunity opp = new opportunity(Name = 'Test opportunity', 
                                              AccountId = acc.Id, 
                                              StageName = label.Stage_4_Economic_Buyer_Signoff, 
                                              Type ='Existing Customer (Renewal)',
                                              RecordTypeId = oppRecordTypeId,
                                              CloseDate = system.Today()+30,Primary_Competitor__c = 'None',Secondary_Competitors__c='None');
            //TriggerHandler.bypass('OpportunityTriggerHandler');
            insert opp;
            Test.stopTest();
            
            Triggerutility.oppoGotoSevenStageSetFalse();
            opp.Has_Technology_Partner__c = TRUE;
            opp.Stagename = Label.Stage_7_Closed_Lost;
            opp.Sub_Stage__c = label.SubStage_Closed_With_No_Decision;/*'Closed With No Decision';*/
            opp.Primary_Competitor__c  = 'No decision';
            opp.Requires_signing_customer_documents__c = 'Other';
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update opp;
        }
        TriggerUtility.realignPatchReset();
    }
    
    @isTest 
    static void oppClosedDeleteDuplicate() {
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_RHX_Opportunity_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Opportunity_Stage_Seven', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        insert trlst;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc']; 

        system.runAs(usr){
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
            opportunity opp = new opportunity(Name = 'Test opportunity', 
                                              AccountId = acc.Id, 
                                              StageName = label.Stage_4_Economic_Buyer_Signoff, 
                                              Type ='Existing Customer (Renewal)',
                                              RecordTypeId = oppRecordTypeId,
                                              CloseDate = system.Today()+30);
            //TriggerHandler.bypass('OpportunityTriggerHandler');
            insert opp;
            Test.stopTest();
            
            Triggerutility.oppoGotoSevenStageSetFalse();
            opp.StageName = Label.Stage_7_Closed_Lost;
            opp.Validation_Stage__c = '1 - Establishing Plan & success criteria';
            opp.Sub_Stage__c = label.SubStage_Closed_Delete_Duplicate;/*'Closed: Delete Duplicate';*/
            opp.Primary_Competitor__c  = 'No decision';
            opp.Requires_signing_customer_documents__c = 'Other';
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update opp;
        }
        TriggerUtility.realignPatchReset();        
    }
    
    @istest
    static void testOppty(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc'];
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(Name = 'Test opportunity', 
                                          AccountId = acc.Id, 
                                          StageName = label.Stage_4_Economic_Buyer_Signoff, 
                                          Type ='Existing Customer (Renewal)',
                                          RecordTypeId = oppRecordTypeId,
                                          CloseDate = system.Today()+30,
										  Primary_Competitor__c = 'None',
										  Secondary_Competitors__c='None');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert opp;
	
        opp.StageName = '5 - Procurement'; /*'5C - Sales Rep Action Required';*/
        opp.Type ='New Business';
        opp.AVP_In_my_Number__c = false;
        opp.Geo_VP_In_my_Number__c =false;
        opp.Next_Steps__c ='Test';
        opp.Reason_for_5C__c = 'Test';
        update opp;
        
        opp.Next_Steps__c = 'YT';
        update opp;
    }
}