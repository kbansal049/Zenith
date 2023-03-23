public class DeleteActionUpdateHandler {
    @InvocableMethod(label='Delete Action Plan Update')
    public static void updateActionPlan(){
        String formattedTime = System.now().format('EEE, yyyy-MM-dd HH:mm:ss','America/Los_Angeles');
        String dayOfWeek_currentTimeAgentTimeZone = formattedTime.split(',').get(0);
        System.debug('day is'+dayOfWeek_currentTimeAgentTimeZone);

        //Custom label separated by Semi-colon
        String dayToExecute = Label.Action_Plan_Delete_Days;
        List<String> dayslist = dayToExecute.split(';');
        System.debug('day list is'+dayslist);
        /*if(dayOfWeek_currentTimeAgentTimeZone == 'MON' || dayOfWeek_currentTimeAgentTimeZone == 'THU'){
            Database.executeBatch(new DeleteActionPlanBatch());
        }*/

        if((!dayslist.isEmpty() && dayslist.contains(dayOfWeek_currentTimeAgentTimeZone)) || Test.isRunningTest()){
            Database.executeBatch(new DeleteActionPlanBatch());
        }
    }
}