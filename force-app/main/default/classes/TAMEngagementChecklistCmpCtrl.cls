/**
 * Name : TAMEngagementChecklistCmpCtrl
 * Description : Controller class for TAMEngagementChecklistCmp LWC
 * Test Class : TAMEngagementChecklistCmpCtrlTest
 * Initial Author : Ankit Bhatnagar
 */

public with sharing class TAMEngagementChecklistCmpCtrl {
    public TAMEngagementChecklistCmpCtrl() {}

    @AuraEnabled
    public static Boolean checkDocs(Id recordId, String docType) {
        System.debug('## INSIDE checkDocs '+recordId +'--'+docType);
        String accountId='';
        Boolean flag = false;
        String product = '';
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c eng = [SELECT id,Account__c,product__c FROM TAM_Engagement__c WHERE id=:recordId];
                accountId = eng.Account__c;
                //Changed as part of IBA-3370
                //products = eng.product__c.split(';');
                product = eng.product__c;
                List<ContentDocumentLink> cdls = new List<ContentDocumentLink>([
                    SELECT Id,ContentDocument.LatestPublishedVersion.Project_Product_Type_fileupload__c, ContentDocument.LatestPublishedVersion.Document_Type_fileupload__c  
                    FROM ContentDocumentLink WHERE LinkedEntityId = :accountId  
                    AND ContentDocument.LatestPublishedVersion.Document_Type_fileupload__c =: docType
                    AND ContentDocument.LatestPublishedVersion.Project_Product_Type_fileupload__c = : product]);
                if(!cdls.isEmpty()) {
                    flag = true;
                } 
            }
        }
        return flag;   
    }
    
    @AuraEnabled
    public static Boolean checkAdoptionPercentage(Id recordId, Decimal perc) {
        String accountId='';
        Boolean flag = false;
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c eng = [SELECT id,Account__c,product__c FROM TAM_Engagement__c WHERE id=:recordId];
                accountId = eng.Account__c;
                Account acc = [SELECT id,ZPA_Enrolled_users_L31D_Vs_Purchase__c,Avg_Estimated_Users_L31D_Vs_Purchase__c,Active_Users_L30D_Vs_Purchased_Users__c	FROM Account WHERE id =: accountId];
                //Changed product from Multi-picklist to picklist as part of IBA-3370
                if(eng.product__c == 'ZIA') {
                    if(acc.Avg_Estimated_Users_L31D_Vs_Purchase__c >= perc) {
                        flag = true;
                    }
                    else {
                        return false;
                    }
                }
                if(eng.product__c == 'ZPA') {
                    if(acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c >= perc) {
                        flag = true;
                    }
                    else {
                        return false;
                    }
                    
                }
                if(eng.product__c == 'ZDX') {
                    if(acc.Active_Users_L30D_Vs_Purchased_Users__c >= perc) {
                        flag = true;
                    }
                    else {
                        return false;
                    }
                }
            }
        }
        return flag;
    }

    @AuraEnabled
    public static Boolean checkWeeklyMeetings(Id recordId) {
        String accountId='';
        Boolean flag = false;
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c eng = [SELECT id,Account__c,product__c FROM TAM_Engagement__c WHERE id=:recordId];
                accountId = eng.Account__c;
                List<Meeting__c> meetings = new List<Meeting__c>([SELECT id,Status__c FROM Meeting__c 
                                                                WHERE Date_of_meeting__c = LAST_N_DAYS:45 AND Status__c = 'Completed' AND Customer_Name__c =:accountId]);
                if(!meetings.isEmpty()) {
                    flag = true;
                }
            }
        }
        return flag;
    }

    @AuraEnabled
    public static Boolean checkTAMProjectStatus(Id recordId) {
        String accountId='';
        Boolean flag = false;
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c eng = [SELECT id,Account__c,product__c FROM TAM_Engagement__c WHERE id=:recordId];
                accountId = eng.Account__c;
                List<AggregateResult> groupedResults = new List<AggregateResult>([SELECT Project_Status__c,COUNT(Id)countStatus  
                                                                                    FROM GCS_Project__c 
                                                                                    WHERE Account__c =: accountId
                                                                                    AND Project_Type__c = 'Best Practice'
                                                                                    AND Project_Sub_Type__c = 'Configuration Audit'
                                                                                    group by Project_Status__c]);                                                                                          
                if(!groupedResults.isEmpty()) {
                    for (AggregateResult ar : groupedResults)  {
                        System.debug(ar.get('Project_Status__c')+'--'+ ar.get('countStatus'));
                        if(ar.get('Project_Status__c')=='New' || 
                            ar.get('Project_Status__c')=='In Progress' || 
                            ar.get('Project_Status__c')=='On Hold') {
                            return false;
                        }
                        else if(ar.get('Project_Status__c')=='Completed') {
                            flag = true;
                        }
                    }
                } 
            }
        }
        return flag;
    }

    @AuraEnabled
    public static CaseReductionDetails calculateReductionInCases(Id recordId) {
        String accountId='';
        Boolean flag = false;
        //Changed product from multi-picklist to picklist as part of IBA-3370
        String product;
        CaseReductionDetails reductionDetails = new CaseReductionDetails();
        List<CaseReduction> reductionLineItems = new List<CaseReduction>();
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c eng = [SELECT id,Account__c,product__c FROM TAM_Engagement__c WHERE id=:recordId];
                accountId = eng.Account__c;
                //Changed product from multi-picklist to picklist as part of IBA-3370
                //products = eng.product__c.split(';');
                product = eng.product__c;
                Integer limitStart = 0 - 6;
                Integer limitEnd = 0 - 3;
                Date limitStartDate = System.today().addMonths(limitStart);
                Date limitEndDate = System.today().addMonths(limitEnd);
                System.debug('limitStartDate'+limitStartDate);
                System.debug('limitEndDate'+limitEndDate);
                List<Case> casesFirstHalf = new List<Case>([SELECT id FROM Case 
                                                            WHERE (Case_Type__c = 'Problem' OR Case_Type__c = 'Question')
                                                            AND Product_New__c = :product
                                                            AND AccountId = :accountId
                                                            AND CreatedDate >=:limitStartDate
                                                            AND CreatedDate <=:limitEndDate]);
                List<Case> casesSecondHalf = new List<Case>([SELECT id FROM Case 
                                                            WHERE (Case_Type__c = 'Problem' OR Case_Type__c = 'Question')
                                                            AND Product_New__c = :product
                                                            AND AccountId = :accountId
                                                            AND CreatedDate >:limitEndDate
                                                            AND CreatedDate <=TODAY]);
                Decimal countFirstHalf =  casesFirstHalf.size();
                Decimal countSecondHalf = casesSecondHalf.size(); 
                reductionLineItems.add(new CaseReduction('Cases between '+String.valueOf(limitStartDate)+ ' and '+String.valueOf(limitEndDate) + ' (first 3 months)', String.valueOf(countFirstHalf)));
                reductionLineItems.add(new CaseReduction('Cases between '+String.valueOf(limitEndDate.addDays(1))+ ' and '+String.valueOf(Date.today()) + ' (last 3 months)',String.valueOf(countSecondHalf)));
                if(countFirstHalf != 0) {
                    Decimal calc = (countFirstHalf-countSecondHalf)/countFirstHalf;
                    System.debug('## Calc'+calc);
                    if(calc<=0) {
                        flag = false;
                        Decimal rounded = (Math.abs(calc)*100).setScale(2);
                        reductionLineItems.add(new CaseReduction('% Increase in cases by Customer',String.valueOf(rounded) + '%'));
                    }
                    else {
                        Decimal rounded = (Math.abs(calc)*100).setScale(2);
                        reductionLineItems.add(new CaseReduction('% Reduction in cases by Customer',String.valueOf(rounded) + '%'));
                        if((calc*100)<15) {
                            flag = false;
                        }
                        else {
                            flag = true;
                        }
                    }
                }
                else{
                    if(countFirstHalf != countSecondHalf) {
                        reductionLineItems.add(new CaseReduction('% Reduction in cases by Customer','Cannot calculate as no cases were logged in the first half'));
                        flag = false;   
                    }
                    else {
                        flag = true;
                    }
                }
            }
        }
        reductionDetails.details = reductionLineItems;
        reductionDetails.flag = flag;
        return reductionDetails;
    }

    @AuraEnabled
    public static String getCustomerSentiment(Id recordId) {
        String accountId='';
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            TAM_Engagement__c eng = [SELECT id,Account__c,product__c FROM TAM_Engagement__c WHERE id=:recordId];
            accountId = eng.Account__c;
            Account acc = [SELECT id,Customer_Sentiment__c	FROM Account WHERE id =: accountId];
            return acc.Customer_Sentiment__c;
        }
        else {
            return '';
        }
    }

    @AuraEnabled
    public static TAMMeetingDetails getTAMMeetingDetails(Id recordId) {
        String accountId='';
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            TAM_Engagement__c eng = [SELECT id,Account__c,product__c FROM TAM_Engagement__c WHERE id=:recordId];
            accountId = eng.Account__c;
            List<Meeting__c> meetings = new List<Meeting__c>([SELECT id,Name, Status__c FROM Meeting__c 
                                                            WHERE Date_of_meeting__c = LAST_N_DAYS:45 AND Status__c = 'Completed' AND Customer_Name__c =:accountId order by Date_of_meeting__c desc]);
            if(!meetings.isEmpty()) {
                TAMMeetingDetails details = new TAMMeetingDetails(meetings.get(0).Name, meetings.get(0).id);
                return details;
            }
            else return null;
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static List<AccountAdoptionRates> getAdoptionRates(Id recordId) {
        List<AccountAdoptionRates> adoptionRates = new List<AccountAdoptionRates>();
        String accountId='';
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c eng = [SELECT id,Account__c,product__c FROM TAM_Engagement__c WHERE id=:recordId];
                accountId = eng.Account__c;
                Account acc = [SELECT id,ZPA_Enrolled_users_L31D_Vs_Purchase__c,Avg_Estimated_Users_L31D_Vs_Purchase__c,Active_Users_L30D_Vs_Purchased_Users__c	FROM Account WHERE id =: accountId];
                //Changed product from multi-picklist to picklist as part of IBA-3370
                if(eng.product__c == 'ZIA') {
                    Decimal ziaCount = acc.Avg_Estimated_Users_L31D_Vs_Purchase__c!=null?acc.Avg_Estimated_Users_L31D_Vs_Purchase__c/100:0;
                    adoptionRates.add(new AccountAdoptionRates('ZIA Adoption Rate',String.valueOf(ziaCount)));
                }
                if(eng.product__c == 'ZPA') {
                    Decimal zpaCount = acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c!=null?acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c/100:0;
                    adoptionRates.add(new AccountAdoptionRates('ZPA Adoption Rate',String.valueOf(zpaCount)));
                }
                if(eng.product__c == 'ZDX') {
                    Decimal zdxCount = acc.Active_Users_L30D_Vs_Purchased_Users__c!=null?acc.Active_Users_L30D_Vs_Purchased_Users__c/100:0;
                    adoptionRates.add(new AccountAdoptionRates('ZDX Adoption Rate',String.valueOf(zdxCount)));
                }
            }
        }
        return adoptionRates;
    }

    @TestVisible
    private class CaseReductionDetails {
        @AuraEnabled public List<CaseReduction> details {get; set;}
        @AuraEnabled public Boolean flag {get; set;}

        private CaseReductionDetails() {
            this.details = null;
            this.flag = false;
        }
    }

    @TestVisible
    private class CaseReduction {
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String label {get; set;}

        private CaseReduction(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    private class AccountAdoptionRates {
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String label {get; set;}

        private AccountAdoptionRates(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @TestVisible
    private class TAMMeetingDetails {
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String id {get; set;}

        private TAMMeetingDetails(String name, String id) {
            this.name = name;
            this.id = id;
        }
    }
}