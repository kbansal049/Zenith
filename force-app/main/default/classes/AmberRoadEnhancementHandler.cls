/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* OwnerCopyTriggerHandler
* @description    Merged code from LinkOpportunityToPatch trigger.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Mahesh T.
* @modifiedBy     Mahesh T.
* @maintainedBy   Mahesh T.
* @version        1.0
* @created        2021-09-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class AmberRoadEnhancementHandler {
    
    private static AmberRoadEnhancementHandler instance;
    public static AmberRoadEnhancementHandler getInstance() {
        if (instance == NULL) {
            instance = new AmberRoadEnhancementHandler();
        }
        
        return instance;
    }
    
    private List<Id> relatedAccIdList;
    public void setRelatedAccIdList(Set<Id> relatedAccIdSet) {
        this.relatedAccIdList = new List<Id> ();
        this.relatedAccIdList.addAll(relatedAccIdSet);
    }
    
    
    public void process() {
        
        if (!relatedAccIdList.isEmpty()) {
            publishEvent();
        }
        
    }
    
    private void publishEvent() {
        if (!TriggerUtility.isOpportunityAccountsScreeningExecuted()) {
            for (Account accountToBeScreened : [SELECT Id, Amber_Road_Status__c, BillingPostalCode, BillingState, BillingCity, BillingCountry,
            	BillingStreet, Fax, Name, Phone, Type FROM Account WHERE Id IN :relatedAccIdList AND 
                Type in ('Prospect','Customer','Partner') AND
                (Amber_Road_Status__c = NULL OR Amber_Road_Status__c = 'Failed To Screen') AND Account.Geo__c != 'Public Sector']) { 
                //create and publish platform events for each account, each event contains a serialized acct and will initiate an acct screening from amber road
				List<Amber_Road_Screen_Account__e> amberRoadAccountScreenEvents = new List<Amber_Road_Screen_Account__e>();
                amberRoadAccountScreenEvents.add(new Amber_Road_Screen_Account__e(Account__c = JSON.serialize(accountToBeScreened)));
                List<Database.SaveResult> amberRoadAccountScreenResults = EventBus.publish(amberRoadAccountScreenEvents);         
                    
                //debug results of amber road screening
                for(Database.SaveResult screenResult : amberRoadAccountScreenResults){
                    if(screenResult.isSuccess()){
                        System.debug('Successfully published AmberRoad account screening event.');
                    } else {
                        for(Database.Error err : screenResult.getErrors()) {
                            System.debug('AmberRoad Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                        }
                    }
                }
            }
        }
    }
}