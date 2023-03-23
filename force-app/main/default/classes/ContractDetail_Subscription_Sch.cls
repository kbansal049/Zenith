global class ContractDetail_Subscription_Sch implements Schedulable{
	 global Date sd;
    global Date ed;
    
    global ContractDetail_Subscription_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        ContractDetail_Subscription_update batch;
        sd = Date.Today().addDays(-1);
        ed = Date.Today().addDays(-1);
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        String query = '';
        batch = new ContractDetail_Subscription_update(startdate,enddate,query);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
}