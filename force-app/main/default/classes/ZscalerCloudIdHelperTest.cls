@isTest
public class ZscalerCloudIdHelperTest {
    @isTest static void ProdOrgCheckbox(){
        Account acc1 = new Account(Name = 'Test Account3284',
                                   Type='Prospect',
                                   BillingCountry = '',
                                   BillingState = '',
                                   BillingPostalCode = '',
                                   Domain__c = '',
                                   Industry = '',
                                   Market_Segment__c = '');
        insert acc1;
        Account acc2 = new Account(Name = 'Test Account3284',
                                   Type='Prospect',
                                   BillingCountry = '',
                                   BillingState = '',
                                   BillingPostalCode = '',
                                   Domain__c = '',
                                   Industry = '',
                                   Market_Segment__c = '');
        insert acc2;
        
		insert new ZscalerCloudIdProgOrgChecbox__c(Name = 'beta');
        Product2 product1 = new Product2(ProductCode = 'ZIA-TRANS-EDITION', Name = 'Zscaler Internet Security Platform', Family = 'ZIA',
                                         IsActive = true);
        insert product1;
        
        Contract_Detail__c  contract1 = new Contract_Detail__c();
        contract1.Name = 'Test Contract1';
        contract1.Account_Name__c = acc1.Id;        
        contract1.Quantity__c = 10000;
        contract1.Contract_Detail_Status__c = 'Active';
        contract1.Product_Name__c = product1.Id;
        contract1.Do_not_Aggregate__c = false;
        contract1.Override_Contract_Detail_Status__c = false;
        contract1.Start_Date__c = Date.today().addDays(-90);
        contract1.End_Date__c = Date.today().addDays(100);
        contract1.Amount_USD__c = 50000.00;
        contract1.ZScaler_Product_Family__c = 'ZIA';
        contract1.Is_Bundle_SKU__c = true;
        insert contract1;
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        String rid = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZIA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926.beta',Account__c=acc1.Id,NS_Org_ID__c='Zscloud.net-3926.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-39262',Account__c=acc1.Id,NS_Org_ID__c='Zscloud.net-3922',Zscaler_Cloud_Domain__c='testacc.com.au.test2',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;
        
        ZDX_Cloud_Usage__c zdxCU = new ZDX_Cloud_Usage__c();
        zdxCU.Org_Name__c = 'Test Customer Org';
        zdxCU.External_ID__c = 'Zscloud.net-'+ Math.mod(Math.abs(Crypto.getRandomInteger()),4);
        zdxCU.Zscaler_Cloud_ID__c = ZSClIDlist[0].Id;
        zdxCU.cloud_id__c = 'Zscloud.net-39262';
        insert zdxCU;
        
        Cloud_Usage__c c1 = new Cloud_Usage__c(Zscaler_Cloud_ID__c = ZSClIDlist[0].Id,Account__c = acc1.Id,Total_Policy_Blocks__c = 200,Total_Transactions__c = 1000,Total_Transactions_Bandwidth__c = 10000,
                                               Total_Security_Blocks__c = 600,total_botnet_blocks__c = 300,total_malware_site_blocks__c   = 100,total_phishing_blocks__c = 200,total_ssl_bytes__c=50,
                                               total_ssl_transactions__c = 300,total_ssl_inspected_transactions__c = 150,Cloud_Usage_Type__c = 'ZIA');
        Insert C1;
        
        Monthly_Policy_Configurations__c mpc = new Monthly_Policy_Configurations__c(Name = 'Test',Zscaler_Cloud_ID__c = ZSClIDlist[0].Id, Account__c = acc1.Id, Parent_Location__c = 2);
        insert mpc;
        
        ZSClIDlist[0].Account__c=acc2.Id;
        ZSClIDlist[1].Account__c=acc2.Id;
        Update ZSClIDlist;
        For(Zscaler_Cloud_ID__c ZscalerIdList : [select id,Cloud_Type__c,Production_Org__c,Name,Account__c from Zscaler_Cloud_ID__c where Account__c =:acc1.id]){
            if(ZscalerIdList.Name == 'Zscloud.net-3926.beta'){
                System.assertEquals(false,ZscalerIdList.Production_Org__c);
            }
            if(ZscalerIdList.Name == 'Zscloud.net-39262'){
                System.assertEquals(true,ZscalerIdList.Production_Org__c);
            }
        }
    }
}