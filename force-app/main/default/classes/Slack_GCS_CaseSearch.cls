/**
* @File Name          : Slack_Utilities.cls
* @Description        : 
* @Author             : Rakesh Nayini
* @Group              : 
* @Last Modified By   : Rakesh Nayini
* @Last Modified On   : 11/17/2022
* @Modification Log   : 
*------------------------------------------------------------------------------
* Ver         Date                     Author                    Modification
*------------------------------------------------------------------------------
* 1.0       11/17/2022                 Rakesh Nayini           Initial Version
**/
public with sharing class Slack_GCS_CaseSearch extends Slack.ActionDispatcher {
    static final String APEX_CLASS_NAME = 'Slack_GCS_CaseSearch';

    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        // the slack action handler should immediately be returned 
        return Slack.ActionHandler.updateModal(new Handler(parameters, context));
    }

    public with sharing class Handler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler (Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call () {
            final String METHOD_NAME = 'call';
            try {
                Map <String, Object> formData = context.getFormData();
                String caseNumber = String.valueOf(formData.get('caseNumber'));
                if(Test.isRunningTest() && caseNumber=='EXCEPTION'){
                    caseNumber = Null;
                }
                caseNumber = caseNumber.length() != 8 ? '0' + caseNumber : caseNumber;
                List<Case> caseRecList = [SELECT Id, CaseNumber, ParentId, Status, recordType.DeveloperName, 
                                            Subject, isEscalated, Case_Owner__c, Account_Name__c, 
                                            Defcon_Level__c, Escalation_Owner__r.Name, Escalation_Reason__c  
                                            FROM Case 
                                            WHERE CaseNumber = :caseNumber 
                                                AND recordType.DeveloperName IN (:GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME, :GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME) 
                                            WITH SECURITY_ENFORCED LIMIT 1];
                if(!caseRecList.isEmpty()){
                    case caseRec = caseRecList[0];
                    if(caseRec.Status.contains('Closed')){
                        Slack.ViewReference viewRef = Slack.View.case_search_modal.get();
                        viewRef.setParameter('caseInputLabel','Case Closed. Please Re-Enter Case Number');
                        return new Slack.ModalView.builder().viewReference(viewRef).build();
                    }
                    
                    Case defconRecord;
                    Slack.ViewReference escViewRef = Slack.View.case_escalation_modal.get();
                    if(caseRec.isEscalated){
                        List<Case> defconCaseList = [SELECT Id, CaseNumber, ParentId, Defcon_Level__c, Escalation_Reason__c,
                                                        Escalation_Owner__r.Name FROM Case WHERE (parentId =: caseRec.Id AND recordType.DeveloperName ='Escalation') WITH SECURITY_ENFORCED LIMIT 1];
                        if(!defconCaseList.isEmpty()){
                            defconRecord = defconCaseList[0];
                        } else{
                            return Slack_Utilities.getMessageModalView('Error Occurred', new List<String>{'Unable to find Defcon for Case with isEscalated True for Case #'+caseNumber});
                        }
                    } else if(caseRec.recordType.DeveloperName == 'Escalation'){
                        defconRecord = caseRec;
                    }

                    if(defconRecord != null){
                        //handling Escaltion ability of user based on Profile
                        String eligibility = handleReEscalationEligibilty(defconRecord);
                        if(eligibility == 'ELIGIBLE'){
                            escViewRef = Slack.View.case_escalation_modal.get();
                        } else {
                            escViewRef = Slack.View.case_escalation_details_modal.get();
                        }
                        escViewRef.setParameter('defconCaseId', defconRecord.Id);
                        escViewRef.setParameter('caseId', defconRecord.ParentId);
                        escViewRef.setParameter('alreadyEscalated', ' `(Already Escalated)`');
                        escViewRef.setParameter('defconLevel', defconRecord.Defcon_Level__c);
                        escViewRef.setParameter('escalatationReason', defconRecord.Escalation_Reason__c);
                    } else {
                        escViewRef.setParameter('caseId', caseRec.Id);
                    }
                    escViewRef.setParameter('caseSubject', caseRec.Subject);
                    escViewRef.setParameter('caseNumber', caseRec.caseNumber);
                    escViewRef.setParameter('status', caseRec.Status);
                    escViewRef.setParameter('isEscalated', caseRec.isEscalated);
                    escViewRef.setParameter('owner', caseRec.Case_Owner__c);
                    escViewRef.setParameter('accName', caseRec.Account_Name__c);
                    escViewRef.setParameter('recordTypeName', caseRec.recordType.DeveloperName);
    
                    return new Slack.ModalView.builder().viewReference(escViewRef).build();
                
                } else {
                    Slack.ViewReference viewRef = Slack.View.case_search_modal.get();
                    viewRef.setParameter('caseInputLabel','Invalid Case Number. Please Re-Enter Case Number');
                    return new Slack.ModalView.builder().viewReference(viewRef).build();
                }    
                
            } catch (Exception e) {
                GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                    GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
                return Slack_Utilities.getMessageModalView('Error Occurred', new List<String>{'There was a problem in case escalation.\nError Info: '+e.getMessage()});
            }
        }

        public String handleReEscalationEligibilty(Case dcs){
            List<User> usrinfo = [SELECT Id, Level__c, Service_Level__c, Profile.name FROM User WHERE id = :UserInfo.getUserId() LIMIT 1];
            String result = 'VALIDATION';
            if(!usrinfo.isEmpty()){
                for(DEFCON_ReEscalation_Mapping__c dum : DEFCON_ReEscalation_Mapping__c.getAll().values()){
                    if((dum.Level__c != null 
                            && usrinfo[0].Level__c != null 
                            && dum.Level__c.contains(usrinfo[0].Level__c)) 
                        || (dum.Profile_Name__c != null 
                            && dum.Profile_Name__c.contains(usrinfo[0].Profile.Name))){
                        if(Integer.valueof(dcs.Defcon_Level__c) > Integer.valueof(dum.name)){
                            result = 'ELIGIBLE';
                        }else if(Integer.valueof(dcs.Defcon_Level__c) <= Integer.valueof(dum.name)){
                            result = 'NOTELIGIBLE';
                        }
                    }
                }
            }
            return result;
        }
    }
}