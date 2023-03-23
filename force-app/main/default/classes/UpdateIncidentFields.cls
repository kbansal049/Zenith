/**
 * Name : UpdateIncidentFields
 * Description : Update Reporting fields on Incidents
 * Test Class : 
 * Initial Author : Chetan Sunil Pednekar
 */
public class UpdateIncidentFields implements Queueable {
    private List<CaseRelatedIssue> CaseRelatedIssueList;
    
    public UpdateIncidentFields(List<CaseRelatedIssue> Caseidlist) {
        this.CaseRelatedIssueList = Caseidlist;
    }
    
    public void execute(QueueableContext context) {
        
        List<Zscaler_Error_Logs__c> zsErrorLogsList = new List<Zscaler_Error_Logs__c>();
        Set<Id> incidentIds=new Set<Id>(); 
        for(CaseRelatedIssue cri:CaseRelatedIssueList){
            if(cri.RelatedEntityType=='Incident'){
                incidentIds.add(cri.RelatedIssueId);
            }
        }
        //Top Customer Segments come from Custom Setting 
        Set<String> CaseTopCustomerstypeSet= new Set<String>();
        String CaseTopCustomerstype= ZscalerCustomSetting__c.getInstance('CaseTopCustomerstype')!=null && ZscalerCustomSetting__c.getInstance('CaseTopCustomerstype').Value__c!=null ? ZscalerCustomSetting__c.getInstance('CaseTopCustomerstype').Value__c:'Top100';
        CaseTopCustomerstypeSet.addall(CaseTopCustomerstype.split(','));
        //Map of Incidents    
        Map<id,Incident> incidentMap= new Map<id,Incident>([Select id,Total_ARR__c,of_Cases__c,of_Top_Customers__c,Median_Score__c FROM Incident where id IN :incidentIds AND RecordType.DeveloperName = 'Cloud_Incident']);     
        
        //system.debug('incidentMap  '+incidentMap);
        //Map of CaseRelatedIssue  
        Map<String, List<String>> incidentChildCaseMap = new Map<String, List<String>>();
        Set<Id> childCaseIds=new Set<Id>();
        Map<String, Case> caseMap = new Map<String,Case>();
        for(CaseRelatedIssue cri : [Select id,RelatedIssueId,CaseId from CaseRelatedIssue where RelatedIssueId IN :incidentMap.keySet()]) {
            if(!incidentChildCaseMap.containsKey(cri.RelatedIssueId)) {
                incidentChildCaseMap.put(cri.RelatedIssueId, new List<String>());
            }
            if(incidentChildCaseMap.containsKey(cri.RelatedIssueId)) {
                incidentChildCaseMap.get(cri.RelatedIssueId).add(cri.CaseId);
            }
            childCaseIds.add(cri.caseId);
        }
        for(Case c : [SELECT id,Customer_Score__c, Customer_Segment__c, Account.Current_ARR__c,AccountId FROM Case WHERE Id IN: childCaseIds]) {
            caseMap.put(c.id,c);
        }
        //system.debug('incidentChildCaseMap  '+incidentChildCaseMap);
        if(!incidentMap.isEmpty()) {
            for(Incident inc : incidentMap.values()) {
                decimal caseCount=0;
                decimal totalARR=0;
                decimal CustomerCount=0;
                decimal medianScore=0;
                decimal topCustomerCount=0;
                Set<String> uniqueAccounts = new Set<String>();
                if(incidentChildCaseMap.containsKey(inc.id)) {
                    for(String caseId :incidentChildCaseMap.get(inc.id)) {
                        if(caseMap.containsKey(caseId)) {
                            Case c = caseMap.get(caseId);
                            caseCount+=1;
                            if(c.customer_Score__c!=null){
                                medianScore+=c.Customer_Score__c;
                            }
                            if(!uniqueAccounts.contains(c.AccountId)) {
                                uniqueAccounts.add(c.AccountId);
                                if(c.Account.Current_ARR__c!=null){
                                    totalArr+=c.Account.Current_ARR__c;
                                }
                                if(CaseTopCustomerstypeSet.contains(c.Customer_Segment__c)){
                                    topCustomerCount+=1;
                                }
                            }
                        }
                    }
                }
                //Setting incident values
                inc.Total_ARR__c=totalArr;
                inc.of_Cases__c=caseCount;
                inc.of_Top_Customers__c=topCustomerCount;
                inc.Median_Score__c=medianScore;
            }
            //system.debug('incidentMap '+incidentMap);
            try {
                update incidentMap.values();
            } catch(Exception e) { 
                //Error handling
                Zscaler_Error_Logs__c logObj = new Zscaler_Error_Logs__c(
                    Class_Name__c = 'UpdateIncidentFields',
                    Method_Name__c = 'execute',
                    Error_in__c = 'Async Apex',
                    User__c  = UserInfo.getUserId(),
                    Biz_Area__c  = 'Service Cloud',
                    Exception_info__c = 'Error' + e
                );
                zsErrorLogsList.add(logObj);
            }
        }
        if(!zsErrorLogsList.isEmpty()){
            Database.SaveResult[] zsErrorLogsSaveResList = Database.insert(zsErrorLogsList,false);
        }
    }
}