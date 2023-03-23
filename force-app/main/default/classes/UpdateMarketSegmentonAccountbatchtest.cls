@istest
public class UpdateMarketSegmentonAccountbatchtest{
@isTest static void testAccountExtMarketSegment()
    {
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        List<Market_Segmentation_Setting__c> mslist= new List<Market_Segmentation_Setting__c>();

        Market_Segmentation_Setting__c ms = new Market_Segmentation_Setting__c();
        ms.Name = '1';
        ms.Start_Range__c = 0;
        ms.End_Range__c = 249;
        ms.Is_EMEA_Region__c = false;
        ms.Market_Segmentation__c = 'SMB';
        mslist.add(ms);
        
        Market_Segmentation_Setting__c ms2 = new Market_Segmentation_Setting__c();
        ms2.Name = '2';
        ms2.Start_Range__c = 250;
        ms2.End_Range__c = 1249;
        ms2.Is_EMEA_Region__c = false;
        ms2.Market_Segmentation__c = 'Commercial';
        mslist.add(ms2);
        
        Market_Segmentation_Setting__c ms3 = new Market_Segmentation_Setting__c();
        ms3.Name = '3';
        ms3.Start_Range__c = 1250;
        ms3.End_Range__c = 5499;
        ms3.Is_EMEA_Region__c = false;
        ms3.Market_Segmentation__c = 'Enterprise';
        mslist.add(ms3);
        
        Market_Segmentation_Setting__c ms4 = new Market_Segmentation_Setting__c();
        ms4.Name = '4';
        ms4.Start_Range__c = 5500;
        ms4.End_Range__c = 39999;
        ms4.Is_EMEA_Region__c = false;
        ms4.Market_Segmentation__c = 'Large Enterprise';
        mslist.add(ms4);
        
        Market_Segmentation_Setting__c ms5 = new Market_Segmentation_Setting__c();
        ms5.Name = '5';
        ms5.Start_Range__c = 40000;
        ms5.End_Range__c = 1000000;
        ms5.Is_EMEA_Region__c = false;
        ms5.Market_Segmentation__c = 'Major';
        mslist.add(ms5);
        
        insert mslist;
        
        Skip_Triggers_User_Based__c st= new Skip_Triggers_User_Based__c();
        st.SetupOwnerId = UserInfo.getUserId();
        st.Object_s_to_skip__c='Account';
        insert st;
        List<Account> Acclist= new List<Account>();
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Account acc2 = TestDatafactory_Zscaler.insertAccount('Test Account2', null, 'Customer', null, null, null);
        Account acc3 = TestDatafactory_Zscaler.insertAccount('Test Account3', null, 'Customer', null, null, null);
        Account acc4 = TestDatafactory_Zscaler.insertAccount('Test Account4', null, 'Customer', null, null, null);
        //Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);
        //accExt.Customer_Success_Engagement__c='';
        // 
        //acc2.NumberOfEmployees=22;
        acc2.No_of_Employees_Users__c='0 - 99';
        acc3.No_of_Employees_Users__c='40000+';
        acc4.NumberOfEmployees=22;
        //acc3.No_of_Employees_Users__c='0-99';
        
        Acclist.add(acc2);
        Acclist.add(acc3);
        Acclist.add(acc4);
        update Acclist;

        Test.StartTest();        
        UpdateMarketSegmentonAccountbatch  btch= new UpdateMarketSegmentonAccountbatch ();
        database.executebatch(btch,5);
        Test.StopTest();        
        
    }

}