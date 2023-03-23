/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

global class SB_CloneQuoteController
{
    @InvocableMethod
    global static List<String> cloneQuote(cloneQuoteInput[] inputs)
    {
        system.debug('oppId'+inputs[0].oppId+'quoteId'+inputs[0].quoteId+'partnerId'+inputs[0].partnerId+'distributorId'+inputs[0].distributorId+'partnerProgram'+inputs[0].partnerProgram+'DiscountSelectionType'+inputs[0].DiscountSelectionType);
        map<String,String> objVsFieldsMap = new map<String,String>();
        SBQQ__Quote__c existingQuote = new SBQQ__Quote__c();
        SBQQ__Quote__c quoteToCreate = new SBQQ__Quote__c();
        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesToCreate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        map<Id,Id> prodIdVsRequiredByProdId = new map<id,Id>();
        List<String> qtId=new List<String>();
    
        if(String.isNotBlank(inputs[0].oppId) && String.isNotBlank(inputs[0].quoteId) && String.isNotBlank(inputs[0].partnerId)){
            //try{
                Account partnerAcc = [Select id,name,SummitDistribution__c from Account where id =:inputs[0].partnerId]; //CR# 3962 - Added SummitDistribution__c to Query
                //Create Quote
                
                
                Opportunity oppRec = [Select Id,OwnerId,closeDate,RecordType.DeveloperName,SBQQ__RenewedContract__r.EndDate from Opportunity where id =:inputs[0].oppId];
                System.debug('oppRec '+oppRec);
                List<Contract> renewedContractList = [SELECT ID, Cloud_Type__c FROM Contract WHERE SBQQ__RenewalOpportunity__c =: oppRec.Id];
                string tempInput = '%' + inputs[0].DiscountSelectionType + '%';
                for(SB_Clone_Quote_Metadata__mdt quoteMeta : [Select id,Object_Name__c,Field_Names__c from SB_Clone_Quote_Metadata__mdt WHERE Discount_Type__c LIKE :tempInput]){
                    objVsFieldsMap.put(quoteMeta.Object_Name__c,quoteMeta.Field_Names__c);
                }
                if(!objVsFieldsMap.isEmpty() && objVsFieldsMap.containsKey('SBQQ__Quote__c')){
                    String quoteQuery = 'SELECT ' + objVsFieldsMap.get('SBQQ__Quote__c') + ' FROM SBQQ__Quote__c WHERE Id = \'' + inputs[0].quoteId + '\'';
                    System.debug('query'+quoteQuery);

                    existingQuote = Database.query(quoteQuery);
                    for(String fieldValue : objVsFieldsMap.get('SBQQ__Quote__c').split(',')){
                        
                        system.debug('existingQuote'+existingQuote.get(fieldValue) + fieldValue);
                        quoteToCreate.put(fieldValue,existingQuote.get(fieldValue));
                    }
                    if(quoteToCreate.recordTypeId != existingQuote.get('Bill_to__c')){
                    
                    }
                    system.debug('quoteToCreate'+quoteToCreate);
                    quoteToCreate.SBQQ__Partner__c = inputs[0].partnerId;
                    quoteToCreate.SBQQ__BillingName__c = partnerAcc.Name;
                    quoteToCreate.Summit_Distribution__c = partnerAcc.SummitDistribution__c; //CR# 3962 - Added for Summit Distribution
                    quoteToCreate.Partner_Program__c = inputs[0].partnerProgram;


                    /*if(String.isNotBlank(inputs[0].distributorId)){
                        Account acc = [Select id,Billing_Frequency__c,Payment_Terms__c from Account where id=: inputs[0].distributorId];
                        if(inputs[0].distributorId != existingQuote.get('Bill_to__c')){
                             quoteToCreate.SBQQ__PaymentTerms__c = acc.Payment_Terms__c;
                        }
                        quoteToCreate.SBQQ__BillingFrequency__c = acc.Billing_Frequency__c;
                    }*/
                    
                    quoteToCreate.SBQQ__Distributor__c = String.isNotBlank(inputs[0].distributorId) ? inputs[0].distributorId : null;
                    quoteToCreate.Partner_Incentive__c = String.isNotBlank(inputs[0].partnerIncentive) ? inputs[0].partnerIncentive : null;
                    quoteToCreate.Bill_to__c = quoteToCreate.SBQQ__Distributor__c != null ? quoteToCreate.SBQQ__Distributor__c : quoteToCreate.SBQQ__Partner__c;
                    if(String.isNotBlank(quoteToCreate.Bill_to__c )){
                        Account acc = [Select id,Billing_Frequency__c,Payment_Terms__c from Account where id=: quoteToCreate.Bill_to__c ];
                        //if(inputs[0].distributorId != existingQuote.get('Bill_to__c')){ /*commented this line for fixing the bug ticket IBA-1899*/
                             quoteToCreate.SBQQ__PaymentTerms__c = acc.Payment_Terms__c;
                            system.debug('@@quoteToCreate'+quoteToCreate.SBQQ__PaymentTerms__c);
                        //}
                        quoteToCreate.SBQQ__BillingFrequency__c = acc.Billing_Frequency__c;
                    }
                    quoteToCreate.Proposal_Name__c = String.isNotBlank(inputs[0].proposalName) ? inputs[0].proposalName : quoteToCreate.Proposal_Name__c;
                    if(inputs[0].isEarlyRenewal == false){
                        quoteToCreate.Cloud_Type__c = String.isNotBlank(inputs[0].FedrampType) ? inputs[0].FedrampType : '';    
                    }
                    quoteToCreate.SBQQ__Status__c = 'Draft';
                    //quoteToCreate.OwnerId = oppRec.OwnerId;
                    TriggerUtility.skipAmendmentRenewalLogic=true;
                    
                    if(inputs[0].isEarlyRenewal == true){
                        quoteToCreate.Early_Renewal__c = true;
                        if(!renewedContractList.isEmpty() && renewedContractList != NULL && renewedContractList[0].Cloud_Type__c != NULL){
                            quoteToCreate.Cloud_Type__c =  renewedContractList[0].Cloud_Type__c;
                        }
                        if(inputs[0].partnerProgram == 'Summit - Federal'){
                            Date EndDate = oppRec.closeDate.addMonths(12);
                            quoteToCreate.SBQQ__StartDate__c = oppRec.closeDate;
                            quoteToCreate.SBQQ__EndDate__c = EndDate.addDays(-1);
                        }else{
                            Date EndDate = oppRec.closeDate.addMonths(36);
                            quoteToCreate.SBQQ__StartDate__c = oppRec.closeDate;
                            quoteToCreate.SBQQ__EndDate__c = EndDate.addDays(-1);
                        }
                    }
                            
                    insert quoteToCreate;
                    system.debug('quoteToCreate'+quoteToCreate);
                    qtId.add(quoteToCreate.Id);
                    SBQQ__Quote__c quote=[Select id,SBQQ__Partner__c,SBQQ__Distributor__c from sbqq__Quote__c where id =:quoteToCreate.Id];
                    system.debug('quote========>'+quote);
                    //Create Quote Lines
                    if(objVsFieldsMap.containsKey('SBQQ__QuoteLine__c')){
                        String quoteLineQuery = 'SELECT ' + objVsFieldsMap.get('SBQQ__QuoteLine__c') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = \'' + inputs[0].quoteId + '\'';
                        System.debug('quoteLineQuery'+quoteLineQuery);
                       
                        existingQuoteLines = Database.query(quoteLineQuery);
                        
                        for(SBQQ__QuoteLine__c quoteLine : existingQuoteLines){
                            SBQQ__QuoteLine__c newQL = new SBQQ__QuoteLine__c();
                            for(String fieldValue : objVsFieldsMap.get('SBQQ__QuoteLine__c').split(',')){
                                system.debug('quoteLine.SBQQ__RequiredBy__c'+quoteLine.SBQQ__RequiredBy__c+'fieldValue'+fieldValue);
                                if(fieldValue == 'SBQQ__RequiredBy__r.SBQQ__Product__c' && quoteLine.SBQQ__RequiredBy__c != null){
                                    prodIdVsRequiredByProdId.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__RequiredBy__r.SBQQ__Product__c);
                                }else if(fieldValue != 'SBQQ__RequiredBy__r.SBQQ__Product__c'){
                                    newQL.put(fieldValue,quoteLine.get(fieldValue));
                                }
                            }
                            newQL.SBQQ__Quote__c = quoteToCreate.Id;
                            newQL.SBQQ__RequiredBy__c = null;
                            
              if(inputs[0].isEarlyRenewal == true){
                Date EndDate = (quoteToCreate.Partner_Program__c == 'Summit - Federal') ? oppRec.closeDate.addMonths(12) : oppRec.closeDate.addMonths(36);
                newQL.SBQQ__StartDate__c = oppRec.closeDate;
                newQL.SBQQ__EndDate__c = EndDate.addDays(-1);
              }
                            quoteLinesToCreate.add(newQL);
                        }
                        system.debug('prodIdVsRequiredByProdId'+prodIdVsRequiredByProdId);
                        if(!quoteLinesToCreate.isEmpty()){
                            insert quoteLinesToCreate;
                            
                            system.debug('quoteLinesToCreate'+quoteLinesToCreate);
                            if(!prodIdVsRequiredByProdId.isEmpty()){
                                map<Id,Id> prodIdVsQLI = new map<id,Id>();
                                for(SBQQ__QuoteLine__c insertedQL : [Select id,SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Product__c IN : prodIdVsRequiredByProdId.values() and SBQQ__Quote__c =:quoteToCreate.Id]){
                                    
                                    prodIdVsQLI.put(insertedQL.SBQQ__Product__c,insertedQL.Id);
                                }
                                system.debug('prodIdVsQLI'+prodIdVsQLI);
                                if(!prodIdVsQLI.isEmpty()){
                                    for(SBQQ__QuoteLine__c insertedQL : [Select id,SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Product__c IN : prodIdVsRequiredByProdId.keySet() and SBQQ__Quote__c =:quoteToCreate.Id]){
                                        String phantomProductId = prodIdVsRequiredByProdId.get(insertedQL.SBQQ__Product__c);
                                        system.debug('phantomProductId'+phantomProductId);
                                        if(prodIdVsQLI.containsKey(phantomProductId)){
                                            insertedQL.SBQQ__RequiredBy__c = prodIdVsQLI.get(phantomProductId);
                                            quoteLinesToUpdate.add(insertedQL);
                                        }
                                    }
                                    system.debug('quoteLinesToUpdate'+quoteLinesToUpdate);
                                    if(!quoteLinesToUpdate.isEmpty()){
                                        update quoteLinesToUpdate;
                                    }
                                }
                            }
                        }
                    }
                }
            //}
            /*catch(Exception ex){
                qtId = new List<String>();
                
                system.debug('error'+ex.getMessage());
                
            }*/
        }
        return qtId;
    }
    
    global class cloneQuoteInput {
        @InvocableVariable(required=true)
        global String oppId;
        
        @InvocableVariable(required=true)
        global String quoteId;
        
        @InvocableVariable(required=true)
        global String partnerId;
        
        @InvocableVariable(required=true)
        global String partnerProgram;
        
        @InvocableVariable
        global String partnerIncentive;
        
        @InvocableVariable
        global String distributorId;
        
        @InvocableVariable
        global String proposalName;
        
        @InvocableVariable(required=true)
        global Boolean isEarlyRenewal;
        
        @InvocableVariable
        global String FedrampType;
        
        @InvocableVariable
        global String DiscountSelectionType;
    }
    
    webservice static Boolean getBannerDetail(String quoteId) {
        SBQQ__Quote__c quote = [Select id,Show_Banner__c from SBQQ__Quote__c where id=:quoteId];
        return quote.Show_Banner__c;
    }
    
    webservice static Boolean getShellQuote(String quoteId) {
        SBQQ__Quote__c quote = [Select id,Shell_Quote__c from SBQQ__Quote__c where id=:quoteId];
        return quote.Shell_Quote__c;
    }
}