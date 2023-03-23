/*****************************************************************************************
Name: TestDataFactory_Project
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Project.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Ayush Kangar       25/01/2023      IBA-6050      update At_Risk_Action_Plan_Last_Updated__c when At_Risk_Action_Plan__c is updated on project record 
******************************************************************************************/
@isTest
public class TestDataFactory_Project {
    public static List<Inspire1__Project__c> prepareTestProject(Integer count, Boolean performDml)
    {
        List<Inspire1__Project__c> projects = new List<Inspire1__Project__c>();
        for(Integer loopVar = 0; loopVar < count; loopVar++)
        {
            Inspire1__Project__c p = new Inspire1__Project__c(); 
            p.Name = 'ZS Test Project '+loopVar;
            projects.add(p);
        }
        if(performDml)
        {
            insert projects;
        }
        return projects;
    }
}