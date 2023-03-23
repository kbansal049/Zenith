/**
 * @description       : 
 * @author            : Jade Global
 * @group             : 
 * @last modified on  : 04-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-27-2021   Jade Global   Initial Version
**/
public with sharing class ShowCartItemsEmailController {

    Public String InstanceURL{get; set;}
    Public ID ApproverId{get; set;}
    Public ID ApprovalRequestId{get; set;}
    public boolean IsAssignment {get; set;}
    public boolean IsApproved {get; set;}
    public boolean isPartnerSummit {get; set;}
    public boolean isPartnerAdjustment {get; set;}
    public boolean IsApproveOrReject {get; set;}
    public boolean isTraditional {get; set;}
    public Boolean isSummitFederal {get;set;}
    public string url {get;set;}


    public SBQQ__Quote__c quoteSO{get;set;}
    private ID prodConfigID;
    private ID proposalID2;
    public String quoteId {get;set;}
    
    public String ApproversId {get;set;}
    public Decimal oldppu{get;set;}
    public decimal newppu{get;set;}
    public decimal changeofPPU{get;set;}
    public Boolean isSummitDiscount {get;set;}
    public Boolean isSummitDistribution {get;set;}
    public Boolean isFy21VolumeTier { get; set; }
    public Boolean isFy21SingleTier { get; set; }
    public Boolean isRenewal {get;set;}
    public Boolean isAmendement {get;set;}

    public Boolean hasRecurringLines {get;set;}
    public Boolean hasRecurringRenewalLines {get;set;}

    public Boolean hasOneTimeLines {get;set;}
    public Boolean hasSupportLine {get;set;}
 
    public Decimal differnceOfRenewableAndProposal {get;set;}
    public Decimal OnlydiffOfRenewableAndProposal {get;set;}
    public Decimal totalBaseExtendedPrice {get; set;}
    public Decimal totalStandardPrice {get; set;}
    public Decimal totalNetPrice {get; set;}
    public Decimal totalACV {get; set;}
    public Decimal totalMRR {get; set;}
    public Decimal totalPPU {get; set;}
    public Decimal totalNetToZscaler {get; set;}
    public Decimal totalZSRP {get; set;}
    public Decimal supportNetPrice {get; set;}
    public Double supportDiscount {get; set;}
    public Double netVariance {get; set;}
    public Decimal totalUnitRecommended {get; set;}
    public Decimal totalNetUnitPrice {get; set;}
    public Decimal totalPriceWithAdjustment {get; set;}
    public String priceListName {get; set;}
    public Boolean IsShowApprovalSection {get;set;}

    public boolean IsEmailTemplateView {get;set;}
    public boolean IsShowCartView {get;set;}


    public list<SBQQ__Subscription__c> subscriptionsListSummitDiscount {get;set;}
    public list<SBQQ__Subscription__c> subscriptionsListSummitDistribution {get;set;}
    public list<SBQQ__Subscription__c> subscriptionsListTraditional {get;set;}
    public list<SBQQ__Subscription__c> subscriptionsListFederal {get;set;}
    public List<Billing_Schedule__c> lstBillingSchedules {get;set;}
    public list<sbaa__Approval__c> approvalList {get;set;}
    public list<SBQQ__Quote__c> quoteRecList {get;set;}
    
    public string accountName {get;set;}
    public string quoteName {get;set;}
    public string approvalReason {get;set;}
    public Boolean hasAssetLines {get;set;}
    public string accountId {get;set;}
    
    public Boolean isSpecialTermAvailable {get;set;}
    public String specialTermVal {get;set;}
    public String recordtypeName {get;set;}
    public Boolean isOrangePartnerContractedDiscount { get; set; }  
    public Boolean isOrangePartnerUpsellDiscount { get; set; }
    public String showCartPerUnit {get;set;}
    public Integer numberofLines {get;set;}
    public Integer isLineItemCount {get;set;}
    public Integer isCompareLineItemCount {get;set;}
    public String isAssignedTo {get;set;}
    public Boolean iscartDetailsEnabled {get;set;}
    // IBA-942 START
    public Boolean isBundleAssociated {get; set;}
    // IBA-942 END

    public ShowCartItemsEmailController() {

        // IBA-942 START
        isBundleAssociated = ShowCartItemsVFController.isProductNamesAssociatedToQuoteLines(quoteId);
        // IBA-942 END

        url  = System.Url.getSalesforceBaseURL().toExternalForm();
        isFy21VolumeTier = false;
        isFy21SingleTier = false;
        isRenewal = false;
        isAmendement = false;
        isOrangePartnerContractedDiscount = false;
        isOrangePartnerUpsellDiscount = false;

        hasRecurringLines = false;
        hasRecurringRenewalLines = false;

        hasOneTimeLines = false;
        hasSupportLine = false;
        totalBaseExtendedPrice = totalStandardPrice = totalNetPrice = totalACV = totalMRR = totalPPU = totalNetToZscaler = totalZSRP = 0;
        totalUnitRecommended = totalNetUnitPrice = totalPriceWithAdjustment = 0;
        supportNetPrice = supportDiscount = netVariance = 0.00;
        priceListName = '';
        subscriptionsListSummitDiscount = new list<SBQQ__Subscription__c>();
        subscriptionsListSummitDistribution = new list<SBQQ__Subscription__c>();
        subscriptionsListTraditional = new list<SBQQ__Subscription__c>();
        subscriptionsListFederal = new list<SBQQ__Subscription__c>();
        lstBillingSchedules = new List<Billing_Schedule__c>();
        approvalList = new List<sbaa__Approval__c>();
        quoteRecList = new List<SBQQ__Quote__c>();
        hasAssetLines = false;
        
        isSpecialTermAvailable = false;
        
        numberofLines=Integer.valueOf(Label.Show_cart_email_restricted_lines);
        isCompareLineItemCount = Integer.valueOf(Label.Compare_the_number_of_Line_Item_Items);
        iscartDetailsEnabled = Boolean.valueOf(Label.Cart_Details_enable_for_showcart);
    }

    public Decimal noOfUsers=0; 
    
    
    public List<SBQQ__Quote__c> getQuoteList(){
        
        if(quoteId != null && quoteRecList.isEmpty()){
         
            quoteRecList = [SELECT id,
                Name, SBQQ__Account__r.Name, Opportunity_Owner__c, 
                Record_Type_Name__c, SBQQ__Opportunity2__r.Name, 
                ACV__c, Total_Blended_Discount__c, Bill_to__r.Name, 
                Current_Quote_MRR__c, Partner_Program__c, Price_List__c,
                SBQQ__Opportunity2__r.Deal_Reg_Margin__c,SBQQ__Opportunity2__r.Deal_Reg_Partner_Teaming_Reseller__c,
                SBQQ__Opportunity2__r.Partner_Margin_Adjustment__c,
                Total_PUPY_Discount__c,TCV__c,Cart_PUPY_without_Support_DAS_Training__c,
                Subscription_Discount_without_Support__c,SBQQ__LineItemCount__c,
                AW_Discount__c,POV_Discount__c,AW_POV_Discount__c,
                Fulfillment_Discount__c,
                SBQQ__Opportunity2__r.Deal_Reg_Margin__r.Name,
                SBQQ__BillingFrequency__c,SBQQ__PaymentTerms__c,SBQQ__Account__r.Customer_Sentiment__c,
                SBQQ__Account__r.Success_Stage__c,Generate_Year_wise_Split__c,Number_of_Users__c,
                SBQQ__SubscriptionTerm__c,Recomm_PUPY_without_Support_DAS_Training__c,
                ACV_New__c,SBQQ__EndDate__c,SBQQ__StartDate__c,Approval_Reason__c,
                Renewal_MRR_Change_Approval__c,Previous_MRR_Approval__c,Rep_Comp_Impacted__c,
                Net_variance_weighted_avg__c,SBQQ__Distributor__c,SBQQ__Distributor__r.Name,
                Total_Discount_Without_Support__c,SBQQ__Partner__c,SBQQ__Partner__r.Name,
                Renewal_ACV__c,Special_Terms__c,Opportunity_Record_Type__c,Contract_Number__c,Show_Cart_Per_Unit__c,Cloud_Type__c
                FROM SBQQ__Quote__c 
                WHERE Id =: quoteId LIMIT 1];
            
            isLineItemCount = Integer.valueOf(quoteRecList[0].SBQQ__LineItemCount__c);
            isPartnerAdjustment = quoteRecList[0].SBQQ__Opportunity2__r.Partner_Margin_Adjustment__c && quoteRecList[0].Partner_Program__c != Label.Partner_Program_Summit_Discount;
            isPartnerSummit = quoteRecList[0].Partner_Program__c == Label.Partner_Program_Partner_Summit;
            isSummitDiscount = quoteRecList[0].Partner_Program__c == Label.Partner_Program_Summit_Discount;
            //CR#2982
            isTraditional = quoteRecList[0].Partner_Program__c == Label.Partner_Program_Traditional;
            isSummitFederal = quoteRecList[0].Partner_Program__c == Label.Partner_Program_Summit_Federal;
            
            accountId = quoteRecList[0].SBQQ__Account__c;
            accountName = quoteRecList[0].SBQQ__Account__r.Name;
            quoteName = quoteRecList[0].Name;
            approvalReason = quoteRecList[0].Approval_Reason__c;
            specialTermVal = quoteRecList[0].Special_Terms__c != null ? quoteRecList[0].Special_Terms__c : '';
            isSpecialTermAvailable = quoteRecList[0].Special_Terms__c != null ? true : false;
            showCartPerUnit = quoteRecList[0].Show_Cart_Per_Unit__c != null ? quoteRecList[0].Show_Cart_Per_Unit__c : '';
            //added by Rakshitha CR#3507 and modified the if blocks
            //not able to use getAll() methods becuase of 255 character limit
            Map<String,List<String>> showCartSettingMap = new Map<String,List<String>>();
            For(Price_List_Setting__mdt   showCartSettingRec : [SELECT DeveloperName,Price_List__c FROM Price_List_Setting__mdt]){
                if(showCartSettingRec.Price_List__c!=null){
                showCartSettingMap.put(showCartSettingRec.DeveloperName,showCartSettingRec.Price_List__c.split(';'));
                }
            }
                priceListName = quoteRecList[0].Price_List__c;
            // IBA-942 - Added isBundleAssociated flag
            if((priceListName != null && showCartSettingMap.get('Volume_Tier').contains(priceListName)) || isBundleAssociated ==true){
                isFy21VolumeTier = true;
            }else if(priceListName != null && showCartSettingMap.get('Federal_Bundle').contains(priceListName)){
                isFy21VolumeTier = true;
            }else if(priceListName != null && showCartSettingMap.get('Commercial').contains(priceListName)){
                isFy21SingleTier = true;
            }else if(priceListName != null && showCartSettingMap.get('Federal_Editions').contains(priceListName)){
                isFy21SingleTier = true;
            }
                        
            if(quoteRecList[0].Opportunity_Record_Type__c == 'Renewal Opportunity'){
                isRenewal = true;
                recordtypeName = 'Renewal';
            }else if(quoteRecList[0].Opportunity_Record_Type__c == 'Upsell Opportunity' || quoteRecList[0].Opportunity_Record_Type__c == 'Upsell Opportunity Closed'){
                isAmendement = true;
                recordtypeName = 'Amendment';
            }else if(quoteRecList[0].Opportunity_Record_Type__c == 'New Business' || quoteRecList[0].Opportunity_Record_Type__c == 'New Business Close'){
                recordtypeName = 'New Business';
            }

            if(System.Label.Contract_Number.split(',').contains(quoteRecList[0].Contract_Number__c)){
                if(isAmendement || isRenewal){  
                    isOrangePartnerUpsellDiscount = true;
                }
                    isOrangePartnerContractedDiscount = true;
            }
             Set<String> approvalReqStatusSet = new set<String>();
            approvalReqStatusSet.add('Assigned');
            approvalReqStatusSet.add('Requested');
            approvalReqStatusSet.add('Revoked');
            for(sbaa__Approval__c appr : [SELECT Id, sbaa__ApprovalStep__c, sbaa__Status__c,
                                        sbaa__AssignedTo__c, sbaa__AssignedTo__r.Name,
                                        sbaa__AssignedGroupId__c,sbaa__AssignedToMe__c,
                                        sbaa__Approver__c, sbaa__CommentsLong__c,Quote__c,
                                        sbaa__Rule__c,sbaa__Rule__r.Name,Rule_Description__c,
                                        Quote__r.Net_Variance_Weighted_Avg_Approval__c,
                                        Quote__r.Manual_Adjustment__c,sbaa__ApprovalChain__r.Name  
                                        FROM sbaa__Approval__c WHERE Quote__c =: quoteId  AND sbaa__Status__c IN: approvalReqStatusSet 
                                        AND ( sbaa__AssignedTo__c  =:ApproverId /*OR sbaa__AssignedGroupId__c IN : GroupIdSet*/)
                                        ORDER BY sbaa__ApprovalChain__r.Name
                                        ])
            {
                if(appr.sbaa__AssignedTo__c == Label.show_cart_exception_User_Id){
                    isAssignedTo=appr.sbaa__AssignedTo__c;
                    system.debug('isAssignedTo'+isAssignedTo);
                } 
            }
            
             
            If(isLineItemCount < isCompareLineItemCount){
            subscriptionsListSummitDiscount =  [SELECT id,SBQQ__Account__c,SBQQ__Account__r.Name,Partner_Program__c,
                                                SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__StartDate__c,
                                                SBQQ__EndDate__c,Base_Extended_Price__c,Volume_Disc__c,SBQQ__PartnerDiscount__c,
                                                New_Logo_Discount__c,Internal_List_Price__c,SBQQ__NetPrice__c,ACV_New__c,
                                                MRR__c,Recomm_Net__c,Net_to_Zscaler__c,SBQQ__ListPrice__c,Recommended_Retail_Price__c,
                                                ZSRP__c,AW_Discount__c,POV_Discount__c,AW_POV_Discount__c,Fulfillment_Discount__c,Deployment_Discount__c,
                                                Co_sell_Discount__c,Blended_Discount__c,Product_Code__c,Deal_Reg_Sourced_Discount__c,
                                                Deal_Reg_Teaming_Reseller_Discount__c,Renewal_Deal_Reg_Discount__c,Distributor_Discount__c,
                                                Subscription_Term__c,Partner_Disc__c,SBQQ__Discount__c,AdditionalDiscountUnit__c,
                                                Total_Discount__c,Net_Total__c,Net_PUPY__c,Net_Variance__c,Price_After_Adjustment__c,
                                                NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c,Deal_Reg_Teaming_Upsell_Discount__c,Contractual_Incentive_Discount__c,Total_base_discount__c
                                                FROM SBQQ__Subscription__c 
                                                WHERE SBQQ__Account__c =: quoteRecList[0].SBQQ__Account__c 
                                                AND Partner_Program__c = :Label.Partner_Program_Summit_Discount
                                                AND SBQQ__Contract__r.Status = 'Activated' and SBQQ__Contract__r.IsExpired__c=false];

        
            subscriptionsListTraditional =  [SELECT id,SBQQ__Account__c,SBQQ__Account__r.Name,Partner_Program__c,
                                                SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__StartDate__c,
                                                SBQQ__EndDate__c,Base_Extended_Price__c,Volume_Disc__c,SBQQ__PartnerDiscount__c,
                                                New_Logo_Discount__c,Internal_List_Price__c,SBQQ__NetPrice__c,ACV_New__c,
                                                MRR__c,Recomm_Net__c,Net_to_Zscaler__c,Product_Code__c,Deal_Reg_Sourced_Discount__c,
                                                Deal_Reg_Teaming_Reseller_Discount__c,Renewal_Deal_Reg_Discount__c,Distributor_Discount__c,
                                                Subscription_Term__c,Partner_Disc__c,SBQQ__Discount__c,AdditionalDiscountUnit__c,
                                                Total_Discount__c,Net_Total__c,Net_PUPY__c,Net_Variance__c,Price_After_Adjustment__c,
                                                NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c,Deal_Reg_Teaming_Upsell_Discount__c,Contractual_Incentive_Discount__c,Total_base_discount__c,SBQQ__ListPrice__c
                                                FROM SBQQ__Subscription__c 
                                                WHERE SBQQ__Account__c =: quoteRecList[0].SBQQ__Account__c 
                                                AND Partner_Program__c = :Label.Partner_Program_Traditional
                                                AND SBQQ__Contract__r.Status = 'Activated' and SBQQ__Contract__r.IsExpired__c=false];

            subscriptionsListFederal =  [SELECT id,SBQQ__Account__c,SBQQ__Account__r.Name,Partner_Program__c,
                                    SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__StartDate__c,
                                    SBQQ__EndDate__c,Base_Extended_Price__c,Volume_Disc__c,SBQQ__PartnerDiscount__c,
                                    New_Logo_Discount__c,Internal_List_Price__c,SBQQ__NetPrice__c,ACV_New__c,
                                    MRR__c,Recomm_Net__c,Net_to_Zscaler__c,SBQQ__ListPrice__c,
                                    ZSRP__c,AW_Discount__c,POV_Discount__c,AW_POV_Discount__c,Fulfillment_Discount__c,Deployment_Discount__c,
                                    Co_sell_Discount__c,Blended_Discount__c,Product_Code__c,Deal_Reg_Sourced_Discount__c,
                                    Deal_Reg_Teaming_Reseller_Discount__c,Renewal_Deal_Reg_Discount__c,Distributor_Discount__c,
                                    Subscription_Term__c,Partner_Disc__c,SBQQ__Discount__c,AdditionalDiscountUnit__c,
                                    Total_Discount__c,Net_Total__c,Net_PUPY__c,Net_Variance__c,Price_After_Adjustment__c,
                                    NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c
                                    FROM SBQQ__Subscription__c 
                                    WHERE SBQQ__Account__c =: quoteRecList[0].SBQQ__Account__c
                                    AND Partner_Program__c = :Label.Partner_Program_Summit_Federal
                                    AND SBQQ__Contract__r.Status = 'Activated' and SBQQ__Contract__r.IsExpired__c=false];
            }
            // Display previous approver records...
            approvalList =  [SELECT Id,Approval_Rule_Name__c,sbaa__ApprovalStep__c, sbaa__Status__c, sbaa__ApprovedBy__r.Name, 
                             sbaa__CommentsLong__c,sbaa__Archived__c,sbaa__ApprovalChain__r.Name 
                             FROM sbaa__Approval__c 
                             WHERE Quote__c =: quoteId AND sbaa__Status__c ='Approved' AND sbaa__Archived__c = false
                             ORDER BY sbaa__ApprovalChain__r.Name];
            
            return quoteRecList;
        }
        system.debug('quoteId'+quoteId);
        return quoteRecList;
      
    }


    Public List<SBQQ__QuoteLine__c> getListOfQuoteLineDetails(){
        list<SBQQ__QuoteLine__c> ListOfQuoteLineDetails = new list<SBQQ__QuoteLine__c>();

        // Query the quote lines....
        if(isLineItemCount < numberofLines){
        ListOfQuoteLineDetails = [SELECT Id,Name,SBQQ__ProductName__c, SBQQ__ProductCode__c, 
                                        SBQQ__ListPrice__c, Volume_Disc__c, Recommended_Retail_Price__c, 
                                        SBQQ__Quantity__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Term__c,
                                        Base_Extended_Price__c, Adjustment_Type__c, Adjustment__c, ZSRP__c, 
                                        Customer_Discount__c, Co_sell_Discount__c, SBQQ__NetPrice__c, Blended_Discount__c, 
                                        ACV_New__c, MRR__c, Net_PUPY__c, Recomm_Net__c,Cart_Price_PUPY__c,
                                        SBQQ__ChargeType__c,SBQQ__Product__r.Credit__c,Net_to_Zscaler__c,
                                        TCV__c,PartnerDisc__c,Deal_Reg_Sourced_Discount__c,Deal_Reg_Teaming_Reseller_Discount__c,
                                        Renewal_Deal_Reg_Discount__c,New_Logo_Discount__c,Internal_List_Price__c,
                                        Fulfillment_Discount__c,Distributor_Discount__c,Deployment_Discount__c,
                                        Net_Variance__c,SBQQ__TotalDiscountRate__c,AW_Discount__c,POV_Discount__c,AW_POV_Discount__c,
                                        SBQQ__Quote__r.SBQQ__Opportunity2__r.Partner_Margin_Adjustment__c,
                                        SBQQ__SubscriptionTerm__c,SBQQ__Discount__c,Last_Ramp_Quantity__c,
                                        Manual_Discount__c,Price_Per_Unit__c,Line_Status__c,SBQQ__NetTotal__c,
                                        AdditionalDiscountUnit__c,Show_Ramp__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,
                                        MRR_New__c,Price_After_Adjustment__c,SBQQ__Number__c,Finance_MRR__c,SBQQ__EffectiveQuantity__c,
                                        NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c,Deal_Reg_Teaming_Upsell_Discount__c,Contractual_Incentive_Discount__c,Total_base_discount__c
                                        FROM SBQQ__QuoteLine__c 
                                        WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductCode__c != null
                                        AND Line_Status__c != 'Existing'    
                                        ORDER BY SBQQ__Number__c];
        }
        
        oldppu = 0;
        newppu = 0;

        //Holds addition of All NewPrice values 
        Decimal sumOfNetPrice=0;  
        totalBaseExtendedPrice = totalStandardPrice = totalNetPrice = totalACV = totalMRR = totalPPU = totalNetToZscaler = totalZSRP = 0;  
        totalUnitRecommended = totalNetUnitPrice = totalPriceWithAdjustment = 0;  
        oldppu = newppu = 0;

        for(SBQQ__QuoteLine__c pli: ListOfQuoteLineDetails){
            
            sumOfNetPrice += (pli.SBQQ__NetTotal__c != null ? pli.SBQQ__NetTotal__c : 0);
            
            if(isSummitFederal || isTraditional){
                totalBaseExtendedPrice += (pli.Base_Extended_Price__c != null ? pli.Base_Extended_Price__c : 0);
                totalStandardPrice += (pli.Internal_List_Price__c != null ? pli.Internal_List_Price__c : 0);
                totalNetPrice = sumOfNetPrice;
                totalACV += (pli.ACV_New__c != null ? pli.ACV_New__c : 0);
                totalMRR += (pli.MRR_New__c != null ? pli.MRR_New__c : 0);
                totalPPU += (pli.Price_Per_Unit__c != null ? pli.Price_Per_Unit__c : 0);
                totalPriceWithAdjustment += (pli.Price_After_Adjustment__c != null ? pli.Price_After_Adjustment__c : 0);
            }
            
            if(isSummitDiscount){
                totalBaseExtendedPrice += (pli.Base_Extended_Price__c != null ? pli.Base_Extended_Price__c : 0);
                totalZSRP += (pli.ZSRP__c != null ? pli.ZSRP__c : 0);
                totalNetPrice = sumOfNetPrice;
                totalACV += (pli.ACV_New__c != null ? pli.ACV_New__c : 0);
                totalMRR += (pli.MRR_New__c != null ? pli.MRR_New__c : 0);
            }
            
            if((pli.SBQQ__Product__r.Credit__c) && pli.SBQQ__Product__r.SBQQ__SubscriptionType__c == 'Renewable' && pli.SBQQ__ProductCode__c != APTS_CONSTANTS.PROD_SKU_PSUPPORT 
                    && pli.Line_Status__c != 'Cancelled'){
                    if(isTraditional){
                        if(isFy21SingleTier){
                            totalUnitRecommended = totalUnitRecommended + ((pli.Recomm_Net__c != null ? pli.Recomm_Net__c : 0)*pli.SBQQ__Quantity__c);
                            totalNetUnitPrice = totalNetUnitPrice + ((pli.Cart_Price_PUPY__c != null ? pli.Cart_Price_PUPY__c : 0)*pli.SBQQ__Quantity__c);
                        }
                        if(isFy21VolumeTier){
                            totalUnitRecommended = totalUnitRecommended + ((pli.Recomm_Net__c != null ? pli.Recomm_Net__c : 0)*pli.SBQQ__Quantity__c);
                            totalNetUnitPrice = totalNetUnitPrice + ((pli.SBQQ__NetTotal__c != null ? pli.SBQQ__NetTotal__c : 0)*pli.SBQQ__Quantity__c);
                        }
                    }
                    if(isSummitDiscount){
                        totalUnitRecommended = totalUnitRecommended + ((pli.Recomm_Net__c != null ? pli.Recomm_Net__c : 0)*pli.SBQQ__Quantity__c);
                        totalNetUnitPrice = totalNetUnitPrice + ((pli.SBQQ__NetTotal__c != null ? pli.SBQQ__NetTotal__c : 0)*pli.SBQQ__Quantity__c);
                    }
                }
            }
            if(totalUnitRecommended > 0){
                netVariance = Math.abs((totalUnitRecommended-totalNetUnitPrice)/totalUnitRecommended*100);
            }
            changeofPPU = oldppu != 0 ? ((newppu - oldppu) / oldppu) * 100 : 0; 
            return ListOfQuoteLineDetails;

    }

    Public List<SBQQ__QuoteLine__c> getListOfRecurringLineItems(){
        list<SBQQ__QuoteLine__c> ListOfRecurringLineItems = new list<SBQQ__QuoteLine__c>();
        // Query for Recurring Lines....
        ListOfRecurringLineItems = [SELECT Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,
                                    SBQQ__Product__c,SBQQ__Product__r.Pricing_Meter__c,
                                    SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__ListPrice__c,
                                    Base_Extended_Price__c, Adjustment_Type__c,Adjustment__c, ZSRP__c, 
                                    Customer_Discount__c, Co_sell_Discount__c,SBQQ__NetPrice__c, Blended_Discount__c, 
                                    ACV_New__c,MRR__c,Net_PUPY__c,Recomm_Net__c,Cart_Price_PUPY__c,
                                    SBQQ__ChargeType__c,SBQQ__Product__r.Credit__c,Net_to_Zscaler__c,
                                    TCV__c,PartnerDisc__c,Deal_Reg_Sourced_Discount__c,Deal_Reg_Teaming_Reseller_Discount__c,
                                    Renewal_Deal_Reg_Discount__c,New_Logo_Discount__c,Internal_List_Price__c,
                                    Fulfillment_Discount__c,Distributor_Discount__c,Deployment_Discount__c,Product_Name_for_GSA__c,
                                    Net_Variance__c,SBQQ__TotalDiscountRate__c,SBQQ__SubscriptionTerm__c,SBQQ__Discount__c,
                                    Recommended_Retail_Price__c,SBQQ__NetTotal__c,Show_Ramp__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,
                                    Line_Status__c,MRR_New__c,Original_PUPY__c,SBQQ__Number__c,Finance_MRR__c,SBQQ__EffectiveQuantity__c
                                    FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductCode__c != null 
                                    AND SBQQ__Product__r.SBQQ__SubscriptionType__c = 'Renewable' AND Line_Status__c != 'Cancelled'
                                    AND SBQQ__ProductCode__c != :APTS_CONSTANTS.PROD_SKU_PSUPPORT AND SBQQ__ProductCode__c !=: APTS_CONSTANTS.PROD_SKU_PSUPPORT_FED AND Line_Status__c != 'Renewed'
                                    AND Line_Status__c != 'Existing'
                                    ORDER BY SBQQ__Number__c];

        if(!ListOfRecurringLineItems.isEmpty()){
            hasRecurringLines = true;
        }
        return ListOfRecurringLineItems;
        
    }

    Public List<SBQQ__QuoteLine__c> getListOfRecurringRenewalLineItems(){
        list<SBQQ__QuoteLine__c> ListOfRecurringRenewalLineItems = new list<SBQQ__QuoteLine__c>();
        if(isLineItemCount < numberofLines ){
        ListOfRecurringRenewalLineItems = [SELECT Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,
                                            SBQQ__Product__c,SBQQ__Product__r.Pricing_Meter__c,
                                            SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__ListPrice__c,
                                            Base_Extended_Price__c, Adjustment_Type__c, Adjustment__c, ZSRP__c, 
                                            Customer_Discount__c, Co_sell_Discount__c, SBQQ__NetPrice__c, Blended_Discount__c, 
                                            ACV_New__c, MRR__c, Net_PUPY__c, Recomm_Net__c,Cart_Price_PUPY__c,
                                            SBQQ__ChargeType__c,SBQQ__Product__r.Credit__c,Net_to_Zscaler__c,
                                            TCV__c,PartnerDisc__c,Deal_Reg_Sourced_Discount__c,Deal_Reg_Teaming_Reseller_Discount__c,
                                            Renewal_Deal_Reg_Discount__c,New_Logo_Discount__c,Internal_List_Price__c,
                                            Fulfillment_Discount__c,Distributor_Discount__c,Deployment_Discount__c,Product_Name_for_GSA__c,
                                            Net_Variance__c,SBQQ__TotalDiscountRate__c,SBQQ__SubscriptionTerm__c,SBQQ__Discount__c,
                                            Recommended_Retail_Price__c,SBQQ__NetTotal__c,Show_Ramp__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,
                                            Line_Status__c,MRR_New__c,Original_PUPY__c,SBQQ__Number__c,Finance_MRR__c,SBQQ__EffectiveQuantity__c
                                            FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductCode__c != null 
                                            AND SBQQ__Product__r.SBQQ__SubscriptionType__c = 'Renewable' AND Line_Status__c != 'Cancelled'
                                            AND SBQQ__ProductCode__c != :APTS_CONSTANTS.PROD_SKU_PSUPPORT 
                                            AND SBQQ__ProductCode__c !=: APTS_CONSTANTS.PROD_SKU_PSUPPORT_FED 
                                            AND Line_Status__c = 'Renewed'
                                            AND Line_Status__c != 'Existing'
                                            ORDER BY SBQQ__Number__c];
        
        if(!ListOfRecurringRenewalLineItems.isEmpty())
            hasRecurringRenewalLines = true;
       }    
        return ListOfRecurringRenewalLineItems;
    }



    Public List<SBQQ__QuoteLine__c> getListOfOneTimeLineItems(){
        list<SBQQ__QuoteLine__c> ListOfOneTimeLineItems = new list<SBQQ__QuoteLine__c>();
        if(isLineItemCount < numberofLines ){
        ListOfOneTimeLineItems = [SELECT Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,
                                    SBQQ__Product__c,SBQQ__Product__r.Pricing_Meter__c,
                                    SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__ListPrice__c,
                                    Base_Extended_Price__c, Adjustment_Type__c, Adjustment__c, ZSRP__c, 
                                    Customer_Discount__c, Co_sell_Discount__c, SBQQ__NetPrice__c, Blended_Discount__c, 
                                    ACV_New__c, MRR__c, Net_PUPY__c, Recomm_Net__c,Cart_Price_PUPY__c,
                                    SBQQ__ChargeType__c,SBQQ__Product__r.Credit__c,Net_to_Zscaler__c,
                                    TCV__c,PartnerDisc__c,Deal_Reg_Sourced_Discount__c,Deal_Reg_Teaming_Reseller_Discount__c,
                                    Renewal_Deal_Reg_Discount__c,New_Logo_Discount__c,Internal_List_Price__c,
                                    Fulfillment_Discount__c,Distributor_Discount__c,Deployment_Discount__c,
                                    Net_Variance__c,SBQQ__TotalDiscountRate__c,SBQQ__SubscriptionTerm__c,SBQQ__Discount__c,
                                    Recommended_Retail_Price__c,SBQQ__NetTotal__c,Product_Name_for_GSA__c,
                                    Show_Ramp__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,Line_Status__c,MRR_New__c,
                                    Original_PUPY__c,SBQQ__Number__c,Finance_MRR__c,SBQQ__EffectiveQuantity__c
                                    FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductCode__c != null 
                                    AND SBQQ__Product__r.SBQQ__SubscriptionType__c != 'Renewable' AND Line_Status__c != 'Cancelled'
                                    AND Line_Status__c != 'Existing'
                                    ORDER BY SBQQ__Number__c];

        if(!ListOfOneTimeLineItems.isEmpty()){
            hasOneTimeLines = true;
        }
        }
        return ListOfOneTimeLineItems;
        
    }

    Public void getSupportLineItem(){
        for(SBQQ__QuoteLine__c objSupportLine :[SELECT Id,SBQQ__ProductCode__c,
                                                Base_Extended_Price__c,TCV__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c,NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__Quote__c =: quoteId 
                                                AND SBQQ__ProductCode__c = :APTS_CONSTANTS.PROD_SKU_PSUPPORT 
                                                AND Line_Status__c != 'Cancelled'
                                                LIMIT 1] )
        {
            hasSupportLine = true;
            if(objSupportLine.SBQQ__NetTotal__c != null){
                supportNetPrice = objSupportLine.SBQQ__NetTotal__c;
            }
            double BaseExtendedPrice = 0.00;
    
            if(isSummitDiscount && objSupportLine.Base_Extended_Price__c != null){
                BaseExtendedPrice = objSupportLine.Base_Extended_Price__c.setScale(2);
            }
               
            if((isTraditional || isPartnerSummit) && objSupportLine.Base_Extended_Price__c != null){
                BaseExtendedPrice = objSupportLine.Base_Extended_Price__c.setScale(2);
            }
    
            if(BaseExtendedPrice > 0){
                supportDiscount = ((BaseExtendedPrice - supportNetPrice)/BaseExtendedPrice)*100;
            }  
        }    
 
    }

        // Approvals...
        public list<string> getApprovalExceptionsList(){
            Set<String> exceptionSet = new set<String>();
            List<string> exceptionList = new List<string>();
            Set<String> approvalReqStatusSet = new set<String>();
            if(IsApproved)
                approvalReqStatusSet.add('Approved');
            else{
                approvalReqStatusSet.add('Rejected');
            }
    
            for(sbaa__Approval__c appr : [SELECT Id, sbaa__ApprovalStep__c, sbaa__Status__c,
                                         sbaa__AssignedTo__c, sbaa__AssignedTo__r.Name,
                                         sbaa__AssignedGroupId__c,sbaa__AssignedToMe__c,
                                         sbaa__Approver__c, sbaa__CommentsLong__c,Quote__c,
                                         sbaa__Rule__c,sbaa__Rule__r.Name,Quote__r.Bill_to__r.Billing_Frequency__c,
                                         Quote__r.Bill_to__r.Payment_Terms__c,Quote__r.Total_Discount_Without_Support__c,
                                         Quote__r.SBQQ__SubscriptionTerm__c,Quote__r.SBQQ__BillingFrequency__c,
                                         Quote__r.SBQQ__PaymentTerms__c,Quote__r.Record_Type_Name__c,
                                         Quote__r.Previous_MRR_Approval__c,Quote__r.Current_Quote_MRR__c,
                                         Quote__r.Renewal_MRR_Change_Approval__c,Rule_Description__c
                                         FROM sbaa__Approval__c
                                         WHERE Quote__c =: quoteId  AND sbaa__Status__c IN: approvalReqStatusSet AND (
                                         sbaa__AssignedTo__c != NULL OR sbaa__AssignedGroupId__c != NULL)] )
            {
                String str = '';
                str = appr.Rule_Description__c;
                
                if(str != null && str != ''){
                   exceptionSet.add(str);
                }    
                
            }
            exceptionList.addAll(exceptionSet);
            return exceptionList;
           
        }
    
    
        public list<string> getMyApprovalExceptionsList(){
            Set<String> exceptionSet = new set<String>();
            List<string> exceptionList = new List<string>();
            Set<String> approvalReqStatusSet = new set<String>();
            approvalReqStatusSet.add('Assigned');
            approvalReqStatusSet.add('Requested');
    
            Set<String> GroupIdSet = new Set<String>();
            for(GroupMember gm : [SELECT GroupId,Id,UserOrGroupId,Group.Type
                                 FROM GroupMember 
                                 WHERE UserOrGroupId =: ApproverId AND Group.Type = 'Regular']){
                                 GroupIdSet.add(String.valueOf(gm.GroupId));
            }   
            
            for(sbaa__Approval__c appr : [SELECT Id, sbaa__ApprovalStep__c, sbaa__Status__c,
                                        sbaa__AssignedTo__c, sbaa__AssignedTo__r.Name,
                                        sbaa__AssignedGroupId__c,sbaa__AssignedToMe__c,
                                        sbaa__Approver__c, sbaa__CommentsLong__c,Quote__c,
                                        sbaa__Rule__c,sbaa__Rule__r.Name,Rule_Description__c,
                                        Quote__r.Net_Variance_Weighted_Avg_Approval__c,
                                        Quote__r.Manual_Adjustment__c,sbaa__ApprovalChain__r.Name  
                                        FROM sbaa__Approval__c
                                        WHERE Quote__c =: quoteId  AND sbaa__Status__c IN: approvalReqStatusSet 
                                        AND (sbaa__AssignedTo__c  =:ApproverId OR sbaa__AssignedGroupId__c IN : GroupIdSet)
                                        ORDER BY sbaa__ApprovalChain__r.Name])
            {
                    String str = '';
                    str = appr.Rule_Description__c;
                    if(str.contains('net variance')){
                        str = str +' '+appr.Quote__r.Net_Variance_Weighted_Avg_Approval__c+'%';
                    }
                    if(str.contains('manual adjustment')){
                        str = str +' '+appr.Quote__r.Manual_Adjustment__c+'%';
                    }
                    
                    if(str != null && str != ''){
                        exceptionSet.add(str);
                    }   
            }
            exceptionList.addAll(exceptionSet);
            return exceptionList;   
        }
    
    
        public list<string> getOtherApprovalExceptionsList(){
            Set<String> exceptionSet = new set<String>();
            Set<String> approverExceptionSet = new set<String>();
            List<string> exceptionList = new List<string>();
            Set<String> approvalReqStatusSet = new set<String>();
            approvalReqStatusSet.add('Assigned');
            approvalReqStatusSet.add('Requested');
            
            Set<String> GroupIdSet = new Set<String>();
            for(GroupMember gm : [SELECT GroupId,Id,UserOrGroupId,Group.Type
                                 FROM GroupMember 
                                 WHERE UserOrGroupId =: ApproverId AND Group.Type = 'Regular']){
                GroupIdSet.add(String.valueOf(gm.GroupId));
            }
            
            for(sbaa__Approval__c appr : [SELECT Id, sbaa__ApprovalStep__c, sbaa__Status__c,
                                        sbaa__AssignedTo__c, sbaa__AssignedTo__r.Name,
                                        sbaa__AssignedGroupId__c,sbaa__AssignedToMe__c,
                                        sbaa__Approver__c, sbaa__CommentsLong__c,Quote__c,
                                        sbaa__Rule__c,sbaa__Rule__r.Name,Rule_Description__c,
                                        Quote__r.Net_Variance_Weighted_Avg_Approval__c,
                                        Quote__r.Manual_Adjustment__c,sbaa__ApprovalChain__r.Name  
                                        FROM sbaa__Approval__c
                                        WHERE Quote__c =: quoteId AND sbaa__Status__c IN: approvalReqStatusSet 
                                        AND (sbaa__AssignedTo__c =:ApproverId OR sbaa__AssignedGroupId__c IN : GroupIdSet)
                                        ORDER BY sbaa__ApprovalChain__r.Name])
            {
                    String str = '';
                    str = appr.Rule_Description__c;
                    if(str.contains('net variance')){
                        str = str +' '+appr.Quote__r.Net_Variance_Weighted_Avg_Approval__c+'%';
                    }
                    if(str.contains('manual adjustment')){
                        str = str +' '+appr.Quote__r.Manual_Adjustment__c+'%';
                    }
                    if(str != null && str != ''){
                        exceptionSet.add(str);
                    }
            }
            
            for(sbaa__Approval__c appr : [SELECT Id, sbaa__ApprovalStep__c, sbaa__Status__c,
                                          sbaa__AssignedTo__c, sbaa__AssignedTo__r.Name,
                                          sbaa__AssignedGroupId__c,sbaa__AssignedToMe__c,
                                          sbaa__Approver__c, sbaa__CommentsLong__c,Quote__c,
                                          sbaa__Rule__c,sbaa__Rule__r.Name,Rule_Description__c,
                                          Quote__r.Net_Variance_Weighted_Avg_Approval__c,
                                          Quote__r.Manual_Adjustment__c,sbaa__ApprovalChain__r.Name  
                                          FROM sbaa__Approval__c
                                          WHERE Quote__c =: quoteId  AND sbaa__Status__c IN: approvalReqStatusSet
                                          AND (sbaa__AssignedTo__c != :ApproverId OR sbaa__AssignedGroupId__c NOT IN : GroupIdSet)
                                          ORDER BY sbaa__ApprovalChain__r.Name])
                {
                    string str = '';
                    str = appr.Rule_Description__c;
                    if(str.contains('net variance')){
                        str = str +' '+appr.Quote__r.Net_Variance_Weighted_Avg_Approval__c+'%';
                    }
                    if(str.contains('manual adjustment')){
                        str = str +' '+appr.Quote__r.Manual_Adjustment__c+'%';
                    }
                    if(str != null && str != '' && !exceptionSet.contains(str)){
                        system.debug('str '+str);
                        approverExceptionSet.add(str);
                    }
                                                    
                }
            
            system.debug('exceptionSet '+exceptionSet);
            system.debug('approverExceptionSet '+approverExceptionSet);
            
            exceptionList.addAll(approverExceptionSet);
            
            if(!exceptionList.isEmpty()){
                return new List<String>{'- There are no other exceptions on the quote'};
            }
            return exceptionList;
            
        }
    
        public String getRejectedBy(){
            String rejectedBy = '';
            
            for(sbaa__Approval__c appr : [SELECT Id, sbaa__ApprovalStep__c, sbaa__Status__c,
                                            sbaa__AssignedTo__c, sbaa__AssignedTo__r.Name,
                                            sbaa__AssignedGroupId__c,sbaa__AssignedToMe__c,
                                            sbaa__Approver__c, sbaa__CommentsLong__c,Quote__c,
                                            sbaa__Rule__c,sbaa__Rule__r.Name,Quote__r.Bill_to__r.Billing_Frequency__c,
                                            Quote__r.Bill_to__r.Payment_Terms__c,
                                            Quote__r.SBQQ__SubscriptionTerm__c,Quote__r.SBQQ__BillingFrequency__c,
                                            Quote__r.SBQQ__PaymentTerms__c,sbaa__RejectedBy__c,sbaa__ApprovedBy__c,
                                            sbaa__RejectedBy__r.Name
                                            FROM sbaa__Approval__c
                                            WHERE Quote__c =: quoteId  AND sbaa__Status__c = 'Rejected']){
                                                
                                                if(appr.sbaa__CommentsLong__c != null){
                                                    rejectedBy = appr.sbaa__RejectedBy__r.Name;
                                                }
                                            
                                            }
            return rejectedBy;
        }
        
    
        public String getRejectionReason(){
            String reason = '';

            for(sbaa__Approval__c appr : [SELECT Id, sbaa__ApprovalStep__c, sbaa__Status__c,
                                            sbaa__AssignedTo__c, sbaa__AssignedTo__r.Name,
                                            sbaa__AssignedGroupId__c,sbaa__AssignedToMe__c,
                                            sbaa__Approver__c, sbaa__CommentsLong__c,Quote__c,
                                            sbaa__Rule__c,sbaa__Rule__r.Name,Quote__r.Bill_to__r.Billing_Frequency__c,
                                            Quote__r.Bill_to__r.Payment_Terms__c,
                                            Quote__r.SBQQ__SubscriptionTerm__c,Quote__r.SBQQ__BillingFrequency__c,
                                            Quote__r.SBQQ__PaymentTerms__c
                                            FROM sbaa__Approval__c
                                            WHERE Quote__c =: quoteId  AND sbaa__Status__c = 'Rejected'] ){
                                                    
                                                string reasonStr = '';
                                                if(appr.sbaa__CommentsLong__c != null) {
                                                    reasonStr = appr.sbaa__CommentsLong__c; 
                                                }
                                                reason +=  reasonStr + ' ';
                                           }
            
            if(reason == null || reason == ''){
                reason = 'No Rejection Reason Provided.';
            }
            
            return reason ;
        }
}