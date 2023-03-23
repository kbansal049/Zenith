global class CaseCapacityMilestoneTimeTrigger implements Support.MilestoneTriggerTimeCalculator{
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Case cs = [select id, Priority from Case where Id=:caseId];
        Integer timeTrigger = 0;
        if(cs.Priority != null){
            if(cs.Priority == 'Urgent (P1)'){
                timeTrigger = Integer.valueOf(Label.Case_Capacity_Time_P1);
            }
            else if(cs.Priority == 'High (P2)'){
                timeTrigger = Integer.valueOf(Label.Case_Capacity_Time_P2);
            }
            else if(cs.Priority == 'Medium (P3)') {
                timeTrigger = Integer.valueOf(Label.Case_Capacity_Time_P3);
            }
            else if(cs.Priority == 'Low (P4)'){
                timeTrigger = Integer.valueOf(Label.Case_Capacity_Time_P4);
            }
        }
        return timeTrigger;
    }
}