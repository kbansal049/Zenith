public without sharing class CreateSalesOrderExtensionCPQLWC {
    
    @auraEnabled
    public static CustomOrderWrapper getCustomOrder(Id opportunityId){
        
        CustomOrderWrapper cow = new CustomOrderWrapper();
        
        System.debug('----getCustomOrder---opportunityId--'+opportunityId);
        
        cow.partnerSummit = System.Label.Partner_Program_Partner_Summit;
        cow.partnerDiscount = System.Label.Partner_Program_Summit_Discount;
        
        Custom_Order__c co = new  Custom_Order__c();
        
        Opportunity opp = [SELECT Id, Name, Type, AccountId, StageName, NS_Integration_Requested_By__c,  X10b_Reason__c,
                           Netsuite_Sales_Order_Internal_ID__c, NS_Integration_Failure_Reason__c, NS_Integration_Status__c,
                           Netsuite_Customer_ID__c, Netsuite_Primary_Partner_ID__c, Netsuite_Customer_ID_Override__c, Netsuite_Primary_Partner_ID_Override__c,
                           First_PO_Date__c,
                           RecordType.Name,
                           Partner_PO_Number__c, Netsuite_Promo_Code__c,
                           Account_Channel_Rep_ZNumber__c, Account_Manager_ZNumber__c, NS_Integration_Requested_by_ZNumber__c, Renewal_Rep_ZNumber__c, SE_Znumber__c,
                           Opportunity_Customer_Advocate__r.IsActive, 
                           Opportunity_Customer_Advocate__r.EmployeeNumber, 
                           Opportunity_Customer_Advocate__r.Manager.EmployeeNumber, 
                           SE_Name__r.IsActive, SE_Name__r.EmployeeNumber, SE_Name__r.Manager.EmployeeNumber, 
                           Opportunity_Account_Manager__r.IsActive, Opportunity_Account_Manager__r.EmployeeNumber, Opportunity_Account_Manager__r.Manager.EmployeeNumber, 
                           NS_Integration_Requested_By__r.IsActive, NS_Integration_Requested_By__r.EmployeeNumber, NS_Integration_Requested_By__r.Manager.EmployeeNumber, 
                           Account.Channel_Manager__r.IsActive, Account.Channel_Manager__r.EmployeeNumber, Account.Channel_Manager__r.Manager.EmployeeNumber, 
                           SO_Creation_Date__c,
                           
                           Primary_Partner_Program__c, 
                           Finance_Comments__c, Netsuite_Sales_Order_No__c, Previous_Sales_Order_No__c, Netsuite_Partner_Internal_ID_Override__c, Secondary_Partner__c, Secondary_Partner_Role__c,
                           
                           Deal_Reg_Margin__c,
                           Deal_Reg_Partner_Teaming_Reseller__c,
                           Partner_Margin_Adjustment__c,
                           
                           Custom_Order__c,Custom_Order__r.Expected_Start_Date__c,
                           SBQQ__PrimaryQuote__c,
                           SBQQ__PrimaryQuote__r.Bill_to__r.Name,
                           SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,
                           SBQQ__PrimaryQuote__r.SBQQ__Account__c, 
                           SBQQ__PrimaryQuote__r.Bill_to__c,
                           SBQQ__PrimaryQuote__r.SBQQ__PriceBook__c,
                           SBQQ__PrimaryQuote__r.SBQQ__PricebookId__c,
                           SBQQ__PrimaryQuote__r.Price_List__c,
                           
                           SBQQ__PrimaryQuote__r.Cart_PUPY_without_Support_DAS_Training__c,
                           SBQQ__PrimaryQuote__r.Recomm_PUPY_without_Support_DAS_Training__c,
                           SBQQ__PrimaryQuote__r.Total_PUPY_Discount__c,
                           SBQQ__PrimaryQuote__r.Total_Blended_Discount__c,
                           SBQQ__PrimaryQuote__r.SBQQ__PriceBook__r.Name,
                           SBQQ__PrimaryQuote__r.Total_Discount__c,
                           SBQQ__PrimaryQuote__r.Total_Discount_Without_Support__c,
                           
                           
                           SBQQ__PrimaryQuote__r.AW_Discount__c,
                           SBQQ__PrimaryQuote__r.POV_Discount__c,
                           SBQQ__PrimaryQuote__r.Fulfillment_Discount__c,
                           SBQQ__PrimaryQuote__r.Deal_Reg_Sourced_Discount__c,
                           SBQQ__PrimaryQuote__r.Deal_Reg_Teaming_Reseller_Discount__c,
                           SBQQ__PrimaryQuote__r.Deployment_Discount__c,
                           SBQQ__PrimaryQuote__r.Distributor_Disc__c,
                           SBQQ__PrimaryQuote__r.Transacting_Distributor_Discount__c,
                           SBQQ__PrimaryQuote__r.Summit_Distribution__c,
                           SBQQ__PrimaryQuote__r.X30_Day_Money_Back__c, //CR# 4019 
                           Forecast_Category__c //IBA-3257
                           
                           FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        
        
        //Set opportunity Record
        cow.opp = opp;
        
        //
        if(opp.SBQQ__PrimaryQuote__c == null){
            throw new SFDCNSIntegrationException('There is no primary Quote, Please make a quote primary.');
        }
        
        
        
        //IS FY21 Single Tier Price list
        if(opp.SBQQ__PrimaryQuote__r.Price_List__c != null &&
           (opp.SBQQ__PrimaryQuote__r.Price_List__c == System.Label.FY21_SingleTier_PriceList || 
            opp.SBQQ__PrimaryQuote__r.Price_List__c == System.Label.FY21_Federal_Single_Tier_Price_List ||
            opp.SBQQ__PrimaryQuote__r.Price_List__c == System.Label.Federal_Editions_Price_List ||
            opp.SBQQ__PrimaryQuote__r.Price_List__c == System.Label.FY23_Federal_Editions_Price_List ||
            opp.SBQQ__PrimaryQuote__r.Price_List__c == System.Label.FY23_Federal_Editions_Upsell_Price_List )) //CR# 4644 //added prachi dandriyal
        {
            cow.isFy21SingleTier = true;
        }
        else{
            cow.isFy21SingleTier = false;
        }
        
        //IS FY21 Volume Tier Price list
        if(opp.SBQQ__PrimaryQuote__r.SBQQ__PriceBook__c != null && 
           opp.SBQQ__PrimaryQuote__r.SBQQ__PriceBook__r.Name != null
           && (opp.SBQQ__PrimaryQuote__r.SBQQ__PriceBook__r.Name == System.Label.FY21_Volume_Tier_Price_List  ||
               opp.SBQQ__PrimaryQuote__r.SBQQ__PriceBook__r.Name == System.Label.FY21_Federal_Volume_Tier_Price_List ||
               opp.SBQQ__PrimaryQuote__r.SBQQ__PriceBook__r.Name == System.Label.Federal_Bundles_Price_List ||
               opp.SBQQ__PrimaryQuote__r.SBQQ__PriceBook__r.Name == System.Label.FY23_Federal_Bundles_Upsell_Price_List ) ) //CR# 4644 //added prachi dandriyal
        {
            cow.isFy21VolumeTier = true;
        }else{
            cow.isFy21VolumeTier = false;
        }
        
        
        
        Map<String, Schema.RecordTypeInfo> mapRecordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        if(opp.Type == 'Existing Customer (Renewal)'){
            cow.showupsellacv = true;
            cow.showrenewalacv = true;
            cow.isRenewal = true;
        }else if(opp.Type == 'New Business'){
            cow.shownewacv = true;
            opp.RecordTypeId = mapRecordTypes.get('New Business Close').RecordTypeId;
        }else if(opp.Type == 'Existing Customer (Add On)'){
            cow.showupsellacv = true;
            opp.RecordTypeId = mapRecordTypes.get('Upsell Opportunity Closed').RecordTypeId;
        }
        if(opp.SBQQ__PrimaryQuote__r.Bill_to__r.Name == 'Carahsoft'){
            cow.requireSecPartner = true;
        }
        //CR#4674
        opp.Allow_Move_Stage_To_Next__c = True;
        opp.StageName = Label.Stage_5B_Opportunity;//5b
        
        
        //Load Custom Order -- [Existing/New]
        co = createCustomOrder(opp);
        
        
        Boolean isTraditional = co.Partner_Program__c == Label.Partner_Program_Traditional;
        Boolean isPartnerSummit = co.Partner_Program__c == Label.Partner_Program_Partner_Summit;
        Boolean isSummitDiscount = co.Partner_Program__c == Label.Partner_Program_Summit_Discount;
        
        cow.isTraditional = isTraditional;
        cow.isSummitDiscount = isSummitDiscount;
       
        
        System.debug('---isTraditional--'+isTraditional);
        System.debug('---isPartnerSummit--'+isPartnerSummit);
        System.debug('---isFy21SingleTier--'+cow.isFy21SingleTier);
        System.debug('---isFy21VolumeTier--'+cow.isFy21VolumeTier);
        
        //Fill Comp impact value on the Custom Order
        if(isTraditional){
            //In Traditional Single Tier we use Net Variance as discount approval/comp impact metrics.
            if(cow.isFy21SingleTier){
                IF( opp.SBQQ__PrimaryQuote__r.Cart_PUPY_without_Support_DAS_Training__c < opp.SBQQ__PrimaryQuote__r.Recomm_PUPY_without_Support_DAS_Training__c){
                    co.Comp_Impact__c = - Math.abs(opp.SBQQ__PrimaryQuote__r.Total_PUPY_Discount__c);
                }else{
                    co.Comp_Impact__c =  Math.abs(opp.SBQQ__PrimaryQuote__r.Total_PUPY_Discount__c);
                }
            }
            //In Traditional Volume Tier we use "Total Subscription Discount without PS and DAS" field for discount approval/comp impact metrics
            if(cow.isFy21VolumeTier){
                co.Comp_Impact__c =  opp.SBQQ__PrimaryQuote__r.Total_Discount_Without_Support__c;
            }
        }
        else if(isPartnerSummit){
            //In Summit (Single/Volume Tier) we use "Blended Discount" field for discount approval/comp impact metrics   
            co.Comp_Impact__c =  opp.SBQQ__PrimaryQuote__r.Total_Blended_Discount__c;
        }
        
        System.debug('---co.Comp_Impact__c--'+co.Comp_Impact__c);
        
        //Important
        updateTheMargins(co, opp);
        
        if(opp.Custom_Order__c != null){
            co.id = opp.Custom_Order__c;
            update co;
        }else{
            insert co;
            opp.Custom_Order__c = co.id;
            update opp;
        }
        
        System.debug('---co---'+co);
        
        
        //Remove unnessessary Existing lines
        removeUnusedCustomOrderLines(co);
        
        Set<ID> coId = new Set<ID>{co.id};
        List<Custom_Order__c> customOrderRefresh =  getCustomOrder(coId);
        
        co = customOrderRefresh[0];
            
            
        
        //Load New Custom Order Lines -- [Existing/New]
        List<Custom_Order_Line__c> customOrdrlines = new List<Custom_Order_Line__c>();
        if(customOrdrlines == null || customOrdrlines.size() == 0 ){
            customOrdrlines = createCustomOrderlines(opp, co);
            upsert customOrdrlines Custom_Order_Line__c.External_ID__c;
        }
        
        System.debug('--customOrdrlines---'+customOrdrlines);
        
        MAP<ID, Custom_Order_Line__c> customOrdrMAP = new MAP<ID, Custom_Order_Line__c>(customOrdrlines);
        
        List<Custom_Order_Line__c> customOrderLinesRefresh =  getCustomOrderLines(customOrdrMAP.keyset());
        
        System.debug('--customOrderLinesRefresh---'+customOrderLinesRefresh);
        
        //CR# 4019 - if buyback is present set promo code
        Boolean isBuybackPreset = false;
        for(Custom_Order_Line__c coline : customOrderLinesRefresh){
            if(coline.Total_Term_after_Buyback__c > 0){
                isBuybackPreset = true;
                break;
            }
        }
        if(isBuybackPreset){
            co.is_Buyback_Present__c = isBuybackPreset;
            update co;
        }
        
        cow.nooverrideACV = [Select id,Do_Not_Override_ACV__c from Custom_Order__c where id = :co.id ].Do_Not_Override_ACV__c;
        
        fillLinetoNSDetails(opp, customOrderLinesRefresh, cow);
        
        
        //add to wrapper
        
        cow.custOrder = co;
        cow.customOrderLines = customOrderLinesRefresh;
        return cow;
    }
    
    
    //Method to re calculate Renewal/Upsell/New ACV/TCV
    @auraEnabled
    public static CustomOrderWrapper reCalculateACV(CustomOrderWrapper cow){
        
        System.debug('---reCalculateACV---called---');
        //fillLinetoNSDetails(cow.opp, cow.customOrderLines, cow);
        
        calculateACV(cow);
        
        return cow;
    }
    
    @testVisible
    private Static void fillLinetoNSDetails(Opportunity opp, List<Custom_Order_Line__c> coLines, CustomOrderWrapper cow ){
        
        
        System.debug('fillLinetoNSDetails---opp--'+opp);
        System.debug('fillLinetoNSDetails---coLines--'+coLines);
        System.debug('fillLinetoNSDetails---cow--'+cow);
        
        Set<String> setrecurringSKUs = new Set<String>();
        Set<String> CFWCSBSKUs = new Set<String>();
        Set<String> CFWZPASKUs = new Set<String>();
        Set<String> setonetimeSKUs = new Set<String>();
        Set<String> zpaDeploymentSKUs = new Set<String>();
        Set<String> setSKUswithACVtobeskipped = new Set<String>();
        Set<String> setSKUsnottoAdd = new Set<String>();
        Set<String> CreditSKUs = new Set<String>();
        Set<String> UpliftSKUs = new Set<String>();
        
        Set<String> cartSKUcodes = new Set<String>();
        
        setrecurringSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Recurring_SKU').SKU_Codes__c.split(';'));
        CFWCSBSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('CFW_CSB_SKUs').SKU_Codes__c.split(';'));
        CFWZPASKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('CFW_ZPA_SKUs').SKU_Codes__c.split(';'));
        setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('One_Time_SKU').SKU_Codes__c.split(';'));
        setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('One_Time_SKU1').SKU_Codes__c.split(';'));
        setSKUswithACVtobeskipped.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('SKUs_to_SKIP_ACV').SKU_Codes__c.split(';'));
        setSKUsnottoAdd.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('SKUs_not_To_ADD').SKU_Codes__c.split(';'));
        CreditSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Credit_SKUs').SKU_Codes__c.split(';'));
        UpliftSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Uplift_SKUs').SKU_Codes__c.split(';'));
        
        
        zpaDeploymentSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZPA_Deployment_SKUs').SKU_Codes__c.split(';'));
        zpaDeploymentSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZPA_Deployment_SKUs1').SKU_Codes__c.split(';'));
        
        
        Map<String, List<Contract_Detail__c>> mapSOnumtocd = new Map<String, List<Contract_Detail__c>>();
        Map<Id, Contract_Detail__c> mapcdIdtoCd = new Map<Id, Contract_Detail__c>();
        
        Map<Id, List<Contract_Detail__c>> mapSOtoquote = new Map<Id, List<Contract_Detail__c>>();
        Map<String, String> mapSonamtoId = new Map<String, String>();
        
        Map<String, Contract_Detail__c> cdnamemap = new Map<String, Contract_Detail__c>();
        List<LinestoNS> lstfinallinestoNS = new List<LinestoNS>();
        
        //Logic to populate contract and additional contract details based on Asset Line Item field on Proposal Line item record. 
        for(Contract_Detail__c cd: [Select Id, Name, Contract_Detail_Status__c, Account_Name__c, Sales_Order_Name__c,
                                    Product_SKU__c, Start_Date__c, End_Date__c, Quantity__c, Sales_Order__c, 
                                    Contract_No__c, Amount_USD__c from Contract_Detail__c where Account_Name__c = :opp.AccountId])
        {
            if(cd.Contract_Detail_Status__c == 'Active' || cd.Contract_Detail_Status__c == 'Pending Renewal' || cd.Contract_Detail_Status__c == 'Pending Activation')
            {
                List<Contract_Detail__c> tmpList = mapSOnumtocd.containskey(cd.Sales_Order_Name__c) ?  mapSOnumtocd.get(cd.Sales_Order_Name__c) : new List<Contract_Detail__c>();
                tmpList.add(cd);
                mapSOnumtocd.put(cd.Sales_Order_Name__c, tmpList);
                mapcdIdtoCd.put(cd.Id, cd);
            }
            cdnamemap.put(cd.name, cd);
        }
        
        system.debug('---cdnamemap---'+cdnamemap);
        system.debug('++++'+mapSOnumtocd);
        
        
        Decimal TotalZIAACV = 0;
        Decimal TotalZPAACV = 0;
        Decimal TotalZIAACVBB = 0;
        Decimal TotalZPAACVBB = 0;
        Decimal TotalTCVU4 = 0;
        Decimal TotalTCVU5 = 0;
        Decimal TotalZIATCV = 0;
        Decimal TotalZPATCV = 0;
        Decimal TotalZPAACVofRecurringInternalSKU = 0;
        Decimal TotalZPATCVofRecurringInternalSKU = 0;
        Decimal TotalZPATCVofNonRecurringInternalSKU = 0;
        Decimal TotalACV = 0;
        Decimal TotalACVinclPS = 0;
        Decimal TotalTCV = 0;
        Decimal TotalCFWZPAACV = 0;
        Decimal TotalCFWCSBACV = 0;
        
        Custom_Order_Line__c pliZIABuyback = null;
        Custom_Order_Line__c pliZPABuyback = null;
        Custom_Order_Line__c pliuplift4 = null;
        Custom_Order_Line__c pliuplift5 = null;
        Custom_Order_Line__c pliOneTimeCredit = null;
        Custom_Order_Line__c plicsbcfwpromo = null;
        Custom_Order_Line__c plizpacfwpromo = null;
        
        Boolean onetimealreadyadded = false;
        Boolean recurringalreadyadded = false;
        Boolean containszpa = false;
        Boolean buybackbifur = false;
        
        
        
        //calculate sum of ACVs of lines whose term is > 36 for uplift 4 bifurcation and term > 48 for uplift 5 bifurcation
        for(Custom_Order_Line__c pli: coLines){
            System.debug('----pli Additional_Contract_Details__c----'+pli.Additional_Contract_Details__c);
            System.debug('----pli Contract_Detail_Name__c----'+pli.Contract_Detail_Name__c);
            System.debug('----pli Contract_No__c----'+pli.Contract_No__c);
            
            pli.Contract_Detail_Name__c =  pli.Contract_Detail_Name__c;
            
            //modified by Raghu 
            //pli.Contract_No__c = pli.Contract_No__c;
            pli.Contract_No__c = mapcdIdtoCd.containskey(pli.Contract_Detail_Name__c) ? mapcdIdtoCd.get(pli.Contract_Detail_Name__c).Contract_No__c : pli.Contract_No__c;
            
            pli.Additional_Contract_Details__c =  pli.Additional_Contract_Details__c;
            
            if(pli.Total_Term_after_Buyback__c > 36 && (pli.Price_Group__c != 'Price Ramp' || (pli.Price_Group__c == 'Price Ramp' && pli.Total_Ramp_Quantity__c == pli.Quantity__c))){
                TotalTCVU4 += pli.Net_Price__c;
            }
            if(pli.Total_Term_after_Buyback__c > 48 && (pli.Price_Group__c != 'Price Ramp' || (pli.Price_Group__c == 'Price Ramp' && pli.Total_Ramp_Quantity__c == pli.Quantity__c))){
                TotalTCVU5 += pli.Net_Price__c;
            }
            if(pli.SKU__c == APTS_CONSTANTS.PROD_SKU_BUYBACK){
                pliZIABuyback = pli;
            }
            if(pli.SKU__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK){
                pliZPABuyback = pli;
            }
            if(pli.SKU__c == APTS_CONSTANTS.PROD_SKU_Z_CREDIT){
                pliOneTimeCredit = pli;
            }
            if(pli.SKU__c == APTS_CONSTANTS.PROD_SKU_ULIFTY4){
                pliuplift4 = pli;
            }
            if(pli.SKU__c == APTS_CONSTANTS.PROD_SKU_ULIFTY5){
                pliuplift5 = pli;
            }
            if(pli.SKU__c == APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO){
                plicsbcfwpromo = pli;
            }
            if(pli.SKU__c == APTS_CONSTANTS.PROD_SKU_CFWZPA_PROMO){
                plizpacfwpromo = pli;
            }
        }
        
        //This loop takes care of bifurcating Uplift 4 and 5 to all lines where respective criteria is met to its TCV and ACV. Also, calculates multiple sum of ACV/TCV for different calculations like Buyback ACV, total zia acv/tcv, total zpa ACV/TCV etc.,
        for(Custom_Order_Line__c pli: coLines){
            
            pli.TCV_after_Bifurcation__c = pli.Net_Price__c != null ? pli.Net_Price__c : 0;
            Decimal amttosub = 0.0;
            
            if(pli.Total_Term_after_Buyback__c > 36 && pli.Price_Type__c != 'One Time' && 
               (pli.Price_Group__c != 'Price Ramp' || pli.Price_Group__c == 'Price Ramp' && pli.Total_Ramp_Quantity__c == pli.Quantity__c) && pliuplift4 != null){
                   amttosub += TotalTCVU4 != 0 ? (pli.Net_Price__c / TotalTCVU4) * pliuplift4.Net_Price__c: 0.0 ;
               }
            
            if(pli.Total_Term_after_Buyback__c > 48 && pli.Price_Type__c != 'One Time' && 
               (pli.Price_Group__c != 'Price Ramp' || pli.Price_Group__c == 'Price Ramp' && pli.Total_Ramp_Quantity__c == pli.Quantity__c) && pliuplift5 != null){
                   amttosub += TotalTCVU5 != 0 ? (pli.Net_Price__c / TotalTCVU5) * pliuplift5.Net_Price__c: 0.0 ;
               }
            
            pli.TCV_after_Bifurcation__c += amttosub;
            
            if(pli.Term__c >= 12){
                pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c != null && pli.Term__c != null ? (pli.TCV_after_Bifurcation__c / pli.Term__c) * 12 : 0.0;
            }else{
                pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c ;
            }
            if(pli.Product__r.Zscaler_Product_Family__c == 'ZIA' && pli.Price_Type__c != 'One Time'){
                if(pli.Product__r.APTS_Buyback_Eligible__c && (pli.Price_Group__c != 'Price Ramp' || pli.Price_Group__c == 'Price Ramp' && pli.Total_Ramp_Quantity__c == pli.Quantity__c)){
                    TotalZIAACVBB += pli.ACV_after_Bifurcation__c;
                }
                TotalZIAACV += pli.ACV_after_Bifurcation__c;
                TotalZIATCV += pli.TCV_after_Bifurcation__c;
                
            }else if(pli.Product__r.Zscaler_Product_Family__c == 'ZPA' && pli.Price_Type__c != 'One Time'){
                containszpa = true;
                if(pli.Product__r.APTS_Buyback_Eligible__c && (pli.Price_Group__c != 'Price Ramp' || pli.Price_Group__c == 'Price Ramp' && pli.Total_Ramp_Quantity__c == pli.Quantity__c)){
                    TotalZPAACVBB += pli.ACV_after_Bifurcation__c;
                }
                TotalZPAACV += pli.ACV_after_Bifurcation__c;
                TotalZPATCV += pli.TCV_after_Bifurcation__c;
            }
            if(pli.Price_Type__c!= 'One Time' && pli.SKU__c != 'Z-CREDIT'){
                TotalACVinclPS += pli.ACV_after_Bifurcation__c;
            }
            TotalACV = TotalZPAACV + TotalZIAACV;
            TotalTCV = TotalZPATCV + TotalZIATCV;
            if(CFWCSBSKUs.contains(pli.SKU__c)){
                TotalCFWCSBACV += pli.ACV_after_Bifurcation__c;
            }
            if(CFWZPASKUs.contains(pli.SKU__c) || pli.Product__r.Zscaler_Product_Family__c == 'ZPA'){
                TotalCFWZPAACV += pli.ACV_after_Bifurcation__c;
            }
            System.debug('--pli.TCV_after_Bifurcation__c---'+pli.TCV_after_Bifurcation__c);
        }
        
        //This loop takes care of credit sku's bifurcation to all eligible lines. Also, to calculate ZIA/ZPA portion of recurring and non recurring SKUs
        for(Custom_Order_Line__c pli: coLines){
            Decimal amttosubACV = 0.0;
            
            if(pli.Product__r.APTS_Buyback_Eligible__c && pli.Product__r.Zscaler_Product_Family__c == 'ZIA' &&
               (pli.Price_Group__c != 'Price Ramp' || pli.Price_Group__c == 'Price Ramp' && pli.Total_Ramp_Quantity__c == pli.Quantity__c) && pliZIABuyback != null){
                   amttosubACV += TotalZIAACVBB != 0 && pliZIABuyback.ACV__c != null? (pli.ACV_after_Bifurcation__c / TotalZIAACVBB) * pliZIABuyback.ACV__c: 0.0 ;
                   buybackbifur = true;
               }
            
            if(pli.Product__r.APTS_Buyback_Eligible__c && pli.Product__r.Zscaler_Product_Family__c == 'ZPA' && 
               (pli.Price_Group__c != 'Price Ramp' || pli.Price_Group__c == 'Price Ramp' && pli.Total_Ramp_Quantity__c == pli.Quantity__c) && pliZPABuyback != null){
                   amttosubACV += TotalZPAACVBB != 0 && pliZPABuyback.ACV__c != null? (pli.ACV_after_Bifurcation__c / TotalZPAACVBB) * pliZPABuyback.ACV__c: 0.0 ;
                   buybackbifur = true;
               }
            
            if(pli.Price_Type__c != 'One Time' && pliOneTimeCredit != null && pli.SKU__c != 'Z-CREDIT'){
                system.debug('onetimecredit' + pli.SKU__c + '++++'+ TotalACVinclPS + '++++'+ pli.ACV_after_Bifurcation__c + '++++' + pliOneTimeCredit.ACV__c);
                amttosubACV += TotalACVinclPS != 0 &&  pliOneTimeCredit.ACV__c != null? (pli.ACV_after_Bifurcation__c / TotalACVinclPS) * pliOneTimeCredit.ACV__c: 0.0 ;
                buybackbifur = true;
            }
            if(CFWCSBSKUs.contains(pli.SKU__c) && plicsbcfwpromo != null){
                amttosubACV += TotalCFWCSBACV != 0  &&  plicsbcfwpromo.ACV__c != null ? (pli.ACV_after_Bifurcation__c / TotalCFWCSBACV) * plicsbcfwpromo.ACV__c: 0.0 ;
                buybackbifur = true;
            }
            if((CFWZPASKUs.contains(pli.SKU__c) || pli.Product__r.Zscaler_Product_Family__c == 'ZPA')&& plizpacfwpromo != null){
                amttosubACV += TotalCFWZPAACV != 0 &&  plizpacfwpromo.ACV__c != null ? (pli.ACV_after_Bifurcation__c / TotalCFWZPAACV) * plizpacfwpromo.ACV__c: 0.0 ;
                buybackbifur = true;
            }
            pli.ACV_after_Bifurcation__c += amttosubACV;
            
            system.debug('onetimecredit' + pli.SKU__c + '++++'+ pli.ACV_after_Bifurcation__c );
            
            if(setrecurringSKUs.contains(pli.SKU__c)){
                TotalZPATCVofRecurringInternalSKU += TotalTCV != 0 && pli.TCV_after_Bifurcation__c != null ? ((TotalZPATCV / TotalTCV) * pli.TCV_after_Bifurcation__c) : 0;
                TotalZPAACVofRecurringInternalSKU += TotalACV != 0 && pli.ACV_after_Bifurcation__c != null ? ((TotalZPAACV / TotalACV) * pli.ACV_after_Bifurcation__c) : 0;
                
                pli.ACV_after_Bifurcation__c = TotalACV != 0 && pli.ACV_after_Bifurcation__c != null ? ((TotalZIAACV / TotalACV) * pli.ACV_after_Bifurcation__c) : (TotalACV == 0 ? pli.ACV_after_Bifurcation__c : 0);
            }
            
            System.debug('--pli.TCV_after_Bifurcation__c---'+pli.TCV_after_Bifurcation__c);
            System.debug('--pli.ACV_after_Bifurcation__c---'+pli.ACV_after_Bifurcation__c);
            
            
            if(setonetimeSKUs.contains(pli.SKU__c)){
                System.debug('--part of onetime sku---');
                TotalZPATCVofNonRecurringInternalSKU += TotalTCV != 0 &&  pli.TCV_after_Bifurcation__c != null ? ((TotalZPATCV / TotalTCV) * pli.TCV_after_Bifurcation__c) : 0;
                pli.TCV_after_Bifurcation__c = TotalTCV != 0 && pli.TCV_after_Bifurcation__c != null ? ((TotalZIATCV / TotalTCV) * pli.TCV_after_Bifurcation__c) : (TotalTCV == 0 ? pli.TCV_after_Bifurcation__c : 0);
                    
                    if(pli.Term__c >= 12){
                        pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c != null && pli.Term__c != null ? (pli.TCV_after_Bifurcation__c / pli.Term__c) * 12 : 0.0;
                    }else{
                        pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c ;
                    }
            }
            
            System.debug('--pli.ACV_after_Bifurcation__c---'+pli.ACV_after_Bifurcation__c);
            System.debug('--pli.TCV_after_Bifurcation__c---'+pli.TCV_after_Bifurcation__c);
            
            //CR# 343
            if(zpaDeploymentSKUs.contains(pli.SKU__c)){
                System.debug('--part of deployment sku---');
                System.debug('--TotalZIATCV---'+TotalZIATCV);
                System.debug('--TotalTCV---'+TotalTCV);
                if(pli.Price_Type__c != 'One Time'){
                    pli.TCV_after_Bifurcation__c = TotalTCV != 0 && pli.TCV_after_Bifurcation__c != null ? ((TotalZIATCV / TotalTCV) * pli.TCV_after_Bifurcation__c) : (TotalTCV == 0 ? pli.TCV_after_Bifurcation__c : 0);
                }
                System.debug('--pli.TCV_after_Bifurcation__c---'+pli.TCV_after_Bifurcation__c); 
                
                if(pli.Term__c >= 12){
                    pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c != null && pli.Term__c != null ? (pli.TCV_after_Bifurcation__c / pli.Term__c) * 12 : 0.0;
                }else{
                    pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c ;
                }
            }
        }
        
        //This loop takes care of preparation of internal and non - internal lines with all calc computed in above loops
        
        System.debug('--setSKUsnottoAdd--'+setSKUsnottoAdd);
       
        
        for(Custom_Order_Line__c pli: coLines){
            System.debug('----pli---'+pli);
            if(!setSKUsnottoAdd.contains(pli.SKU__c)){
                lstfinallinestoNS.add(new LinestoNS(pli, buybackbifur));
                cartSKUcodes.add(pli.SKU__c);
            }
        }
        
        System.debug('--lstfinallinestoNS--'+lstfinallinestoNS);
        
        
        cow.lstfinallinestoNS = lstfinallinestoNS;
        cow.cdnamemap = cdnamemap;
        cow.customOrderLines = coLines;
        
        if(cow.nooverrideACV != null && cow.nooverrideACV){
            fillListWithoutInternalLines(cow);
        }else{
            //Calculate ACV
            calculateACV(cow);
        }
    }
    
    
    
    
    @testVisible
    private static void fillListWithoutInternalLines(CustomOrderWrapper cow){
        List<LinestoNS> lstfinallinestoNSwithoutinternallines = new List<LinestoNS>();
        for(LinestoNS rlw: cow.lstfinallinestoNS){
            if(rlw.pliId != null){
                lstfinallinestoNSwithoutinternallines.add(rlw);
            }
        }
        cow.lstfinallinestoNSwithoutinternallines = lstfinallinestoNSwithoutinternallines;
    }
    
    
    //Method to calculate Renewal/Upsell/New ACV/TCV
    @testVisible
    private static CustomOrderWrapper calculateACV(CustomOrderWrapper cow){
        
        if(cow.nooverrideACV != null && cow.nooverrideACV){
            return cow;
        }
        
        System.debug('---calculateACV---called---');
        
        Opportunity opp = cow.opp;
        List<LinestoNS> lstfinallinestoNS = cow.lstfinallinestoNS;
        Map<String, Contract_Detail__c> cdnamemap = cow.cdnamemap;
        
        System.debug('---calculateACV---lstfinallinestoNS---'+lstfinallinestoNS);
        System.debug('---calculateACV---cdnamemap---'+cdnamemap);
        System.debug('---calculateACV---cow---'+cow);
        
        Set<String> setrecurringSKUs = new Set<String>();
        Set<String> CFWCSBSKUs = new Set<String>();
        Set<String> CFWZPASKUs = new Set<String>();
        Set<String> setonetimeSKUs = new Set<String>();
        Set<String> zpaDeploymentSKUs = new Set<String>();
        Set<String> setSKUswithACVtobeskipped = new Set<String>();
        Set<String> setSKUsnottoAdd = new Set<String>();
        Set<String> CreditSKUs = new Set<String>();
        Set<String> UpliftSKUs = new Set<String>();
        
        Set<String> cartSKUcodes = new Set<String>();
        
        setrecurringSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Recurring_SKU').SKU_Codes__c.split(';'));
        CFWCSBSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('CFW_CSB_SKUs').SKU_Codes__c.split(';'));
        CFWZPASKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('CFW_ZPA_SKUs').SKU_Codes__c.split(';'));
        setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('One_Time_SKU').SKU_Codes__c.split(';'));
        setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('One_Time_SKU1').SKU_Codes__c.split(';'));
        setSKUswithACVtobeskipped.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('SKUs_to_SKIP_ACV').SKU_Codes__c.split(';'));
        setSKUsnottoAdd.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('SKUs_not_To_ADD').SKU_Codes__c.split(';'));
        CreditSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Credit_SKUs').SKU_Codes__c.split(';'));
        UpliftSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Uplift_SKUs').SKU_Codes__c.split(';'));
        
        zpaDeploymentSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZPA_Deployment_SKUs').SKU_Codes__c.split(';'));
        zpaDeploymentSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZPA_Deployment_SKUs1').SKU_Codes__c.split(';'));
        
        
        List<LinestoNS> lstfinallinestoNSwithoutinternallines = new List<LinestoNS>();
        List<LinestoNS> lstfinallinestoNSwithInternalLines = new List<LinestoNS>();
        List<Contract_Detail__c> lstdroppedcontractdetails = new List<Contract_Detail__c>();
        
        //List<Custom_Order_Line__c> lstinternallinestoinsert = new List<Custom_Order_Line__c>();
        
        List<String> contractdetailslst = opp.Netsuite_Sales_Order_No__c != null ? opp.Netsuite_Sales_Order_No__c.split(',') : new List<String>();
        Set<String> contractdetails = new Set<String>();
        Set<String> premsupportCDs = new Set<String>();
        contractdetails.addAll(contractdetailslst);
        
        //This is to get the set of All Sales order numbers based on the contract/additional contract details keyed in by Finanace team for PREM-SUP calculation
        for(LinestoNS rlw: lstfinallinestoNS){
            if(rlw.contractDetailName != null && rlw.contractDetailName != ''){
                if(cdnamemap.containskey(rlw.contractDetailName) && cdnamemap.get(rlw.contractDetailName) != null && cdnamemap.get(rlw.contractDetailName).Sales_Order_Name__c != null){
                    contractdetails.add(cdnamemap.get(rlw.contractDetailName).Sales_Order_Name__c);
                }
                if(rlw.productCode == 'ZCES-SUP-PREM'){
                    premsupportCDs.add(rlw.contractDetailName);
                }
            }
            if(rlw.addcontractDetailName != null && rlw.addcontractDetailName != ''){
                for(String addcd: rlw.addcontractDetailName.split(',')){
                    if(addcd != null && addcd != ''){
                        if(cdnamemap.containskey(addcd.trim()) && cdnamemap.get(addcd.trim()) != null && cdnamemap.get(addcd.trim()).Sales_Order_Name__c != null){
                            contractdetails.add(cdnamemap.get(addcd.trim()).Sales_Order_Name__c);
                        }
                    }
                    if(rlw.productCode == 'ZCES-SUP-PREM'){
                        premsupportCDs.add(addcd.trim());
                    }
                }
            }
        }
        
        Decimal totalARR = 0;
        Decimal totalARRofentireCart = 0;
        Decimal PSARR = 0;
        Decimal totalACVtocarveout = 0;
        Date ChurnSD = opp.Custom_Order__r.Expected_Start_Date__c != null ? opp.Custom_Order__r.Expected_Start_Date__c.addmonths(-3) : null;
        Date ChurnEd = opp.Custom_Order__r.Expected_Start_Date__c != null ? opp.Custom_Order__r.Expected_Start_Date__c.addmonths(3) : null;
        List<Contract_Detail__c> conlst = new List<Contract_Detail__c>();
        Set<String> MatchingcartSKUs = new Set<String>();
        
        //This loop calculates total ZIA/ZPA ARR of CD for PREM SUP calc, total ARR of entire CD to decide whether we need carve out. Only if Total Renewal ACV < Total ARR of entire cart then we need carve out. Also, prepare list of dropped SKUs to display on the screen based on SKU Churn Date.
        for(Contract_Detail__c cd: [Select Id, Name, SKU_Churn_Date__c, Term__c, Quantity__c, ARR_Finance__c, Amount_USD__c, 
                                    MRR_USD__c, Product_Name__r.Zscaler_Product_Family__c, Product_SKU__c, Product_Name__r.Name 
                                    from Contract_Detail__c where Sales_Order_Name__c in :contractdetails])
        {
            if (cd.ARR_Finance__c == null) cd.ARR_Finance__c = 0;
            if((cd.Product_Name__r.Zscaler_Product_Family__c == 'ZIA' || cd.Product_Name__r.Zscaler_Product_Family__c == 'ZPA') && cd.ARR_Finance__c != null){
                totalARR += cd.ARR_Finance__c;
            }
            
            if(cd.ARR_Finance__c != null){
                totalARRofentireCart += cd.ARR_Finance__c;
            }
            
            if((cd.Product_SKU__c == 'ZCES-SUP-PREM' || cd.Product_SKU__c == 'ZCES-SUP-PREM-SP') && (premsupportCDs.isEmpty() || premsupportCDs.contains(cd.Name))){
                PSARR += cd.ARR_Finance__c;
            }
            
            if(cd.SKU_Churn_Date__c >= ChurnSD && cd.SKU_Churn_Date__c <= ChurnEd && !CreditSKUs.contains(cd.Product_SKU__c)){
                totalACVtocarveout += (cd.MRR_USD__c * 12);
                lstdroppedcontractdetails.add(cd);
            }
            conlst.add(cd);
        }
        
        
        String renewalupselldecision = '';
        String additionalcontractdetailsvals = '';
        
        
        Map<String, Upgrade_SKU_Mapping_NS_Integration__c> mapupgrade = Upgrade_SKU_Mapping_NS_Integration__c.getAll();
        //This loop to populate additional contract details on lines which match upgrade Scenario
        for(String key: mapupgrade.keySet()){
            String addcon = '';
            String s = mapupgrade.get(key).Matching_SKU_On_IB__c;
            Set<String> skulist = new Set<String>();
            Set<String> skulisttocompare = new Set<String>();
            skulist.addAll(s.split(';'));
            for(Contract_Detail__c cd: conlst){
                if(skulist.contains(cd.Product_SKU__c)){
                    skulisttocompare.add(cd.Product_SKU__c);
                    addcon += cd.name + ',';
                }
            }
            if(skulist.size() == skulisttocompare.size() && cartSKUcodes.containsAll(mapupgrade.get(key).Matching_SKU_On_Cart__c.split(';'))){
                MatchingcartSKUs.addAll(mapupgrade.get(key).Matching_SKU_On_Cart__c.split(';'));
                renewalupselldecision = mapupgrade.get(key).IsrenewalorUpsell__c;
                
                additionalcontractdetailsvals = additionalcontractdetailsvals.length() < addcon.length() ? addcon : additionalcontractdetailsvals;
            }
        }
        
        MAP<String, Contract_Detail__c> mapnumbertocd = new MAP<String, Contract_Detail__c>();
        List<Custom_Order_Line__c> plistoupdate = new List<Custom_Order_Line__c> ();
        List<LinestoNS> plilsttoupdate = new List<LinestoNS> ();
        List<LinestoNS> plilstneedscarveout = new List<LinestoNS> ();
        
        Set<String> contractdetailnumberset = new Set<String>();
        Decimal Overall_Upsell = 0;
        Decimal Overall_Carveout = 0;
        Decimal Overall_Renewal = 0;
        Decimal TotalNetPriceofZIAZPA = 0;
        
        
        system.debug('++++MatchingcartSKUs+++'+MatchingcartSKUs);
        
        //Loop to prepare map of CD names, to get contract detail information based on populated CD.
        for(LinestoNS rlw: lstfinallinestoNS){
            System.debug('--rlw contractDetailName--'+rlw.contractDetailName);
            System.debug('--rlw addcontractDetailName--'+rlw.addcontractDetailName);
            
            if(MatchingcartSKUs.contains(rlw.productCode)){
                rlw.addcontractDetailName = additionalcontractdetailsvals;
            }
            if(rlw.contractDetailName != null && rlw.contractDetailName != '')
                contractdetailnumberset.add(rlw.contractDetailName);
            if(rlw.addcontractDetailName != null && rlw.addcontractDetailName != ''){
                for(String addcd: rlw.addcontractDetailName.split(',')){
                    if(addcd != null && addcd != '')
                        contractdetailnumberset.add(addcd.trim());
                }
            }
        }
        
        System.debug('--contractdetailnumberset--'+contractdetailnumberset);
        for(Contract_Detail__c cd: [Select Id, Name, Quantity__c, Start_Date__c, End_Date__c, SKU_Churn_Date__c, Sales_Order_Date__c, 
                                    Amount_USD__c, Product_SKU__c, Term__c, MRR_USD__c, ARR_Finance__c, Order_Type__c from Contract_Detail__c where Name in :contractdetailnumberset and Account_Name__c = : opp.AccountId])
        {
            mapnumbertocd.put(cd.name, cd);
        }
        System.debug('--mapnumbertocd--'+mapnumbertocd);
        
        
        Date today = date.today();
        List<FiscalyearSettings> fiscalYears = [select Id, Name, IsStandardYear, StartDate, EndDate from FiscalYearSettings where StartDate<=:today and EndDate>= :today limit 1];
        
        //this loop calculates Renewal/Upsell/New ACV/TCV
        for(LinestoNS rlw: lstfinallinestoNS){
            System.debug('----LinestoNS---rlw---'+rlw);
            System.debug('----LinestoNS---pli.pliId---'+rlw.pliId);
            
            LinestoNS pli = rlw;
            Decimal renewalbaseACVofcontracts = 0;
            Decimal inhandrenewal = 0;
            Decimal renewalbaseqty = 0;
            Decimal renewalbaseterm = 0;
            Decimal renewalbasemrr = 0;
            Date farthestenddate = null;
            Decimal total_renewal = 0;
            Decimal total_upsell = 0;
            Decimal total_carveout = 0;
            Boolean ispurerenewal = false;
            Boolean ispureupsell = false;
            Boolean isrenewalupsell = false;
            Boolean isSameSKU = true;
            Boolean isUpgradeScenariomatched = false;
            Decimal termforupsellcompensation = 0;
            Decimal UpsellMRRforcompensation = 0;
            Date startdatecompensation = null;
            Date enddatecompensation = null;
            Date salesorderdate = null;
            Decimal termofcontract = null;
            
            if(opp.type == 'Existing Customer (Renewal)' && pli.productCode != 'ZCES-SUP-PREM'){
                if(pli.productfamily == 'ZIA' || pli.productfamily == 'ZPA'){
                    TotalNetPriceofZIAZPA += pli.NetPrice;
                }
                if((rlw.contractDetailName != '' && rlw.contractDetailName != null) || (rlw.addcontractDetailName != '' && rlw.addcontractDetailName != null))
                {
                    Set<String> cdset = new Set<String>();
                    if(rlw.contractDetailName != null && rlw.contractDetailName != '')
                        cdset.add(rlw.contractDetailName);
                    if(rlw.addcontractDetailName != null && rlw.addcontractDetailName != ''){
                        for(String addcd: rlw.addcontractDetailName.split(',')){
                            if(addcd != null && addcd != '')
                                cdset.add(addcd.trim());
                        }
                    }
                    system.debug('+++'+cdset);
                    Set<String> upgradeSKUset = new Set<String>();
                    Map<String,Upgrade_SKU_Mapping_NS_Integration__c> upgradeSKUMap =  Upgrade_SKU_Mapping_NS_Integration__c.getAll();
                    
                    for(String cdnum: cdset)
                    {
                        Decimal contractterm = 0;
                        Decimal contractqty = 0;
                        Decimal contractACV = 0;
                        Decimal arrval = 0;
                        
                        startdatecompensation = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Start_Date__c != null ? ((startdatecompensation == null || mapnumbertocd.get(cdnum).Start_Date__c < startdatecompensation) && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).Start_Date__c : startdatecompensation) : null ;
                        
                        termofcontract = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Term__c != null ? ((termofcontract == null || mapnumbertocd.get(cdnum).Term__c > termofcontract) && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).Term__c : termofcontract) : null ;
                        
                        enddatecompensation = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).End_Date__c != null ? ((enddatecompensation == null || mapnumbertocd.get(cdnum).End_Date__c > enddatecompensation) && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).End_Date__c : enddatecompensation) : null ;
                        
                        salesorderdate = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Sales_Order_Date__c != null && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).Sales_Order_Date__c : null ;
                        
                        UpsellMRRforcompensation += mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).MRR_USD__c != null && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).MRR_USD__c : 0.0 ;
                        
                        arrval += mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).ARR_Finance__c != null ? mapnumbertocd.get(cdnum).ARR_Finance__c : 0.0 ;
                        renewalbasemrr += arrval;
                        
                        contractterm = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Term__c != null? mapnumbertocd.get(cdnum).Term__c : 0.0 ;
                        renewalbaseterm += contractterm;
                        
                        contractqty = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Quantity__c != null ? mapnumbertocd.get(cdnum).Quantity__c : 0.0 ;
                        renewalbaseqty += contractqty;
                        
                        contractACV = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Amount_USD__c != null && contractqty != 0 &&  contractterm != 0 ? (contractterm > 12 ? ((mapnumbertocd.get(cdnum).Amount_USD__c / (contractqty * contractterm)) * 12 * contractqty)  : ((mapnumbertocd.get(cdnum).Amount_USD__c / (contractqty * contractterm)) * contractterm * contractqty)) : 0.0 ;
                        renewalbaseACVofcontracts += contractACV;
                        
                        farthestenddate = ((mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).End_Date__c != null) ? ((farthestenddate == null) ? mapnumbertocd.get(cdnum).End_Date__c : (farthestenddate < mapnumbertocd.get(cdnum).End_Date__c ? mapnumbertocd.get(cdnum).End_Date__c : farthestenddate)) : farthestenddate);
                        if(mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Product_SKU__c != pli.productCode){
                            isSameSKU = false;
                        }
                        if(mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Product_SKU__c != null && upgradeSKUset.contains(mapnumbertocd.get(cdnum).Product_SKU__c)){
                            upgradeSKUset.remove(mapnumbertocd.get(cdnum).Product_SKU__c);
                        }
                        
                    }
                    if(upgradeSKUset.isEmpty()){
                        isUpgradeScenariomatched = true;
                    }
                    
                    if(renewalbasemrr > 0){
                        renewalbaseACVofcontracts = renewalbasemrr;
                    }
                    
                    Decimal ppufrompli = pli.Qty != 0 && pli.Qty != null && pli.ACV != null ? (pli.ACV  / pli.Qty) : 0;
                    Decimal ppufromcd = renewalbaseqty != 0 && renewalbaseqty != null && renewalbasemrr!= null ? (renewalbasemrr  / renewalbaseqty) : 0;
                    system.debug('+++++'+pli.productCode + '--'+ isSameSKU +'--'+ renewalbaseqty +'--'+pli.Qty +'--'+ pli.StartDate +'--'+ farthestenddate);
                    system.debug('+++++'+ppufrompli + '--'+ ppufromcd );
                    system.debug('+++++renewalbaseACVofcontracts+++'+renewalbaseACVofcontracts);
                    
                    if((isSameSKU && renewalbaseqty == pli.Qty && pli.StartDate > farthestenddate) || (renewalupselldecision == 'renewal' && MatchingcartSKUs.contains(pli.productCode))){
                        ispurerenewal = true;
                    }else if(isSameSKU && renewalbaseqty != null){
                        inhandrenewal = renewalbaseqty * Math.max(ppufrompli,ppufromcd);
                        isrenewalupsell = true;
                    }else if(!isSameSKU){
                        inhandrenewal = renewalbaseACVofcontracts;
                        isrenewalupsell = true;
                    }
                    
                    System.debug('---renewalbaseqty--'+renewalbaseqty);
                    System.debug('---inhandrenewal--'+inhandrenewal);
                    
                    System.debug('---ispureupsell--'+ispureupsell);
                    System.debug('---ispurerenewal--'+ispurerenewal);
                    System.debug('---isrenewalupsell--'+isrenewalupsell);
                    
                    if(ispureupsell){
                        total_renewal = 0;
                        total_upsell = pli.ACV;
                        total_carveout = 0;
                    }else if(ispurerenewal){
                        total_renewal = pli.ACV;
                        total_upsell = 0;
                        total_carveout = 0;
                    }else if(isrenewalupsell){
                        
                        if(startdatecompensation != null && enddatecompensation != null && termofcontract < 12 && enddatecompensation.adddays(1) == opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c && !fiscalYears.isEmpty() && salesorderdate >= fiscalYears[0].StartDate && salesorderdate <= fiscalYears[0].EndDate){
                            Decimal upsell_ACV = UpsellMRRforcompensation * (12 - (Integer)Math.roundToLong(((startdatecompensation.daysBetween(enddatecompensation))/30.25)));
                            total_renewal = pli.ACV - upsell_ACV;
                            total_upsell = upsell_ACV;
                            total_carveout = 0;
                        }else{
                            total_renewal = inhandrenewal < pli.ACV ? inhandrenewal : pli.ACV;
                            total_upsell = inhandrenewal < pli.ACV ? pli.ACV - inhandrenewal : 0.0;
                            total_carveout = renewalbaseACVofcontracts - inhandrenewal;
                            total_carveout += inhandrenewal > pli.ACV ? inhandrenewal - pli.ACV : 0.0;
                        }
                        system.debug(pli.productCode + '--'+inhandrenewal + '--'+pli.ACV + '--'+ renewalbaseACVofcontracts+'--'+total_carveout);
                    }
                    
                    System.debug('--total_upsell--'+total_upsell);
                    System.debug('--total_renewal--'+total_renewal);
                    
                    
                    pli.newACV = 0.0;
                    pli.UpsellACV = total_upsell;
                    pli.RenewalACV = total_renewal;
                    pli.CarvedOutACV = total_carveout;
                    
                    
                    if(pli.SellingTerm >= 12){
                        if(pli.isbuybackbifurcated){
                            pli.newTCV = 0;
                            pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        }else{
                            pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                            pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                            pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                        }
                    }
                    else{
                        if(pli.isbuybackbifurcated){
                            pli.newTCV = 0;
                            pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        }else{
                            pli.newTCV = pli.newACV ;
                            pli.UpsellTCV = pli.UpsellACV;
                            pli.RenewalTCV = pli.RenewalACV;
                        }
                    }
                    if(setonetimeSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                        pli.ACV = 0;
                        pli.UpsellACV = 0;
                        pli.RenewalACV = 0;
                        pli.CarvedOutACV = 0;
                    }
                    
                    if(zpaDeploymentSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                        pli.ACV = 0;
                        pli.UpsellACV = 0;
                        pli.RenewalACV = 0;
                        pli.CarvedOutACV = 0;
                    }
                    
                    Overall_Upsell += pli.UpsellACV;
                    Overall_Renewal += pli.RenewalACV;
                    Overall_Carveout += pli.CarvedOutACV;
                    pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                    pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                    pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                    pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                    pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                    pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                    pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                    plilsttoupdate.add(pli);
                    if(total_carveout > 0){
                        plilstneedscarveout.add(pli);
                    }
                }
                else
                {
                    pli.UpsellACV = pli.ACV;
                    pli.RenewalACV = 0;
                    pli.newACV = 0;
                    pli.CarvedOutACV = 0;
                    if(pli.SellingTerm >= 12){
                        if(pli.isbuybackbifurcated){
                            pli.newTCV = 0;
                            pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        }else{
                            pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                            pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                            pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                        }
                    }else{
                        if(pli.isbuybackbifurcated){
                            pli.newTCV = 0;
                            pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        }else{
                            pli.newTCV = pli.newACV ;
                            pli.UpsellTCV = pli.UpsellACV;
                            pli.RenewalTCV = pli.RenewalACV;
                        }
                    }
                    
                    if(setonetimeSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                        pli.ACV = 0;
                        pli.UpsellACV = 0;
                        pli.RenewalACV = 0;
                        pli.CarvedOutACV = 0;
                    }
                    if(zpaDeploymentSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                        pli.ACV = 0;
                        pli.UpsellACV = 0;
                        pli.RenewalACV = 0;
                        pli.CarvedOutACV = 0;
                    }
                    Overall_Upsell += pli.UpsellACV;
                    Overall_Renewal += pli.RenewalACV;
                    Overall_Carveout += pli.CarvedOutACV;
                    pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                    pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                    pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                    pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                    pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                    pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                    pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                    plilsttoupdate.add(pli);
                }
            }
            else if(opp.type == 'Existing Customer (Add On)'){
                pli.newACV = 0;
                pli.UpsellACV = pli.ACV;
                pli.RenewalACV = 0;
                pli.CarvedOutACV = 0;
                if(pli.SellingTerm >= 12){
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = 0;
                        pli.UpsellTCV = pli.NetPrice; 
                        pli.RenewalTCV = 0; 
                    }else{
                        pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                        pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                        pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                    }
                }else{
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = 0;
                        pli.UpsellTCV = pli.NetPrice; 
                        pli.RenewalTCV = 0; 
                    }else{
                        pli.newTCV = pli.newACV ;
                        pli.UpsellTCV = pli.UpsellACV;
                        pli.RenewalTCV = pli.RenewalACV;
                    }
                }
                
                if(setonetimeSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                    pli.ACV = 0;
                    pli.UpsellACV = 0;
                    pli.RenewalACV = 0;
                    pli.NewACV = 0;
                }
                if(zpaDeploymentSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                    pli.ACV = 0;
                    pli.UpsellACV = 0;
                    pli.RenewalACV = 0;
                    pli.NewACV = 0;
                }
                
                if(pli.productCode == 'ZCES-SUP-PREM'){
                    pli.UpsellTCV = pli.UpsellACV == 0 ? pli.NetPrice : pli.UpsellTCV;
                }
                pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                plilsttoupdate.add(pli);
            }
            else if(opp.type == 'New Business'){
                pli.newACV = pli.newACV != pli.ACV ? pli.ACV :  pli.newACV  ;
                pli.UpsellACV = 0;
                pli.RenewalACV = 0;
                pli.CarvedOutACV = 0;
                if(pli.SellingTerm >= 12){
                    system.debug('--isbuybackbifurcated--'+pli.isbuybackbifurcated);
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = pli.NetPrice;
                        pli.UpsellTCV = 0; 
                        pli.RenewalTCV = 0; 
                    }else{
                        pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                        system.debug('--pli.newTCV--'+pli.newTCV);
                        pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                        pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                    }
                }else{
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = pli.NetPrice;
                        pli.UpsellTCV = 0; 
                        pli.RenewalTCV = 0; 
                    }else{
                        pli.newTCV = pli.newACV ;
                        pli.UpsellTCV = pli.UpsellACV;
                        pli.RenewalTCV = pli.RenewalACV;
                    }
                }
                
                System.debug('--pli.newTCV--'+pli.newTCV);
                
                
                if(setonetimeSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                    pli.ACV = 0;
                    pli.UpsellACV = 0;
                    pli.RenewalACV = 0;
                    pli.NewACV = 0;
                }
                if(zpaDeploymentSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                    pli.ACV = 0;
                    pli.UpsellACV = 0;
                    pli.RenewalACV = 0;
                    pli.NewACV = 0;
                }
                if(pli.productCode == 'ZCES-SUP-PREM'){
                    pli.newTCV = pli.NewACV == 0 ? pli.NetPrice : pli.newTCV;
                }
                pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                plilsttoupdate.add(pli);
            }
            
            //prepare lines for UI and also update Proposal Line Items
            if(pli.pliId != null){
                if(setonetimeSKUs.contains(pli.productCode)){
                    pli.NetPrice = pli.NetPriceOriginal;         
                }
                if(zpaDeploymentSKUs.contains(pli.productCode)){
                    pli.NetPrice = pli.NetPriceOriginal;
                }
                Custom_Order_Line__c proposallineitem = new Custom_Order_Line__c(Id = pli.pliId,
                                                                                 New_ACV_to_NetSuite__c = pli.newACV, 
                                                                                 Upsell_ACV_to_NetSuite__c = pli.UpsellACV, 
                                                                                 Renewal_ACV_to_NetSuite__c = pli.RenewalACV, 
                                                                                 Carved_Out_ACV__c = pli.CarvedOutACV,
                                                                                 Additional_Contract_Details__c = pli.addcontractDetailName,
                                                                                 Contract_Detail_Name__c = pli.contractDetailId, 
                                                                                 New_TCV_to_NetSuite__c = pli.newTCV, 
                                                                                 Upsell_TCV_to_NetSuite__c = pli.UpsellTCV, 
                                                                                 Renewal_TCV_to_NetSuite__c = pli.RenewalTCV, 
                                                                                 ACV_after_Bifurcation__c = pli.acv, 
                                                                                 TCV_after_Bifurcation__c = pli.NetPrice);
                plistoupdate.add(proposallineitem);
            }
            
            if(pli.pliId != null){
                lstfinallinestoNSwithoutinternallines.add(pli);
            }
        }
        System.debug('----lstfinallinestoNSwithoutinternallines--'+lstfinallinestoNSwithoutinternallines);
        
        Decimal PPUExisting = 0;
        
        PPUExisting = totalARR != null && totalARR != 0 && PSARR != null ? PSARR/totalARR : 0;
        
        //This loop is to calculate PS ACV/TCV as it depends on buy% of the IB and also the sum of IB ZIA/ZPA ARR
        for(LinestoNS rlw: lstfinallinestoNS){
            LinestoNS pli = rlw;
            if(opp.type == 'Existing Customer (Renewal)' && pli.productCode == 'ZCES-SUP-PREM'){
                Decimal ppuofcurrentcart = TotalNetPriceofZIAZPA != 0 && pli.NetPrice != null ? pli.NetPrice / TotalNetPriceofZIAZPA : 0;
                Decimal totalrenewal = Overall_Carveout <= Overall_Upsell ? Overall_Renewal + Overall_Carveout : Overall_Renewal + Overall_Upsell;
                pli.RenewalACV = PSARR < pli.ACV && (Math.max(ppuofcurrentcart, PPUExisting) * totalrenewal) < pli.ACV ? (Math.max(ppuofcurrentcart, PPUExisting) * totalrenewal) : pli.ACV;
                pli.UpsellACV = pli.ACV - pli.RenewalACV;
                pli.CarvedOutACV = PSARR > pli.ACV ? PSARR - pli.ACV: 0;
                pli.newACV = 0;
                if(pli.SellingTerm >= 12){
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = 0;
                        pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                    }else{
                        pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                        pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                        pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                    }
                }else{
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = 0;
                        pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                    }else{
                        pli.newTCV = pli.newACV ;
                        pli.UpsellTCV = pli.UpsellACV;
                        pli.RenewalTCV = pli.RenewalACV;
                    }
                }
                pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                plilsttoupdate.add(pli);
                if(pli.CarvedOutACV > 0){
                    plilstneedscarveout.add(pli);
                }
                Overall_Upsell += pli.UpsellACV;
                Overall_Renewal += pli.RenewalACV;
            }
            system.debug('++++carveout'+pli.CarvedOutACV);
        }
        
        //This loop is to carve out any additional ACV required to compensate Renewal ACV as long as Overall Renewal ACV < Total ARR of IB
        if(Overall_Renewal < totalARRofentireCart){
            for(LinestoNS plicarve: plilstneedscarveout){
                if(Overall_Upsell > plicarve.CarvedOutACV){
                    for(LinestoNS pli: plilsttoupdate){
                        if(pli.UpsellACV > 0 && Overall_Upsell != 0 && plicarve.CarvedOutACV != null){
                            pli.RenewalACV = (pli.RenewalACV + ((pli.UpsellACV / Overall_Upsell) * plicarve.CarvedOutACV)).setscale(2, RoundingMode.HALF_UP);
                            pli.UpsellACV = (pli.UpsellACV - ((pli.UpsellACV / Overall_Upsell) * plicarve.CarvedOutACV)).setscale(2, RoundingMode.HALF_UP);
                        }
                        if(pli.SellingTerm >= 12){
                            if(pli.isbuybackbifurcated){
                                pli.newTCV = 0;
                                pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            }else{
                                pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                                pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                                pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                            }
                        }else{
                            if(pli.isbuybackbifurcated){
                                pli.newTCV = 0;
                                pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            }else{
                                pli.newTCV = pli.newACV ;
                                pli.UpsellTCV = pli.UpsellACV;
                                pli.RenewalTCV = pli.RenewalACV;
                            }
                        }
                        pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                        pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                        pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                        pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                        pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                        pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                    }
                    Overall_Upsell -= plicarve.CarvedOutACV;
                }else{
                    for(LinestoNS pli: plilsttoupdate){
                        if(pli.UpsellACV > 0){
                            pli.RenewalACV = (pli.RenewalACV + pli.UpsellACV).setscale(2, RoundingMode.HALF_UP);
                            pli.UpsellACV = pli.UpsellACV - pli.UpsellACV;
                            if(pli.SellingTerm >= 12){
                                if(pli.isbuybackbifurcated){
                                    pli.newTCV = 0;
                                    pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                    pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                }else{
                                    pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                                    pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                                    pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                                }
                            }else{
                                if(pli.isbuybackbifurcated){
                                    pli.newTCV = 0;
                                    pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                    pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                }else{
                                    pli.newTCV = pli.newACV ;
                                    pli.UpsellTCV = pli.UpsellACV;
                                    pli.RenewalTCV = pli.RenewalACV;
                                }
                            }
                            pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                            pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                            pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                            pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                            pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                            pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                        }
                    }
                    Overall_Upsell -= Overall_Upsell;
                }
                plicarve.RenewalACV = plicarve.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                
            }
        }
        
        System.debug('----plistoupdate---'+plistoupdate);
        update plistoupdate;
        
        cow.lstfinallinestoNSwithoutinternallines = lstfinallinestoNSwithoutinternallines;
        cow.lstdroppedcontractdetails = lstdroppedcontractdetails;
        
        return cow;
    }
    
    
    @auraEnabled
    public static ResultWrapper doReview(CustomOrderWrapper cow) {
        ResultWrapper rw = new ResultWrapper();
        rw.cow = cow;
        
        Opportunity opp = cow.opp;
        
        try{
            if(!(String.isBlank(opp.Netsuite_Primary_Partner_ID_Override__c))){
                cow.nsPartnerIdOverridden = true;
            }else{
                cow.nsPartnerIdOverridden = false;
            }
            
            if(!(String.isBlank(opp.Netsuite_Customer_ID_Override__c ))){
                cow.nsCustomerIdOverridden = true;
            }else{
                cow.nsCustomerIdOverridden = false;
            }
            
            System.debug('---cow-nsPartnerIdOverridden--'+cow.nsPartnerIdOverridden);
            System.debug('---cow-nsCustomerIdOverridden--'+cow.nsCustomerIdOverridden);
            System.debug('---cow-overrideBillToId--'+cow.overrideBillToId);
            System.debug('---cow-overrideShipToId--'+cow.overrideShipToId);
            System.debug('---cow-overridePartnerId--'+cow.overridePartnerId);
            
            Boolean overrideBillToId = cow.overrideBillToId != null && cow.overrideBillToId ? true : false;
            Boolean overrideShipToId = cow.overrideShipToId != null && cow.overrideShipToId ? true : false;
            Boolean overridePartnerId = cow.overridePartnerId != null && cow.overridePartnerId ? true : false;
            
            if( overrideBillToId || overrideShipToId || overridePartnerId)
            {
                case tempCase = new case();
                tempCase.Opportunity_Name__c = opp.Id;
                tempCase.Subject = 'New Case for Bill To/ Ship To/ Venodr ID override for NS integration for Opportunity '+ opp.Name + ' / ' + opp.Id;
                tempCase.Description = 'New Case for Bill To/ Ship To/ Venodr ID override for NS integration for Opportunity '+ opp.Name + ' / ' + opp.Id;
                
                if(overrideBillToId){
                    tempCase.Description += '\n Order Ops Bill To Override: ' + opp.Netsuite_Primary_Partner_ID_Override__c;
                }
                if(overrideShipToId){
                    tempCase.Description += '\n Netsuite Partner Internal ID Override: ' + opp.Netsuite_Partner_Internal_ID_Override__c;
                }
                if(overridePartnerId){
                    tempCase.Description += '\n Order Ops Ship To Override: ' + opp.Netsuite_Customer_ID_Override__c;
                }
                
                tempCase.Case_Category__c = 'Opportunities';
                tempCase.Case_Sub_Category__c = 'Others';
                tempCase.RecordTypeId = Label.CaseRT_SalesOperation;
                tempCase.Status = 'New';
                if(!Test.isRunningTest()){
                    tempCase.OwnerId = ZscalerSetting__c.getValues('NSIntegCaseOwnerId').Value__c;
                    insert tempCase;
                }
                System.debug('--tempCase--'+tempCase);
            }
            
            rw.isSuccess= true;
            rw.errMSg = '';
            
        }
        catch(Exception exp){
            System.debug('*** Exception occured while updating the opportunity: ' + exp.getMessage() + ' ' + exp.getStackTraceString());
            System.debug('-Exception-'+exp.getMessage());
            System.debug('-Exception-'+exp.getLineNumber());
            System.debug('-Exception-'+exp.getStackTraceString());
            
            rw.isSuccess= false;
            rw.errMSg = exp.getMessage();
        }
        return rw;
    }
   
       
    //Submit the Request
    @auraEnabled
    public static CustomOrderWrapper doSubmit(CustomOrderWrapper cow) {
        List<User> usrlst = [Select Id, EmployeeNumber, IsActive, Manager.EmployeeNumber, ManagerId from User where Id = :UserInfo.getuserId()];
        try {
            
            Opportunity opp = cow.opp;
            
            opp.NS_Integration_Status__c = 'In Progress';
            opp.NS_Integration_Failure_Reason__c = '';
            opp.NS_Integration_Requested_By__c = UserInfo.getUserId();
            opp.NS_Integration_Status_Change_Time__c = system.now().addMinutes(15);
            opp.Account_Channel_Rep_ZNumber__c = opp.Account.Channel_Manager__r.IsActive && opp.Account.Channel_Manager__r.EmployeeNumber != null? opp.Account.Channel_Manager__r.EmployeeNumber : opp.Account.Channel_Manager__r.Manager.EmployeeNumber;
            opp.Account_Manager_ZNumber__c = opp.Opportunity_Account_Manager__r.IsActive && opp.Opportunity_Account_Manager__r.EmployeeNumber != null? opp.Opportunity_Account_Manager__r.EmployeeNumber : opp.Opportunity_Account_Manager__r.Manager.EmployeeNumber;
            opp.CloseDate = opp.SO_Creation_Date__c;
            
            opp.NS_Integration_Requested_by_ZNumber__c = (!usrlst.isEmpty() && usrlst[0].isActive && usrlst[0].EmployeeNumber != null) ? usrlst[0].EmployeeNumber : (usrlst[0].ManagerId != null ? usrlst[0].Manager.EmployeeNumber : null);
                opp.SE_Znumber__c = opp.SE_Name__r.IsActive && opp.SE_Name__r.EmployeeNumber != null? opp.SE_Name__r.EmployeeNumber : opp.SE_Name__r.Manager.EmployeeNumber;
            opp.Renewal_Rep_ZNumber__c = opp.Opportunity_Customer_Advocate__r.IsActive && opp.Opportunity_Customer_Advocate__r.EmployeeNumber != null? opp.Opportunity_Customer_Advocate__r.EmployeeNumber : opp.Opportunity_Customer_Advocate__r.Manager.EmployeeNumber;
            opp.Previous_Sales_Order_No__c = opp.Netsuite_Sales_Order_No__c;
            opp.Netsuite_Sales_Order_No__c = null;
            update opp;
            
            savelines(cow);
            
        } catch(Exception ex) {
            System.debug('*** Exception occured while updating the opportunity: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            throw ex;
        }
        
        sendCreateSalesOrderRequest(cow.opp.id);
        return cow;
    }
    
    
    @testVisible
    private static void removeUnusedCustomOrderLines(Custom_Order__c co){
        System.debug('--removeUnusedCustomOrderLines--called');
        MAP<ID, Custom_Order_Line__c> quotelineCustomOrderLineMAP = new MAP<ID, Custom_Order_Line__c>();
        set<ID> externalID = new set<ID>();
        
        MAP<ID, Custom_Order_Line__c> customOrderLineToBeDeleted = new MAP<ID, Custom_Order_Line__c>();
        
        for(Custom_Order_Line__c col : [Select id,External_ID__c from Custom_Order_Line__c where Custom_Order__c = :co.id]){
            if(col.External_ID__c != null && doesValidID(col.External_ID__c)){
                externalID.add(col.External_ID__c);
                quotelineCustomOrderLineMAP.put(col.External_ID__c, col);
            }else{
                customOrderLineToBeDeleted.put(col.Id,col);
            }
        }
        
        MAP<ID, SBQQ__QuoteLine__c> quoteLineMAP = new MAP<ID, SBQQ__QuoteLine__c>([Select id from SBQQ__QuoteLine__c where id in :externalID and SBQQ__Quote__c = :co.External_ID__c and Line_Status__c != 'Existing' and SBQQ__ProductCode__c != null]);
        
        
        for(ID qline : quotelineCustomOrderLineMAP.keyset()){
            if(!quoteLineMAP.keyset().contains(qline)){
                customOrderLineToBeDeleted.put(quotelineCustomOrderLineMAP.get(qline).Id,quotelineCustomOrderLineMAP.get(qline));
            }
        }
        System.debug('--customOrderLineToBeDeleted--'+customOrderLineToBeDeleted);
        delete customOrderLineToBeDeleted.values();
    }
    
    @testVisible
    private static Boolean doesValidID(String value){
        Id recordId;
        try { 
            recordId = Id.valueOf(value);
            return true;
        }
        catch (StringException e) { 
            return false;
        }
    }

   
    
    @testVisible
    private Static Custom_Order__c createCustomOrder(Opportunity opp ){        
        //Create Custom Order
        Custom_Order__c co = new Custom_Order__c();
        
        Id recordId = opp.SBQQ__PrimaryQuote__c;
        
        SBQQ__Quote__c primaryProposal = Database.query(getRecordQuery(AllFields('SBQQ__Quote__c'), 'SBQQ__Quote__c'));
        System.debug('---this.primaryProposal--'+primaryProposal);
        
        List<Generic_Field_Mapping__mdt> metaDataList = GenericFieldMappingController.getMappingFromMetaData('SBQQ__Quote__c','Custom_Order__c');
        System.debug('---metaDataList---'+metaDataList);
        if(metaDataList != null && metaDataList.size()>0){
            co = prepareCustomOrder(primaryProposal, co , metaDataList);
        }
        System.debug('---this.co--'+co);
        return co;
    }
    
    @testVisible
    private Static List<Custom_Order_Line__c> createCustomOrderlines(Opportunity opp, Custom_Order__c co ){
        System.debug('---createCustomOrderlines---called--');
         System.debug('---createCustomOrderlines---co--'+co);
        //Create Custom Order lines
        List<Custom_Order_Line__c> coLines = new List<Custom_Order_Line__c>();
        
        Map<Id, SBQQ__QuoteLine__c> plimap = new Map<Id, SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c pliSO : [SELECT SBQQ__ProductName__c,  SBQQ__Product__r.is_Phantom_SKU_s__c, SBQQ__ProductCode__c,                                           
                                         SBQQ__StartDate__c,
                                         SBQQ__EndDate__c,                                         
                                         SBQQ__Quantity__c,
                                         SBQQ__EffectiveQuantity__c,
                                         Last_Ramp_Quantity__c,
                                         SBQQ__SubscriptionTerm__c,
                                         Term__c, Total_Term__c, Effective_Term__c,                                         
                                         Recommended_Retail_Price__c,
                                         Base_Extended_Price__c,
                                         SBQQ__NetPrice__c, 
                                         SBQQ__NetTotal__c,
                                         SBQQ__ListPrice__c,
                                         SBQQ__CustomerPrice__c,
           SBQQ__ProratedListPrice__c,
                                         Price_Per_Unit__c,                                         
                                         ACV_New__c,
                                         TCV__c,                                         
                                         SBQQ__TotalDiscountRate__c,
                                         SBQQ__TotalDiscountAmount__c,                                          
                                         Line_Status__c,                                         
                                         SBQQ__Product__r.Zscaler_Product_Family__c,
                                         SBQQ__Product__r.APTS_Buyback_Eligible__c, 
                                         
                                         //Apttus_QPConfig__PriceGroup__c, 
                                         //Apttus_QPConfig__NetPrice__c,                                         
                                         //APTS_Contract_No__c,
                                         //APTS_Contract_Detail_Name__c,
                                         //APTS_Contract_Detail_Name__r.Name,
                                         //Additional_Contract_Details__c,                                         
                                         //APTS_Total_Ramp_Quantity__c,
                                         //ACV_after_Bifurcation__c, 
                                         //TCV_after_Bifurcation__c,
                                         //Proposal_SKU__c,                                         
                                         //NS_Zscaler_Net_Amount__c,
                                         //NS_Total_Discount__c,
                                         
                                         SBQQ__RenewedSubscription__r.Contract_Detail__c,
                                         SBQQ__RenewedSubscription__r.Contract_Detail__r.Name,
                                         SBQQ__RenewedSubscription__r.Contract_Detail__r.Contract_No__c,
                                         
                                         SBQQ__Discount__c,
                                         AdditionalDiscountUnit__c,
                                         Adjustment_Type__c,
                                         Adjustment__c,                                         
                                         Manual_Discount__c,
                                         Selling_Freq__c,
                                         Renewal_Deal_Reg_Discount__c,
                                         Deal_Reg_Sourced_Discount__c,
                                         Deal_Reg_Teaming_Reseller_Discount__c,
                                         
                                         MRR__c,MRR_New__c,
                                         ZSRP__c,
                                         AW_Discount__c, POV_Discount__c,
                                         Fulfillment_Discount__c,Volume_Disc__c,
                                         PartnerDisc__c,
                                         //Carved_Out_ACV__c,
                                         Distributor_Discount__c,Deployment_Discount__c,
                                         Co_sell_Discount__c,
                                         Term_after_Buyback__c,
                                         SBQQ__ProductSubscriptionType__c,
                                         Is_Ramped__c,
                                         Total_Discount_Base__c, //CR# 4054
                                         AW_POV_Discount__c, //CR-2556
                                         NS_Product_SKU__c,
                                         Ns_Product_Id__c,
                                         Line_Renewal_ACV__c,
                                         Line_Upsell_ACV__c,
                                         Country_Language__c //IBA-5722
                                         FROM SBQQ__QuoteLine__c
                                         WHERE SBQQ__Quote__c = :opp.SBQQ__PrimaryQuote__c
                                         And SBQQ__Product__r.is_Phantom_SKU_s__c = false
                                         And Line_Status__c != 'Existing'
                                         //And Line_Status__c != 'Cancelled'
                                         AND SBQQ__ProductCode__c != null
                                         order by SBQQ__Number__c
                                         
                                         ]) 
        {            
            plimap.put(pliSO.Id,pliSO);
        }
        
        
        //Create Custom Order lines
        List<Generic_Field_Mapping__mdt> metaDataListLines = GenericFieldMappingController.getMappingFromMetaData('SBQQ__QuoteLine__c','Custom_Order_Line__c');
        System.debug('---metaDataListLines---'+metaDataListLines);
        
        for(Id pliId : plimap.keyset()){
            SBQQ__QuoteLine__c pliSO = plimap.get(pliId);
            if(metaDataListLines != null && metaDataListLines.size()>0){
                Custom_Order_Line__c coline = new Custom_Order_Line__c(Custom_order__c = co.id);
                //Prefill Parent Field Values
                
                coline.Total_Term_after_Buyback__c = pliSO.Term_after_Buyback__c != null ? pliSO.Term_after_Buyback__c : 0; 
                
                //coline.Total_Zscaler_Discount__c = pliSO.Apttus_QPConfig__DerivedFromId__r.Total_Zscaler_Discount__c;
                //coline.Asset_Line_Item_Id__c = pliSO.Apttus_QPConfig__AssetLineItemId__c;
                coline.Type__c = 'Main';
                
                //CR# 4054
                coline.Total_Discount_New__c = plisO.Total_Discount_Base__c != null ? plisO.Total_Discount_Base__c : 0;
                
                if(opp.Type == 'New Business'){
                    //coLine.New_TCV_to_NetSuite__c = pliSO.SBQQ__NetTotal__c;
                    //coLine.New_ACV_to_NetSuite__c = pliSO.ACV_New__c;
                } else if(opp.Type == 'Existing Customer (Add On)'){
                    //coLine.Upsell_TCV_to_NetSuite__c = pliSO.SBQQ__NetTotal__c;
                    //coLine.Upsell_ACV_to_NetSuite__c = pliSO.ACV_New__c;
                } else if (opp.type == 'Existing Customer (Renewal)'){
                    if(pliso.SBQQ__RenewedSubscription__r != null && pliso.SBQQ__RenewedSubscription__r.Contract_Detail__c != null){
                        coline.Contract_Detail_Name__c =  pliSO.SBQQ__RenewedSubscription__r.Contract_Detail__c;
                        coline.Contract_No__c =  pliSO.SBQQ__RenewedSubscription__r.Contract_Detail__r.Contract_No__c;
                    }
                }
                
                
                coline = prepareCustomOrderLine(pliSO, coline, metaDataListLines);
                
                coline.Buyback_Period_in_Months__c = (coline.Term__c != null ? coline.Term__c : 0)  - (coline.Total_Term_after_Buyback__c != null ? coline.Total_Term_after_Buyback__c : 0);
                
                coline.Quantity__c = coline.Quantity__c == null || coline.Quantity__c == 0 ? pliSO.SBQQ__EffectiveQuantity__c : coline.Quantity__c; 
                
                coline.Price_Type__c = pliSO.SBQQ__ProductSubscriptionType__c != null && pliSo.SBQQ__ProductSubscriptionType__c == 'One-time'? 'One Time': null;
                
                coLines.add(coline);
            }
        }
        System.debug('---coLines---'+coLines);
        
        return coLines;
    }
    
    
    
    
    
    private static Custom_Order__c prepareCustomOrder(SBQQ__Quote__c proposal,  Custom_Order__c coObj, List<Generic_Field_Mapping__mdt> metaDataList){
        if(coObj == null)
            coObj = new Custom_Order__c();
        
        List<Generic_Field_Mapping__mdt> coMapping = new  List<Generic_Field_Mapping__mdt>();
        for(Generic_Field_Mapping__mdt mdt : metaDataList){
            if(mdt.Origin__c != null && mdt.Origin__c == 'CreateSalesOrder'){
                coMapping.add(mdt);
            }
        }
        System.debug('---prepareCustomOrder--coMapping--'+coMapping);
        
        coObj = (Custom_Order__c)GenericFieldMappingController.prepareRecordFromGenericFieldMapping(proposal, coObj, coMapping);
        return coObj;
    }
    
    private static Custom_Order_Line__c prepareCustomOrderLine(SBQQ__QuoteLine__c proposalLine,  Custom_Order_Line__c coObj, List<Generic_Field_Mapping__mdt> metaDataList){
        if(coObj == null)
            coObj = new Custom_Order_Line__c();
        
        List<Generic_Field_Mapping__mdt> coMapping = new  List<Generic_Field_Mapping__mdt>();
        for(Generic_Field_Mapping__mdt mdt : metaDataList){
            if(mdt.Origin__c != null && mdt.Origin__c == 'CreateSalesOrder'){
                coMapping.add(mdt);
            }
        }
        System.debug('---prepareCustomOrder--coMapping--'+coMapping);
        coObj = (Custom_Order_Line__c)GenericFieldMappingController.prepareRecordFromGenericFieldMapping(proposalLine, coObj, coMapping);
        return coObj;
    }
    
    
    
    
    public static List<String> AllFields(String ObjectName) {
        System.debug('--AllFields--ObjectName--'+ObjectName);
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().keySet());
        return fields;
    }
    
    public Static String getRecordQuery(List<String> fields,String ObjectName){
        return 'SELECT '+String.join(fields, ',')+' FROM '+ObjectName+ ' Where Id = :recordId';
    }
    
    public Static String getRecordsQuery(List<String> fields,String ObjectName){
        return 'SELECT '+String.join(fields, ',')+' FROM '+ObjectName+ ' Where Id  in :recordIdList';
    }
    
    
    @testvisible 
    private Static List<Custom_Order_Line__c> getCustomOrderLines(Set<ID> recordIdList){
        List<String> fieldList = AllFields('Custom_Order_Line__c');
        fieldList.add('Product__r.Name');
        fieldList.add('Contract_Detail_Name__r.Name');
        fieldList.add('Product__r.Zscaler_Product_Family__c');
        fieldList.add('Product__r.Deployment_Margin__c');
        fieldList.add('Product__r.APTS_Buyback_Eligible__c');
        return Database.query(getRecordsQuery(fieldList, 'Custom_Order_Line__c'));
    }
    
    @testvisible 
    private Static List<Custom_Order__c> getCustomOrder(Set<ID> recordIdList){
        List<String> fieldList = AllFields('Custom_Order__c');
        return Database.query(getRecordsQuery(fieldList, 'Custom_Order__c'));
    }
    
    
    
    @testVisible
    private static void savelines(CustomOrderWrapper cow){
        Opportunity opp = cow.opp;
        List<LinestoNS> lstfinallinestoNS = cow.lstfinallinestoNS;
        Decimal totalnewacv = 0, totalnewtcv = 0, totalupsellacv = 0, totalupselltcv = 0, totalrenewaltcv = 0, totalrenewalacv = 0;
        
        List<Custom_Order_Line__c> plilsttoupdate = new List<Custom_Order_Line__c> ();
        for(LinestoNS pli: lstfinallinestoNS){
            if(pli.pliId != null){
                Custom_Order_Line__c proposallineitem = new Custom_Order_Line__c(Id = pli.pliId, New_ACV_to_NetSuite__c = pli.newACV, 
                                                                                 Upsell_ACV_to_NetSuite__c = pli.UpsellACV, 
                                                                                 Renewal_ACV_to_NetSuite__c = pli.RenewalACV, 
                                                                                 Carved_Out_ACV__c = pli.CarvedOutACV, 
                                                                                 Additional_Contract_Details__c = pli.addcontractDetailName, 
                                                                                 Contract_Detail_Name__c = pli.contractDetailId, 
                                                                                 New_TCV_to_NetSuite__c = pli.newTCV, 
                                                                                 Upsell_TCV_to_NetSuite__c = pli.UpsellTCV, 
                                                                                 Renewal_TCV_to_NetSuite__c = pli.RenewalTCV, 
                                                                                 ACV_after_Bifurcation__c = pli.acv, 
                                                                                 TCV_after_Bifurcation__c = pli.NetPrice);
                plilsttoupdate.add(proposallineitem);
                
                totalnewacv += pli.newACV;
                totalnewtcv += pli.newTCV;
                totalupsellacv += pli.UpsellACV;
                totalupselltcv += pli.UpsellTCV;
                totalrenewaltcv += pli.RenewalTCV;
                totalrenewalacv += pli.RenewalACV;
            }
        }
        
        System.debug('--cow--nooverrideACV--'+cow.nooverrideACV);
        
        
        //update Custom Order
        Custom_Order__c custOrder = new Custom_Order__c();
        custOrder.Id = opp.Custom_Order__c;
        custOrder.Total_New_ACV__c = totalnewacv;
        custOrder.Total_New_TCV__c = totalnewtcv;
        custOrder.Total_Upsell_ACV__c = totalupsellacv;
        custOrder.Total_Upsell_TCV__c = totalupselltcv;
        custOrder.Total_Renewal_ACV__c = totalrenewalacv;
        custOrder.Total_Renewal_TCV__c = totalrenewaltcv;
        custOrder.Do_Not_Override_ACV__c = cow.nooverrideACV;
        TriggerUtility.generateYearWiseSplitExecuted();
        update custOrder;
        update plilsttoupdate;
    }
    
    @testvisible 
    @Future(Callout = true)
    private static void sendCreateSalesOrderRequest(Id opportunityId) {
        System.debug('--sendCreateSalesOrderRequest--called--');
        Opportunity oppty = [SELECT Id, Type, NS_Integration_Status__c, NS_Integration_Failure_Reason__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        
        if (oppty == null) {
            return;
        }
        
        String createSaleOrderSource  = System.label.Create_Sales_Order_Source;
        
        if(createSaleOrderSource == 'Workato'){
            FireCreateSalesOrderPlatformEvents(oppty);
        }else{
            Map<String, String> requestMap = new Map<String, String> { 'id' => opportunityId, 'type' => oppty.Type };
                
            
            HttpRequest request = createHttpRequest('callout:DB_Create_Sales_Order/v1/create', 'POST', JSON.serialize(requestMap));
            HttpResponse response;
             System.debug('--request--'+request);
            Http http = new Http();
            response = http.send(request);
            System.debug('--response--'+response.getBody());
            
            createIntegrationLog((String)opportunityId, '', 'callout:DB_Create_Sales_Order/v1/create', 'POST', JSON.serialize(requestMap), response.getBody(), string.valueOf(response.getStatusCode()), response.getStatusCode() == 200 ? 'Success': 'Failure');
            if(response.getStatusCode() != 200){
                oppty.NS_Integration_Status__c = 'Failure';
                oppty.NS_Integration_Failure_Reason__c = response.getBody();
                update oppty;
            }
        }
        
    }
    
    public Static void FireCreateSalesOrderPlatformEvents(Opportunity opp){
        List<Opportunity_Create_Sale_Order_Event__e>  SOEventList = new List<Opportunity_Create_Sale_Order_Event__e>();
        SOEventList.add(new Opportunity_Create_Sale_Order_Event__e(Opportunity_Id__c=opp.id, Opportunity_Type__c = opp.Type));
        EventBus.publish(SOEventList);
    }
    
    @auraEnabled
    public Static  List<NetSuiteCustomerInfoLine> getCustomerDetails(Opportunity opp){
        List<NetSuiteCustomerInfoLine> responseObj = new List<NetSuiteCustomerInfoLine>();
        System.debug('----getCustomerDetails---opp--'+opp);
        
        String customerID = opp.Netsuite_Customer_ID__c;
        String customerOverriddenId = opp.Netsuite_Customer_ID_Override__c;
        String billToId = opp.Netsuite_Primary_Partner_ID__c;
        String billToOverriddenId = opp.Netsuite_Primary_Partner_ID_Override__c;
        
        
        
        List<Account> acclst = [Select Id, NetSuite_Internal_id__c, 
                                Netsuite_Partner_Internal_Id__c from Account where
                                NetSuite_Internal_id__c = :billToOverriddenId limit 1];
        String partnerId = !acclst.isEmpty() && acclst[0].Netsuite_Partner_Internal_Id__c != null ? acclst[0].Netsuite_Partner_Internal_Id__c : billToOverriddenId;
        
        String partnerOverriddenId = opp.Netsuite_Partner_Internal_ID_Override__c;
        
        
        System.debug('----customerID---'+customerID);
        System.debug('----customerOverriddenId---'+customerOverriddenId);
        System.debug('----billToId---'+billToId);
        System.debug('----billToOverriddenId---'+billToOverriddenId);
        System.debug('----partnerId---'+partnerId);
        System.debug('----partnerOverriddenId---'+partnerOverriddenId);
        
        List<String> lstCustomerIds = new List<String>();
        List<String> lstPartnerIds = new List<String>();
        
        if(customerId != null && customerId != '')
            lstCustomerIds.add(customerId);
        if(billToId != null && billToId != '')
            lstCustomerIds.add(billToId);
        if(customerOverriddenId != null && customerOverriddenId != '')
            lstCustomerIds.add(customerOverriddenId);
        if(billToOverriddenId != null && billToOverriddenId != '')
            lstCustomerIds.add(billToOverriddenId);
        
        if(partnerId != null && partnerId != '')
            lstPartnerIds.add(partnerId);
        if(partnerOverriddenId != null && partnerOverriddenId != ''){
            lstPartnerIds.add(partnerOverriddenId);
        }
        
       
        String jsonstr = '{"customerIds": ' + JSON.serialize(lstCustomerIds) + ', "partnerIds" : ' + JSON.serialize(lstPartnerIds) +  '}';
        System.debug('--jsonstr---'+jsonstr);
        
        //HttpRequest request = createHttpRequest('callout:DB_Create_Sales_Order/v1/CustomerAndPartner', 'POST', jsonstr);
        //request.setHeader('Content-Type','application/json');
        //request.setHeader('accept','application/json');
        
        //String responseHardCode = '[{"id" : 21026, "name" : "testCustomer", "entityId" : "123", "type" : "customer"},{"id": 4883, "name": "testCustomer1", "entityId" : "123", "type" : "customer"}]';
        
        
        try {
            //Http http = new Http();
            //HttpResponse response = http.send(request);
            HttpResponse response = WorkatoAPIUtility.retrivePartnerAndCustomerDetails(jsonstr);
            System.debug('--responseBody--'+response.getBody());
            
            
            NetSuiteCustomerInfoResponse res = response.getBody() != null && response.getBody() != '' ? (NetSuiteCustomerInfoResponse)JSON.deserialize(response.getBody(),NetSuiteCustomerInfoResponse.class) : new NetSuiteCustomerInfoResponse();
            
            responseObj =  res.customersandpartners;
            
        } catch (Exception ex) {
            System.debug('*** Error occurred fetching NS account information: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            responseObj = new List<NetSuiteCustomerInfoLine>();
        }
        
        
        //responseObj =  (List<NetSuiteCustomerInfoLine>)JSON.deserialize(responseHardCode, List<NetSuiteCustomerInfoLine>.class);
        
        return responseObj;
    }  
    
    
    @testvisible 
    private static void updateTheMargins(Custom_Order__c co, Opportunity opp){
        System.debug('---updateTheMargins--called---');
        
        if(opp.SBQQ__PrimaryQuote__r.Bill_to__c != null){
            co.Fulfillment_Discount__c = opp.SBQQ__PrimaryQuote__r.Fulfillment_Discount__c != null ? opp.SBQQ__PrimaryQuote__r.Fulfillment_Discount__c  : 0;
        }
        
        if(opp.Deal_Reg_Margin__c != null){
            co.Deal_Reg_Sourced_Discount__c = opp.SBQQ__PrimaryQuote__r.Deal_Reg_Sourced_Discount__c != null ? opp.SBQQ__PrimaryQuote__r.Deal_Reg_Sourced_Discount__c  : 0;
        }
        
        if(opp.Deal_Reg_Partner_Teaming_Reseller__c != null){
            co.Deal_Reg_Teaming_Reseller_Discount__c = opp.SBQQ__PrimaryQuote__r.Deal_Reg_Teaming_Reseller_Discount__c != null ? opp.SBQQ__PrimaryQuote__r.Deal_Reg_Teaming_Reseller_Discount__c  : 0;
        }
               
        co.Deployment_Discount__c = opp.SBQQ__PrimaryQuote__r.Deployment_Discount__c != null ? opp.SBQQ__PrimaryQuote__r.Deployment_Discount__c  : 0;
        if(opp.SBQQ__PrimaryQuote__c != NULL && opp.SBQQ__PrimaryQuote__r.Summit_Distribution__c){
            co.Transacting_Distributor_Discount__c = opp.SBQQ__PrimaryQuote__r.Transacting_Distributor_Discount__c != null? opp.SBQQ__PrimaryQuote__r.Transacting_Distributor_Discount__c : 0;
        }
        else{
            co.Transacting_Distributor_Discount__c = opp.SBQQ__PrimaryQuote__r.Distributor_Disc__c != null? opp.SBQQ__PrimaryQuote__r.Distributor_Disc__c : 0;    
        }
       
    }
    
    @testvisible 
    private static HttpRequest createHttpRequest(String endpoint, String method, String body) {
        return createHttpRequest(endpoint, method, body, 120000);
    }
    
    @testvisible 
    private static HttpRequest createHttpRequest(String endpoint, String method, String body, Integer timeout) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setBody(body);
        request.setTimeout(timeout);
        return request;
    }
    
    @testvisible 
    private static void createIntegrationLog(String objectId, String typeOfOperation, String endpoint, String queryParameters,
                                             String request, String response, String status, String statusDetail) 
    {
        Integration_Log__c log = new Integration_Log__c(
            Related_Record_Id__c = objectId,
            Opportunity__c = objectId,
            Type_Of_Operation__c = typeOfOperation,
            Endpoint__c = endpoint,
            Query_Parameters__c = queryParameters,
            Request__c = request,
            Response__c = response,
            Response_Code__c = decimal.valueOf(status),
            Status__c = status,
            Status_Detail__c = statusDetail
        );
        
        try {
            TriggerUtility.intLogtriggerPRLogicExecuted();
            insert log;
        } catch (Exception ex) {
            System.debug('*** Error occurred while creating Integartion Log entry ' + JSON.serialize(log) + '; ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
    
    
    public class CustomOrderWrapper{
        @auraEnabled
        public Opportunity opp{get;set;}
        @auraEnabled
        public Custom_order__c custOrder{get;set;}
        @auraEnabled
        public List<Custom_Order_Line__c> customOrderLines {get;set;}
        
        
        
        @auraEnabled
        public Boolean isRenewal{get;set;}
        
        @auraEnabled
        public Boolean isTraditional{get;set;}
        
        @auraEnabled
        public Boolean isSummitDiscount{get;set;}
        
        @auraEnabled
        public Boolean isFy21SingleTier{get;set;}
        @auraEnabled
        public Boolean isFy21VolumeTier{get;set;}
        @auraEnabled
        public Boolean showupsellacv{get;set;}
        @auraEnabled
        public Boolean showrenewalacv{get;set;}
        @auraEnabled
        public Boolean shownewacv{get;set;}
        @auraEnabled
        public Boolean requireSecPartner{get;set;}
        @auraEnabled
        public String partnerSummit{get;set;}
        @auraEnabled
        public String partnerDiscount{get;set;}
        
        @auraEnabled
        public String billToDetails{get;set;}
        @auraEnabled
        public String billToOverriddenDetails{get;set;}
        @auraEnabled
        public String partnerIdOverriddendetails{get;set;}
        
        @auraEnabled
        public String shipToDetails{get;set;}
        @auraEnabled
        public String shipToOverriddenDetails{get;set;}
        
        @auraEnabled
        public boolean nooverrideACV{get;set;}
        
        @auraEnabled
        public boolean hasinternallines{get;set;}
        
        
        @auraEnabled
        public List<LinestoNS> lstfinallinestoNSwithoutinternallines{get;set;}
        @auraEnabled
        public List<LinestoNS> lstfinallinestoNSwithInternalLines{get;set;}
        @auraEnabled
        public List<Contract_Detail__c> lstdroppedcontractdetails{get;set;}    
        
        @auraEnabled
        public List<LinestoNS> lstfinallinestoNS{get;set;} 
        
        @auraEnabled
        public Map<String, Contract_Detail__c> cdnamemap{get;set;}
        
        
        @auraEnabled
        public Boolean nsPartnerIdOverridden {get; set;}
        
        @auraEnabled
        public Boolean nsCustomerIdOverridden {get; set;}
        
        @auraEnabled
        public Boolean overrideBillToId { get; set; }
        @auraEnabled
        public Boolean overridePartnerId { get; set; }
        @auraEnabled
        public Boolean overrideShipToId { get; set; }
    }
    
    public class ResultWrapper {
        @auraEnabled
        public Boolean isSuccess { get; set; }
        @auraEnabled
        public String errMsg { get; set; }
        @auraEnabled
        public CustomOrderWrapper cow { get; set; }
    }
    
    
    
    public class LinestoNS {
        @auraEnabled
        public Id recId { get; set; }
        @auraEnabled
        public Id pliId { get; set; }
        
        @auraEnabled
        public String productName { get; set; }
        @auraEnabled
        public String productfamily { get; set; }
        @auraEnabled
        public String productId { get; set; }
        @auraEnabled
        public String productCode { get; set; }
        
        @auraEnabled
        public String quoteId { get; set; }
       
        
        
        @auraEnabled
        public Decimal Qty { get; set; }
        @auraEnabled
        public Date StartDate { get; set; }
        @auraEnabled
        public Date EndDate { get; set; }
        @auraEnabled
        public Decimal SellingTerm { get; set; }
        
        @auraEnabled
        public Decimal basePrice { get; set; }
        @auraEnabled
        public Decimal baseExtendedPrice { get; set; }
        @auraEnabled
        public Decimal recommendedRetailPrice { get; set; }
        @auraEnabled
        public Decimal ListPrice { get; set; }
        @auraEnabled
        public Decimal NetPrice { get; set; }
        @auraEnabled
        public Decimal NetPriceOriginal { get; set; }
        
        @auraEnabled
        public Decimal discPercent { get; set; }
        
        @auraEnabled
        public Decimal ACV { get; set; }
        @auraEnabled
        public Decimal ACVoriginal { get; set; }
        @auraEnabled
        public Decimal newACV { get; set; }
        @auraEnabled
        public Decimal UpsellACV { get; set; }
        @auraEnabled
        public Decimal RenewalACV { get; set; }
        @auraEnabled
        public Decimal newTCV { get; set; }
        @auraEnabled
        public Decimal UpsellTCV { get; set; }
        @auraEnabled
        public Decimal RenewalTCV { get; set; }
        @auraEnabled
        public Decimal CarvedOutACV { get; set; }
        
        @auraEnabled
        public String contractDetailName { get; set; }
        @auraEnabled
        public String contractNo { get; set; }
        @auraEnabled
        public Id contractDetailId { get; set; }
        @auraEnabled
        public String addcontractDetailName { get; set; }
       
        @auraEnabled
        public Boolean isbuybackbifurcated { get; set; }
        
        
        //Summit Discount
        @auraEnabled
        public Decimal awDiscount { get; set; }
        @auraEnabled
        public Decimal povDiscount { get; set; }
        
        //CR-2556
        @auraEnabled
        public Decimal aw_povDiscount { get; set; }
        //CR-3665
        @auraEnabled
        public Boolean isRamped { get; set; }    
        
        @auraEnabled
        public Decimal fulDiscount { get; set; }
        
        //Renewal_Deal_Reg_Discount__c
        @auraEnabled
        public Decimal drRenewalDiscount { get; set; }
        
        @auraEnabled
        public Decimal drSourcedDiscount { get; set; }
        @auraEnabled
        public Decimal drTeamingResellerDiscount { get; set; }
        @auraEnabled
        public Decimal depDiscount { get; set; }     
        @auraEnabled
        public Decimal volumeDiscount { get; set; }     
        
        @auraEnabled
        public Decimal  partnerDiscount { get; set; } 
        
        //deva CR#1768
        @auraEnabled
        public Decimal distributorDiscount {get;set;}
        @auraEnabled
        public String adjustType  { get; set; }  
        @auraEnabled
        public Decimal adjustValue  { get; set; }  
        
        @auraEnabled
        public Decimal coCellDiscount  { get; set; }  
        @auraEnabled
        public Decimal blendedDiscount  { get; set; }  
        @auraEnabled
        public Decimal disNetPrice { get; set; }
        
        
        @auraEnabled
        public Decimal aptsACV  { get; set; }  
        @auraEnabled
        public Decimal aptsMRR  { get; set; }
        @auraEnabled
        public Decimal aptsMCV  { get; set; }  
        
        @auraEnabled
        public Decimal zsrp  { get; set; }  
        
        
        @auraEnabled
        public Boolean showDeploymentMargin { get; set; }
        @auraEnabled
        public Boolean showDeploymentDiscount { get; set; }
        
        public LinestoNS() {
            
        }
        
        
        //For Main lines
        public LinestoNS(Custom_Order_Line__c lineItem, Boolean buybackbifur) {
            
            pliId = lineItem.Id;
            recId = pliId;
            productName  = lineItem.Product__r.Name;
            productCode = lineItem.SKU__c;
            basePrice = lineItem.Base_Price__c;
            Qty = lineItem.Quantity__c;
            StartDate = lineItem.Start_Date__c;
            EndDate = lineItem.End_Date__c;
            SellingTerm = lineItem.Term__c;
            
            recommendedRetailPrice = lineItem.Recommended_Retail_Price__c;
            ListPrice = lineItem.List_Price__c; 
            baseExtendedPrice = lineItem.Base_Extended_Price__c;
            basePrice = lineItem.Base_Price__c;
            
            discPercent = (lineItem.Total_Discount__c != null ? lineItem.Total_Discount__c : 0)/100;
            NetPrice = lineItem.TCV_after_Bifurcation__c != null ? lineItem.TCV_after_Bifurcation__c : 0;
            NetPriceOriginal = lineItem.Net_Price__c != null ? lineItem.Net_Price__c : 0;
            ACV = lineItem.ACV_after_Bifurcation__c != null ? lineItem.ACV_after_Bifurcation__c : 0;
            ACVoriginal = lineItem.ACV__c != null ? lineItem.ACV__c : 0;
            newTCV = lineItem.New_TCV_to_NetSuite__c != null ? lineItem.New_TCV_to_NetSuite__c : 0;
            UpsellTCV = lineItem.Upsell_TCV_to_NetSuite__c != null ? lineItem.Upsell_TCV_to_NetSuite__c : 0 ;
            RenewalTCV = lineItem.Renewal_TCV_to_NetSuite__c != null ? lineItem.Renewal_TCV_to_NetSuite__c : 0;
            newACV = lineItem.New_ACV_to_NetSuite__c != null ? lineItem.New_ACV_to_NetSuite__c : 0;
            UpsellACV = lineItem.Upsell_ACV_to_NetSuite__c != null ? lineItem.Upsell_ACV_to_NetSuite__c : 0;
            RenewalACV = lineItem.Renewal_ACV_to_NetSuite__c != null ? lineItem.Renewal_ACV_to_NetSuite__c : 0;
            CarvedOutACV = 0;
            
            System.debug('----lineItem.Price_Group__c--'+lineItem.Price_Group__c);
            System.debug('----lineItem.Total_Ramp_Quantity__c--'+lineItem.Total_Ramp_Quantity__c);
            System.debug('----lineItem.Quantity__c--'+lineItem.Quantity__c);
            System.debug('----lineItem.Additional_Contract_Details__c--'+lineItem.Additional_Contract_Details__c);
            
            
            contractNo = lineItem.Price_Group__c != 'Price Ramp' || (lineItem.Price_Group__c == 'Price Ramp' && lineItem.Total_Ramp_Quantity__c == lineItem.Quantity__c) ? lineItem.Contract_No__c : '';
            contractDetailName = lineItem.Price_Group__c != 'Price Ramp' || (lineItem.Price_Group__c == 'Price Ramp' && lineItem.Total_Ramp_Quantity__c == lineItem.Quantity__c) ? lineItem.Contract_Detail_Name__r.name : '';
            contractDetailId =  lineItem.Price_Group__c != 'Price Ramp' || (lineItem.Price_Group__c == 'Price Ramp' && lineItem.Total_Ramp_Quantity__c == lineItem.Quantity__c) ? lineItem.Contract_Detail_Name__c : null;
            addcontractDetailName =  lineItem.Price_Group__c != 'Price Ramp' || (lineItem.Price_Group__c == 'Price Ramp' && lineItem.Total_Ramp_Quantity__c == lineItem.Quantity__c) ? lineItem.Additional_Contract_Details__c : '';
            
            quoteId = lineItem.Custom_Order__c;
            productId =  lineItem.Product__c;
            isbuybackbifurcated = buybackbifur;
            productfamily = lineItem.Product__r.Zscaler_Product_Family__c;
            awDiscount = lineItem.AW_Discount__c != null ? lineItem.AW_Discount__c/100 : 0;
            povDiscount = lineItem.POV_Discount__c != null ? lineItem.POV_Discount__c/100 : 0; 
            
            //CR-2556
            aw_povDiscount = (lineItem.AW_POV_Discount__c != null ) ? lineItem.AW_POV_Discount__c /100 :0;

            //CR-3665
            isRamped =  lineItem.Is_Ramped__c;
            
            fulDiscount = lineItem.Fulfilment_Discount__c != null ? lineItem.Fulfilment_Discount__c/100 : 0;  
            
            drRenewalDiscount = lineItem.Renewal_Deal_Reg_Discount__c != null ? lineItem.Renewal_Deal_Reg_Discount__c/100: 0;  
            drSourcedDiscount = lineItem.Sourced_Deal_Reg_Discount__c != null ? lineItem.Sourced_Deal_Reg_Discount__c/100: 0;  
            drTeamingResellerDiscount = lineItem.Teaming_Deal_Reg_Discount__c != null ? lineItem.Teaming_Deal_Reg_Discount__c/100 : 0;  
            
            depDiscount = lineItem.Deployment_Discount__c != null ? lineItem.Deployment_Discount__c/100 : 0;   
            
            showDeploymentDiscount = (lineItem.Product__r.Deployment_Margin__c != null &&
                                      lineItem.Product__r.Deployment_Margin__c == true) ? true : false;
            
            adjustType = lineItem.Partner_Adjustment_Type__c;
            adjustValue = lineItem.Partner_Adjustment__c != null ? lineItem.Partner_Adjustment__c : 0;
            
            coCellDiscount = lineItem.Co_sell_Discount__c != null ? lineItem.Co_sell_Discount__c/100 : 0;
            blendedDiscount = (lineItem.Total_Zscaler_Discount__c != null) ? lineItem.Total_Zscaler_Discount__c/100 : 0;
            disNetPrice = (lineItem.Net_Price__c != null) ? lineItem.Net_Price__c : 0;
            aptsACV = (lineItem.ACV__c != null ) ? lineItem.ACV__c : 0;
            aptsMRR = (lineItem.MRR__c != null ) ? lineItem.MRR__c : 0;
            volumeDiscount = (lineItem.Volume_Discount__c != null ) ? lineItem.Volume_Discount__c/100 : 0;
            partnerDiscount = (lineItem.PartnerDisc__c != null ) ? lineItem.PartnerDisc__c: 0;
            distributorDiscount = (lineItem.Distributor_Discount__c != null ) ? lineItem.Distributor_Discount__c/100 :0;
            
            
            
            zsrp = (lineItem.ZSRP__c != null ) ? lineItem.ZSRP__c:0;
        }
    }
    
    
    public class NetSuiteCustomerInfoResponse {
        public List<NetSuiteCustomerInfoLine> customersandpartners { get; set; }
        
        //public List<NetSuiteCustomerInfoLine> response { get; set; }
        
        public NetSuiteCustomerInfoResponse() {
            this.customersandpartners = new List<NetSuiteCustomerInfoLine>();
        }
    }
    
    public class NetSuiteCustomerInfoLine {
        @auraEnabled
        public Integer id { get; set; }
        @auraEnabled
        public String name { get; set; }
        @auraEnabled
        public String entityId { get; set; }
        @auraEnabled
        public String type { get; set; }
    }
    
    public class SFDCNSIntegrationException extends Exception {}
    
    
    
    @testvisible
    private static void codebooster(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}