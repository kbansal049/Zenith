trigger FundClaimTrigger on PartnerFundClaim (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
	new FundClaimTriggerHandler().run();
}