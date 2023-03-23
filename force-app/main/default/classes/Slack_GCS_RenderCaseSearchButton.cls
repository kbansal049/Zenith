public with sharing class Slack_GCS_RenderCaseSearchButton extends Slack.ActionDispatcher {

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

        public Slack.ModalView call() {
            return new Slack.ModalView.builder().viewReference(Slack.View.case_search_modal.get()).build();
        }
    }
}