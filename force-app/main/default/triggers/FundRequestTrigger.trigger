trigger FundRequestTrigger on PartnerFundRequest (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
	new FundRequestTriggerHandler().run();
}