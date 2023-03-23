global without sharing class ActionPlan_ClosedThisMeeting_OneDoc extends OneDoc.BaseTemplateDataProvider{
    global ActionPlan_ClosedThisMeeting_OneDoc() {
    }
    public override Object provide(Map<String, String> params) {   
        List<objWrapper> reslst = new List<objWrapper>();
        String CustomerId=[Select Id,Customer_Name__c from Meeting__c where Id = :params.get('Id')].Customer_Name__c;
        Integer i = 0;
        for(Action_Plan__c ap: [Select Id,CreatedDate,Status__c, Name, Case__c, Case__r.CaseNumber, Meeting__c, Meeting__r.Name, Project__c, Project__r.Name, Objective__c, Objective_Name__c, Customer__c,Customer__r.Name, Detail_TAM_Notes__c, Owner__c from Action_Plan__c where Status__c = 'Completed' and Customer__c = :CustomerId and Completion_Date__c=LAST_N_DAYS:14 and Visible_in_Doc__c = true order by CreatedDate desc]){
            reslst.add(new objWrapper(ap, ap.Status__c,ap.Owner__c,++i));
        }
        return JSON.serialize(reslst);
    }
    global class objWrapper{
        global Action_Plan__c ap;
        global String assignedTo;
        global String status;
        global Integer rowNum;
        global objWrapper(Action_Plan__c a, string t,string to,Integer i){
            ap = a;
            status=t;
            assignedTo=to;
            rowNum = i;
        }
    }
}