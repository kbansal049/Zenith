@isTest(seeAllData = false)
public class OpportunityClosedLostVFControllerTest {
@TestSetup static void setuprecs(){
        Account acc = new Account(name='testaccount1234567',Type='Partner');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'test opp1234567', AccountId = acc.Id, StageName = label.Stage_7_Closed_Lost , Sub_Stage__c = Label.SubStage_Closed_Delete_Duplicate/*'Qualified'*/, CloseDate = Date.Today(),
                                         Deal_Reg_Margin__c = acc.Id,Deal_Reg_Partner_Teaming_Reseller__c = acc.Id);
        insert opp;
        Opportunity opp1 = new Opportunity(Name = 'testing opp1234567999', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'Qualified'*/, CloseDate = Date.Today(),
                                         Deal_Reg_Margin__c = acc.Id,Deal_Reg_Partner_Teaming_Reseller__c = acc.Id);
        insert opp1;
        Opportunity_Extension__c oppExtRecord = new Opportunity_Extension__c
            (
                Opportunity__c = opp.Id,
                Duplicate_Opportunity__c = opp1.Id
        	);
        insert oppExtRecord;
    }
    static testmethod void testopplineitemctrl(){
        Account acc = [Select Id from Account where Name='testaccount1234567'];
        Opportunity opp = [Select Id from Opportunity where Name='test opp1234567'];
        OpportunityClosedLostVFController ctrl = new OpportunityClosedLostVFController();
        System.debug(ctrl.url);
        //if(!opp.isEmpty()){
            ctrl.opptyrecId = opp.Id;
            System.debug(ctrl.opptyrec);
            System.debug(ctrl.opptyExtrec);
        //}
    }
    static testmethod void testopplineitemctrl1(){
        Account acc = [Select Id from Account where Name='testaccount1234567'];
        List<Opportunity> opp = [Select Id from Opportunity where Name='testing opp1234567999' or Name='test opp1234567'];
        for(Opportunity_Extension__c EXT : [Select Id,Duplicate_Opportunity__c from Opportunity_Extension__c where Opportunity__r.Name='testing opp1234567999']){
        	EXT.Duplicate_Opportunity__c = opp[1].Id;
        }
        OpportunityClosedLostVFController ctrl = new OpportunityClosedLostVFController();
        System.debug(ctrl.url);
        //if(!opp.isEmpty()){
            ctrl.opptyrecId = opp[0].Id;
            System.debug(ctrl.opptyrec);
            System.debug(ctrl.opptyExtrec);
        //}
    }
}