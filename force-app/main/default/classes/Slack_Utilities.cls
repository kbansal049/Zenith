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
global with sharing class Slack_Utilities {
    global static Slack.App app = getCurrentOrgSlackApp();
    global static Slack.BotClient botClient = null;
    global static Slack.ViewReference viewReference = null;
    global static Slack.ModalView modalView = null;
    global static String testOrgDomain = URL.getOrgDomainUrl().toExternalForm();
    
    global static Slack.BotClient getSlackBotClient(String teamId){
		botClient = app.getBotClientForTeam(teamId);		//Ex: 'T047KJENEC8'
        return botClient;
    }
    
    global static Slack.ChatPostMessageResponse sendMessage(Slack.BotClient botClient, 
                                                            Slack.ViewReference viewReference, 
                                                            String slackChannelId){
		Slack.ChatPostMessageRequest chatPostMsgReq = null;
        Slack.ChatPostMessageResponse chatPostMsgResp = null;

		chatPostMsgReq = new Slack.ChatPostMessageRequest.builder()
            .channel(slackChannelId)							//Ex: 'U046P96L278'
            .viewReference(viewReference)
            .build();
		System.debug('888(A) ==>>> chatPostMsgReq val is: '+chatPostMsgReq);
        chatPostMsgResp = botClient.ChatPostMessage(chatPostMsgReq);
		
        String ts = chatPostMsgResp.getTs();
        System.debug('ChatPostMessageResponse val is:'+chatPostMsgResp);
        System.debug('ts val is:'+ts);
        return chatPostMsgResp;
    }
    
    global static List<Slack.ChatPostMessageResponse> sendMessages(Slack.BotClient botClient, 
                                                                   List<Slack.ViewReference> viewReferenceList, 
                                                                   String slackChannelId){
        List<Slack.ChatPostMessageResponse> chatPostMsgRespList = new List<Slack.ChatPostMessageResponse>();
        for(Slack.ViewReference viewReference : viewReferenceList){
            Slack.ChatPostMessageResponse chatPostMsgResp = sendMessage(botClient, viewReference, slackChannelId);
            chatPostMsgRespList.add(chatPostMsgResp);
        }
        return chatPostMsgRespList;
	}
    
    global static List<Slack.ChatPostMessageResponse> sendMessages(Slack.BotClient botClient, 
                                                                   Map<String, List<Slack.ViewReference>> viewReferenceMap){
        List<Slack.ChatPostMessageResponse> chatPostMsgRespList = new List<Slack.ChatPostMessageResponse>();
            System.debug('666(A) ==>> In sendMessages(), viewReferenceMap.keySet() val is: '+viewReferenceMap.keySet());
            System.debug('666(B) ==>> viewReferenceMap val is: '+viewReferenceMap);
        for(String channelId : viewReferenceMap.keySet()){
            for(Slack.ViewReference viewReference : viewReferenceMap.get(channelId)){
                System.debug('777(A) ==>>> viewReference val is: '+viewReference);
                Slack.ChatPostMessageResponse chatPostMsgResp = sendMessage(botClient, viewReference, channelId);
                System.debug('777(B) ==>>> chatPostMsgResp val is: '+chatPostMsgResp);
                chatPostMsgRespList.add(chatPostMsgResp);
            }
        }
        return chatPostMsgRespList;
	}
    
    global static Slack.ModalView getMessageModalView(String title, List<String> messages) {
        if (!messages.isEmpty() && String.isNotBlank(title)) {
            String message;
            if (messages.size() == 1) {
                message = messages[0];
            } else {
                for (String msg : messages) {
                    if (String.isBlank(msg)) {
                        message = msg;
                    } else {
                        message += msg;
                    }
                }
            }

            viewReference = constructViewReference(title, message);
            modalView = new Slack.ModalView.builder().viewReference(viewReference).build();
        }
        return modalView;
    }

    global static Slack.ViewReference constructViewReference(String title, String message) {
        Slack.ViewReference viewReference = Slack.View.message_modal.get();
        viewReference.setParameter('title', title);
        viewReference.setParameter('message', message);
        return viewReference;
    }

    global static Slack.App getCurrentOrgSlackApp(){
        String orgDomain = Test.isRunningTest() ? Slack_Utilities.testOrgDomain : URL.getOrgDomainUrl().toExternalForm();
        if(orgDomain == System.Label.zs_production_sfdc_base_url 
			|| orgDomain == System.Label.zs_production_sfdc_old_base_url){
            app = Slack.App.PROD_SlackApp.get();
        }else if(orgDomain == System.Label.zs_stage_sbx_sfdc_base_url 
			|| orgDomain == System.Label.zs_stage_sbx_sfdc_old_base_url){
            app = Slack.App.STAGE_SlackApp.get();
        }else if(orgDomain == System.Label.zs_uat_sbx_sfdc_base_url 
			|| orgDomain == System.Label.zs_uat_sbx_sfdc_old_base_url){
            app = Slack.App.UAT_SlackApp.get();
        }else if(orgDomain == System.Label.zs_qa_sbx_sfdc_base_url 
			|| orgDomain == System.Label.zs_qa_sbx_sfdc_old_base_url){
            app = Slack.App.QA_SlackApp.get();
        }else if(orgDomain == System.Label.zs_sbdev36_sbx_sfdc_base_url 
			|| orgDomain == System.Label.zs_sbdev36_sbx_sfdc_old_base_url){
            app = Slack.App.SBDEV36_SlackApp.get();
        }else if(orgDomain == System.Label.zs_sbdev28_sbx_sfdc_base_url 
			|| orgDomain == System.Label.zs_sbdev28_sbx_sfdc_old_base_url){
            app = Slack.App.SBDEV28_SlackApp.get();
        }
        return app; 
    }
}