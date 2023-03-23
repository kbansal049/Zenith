/*****************************************************************************************
Name: TestDataFactory_Task
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Tasks.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Digvijay Singh       10/02/2023      IBA-6527      Created class and added method to prepare test tasks
******************************************************************************************/
@isTest
public with sharing class TestDataFactory_Task {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6527 : to prepare test Task records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestTasks .
    * @param    NAME : String subject               : Task Subject .
    * @param    NAME : String status                : Task Status.
    * @param    Name : String priority              : Task priority.
    * @param    Name : String whatId                : Related Record Id.
    * @param    Name : String whoId                 : Related Lead/Contact Id.
    * @param    NAME : Integer numberOfRecords      : Number of records to prepare.
    * @return   TYPE : List<Task>                   : List of prepared task records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Task> prepareTestTasks(String status, String priority, String whatId, String whoId, Integer noOfRecords) {
        List<Task> testTasksList = new List<Task>();
        for (Integer count = 1; count <= noOfRecords; count++) {
            Task testTask = new Task();
            testTask.Subject = 'Test Task ' + count;
            testTask.Status = status;
            if (priority != null) {
                testTask.Priority = priority;
            }
            testTask.WhatId = whatid;
            testTask.WhoId = whoId;
            testTasksList.add(testTask);
        }
        return testTasksList;
    }
}