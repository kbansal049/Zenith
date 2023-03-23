@isTest
public class Extension_Expiry_Notification_Batch_Test{
    static testmethod void test1(){
        Account account = new Account(Name = 'Test Account');
        //account.Needs_to_be_Migrated__c = true;
        insert account;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.AccountId = account.Id;

        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
        con2.Renewal_Notification_Recipient__c = true;
        con2.AccountId = account.Id;
        
        insert new List<Contact> { con1, con2 };
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        opp.New_Extended_Contract_Date__c = date.today();
        update opp;
        
        Extension_Expiry_Notification_Batch batch;
        batch = new Extension_Expiry_Notification_Batch();
        Extension_Expiry_Notification_Batch batch1;  
        string query = 'Select Id, Account.CSM_Name_New__r.Email, Account.CSM_Name_New__c, Owner.Email from Opportunity where Contract_End_Date_New__c =: day AND Recordtype.name = \'Renewal Opportunity\' and Type =\'Existing Customer (Renewal)\' AND (StageName != \'6 - Closed Won\' OR StageName != \'7 - Closed Lost\')';   
        batch1 = new Extension_Expiry_Notification_Batch(query,14);
        batch.errorlst.add('abc');
        batch1.successlst.add('abc');
        Database.executeBatch(batch,1);
        Database.executeBatch(batch1,1);
        
    }
    
    static testmethod void test2(){
        Account account = new Account(Name = 'Test Account');
        //account.Needs_to_be_Migrated__c = true;
        insert account;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.AccountId = account.Id;

        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
        con2.Renewal_Notification_Recipient__c = true;
        con2.AccountId = account.Id;
        
        insert new List<Contact> { con1, con2 };
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true,Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        opp.New_Extended_Contract_Date__c = date.today().adddays(-1);
        update opp;
        
        Extension_Expiry_Notification_Batch batch;
        batch = new Extension_Expiry_Notification_Batch();
        Extension_Expiry_Notification_Batch batch1;  
        string query = 'Select Id, Account.CSM_Name_New__r.Email, Account.CSM_Name_New__c, Owner.Email from Opportunity where Contract_End_Date_New__c =: day AND Recordtype.name = \'Renewal Opportunity\' and Type =\'Existing Customer (Renewal)\' AND (StageName != \'6 - Closed Won\' OR StageName != \'7 - Closed Lost\')';   
        batch1 = new Extension_Expiry_Notification_Batch(query,14);
        //batch.errorlst.add('abc');
        batch1.successlst.add('abc');
        Database.executeBatch(batch,1);
        Database.executeBatch(batch1,1);
        
    }
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
       Product2 productSO = new Product2();
       productSO.Name = ProductName;
       productSO.Family = pfamily;
       productSO.ProductCode = pcode;
       productSO.IsActive = true;
       
