global class APTS_TestUtil {

   public static Account createAccount () {
        Account acc = new Account ();
        acc.Name = 'Test Account';
        acc.APTS_Platform_Subscription_End_Date__c = Date.today();
        insert acc;
        return acc;
    }

	public static opportunity createOpportunity (string accountId,string pricelistId) {
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.StageName = Label.Stage_1_Alignment;
        opp.closedate =  Date.today();
        opp.accountId = accountId;
        //opp.Price_List__c = pricelistId;
        opp.type ='Existing Customer (Renewal)';
        insert opp;
        return opp;
    }

    public static List<product2> createProducts(Integer pcount) {
        List<product2> testProducts = new List<product2>();
        for(Integer i = 0; i < pcount; i++){
            product2 tp = new product2();
            tp.Name = 'test product '+i;
            tp.ProductCode = 'ZSEC-SKU'+i;
            tp.Family = 'Zscaler Products';
            tp.IsActive = true;
            tp.AW__c = true;
            tp.PS_Deal_Reg__c = true;
            tp.Deployment_Margin__c = true;
            tp.Fulfilment_Margin__c = true;
            tp.POV__c = true;
            tp.APTS_Allow_Deal_Reg__c = true;
            tp.APTS_Allow_New_Logo__c = true;
            tp.APTS_Allow_Partner_Discount__c = true;
            tp.Partner_Discount_Category__c = 'A';
            testProducts.add(tp);
        }
        insert testProducts;
        return testProducts;
    }
}