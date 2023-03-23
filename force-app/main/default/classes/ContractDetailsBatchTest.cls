@IsTest
private class ContractDetailsBatchTest {
    
    @TestSetup static void setup() {
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerUtility.SkipConDetailTriggerExecuted();
        
        //Select Id,name from Contract_Details_Integration_Sync__c where SKU__c != null and Sync_Status__c != \'Success\' and 
        //Sales_Order_Number__c != null order by Renewed_To_Internal_ID__c nulls first
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'System',
                          lastname='Admin',
                          Alias='sysAdmin',
                          email = 'test'+System.now().getTime()+'@zscaler.com',
                          username= 'test'+System.now().getTime()+'@zscaler.com',
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.TAM_Email__c = 'abc@abc.com';
        acc.BillingCity = 'Test city';
        acc.BillingCountry = 'Test country';
        acc.BillingStreet = 'Test street';
        accList.add(acc);
        
        Account acc1 = new Account();
        acc1.Name = 'TestAccount1';
        acc1.TAM_Email__c = 'def@abc.com';
        acc1.BillingCity = 'Test city1';
        acc1.BillingCountry = 'Test country1';
        acc1.BillingStreet = 'Test street1';
        accList.add(acc1);
        insert accList;
        
        opportunity oppty= new opportunity();
        oppty.Name = 'Testopportunity';
        oppty.Primary_Quote_Exception__c  = true; 
        oppty.AccountId = accList.get(0).Id;
        oppty.StageName = '6 - Closed Won';
        oppty.CloseDate = system.Today()+30;
        oppty.Netsuite_Sales_Order_Number__c = 'TestOrder';
        oppty.Applied_Price_List_Name__c = 'FY20 Pricelist';
        insert oppty;
        
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> csLst = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs.Name = 'ZDX_Contract_Date';
        cs.SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZDX-ADVANCED';
        csLst.add(cs);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs1.Name = 'ZDX_Adv';
        cs1.SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZDX-ADVANCED;ZDX-ADV;ZDX-M365';
        csLst.add(cs1);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs2.Name = 'ZDX_Standard';
        cs2.SKU_Codes__c = 'ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION';
        csLst.add(cs2);
        
        INSERT csLst;
        
    }
    
    @IsTest static void testBatch(){
        
        User sysAdmin = [SELECT Id FROM User LIMIT 1];
        System.runAs(sysAdmin) {
            
            List<Account> accList = [Select id, name from Account limit 2];
            
            Opportunity oppty = [Select id, name from Opportunity limit 1];
            
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler');
            TriggerUtility.SkipConDetailTriggerExecuted();
            
            //Select id,Name,AccountId,NS_Sales_Order_Number__c from Order where NS_Sales_Order_Number__c != null and NS_Sales_Order_Number__c in : soNums
            Order ord = new Order();
            ord.Name = 'TestOrder';
            ord.AccountId = accList.get(0).id;
            ord.NS_Sales_Order_Number__c = 'S38035';
            ord.EffectiveDate = Date.today();
            ord.Status = 'Draft';
            ord.Order_Date__c =  Date.today();
            insert ord;
            
            Contract_Detail__c  contract = new Contract_Detail__c();
            contract.Name = 'Test Contract';
            contract.Account_Name__c = accList.get(0).Id;        
            contract.Quantity__c = 5000;
            contract.Contract_Detail_Status__c = 'Active';
            
            contract.Do_not_Aggregate__c = false;
            contract.Override_Contract_Detail_Status__c = false;
            contract.Start_Date__c = Date.today();
            contract.End_Date__c = Date.today().addDays(180);
            contract.Amount_USD__c = 50000.00;
            contract.ZScaler_Product_Family__c = 'ZIA';
            contract.Is_Bundle_SKU__c = true;
            contract.CD_InternalID__c = '123456';
            insert contract;                             
            
            insert new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'ZDX_Contract_Date', SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZDX-ADVANCED;ZDX-ADV;ZDX-M365');
            insert new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZPA-Remote-PRE;ZS-WFA-BUS-EDITION;ZPA-FED-BUNDLE;ZPA-ZFED-MODERATE');
            
        }  
        Test.startTest();            
        ContractDetailsBatchSch Schedule = new ContractDetailsBatchSch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test', sch, Schedule);
        Date todayDate = Date.today() ;
        string query= 'SELECT Id,Active__c,Is_Contract_Active__c from Contract_Detail__c';
        contractDetailsBatch instance = new contractDetailsBatch(query);    
        Id jobid = Database.executeBatch(instance);
        Test.stopTest();  
    }
}