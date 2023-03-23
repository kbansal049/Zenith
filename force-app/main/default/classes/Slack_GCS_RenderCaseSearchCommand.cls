public with sharing class Slack_GCS_RenderCaseSearchCommand extends Slack.SlashCommandDispatcher {

    public override Slack.ActionHandler invoke(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {
        return Slack.ActionHandler.modal(new Handler(parameters, context), 'Seach Case');
    }

    public class Handler implements Slack.ModalHandler {
 
        Slack.SlashCommandParameters parameters;
        Slack.RequestContext context;
 
        public Handler(Slack.SlashCommandParameters parameters, Slack.RequestContext context){
            this.parameters = parameters;
            this.context = context;
        }
 
        public Slack.ModalView call() {
            return new Slack.ModalView.builder().viewReference(Slack.View.case_search_modal.get()).build();
        }
    }
}