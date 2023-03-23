global class AccountCloudUsageMonthlySch implements Schedulable{        
    global void execute(SchedulableContext SC){
    	AccountCloudUsageMonthlyBatch b = new AccountCloudUsageMonthlyBatch(new Set<Id>());
		Database.executeBatch(b);	    
    }
}