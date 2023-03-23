/*********************************************************************
 * $Id$:            SB_TestCPQDataUtility
 * $Description$:   This is a data factory class for CPQ functionality
 ********************************************************************/
    @isTest(seeAllData=false)
    public  class SB_TestCPQDataUtility {
        //Variable declaration 
        public static list<product2>lstProduct = new list<product2>();
        public static List<Account> accResults = new List<Account>();
        public static List<Partner_Incentive__c> partnerIncentiveResults = new List<Partner_Incentive__c>();
        public static List<Contact> conResults = new List<Contact>();
        public static List<Opportunity> oppResults = new List<Opportunity>();
        public static List<SBQQ__Quote__c> quoteResults = new List<SBQQ__Quote__c>();
        public static List<OpportunityLineItem> opptyLineList = new List<OpportunityLineItem>();
        public static List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        public static List<User> lResults = new List<User>();
        public static List<product2> prodResults = new List<product2>();
        public static List<PriceBook2> priceBooksToBeInsertedList = new List<PriceBook2>();
        public static List<PricebookEntry> pbeResults = new List<PricebookEntry>();
        public static List<Contract> contractsList = new List<Contract>();
        public static List<SBQQ__Subscription__c> subscriptionsList = new List<SBQQ__Subscription__c>();
        public static Id pricebookId = Test.getStandardPricebookId();   
        
        /**
        *  Description: Create Accounts
        *  @name      : createAccount
        *  @param     : Integer
        *  @return    : list of Account
        */
        public static List<Account> createAccount(Integer iNum){
            for (Integer i = 0; i < iNum; i++) {
                Account a = new Account(Name='TestAccount' + i, ShippingCountry='India');
                a.BillingCountry = 'United States';
                a.BillingStreet = 'Test Street';
                a.BillingState ='Test Billing State';
                a.BillingPostalCode ='12345';
                a.ShippingCity ='Pune';
                a.ShippingCountry ='India';
                a.ShippingPostalCode = '12345';
                a.ShippingState = 'Maharashtra';
                a.ShippingStreet = 'Test Shipping Street';  
                a.Website = 'www.google.com';
                accResults.add(a);
            }
            return accResults;
        }
        
        /**
        *  Description: Create Partner Incentives
        *  @name      : createPartnerIncentive
        *  @param     : Integer , String, Boolean, Date, Date, String, String
        *  @return    : list of Partner Incentives
        */
        public static List<Partner_Incentive__c> createPartnerIncentive(Integer iNum,String accId, Boolean pIActive, Date endDate, Date startDate, String partnerProgramName, String partnerRole){
            for (Integer i = 0; i < iNum; i++) {
                Partner_Incentive__c pI = new Partner_Incentive__c();
                pI.Account__c = accId;
                pI.Active__c = pIActive;
                pI.Architecture_Workshop__c = 4;
                pI.Category_A__c = 32;
                pI.Category_B__c = 20;
                pI.Deal_Reg_Renewal__c = 10;
                pI.Deal_Reg_Teaming__c = 6;
                pI.Distributor__c = 6;
                pI.Effective_End_Date__c = endDate;
                pI.Effective_Start_Date__c = startDate;
                pI.Partner_Program__c = partnerProgramName;
                pI.Partner_Role__c = partnerRole;
                pI.Partner_Tier__c = 'Zenith';
                partnerIncentiveResults.add(pI);
            }
            return partnerIncentiveResults;
        }
        
        /**
        *  Description: Create Users
        *  @name      : createUsers
        *  @param     : Integer , String , String , String 
        *  @return    : list of Users
        */
        public static List<User> createUsers(Integer iNum, String fName, String lName, String profileName) {    
            Profile usrProfile = [SELECT Id FROM Profile WHERE Name =:ProfileName];
            for (Integer i = 0; i < iNum; i++){
                User usr = new User();
                usr.FirstName = fName;
                usr.LastName = lName;             
                usr.Username = System.now().millisecond() + 'user0@test.com.' + fName;
                usr.ProfileId = usrProfile.Id;
                usr.Alias = 'user0';
                usr.isActive = true;
                usr.Email = 'user0@test.com';
                usr.CommunityNickname = System.now().millisecond()+fName;            
                usr.TimeZoneSidKey = 'America/Los_Angeles';
                usr.LocaleSidKey = 'en_US';
                usr.EmailEncodingKey = 'UTF-8';
                usr.LanguageLocaleKey = 'en_US';    
                lResults.add(usr);
            }
            return lResults;
        }
        
        /**
        *  Description: Create Contact
        *  @name      : createContact
        *  @param     : Integer, String, String, String, String 
        *  @return    : list of Contact
        */ 
        public static List<Contact> createContact (Integer iNum, String accId){
            for (Integer i = 0; i < iNum; i++) {
                Contact newCon = new Contact();
                newCon.FirstName = 'Test First' + i;
                newCon.LastName = 'Test Last' + i;
                newCon.Email = 'testCPQEmail'+i+'@test.com';
                newCon.AccountId = accId;
                conResults.add(newCon);
            }
            return conResults;
        }
        
        /**
        *  Description: Create Product
        *  @name      : createProduct
        *  @param     : Integer, String, String, String, String
        *  @return    : list of product2
        */
        public static List<product2> createProduct(Integer iNum, String prodName, String prodCode,String subsType,String priceMeter) {
            for (Integer i = 0; i < iNum; i++) {
                Product2 objProd = new Product2();
                objProd.Name = prodName+i;
                objProd.ProductCode = prodCode+i;
                objProd.isActive = true;   
                objProd.SBQQ__SubscriptionType__c = subsType;   
                objProd.SBQQ__SubscriptionTerm__c=12;
                objProd.Pricing_Meter__c=priceMeter;   
                prodResults.add(objProd);
            }
            system.debug('prodResults'+prodResults);
            return prodResults;       
        }
        
        /**
        *  Description: Create Custom PriceBook
        *  @name      : createCustomPriceBooks
        *  @param     : Integer
        *  @return    : list of Pricebook2
        */
        public static List<PriceBook2> createCustomPriceBooks(Integer iNum){
            for(Integer i = 0; i < iNum; i++){
                PriceBook2 pb = new PriceBook2(name='Test PriceBook '+i, isActive=TRUE);
                priceBooksToBeInsertedList.add(pb);
            }
            return priceBooksToBeInsertedList;
        }

        /**
        *  Description: Create PricebookEntry
        *  @name      : createPriceBookEntry
        *  @param     : Integer, String, double
        *  @return    : list of PricebookEntry
        */
        public static List<PricebookEntry> createPriceBookEntry(Integer iNum, String prodId, double pbeUnitPrice){ 
            List<PricebookEntry> standardPBE = new List<PricebookEntry>();
            for (Integer i = 0; i < iNum; i++) {
                PricebookEntry objPriceBookEntry = new PricebookEntry();
                objPriceBookEntry.Product2Id = prodId;
                objPriceBookEntry.UnitPrice = pbeUnitPrice;
                objPriceBookEntry.IsActive = true;
                objPriceBookEntry.Pricebook2Id = priceBooksToBeInsertedList[0].Id;  
                pbeResults.add(objPriceBookEntry);
                //Standard Price Book Entry
                objPriceBookEntry = new PricebookEntry();
                objPriceBookEntry.Product2Id = prodId;
                objPriceBookEntry.UnitPrice = 0;
                objPriceBookEntry.IsActive = true;
                objPriceBookEntry.Pricebook2Id = Test.getStandardPricebookId();                    
                standardPBE.add(objPriceBookEntry);
            }
            insert standardPBE;
            return pbeResults;
        }  
        
        
        /**
        *  Description: Create Opportunity
        *  @name      : createOpportunity
        *  @param     : Integer, String, String
        *  @return    : List of Opportunity
        */ 
        public static List<opportunity> createOpportunity(Integer iNum, String oppName, String accId){
            for (Integer i = 0; i < iNum; i++) {
                Opportunity objOpp = new Opportunity();
                objOpp.Name = oppName+i;
                objOpp.Amount = 100000;
                objOpp.StageName = '1 - Discovery & Qualification '; 
                objOpp.Opp_Price_List__c = 'FY21 Single Tier Price List'; 
                objOpp.Pricebook2Id = priceBooksToBeInsertedList[0].Id; 
                objOpp.Applied_Price_List_Name__c = 'FY 21 Single Tier Pricelist';
                objOpp.Type = 'New Business';
                objOpp.AccountId = accId;
                objOpp.CloseDate=System.today().addMonths(1);
                oppResults.add(objOpp);
            }
            return oppResults;
        } 

        /**
        *  Description: create Opportunity Line Item
        *  @name      : createOpptyLineItem
        *  @param     : List,Integer, Integer, Id 
        *  @return    : List of OpportunityLineItem
        */
        public static List<OpportunityLineItem> createOpptyLineItem ( List<PricebookEntry> pbeList, Integer quantity , Integer totalPrice,Id oppId){
            for (Integer i = 0; i < pbeList.size(); i++) {
                OpportunityLineItem opptyLine = new OpportunityLineItem();
                opptyLine.OpportunityId = oppId;
                opptyLine.PricebookEntryId = pbeList[i].id;
                opptyLine.Product2Id = pbeList[i].Product2Id;
                opptyLine.Quantity = quantity;
                opptyLine.UnitPrice  = totalPrice;
                opptyLineList.add(opptyLine);
            }
            return opptyLineList;
        }

        /**
        *  Description: Create Quote
        *  @name      : createQuote
        *  @param     : Integer, String, String, String, String, String
        *  @return    : list of Quote
        */ 
        public static List<SBQQ__Quote__c> createQuote (Integer iNum, String oppId, String accId, String partnerAccId, String distAccId, String recordTypeId){
            for (Integer i = 0; i < iNum; i++) {
                SBQQ__Quote__c quote = new SBQQ__Quote__c();
                quote.SBQQ__Status__c='Draft';
                quote.SBQQ__Type__c='Quote';
                quote.SBQQ__ShippingCountry__c='Australia';
                quote.SBQQ__Opportunity2__c=oppId;
                quote.SBQQ__Account__c= accId; 
                quote.SBQQ__StartDate__c = System.Today();
                quote.SBQQ__EndDate__c = System.Today()+365;
                quote.SBQQ__Partner__c = partnerAccId;
                quote.Bill_to__c = distAccId;
                quote.recordTypeId = recordTypeId;
                //quote.pricebook2Id = priceBooksToBeInsertedList[0].Id;
                
                quoteResults.add(quote);
            }
            return quoteResults;
        }

        /**
        *  Description: Create Quote Line
        *  @name      : createQuoteLine
        *  @param     : Integer , String, String, Date, Date, String
        *  @return    : List of SBQQ__QuoteLine__c
        */
        public static List<SBQQ__QuoteLine__c> createQuoteLine (Integer iNum , String quoteId,String productId, Date startDate, Date endDate ,Double quantity){
            for (Integer i = 0; i < iNum; i++) {
                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                quoteLine.SBQQ__Quote__c = quoteId;
                quoteLine.SBQQ__Product__c = productId;
                quoteLine.SBQQ__StartDate__c = startDate;
                quoteLine.SBQQ__EndDate__c = endDate ;
                quoteLine.SBQQ__Quantity__c = quantity;
                quoteLine.SBQQ__NetPrice__c = 96;
                //quoteLine.SBQQ__SubscriptionType__c = subsType;
                quoteLineList.add(quoteLine);
            }   
            return quoteLineList;
        }
        
        /**
        *  Description: Create Contract
        *  @name      : createContracts
        *  @param     : SBQQ__Quote__c , Integer
        *  @return    : List of Contract
        */
        public static List<Contract> createContracts(String accId,String partnerId,String billToId,Partner_Incentive__c pId,Integer numOfContracts){
            contractsList = new List<Contract>();
            for (Integer i=0;i<numOfContracts;i++) {
                Contract c = new Contract();
                c.Name='Test Contract '+i;
                c.AccountId=accId;
                c.StartDate=system.today()-10;
                c.EndDate=system.today()+(365*3);
                c.ACV_New__c=117606.68;
                c.Billing_Frequency__c = 'Annual';
                c.Bill_to__c = billToId;
                c.Partner__c = partnerId;
                c.Partner_Incentive__c=pId.Id;
                c.Partner_Program__c=pId.Partner_Program__c;
                c.Price_List__c='FY21 Single Tier Price List';
                c.TVC__c = 312749.03;
                c.SBQQ__RenewalQuoted__c = true;
                c.SBQQ__RenewalForecast__c=true;
                //c.SBQQ__Quote__c=quote.Id;
                //c.SBQQ__Opportunity__c=quote.SBQQ__Opportunity2__c;
                contractsList.add(c);
            }
            return contractsList;
        }

        /**
        *  Description: Create Subscription Lines
        *  @name      : createSubscriptions
        *  @param     : Contract ,String
        *  @return    : List of SBQQ__Subscription__c
        */
        public static List<SBQQ__Subscription__c> createSubscriptions(Contract contractRec, List<Product2> prodList){
            subscriptionsList = new List<SBQQ__Subscription__c>();
            for(Product2 prod : prodList){
                SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                sub.SBQQ__Contract__c = contractRec.Id;
                sub.SBQQ__Account__c = contractRec.AccountId;
                sub.SBQQ__Quantity__c = 96;
                sub.SBQQ__Product__c = prod.Id;
                sub.SBQQ__TerminatedDate__c = System.today().addMonths(4);
                subscriptionsList.add(sub);
            }
            return subscriptionsList;
        }

         /**
        *  Description: Create premium support range 
        *  @name      : createPremiumSupportRange
        *  @param     :  Decimal,Decimal,String,String,String
        *  @return    : Premium_support_range__c
        */
        public static Premium_support_range__c createPremiumSupportRange(Decimal minimumRange, Decimal maxRange,String TamCoverage,String supportType,String productCode){
                Premium_support_range__c ps = new Premium_support_range__c();
                ps.Minimum_Price_Range__c = minimumRange;
                ps.Maximum_Price_Range__c = maxRange;
                ps.TAM_Coverage__c = TamCoverage;
                ps.Support_Type__c = supportType;
                ps.Product_Code__c = productCode;
            return ps;
        }

        /**
        *  Description: Create Clone Quote Mapping data
        *  @name      : createCloneQuoteMapping
        *  @param     : None
        *  @return    : list of SB_Clone_Quote_Metadata__mdt
        */  
        public static list<SB_Clone_Quote_Metadata__mdt> createCloneQuoteMapping(){

            list<SB_Clone_Quote_Metadata__mdt> cloneList = new list<SB_Clone_Quote_Metadata__mdt>();    
            SB_Clone_Quote_Metadata__mdt cloneData;
            
            cloneData = new SB_Clone_Quote_Metadata__mdt(MasterLabel='Quote Line Mapping',DeveloperName = 'Quote_Line_Mapping', Field_Names__c = 'Ramp_Label__c,SBQQ__Number__c,SBQQ__RequiredBy__c,Is_Ramped__c,Show_Ramp__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Quantity__c,Edition_Quantity__c,SBQQ__OptionLevel__c,SBQQ__Quote__c,SBQQ__Product__c,SBQQ__ProductSubscriptionType__c,SBQQ__SubscriptionType__c,SBQQ__PricebookEntryId__c,AdditionalDiscountUnit__c,SBQQ__Description__c,SBQQ__RequiredBy__r.SBQQ__Product__c,SBQQ__ProductOption__c,SBQQ__DynamicOptionId__c,SBQQ__OptionType__c,Last_Ramp_Quantity__c,Re_Ramped__c,SBQQ__RenewedSubscription__c,SBQQ__UpgradedSubscription__c,SBQQ__Existing__c,SBQQ__PriorQuantity__c', Object_Name__c = 'SBQQ__QuoteLine__c');
            cloneList.add(cloneData);
            
            cloneData = new SB_Clone_Quote_Metadata__mdt(MasterLabel='Quote Mapping',DeveloperName = 'Quote_Mapping', Field_Names__c = 'SBQQ__Account__c,SBQQ__Opportunity2__c,Proposal_Name__c,Price_List__c,SBQQ__Partner__c,SBQQ__Distributor__c,Area_VP__c,Bill_to__c,GEO_VP__c,Partner_Program__c,Regional_VP__c,SBQQ__EndDate__c,SBQQ__ExpirationDate__c,SBQQ__PaymentTerms__c,SBQQ__PriceBook__c,SBQQ__StartDate__c,SBQQ__SubscriptionTerm__c,RampQuote__c,SBQQ__MasterContract__c,Special_Terms__c,SBQQ__Type__c,Auto_Generated_Quote__c,RecordTypeId', Object_Name__c = 'SBQQ__Quote__c');
            cloneList.add(cloneData);
            return cloneList;
        }
}