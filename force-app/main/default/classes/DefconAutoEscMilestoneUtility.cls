/**
 * @description       : Dynamically calculates the timer minutes for Auto Escalation SLA on a Defcon Case
 * Test Class Name    : DefconAutoEscMilestoneUtilityTest
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-04-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class DefconAutoEscMilestoneUtility implements Support.MilestoneTriggerTimeCalculator {
    global Integer calculateMilestoneTriggerTime(String defconId, String milestoneTypeId){
        Integer minutes = 0;
        Map<String, Map<String, Decimal>> autoSLAConfigMap = new Map<String, Map<String, Decimal>>();
        for(Defcon_Auto_Esc_SLA_Configurations__mdt meta : [SELECT id, defcon_Level__c, Escalation_Level__c, SLA_Minutes__c
                                                                FROM Defcon_Auto_Esc_SLA_Configurations__mdt]) {
            if(!autoSLAConfigMap.containsKey(meta.defcon_level__c)) {
                autoSLAConfigMap.put(meta.defcon_Level__c, new Map<String, Decimal>());
            }
            autoSLAConfigMap.get(meta.defcon_level__c).put(meta.Escalation_Level__c, meta.SLA_Minutes__c);
        }
        if(!autoSLAConfigMap.isEmpty()) {
            Case c = [SELECT caseNumber,id, Defcon_Level__c, Escalation_Level__c, Auto_Esc_SLA_Level_0_Cumulative_Time__c, Auto_Esc_SLA_Level_1_Cumulative_Time__c, Auto_Esc_SLA_Level_2_Cumulative_Time__c
                        FROM Case WHERE RecordType.DeveloperName = 'Escalation' AND Id =: defconId];
            if(autoSLAConfigMap.containsKey(c.Defcon_Level__c) && (autoSLAConfigMap.get(c.Defcon_Level__c) != null && autoSLAConfigMap.get(c.Defcon_Level__c).containsKey(c.Escalation_Level__c))) {
                Decimal totalTime = autoSLAConfigMap.get(c.Defcon_Level__c).get(c.Escalation_Level__c);
                Long longminutes;
                if(c.Escalation_Level__c == 'Level 0') {
                    longminutes = totalTime.longValue() - (c.Auto_Esc_SLA_Level_0_Cumulative_Time__c.longValue()/60);
                }
                else if(c.Escalation_Level__c == 'Level 1') {
                    longminutes = totalTime.longValue() - (c.Auto_Esc_SLA_Level_1_Cumulative_Time__c.longValue()/60);
                }
                else if(c.Escalation_Level__c == 'Level 2') {
                    longminutes = totalTime.longValue() - (c.Auto_Esc_SLA_Level_2_Cumulative_Time__c.longValue()/60);
                }
                minutes = longminutes.intValue();
            }
        }
        return minutes;
    }
}