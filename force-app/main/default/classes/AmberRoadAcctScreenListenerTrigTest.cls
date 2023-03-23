@isTest
public with sharing class AmberRoadAcctScreenListenerTrigTest {
    @isTest
    public static void runTest() {
        Test.startTest();
        //create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        List<Amber_Road_Screen_Account__e> amberRoadAccountScreenEvents = new List<Amber_Road_Screen_Account__e>();
        amberRoadAccountScreenEvents.add(new Amber_Road_Screen_Account__e(Account__c = JSON.serialize(testAccount)));
        List<Database.SaveResult> amberRoadAccountScreenResults = EventBus.publish(amberRoadAccountScreenEvents);         
        
        //debug results of amber road screening
        for(Database.SaveResult screenResult : amberRoadAccountScreenResults){
            if(screenResult.isSuccess()){
                System.debug('Successfully published AmberRoad account screening event.');
            }else{
                for(Database.Error err : screenResult.getErrors()) {
                    System.debug('AmberRoad Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }
        Test.stopTest();
    }
}