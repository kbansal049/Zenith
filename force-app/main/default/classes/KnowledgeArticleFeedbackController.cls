/**
 * @description       : This class will be used for Knowledge Article Feedback related actions
 * @author            : Ram Sangati
 * @last modified on  : 01-11-2023
 * @last modified by  : Ram Sangati
**/
public with sharing class KnowledgeArticleFeedbackController {
    static final String APEX_CLASS_NAME = 'KnowledgeArticleFeedbackController';
    /**
     * This method used to send an email notification when ever a feedback submitted for a knowledge article.
     * @param  kaId                 Knowledge Article Id
     * @param  kaUrlName            Knowledge Article UrlName
     * @param  feedbackCategory     Feed Category (Like/Nuetral/Dislike)
     * @param  feedbackType         Feedback Type (Comments/Suggetions (or) General Comments)
     * @param  feedbackComments     Additioanl Comments
     * @return                      Success (or) Failure
     */
    @AuraEnabled
    public static String sendKAFeedback(String kaId, String kaUrlName, 
        String feedbackCategory, String feedbackType, String feedbackComments) {
        final String METHOD_NAME = 'sendKAFeedback';
        try{
            KB__kav kb = null;
            if(String.isNotBlank(kaUrlName)){
                kb = KnowledgeArticleSelector.getKB(null, kaUrlName);
            }else if(String.isNotBlank(kaId)){
                kb = KnowledgeArticleSelector.getKB(kaId, null);
            }else{
                return 'No Record found.';
            }
        
            List<String> toAddresses = new List<String>();
            if(kb.Author__c != null && String.isNotBlank(kb.Author__r.Email)) {
                toAddresses.add(kb.Author__r.Email);
            }
            if(kb.Owner != null && String.isNotBlank(kb.Owner.Email)) {
                toAddresses.add(kb.Owner.Email);
            }
            if(kb.Technical_Reviewer__c != null && String.isNotBlank(kb.Technical_Reviewer__r.Email)) {
                toAddresses.add(kb.Technical_Reviewer__r.Email);
            }
            toAddresses.add(System.Label.Knowledge_Article_Feedback_Email_Distro);

            // sending an email for the feedback submitted knowledge article
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('Feedback for \"' + kb.Title + '\" knowledge article.');
            mail.setHtmlBody('Hello,<br/><br/>' 
                            + 'We have received a feedback for \"<a href=' + getFormattedSFUrl() + kb.Id +'/view>' 
                            + kb.Title + '</a>\" knowledge article. Please refer to the below for additional details: <br/>'
                            + '<br/>Feedback Category: ' + feedbackCategory 
                            + '<br/>Feedback Type: ' + feedbackType 
                            + '<br/>Comments: ' + feedbackComments 
                            + '<br/><br/>Thank you!');

            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            mailList.add(mail);
            List<Messaging.SendEmailResult> mailResultList = Messaging.sendEmail(mailList);
            GCSCommonUtility.logSendEmailError(mailResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            return 'Success';
        }catch(Exception ex){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
            return 'Fail';
        }
    }

    /**
     * This method will return the formatted SF URL which will be used to construct the record URL
     * @return   Formatted SF URL
     */
    private static String getFormattedSFUrl(){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String formatterBaseUrl = '';
        if(baseUrl.contains('my.site.com/customers')){
            formatterBaseUrl = baseUrl.replace('my.site.com', 'lightning.force.com/lightning/r/KB__kav/');
        }else{
            formatterBaseUrl = baseUrl + '/lightning/r/KB__kav/';
        }
        return formatterBaseUrl;
    }
}