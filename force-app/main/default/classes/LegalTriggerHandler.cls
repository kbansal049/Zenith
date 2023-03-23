public class LegalTriggerHandler{
    public static void UpdateSalesOrder(List<Legal__c> LegalList){
        system.debug('inside UpdateSalesOrder');
        Set<String> ContractTypeSet= new Set<string>();
        ContractTypeSet.add('EUSA');
        ContractTypeSet.add('Customer MSA');
        for(Legal__c  legal: LegalList){
            system.debug('inside for loop '+legal);
            if(legal.Initial_Request_Date__c!=null && legal.Contract_Execution_Date__c==null){
                String tempstr= legal.Contract_Type__c;
                system.debug('tempstr  '+tempstr);
                for(String str:ContractTypeSet){
                    system.debug('str '+str);
                    if(tempstr.contains(str)){
                        legal.Create_Sales_Order__c=true;
                        break;
                    }else{
                        legal.Create_Sales_Order__c=false;
                    }
                }
            }else{
                legal.Create_Sales_Order__c=false;
            }
            
        }
    }
}