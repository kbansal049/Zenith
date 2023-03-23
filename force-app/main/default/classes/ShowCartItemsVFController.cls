/**
 * @description       : 
 * @author            : Jade Global
 * @group             : 
 * @last modified on  : 05-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-21-2021   Jade Global   Initial Version
**/
global class ShowCartItemsVFController {
    
    public SBQQ__Quote__c quote {get;set;}
    public Boolean isPartnerSummit {get;set;}
    public Boolean isPartnerAdjustment {get;set;}
    public Boolean isTraditional {get;set;}
    public Boolean isSummitFederal {get;set;}

    public Boolean isFy21VolumeTier { get; set; }
    public Boolean isFy21SingleTier { get; set; }
    public List<CoSellAtivity> coSellList { get; private set; }
    public list<SBQQ__QuoteLine__c> quoteLineList {get;set;}
    public list<SBQQ__Subscription__c> subscriptionsListTraditional {get;set;}
    public list<SBQQ__Subscription__c> subscriptionsListFederal {get;set;}
    public list<SBQQ__Subscription__c> subscriptionsListPartnerSummit {get;set;}
    public list<SBQQ__Subscription__c> subscriptionsListSummitDiscount {get;set;}
    public list<SBQQ__QuoteLine__c> listOfRecurringLineItems {get;set;}
    public list<SBQQ__QuoteLine__c> listOfRecurringRenewalLineItems {get;set;}
    public list<SBQQ__QuoteLine__c> listOfOneTimeLineItems {get;set;}
    public list<SBQQ__QuoteLine__c> ListOfQuoteLineDetails {get;set;}

    public List<Billing_Schedule__c> lstBillingSchedules {get;set;}

    public AnnualBreakdownYWSUtil.YearWiseSplitWrapper yearWiseSplit { get; set; }
    
    public Boolean showDRSourced {get;set;}
    public Boolean showDRTeamResell {get;set;}
    public Boolean showDRTeamTech {get;set;}
    public Boolean isSummitDiscount {get;set;}
    
    public Boolean isRenewal {get;set;}
    public Boolean isAmendement {get;set;}
    public String priceListName {get; set;}
    public Boolean hasRecurringLines {get;set;}

    public Boolean hasRecurringRenewalLines {get;set;}

    public Boolean hasOneTimeLines {get;set;}
    public Boolean hasSupportLine {get;set;}
   
    public Double netVariance {get; set;}
    public Decimal totalUnitRecommendedNet {get; set;}
    public Decimal totalNetPUPY {get; set;}
    public Decimal totalUnitRecommended {get; set;}
    public Decimal totalPriceWithAdjustment {get; set;}

    public string url {get;set;}
    public String quoteRecordId {get;set;}
    public String isClickFromQLE {get;set;}
    public Boolean showBtnOnQLE {get;set;}

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
    public Decimal totalNetUnitPrice {get; set;}
    public Decimal noOfUsers = 0;

    public Decimal oldppu{get;set;}
    public Decimal newppu{get;set;}
    public Decimal changeofPPU{get;set;}

    // Approvals Section on Email Template 
    public String InstanceURL{get; set;}
    public ID ApproverId{get; set;}
    public ID ApprovalRequestId{get; set;}
    public boolean IsAssignment {get; set;}
    public boolean IsApproved {get; set;}
    public boolean IsApproveOrReject {get; set;}
    public Boolean IsShowApprovalSection {get;set;}
    public boolean IsEmailTemplateView {get;set;}
    public boolean IsShowCartView {get;set;}

    public String quoteId {get;set;}
    public String recordtypeName {get;set;}
    public Boolean isOrangePartnerContractedDiscount { get; set; }  
    public Boolean isOrangePartnerUpsellDiscount { get; set; }
    
    public list<sbaa__Approval__c> approvalList {get;set;}

    //  Collapsible table...
    public id pid {get;set;}
    public boolean showChild {get;set;}
    public List<WrapperList> wList {get;set;}
    public String BtnValue {get;set;}

    // IBA-942 START
    public Boolean isBundleAssociated {get; set;}
    // IBA-942 END

    public ShowCartItemsVFController(){

        quote = new SBQQ__Quote__c();
        quoteLineList = new list<SBQQ__QuoteLine__c>();
        subscriptionsListTraditional = new list<SBQQ__Subscription__c>();
        subscriptionsListFederal = new list<SBQQ__Subscription__c>();
        subscriptionsListPartnerSummit = new list<SBQQ__Subscription__c>();
        subscriptionsListSummitDiscount = new list<SBQQ__Subscription__c>();
        listOfRecurringLineItems = new list<SBQQ__QuoteLine__c>();
        listOfRecurringRenewalLineItems = new list<SBQQ__QuoteLine__c>();
        listOfOneTimeLineItems = new list<SBQQ__QuoteLine__c>();
        ListOfQuoteLineDetails = new list<SBQQ__QuoteLine__c>();

        lstBillingSchedules = new List<Billing_Schedule__c>();
        approvalList = new List<sbaa__Approval__c>();

        url  = System.Url.getSalesforceBaseURL().toExternalForm();
        isFy21VolumeTier = false;
        isFy21SingleTier = false;
        isRenewal = false;
        isAmendement = false;
        isOrangePartnerContractedDiscount = false;
        isOrangePartnerUpsellDiscount = false;
        String quoteId = ApexPages.currentPage().getParameters().get('id');
        quoteRecordId = ApexPages.currentPage().getParameters().get('id');
        isClickFromQLE = ApexPages.currentPage().getParameters().get('isClickQLE');
        if(isClickFromQLE == 'Yes'){
            showBtnOnQLE = true;
        }else{
            showBtnOnQLE = false;
        }
        
        coSellList = new List<CoSellAtivity>();
        priceListName = '';
        isSummitFederal = false;

        hasRecurringLines = false;
        hasRecurringRenewalLines=false;
        hasOneTimeLines = false;
        hasSupportLine = false;
        totalBaseExtendedPrice = totalStandardPrice = totalNetPrice = totalACV = totalMRR = totalPPU = totalNetToZscaler = totalZSRP = 0;
        totalUnitRecommended = totalNetUnitPrice = totalPriceWithAdjustment = 0;
        supportNetPrice = supportDiscount = netVariance = 0.00;

        yearWiseSplit = new AnnualBreakdownYWSUtil.YearWiseSplitWrapper();

        // Collapsible Table...
        BtnValue = '+';
        wList = new List<WrapperList>();
        
        // Query for Quote record..
        if(quoteId != null && quoteId != ''){
            
            //CR# 3959 - Added Summit_Distribution__c,Transacting_Distributor_Discount__c to below query
            quote = [SELECT id, 
                        Name, SBQQ__Account__r.Name, Opportunity_Owner__c, 
                        Record_Type_Name__c, SBQQ__Opportunity2__r.Name, 
                        ACV__c, Total_Blended_Discount__c, Bill_to__r.Name, 
                        Current_Quote_MRR__c, Partner_Program__c, Price_List__c,Quote_Extension__r.message_according_to_netVariance__c,
                        SBQQ__Opportunity2__r.Deal_Reg_Margin__c,SBQQ__Opportunity2__r.Deal_Reg_Partner_Teaming_Reseller__c,
                        SBQQ__Opportunity2__r.Partner_Margin_Adjustment__c,
                        Total_PUPY_Discount__c,TCV__c,Cart_PUPY_without_Support_DAS_Training__c,
                        Subscription_Discount_without_Support__c,Summit_Distribution__c,Transacting_Distributor_Discount__c,
                        AW_Discount__c,POV_Discount__c,AW_POV_Discount__c,
                        Fulfillment_Discount__c,
                        SBQQ__Opportunity2__r.Deal_Reg_Margin__r.Name,
                        SBQQ__BillingFrequency__c,SBQQ__PaymentTerms__c,SBQQ__Account__r.Customer_Sentiment__c,
                        SBQQ__Account__r.Success_Stage__c,Generate_Year_wise_Split__c,Number_of_Users__c,
                        SBQQ__SubscriptionTerm__c,Recomm_PUPY_without_Support_DAS_Training__c,
                        ACV_New__c,Net_variance_weighted_avg__c,Deal_Reg_Sourced_Discount__c,
                        SBQQ__Opportunity2__r.Deal_Reg_Partner_Teaming_Reseller__r.Name,
                        Deal_Reg_Teaming_Reseller_Discount__c,Renewal_MRR_Change_Approval__c,
                        Previous_MRR_Approval__c,Rep_Comp_Impacted__c,Document_Type__c,Number_Of_Year_Wise_Split_Years__c,
                        SBQQ__Distributor__c,SBQQ__Distributor__r.Name,SBQQ__StartDate__c,
                        SBQQ__EndDate__c,Total_Discount_Without_Support__c,SBQQ__Partner__c,
                        SBQQ__Partner__r.Name,Opportunity_Record_Type__c,Contract_Number__c,Cloud_Type__c
                        FROM SBQQ__Quote__c 
                        WHERE Id =: quoteId];

            // IBA-942 - START
            isBundleAssociated = isProductNamesAssociatedToQuoteLines(quoteId);
            // IBA-942 - END
            
            //added by Rakshitha CR#3507 and modified the if blocks
            //not able to use getAll() methods becuase of 255 character limit
            Map<String,List<String>> showCartSettingMap = new Map<String,List<String>>();
            For(Price_List_Setting__mdt  showCartSettingRec : [SELECT DeveloperName,Price_List__c FROM Price_List_Setting__mdt  ]){
                if(!String.IsEmpty(showCartSettingRec.Price_List__c)){
                    showCartSettingMap.put(showCartSettingRec.DeveloperName,showCartSettingRec.Price_List__c.split(';'));
                }
            }
            priceListName = quote.Price_List__c;
            // IBA-942 - Added isBundleAssociated flag
            if((priceListName != null && showCartSettingMap.get('Volume_Tier').contains(priceListName)) || isBundleAssociated){
                isFy21VolumeTier = true;
            }else if(priceListName != null && showCartSettingMap.get('Federal_Bundle').contains(priceListName)){
                isFy21VolumeTier = true;
            }else if(priceListName != null && showCartSettingMap.get('Commercial').contains(priceListName)){
                isFy21SingleTier = true;
            }else if(priceListName != null && showCartSettingMap.get('Federal_Editions').contains(priceListName)){
                isFy21SingleTier = true;
            }

            if(quote.Opportunity_Record_Type__c == 'Renewal Opportunity'){
                isRenewal = true;
                recordtypeName = 'Renewal';
            } else if(quote.Opportunity_Record_Type__c == 'Upsell Opportunity' || quote.Opportunity_Record_Type__c == 'Upsell Opportunity Closed'){
                isAmendement = true;
                recordtypeName = 'Amendment';
            }else if(quote.Opportunity_Record_Type__c == 'New Business' || quote.Opportunity_Record_Type__c == 'New Business Close'){
                recordtypeName = 'New Business';
            }
            //ends here
            
            // added by Rakshitha CR# 4405-->
            if(System.Label.Contract_Number.split(',').contains(quote.Contract_Number__c)){
                if(isAmendement || isRenewal){
                    isOrangePartnerUpsellDiscount = true;
                }
                isOrangePartnerContractedDiscount = true;
            }
            //end
            
            //CR# 3959 Start
            if(quote.Bill_to__c != null){
                //CR# 4708
                if(quote.Summit_Distribution__c && !isRenewal){
                    coSellList.add(new CoSellAtivity('Fulfilment',
                                                    quote.Bill_to__r.Name,
                                                    quote.Transacting_Distributor_Discount__c != null ? quote.Transacting_Distributor_Discount__c : 0));                                                
                                                    
                }else if(!quote.Summit_Distribution__c){
                    coSellList.add(new CoSellAtivity('Fulfilment',
                                                    quote.Bill_to__r.Name,
                                                    quote.Fulfillment_Discount__c != null ? quote.Fulfillment_Discount__c : 0));                                                
                                                    
                }
            }
            //CR# 3959 End
            
            if(quote.SBQQ__Opportunity2__r.Deal_Reg_Margin__c != null){
                coSellList.add(new CoSellAtivity('Deal Registration',
                                                 quote.SBQQ__Opportunity2__r.Deal_Reg_Margin__r.Name,
                                                 quote.Deal_Reg_Sourced_Discount__c != null ? quote.Deal_Reg_Sourced_Discount__c : 0));
            }
            
            if(quote.SBQQ__Opportunity2__r.Deal_Reg_Partner_Teaming_Reseller__c != null){
                coSellList.add(new CoSellAtivity('Reseller',
                                                 quote.SBQQ__Opportunity2__r.Deal_Reg_Partner_Teaming_Reseller__r.Name,
                                                 quote.Deal_Reg_Teaming_Reseller_Discount__c != null ? quote.Deal_Reg_Teaming_Reseller_Discount__c : 0));
            }
                    
            showDRSourced = quote.SBQQ__Opportunity2__r.Deal_Reg_Margin__c != null ? true : false;
            showDRTeamResell = quote.SBQQ__Opportunity2__r.Deal_Reg_Partner_Teaming_Reseller__c != null ? true : false;
            showDRTeamTech = false;
            
            isPartnerAdjustment = quote.SBQQ__Opportunity2__r.Partner_Margin_Adjustment__c && quote.Partner_Program__c != Label.Partner_Program_Summit_Discount;
            isPartnerSummit = quote.Partner_Program__c == Label.Partner_Program_Partner_Summit;
            isSummitDiscount = quote.Partner_Program__c == Label.Partner_Program_Summit_Discount;
            isTraditional = quote.Partner_Program__c == Label.Partner_Program_Traditional;
            isSummitFederal = quote.Partner_Program__c == Label.Partner_Program_Summit_Federal; 
                  
            // Query the quote lines....
            quoteLineList = [SELECT Id,Name,SBQQ__ProductName__c, SBQQ__ProductCode__c, 
                            SBQQ__ListPrice__c, Volume_Disc__c, Recommended_Retail_Price__c, 
                            SBQQ__Quantity__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c,
                            Base_Extended_Price__c, Adjustment_Type__c, Adjustment__c, ZSRP__c, 
                            Customer_Discount__c, Co_sell_Discount__c, SBQQ__NetPrice__c, Blended_Discount__c, 
                            ACV_New__c, MRR__c, Net_PUPY__c, Recomm_Net__c,Cart_Price_PUPY__c,
                            SBQQ__ChargeType__c,SBQQ__Product__r.Credit__c,Net_to_Zscaler__c,
                            TCV__c,PartnerDisc__c,Deal_Reg_Sourced_Discount__c,Deal_Reg_Teaming_Reseller_Discount__c,
                            Renewal_Deal_Reg_Discount__c,New_Logo_Discount__c,Internal_List_Price__c,
                            Fulfillment_Discount__c,Distributor_Discount__c,Deployment_Discount__c,
                            Net_Variance__c,SBQQ__Discount__c,AdditionalDiscountUnit__c,SBQQ__Number__c,
                            SBQQ__RequiredBy__c,SBQQ__NetTotal__c,Show_Ramp__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,
                            MRR_New__c,Finance_MRR__c,SBQQ__EffectiveQuantity__c,NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c,Deal_Reg_Teaming_Upsell_Discount__c,Contractual_Incentive_Discount__c,Total_base_discount__c
                            FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductCode__c != null
                            AND Line_Status__c != 'Existing'
                            ORDER BY SBQQ__Number__c]; 

            // Create Wrapper List for Collapsible Table...
            for(SBQQ__QuoteLine__c qline: quoteLineList){
                WrapperList objWrapper = new WrapperList(qline,false,'+');
                wList.add(objWrapper);
            }              
                            
            
            // Query the subscriptions....
            if(quote != null && quote.SBQQ__Account__c != null){

                subscriptionsListTraditional =  [SELECT id,SBQQ__Account__c,SBQQ__Account__r.Name,Partner_Program__c,
                                                SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__StartDate__c,
                                                SBQQ__EndDate__c,Base_Extended_Price__c,Volume_Disc__c,SBQQ__PartnerDiscount__c,
                                                New_Logo_Discount__c,Internal_List_Price__c,SBQQ__NetPrice__c,ACV_New__c,
                                                MRR__c,Recomm_Net__c,Net_to_Zscaler__c,Product_Code__c,Deal_Reg_Sourced_Discount__c,
                                                Deal_Reg_Teaming_Reseller_Discount__c,Renewal_Deal_Reg_Discount__c,Distributor_Discount__c,
                                                Subscription_Term__c,Partner_Disc__c,SBQQ__Discount__c,AdditionalDiscountUnit__c,
                                                Total_Discount__c,Net_Total__c,Net_PUPY__c,Net_Variance__c,MRR_New__c,
                                                NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c,Deal_Reg_Teaming_Upsell_Discount__c,Contractual_Incentive_Discount__c,SBQQ__ListPrice__c,Total_base_discount__c
                                                FROM SBQQ__Subscription__c 
                                                WHERE SBQQ__Account__c =: quote.SBQQ__Account__c
                                                AND Partner_Program__c = :Label.Partner_Program_Traditional
                                                AND SBQQ__Contract__r.Status = 'Activated' AND SBQQ__Contract__r.IsExpired__c=false];
                
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
                                                MRR_New__c,NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c
                                                FROM SBQQ__Subscription__c 
                                                WHERE SBQQ__Account__c =: quote.SBQQ__Account__c 
                                                AND Partner_Program__c = :Label.Partner_Program_Summit_Federal
                                                AND SBQQ__Contract__r.Status = 'Activated' AND SBQQ__Contract__r.IsExpired__c=false];


                subscriptionsListSummitDiscount =  [SELECT id,SBQQ__Account__c,SBQQ__Account__r.Name,Partner_Program__c,
                                                SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__StartDate__c,
                                                SBQQ__EndDate__c,Base_Extended_Price__c,Volume_Disc__c,SBQQ__PartnerDiscount__c,
                                                New_Logo_Discount__c,Internal_List_Price__c,SBQQ__NetPrice__c,ACV_New__c,
                                                MRR__c,Recomm_Net__c,Net_to_Zscaler__c,SBQQ__ListPrice__c,Recommended_Retail_Price__c,
                                                ZSRP__c,AW_Discount__c,POV_Discount__c,AW_POV_Discount__c,Fulfillment_Discount__c,Deployment_Discount__c,
                                                Co_sell_Discount__c,Blended_Discount__c,Product_Code__c,Deal_Reg_Sourced_Discount__c,
                                                Deal_Reg_Teaming_Reseller_Discount__c,Renewal_Deal_Reg_Discount__c,Distributor_Discount__c,
                                                Subscription_Term__c,Partner_Disc__c,SBQQ__Discount__c,AdditionalDiscountUnit__c,
                                                Total_Discount__c,Net_Total__c,Net_PUPY__c,Net_Variance__c,MRR_New__c,
                                                NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c
                                                FROM SBQQ__Subscription__c 
                                                WHERE SBQQ__Account__c =: quote.SBQQ__Account__c 
                                                AND Partner_Program__c = :Label.Partner_Program_Summit_Discount
                                                AND SBQQ__Contract__r.Status = 'Activated' AND SBQQ__Contract__r.IsExpired__c=false];
            }
            
            // Query for Recurring Lines....
            listOfRecurringLineItems = [SELECT Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,
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
                                        Recommended_Retail_Price__c,SBQQ__NetTotal__c,Show_Ramp__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,
                                        Line_Status__c,MRR_New__c,Finance_MRR__c,SBQQ__EffectiveQuantity__c,NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c
                                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductCode__c != null 
                                        AND SBQQ__Product__r.SBQQ__SubscriptionType__c = 'Renewable' AND Line_Status__c != 'Cancelled'
                                        AND SBQQ__ProductCode__c != :APTS_CONSTANTS.PROD_SKU_PSUPPORT  
                                        AND SBQQ__ProductCode__c !=: APTS_CONSTANTS.PROD_SKU_PSUPPORT_FED
                                        AND Line_Status__c != 'Renewed' 
                                        AND Line_Status__c != 'Existing' 
                                        ORDER BY SBQQ__Number__c];
            
            if(!listOfRecurringLineItems.isEmpty()){
                hasRecurringLines = true;
            }

            // Query for Recurring Renewal Lines....
            listOfRecurringRenewalLineItems = [SELECT Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,
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
                                                Recommended_Retail_Price__c,SBQQ__NetTotal__c,Show_Ramp__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,
                                                Line_Status__c,MRR_New__c,Original_PUPY__c,Finance_MRR__c,SBQQ__EffectiveQuantity__c,
                                                NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c
                                                FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductCode__c != null 
                                                AND SBQQ__Product__r.SBQQ__SubscriptionType__c = 'Renewable' AND Line_Status__c != 'Cancelled'
                                                AND SBQQ__ProductCode__c != :APTS_CONSTANTS.PROD_SKU_PSUPPORT 
                                                AND SBQQ__ProductCode__c !=: APTS_CONSTANTS.PROD_SKU_PSUPPORT_FED
                                                AND Line_Status__c = 'Renewed'
                                                AND Line_Status__c != 'Existing'
                                                ORDER BY SBQQ__Number__c];


            if(!listOfRecurringRenewalLineItems.isEmpty()){
                hasRecurringRenewalLines = true;
            }

            // Query for One Time Lines...
            listOfOneTimeLineItems = [SELECT Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,
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
                                    Recommended_Retail_Price__c,SBQQ__NetTotal__c,Show_Ramp__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,
                                    Line_Status__c,MRR_New__c,Finance_MRR__c,SBQQ__EffectiveQuantity__c,NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c
                                    FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductCode__c != null 
                                    AND SBQQ__Product__r.SBQQ__SubscriptionType__c != 'Renewable' AND Line_Status__c != 'Cancelled'
                                    AND Line_Status__c != 'Existing'  
                                    ORDER BY SBQQ__Number__c];
            
            if(!listOfOneTimeLineItems.isEmpty()){
                hasOneTimeLines = true;
            }

            // Query for Support Lines....
            List<SBQQ__QuoteLine__c> supportLines = [SELECT Id,SBQQ__ProductCode__c,
                                                    Base_Extended_Price__c,TCV__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c,
                                                    Line_Status__c,NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c
                                                    FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId and 
                                                    SBQQ__ProductCode__c = :APTS_CONSTANTS.PROD_SKU_PSUPPORT and Line_Status__c != 'Cancelled'];
            if(!supportLines.isEmpty()){
                hasSupportLine = true;
                if(supportLines[0].SBQQ__NetTotal__c != null){
                    supportNetPrice = supportLines[0].SBQQ__NetTotal__c;
                }
                
                double BaseExtendedPrice = 0.00;
                if(isSummitDiscount && supportLines[0].Base_Extended_Price__c != null){
                    BaseExtendedPrice = supportLines[0].Base_Extended_Price__c.setScale(2);
                }
 
                if((isTraditional || isPartnerSummit) && supportLines[0].Base_Extended_Price__c != null){
                    BaseExtendedPrice = supportLines[0].Base_Extended_Price__c.setScale(2);
                }
                    
                if(BaseExtendedPrice > 0){
                    supportDiscount = ((BaseExtendedPrice - supportNetPrice)/BaseExtendedPrice)*100;
                }
                    
            }
            

            // Condition for YWS...
            if(quote.Document_Type__c != '') {                
                yearWiseSplit = AnnualBreakdownYWSUtil.getYearWiseSplitsList(quoteId);
            }
            
            
            // Query for Quote Line Details to visible on Cart Details Table...
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
                                        SBQQ__RequiredBy__c,MRR_New__c,Price_After_Adjustment__c,
                                        Finance_MRR__c,Apply_AW_POV_Discount__c,SBQQ__EffectiveQuantity__c,NS_Product_Name__c,NS_Product_SKU__c,Product_Name_for_GSA__c,Contractual_Incentive_Discount__c,Deal_Reg_Teaming_Upsell_Discount__c,Total_base_discount__c
                                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductCode__c != null
                                        AND Line_Status__c != 'Existing'
                                        ORDER BY SBQQ__Number__c];
            

            oldppu = 0;
            newppu = 0;

            //Holds addition of All NewPrice values 
            Decimal sumOfNetPrice=0;  
            totalBaseExtendedPrice = totalStandardPrice = totalNetPrice = totalACV = totalMRR = totalPPU = totalNetToZscaler = totalZSRP = 0;  
            totalUnitRecommended = totalNetUnitPrice = totalPriceWithAdjustment = 0;   
            oldppu = newppu = 0;

            for(SBQQ__QuoteLine__c pli: ListOfQuoteLineDetails){
                
                sumOfNetPrice += (pli.SBQQ__NetTotal__c != null ? pli.SBQQ__NetTotal__c : 0);
                
                if(isTraditional || isSummitFederal){
                    totalBaseExtendedPrice += (pli.Base_Extended_Price__c != null ? pli.Base_Extended_Price__c : 0);
                    totalStandardPrice += (pli.Internal_List_Price__c != null ? pli.Internal_List_Price__c : 0);
                    totalNetPrice = sumOfNetPrice;
                    totalACV += (pli.ACV_New__c != null ? pli.ACV_New__c : 0);
                    totalMRR += (pli.MRR_New__c != null ? pli.MRR_New__c : 0);
                    totalPPU += (pli.Net_PUPY__c != null ? pli.Net_PUPY__c : 0);
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
            
            // Display related Billing schedule records....
            lstBillingSchedules = [SELECT Id,Name,Quote__c,Amount__c,Billing_Date__c,Quote__r.Name 
                                    FROM Billing_Schedule__c
                                    WHERE Quote__c =: quoteId];
            
            
            // Display previous approver records...
            approvalList =  [SELECT Id,Approval_Rule_Name__c,sbaa__ApprovalStep__c, sbaa__Status__c, sbaa__ApprovedBy__r.Name, sbaa__CommentsLong__c,sbaa__Archived__c 
                            FROM sbaa__Approval__c WHERE Quote__c =: quoteId AND sbaa__Status__c ='Approved'
                            AND sbaa__Archived__c = false];
        }
    }

    public static Boolean isProductNamesAssociatedToQuoteLines(Id quoteIdOfQuote) {
        // IBA-942 START
        Boolean isValidQuoteLine = false;
        CPQ_Pricing_Parameters__mdt fy23PricingMetadata = CPQ_Pricing_Parameters__mdt.getInstance('Bundle_SKU_for_ShowCart');
        if (fy23PricingMetadata != null) {
            List<String> productCodeList = String.isNotBlank(fy23PricingMetadata.SKU_Code__c) ? 
                fy23PricingMetadata.SKU_Code__c.split(',') : new List<String>();
            List<SBQQ__QuoteLine__c> quoteLineList = getAssociatedQuoteLinesByProductNames(quoteIdOfQuote, productCodeList);
            isValidQuoteLine = !quoteLineList.isEmpty();
        }
        return isValidQuoteLine;
        // IBA-942 END
    }

    // IBA-942 START
    public static List<SBQQ__QuoteLine__c> getAssociatedQuoteLinesByProductNames(Id quoteIdOfQuote, List<String> productCodeList) {
        return [SELECT Id, SBQQ__ProductCode__c FROM SBQQ__QuoteLine__c WHERE SBQQ__ProductCode__c IN :productCodeList AND 
            SBQQ__Quote__c = :quoteIdOfQuote AND SBQQ__EffectiveQuantity__c > 0 ];
    }
    // IBA-942 END

    public Pagereference GetChildRecords(){
        List<WrapperList> temp = new List<WrapperList>();
        temp.addAll(wList);
        for(WrapperList objWrapper: wList){
            if(objWrapper.parentRecord.SBQQ__RequiredBy__c == pid){
                objWrapper.showRow = !objWrapper.showRow;
                objWrapper.styleClass = !objWrapper.showRow ? 'displayNone alignTextRight' : 'alignTextRight';
            }
            if(objWrapper.parentRecord.Id == pid){
                objWrapper.btnLabelVal = objWrapper.btnLabelVal == '+' ? '-' : '+';
            }
        }

        BtnValue = '-';
        return null;
    }
    
    public Pagereference onCancel(){
    // return to QLE.....
        PageReference resPg = Page.SBQQ__SB;
        resPg.getParameters().put('scontrolCaching','1');
        resPg.getParameters().put('id',quoteId);  
        resPg.setRedirect(true);
        return resPg;
    }


    public Class CoSellAtivity{
        public string Activity {get;set;}
        public string PartnerName {get;set;}
        public Decimal Margin {get;set;}
        
        public CoSellAtivity(String activity,String partName, Decimal margin){
            this.Activity = activity;
            this.PartnerName = partName;
            this.Margin = margin;
        }
        
    }

    public Class WrapperList{
        public SBQQ__QuoteLine__c parentRecord {get; set;}
        public Boolean showRow {get; set;}
        public String btnLabelVal {get;set;}
        public String styleClass {get;set;}

        public WrapperList(SBQQ__QuoteLine__c parentRecord, Boolean showChild, String btnLabelVal){
            this.parentRecord = parentRecord;
            this.showRow = parentRecord.SBQQ__RequiredBy__c == null ? true : false;
            this.btnLabelVal = '+';
            this.styleClass = !this.showRow ? 'displayNone alignTextRight' : 'alignTextRight';
        }        
    }
}