       return productSO;
   }
   
    //Added by Rajesh -- CR 1035/1036 - Start
            
    static testmethod void notification180Test(){   
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);   
        acc.CSM_Name_New__c = UserInfo.getUserId(); 
        acc.Customer_Advocate__c = UserInfo.getUserId();    
        acc.Sales_Engineer__c = UserInfo.getUserId();   
        acc.Solution_Architect__c = UserInfo.getUserId();   
        acc.Account_Manager__c = UserInfo.getUserId();  
        acc.TAM_Name_New__c = UserInfo.getUserId(); 
        acc.Channel_Manager__c = UserInfo.getUserId();  
            
        update acc; 
        
        Date closeDate = system.today() + 365;  
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId(); 
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , meRecordTypeId, null, null, null,null, null, null, null, null, null, true);   
        //opp.Renewable_ACV__c= Null;
        opp.Contract_End_Date_New__c = system.today() + 180;    
        opp.Type =  'Existing Customer (Renewal)';  
            
        update opp; 
        
        Test.startTest();   
        Renewal_Notification_Batch_180Sch sche = new Renewal_Notification_Batch_180Sch();   
        String sch ='0 0 0 * * ?';  
        System.schedule('Notification Test', sch,sche); 
            
        Extension_Expiry_Notification_Batch batch;  
        string query = 'Select Id,Owner.Name, Contract_End_Date_New__c,Owner.Email, CloseDate, Renewal_Amount__c,Renewable_ACV__c, Account.Sales_Engineer__r.Name, Account.Channel_Manager__r.Name,Account.Name, Account.CSM_NAMEOverlay__c, Account.TAM_Name_New__r.Name, Account.Solution_Architect_Name__c, Account.Customer_Advocate__c, Account.Customer_Advocate__r.Name, Account.Owner.Name, Account.Secondary_TAM_Name__r.Email, Account.Secondary_TAM_Name__c, Account.Channel_Manager__r.Email, Account.Channel_Manager__c, Account.TAM_Name_New__r.Email, Account.TAM_Name_New__c, Account.Account_Manager__r.Email, Account.Account_Manager__c, Account.Customer_Advocate__r.Email, Account.Sales_Engineer__r.Email, Account.CSM_Name_New__c, Account.CSM_Name_New__r.Email, Account.Solution_Architect__c, Account.Solution_Architect__r.Email, Account.Id, Name from Opportunity where Contract_End_Date_New__c =: day AND Recordtype.name = \'Renewal Opportunity\' and Type =\'Existing Customer (Renewal)\' AND (StageName != \'6 - Closed Won\' OR StageName != \'7 - Closed Lost\')'; 
        batch = new Extension_Expiry_Notification_Batch(query,180); 
        Database.executeBatch(batch,1); 
        Test.stopTest();    
    }
    //Added by Rajesh -- CR 1035/1036 - End
    
    static testmethod void notification180Test2(){  
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);       
        //acc.CSM_Name_New__c = UserInfo.getUserId();   
        acc.Customer_Advocate__c = UserInfo.getUserId();    
        acc.Sales_Engineer__c = UserInfo.getUserId();
        acc.Secondary_TAM_Name__c = UserInfo.getUserId();
        //acc.OwnerId = Null;
        update acc; 
        
        Date closeDate = system.today() + 365;  
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId(); 
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , meRecordTypeId, null, null, null,null, null, null, null, null, null, true);   
        opp.Renewable_ACV__c= Null;
        opp.Contract_End_Date_New__c = system.today() + 180;    
        //opp.Contract_End_Date_New__c = Null;
        opp.Type =  'Existing Customer (Renewal)';  
            
        update opp; 
       
        
        Test.startTest();   
        Renewal_Notification_Batch_180Sch sche = new Renewal_Notification_Batch_180Sch();   
        String sch ='0 0 0 * * ?';  
        System.schedule('Notification Test', sch,sche); 
            
        Extension_Expiry_Notification_Batch batch;  
        string query = 'Select Id,Owner.Name, Contract_End_Date_New__c,Owner.Email, CloseDate, Renewal_Amount__c,Renewable_ACV__c, Account.Sales_Engineer__r.Name, Account.Channel_Manager__r.Name,Account.Name, Account.CSM_NAMEOverlay__c, Account.TAM_Name_New__r.Name, Account.Solution_Architect_Name__c, Account.Customer_Advocate__c, Account.Customer_Advocate__r.Name, Account.Owner.Name, Account.Secondary_TAM_Name__r.Email, Account.Secondary_TAM_Name__c, Account.Channel_Manager__r.Email, Account.Channel_Manager__c, Account.TAM_Name_New__r.Email, Account.TAM_Name_New__c, Account.Account_Manager__r.Email, Account.Account_Manager__c, Account.Customer_Advocate__r.Email, Account.Sales_Engineer__r.Email, Account.CSM_Name_New__c, Account.CSM_Name_New__r.Email, Account.Solution_Architect__c, Account.Solution_Architect__r.Email, Account.Id, Name from Opportunity where Contract_End_Date_New__c =: day AND Recordtype.name = \'Renewal Opportunity\' and Type =\'Existing Customer (Renewal)\' AND (StageName != \'6 - Closed Won\' OR StageName != \'7 - Closed Lost\')'; 
        batch = new Extension_Expiry_Notification_Batch(query,180); 
        Database.executeBatch(batch,1); 
        Test.stopTest();    
    }
    
    static testmethod void notification180Test3(){  
        
        Date closeDate = system.today() + 365;  
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId(); 
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, Null, Label.Stage_4_Economic_Buyer_Signoff, closeDate , meRecordTypeId, null, null, null,null, null, null, null, null, null, true); 
        opp.Renewable_ACV__c= Null;
        opp.Contract_End_Date_New__c = system.today() + 180;    
        //opp.Contract_End_Date_New__c = Null;
        opp.Type =  'Existing Customer (Renewal)';  
            
        update opp; 
       
        
        Test.startTest();   
        Renewal_Notification_Batch_180Sch sche = new Renewal_Notification_Batch_180Sch();   
        String sch ='0 0 0 * * ?';  
        System.schedule('Notification Test', sch,sche); 
            
        Extension_Expiry_Notification_Batch batch;  
        string query = 'Select Id, Contract_End_Date_New__c, CloseDate,Owner.Email,Owner.Name, Renewal_Amount__c,Renewable_ACV__c, Account.Sales_Engineer__r.Name, Account.Channel_Manager__r.Name,Account.Name, Account.CSM_NAMEOverlay__c, Account.TAM_Name_New__r.Name, Account.Solution_Architect_Name__c, Account.Customer_Advocate__c, Account.Customer_Advocate__r.Name, Account.Owner.Name, Account.Secondary_TAM_Name__r.Email, Account.Secondary_TAM_Name__c, Account.Channel_Manager__r.Email, Account.Channel_Manager__c, Account.TAM_Name_New__r.Email, Account.TAM_Name_New__c, Account.Account_Manager__r.Email, Account.Account_Manager__c, Account.Customer_Advocate__r.Email, Account.Sales_Engineer__r.Email, Account.CSM_Name_New__c, Account.CSM_Name_New__r.Email, Account.Solution_Architect__c, Account.Solution_Architect__r.Email, Account.Id, Name from Opportunity where Contract_End_Date_New__c =: day AND Recordtype.name = \'Renewal Opportunity\' and Type =\'Existing Customer (Renewal)\' AND (StageName != \'6 - Closed Won\' OR StageName != \'7 - Closed Lost\')'; 
        batch = new Extension_Expiry_Notification_Batch(query,180); 
        Database.executeBatch(batch,1); 
        Test.stopTest();    
    }
    //Added by Rajesh -- CR 1035/1036 - End
	
}