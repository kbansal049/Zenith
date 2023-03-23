/**
 * Class Name : DefconFollowUpMilestoneUtility
 * Test Class Name : DefconFollowUpMilestoneUtilityTest
 * Description : Dynamically calculates the timer minutes for Follow Up SLA on a Defcon Case (Escalation Record Type) record
 */
global class DefconFollowUpMilestoneUtility implements Support.MilestoneTriggerTimeCalculator {   
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Case c = [SELECT Next_Update_Due__c FROM Case WHERE Id=:caseId];
        List<CaseMilestone> cmList = new List<CaseMilestone>([SELECT id,caseId,StartDate,targetDate 
                                                                FROM CaseMilestone 
                                                                WHERE MilestoneTypeId = :milestoneTypeId 
                                                                AND CaseId = :caseId
                                                                AND isCompleted = False 
                                                                AND isViolated = False]);
        Long longminutes;              
        if(!cmList.isEmpty()) {
            longminutes = (c.Next_Update_Due__c.getTime()/1000/60) - (cmList.get(0).StartDate.getTime()/1000/60);              
        }
        else {
            longminutes = (c.Next_Update_Due__c.getTime()/1000/60) - (System.Now().getTime()/1000/60);              
        }     
        Integer minutes = longminutes.intValue();
        return minutes;   
    }
}