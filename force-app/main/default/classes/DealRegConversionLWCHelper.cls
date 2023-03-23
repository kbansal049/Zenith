/*****************************************************************************************
Name: DealRegConversionLWCHelper
Copyright © Zscaler
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            NA                      NA                Initial Development
2.0            Swathi                  7/26/2022         IBA - 1599
3.0            Ram S                   8/15/2022         Refactored the DealRegConversionController class to resolve too many SOQL : 101 error
******************************************************************************************/
public without sharing class DealRegConversionLWCHelper {
    @AuraEnabled
    public static DealRegConversionWrapper init(Id dealregtoconvert){
        System.debug('111 ==>>> DealRegConversionLWCHelper.init(), dealregtoconvert val is: '+dealregtoconvert);
        DealRegConversionWrapper wrp = null;
        if(dealregtoconvert != null){
        System.debug('222 ==>>> DealRegConversionLWCHelper.init(), dealregtoconvert val is: '+dealregtoconvert);
            DealRegConversionController.convertDealReg(dealregtoconvert);

            wrp = new DealRegConversionWrapper();
            wrp.convertedOppId = DealRegConversionController.convertedOppId;
            wrp.oppList = DealRegConversionController.oppWrapperList;
            wrp.dealReg = DealRegConversionController.dealReg;
            
            Set<String> conditionSet = new Set<String>();
            Map<String, Deal_Reg_Conversion_Matrix_Allow_Cases__c> mapConditions = Deal_Reg_Conversion_Matrix_Allow_Cases__c.getAll();
            for(Deal_Reg_Conversion_Matrix_Allow_Cases__c rec : mapConditions.values()){
                conditionSet.add(rec.Current_DR_Type__c 
                                     + rec.Current_DR_Partner_Type__c 
                                     + rec.Opportunity_Sourced_Type__c
                                     + rec.Opportunity_Sourced_Partner_Type__c 
                                     + rec.Teaming_Reseller_Type__c 
                                     + rec.Teaming_Reseller_Partner_Type__c 
                                     + rec.Teaming_Tech_Type__c 
                                     + rec.Teaming_Tech_Partner_Type__c);
            }
            wrp.conditionSet = conditionSet;
        }
        return wrp;
    }

    @AuraEnabled
    public static DealRegConversionWrapper convertDRtoOpportunity(String selectedOppId, String drId){
        DealRegConversionController.associateDealToOpp(selectedOppId, drId);
        
        DealRegConversionWrapper wrp = new DealRegConversionWrapper();
        wrp.oppList = null;
        wrp.convertedOppId = DealRegConversionController.convertedOppId;
        return wrp;
    }
    
    public class DealRegConversionWrapper{
        @AuraEnabled
        public String convertedOppId{get; set;}
        @AuraEnabled
        public Deal_Reg__c dealReg{get; set;}
        @AuraEnabled
        public Set<String> conditionSet{get; set;}
        @AuraEnabled
        public List<DealRegConversionController.OpportunityListWrapper> oppList{get; set;}
    }
    
	//Changes of IBA - 1599 - Start
    @AuraEnabled
    public static String uploadFiles(List<Map<String, Object>> files,Deal_Reg__c dealReg,String source,Boolean avpApprovalcheck){
        Boolean isSuccess = false;
        String returnmessage;
        List<ContentVersion> relatedDocuments = new List<ContentVersion>();
        for (Map<String, Object> file : files) {
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            ContentVersion contentVersionFile = new ContentVersion();
            contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
            contentVersionFile.Title = relatedDocument.Title;
            contentVersionFile.VersionData = relatedDocument.VersionData;
            contentVersionFile.Source_fileupload__c = 'AVPApprovalonDR';
            relatedDocuments.add(contentVersionFile);
        }
        Database.saveResult[] srFiles = Database.insert(relatedDocuments);
        for (Database.SaveResult saveResult : srFiles) {
            isSuccess = saveResult.isSuccess();
        }
        if(isSuccess){
        	List<ContentDocumentLink> contDocumentslinks = new List<ContentDocumentLink>();
            for(ContentVersion contVersion : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: relatedDocuments]){
                ContentDocumentLink cdl = new ContentDocumentLink();
        		cdl.ContentDocumentId = contVersion.ContentDocumentId;
    			cdl.LinkedEntityId = dealReg.Id;
    			cdl.ShareType = 'V';
                contDocumentslinks.add(cdl);
            }
            if(!contDocumentslinks.isEmpty()){
                Database.saveResult[] srFile = Database.insert(contDocumentslinks);
        		for (Database.SaveResult saveResult : srFile) {
                    if (!saveResult.isSuccess()){
                        for (Database.Error e : saveResult.getErrors()){ 
                            System.debug('error message'+e.getMessage());
                            System.debug('error message'+e);
                            returnmessage = e.getMessage();
                        }
                    }
                    else{
                        returnmessage = 'success';
                    }
        		}
            }
        }
        if(source == 'AVPApprovalonDR'){
        	dealReg.AVP_Approval__c = avpApprovalcheck;
            TriggerUtility.dealRegBeforeUpdateExecuted();
            TriggerUtility.DRFinalReviewExecuted();
            TriggerUtility.dealRegAfterUpdateExecuted();
            update dealReg;
         }
        return returnmessage;
    }
    
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }
    //Changes of IBA - 1599 - End
}