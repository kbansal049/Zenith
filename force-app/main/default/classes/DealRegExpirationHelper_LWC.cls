// Commenting Deal_Reg_Teaming_Tech_Partner__c as part of IBA-7556
public without sharing class DealRegExpirationHelper_LWC {
    @AuraEnabled
    public static String checkDealRegValidity(String dealRegId){
        String msg = '';
        List<Opportunity> opplst = [Select Id, Name, stagename, Account.Name, Amount, Primary_reseller_Partner__r.Name from Opportunity where stagename in (:Label.Stage_6_Closed_Won, :Label.Stage_5A_Opportunity, :Label.Stage_5B_Opportunity, :Label.Stage_5C_Opportunity) and (Deal_Reg__c = :dealRegId or Deal_Reg_Teaming_Reseller__c = :dealRegId /*or Deal_Reg_Teaming_Tech_Partner__c = :dealRegId*/)];
        if(!opplst.isEmpty()){
            msg = 'The Deal Reg is associated to an opprtunity which is already Closed Won! Expiration cannot be processed.<br/><ul>';
            for(Opportunity opp: opplst){
                msg += '<li><a target = "_blank" href="/'+ opp.Id + '">'+ opp.Name + '</a></li>';
            }
            msg += '</ul>';
        }
        return msg;
    }

    @AuraEnabled
    public static List<Opportunity> getOppsbeforeExpiration(String dealRegId){
        return [Select Id, Name, stagename, Account.Name, Amount, Primary_reseller_Partner__r.Name,Primary_reseller_Partner__c from Opportunity where stagename not in (:Label.Stage_6_Closed_Won, :Label.Stage_5A_Opportunity, :Label.Stage_5B_Opportunity, :Label.Stage_5C_Opportunity) and (Deal_Reg__c = :dealRegId or Deal_Reg_Teaming_Reseller__c = :dealRegId /*or Deal_Reg_Teaming_Tech_Partner__c = :dealRegId*/)];
    }

    @AuraEnabled
    public static string saveExpiration(String drtoExpire, String drtoConvert, String oppId, String expreason){
        /*TriggerUtility.skipOpportunityTrigger();
        List<Opportunity> opplst = new List<Opportunity>();
        for(Opportunity opp: [Select Id, Deal_Reg__c from Opportunity where stagename not in (:Label.Stage_6_Closed_Won, :Label.Stage_5_Contracts_Complete) and Deal_Reg__c = :drtoExpire]){
            if(oppId == null || oppId == '' || opp.Id != (Id)oppId){
                opp.Deal_Reg__c = null;
                opplst.add(opp);
            }
        }
        if(!opplst.isEmpty()){
            update opplst;
        }
        if(drtoConvert != null && drtoConvert != ''){
            DealRegConversionController ctrl = new DealRegConversionController();
            ctrl.dealRegId = drtoConvert;
            ctrl.selectedOppId = oppId;
            ctrl.reasonforExp = expreason;
            ctrl.dealReg = [Select Id, Name, Partner_Contact__c, Partner_Contact_Email__c,Account_Manager__c, AW_Partner_Intent__c, POV_Partner_Intent__c, Partner_Account_Program__c, Partner_Program__c, Partner_Category__c, End_Customer_Name__c , Partner_Role__c, Partner_Account__c, Estimated_Amount__c,Expected_Close_Date__c,
                                        Partner_Company_Name__c , Lead__c, Contact__c, Contact__r.AccountId, OwnerId, End_Customer_Domain__c, End_Customer_Street_Address__c, End_Customer_City__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Postal_Code__c  from Deal_Reg__c where ID =: drtoConvert];
            ctrl.associateDealToOpp();
        }else{
        }*/

        Deal_Reg__c rec = new Deal_Reg__c(Id = drtoExpire, Reason_for_Expiration__c = expreason, Expiration_Requested_By__c = UserInfo.getUserId(), Expiration_Requested_Date__c = System.now(), Status__c = Label.DR_Request_for_Expiration);
        TriggerUtility.dontThrowErrorForConvertedDR=true;
        update rec;
        TriggerUtility.dontThrowErrorForConvertedDR=false;

        //Submitting it to Expiration Approval
        String SalesOpsSystemAdminUser= ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID')!=null && ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID').Value__c:'00570000002GeGO';
        id sfAdminUser=id.valueof(SalesOpsSystemAdminUser);
        
        List<genericApprovalActionController.SubmitRecordWrapper> reqList = new List<genericApprovalActionController.SubmitRecordWrapper>();
        genericApprovalActionController.SubmitRecordWrapper ctrl = new genericApprovalActionController.SubmitRecordWrapper();
        ctrl.comment = Label.DR_Reason_for_DR_Expiry_Approval_Submission;
        ctrl.recordId = drtoExpire;
        ctrl.skipEntryCriteria = false;
        ctrl.submitterId = sfAdminUser;
        reqList.add(ctrl);
        
        try{
            genericApprovalActionController.submitRecord(reqList);
        }catch(exception e){
            System.debug('exception'+e);
        }
       
        return '/' + oppId;
    }
}