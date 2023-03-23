@isTest
public class EventCreateRoleTriggerTest {
	public static testMethod void testEvent(){
        
        Account a= new Account ();
        a.name='Test Account';
        insert a;
        
        Event e = new Event();
        e.WhatId=a.id;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        
        Test.startTest();  
			try
			{
				insert  e;       
			}
			catch(Exception ex)
			{
				Boolean expectedExceptionThrown =  ex.getMessage().contains('New Event Cannot be Created') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);                
			}
		Test.stopTest();  
    
    }
}