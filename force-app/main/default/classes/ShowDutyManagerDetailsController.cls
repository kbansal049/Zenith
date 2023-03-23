/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* ShowDutyManagerDetailsController
* @description - This class works as Controller for Aura Component - showDutyManagerDetails.cmp
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Bhagyalaxmi Deshmukh
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-01-24
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class ShowDutyManagerDetailsController {
    static final String APEX_CLASS_NAME = 'ShowDutyManagerDetailsController';

    /**
     * This method is used to get details of Duty Manager 
     * @param  recordId Case Id
     */
    @AuraEnabled
    public static List<objWrapper> getDetails(Id recordId){
        final String METHOD_NAME = 'getDetails';
        List<objWrapper> objList = new List<objWrapper>();        
        try{            
            if(String.isNotBlank(recordId)){
            
                String segmentForCase = GCSCommonConstants.EMPTY_STRING;
                String customerSegment = GCSCommonConstants.EMPTY_STRING;
                List<String> nonZpaProducts = new List<String>();                
                Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();

                //Case            
                Case caseObj = [SELECT Id, Product_New__c, IsEscalated, Customer_Segment__c FROM Case WHERE Id = :recordId];
                                        
                //Time Conversion
                Timezone pstTz = Timezone.getTimeZone(GCSCommonConstants.AMERICA_LA_TIME_ZONE);
                DateTime currentTimePst = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000));
                Time timeNowPst = currentTimePst.timeGMT();

                //Non-ZPA Products
                if(String.isNotBlank(Label.Non_ZPA_Products)){
                    nonZpaProducts = Label.Non_ZPA_Products.trim().split(GCSCommonConstants.COMMA_STRING);
                }

                segmentForCase = caseObj.Customer_Segment__c;
                if(String.isBlank(segmentForCase)){
                    segmentForCase = GCSCommonConstants.CASE_CUSTOMER_SEGMENT_PLATINUM;
                }
                customerSegment = psesupportmap != null && psesupportmap.containsKey(segmentForCase) 
                                    ? psesupportmap.get(segmentForCase).Primary_Support__c 
                                    : GCSCommonConstants.EMPTY_STRING;

                //Check for On Duty Duty Manager 
                for(Shift shiftObj : [SELECT Id, Duty_Manager__r.Name, Duty_Manager__r.Email, Backup_Duty_Manager__r.Name, 
                                        Duty_Manager__c, Backup_Duty_Manager__c, Type__c, StartTime, EndTime,Product__c, Segment__c 
                                        FROM Shift 
                                        WHERE Type__c = :GCSCommonConstants.SHIFT_TYPE_DUTY_MANAGER]){

                    DateTime startTimePst = shiftObj.StartTime.addSeconds((pstTz.getOffset(Datetime.now())/1000));
                    Time startPst = startTimePst.timeGMT(); 
                    DateTime endTimePst = shiftObj.EndTime.addSeconds((pstTz.getOffset(Datetime.now())/1000));
                    Time endPst = endTimePst.timeGMT();

                    if((shiftObj.Type__c == GCSCommonConstants.SHIFT_TYPE_DUTY_MANAGER 
                        && timeNowPst >= startPst
                        && timeNowPst <= endPst
                        && (nonZpaProducts.contains(caseObj.Product_New__c) 
                            || caseObj.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA)) 
                        || Test.isRunningTest()){
                        if(shiftObj.Product__c == GCSCommonConstants.SHIFT_PRODUCT_ZPA 
                            && caseObj.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA){
                            objList.add(new objWrapper(shiftObj.Duty_Manager__r.Name,shiftObj.Backup_Duty_Manager__r.Name));
                            break;
                        }else if(shiftObj.Segment__c == customerSegment 
                            && nonZpaProducts.contains(caseObj.Product_New__c) 
                            && nonZpaProducts.contains(shiftObj.Product__c)){
                            objList.add(new objWrapper(shiftObj.Duty_Manager__r.Name,shiftObj.Backup_Duty_Manager__r.Name));
                            break;
                        }else if(shiftObj.Product__c == GCSCommonConstants.SHIFT_PRODUCT_ZIA_ZPA 
                            && (nonZpaProducts.contains(caseObj.Product_New__c) 
                                || caseObj.Product_New__c==GCSCommonConstants.CASE_PRODUCT_ZPA)){
                            objList.add(new objWrapper(shiftObj.Duty_Manager__r.Name,shiftObj.Backup_Duty_Manager__r.Name));
                            break;
                        }
                    }
                }
            }
          
        }Catch(Exception e){            
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
        return objList;
    }   
   
    /**
     * This method is used to check Escalation of case
     * @param  recordId Case Id
     */
    @AuraEnabled
    public static Boolean checkEscalation(Id recordId){
        final String METHOD_NAME = 'checkEscalation';
        Boolean isEscalated = false;
        try{
            Case caseObj = [SELECT Id, Product_New__c, IsEscalated, Customer_Segment__c FROM Case WHERE Id = :recordId];
            if(caseObj.IsEscalated){
                isEscalated = true;
            }
        }Catch(Exception e){            
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
        return isEscalated;
    }
    
    public class objWrapper{
        @AuraEnabled
        public String dutyManager;

        @AuraEnabled
        public String backupDutyManager;
        
        public objWrapper(String t, String to){
            dutyManager = t;
            backupDutyManager = to;
        }
    }
}