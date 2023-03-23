@isTest
public class UpdateMarketSegmentonLeadbatchtest {

    @isTest static void myTest() {
        
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
        
        TriggerUtility.UpdatingMarketsegmentforLeadsettrue();
        
        List<lead> NewLeadList= new List<lead>();
        
        Lead ld1= new lead(FirstName ='Test 1', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Pending Marketing Qualification',No_Employees_Users__c='0 - 99');
        NewLeadList.add(ld1);
        Lead ld2= new lead(FirstName ='Test 2', LastName = 'Lead', Company = 'Test Lead Company2', Status = 'Pending Marketing Qualification',NumberOfEmployees=55);
        NewLeadList.add(ld2);
        Lead ld3= new lead(FirstName ='Test 3', LastName = 'Lead', Company = 'Test Lead Company3', Status = 'Pending Marketing Qualification',NumberOfEmployees=null,No_Employees_Users__c=null);
        NewLeadList.add(ld3);
        Lead ld4= new lead(FirstName ='Test 1', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Pending Marketing Qualification',No_Employees_Users__c='40000+');
        NewLeadList.add(ld4);
        insert NewLeadList;
        
        UpdateMarketSegmentonLeadbatch btch1= new UpdateMarketSegmentonLeadbatch();
        Database.executeBatch(btch1,10);
    }    
}