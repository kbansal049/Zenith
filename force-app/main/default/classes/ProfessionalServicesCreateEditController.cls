//Test Class - PSCreateEditControllerTest
public class ProfessionalServicesCreateEditController {
    
    @AuraEnabled
    public static List<ColumnsWrapper> getColumnDetails(String fieldSetName, String objectAPIName){
        List<ColumnsWrapper> columnsWrapperList = new List<ColumnsWrapper>();
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(fieldSetName,objectAPIName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            system.debug('fieldSetMemberObj : ' + fieldSetMemberObj);
            system.debug('API Name : ' + fieldSetMemberObj.getFieldPath()); //api name
            system.debug('Label : ' + fieldSetMemberObj.getLabel());
            system.debug('Required : ' + fieldSetMemberObj.getRequired());
            system.debug('DbRequired : ' + fieldSetMemberObj.getDbRequired());
            system.debug('Type : ' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
            ColumnsWrapper columnsWrapperObj = new ColumnsWrapper();
            columnsWrapperObj.label = fieldSetMemberObj.getLabel();
            columnsWrapperObj.fieldName = fieldSetMemberObj.getFieldPath();
            columnsWrapperObj.type = String.valueOf(fieldSetMemberObj.getType());
            columnsWrapperObj.isRequired = fieldSetMemberObj.getDbRequired();
            columnsWrapperObj.isEarlyEngagementSelected = FALSE;
            
            if(fieldSetMemberObj.getFieldPath() == 'Name' || fieldSetMemberObj.getFieldPath() == 'Type__c'){
                columnsWrapperObj.isRequired = TRUE;
            }
            if(fieldSetMemberObj.getFieldPath() == 'Business_Benefit_Reason__c' ||
               /*fieldSetMemberObj.getFieldPath() == 'Describe_request_customer_expectation__c' ||*/
               fieldSetMemberObj.getFieldPath() == 'POC_POV_Completed__c'){
                columnsWrapperObj.isEarlyEngagementSelected = TRUE;
            }            
            columnsWrapperList.add(columnsWrapperObj);
        }
        return columnsWrapperList;
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
    
    @AuraEnabled
    public static ValidateEarlyEngagementWrapper validateEarlyEngagementRequest(String opportunityId){
        
        ValidateEarlyEngagementWrapper validateEarlyEngagementWrapperObj = new ValidateEarlyEngagementWrapper();
        Boolean isTCVGreaterThan12PercentOfOppAmount = FALSE;
        String returnStr = 'Valid';
        validateEarlyEngagementWrapperObj.status = 'Valid';
        validateEarlyEngagementWrapperObj.message = 'Valid';
        List<String> psSKUList = new List<String>();
        Decimal consolidatedTCVOfPSSKU = 0.0;
        Decimal oppAmountACV = 0.0;							//CR 4607
        Set<String> oppStageValueSet = new Set<String>();
        oppStageValueSet.add(Label.Stage_5A_Opportunity);
        oppStageValueSet.add(Label.Stage_5B_Opportunity);
        oppStageValueSet.add(Label.Stage_5C_Opportunity);
        oppStageValueSet.add(Label.Stage_5D_Opportunity);
        oppStageValueSet.add(Label.Stage_5_Contracts_Complete);
        if(String.isNotBlank(opportunityId)){
            
            Opportunity oppRecord = [SELECT Id, Amount, DAS_Package_New__c, 
                                     StageName, TCV__c, SBQQ__PrimaryQuote__c
                                     FROM Opportunity
                                     WHERE Id = : opportunityId];
            System.debug('oppRecord : ' + oppRecord);
            oppAmountACV = oppRecord.Amount != null ? oppRecord.Amount : 0;  //CR 4607
            
            if(String.isNotBlank(oppRecord.DAS_Package_New__c) && oppRecord.DAS_Package_New__c.contains(',')){
                psSKUList = oppRecord.DAS_Package_New__c.split(',');
            }else if(String.isNotBlank(oppRecord.DAS_Package_New__c) && !oppRecord.DAS_Package_New__c.contains(',')) {
                psSKUList.add(oppRecord.DAS_Package_New__c);
            }
            
            List<SBQQ__QuoteLine__c> quoteLineItemList = [SELECT ID,ACV__c,SBQQ__ProductName__c,SBQQ__ProductCode__c,
                                                          Product_Name_for_GSA__c,Product_Name_with_users__c 
                                                          FROM SBQQ__QuoteLine__c 
                                                          WHERE SBQQ__Quote__c = : oppRecord.SBQQ__PrimaryQuote__c AND
                                                          Product_Name_for_GSA__c IN : psSKUList];
            System.debug('quoteLineItemList : ' + quoteLineItemList);
            for(SBQQ__QuoteLine__c quoteLineItem : quoteLineItemList){
                consolidatedTCVOfPSSKU += quoteLineItem.ACV__c;
            }
            System.debug('consolidatedTCVOfPSSKU : ' + consolidatedTCVOfPSSKU);
            validateEarlyEngagementWrapperObj.consolidatedTCVOfPSSKU = consolidatedTCVOfPSSKU;
            
            //CR 4607 - Added by Arsh - excluding support/tam/training products from opportunity amount
            List<opportunitylineitem> oppLineItemList = [SELECT id, TotalPrice, Product2.Product_Category_Subtype__c FROM opportunitylineitem WHERE OpportunityId =: opportunityId AND Product2.Product_Category_Subtype__c IN ('Support', 'Training')];
            for(opportunitylineitem oli:oppLineItemList ){
                oppAmountACV -= oli.TotalPrice;
            }  
            System.debug('oppAmountACV: '+ oppAmountACV);
            //CR 4607 end - Added by Arsh
            
            isTCVGreaterThan12PercentOfOppAmount = consolidatedTCVOfPSSKU >= (0.125 * oppAmountACV) == TRUE ? TRUE : FALSE;   //CR 4607 - updated
            System.debug('isTCVGreaterThan12PercentOfOppAmount : ' + isTCVGreaterThan12PercentOfOppAmount);
            //Rejection Condition checks
            Boolean isPSSKUContainsESSorADV = FALSE;
            if(String.isNotBlank(oppRecord.DAS_Package_New__c) && !oppRecord.DAS_Package_New__c.contains(',')){
                if(oppRecord.DAS_Package_New__c.contains('ESS') || oppRecord.DAS_Package_New__c.contains('ADV')){
                    isPSSKUContainsESSorADV = TRUE;
                }
            }
            // IBA-1879 START
            // Commented below condition as we do not need to request the request
            // We will show warning popup for the following condition
            /*
            if(oppAmountACV < 350000 || String.isBlank(oppRecord.DAS_Package_New__c) || isPSSKUContainsESSorADV){
                returnStr = 'Reject';
                validateEarlyEngagementWrapperObj.status = 'Reject';
                if(oppAmountACV < 350000){                
                    validateEarlyEngagementWrapperObj.message = 'Opportunity Amount is less than 350K.';
                }else if(String.isBlank(oppRecord.DAS_Package_New__c)){
                    validateEarlyEngagementWrapperObj.message = 'PS SKU field is empty.';
                }else if(isPSSKUContainsESSorADV){
                    validateEarlyEngagementWrapperObj.message = 'Essential, Advance SKUs do not qualify for an Early Engagement.';
                }
            }
            */
            // IBA-1879 END

            //Warning condition checks
            // IBA-1879 START
            // Added condition to show warning popup if oppAmountACV < 350000 || String.isBlank(oppRecord.DAS_Package_New__c) || isPSSKUContainsESSorADV
            if((returnStr != 'Reject' || validateEarlyEngagementWrapperObj.status != 'Reject') && 
               (!(((oppRecord.StageName == Label.Stage_4_Economic_Buyer_Signoff && oppAmountACV > 750000) ||
                  (oppStageValueSet.contains(oppRecord.StageName) && oppAmountACV > 350000)) &&
                 isTCVGreaterThan12PercentOfOppAmount) || (oppAmountACV < 350000 || String.isBlank(oppRecord.DAS_Package_New__c) || isPSSKUContainsESSorADV))
              ){
                  returnStr = 'Warn';
                  validateEarlyEngagementWrapperObj.status = 'Warn';
                  if (oppAmountACV < 350000) {
                    validateEarlyEngagementWrapperObj.message = 'Please check if Opportuntity ACV > $350K';
                  } else if (String.isBlank(oppRecord.DAS_Package_New__c)) {
                      validateEarlyEngagementWrapperObj.message = 'Please check if PS SKU on Opportunity is not Blank';
                  } else if (isPSSKUContainsESSorADV) {
                      validateEarlyEngagementWrapperObj.message = 'Please check if PS SKU on Opportunity excludes the ZCES-DEP-ESS & ZCES-DEP-ADV';
                  } else if(!isTCVGreaterThan12PercentOfOppAmount){
                      validateEarlyEngagementWrapperObj.message = 'Please check if the Consolidated TCV(PS SKU) >= 12.5% of Opportunity ACV.';
                  }else if (!(oppRecord.StageName == Label.Stage_4_Economic_Buyer_Signoff && oppAmountACV > 750000)){
                      validateEarlyEngagementWrapperObj.message = 'Please check if Opportunity = Stage 4 and Opportunity ACV > $750K';
                  }else if (!(oppStageValueSet.contains(oppRecord.StageName) && oppAmountACV > 350000)){
                      validateEarlyEngagementWrapperObj.message = 'Please check if Opportunity = Stage 5 (A,B,C,D) and Opportunity ACV > $350K';
                  } else {
                      validateEarlyEngagementWrapperObj.message = 'Warn';
                  }                 
              }
        }
        return validateEarlyEngagementWrapperObj;
    }
    
    public class ColumnsWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isEarlyEngagementSelected;
        @AuraEnabled public String value;           //Added by Ayush Kangar as part of CR#4575 - Start
    }
    
    public class ErrorWrapper{
        @AuraEnabled public String status;
        @AuraEnabled public String message;
    }
    
    public class ValidateEarlyEngagementWrapper{
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public Decimal consolidatedTCVOfPSSKU = 0.0;
    }

    //Added by Ayush Kangar as part of CR#4575 - Start
    @AuraEnabled()
    public static AccIdOppWrapper FetchAcountNameFromOpportunity(Id opportunityId){
        AccIdOppWrapper obj = new AccIdOppWrapper();
        Opportunity oppRecord = [SELECT Id, Amount, DAS_Package_New__c, 
        StageName, TCV__c, SBQQ__PrimaryQuote__c,Account.Name
        FROM Opportunity
        WHERE Id = : opportunityId];
        obj.AccountNameFromOpp= 'Early Engagement - '+ oppRecord.Account.Name;
        system.debug('test'+obj.AccountNameFromOpp);
        return obj;
    }

    public class AccIdOppWrapper{
        @AuraEnabled public String AccountNameFromOpp;
    }
    //Added by Ayush Kangar as part of CR#4575 - End
}