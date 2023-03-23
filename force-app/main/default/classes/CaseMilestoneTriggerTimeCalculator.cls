global class CaseMilestoneTriggerTimeCalculator implements Support.MilestoneTriggerTimeCalculator{
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer returnValue = 0;
        Map<String, List<Integer>> mapOfSlotAndHour = new Map<String, List<Integer>>();
        Case cs = [select id, Contact_Time_Slot__c, Preferred_Contact_Time_Zone__c from Case where Id=:caseId];
        if(cs.Contact_Time_SLot__c != null){
            List<TAC_Time_Slot_Hour_Mapping__mdt> timeSlotMapping = TAC_Time_Slot_Hour_Mapping__mdt.getAll().values();
            for(TAC_Time_Slot_Hour_Mapping__mdt tsl : timeSlotMapping){
                List<Integer> hoursList = new List<Integer>();
                hoursList.add(Integer.valueOf(tsl.Start_Hour__c));
                hoursList.add(Integer.valueOf(tsl.End_Hour__c));
                mapOfSlotAndHour.put(tsl.Contact_Time_Slot__c, hoursList);
            }
            String formattedTime = System.now().format('EEE, yyyy-MM-dd HH:mm:ss',cs.Preferred_Contact_Time_Zone__c);
            List<String> splitTime = formattedTime.split(' ');
            String timePart = splitTime[2].trim();
            List<String> timeSplitList = timePart.split(':');
            Integer hourNow = Integer.valueOf(timeSplitList[0].trim());
            Integer minuteNow = Integer.valueOf(timeSplitList[1].trim());

            Integer startHour = Integer.valueOf(mapOfSlotAndHour.get(cs.Contact_Time_Slot__c)[0]);
            Integer endHour = Integer.valueOf(mapOfSlotAndHour.get(cs.Contact_Time_Slot__c)[1]);

            Integer oneLaterStartHour = startHour + 1;
            if(oneLaterStartHour>hourNow){
                Integer hourLeft = oneLaterStartHour - hourNow;
                Integer totalMinutesLeft = (hourLeft*60) - minuteNow;
                returnValue = totalMinutesLeft;
            }
            else if(oneLaterStartHour<=hourNow){
                Integer hourLeft = (24-hourNow) + oneLaterStartHour;
                Integer totalMinutesLeft = (hourLeft*60) - minuteNow;
                returnValue = totalMinutesLeft;
            }
        }
        return returnValue;
    }

}