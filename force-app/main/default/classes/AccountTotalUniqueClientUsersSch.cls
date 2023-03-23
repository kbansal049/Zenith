// Created by Harish for CR 1141

global class AccountTotalUniqueClientUsersSch implements Schedulable{        
    global void execute(SchedulableContext SC){
    	AccountTotalUniqueClientUsersBatch b = new AccountTotalUniqueClientUsersBatch(new Set<Id>());
		Database.executeBatch(b);	    
    }
}