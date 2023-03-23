public class AutomaticStrikeCloseCaseBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('AutomaticStrikeCloseCaseBatch');
    List<Id> listCases=new List<Id>();
    List<Case> casesToUpdate=new List<Case>();
    Integer Strike1value=Integer.valueOf(System.Label.Strike1);
    Integer Strike2value=Integer.valueOf(System.Label.Strike2);
    Integer Strike3value=Integer.valueOf(System.Label.Strike3);
    String query;
    public AutomaticStrikeCloseCaseBatch(List<Id> listCases) {
        this.listCases=listCases;
        query = 'Select Id,Status,Resolution_Type__c,Pending_Customer_Time_Difference__c,Automatic_Strike_Tracking__c from Case where Id IN :listCases';
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Case> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        for(Case cs:scope){
            if(cs.Pending_Customer_Time_Difference__c==Strike3value){
                cs.Status='Closed';
                cs.Resolution_Type__c='Customer';
                cs.Automatic_Strike_Tracking__c='Third Strike Sent';
                cs.Create_New_Knowledge_Article__c='No Knowledge Association';
                cs.No_Knowledge_Article_Justification__c='This case is closed automatically by three strike policy.';
                cs.Days_since_last_activity__c=System.Now();
                casesToUpdate.add(cs);
            }
            if(cs.Pending_Customer_Time_Difference__c==Strike2value){
                cs.Automatic_Strike_Tracking__c='Second Strike Sent';
                cs.Days_since_last_activity__c=System.Now();
                casesToUpdate.add(cs);
            }  
            if(cs.Pending_Customer_Time_Difference__c==Strike1value){
                cs.Automatic_Strike_Tracking__c='First Strike Sent';
                cs.Days_since_last_activity__c=System.Now();
                casesToUpdate.add(cs);
            }         
        }
        Database.update(casesToUpdate,false);
    }
    public void finish(Database.BatchableContext BC) {
        /*
        Eventually I would love to keep track of failed batches
        */
        this.zb.callFinish(bc);
    }
}