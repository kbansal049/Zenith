public class CreateShiftInstance {
    
    @AuraEnabled
    public static PRExtWrapper allowPRExtensionOrNot(string ProvReqId){
        //Get loggedIn User Profile
        List<Profile> loggedInUserProflie = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String loggedInUserProflieName = loggedInUserProflie[0].Name;
        System.debug('CR# 4395 loggedInUserProflieName ' + loggedInUserProflieName);
        System.debug('CR# 4395 ProvReqId : ' + ProvReqId);
        PRExtWrapper prExtWrapperObj = new PRExtWrapper();
        if(ProvReqId != null){
            Provisioning_Request__c ProvReq = new Provisioning_Request__c();
            ProvReq = [SELECT Id,Name,
                       Organization_Domain__c,
                       Org_ID_with_cloud__c,
                       Decomm_Req_date__c,
                       Provisioning_Status__c,
                       Provisioning_Extension_Status__c,
                       Send_Initial_l__c,
                       SE__c,
                       Partner_Contact__c,
                       Primary_Eval_Contact__c,
                       RecordTypeId,
                       RecordType.Name,
                       Account__c,
                       Account__r.Amber_Road_Status__c,
                       Opportunity__c
                       FROM
                       Provisioning_Request__c
                       WHERE
                       Id =:ProvReqId 
                       LIMIT 1];
            System.debug('CR# 4395 ProvReq : ' + ProvReq);
            if(ProvReq.Opportunity__c != NULL && loggedInUserProflieName != 'System Administrator'){
                AmberRoadValidation.PRScreeningWrapper oppScreenStatus = AmberRoadValidation.checkPRComplianceStatusForOppotunity(ProvReq.Opportunity__c);
                if(!oppScreenStatus.isAccOrOppCompliant){
                    System.debug('CR# 4395 Inside Opportunity');
                    prExtWrapperObj.allowPRExt = oppScreenStatus.isAccOrOppCompliant;
                    prExtWrapperObj.nonCompliantAccountName = oppScreenStatus.nonCompliantAccountName;
                    prExtWrapperObj.nonCompliantAccountType = oppScreenStatus.nonCompliantAccountType;
                    prExtWrapperObj.prRecord = ProvReq;
                }else {
                    prExtWrapperObj.allowPRExt = TRUE;
                    prExtWrapperObj.prRecord = ProvReq;
                }                
            }else if (ProvReq.Account__c != NULL && loggedInUserProflieName != 'System Administrator'){
                AmberRoadValidation.PRScreeningWrapper accScreenStatus = AmberRoadValidation.checkPRComplianceStatusForAccount(ProvReq.Account__c);
                if(!accScreenStatus.isAccOrOppCompliant){
                    System.debug('CR# 4395 Inside Account');
                    prExtWrapperObj.allowPRExt = accScreenStatus.isAccOrOppCompliant;
                    prExtWrapperObj.nonCompliantAccountName = accScreenStatus.nonCompliantAccountName;
                    prExtWrapperObj.nonCompliantAccountType = accScreenStatus.nonCompliantAccountType;
                    prExtWrapperObj.prRecord = ProvReq;
                }else {
                    prExtWrapperObj.allowPRExt = TRUE;
                    prExtWrapperObj.prRecord = ProvReq;
                }                
            }else {
                prExtWrapperObj.allowPRExt = TRUE;
                prExtWrapperObj.prRecord = ProvReq;
            }            
        }
        System.debug('CR# 4395 prExtWrapperObj : ' + prExtWrapperObj);
        return prExtWrapperObj;
    }
    
    @AuraEnabled
    public static Provisioning_Request__c getProvisioningReqDetails(string ProvReqId){
        
        if(ProvReqId != null){
            Provisioning_Request__c ProvReq = new Provisioning_Request__c();
            ProvReq = [select    Id,Name,
                       Organization_Domain__c,
                       Org_ID_with_cloud__c,Decomm_Req_date__c,
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
    
    @AuraEnabled
    public static Map<string,string> DoNotPurge(string ProvReqId){ 
        Map<string,string> ResultMap = new Map<string,string>();
        if(ProvReqId != null){
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
                       Id =:ProvReqId limit 1];
            
            if(ProvReq.Provisioning_Status__c != 'To Be Purged'){
                ResultMap.put('Status','Error');
                ResultMap.put('Message','Provisioning Request Status has to be "To Be Purged"');
            }
            else if(ProvReq.Provisioning_Status__c == 'To Be Purged'){
                try{
                    ProvReq.id = ProvReqId;
                    ProvReq.Provisioning_Status__c= 'Decommissioned';
                    update ProvReq;
                    ResultMap.put('Status','Success');
                    ResultMap.put('Message','Updated Successfully');
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
    public static Map<string,string> ExtendZPAInteractive(string ProvReqId){
        Map<string,string> ResultMap = new Map<string,string>();
        if(ProvReqId != null){
            Provisioning_Request__c ProvReq = new Provisioning_Request__c();
            ProvReq = [select    Id,Name,
                       Organization_Domain__c,
                       Org_ID_with_cloud__c,
                       Provisioning_Status__c,
                       Send_Initial_l__c,
                       SE__c,
                       Partner_Contact__c,
                       Primary_Eval_Contact__c,
                       Is_ZPA_FeVa_Extended__c,
                       RecordTypeId,RecordType.Name,
                       Decomm_Req_date__c,
                       ZPA_FeVa_Extended_Date__c,
                       Provisioning_End_Date__c
                       from
                       Provisioning_Request__c
                       where
                       Id =:ProvReqId limit 1];
            
            if(ProvReq.Provisioning_Status__c == 'Decommissioned' || ProvReq.Is_ZPA_FeVa_Extended__c == true){
                ResultMap.put('Status','Error');
                ResultMap.put('Message','Either this request is Decommisioned or already extended once.');
            }
            else {
                try{
                    if(ProvReq.Provisioning_Status__c == 'Disabled'){
                        ProvReq.Provisioning_Status__c = 'Request Extension';
                    }
                    else{
                        ProvReq.Provisioning_Status__c = 'Extended';
                    }
                    ProvReq.Is_ZPA_FeVa_Extended__c = true;
                    ProvReq.ZPA_FeVa_Extended_Date__c = Date.Today();
                    ProvReq.Provisioning_End_Date__c = system.today().adddays(7);
                    ProvReq.Decomm_Req_date__c = null;
                    update ProvReq;
                    ResultMap.put('Status','Success');
                    ResultMap.put('Message','Updated Successfully');
                }catch(Exception ex){
                    ResultMap.put('Status','Error');
                    ResultMap.put('Message',ex.getMessage());
                }
            }
            return ResultMap;
        }
        return null;
    }
    
    public class PRExtWrapper{
        @AuraEnabled public Boolean allowPRExt;
        @AuraEnabled public String nonCompliantAccountName;
        @AuraEnabled public String nonCompliantAccountType;
        @AuraEnabled public Provisioning_Request__c prRecord;
    }
    
}