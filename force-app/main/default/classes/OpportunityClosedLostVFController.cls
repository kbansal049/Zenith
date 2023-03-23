// Commenting Deal_Reg_Teaming_Tech_Partner__c,Deal_Reg_Partner_Teaming_Tech_Partner__c as part of IBA-7556
public class OpportunityClosedLostVFController {
    Public String opptyrecId{get; set;}
    Public Boolean SourceCheck{get; set;}
    Public Boolean TeamingCheck{get; set;}
    Public Boolean PartnerTypeValue{get; set;}
    public string url{get{
        url = System.Url.getSalesforceBaseURL().toExternalForm();
        return url;
    } set;}
    Public Opportunity opptyrec{get {
        if(opptyrecId != null){
        opptyrec = [Select Id, AccountId,Account.Name,Name,Amount,Forecast_Type__c,OwnerId,Owner.Name,Primary_Reseller_Partner__r.Name,Deal_Reg_Type__c,Deal_Reg_Margin__c,Deal_Reg__r.Name,Deal_Reg_Margin__r.Name,
                    Deal_Reg_Partner_Teaming_Reseller__c,/*Deal_Reg_Partner_Teaming_Tech_Partner__c,Renewal_Deal_Reg_Partner__c,*/Deal_Reg__c,Deal_Reg_Teaming_Reseller__c,Deal_Reg_Partner_Teaming_Reseller__r.Name,
                    Deal_Reg_Teaming_Reseller__r.Name,/*Deal_Reg_Teaming_Tech_Partner__c,Renewal_Deal_Registration__c,*/Partner_Type__c/*,Deal_Reg_Partner_Teaming_Tech_Partner__r.Name,Deal_Reg_Teaming_Tech_Partner__r.Name*/,
                    /*Renewal_Deal_Reg_Partner__r.Name,Renewal_Deal_Registration__r.Name,*/Sub_Stage__c from Opportunity where Id = :opptyrecId];
        }
        if(opptyrec.Partner_Type__c=='Partner' && opptyrec.Sub_Stage__c == Label.SubStage_Closed_Delete_Duplicate){
            PartnerTypeValue = true;
        	if(opptyrec.Deal_Reg_Margin__c!=Null)
            	SourceCheck = true;
        	if(opptyrec.Deal_Reg_Partner_Teaming_Reseller__c!=Null)
            	TeamingCheck = true;
        }
        return opptyrec;
    } set;}
    Public Opportunity_Extension__c opptyExtrec{get {
        if(opptyrecId != null){
        //opptyExtrec = [Select Duplicate_Opportunity__r.Name,Duplicate_Opportunity__r.Partner_Type__c,Duplicate_Opportunity__r.Deal_Reg_Margin__c,Duplicate_Opportunity__r.Deal_Reg_Partner_Teaming_Reseller__c from Opportunity_Extension__c where Opportunity__c = :opptyrecId Limit 1];
            for(Opportunity_Extension__c opptyExtrec: [Select Duplicate_Opportunity__r.Name,Duplicate_Opportunity__r.Partner_Type__c,Duplicate_Opportunity__r.Deal_Reg_Margin__c,Duplicate_Opportunity__r.Deal_Reg_Partner_Teaming_Reseller__c from Opportunity_Extension__c where Opportunity__c = :opptyrecId Limit 1]){
                if(opptyExtrec.Duplicate_Opportunity__r.Partner_Type__c=='Partner'){
                    PartnerTypeValue = true;
                    if(opptyExtrec.Duplicate_Opportunity__r.Deal_Reg_Margin__c!=Null)
                        SourceCheck = true;
                    if(opptyExtrec.Duplicate_Opportunity__r.Deal_Reg_Partner_Teaming_Reseller__c!=Null)
                        TeamingCheck = true;
                }
                
                if(opptyExtrec.Duplicate_Opportunity__r.Deal_Reg_Margin__c==Null && opptyExtrec.Duplicate_Opportunity__r.Deal_Reg_Partner_Teaming_Reseller__c==Null){
                    SourceCheck = false;
                    TeamingCheck = false;
                    PartnerTypeValue = false;
                }
                this.opptyExtrec=opptyExtrec;
            }
            
        }
        //System.debug('opptyExtrec'+opptyExtrec);
        return opptyExtrec;
    } set;}

}