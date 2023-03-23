@isTest
public class Rollup_Key_Fields_To_Opportunity_Test{

    static testmethod void test1(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = UserInfo.getUserId();
        sk.Object_s_to_skip__c = 'User;Account';
        INSERT sk;
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acct.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        opp.Value_Creation_Stage__c ='9-Value Consulting - Completed';
        insert opp;
        
        Significant_Customer_Interaction__c sci = new Significant_Customer_Interaction__c();
        sci.Date__c = system.today();
        sci.Interaction_With__c = 'Test Data';
        sci.I_am_the__c = 'Organizer';
        sci.Next_Steps__c = 'F2F Meeting';
        sci.Meeting_Notes__c = 'Important conv';
        sci.Account_Name__c = acct.Id;
        sci.Primary_Topic_Covered__c = 'Solution Architecture';
        sci.Opportunity_Name__c = opp.Id;
        sci.Method_of_Interaction__c = 'F2F';
        
        insert sci;
        
       
        VC_and_Opportunity_Stage_Mapping__mdt vcopp = [SELECT Id,VC_Value__c,Opportunity_Value__c FROM VC_and_Opportunity_Stage_Mapping__mdt limit 1];
        Value_Creation_Engagements__c vc = new Value_Creation_Engagements__c();
        vc.Link_to_SFDC_Opportunity__c = opp.Id;
        vc.Engagement_Type__c = 'Consulting';
        vc.Value_Creation_Stage__c = '9-Value Consulting - Completed';
        vc.Collaboration__c = 'Customer - all';
        vc.EB_Read_out__c = 'Read out to EB';
        vc.Customer_Metrics__c = 'Some';
        vc.Timeliness__c = 'Last minute';
        TriggerHandler.bypass('ValueCreationEngagementHelper');
        insert vc;
        
        
        
        Value_Creation_Engagements__c vc2 = new Value_Creation_Engagements__c();
        vc2.Link_to_SFDC_Opportunity__c = opp.Id;
        vc2.Engagement_Type__c = 'Assessment';
        vc2.Value_Creation_Stage__c = '7-Output Presentation';
        vc2.Collaboration__c = 'Customer - all';
        vc2.EB_Read_out__c = 'Read out to EB';
        vc2.Customer_Metrics__c = 'Some';
        vc2.Timeliness__c = 'Last minute';
        TriggerHandler.bypass('ValueCreationEngagementHelper');
        insert vc2;
        
        Value_Creation_Engagements__c vc3 = new Value_Creation_Engagements__c();
        vc3.Link_to_SFDC_Opportunity__c = opp.Id;
        vc3.Engagement_Type__c = 'Realization';
        
        //vc3.Value_Creation_Stage__c = vcopp.VC_Value__c;
        vc3.Value_Creation_Stage__c = '7-Output Presentation';
         vc3.Collaboration__c = 'Customer - all';
        vc3.EB_Read_out__c = 'Read out to EB';
        vc3.Customer_Metrics__c = 'Some';
        vc3.Timeliness__c = 'Last minute';
        TriggerHandler.bypass('ValueCreationEngagementHelper');
        insert vc3;
        
        
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
        
        //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' Limit 1];
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
        
        List<Value_Creation_Engagements__c> valueCreationTest = [Select id,Name,Engagement_Type__c,Value_Creation_Stage__c,Link_to_SFDC_Opportunity__c from Value_Creation_Engagements__c];
        List<Value_Creation_Engagements__c> newValueCreationList = new List<Value_Creation_Engagements__c>();
        for(Value_Creation_Engagements__c valueCre : valueCreationTest){
            valueCre.Value_Creation_Stage__c = '9-Value Consulting - Completed';
            newValueCreationList.add(valueCre);
        }
        update newValueCreationList;
        
        List<Value_Creation_Engagements__c> valueCreationTest1 = [Select id,Name,Engagement_Type__c,Value_Creation_Stage__c,Link_to_SFDC_Opportunity__c from Value_Creation_Engagements__c];
        
        test.starttest();
        Rollup_Key_Fields_To_Opportunity batch;
        batch = new Rollup_Key_Fields_To_Opportunity('Select Id,  All_time_F2F_of_SCI__c, All_time_of_SCI__c from Opportunity ');
        batch.errorlst.add('abc');
        Database.executeBatch(batch,200);
        test.stoptest();
    
    }
    static testmethod void test2(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = UserInfo.getUserId();
        sk.Object_s_to_skip__c = 'User;Account';
        INSERT sk;
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acct.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        opportunity opp1 = new opportunity(Name = 'Test1 opportunity', Primary_Quote_Exception__c  = true, AccountId = acct.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+20);
        insert opp1;
        
        test.starttest();
        
        List<Value_Creation_Engagements__c> VCElist = new List<Value_Creation_Engagements__c>();
        Value_Creation_Engagements__c VCE1= new Value_Creation_Engagements__c(Engagement_Type__c='Consulting',Link_to_SFDC_Opportunity__c=opp.id);
        VCElist.add(VCE1);
        TriggerHandler.bypass('ValueCreationEngagementHandler');
        insert VCElist;
            
        VCElist[0].Value_Creation_Stage__c='9-Value Consulting - Completed';
        update VCElist;

        test.stoptest();
    }
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
      
        return productSO;
    }
}