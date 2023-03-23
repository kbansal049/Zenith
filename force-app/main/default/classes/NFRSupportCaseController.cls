public class NFRSupportCaseController {
    Public String PRrecId{get; set;}
    Public String ZPAPRrecId{get; set;}
    Public String ZDXPRrecId{get; set;}
    Public String NFRrecId{get; set;}
    public string url{get{
        url = System.Url.getSalesforceBaseURL().toExternalForm();
        return url;
    } set;}
    Public List<Case> caseRec{get {
        //Provisioning_Request__c PRrec;
        Set<ID> PRID=new Set<Id>();
        if(PRrecId != null){
        	PRID.add([Select Id, Provisioning_Status__c From Provisioning_Request__c Where ID =: PRrecId ].Id);
        }
        else if(NFRrecId != null){
            For(Provisioning_Request__c pr : [Select Id, Provisioning_Status__c From Provisioning_Request__c Where NFR_Form_Link__c =: NFRrecId]){
                PRID.add(pr.ID);
            }
        }
        System.debug('PRID'+PRID);
        if(!PRID.isEmpty()){
        	caseRec = [Select Id, CaseNumber from Case where Provisioning_Request__c in :PRID];
        }
        System.debug('caseRec'+caseRec);
        /*else if(ZPAPRrecId != null){
        	caseRec = [Select Id, CaseNumber,Provisioning_Request__c from Case where Provisioning_Request__c = :ZPAPRrecId];
        }
        else if(ZDXPRrecId != null){
        	caseRec = [Select Id, CaseNumber,Provisioning_Request__c from Case where Provisioning_Request__c = :ZDXPRrecId];
        }*/
        return caseRec;
    } set;}

}