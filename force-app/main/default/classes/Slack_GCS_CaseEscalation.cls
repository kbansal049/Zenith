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
public class Slack_GCS_CaseEscalation extends Slack.ActionDispatcher {
    static final String APEX_CLASS_NAME = 'Slack_GCS_CaseEscalation';
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        // the slack action handler should immediately be returned 
        return Slack.ActionHandler.updateModal(new Handler(parameters, context));
    }

    public class Handler implements Slack.ModalHandler {
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
                String caseNumber = String.valueOf(this.parameters.get('caseNumber'));
                if(Test.isRunningTest() && caseNumber == 'EXCEPTION'){
                    caseNumber = Null;
                }
                caseNumber = caseNumber.length() != 8 ? '0' + caseNumber : caseNumber;
                String escReason = String.valueOf(formData.get('Escalation_Reason__c'));
                Boolean escalationOnBehalf = false;
                String caseId = String.valueOf(this.parameters.get('caseId'));
                String defconCaseId = String.valueOf(this.parameters.get('defconCaseId'));
                String recordTypeName = String.valueOf(this.parameters.get('recordTypeName'));
                Boolean isEscalated = Boolean.valueOf(this.parameters.get('isEscalated'));
                String defconResp = GCSCommonConstants.EMPTY_STRING;
                if(recordTypeName == 'Support' && !isEscalated){
                    DefconEscalationController.IS_INVOKED_FROM_SLACK_SDK = true;
                    defconResp = DefconEscalationController.createDefcon(escReason, escalationOnBehalf, caseId);
                } else {
                    DefconReEscalationController.IS_INVOKED_FROM_SLACK_SDK = true;
                    defconResp = DefconReEscalationController.updateDefcon(escReason, defconCaseId);
                }

                if(defconResp == 'SUCCESS'){
                    //getting newly created/updated defcon record data
                    List<Case> defconCaseList = [SELECT caseNumber, Parent_Case_Number__c, Defcon_Level__c FROM Case WHERE (parentId =: caseId AND recordType.DeveloperName ='Escalation') WITH SECURITY_ENFORCED LIMIT 1];
                    //sending a DM to escalated user 
                    Slack_GCS_CaseEscalation.postCaseMsg(defconCaseList[0].Parent_Case_Number__c, defconCaseList[0].caseNumber, this.context.getTeamId(), this.context.getUserId());
                    return Slack_Utilities.getMessageModalView('Escalated', new List<String>{'Your case *#'+ defconCaseList[0].Parent_Case_Number__c +'* is escalated successfully with defcon level #'+ defconCaseList[0]?.Defcon_Level__c +'. Here is the Escalation Number *#' + defconCaseList[0].caseNumber+'*.'});
                } else {
                    return Slack_Utilities.getMessageModalView('Error Occurred', new List<String>{'Error Code: *'+defconResp+'*, Unable to perform case Escalation.\n You might * NOT ELIGIBLE* to Re-Escalate, Check with Team for more info *#'+ caseNumber+'*.'});
                }
            } catch (Exception e) {
                GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                    GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
                
                return Slack_Utilities.getMessageModalView('Error Occurred', new List<String>{'There was a problem in defcon case escalation.\nError Info: '+e.getMessage()});
            }
        }
    }

    @future(callout=true)
    public static void postCaseMsg(String parentCaseNo, String defconCaseNumber, String teamId, String channelId) {
        final String METHOD_NAME = 'postCaseMsg';
        try{
            case parentCase = [SELECT Id, caseNumber, OwnerId, Escalation_Start_Time__c, Account_Name__c, Subject, Priority, Status, Case_Owner__c FROM Case WHERE CaseNumber = :parentCaseNo WITH SECURITY_ENFORCED];
            case defconCase = [SELECT Id, caseNumber, Defcon_Level__c, Status, Case_Owner__c, Escalation_Level__c, Escalation_Start_Time__c, Escalated_By__r.Name FROM Case WHERE caseNumber = :defconCaseNumber WITH SECURITY_ENFORCED];
            
            Slack.App app = Slack_Utilities.getCurrentOrgSlackApp();
            Slack.BotClient botClient = app.getBotClientForTeam(teamId);
            Slack.ViewReference viewRef = Slack.View.case_escalation_alert_message.get();
            viewRef.setParameter('caseNumber', parentCase.caseNumber);
            viewRef.setParameter('parentCaseLink', URL.getOrgDomainUrl().toExternalForm()+'/'+parentCase.Id);
            viewRef.setParameter('accName', parentCase.Account_Name__c);
            viewRef.setParameter('caseSubject', parentCase.Subject);
            viewRef.setParameter('casePriority', parentCase.Priority);
            viewRef.setParameter('caseStatus', parentCase.Status);
            viewRef.setParameter('caseOwner', parentCase.Case_Owner__c);
            viewRef.setParameter('defconCaseNumber', defconCase.caseNumber);
            viewRef.setParameter('defconCaseLink',  URL.getOrgDomainUrl().toExternalForm()+'/'+defconCase.Id);
            viewRef.setParameter('defconCaseLevel', defconCase.Defcon_Level__c);
            viewRef.setParameter('defconStatus', defconCase.Status);
            viewRef.setParameter('defconOwner', defconCase.Case_Owner__c);
            viewRef.setParameter('escalationLevel', defconCase.Escalation_Level__c);
            viewRef.setParameter('escalationDate', defconCase.Escalation_Start_Time__c?.format('yyyy-MM-dd\' \'hh:mm a'));
            viewRef.setParameter('escalatedBy', defconCase.Escalated_By__r.Name);
            system.debug('URL.getOrgDomainUrl().toExternalForm():'+URL.getOrgDomainUrl().toExternalForm());
            
            Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.builder()
                .channel(channelId)
                .text('Details for Case Number:#' + parentCase.caseNumber)
                .viewReference(viewRef)
                .build();

            Slack.ChatPostMessageResponse response = botClient.ChatPostMessage(req);
            String ts = response.getTs();
            System.debug('ts::: '+ ts + '\nMessage Post Response:'+response);
        } catch (Exception e) {
            Database.insert(
                GCSCommonUtility.prepareZscalerErrorLog(
                    APEX_CLASS_NAME, METHOD_NAME, defconCaseNumber, 
                    e.getStackTraceString(), String.valueOf(e), e.getTypeName()), false);
        }
    }
}