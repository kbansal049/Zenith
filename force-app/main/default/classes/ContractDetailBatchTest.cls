@IsTest
private class ContractDetailBatchTest {
    
    @TestSetup static void setup() {
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c cs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        cs.Name = 'ZDX_Contract_Date';
        cs.SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZDX-ADVANCED';
        INSERT cs;
        
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
        
    }
    
    @IsTest static void testSchedule(){
        User sysAdmin = [SELECT Id FROM User LIMIT 1];
        System.runAs(sysAdmin) {
            List<Account> accList = new List<Account>();
            Account acc = new Account();
            acc.Name = 'Account Historical 7';
            acc.BillingCity = 'Test city';
            acc.BillingCountry = 'Test country';
            acc.BillingStreet = 'Test street';
            accList.add(acc);
            insert accList;
            
            
            List<Account_Extension__c> extList = new List<Account_Extension__c>();
            Account_Extension__c ext = new Account_Extension__c();
            ext.Account__c = accList.get(0).Id;
            extList.add(ext);
            insert extList;
            
            
            
            
            List<Contract_Detail__c> conDetail = new List<Contract_Detail__c>();
            /*Contract_Detail__c con = new Contract_Detail__c();
con.Account_Name__c = accList.get(0).Id;        
con.Start_Date__c = Date.today();
con.Product_SKU__c = 'ZIA-TRANS-EDITION';
con.Product_Name__c = product.Id;
con.Is_Bundle_SKU__c  = TRUE;*/
            
            
            Contract_Detail__c  contract = new Contract_Detail__c();
            contract.Name = 'Test Contract';
            contract.Account_Name__c = accList.get(0).Id;        
            contract.Quantity__c = 5000;
            contract.Contract_Detail_Status__c = 'Active';
            contract.Product_SKU__c = 'ZIA-TRANS-EDITION';
            
            
            contract.Do_not_Aggregate__c = false;
            contract.Override_Contract_Detail_Status__c = false;
            contract.Start_Date__c = Date.today().addDays(-100);
            contract.End_Date__c = Date.today().addDays(100);
            contract.Amount_USD__c = 50000.00;
            contract.ZScaler_Product_Family__c = 'ZIA';
            contract.Is_Bundle_SKU__c = true;
            
            conDetail.add(contract);
            
            insert conDetail;
            
            List<Contract_Detail__c> contractDetails1 = [SELECT Id, Account_Name__c, Start_Date__c, Product_SKU__c 
                                                         FROM Contract_Detail__c ];
                        
            
            Test.startTest();
            
            
            ContractDetailBatch instance = new ContractDetailBatch();
            
            Id jobid = Database.executeBatch(instance);
            
            system.debug('-=-=- jobid -=- '+jobid);
            
            Test.stopTest(); 	
        }
        
    }
}