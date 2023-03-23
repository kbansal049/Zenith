/*****************************************************************************************
Name: genericContactTrigger
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Genric trigger on contacts for all events.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            13-Nov-2015    Initial Development
2.0            Gurjinder Singh      11-Jun-2019    Changes as a part of Zscaler Cloud contact automation
3.0                                 9th Aug -2019   PatchRealign Check is added as a part of RBAC
4.0            Neeraj Kumar Singh   4th July 2020   Changes as per CR # 495
5.0            Satishakumar Awati   14th Dec 2022   Move Contact Trigger to New Trigger Framework
******************************************************************************************/

trigger genericContactTrigger on Contact (before insert, 
                                          before update, 
                                          after insert, 
                                          after update, 
                                          before delete, 
                                          after delete, 
                                          after undelete) {
                                              
	new ContactTriggerHandler().run();
}