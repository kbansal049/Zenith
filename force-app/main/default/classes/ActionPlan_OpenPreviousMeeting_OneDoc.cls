global without sharing class ActionPlan_OpenPreviousMeeting_OneDoc extends OneDoc.BaseTemplateDataProvider{
    global ActionPlan_OpenPreviousMeeting_OneDoc() {
    }
    public override Object provide(Map<String, String> params) {   
        List<objWrapper> reslst = new List<objWrapper>();
        Integer i = 0;
        //Added Visible_in_Doc__c by Swathi : CR#1476
        for(Action_Plan__c ap: [Select Id,CreatedDate,Status__c,Name, Case__c, Case__r.CaseNumber, Meeting__c, Meeting__r.Name, Project__c, Project__r.Name, Objective__c, Objective_Name__c, Customer__c, Customer__r.Name, Detail_TAM_Notes__c, Owner__c from Action_Plan__c where Status__c not in ('Completed', 'Cancelled') and Visible_in_Doc__c = true and Meeting__c != :params.get('Id') and Customer__c in (Select Customer_Name__c from Meeting__c where Id = :params.get('Id')) order by CreatedDate desc]){
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