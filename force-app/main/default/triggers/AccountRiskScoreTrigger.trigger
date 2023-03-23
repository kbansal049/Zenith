/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AccountRiskScoreTrigger
* @description    This is the single AccountRiskScore Trigger where we call/control all AccountRiskScore logic
*				  
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Mahesh Tirumalaraju
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-12-06
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger AccountRiskScoreTrigger on Account_Risk_Score__c (before insert, 
                                                          before update, 
                                                          after insert, 
                                                          after update, 
                                                          before delete, 
                                                          after delete, 
                                                          after undelete) {
                                                              
                                                              new AccountRiskScoreTriggerHandler().run();
                                                              
                                                          }