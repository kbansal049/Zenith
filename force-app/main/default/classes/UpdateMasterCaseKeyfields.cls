public class UpdateMasterCaseKeyfields implements Queueable {
    
    private List<id> CaseidList;
    
    public UpdateMasterCaseKeyfields(List<id> Caseidlist) {
        this.CaseidList = Caseidlist;
    }
   
    public void execute(QueueableContext context) {
        
        List<String> errorlst = new List<String>();
        List<String> successlst = new List<String>();  
        
        //Top Customer Segments come from Custom Setting 
        Set<String> CaseTopCustomerstypeSet= new Set<String>();
        String CaseTopCustomerstype= ZscalerCustomSetting__c.getInstance('CaseTopCustomerstype')!=null && ZscalerCustomSetting__c.getInstance('CaseTopCustomerstype').Value__c!=null ? ZscalerCustomSetting__c.getInstance('CaseTopCustomerstype').Value__c:'Top100';
        CaseTopCustomerstypeSet.addall(CaseTopCustomerstype.split(','));
            
        Id MasterCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Master_Case').getRecordTypeId();
        Map<id,Case> masterCaseMap= new Map<id,Case>([Select id,CaseNumber,Total_ARR__c,Customer_Segment__c,Customer_Score__c,Median_Score__c,of_Cases__c,of_Top_Customers__c,Share_with_Customer__c,Push_comment_to_child_cases__c FROM Case where id=:CaseidList and recordtypeid=:MasterCaseRT]);     

        system.debug('MasterCasemap  '+MasterCasemap);
        Map<String, List<Case>> masterChildCaseMap = new Map<String, List<Case>>();
        for(Case childCase : [Select id,Customer_Score__c,Median_Score__c,Master_Case__c,Accountid,Account.Current_ARR__c,Customer_Segment__c from Case where Master_Case__c=:CaseidList]) {
            if(!masterChildCaseMap.containsKey(childCase.Master_Case__c)) {
                masterChildCaseMap.put(childCase.Master_Case__c, new List<Case>());
            }
            masterChildCaseMap.get(childCase.Master_Case__c).add(childCase);
        }

        if(!masterCaseMap.isEmpty()) {
            //Changes by Ankit - IBA-800 Start
            for(Case master : MasterCasemap.values()) {
                decimal caseCount=0;
                decimal totalARR=0;
                decimal CustomerCount=0;
                decimal medianScore=0;
                decimal topCustomerCount=0;
                Set<String> uniqueAccounts = new Set<String>();
                if(masterChildCaseMap.containsKey(master.id)) {
                    for(Case child : masterChildCaseMap.get(master.id)) {
                        caseCount+=1;
                        if(child.customer_Score__c!=null){
                            medianScore+=child.Customer_Score__c;
                        }
                        if(!uniqueAccounts.contains(child.AccountId)) {
                            uniqueAccounts.add(child.AccountId);
                            if(child.Account.Current_ARR__c!=null){
                                totalArr+=child.Account.Current_ARR__c;
                            }
                            if(CaseTopCustomerstypeSet.contains(child.Customer_Segment__c)){
                                topCustomerCount+=1;
                            }
                        }
                    }
                }
                master.Total_ARR__c=totalArr;
                master.of_Cases__c=caseCount;
                master.of_Top_Customers__c=topCustomerCount;
                master.Median_Score__c=medianScore;
            }
            //Changes by Ankit - IBA-800 End   
            system.debug('masterCaseMap '+masterCaseMap);
            try{
                update masterCaseMap.values();
                successlst.add(masterCaseMap.values().Id);
            }catch(Exception e){ 
                errorlst.add('Exception on Master Case:' + masterCaseMap.values().Id + '. Exception is ' + e);
            }
        }
    }
}