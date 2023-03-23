/*****************************************************************************************
Name: TestDataFactory_ProductEngagement
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Product Engagement Records.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Ayush Kangar       21/02/2023      IBA-6552     
******************************************************************************************/
@isTest
public class TestDataFactory_ProductEngagement {
    public static List<Product_Engagement__c> createProductEngagement(Integer count, Boolean performDml,String oppId)
    {
        List<Product_Engagement__c> productEngagementList = new List<Product_Engagement__c>();
        for(Integer loopVar = 0; loopVar < count; loopVar++)
        {
            Product_Engagement__c pe = new Product_Engagement__c();
            pe.Opportunity__c = oppId;
            pe.Engagement_Type__c = 'Roadmap';
            pe.Product__c	 = 'ZDX';
            pe.Engagement_Stage__c = '1 - Discovery Workshop';
            pe.Timeframe_for_the_Engagement__c = 'This week';
            productEngagementList.add(pe);
        }
        if(performDml)
        {
            insert productEngagementList;
        }
        return productEngagementList;
    }
}