public class PRQuickActionController{
    
    @AuraEnabled
    public static Map<string,string> RequestDecommission(string PRid){
        system.debug('inside RequestDecommission method');
        Map<string,string> ResultMap = new Map<string,string>();
        if(PRid != null){
            Provisioning_Request__c ProvReq = new Provisioning_Request__c();
            ProvReq = [select    Id,Name,
                                 Organization_Domain__c,
                                 Org_ID_with_cloud__c,
                                 Provisioning_Status__c,
                                 Send_Initial_l__c,
                                 SE__c,
                                 Partner_Contact__c,
                                 Primary_Eval_Contact__c,
                                 RecordTypeId,RecordType.Name
                                 from
                                 Provisioning_Request__c
                                 where
                                 Id =:PRid limit 1];
            if(ProvReq.Provisioning_Status__c == 'Request Decommission' || ProvReq.Provisioning_Status__c== 'Decommissioned'){
                ResultMap.put('Status','Error');
                ResultMap.put('Message','Decommission was previously requested. This action cannot be performed.');
            }
                //if (confirm("Note that all traffic will stop forwarding and you should have a live conversation with the customer first. A decommissioned Eval can always be renabled at a later date with full configuration intact.\n\nAre you sure you want to decommission this Eval? ")) {
            
            else{
                try{
                    //ProvReq.id = PRid;
                    //ProvReq.Provisioning_Status__c= 'Request Decommission';
                    //update ProvReq;
                    //ResultMap.put('Status','Success');
                    //ResultMap.put('Message','Updated Successfully');
                    ResultMap.put('Status','Confirm');
                    ResultMap.put('Message','Are you sure you want to decommission this Eval?');
                }catch(Exception ex){
                    ResultMap.put('Status','Error');
                    ResultMap.put('Message',ex.getMessage());
                }
            }
            return ResultMap;
        }
        return null;
    }
    
    @AuraEnabled
    public static Provisioning_Request__c GetProvReqDetail(string ProvReqId){
        system.debug('inside GetProvReqDetail method');
        if(ProvReqId != null){
            Provisioning_Request__c ProvReq = new Provisioning_Request__c();
            ProvReq = [select Id,Name,
                                 Organization_Domain__c,
                                 Org_ID_with_cloud__c,
                                 Provisioning_Status__c,
                                 Send_Initial_l__c,
                                 SE__c,
                                 Partner_Contact__c,
                                 Primary_Eval_Contact__c,
                                 RecordTypeId,RecordType.Name
                                 from
                                 Provisioning_Request__c
                                 where
                                 Id =:ProvReqId limit 1];
           return ProvReq;
        }
        return null;
    }
    /*public static void booster(){
        integer i=1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }*/
}