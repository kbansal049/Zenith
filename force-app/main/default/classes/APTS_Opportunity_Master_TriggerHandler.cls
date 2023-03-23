/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* OwnerCopyTriggerHandler
* @description    Merged code from APTS_Opportunity_Master_Trigger.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Mahesh T.
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        2021-09-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*  2022-05-03.   Karthik Pullagurla - Commenting out the code in before update method as Closed Lost button would capture churn loss 
                 and instantly update the stage of the opportunity
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class APTS_Opportunity_Master_TriggerHandler {

    private static APTS_Opportunity_Master_TriggerHandler instance;
    public static APTS_Opportunity_Master_TriggerHandler getInstance() {
        if (instance == NULL) {
            instance = new APTS_Opportunity_Master_TriggerHandler();
        }
        
        return instance;
    }
       
    private List<Opportunity> newOppList;
    public void setNewOppList(List<Opportunity> newOppList) {
        this.newOppList = newOppList;
    }
    private Map<Id,Opportunity> oldMap;
    public void setOldMap(Map<Id,Opportunity> oldMap) {
        this.oldMap = oldMap;
    }

    public void beforeUpdate(){
        //Integer countCHURN = [SELECT count() FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c IN: Trigger.new];
        Set<String> OppSubStageSet = new Set<String>();
        OppSubStageSet.add('Closed Lost');
        OppSubStageSet.add('Closed With No Decision');
        //if(!System.Label.System_Admin_Id.contains(UserInfo.getProfileId()) || Test.isRunningTest()){
        for(Opportunity opp : newOppList){
            /*if(opp.Stagename == Label.Stage_7_Closed_Lost && opp.Stagename != trigger.oldMap.get(opp.Id).Stagename && !String.isblank(opp.Validation_Stage__c) && opp.Validation_Stage__c != '6 - Technical Win'  && opp.Validation_Stage__c != '7 - Technical Loss' && opp.Validation_Stage__c != '8 - Not Required' && opp.Validation_Stage__c!='0 - Not Started' && opp.Validation_Stage__c!='8B - Not Required - Preferred'){
			opp.addError('Please choose the Technical Validation Stage value from "6 - Technical Win" or "7 - Technical Loss" or "8A - Not Required" or "8B - Not Required - Preferred"',false);
		}
		else */
            if(String.isNotBlank(opp.Sub_Stage__c)){
                /*if(!opp.Has_Technology_Partner__c && opp.Stagename != oldMap.get(opp.Id).Stagename && opp.Stagename == Label.Stage_7_Closed_Lost && System.Label.Stages_for_Loss_Form.contains(opp.Sub_Stage__c) && !System.FeatureManagement.checkPermission('Ops_Team_ByPass') && 
                   !System.Label.Profile_System_Administrator.contains(userInfo.getProfileId()) && System.Label.Profile_Finance_Id != userInfo.getProfileId() && System.Label.Profile_Core_Sales_DealDesk != opp.CurrentUserProfile__c && System.Label.Profile_Core_Sales_Sales_Ops != opp.CurrentUserProfile__c && 
                   (System.Label.Profile_Core_Sales_Renewals != opp.CurrentUserProfile__c || (System.Label.Profile_Core_Sales_Renewals == opp.CurrentUserProfile__c && opp.Split_Type__c == System.Label.Renewal_Upsell_Split))){
                       if(!Test.isRunningTest())
                           opp.addError(System.Label.Primary_Technology_Partner_Validation_Message);
                   }else if(!System.Label.Profile_System_Administrator.contains(userInfo.getProfileId()) && ((opp.Stagename == Label.Stage_7_Closed_Lost && System.Label.Stages_for_Loss_Form.contains(opp.Sub_Stage__c) && opp.isChurnpresent__c == false && opp.Stagename != oldMap.get(opp.Id).Stagename && System.Label.Skip_Churn_And_Loss != 'Yes' && !String.isblank(opp.Validation_Stage__c) && opp.Validation_Stage__c != '0 - Not Started') || (System.Label.Skip_Churn_And_Loss != 'Yes' && opp.isChurnpresent__c == false && opp.Stagename == Label.Stage_7_Closed_Lost && OppSubStageSet.contains(opp.Sub_Stage__c) && opp.Type=='Existing Customer (Renewal)') && opp.Stagename!= oldMap.get(opp.Id).Stagename)){
                       //if(!Test.isRunningTest()){
                                //Priyanka : CR# 1325 - Added params to URL to read them in VF page
                                //opp.addError('The opportunity cannot be set to closed set without completing the opportunity loss form. <a href=\''+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/OppLossReasonFormPage?oppId='+opp.Id+'&subStage='+opp.Sub_Stage__c+'&technicalValStage='+opp.Validation_Stage__c+'&userProfile='+opp.CurrentUserProfile__c+'&splitType='+opp.Split_Type__c+'\'>Click here</a> to complete the form.', false);
                                
                       			//CR# 2850 This alert is now rendered through a VF Page OppLossFormErrorAlert as 
                                //the errors are not working correctly in lightning
                                opp.Reason_form_check__c=true;
                                if(opp.Sub_Stage__c == 'Closed Lost'){
                                    opp.Render_Substage_churn_form__c = true;
                                }
                                else if (opp.Sub_Stage__c == 'Closed With No Decision'){
                                    opp.Render_Substage_churn_form__c = false;
                                }
                                opp.Stagename = oldMap.get(opp.Id).Stagename;
                                opp.Sub_Stage__c = oldMap.get(opp.Id).Sub_Stage__c;
                       			// Added by Ayush Kangar as part of CR# 3335 - Start
                       			opp.Forecast_Category__c = oldMap.get(opp.Id).Forecast_Category__c; 
                       			opp.AD_Forecast_Category__c = oldMap.get(opp.Id).AD_Forecast_Category__c; 
                       			opp.CRO_Forecast_Category__c = oldMap.get(opp.Id).CRO_Forecast_Category__c;
                       			opp.DM_Forecast_Category__c = oldMap.get(opp.Id).DM_Forecast_Category__c; 
                       			opp.VP_Forecast_Category__c = oldMap.get(opp.Id).VP_Forecast_Category__c; 
                       			opp.RVP_Forecast_Category__c = oldMap.get(opp.Id).RVP_Forecast_Category__c; 
                                // Added by Ayush Kangar as part of CR# 3335 - End
                            //}
                   } 
                //CR# 3382 START- Bikram 12th oct 2021
                else*/ if((opp.Stagename == Label.Stage_7_Closed_Lost && opp.Sub_Stage__c == 'Closed: Delete Duplicate') &&
                        (opp.Stagename != oldMap.get(opp.Id).Stagename &&
                         opp.Sub_Stage__c != oldMap.get(opp.Id).Sub_Stage__c)){
                             opp.is_Duplicate_Opportunity_Linked__c = TRUE;
                         }
                //CR# 3382 END- Bikram 12th oct 2021
            }
        }
        
    }
    
}