/*********************************************************************************
** Class Name: QuoteTriggerHelper
**
** Description: This class contains methods which are getting invoked
from Quote Trigger.
*********************************************************************************/
public class QuoteTriggerHelper {

public static Boolean blnRunOnce = false;
/*********************************************************************************
** Method Name: assignRecordType
**
** Description: Thid methood assigns RecordType to Quote based on parent Opportunity 
Record Type values.
**
** @Param : List<SBQQ__Quote__c>
** @return : List<Opportunity>
*********************************************************************************/
public static void assignRecordType(List<SBQQ__Quote__c> newList){
    if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        system.debug('inside quote creation trigger');
        List<Opportunity> OppList = new List<Opportunity>();
        Map<Id, Opportunity> mapOppRecord = new Map<Id, Opportunity>();
        Set<ID> OppIDs = new Set<ID>();
        Set<ID> AccIDs = new Set<ID>();
        Id newBusReTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id renewReTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(SB_CONSTANTS.RENEWAL).getRecordTypeId();
        Id amendReTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        //try{
        for(SBQQ__Quote__c qt : newList){
            OppIDs.add(qt.SBQQ__Opportunity2__c);
            if(qt.SBQQ__partner__c!=null && qt.SBQQ__partner__c!=qt.Bill_to__c && qt.Bill_to__c!= null  ){
                AccIDs.add(qt.Bill_to__c);
            }
        }
        if(!OppIDs.isEmpty()){
            OppList = [ SELECT id, name ,OwnerId, recordType.DeveloperName,closedate,SBQQ__RenewedContract__c,account.name,
                        Is_Federal_Opportunity_Sync__c, Region_Account__c,Account.Region__c,
                            (SELECT id,Account__c,Approval_Status__c,Is_Primary__c,Partner_Type__c,Partner_Program__c,Partner_Incentive__c,
                            Partner_Incentive__r.DR_Sourced__c, Partner_Incentive__r.Deal_Reg_Teaming__c,Partner_Incentive__r.Fulfillment__c,
                            Partner_Incentive__r.Architecture_Workshop__c,Partner_Incentive__r.POV__c,Partner_Incentive__r.New_Logo__c,
                            Partner_Incentive__r.Default__c,Partner_Incentive__r.Effective_End_Date__c,Partner_Incentive__r.Effective_Start_Date__c,
                            Partner_Incentive__r.Active__c,Partner_Incentive__r.Category_A__c,Partner_Incentive__r.Distributor__c 
                            FROM Opportunity_Partners__r WHERE Is_Primary__c=true AND Partner_Type__c='Reseller' AND Partner_Incentive__c!=null) 
                        FROM Opportunity WHERE id IN :OppIDs];

            Map<id,List<Partner_Incentive__c>> accWithIncentive  = new Map<id,List<Partner_Incentive__c>>();
            for(Partner_Incentive__c prInc:[SELECT id,Account__c,Distributor__c FROM Partner_Incentive__c WHERE Account__c IN : AccIDs AND Distributor__c!= null AND Partner_Role__c=:SB_CONSTANTS.PARTNER_TYPE_DISTRIBUTOR AND Active__c = true AND Effective_Start_Date__c <= :Date.today() AND Effective_End_Date__c >= :Date.today()]){
                if(accWithIncentive.containsKey(prInc.Account__c)){
                    accWithIncentive.get(prInc.Account__c).add(prInc);
                }
                else{
                    accWithIncentive.put(prInc.Account__c,new List<Partner_Incentive__c>{prInc});
                }
            }
            
            System.debug('OppList is:' +OppList+'accWithIncentive'+accWithIncentive);
            if(!OppList.isEmpty()){
                for(Opportunity opp : OppList){
                    mapOppRecord.put(opp.id,opp );
                }
                system.debug('mapOppRecord is:'+mapOppRecord);
                if(!mapOppRecord.isEmpty()){
                    for(SBQQ__Quote__c qt : newList){
                        if(mapOppRecord.containskey(qt.SBQQ__Opportunity2__c)){
                            Opportunity Opp = mapOppRecord.get(qt.SBQQ__Opportunity2__c);
                            if(Opp.recordType.DeveloperName == 'New_Business_Open' || 
                                Opp.recordType.DeveloperName == 'New_Business_Close'){
                                    qt.RecordTypeId = newBusReTypeID != NULL ? newBusReTypeID : null;
                                }
                            else if(Opp.recordType.DeveloperName == 'Upsell_Opportunity_Open' || 
                                    Opp.recordType.DeveloperName == 'Upsell_Opportunity_Closed'){
                                        
                                        qt.RecordTypeId = amendReTypeID != NULL ? amendReTypeID : null;
                                    }else if(Opp.recordType.DeveloperName == 'Renewal_Opportunity'){
                                        
                                        qt.RecordTypeId = renewReTypeID != NULL ? renewReTypeID :null;
                                        //added by Rakshitha. To set the quote owner for renewal quote
                                        qt.OwnerId = opp.OwnerId;
                                    }
                            if(!opp.Opportunity_Partners__r.isEmpty() && qt.Partner_Incentive__c == null){
                                for(Opportunity_Partner__c op:opp.Opportunity_Partners__r){qt.Partner_Incentive__c = op.Partner_Incentive__c;}                                    
                            }//End of IF block of Opportunity_Partners__r 
                            if( qt.SBQQ__partner__c!=null && qt.SBQQ__partner__c!=qt.Bill_to__c && accWithIncentive.containsKey(qt.Bill_to__c)   && (opp.Account.Name.contains('A0') || opp.Is_Federal_Opportunity_Sync__c || opp.Region_Account__c == 'Federal' || opp.Account.Region__c=='SLED' || qt.Partner_Program__c=='Summit - Discount')){                                 
                                if(!accWithIncentive.get(qt.Bill_to__c).isEmpty()){
                                    qt.Distributor_Disc__c  = accWithIncentive.get(qt.Bill_to__c)[0].Distributor__c;
                                }
                            }
                            
                        }//End of IF block of Opportunity Map
                    }//End of FOR Look of Quote
                }
            }
        }
        /*}Catch(Exception e){
system.debug('Exception Occurred:' +e.getStackTraceString());
}*/
    }
}
/*********************************************************************************
** Method Name: updateChecboxesOnQE
**
** Description: This methood updates the checkboxes on Quote Extension.
**
** @Param : 
** @return : void
*********************************************************************************/
public static void updateChecboxesOnQE (Map<Id,SBQQ__Quote__c> newMap){
    if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        Map<Id,Quote_Extension__c> updQuoteExtMap = new Map<Id,Quote_Extension__c>(); 
        Set<Id> creditLineQuotSet = new Set<Id>();
        Set<Id> quoteIdsforLightProduct = new Set<Id>(); 
        Set<Id> quoteIdsforPSProduct = new Set<Id>(); 
        Map<string,string> detailsApprovalTemplate =new Map<string,string>();
        String netVarianceMesssage = '';
        Map<string, List<string>> netVarianceMap = new Map<string, List<string>>();
        
        string detailsApprovalTemplateString = '<table><tbody><tr><td><b>Product Code</b></td><td><b>Quantity</b></td><td><b>Net Variance</b></td><td><b>ACV</b></td></tr>';
        if(newMap.keyset().size() > 0){
            //added below for CR#4299-Rakshitha
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c skuLineExceptionProduct = SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Credit SKU Line - Exception  Product');
            System.debug(skuLineExceptionProduct);
            List<String> skuExceptionList = skuLineExceptionProduct!=null && skuLineExceptionProduct.SKU_Codes__c!=null ?skuLineExceptionProduct.SKU_Codes__c.split(';'):new List<String>();
            double netVariance;
            double acv;
            for(SBQQ__QuoteLine__c quoteLines :[SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.ACV_New__c,Is_Platform_SKU__c,SBQQ__Quantity__c,SBQQ__SubscriptionType__c,Net_Variance__c,SBQQ__ProductCode__c,Line_Status__c,SBQQ__NetTotal__c, ACV_New__c,MRR_New__c,SBQQ__Product__C,SBQQ__Product__r.Products_Type__c,SBQQ__product__r.SKU_Category__c,SBQQ__product__r.Zscaler_Product_Family__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c In :newMap.keyset() order by ACV_New__c desc/* and SBQQ__NetTotal__c<0  and (SBQQ__product__r.SKU_Category__c !='Promo' and SBQQ__product__r.Zscaler_Product_Family__c !='credits')*/]){
                if( quoteLines.SBQQ__NetTotal__c<0 && quoteLines.SBQQ__product__r.SKU_Category__c !='Promo' && quoteLines.SBQQ__product__r.Zscaler_Product_Family__c !='credits'&& (skuExceptionList.isEmpty() ||(!skuExceptionList.isEmpty() && !skuExceptionList.contains(quoteLines.SBQQ__ProductCode__c)))){
                    creditLineQuotSet.add(quoteLines.SBQQ__Quote__c);
                }
                //IBA-6019
                if(quoteLines.SBQQ__Product__r.Products_Type__c != null && quoteLines.SBQQ__Product__r.Products_Type__c.Contains('Light User SKU') && quoteLines.SBQQ__ProductCode__c !=null && quoteLines.Line_Status__c != 'Existing' && quoteLines.Line_Status__c != SB_CONSTANTS.CANCELLED && quoteLines.Line_Status__c != 'Renewed'){
                    quoteIdsforLightProduct.add(quoteLines.SBQQ__Quote__c);
                }
                 //IBA-7071
                if(quoteLines.SBQQ__Product__r.Products_Type__c != null && quoteLines.SBQQ__Product__r.Products_Type__c.Contains('Fed PS SKU') && quoteLines.SBQQ__ProductCode__c !=null &&  quoteLines.Line_Status__c != SB_CONSTANTS.CANCELLED ){
                    quoteIdsforPSProduct.add(quoteLines.SBQQ__Quote__c);
                }
                // IBA 4202
				if(quoteLines.Line_Status__c == 'New' && quoteLines.SBQQ__Quote__r.ACV_New__c > 100000 && quoteLines.Is_Platform_SKU__c  && quoteLines.Net_Variance__c < -20 ){
 				 
   				  if(quoteLines.Net_Variance__c <= -35){
                    if(!netVarianceMap.containskey('35'+quoteLines.SBQQ__Quote__c)){
                       netVarianceMap.put('35'+quoteLines.SBQQ__Quote__c,new List<string>()); 
                    }
                    netVarianceMap.get('35'+quoteLines.SBQQ__Quote__c).add(quoteLines.SBQQ__ProductCode__c);  
                  }
                  else{
                    if(!netVarianceMap.containskey('20'+quoteLines.SBQQ__Quote__c)){
                       netVarianceMap.put('20'+quoteLines.SBQQ__Quote__c,new List<string>()); 
                    }
                    netVarianceMap.get('20'+quoteLines.SBQQ__Quote__c).add(quoteLines.SBQQ__ProductCode__c);  
                  }
                
                }
                
                
                //IBA-6994
                if(quoteLines.SBQQ__ProductCode__c!=null && (quoteLines.Net_Variance__c!=null || quoteLines.ACV_New__c!=null) && quoteLines.SBQQ__SubscriptionType__c=='Renewable'){
                   string temp;
                   netVariance = 0.0;
                   acv = 0.0;
                   if(quoteLines.Net_Variance__c!=null){
                        netVariance = quoteLines.Net_Variance__c.setScale(2);
                    } 
                   if(quoteLines.ACV_New__c!=null){
                        acv = quoteLines.ACV_New__c.setScale(2);
                    }
                    
                   temp =  '<td>'+quoteLines.SBQQ__ProductCode__c + '</td> <td>'+ Integer.valueOf(quoteLines.SBQQ__Quantity__c) + '</td> <td> ' + netVariance+'%' + '</td> <td>'  +'$'+acv.format()+'</td>' ;
                    
                   if(detailsApprovalTemplate.containskey(quoteLines.SBQQ__Quote__c)  && detailsApprovalTemplate.get(quoteLines.SBQQ__Quote__c)!=null){
                       
                   		detailsApprovalTemplate.put(quoteLines.SBQQ__Quote__c,detailsApprovalTemplate.get(quoteLines.SBQQ__Quote__c)+'<tr>'+temp+'</tr>');  
                    }
                   else{
                        detailsApprovalTemplate.put(quoteLines.SBQQ__Quote__c,detailsApprovalTemplateString+'<tr> '+temp+'</tr>');
                     }
                    
                }
                
            }
            
            for(Quote_Extension__c qe:[SELECT Id,Details_on_Approval_Email_Template__c,message_according_to_netVariance__c,SBQQ_Quote__r.ShowLegalTerm__c,SBQQ_Quote__r.Special_Terms__c,SBQQ_Quote__r.Include_Value_Summary_Feature_Additions__c,Professional_Services_Included__c,EDU_Credits_Included__c,light_user_product__c,SBQQ_Quote__r.Partner_Program__c,SBQQ_Quote__c,SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c,Test_check__c,DAS_Package_Included__c,SBQQ_Quote__r.X30_Day_Money_Back__c,SBQQ_Quote__r.Public_Sector_3_yr_contract_Terms__c,SBQQ_Quote__r.Line_Item_SKU_Approval__c,SBQQ_Quote__r.Terms_and_Conditions_Type__c FROM Quote_Extension__c WHERE SBQQ_Quote__c in: newMap.keyset()]){
                qe.Contains_FED_Platform_SKUs__c = false;
                qe.Contains_Deploy_Service_SKU__c = false;
                qe.Main_Condn_to_display_Additional_Terms__c = false;
                qe.Deployment_hrs_90_1_deadline__c = false;
                qe.Deployment_hrs_60_deadline__c = false;
                qe.Deployment_hrs_30_deadline__c = false;
                qe.Deployment_hrs_90_2_deadline__c = false;
                qe.Deployment_hrs_180_deadline__c = false;
                qe.DAS_Package_Included__c = false;
                qe.Buy_Back_Present__c = false;
                qe.One_Time_Credit_Present__c = false;
                qe.Phishing__c = false;
                qe.Machine_learning_based_real_time_Malware__c = false;
                qe.CASB_API__c= false;
                qe.Additional_Term_for_ZCES_PRO_DRR__c = false;
                qe.Additional_Term_for_ZCES_PRO_SVC__c = false;
                qe.Choose_your_own_sandbox_detonation_reg__c = false;
                qe.New_file_types_support_in_sandbox_policy__c = false;
                //qe.Light_Bundle_Family_Cart__c = Null;   //IBA-6019 commented 
                qe.light_user_product__c = quoteIdsforLightProduct.contains(qe.SBQQ_Quote__c) ? TRUE:FALSE;  //IBA-6019
                qe.Professional_Services_Included__c = false;
                qe.EDU_Credits_Included__c = false;
                qe.SpecialTerms_not_Null__c = false;
                qe.SKU_line_credit_Term__c = creditLineQuotSet.contains(qe.SBQQ_Quote__c);
                qe.Main_Condn_to_display_Additional_Terms__c = qe.SKU_line_credit_Term__c;
                qe.Is_PS_SKU__c=quoteIdsforPSProduct.contains(qe.SBQQ_Quote__c) ? TRUE:FALSE;//IBA-7071
                if(netVarianceMap.containskey('20'+qe.SBQQ_Quote__c) && netVarianceMap.get('20'+qe.SBQQ_Quote__c)!=null){
                    netVarianceMesssage = System.Label.NetVariance20;
                    netVarianceMesssage = netVarianceMesssage.replace('{0}', string.join(netVarianceMap.get('20'+qe.SBQQ_Quote__c),','));
                    
                }
                if(netVarianceMap.containskey('35'+qe.SBQQ_Quote__c) && netVarianceMap.get('35'+qe.SBQQ_Quote__c)!=null){
                    netVarianceMesssage = netVarianceMesssage + System.Label.NetVariance_35;
                    netVarianceMesssage = netVarianceMesssage.replace('{0}', string.join(netVarianceMap.get('35'+qe.SBQQ_Quote__c),','));
                        
                }
                qe.message_according_to_netVariance__c = netVarianceMesssage;
                if(detailsApprovalTemplate.containskey(qe.SBQQ_Quote__c) && detailsApprovalTemplate.get(qe.SBQQ_Quote__c)!=null){
                    qe.Details_on_Approval_Email_Template__c = detailsApprovalTemplate.get(qe.SBQQ_Quote__c)+'</tbody></table>';
                }
                if(qe.SBQQ_Quote__r.Include_Value_Summary_Feature_Additions__c==true|| qe.SBQQ_Quote__r.Partner_Program__c== SB_CONSTANTS.RENEWAL){
                        qe.New_file_types_support_in_sandbox_policy__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                if(qe.SBQQ_Quote__r.Special_Terms__c != NULL){
                    qe.SpecialTerms_not_Null__c = true;
                    updQuoteExtMap.put(qe.Id,qe);
                }
                if(qe.SBQQ_Quote__r.Include_Value_Summary_Feature_Additions__c == true|| qe.SBQQ_Quote__r.Partner_Program__c ==SB_CONSTANTS.RENEWAL){
                        qe.Choose_your_own_sandbox_detonation_reg__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                if(qe.SBQQ_Quote__r.Include_Value_Summary_Feature_Additions__c == true|| qe.SBQQ_Quote__r.Partner_Program__c == SB_CONSTANTS.RENEWAL){
                        qe.CASB_API__c= true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                if(qe.SBQQ_Quote__r.Include_Value_Summary_Feature_Additions__c == true|| qe.SBQQ_Quote__r.Partner_Program__c == SB_CONSTANTS.RENEWAL){
                        qe.Machine_learning_based_real_time_Malware__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                if(!(String.isBlank(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c)) && qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c!= NULL && qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c!= ''){
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZPA-ZFED-MODERATE')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZIA-ZFED-MODERATE')){
                        qe.Contains_FED_Platform_SKUs__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-PRO-DZX')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-PRO-DRR')){
                        qe.Additional_Term_for_ZCES_PRO_DRR__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_PRO_SVC)){
                        qe.Professional_Services_Included__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_PRO_SVC)){
                        qe.Additional_Term_for_ZCES_PRO_SVC__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG6')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG0')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-FED1')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-FED2')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-FED3')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ADV)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ENT)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DEP-ENTPLUS')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ESS)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_PRO_HEALTH)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-PRO-OPTENT')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-PRO-OPTADV')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_PRO_SVC)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG1')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG2')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG3')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG4')){
                        qe.Contains_Deploy_Service_SKU__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    //IBA-6019 commented below lines of code
                    /*if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_EDITION_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_LU_OVERAGE_GB) 
                        || qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_BIZ_EDITION_LU) || qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_TFORM_EDITION_LU)
                    ){
                        qe.Light_Bundle_Family_Cart__c = 'ZPA';
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_PRO_EDITION_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_BUS_EDITION_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_TRANS_EDITION_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_ELA_EDITION_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_LU_OVERAGE_GB) 
                        || qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_BIZ_EDITION_LU) || qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_TFORM_EDITION_LU) || qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_UNLTD_EDITION_LU)
                    ){
                        qe.Light_Bundle_Family_Cart__c = 'ZIA';
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if((qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_EDITION_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_LU_OVERAGE_GB)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_BIZ_EDITION_LU) || qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZPA_TFORM_EDITION_LU) ) && (qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_PRO_EDITION_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_BUS_EDITION_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_TRANS_EDITION_LU)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_ELA_EDITION_LU)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_LU_OVERAGE_GB)
                        || qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_BIZ_EDITION_LU) || qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_TFORM_EDITION_LU) || qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(APTS_CONSTANTS.PROD_SKU_ZIA_UNLTD_EDITION_LU))){
                        qe.Light_Bundle_Family_Cart__c = 'ZIA/ZPA';
                        updQuoteExtMap.put(qe.Id,qe);
                    }*/
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-EDU-CREDIT')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-EDU-LABCREDIT')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_PRO_SVC)
                        ||qe.SBQQ_Quote__r.X30_Day_Money_Back__c || qe.SBQQ_Quote__r.Public_Sector_3_yr_contract_Terms__c || qe.DAS_Package_Included__c || qe.SBQQ_Quote__r.Terms_and_Conditions_Type__c == 'CPPO' || qe.SBQQ_Quote__r.ShowLegalTerm__c || creditLineQuotSet.contains(qe.SBQQ_Quote__c)){
                            qe.Main_Condn_to_display_Additional_Terms__c = true;
                            updQuoteExtMap.put(qe.Id,qe);
                        }
                    if(qe.DAS_Package_Included__c && !(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ENT))&& !(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DEP-ENTPLUS'))&&!(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-PRO-OPTESS'))&& !(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-PRO-OPTADV'))&&!(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ESS))&& !(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ADV))&& !(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_PRO_HEALTH))){
                        qe.Deployment_hrs_90_1_deadline__c = true;updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-PRO-OPTESS')){
                        qe.Deployment_hrs_30_deadline__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-PRO-OPTADV')){
                        qe.Deployment_hrs_60_deadline__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ADV)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_PRO_HEALTH	)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-PRO-OPTENT')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ESS)){
                        qe.Deployment_hrs_90_2_deadline__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ENT)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DEP-ENTPLUS')){
                        qe.Deployment_hrs_180_deadline__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG0')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG1')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG2')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG3')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG4')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-DAS-PKG6')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ESS)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ADV)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_DEP_ENT)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZCES_PRO_HEALTH)){
                        qe.DAS_Package_Included__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCR-BuyBack')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('Z-ZPA-BuyBack')){
                        qe.Buy_Back_Present__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-EDU-CREDIT')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZCES-EDU-LABCREDIT')){
                        qe.EDU_Credits_Included__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('Z-Credit')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('CASB-PROMO')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('WFH_PROMO')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZPA-PRO-PROMO')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('Z-CFWZPA-Credit')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('Z-CFWCSB-PROMO')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZLIVE-VIPC')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZLIVE-SPG')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZLIVE-TEAM')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZLIVE-WOMENINTECH')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZLIVE-EARLYBIRD')){
                        qe.One_Time_Credit_Present__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZIA_ELA_BUNDLE)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZSEC-ATP')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZIA_TRANS_BUNDLE)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZIA-ATP')|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZIA_TRANS_EDITION)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZPA_TRANS_EDITION)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZIA_ELA_EDITION)){
                        qe.Phishing__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZIA-SANDBOX')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZIA_TRANS_EDITION)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZPA_TRANS_EDITION)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZIA_ELA_EDITION)){
                        qe.Machine_learning_based_real_time_Malware__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZSEC_WEB_ABA)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZIA_ELA_BUNDLE)|| qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZIA_TRANS_BUNDLE)){
                        qe.Choose_your_own_sandbox_detonation_reg__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains(SB_CONSTANTS.PROD_ZSEC_WEB_ABA)||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZIA-ELA-BUNDLE')||qe.SBQQ_Quote__r.Line_Item_SKU_Approval__c.Contains('ZIA-TRANS-BUNDLE')){
                        qe.New_file_types_support_in_sandbox_policy__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                }
                if(!(String.isBlank(qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c)) && qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c!= NULL && qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c!= ''){
                    if(qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains('ZSEC-ATP')||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_ELA_BUNDLE)||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_TRANS_BUNDLE)||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains('ZIA-ATP')||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_TRANS_EDITION)||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZPA_TRANS_EDITION)||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_ELA_EDITION)){
                        qe.Phishing__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_TRANS_EDITION)||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZPA_TRANS_EDITION)||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_ELA_EDITION)){
                        qe.Machine_learning_based_real_time_Malware__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZSEC_WEB_ABA)||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_ELA_BUNDLE)|| qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_TRANS_BUNDLE)){
                        qe.Choose_your_own_sandbox_detonation_reg__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                    if(qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZSEC_WEB_ABA)||qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_ELA_BUNDLE)|| qe.SBQQ_Quote__r.SBQQ__Account__r.Asset_SKU_Codes__c.Contains(SB_CONSTANTS.PROD_ZIA_TRANS_BUNDLE)){
                        qe.New_file_types_support_in_sandbox_policy__c = true;
                        updQuoteExtMap.put(qe.Id,qe);
                    }
                }
            }
            
            
        }
        /* if(updQuoteExtList.size() > 0){
update updQuoteExtList;
}*/
        if(!updQuoteExtMap.isEmpty()){
            Database.SaveResult[] saveResultList = Database.update(updQuoteExtMap.values(), false);
        }
    }
}
/*********************************************************************************
** Method Name: updateQuoteSubsTerm
**
** Description: Thid methood updates the subscription term value on Quote level.
**
** @Param : 
** @return : List<SBQQ__Quote__c>
*********************************************************************************
public static void updateQuoteSubsTerm (List<SBQQ__Quote__c> lstQuote, Map<Id, SBQQ__Quote__c> oldMap){
if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
try{
for(SBQQ__Quote__c qte : lstQuote){
if(qte.SBQQ__StartDate__c != NULL && qte.SBQQ__StartDate__c != oldMap.get(qte.id).SBQQ__StartDate__c
|| qte.SBQQ__EndDate__c != NULL && qte.SBQQ__EndDate__c  != oldMap.get(qte.id).SBQQ__EndDate__c){
qte.SBQQ__SubscriptionTerm__c = (Integer)Math.roundToLong(((qte.SBQQ__StartDate__c.daysBetween(qte.SBQQ__EndDate__c))/30.25));
//Decimal liSellingTerm_02 = ((Decimal)((lstProposal[0].Apttus_Proposal__ExpectedStartDate__c.daysBetween(lstProposal[0].Apttus_Proposal__ExpectedEndDate__c)+1)/365)*12).setScale(1);
}
}
}Catch(Exception e){
system.debug('Exception Occurred:' +e.getStackTraceString());
}
}
}
*/
/*********************************************************************************
** Method Name: assignProductCodes
**
** Description: Thid methood is used to update product codes on Quote record
**
** @Param : List<SBQQ__Quote__c>
** @return : void
*********************************************************************************/
public static void assignProductCodes(List<SBQQ__Quote__c> newList){
    if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        Set<Id> qlinesId = new set<Id>();
        List<String> productCodes = new List<String>();
        Map<Id,Set<String>> quoteproductCodes = new Map<Id,Set<String>>();
        Map<Id,Boolean> preSKUMap = new Map<Id,Boolean>();
        Map<Id,Boolean> zpaMap = new Map<Id,Boolean>();
        Map<Id,Boolean> showLegalTerm = new Map<Id,Boolean>();
        Map<string, string> pendingFullSkusForApproval = new Map<string, string>();
        Map<string, string> InternalRestrictedPreSKUForApproval = new Map<string, string>();
        Map<string, string> approvedFullSkus = new Map<string, string>();
        List<string> statuslst = new List<string>();
        Map<Id,Set<String>> quoteToPreSkuMap = new Map<Id,Set<String>>();
        Map<String, Map<String, string>> pendingFullSkuTemMap = new  Map<String,Map<String,string>>(); 
        Map<String, Map<String, string>> InternalRestrictedPreSKUMap = new  Map<String,Map<String,string>>(); 
        String lineSKUs = '';
        Decimal netVar;
        
        for(SBQQ__Quote__c objQuote : newList){
            qlinesId.add(objQuote.Id); 
            preSKUMap.put(objQuote.id,false);
            zpaMap.put(objQuote.id,false);
            showLegalTerm.put(objQuote.id,false);
        }
		CPQ_Pricing_Parameters__mdt paramList = CPQ_Pricing_Parameters__mdt.getInstance('Line_Status');//IBA-5220 Changes Start
            if(paramList.Line_Status__c != null && paramList.DeveloperName == 'Line_Status'){
                statuslst = paramList.Line_Status__c.split(';');
            }
            //IBA-5220 Changes End
            
        
            for(SBQQ__QuoteLine__c qlines: [SELECT Id,Support_Type_Product_Code__c,Support_Type__c,SBQQ__Existing__c,Legal_terms__c,SBQQ__Quote__c,SBQQ__Product__r.ProductCode,SBQQ__Product__r.SKU_Type__c,SBQQ__ProductCode__c,Line_Status__c,Eligible_Deep_Discounting_Approval__c,SBQQ__Product__r.Products_Type__c,SBQQ__Quote__r.Quote_Extension__c,SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c,Net_Variance__c,Recommended_Total1__c,SBQQ__Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :qlinesId]){
                if(qlines.SBQQ__ProductCode__c !=null && qlines.Line_Status__c != 'Existing' && qlines.Line_Status__c != SB_CONSTANTS.CANCELLED && qlines.Line_Status__c != 'Renewed'){
                if(!quoteproductCodes.containsKey(qlines.SBQQ__Quote__c)){
                    quoteproductCodes.put(qlines.SBQQ__Quote__c,new Set<String>());
                }
                quoteproductCodes.get(qlines.SBQQ__Quote__c).add(qlines.SBQQ__ProductCode__c);
            }
			 if(qlines.SBQQ__ProductCode__c !=null && statuslst.contains(qlines.Line_Status__c) && qlines.SBQQ__Product__r.Products_Type__c!=null && qlines.SBQQ__Product__r.Products_Type__c.contains('Internal & Pre SKU')  ){//IBA-5220 Changes Start
                    if(!quoteToPreSkuMap.containsKey(qlines.SBQQ__Quote__c)){
                        quoteToPreSkuMap.put(qlines.SBQQ__Quote__c,new Set<String>());
                    }
                    quoteToPreSkuMap.get(qlines.SBQQ__Quote__c).add(qlines.SBQQ__ProductCode__c);
                }//IBA-5220 Changes End
            if(qlines.SBQQ__Product__r.SKU_Type__c != null && qlines.SBQQ__Product__r.SKU_Type__c.contains('PRE')&& qlines.SBQQ__Existing__c != true && qlines.Line_Status__c != SB_CONSTANTS.CANCELLED){
                preSKUMap.put(qlines.SBQQ__Quote__c,true);
            }
            if(qlines.SBQQ__Product__r.SKU_Type__c != null && qlines.SBQQ__Product__r.ProductCode!=null && qlines.SBQQ__Product__r.ProductCode.contains(SB_CONSTANTS.PROD_FAMILY_ZPA)){
                zpaMap.put(qlines.SBQQ__Quote__c,true);
            }
            if(!(String.isBlank(qlines.Legal_terms__c)) && qlines.Legal_terms__c!= NULL && qlines.Legal_terms__c!= ''){
                showLegalTerm.put(qlines.SBQQ__Quote__c,true);
            }
			// Adding FullSkus to PendingApproval
                if(qlines.Eligible_Deep_Discounting_Approval__c =='Full SKU deep discounting approval' &&  qlines.SBQQ__Quote__r.Quote_Extension__c!=null){ 
                    // 1st Insert case
                    netVar = qlines.Net_Variance__c!=null?qlines.Net_Variance__c.setScale(2):0;//IBA-7292
                    if(qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c == null || qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c == '{}'
                       || !qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c.CONTAINS(qlines.SBQQ__ProductCode__c)){ //new line
                           pendingFullSkusForApproval.put(qlines.SBQQ__ProductCode__c,netVar+';'+qlines.Recommended_Total1__c);
                       }
                    else if(qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c.CONTAINS(qlines.SBQQ__ProductCode__c)){
                        approvedFullSkus = (Map<string,string>)JSON.deserialize(qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c, Map<string,string>.class);
                        List<string> values = approvedFullSkus.get(qlines.SBQQ__ProductCode__c).split(';');
                        if(netVar < decimal.valueOf(values[0]) || qlines.Recommended_Total1__c < decimal.valueOf(values[1])){
                            pendingFullSkusForApproval.put(qlines.SBQQ__ProductCode__c,netVar+';'+qlines.Recommended_Total1__c);
                        }
                    }
                    if(!pendingFullSkuTemMap.containsKey(qlines.SBQQ__Quote__c)){
                        pendingFullSkuTemMap.put(qlines.SBQQ__Quote__c,new Map<String,string>());
                    }
                    if(!pendingFullSkusForApproval.isEmpty()){
                        pendingFullSkuTemMap.get(qlines.SBQQ__Quote__c).putall(pendingFullSkusForApproval);
                    }
                }
                else if(qlines.Eligible_Deep_Discounting_Approval__c =='Internal/Restricted/Pre-SKU Deep discounting approval' &&  qlines.SBQQ__Quote__r.Quote_Extension__c!=null) {
                    netVar = qlines.Net_Variance__c!=null?qlines.Net_Variance__c.setScale(2):0;
                    system.debug(netVar);
                    system.debug(qlines.SBQQ__ProductCode__c);
                    if(qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c == null || qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c == '{}'
                       || !qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c.CONTAINS(qlines.SBQQ__ProductCode__c)){ 
                           InternalRestrictedPreSKUForApproval.put(qlines.SBQQ__ProductCode__c,netVar+'');
                           system.debug(qlines.SBQQ__ProductCode__c);
                        }
                        else if(qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c.CONTAINS(qlines.SBQQ__ProductCode__c)){
                        approvedFullSkus = (Map<string,string>)JSON.deserialize(qlines.SBQQ__Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c, Map<string,string>.class);
                        List<string> values = approvedFullSkus.get(qlines.SBQQ__ProductCode__c).split(';');
                        if(netVar < decimal.valueOf(values[0])){
                            InternalRestrictedPreSKUForApproval.put(qlines.SBQQ__ProductCode__c,netVar+'');
                        }
                    }
                }
                system.debug(InternalRestrictedPreSKUMap);
                	if(!InternalRestrictedPreSKUMap.containsKey(qlines.SBQQ__Quote__c)){
                        InternalRestrictedPreSKUMap.put(qlines.SBQQ__Quote__c,new Map<String,string>());
                    }
                    if(!InternalRestrictedPreSKUForApproval.isEmpty()){
                        InternalRestrictedPreSKUMap.get(qlines.SBQQ__Quote__c).putall(InternalRestrictedPreSKUForApproval);
                    }
                system.debug(InternalRestrictedPreSKUMap);
        }
        
        
        // Update quote record with value of lineSKUs..
        for(SBQQ__Quote__c objQuote : newList){
            system.debug(InternalRestrictedPreSKUMap);
            if(InternalRestrictedPreSKUMap.containsKey(objQuote.Id) && !InternalRestrictedPreSKUMap.get(objQuote.Id).isEmpty()){
                objQuote.Pending_Deep_Discounting_Approval__c = JSON.serialize(InternalRestrictedPreSKUMap.get(objQuote.Id));
            } else{ 
                objQuote.Pending_Deep_Discounting_Approval__c = null; 
            }
            system.debug( objQuote.Pending_Deep_Discounting_Approval__c );
                if(pendingFullSkuTemMap.containsKey(objQuote.Id) && !pendingFullSkuTemMap.get(objQuote.Id).isEmpty()){
                    objQuote.Pending_FullSku_approval__c = JSON.serialize(pendingFullSkuTemMap.get(objQuote.Id));
                }else{
                    objQuote.Pending_FullSku_approval__c = null;
                }
      
			
            if(quoteproductCodes.containsKey(objQuote.Id)){
                productCodes.addAll(quoteproductCodes.get(objQuote.Id));
                objQuote.Line_Item_SKU_Approval__c = test.isRunningTest()?objQuote.Line_Item_SKU_Approval__c+lineSKUs: !productCodes.isEmpty()? String.join(productCodes,','):'';
                productCodes.clear();
            }else if(objQuote.Line_Item_SKU_Approval__c !=null){
                objQuote.Line_Item_SKU_Approval__c = null;
            }
			//IBA-5220 Changes Start
                if(quoteToPreSkuMap.containsKey(objQuote.Id)){
                    productCodes.addAll(quoteToPreSkuMap.get(objQuote.Id));
                    objQuote.Line_Item_Product_Use_Case_Products__c =!productCodes.isEmpty()? String.join(productCodes,','):'';
                    productCodes.clear();
                }else if(objQuote.Line_Item_Product_Use_Case_Products__c !=null){
                    objQuote.Line_Item_Product_Use_Case_Products__c = null;
                } //IBA-5220 Changes End
            
                objQuote.Contains_PRE_SKU__c = preSKUMap.get(objQuote.Id);
                objQuote.Has_ZPA_Products__c = zpaMap.get(objQuote.Id);
                objQuote.ShowLegalTerm__c = showLegalTerm.get(objQuote.Id);
        }
        
        
        
    }
}


/*********************************************************************************
** Method Name: setApprovedSubscriptionTerm
**
** Description: Thid methood is used to update Approved Subscription Term on Quote
**
** @Param : List<SBQQ__Quote__c>
** @return : void
*********************************************************************************/
public static void setApprovedSubscriptionTerm(List<SBQQ__Quote__c> newList, Map<Id, SBQQ__Quote__c> oldMap){
    if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        for(SBQQ__Quote__c objQuote : newList){
            if(objQuote.ApprovalStatus__c == 'Approved' && oldMap.get(objQuote.Id).ApprovalStatus__c != 'Approved' 
                && (objQuote.Record_Type_Name__c == APTS_CONSTANTS.P_RT_NBUSINESS || objQuote.Record_Type_Name__c == APTS_CONSTANTS.P_RT_RENEWAL) && objQuote.Enterprise_Account_Approval__c){
                    objQuote.Approved_Subscription_Term__c = oldMap.get(objQuote.Id).SBQQ__SubscriptionTerm__c;
                } 
        }
    }
}

/* public static void setYearWiseSplit(List<SBQQ__Quote__c> newList,Map<Id,SBQQ__Quote__c> oldQuoteMap){
    //if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        set<id> accIds = new set<Id>();
    set<id> finalAccIds = new set<id>();
    for(SBQQ__Quote__c objQuote : newList){
        accIds.add(objQuote.SBQQ__Partner__c);
    }
    if(!accIds.isEmpty()){
        for(Account ac : [Select id,name from Account where (name like '%cdw%' or name like '%verizon%') and Id IN :accIds]){
                finalAccIds.add(ac.Id);
        }
    }
    for(SBQQ__Quote__c objQuote : newList){
        //modified for CR# 3545
        if(oldQuoteMap==null && objQuote.SBQQ__BillingFrequency__c !='Annual'){
        objQuote.Generate_Year_Wise_Split__c = false;
    }else if(oldQuoteMap==null && (objQuote.SBQQ__SubscriptionTerm__c > 12 || finalAccIds.contains(objQuote.SBQQ__Partner__c))){
        objQuote.Generate_Year_Wise_Split__c = true;
    }else if(oldQuoteMap !=null && ((oldQuoteMap.get(objQuote.Id).SBQQ__SubscriptionTerm__c < 12 && objQuote.SBQQ__SubscriptionTerm__c > 12)|| (!finalAccIds.contains(oldQuoteMap.get(objQuote.Id).SBQQ__Partner__c) && finalAccIds.contains(objQuote.SBQQ__Partner__c)))){
        objQuote.Generate_Year_Wise_Split__c = true;
    }else if(oldQuoteMap !=null && oldQuoteMap.get(objQuote.Id).SBQQ__SubscriptionTerm__c > 12 && objQuote.SBQQ__SubscriptionTerm__c < 12){
        objQuote.Generate_Year_Wise_Split__c = false;
    }else if(oldQuoteMap !=null && oldQuoteMap.get(objQuote.Id).SBQQ__BillingFrequency__c!=objQuote.SBQQ__BillingFrequency__c){
        if(objQuote.SBQQ__BillingFrequency__c !='Annual'){
            objQuote.Generate_Year_Wise_Split__c = false;}else{objQuote.Generate_Year_Wise_Split__c = true; }
    }
        system.debug('10th block'+objQuote.generate_year_wise_split__c);
    }
} */


public static void resetApprovedSubscriptionTerm(List<SBQQ__Quote__c> newList){
    if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        for(SBQQ__Quote__c objQuote : newList){
            objQuote.Approved_Subscription_Term__c = 0;
        }
    }
}
public static void setSubscriptionProductCodes (List<SBQQ__Quote__c> lstQuote){
    if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        //try{
        
        Set<Id> contractIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        for(SBQQ__Quote__c objQuote : lstQuote){
            if(objQuote.SBQQ__MasterContract__c !=null && objQuote.Subscription_ProductCodes__c ==null){
                contractIds.add(objQuote.SBQQ__MasterContract__c);
            }
            if(objQuote.SBQQ__Account__c !=null && (objQuote.SBQQ__Type__c==SB_CONSTANTS.RENEWAL || objQuote.Opportunity_Record_Type__c.contains('Upsell') || objQuote.Opportunity_Record_Type__c.contains(SB_CONSTANTS.RENEWAL))    && objQuote.Subscription_ProductCodes__c ==null){
                accIds.add(objQuote.SBQQ__Account__c);
            }
            
        }
        if(!contractIds.isEmpty()){
            
            Map<Id,Contract> IdVsContract = new Map<Id,Contract>([SELECT id,StartDate,EndDate,Price_List__c,(SELECT id,SBQQ__ProductName__c,Product_Code__c,SBQQ__Product__r.Product_Family__c,Last_Ramp_Quantity__c,SBQQ__Quantity__c FROM SBQQ__Subscriptions__r WHERE SBQQ__TerminatedDate__c =null) FROM Contract WHERE Id IN :contractIds]);
            for(SBQQ__Quote__c objQuote : lstQuote){
                if(objQuote.SBQQ__MasterContract__c !=null && IdVsContract.containsKey(objQuote.SBQQ__MasterContract__c) && objQuote.Subscription_ProductCodes__c ==null){
                    //objQuote.Price_List__c = IdVsContract.get(objQuote.SBQQ__MasterContract__c).Price_List__c;
                    Double platformQTY = 0;
                    if(!IdVsContract.get(objQuote.SBQQ__MasterContract__c).SBQQ__Subscriptions__r.isEmpty()){
                        String prodCode = '';
                        for(SBQQ__Subscription__c sub : IdVsContract.get(objQuote.SBQQ__MasterContract__c).SBQQ__Subscriptions__r){
                            String str = sub.Product_Code__c!=null ? sub.Product_Code__c:sub.SBQQ__ProductName__c;
                            prodCode += str + ',';
                            
                            if(sub.SBQQ__Product__r.Product_Family__c=='Bundle Platforms'){
                                Double QTY = sub.Last_Ramp_Quantity__c!=null?sub.Last_Ramp_Quantity__c:sub.SBQQ__Quantity__c;
                                platformQTY = platformQTY +QTY;
                            }
                        }
                        
                        objQuote.Subscription_ProductCodes__c =prodCode;
                    }
                    
                    // objQuote.Subscription_ProductCodes__c = (objQuote.SBQQ__Type__c=='Renewal' ||objQuote.Opportunity_Record_Type__c.contains('Upsell') || objQuote.Opportunity_Record_Type__c.contains('Renewal') )?prodCode:objQuote.Subscription_ProductCodes__c;
                    objQuote.Existing_ZIA_Customer__c = (objQuote.Subscription_ProductCodes__c!=null &&  objQuote.Subscription_ProductCodes__c.contains('ZIA'))?true:false;
                    objQuote.Existing_ZPA_Customer__c = (objQuote.Subscription_ProductCodes__c!=null &&  objQuote.Subscription_ProductCodes__c.contains('ZPA'))?true:false;
                    objQuote.Existing_ZWS_Customer__c = (objQuote.Subscription_ProductCodes__c!=null &&  objQuote.Subscription_ProductCodes__c.contains('ZWS'))?true:false;
                    objQuote.No_of_Platform_Seats__c = platformQTY;
                }
            }
            
        }
        if(!accIds.isEmpty()){
            Map<Id,Account>  accMap =new Map<Id,Account>([SELECT id,(SELECT id,SBQQ__ProductName__c,Product_Code__c,SBQQ__Quantity__c,Last_Ramp_Quantity__c,SBQQ__Product__r.Product_Family__c FROM SBQQ__Subscriptions__r WHERE SBQQ__TerminatedDate__c =null and SBQQ__EndDate__c>=:system.today()) FROM Account WHERE Id IN :accIds]);
            for(SBQQ__Quote__c objQuote : lstQuote){
                if(objQuote.SBQQ__Account__c !=null && objQuote.Subscription_ProductCodes__c ==null && accmap.containsKey(objQuote.SBQQ__Account__c)){
                    if(!accMap.get(objQuote.SBQQ__Account__c).SBQQ__Subscriptions__r.isEmpty()){
                        String prodCode = '';
                        Double platformQTY = 0;
                        for(SBQQ__Subscription__c sub : accMap.get(objQuote.SBQQ__Account__c).SBQQ__Subscriptions__r){
                            String str = sub.Product_Code__c!=null ? sub.Product_Code__c:sub.SBQQ__ProductName__c;
                            prodCode += str + ',';
                            if(sub.SBQQ__Product__r.Product_Family__c=='Bundle Platforms'){
                                Double QTY = sub.Last_Ramp_Quantity__c!=null?sub.Last_Ramp_Quantity__c:sub.SBQQ__Quantity__c;
                                platformQTY = platformQTY +QTY;
                            }
                        }
                        objQuote.Subscription_ProductCodes__c = (objQuote.SBQQ__Type__c==SB_CONSTANTS.RENEWAL ||objQuote.Opportunity_Record_Type__c.contains('Upsell') || objQuote.Opportunity_Record_Type__c.contains(SB_CONSTANTS.RENEWAL) )?prodCode:objQuote.Subscription_ProductCodes__c;
                        objQuote.Existing_ZIA_Customer__c = (objQuote.Subscription_ProductCodes__c!=null &&  objQuote.Subscription_ProductCodes__c.contains('ZIA'))?true:false;
                        objQuote.Existing_ZPA_Customer__c = (objQuote.Subscription_ProductCodes__c!=null &&  objQuote.Subscription_ProductCodes__c.contains('ZPA'))?true:false;
                        objQuote.Existing_ZWS_Customer__c = (objQuote.Subscription_ProductCodes__c!=null &&  objQuote.Subscription_ProductCodes__c.contains('ZWS'))?true:false;
                        objQuote.No_of_Platform_Seats__c = platformQTY;
                    }
                }   
            }
            
        }
        /*}catch(Exception e){
system.debug('Exception Occurred:' +e.getStackTraceString());
}*/
    }
}


public static void setPrimaryQuote(List<SBQQ__Quote__c> newList, Map<Id, SBQQ__Quote__c> oldMap,Boolean isInsert){
    if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        set<Id> oppId = new set<Id>(); 
        String currUserName = userinfo.getName();
        set<Id> oppWithoutPrimQuoteId = new set<Id>(); 
        set<Opportunity_Partner__c> oppPartnerToUpdate = new set<Opportunity_Partner__c>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        map<Id,SBQQ__Quote__c> oppVsQuoteMap = new map<Id,SBQQ__Quote__c>();
        //map<Id,SBQQ__Quote__c> oppVsNonPrimQuoteMap = new map<Id,SBQQ__Quote__c>();
        system.debug('in setPrimaryQuote..');
        
        for(SBQQ__Quote__c objQuote : newList){
            
            if((isInsert && objQuote.SBQQ__Primary__c == true) ||
                (!isInsert && objQuote.SBQQ__Primary__c == true && oldMap.get(objQuote.Id).SBQQ__Primary__c != true))
            {
                if(!TriggerUtility.isMakePrimaryExecuted()){
                    TriggerUtility.setMakePrimary();
                }
            }
            system.debug('Contract..'+objQuote.SBQQ__MasterContract__c);
            system.debug('isInsert..'+isInsert);
            system.debug('objQuote.SBQQ__Primary__c..'+objQuote.SBQQ__Primary__c);
            /* if(objQuote.SBQQ__MasterContract__c == Null && (objQuote.Opportunity_Record_Type__c != 'Renewal Opportunity' || (objQuote.Opportunity_Record_Type__c == 'Renewal Opportunity' && (objQuote.Auto_Generated_Quote__c == FALSE || (objQuote.Auto_Generated_Quote__c == TRUE && objQuote.Is_System_Admin__c == FALSE))))){ */
            if(objQuote.Opportunity_Record_Type__c != SB_CONSTANTS.OPP_RECORD_TYPE || (objQuote.Opportunity_Record_Type__c == SB_CONSTANTS.OPP_RECORD_TYPE && (objQuote.Auto_Generated_Quote__c == FALSE || (objQuote.Auto_Generated_Quote__c == TRUE && objQuote.Is_System_Admin__c == FALSE)))){
                if((isInsert && objQuote.SBQQ__Primary__c == true) || (!isInsert && objQuote.SBQQ__Primary__c == true && oldMap.get(objQuote.Id).SBQQ__Primary__c != true)){
                    oppId.add(objQuote.SBQQ__Opportunity2__c);
                    oppVsQuoteMap.put(objQuote.SBQQ__Opportunity2__c,objQuote);
                }
                //commented below code as it was setting parter to blank in case of upsell
                else if(!isInsert && objQuote.SBQQ__Primary__c == false && oldMap.get(objQuote.Id).SBQQ__Primary__c == true && (!currUserName.equalsIgnoreCase(System.Label.CPQ_User))){
                    system.debug('Contract1..'+objQuote.SBQQ__MasterContract__c);
                    //oppWithoutPrimQuoteId.add(objQuote.SBQQ__Opportunity2__c);oppVsQuoteMap.put(objQuote.SBQQ__Opportunity2__c,objQuote);
                }
            }
                
        }
        system.debug('oppId..'+oppId);
        system.debug('oppVsQuoteMap..'+oppVsQuoteMap);
        system.debug('oppWithoutPrimQuoteId..'+oppWithoutPrimQuoteId);
        
        if(!oppId.isEmpty()){
            for(Opportunity_Partner__c opPartner : [Select Id,Partner_Type__c,Is_Primary__c,Opportunity__c,Account__c,Partner_Program__c,Partner_Incentive__c from Opportunity_Partner__c Where Partner_Type__c IN ('Reseller','Distributor') AND Opportunity__c IN :oppId]){
                if(!oppVsQuoteMap.isEmpty()){
                    system.debug('opPartner..'+opPartner);
                    if(oppVsQuoteMap.containsKey(opPartner.Opportunity__c) && opPartner.Is_Primary__c == true){
                        if(opPartner.Partner_Type__c == 'Reseller' && opPartner.Account__c != oppVsQuoteMap.get(opPartner.Opportunity__c).SBQQ__Partner__c){
                            opPartner.Is_Primary__c = false;oppPartnerToUpdate.add(opPartner);
                        }else if(opPartner.Partner_Type__c == SB_CONSTANTS.PARTNER_TYPE_DISTRIBUTOR && opPartner.Account__c != oppVsQuoteMap.get(opPartner.Opportunity__c).Bill_to__c){
                            opPartner.Is_Primary__c = false;oppPartnerToUpdate.add(opPartner);
                        }
                    }else if(oppVsQuoteMap.containsKey(opPartner.Opportunity__c) && opPartner.Is_Primary__c != true ){
                        if(opPartner.Partner_Type__c == 'Reseller' && opPartner.Account__c == oppVsQuoteMap.get(opPartner.Opportunity__c).SBQQ__Partner__c && opPartner.Partner_Program__c == oppVsQuoteMap.get(opPartner.Opportunity__c).Partner_Program__c && opPartner.Partner_Incentive__c== oppVsQuoteMap.get(opPartner.Opportunity__c).Partner_Incentive__c){
                            opPartner.Is_Primary__c = true;
                            oppPartnerToUpdate.add(opPartner);
                        }else if(opPartner.Partner_Type__c == SB_CONSTANTS.PARTNER_TYPE_DISTRIBUTOR && opPartner.Account__c == oppVsQuoteMap.get(opPartner.Opportunity__c).Bill_to__c){
                            opPartner.Is_Primary__c = true;oppPartnerToUpdate.add(opPartner);
                        }
                    }
                }
            }
            system.debug('oppPartnerToUpdate...'+oppPartnerToUpdate);
        }
        if(!oppWithoutPrimQuoteId.isEmpty()){
            for(Opportunity_Partner__c opPartner : [Select Id,Partner_Type__c,Is_Primary__c,Opportunity__c,Account__c,Partner_Program__c,Partner_Incentive__c from Opportunity_Partner__c Where Partner_Type__c IN ('Reseller','Distributor') AND Opportunity__c IN :oppWithoutPrimQuoteId]){
                if(oppVsQuoteMap.containsKey(opPartner.Opportunity__c) && opPartner.Is_Primary__c == true){
                    if(opPartner.Partner_Type__c == 'Reseller' && opPartner.Account__c == oppVsQuoteMap.get(opPartner.Opportunity__c).SBQQ__Partner__c){
                        opPartner.Is_Primary__c = false;
                        oppPartnerToUpdate.add(opPartner);
                    }else if(opPartner.Partner_Type__c == SB_CONSTANTS.PARTNER_TYPE_DISTRIBUTOR && opPartner.Account__c == oppVsQuoteMap.get(opPartner.Opportunity__c).Bill_to__c){
                        opPartner.Is_Primary__c = false;
                        oppPartnerToUpdate.add(opPartner);
                    }
                }
            }
        }

        if(!oppId.isEmpty()){
            for(Opportunity opp : [Select Id,SBQQ__PrimaryQuote__c,Primary_Partner_Program__c from Opportunity Where Id IN :oppId]){
                opp.SBQQ__PrimaryQuote__c = oppVsQuoteMap.get(opp.id).Id;
                opp.Primary_Partner_Program__c = oppVsQuoteMap.get(opp.id).Partner_Program__c;
                opp.Primary_Reseller_Partner__c = oppVsQuoteMap.get(opp.id).SBQQ__Partner__c;
                //added as a part of CR# 4616
                opp.Cloud_Type__c = oppVsQuoteMap.get(opp.id).Cloud_Type__c;
                oppToUpdate.add(opp);
            }
        }if(!oppWithoutPrimQuoteId.isEmpty()){
            for(Opportunity opp : [Select Id,SBQQ__PrimaryQuote__c,Primary_Partner_Program__c from Opportunity Where Id IN :oppWithoutPrimQuoteId]){
                opp.SBQQ__PrimaryQuote__c = null;opp.Primary_Partner_Program__c = '';
                opp.Primary_Reseller_Partner__c = null;
                //added as a part of CR# 4616
                opp.Cloud_Type__c = null;
                oppToUpdate.add(opp);
            }
        }
        
        system.debug('oppToUpdate...'+oppToUpdate);
        if(!oppToUpdate.isEmpty()){
            update oppToUpdate;
        }if(!oppPartnerToUpdate.isEmpty()){
            List<Opportunity_Partner__c> oppPartnerListToUpdate = new List<Opportunity_Partner__c>(oppPartnerToUpdate);
            update oppPartnerListToUpdate;
        }
    }
}
 
//Method to validate auto psCredit attach   
 public static void psCreditValidation(List<SBQQ__Quote__c> newQuoteList){
    Set<Id> oppIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();

    for (SBQQ__Quote__c quote : newQuoteList){
        if(quote.SBQQ__Opportunity2__c!=null && quote.SBQQ__Partner__c!=null){
            oppIds.add(quote.SBQQ__Opportunity2__c);
            accountIds.add(quote.SBQQ__Partner__c);
        }
    }

    Map<Id, Opportunity> opportunityMap= new Map<Id, Opportunity>([select SBQQ__PrimaryQuote__r.SBQQ__Partner__c,Deal_Reg_Teaming_Reseller__r.Delivery_Intent__c,Deal_Reg_Partner_Teaming_Reseller__c,Deal_Reg__r.Delivery_Intent__c,Deal_Reg_Margin__c,SBQQ__PrimaryQuote__r.SBQQ__Account__r.Id,SBQQ__PrimaryQuote__r.SBQQ__Account__r.Service_Authorizations__c from  Opportunity   where Id In :oppIds]);
    Map<Id, Account> accountMap= new Map<Id, Account>([select Ultimate_Parent_Account__c,Service_Authorizations__c  from Account where Id IN : accountIds]);
    List<string> mssp_PartnerList = system.label.mssp_Partner.split(';');

    for (SBQQ__Quote__c quote : newQuoteList){
    if(opportunityMap.containsKey(quote.SBQQ__Opportunity2__c)){
        
    Opportunity opportunity = opportunityMap.get(quote.SBQQ__Opportunity2__c);
    Account account = accountMap.get(quote.SBQQ__Partner__c);
    
    String psCreditExcludeField = 'false';
    Boolean mssp_Partner = false;
    Boolean intent_of_delivery = false;
    Boolean account_Service_authorizations = false;

    if(mssp_PartnerList.contains(quote.SBQQ__Partner__c) || mssp_PartnerList.contains(account.Ultimate_Parent_Account__c)){
     mssp_Partner = true;
    }
    if(quote.SBQQ__Partner__c== opportunity.Deal_Reg_Margin__c && opportunity.Deal_Reg__r.Delivery_Intent__c== 'Interested'){
            intent_of_delivery = true;
    }
    if(quote.SBQQ__Partner__c==opportunity.Deal_Reg_Partner_Teaming_Reseller__c && opportunity.Deal_Reg_Teaming_Reseller__r.Delivery_Intent__c=='Interested'){
        intent_of_delivery = true;   
    }

    if(account.Service_Authorizations__c!=null){
     if(account.Service_Authorizations__c.contains('Delivery Services Authorized')){
        account_Service_authorizations = true;
     }
    }
    if(mssp_Partner){
    psCreditExcludeField = 'true';
    }
    if(!mssp_Partner){
        if(intent_of_delivery & account_Service_authorizations){
            psCreditExcludeField = 'true';
        }
    }
    quote.PSCreditExclude__c = psCreditExcludeField;

    }
   }

 }
 

//Method to set amendment fields during Amendment
public static void setAmendQuoteFields(List<SBQQ__Quote__c> listNewQLs){
    if(!TriggerUtility.skipAmendmentRenewalLogic){
        Set<Id> setMasterContract = new Set<Id>();
        Set<Id> setOppty = new Set<Id>();
        for(SBQQ__Quote__C objQuote : listNewQLs){
            system.debug('objQuote..'+objQuote);
            if(objQuote.SBQQ__MasterContract__C!=null && objQuote.Opportunity_Record_Type__c != SB_CONSTANTS.OPP_RECORD_TYPE){
                system.debug('amend..'+objQuote.SBQQ__MasterContract__C);
                setMasterContract.add(objQuote.SBQQ__MasterContract__C);
                if(objQuote.SBQQ__opportunity2__c!=null){
                    system.debug('upsell..'+objQuote.SBQQ__opportunity2__c);
                    setOppty.add(objQuote.SBQQ__opportunity2__c);
                }
            }else if (objQuote.Opportunity_Record_Type__c == SB_CONSTANTS.OPP_RECORD_TYPE){
                setOppty.add(objQuote.SBQQ__opportunity2__c);
            }
        }
        if(!setOppty.isEmpty()){
            //Map<Id,Contract> mapIdToContract = new Map<Id,Contract>([SELECT Id FROM Contract WHERE Id IN: setMasterContract]);
            Map<Id,Opportunity> mapIdToOpportunity = new Map<Id,Opportunity>([SELECT ID,AccountId,Name,OwnerId,Primary_Reseller_Partner__c,Opp_Price_List__c,SBQQ__AmendedContract__c,SBQQ__AmendedContract__r.Partner__c,CloseDate,SBQQ__AmendedContract__r.Billing_Frequency__c,SBQQ__AmendedContract__r.Price_List__c,SBQQ__AmendedContract__r.Partner_Program__c,SBQQ__RenewedContract__c,SBQQ__RenewedContract__r.Bill_to__c,SBQQ__RenewedContract__r.SBQQ__RenewalTerm__c,SBQQ__RenewedContract__r.Cloud_Type__c,Renewable_ACV__c,(SELECT Id,Partner_Type__c,Partner_Program__c,Partner_Incentive__c,Account__c,Account__r.Name,Account__r.Payment_Terms__c,Account__r.Billing_Frequency__c  FROM Opportunity_Partners__r WHERE Is_Primary__c=TRUE AND Partner_Type__c IN ('Reseller','Distributor') ORDER BY Partner_Type__c) FROM Opportunity WHERE ID IN: setOppty]);//IBA-1700
            Map<id,Partner_Incentive__c> mapDistrbutorPI = new Map<id,Partner_Incentive__c>();
            for(Partner_Incentive__c objPI:[select id,Account__c,Distributor__c from Partner_Incentive__c WHERE Distributor__c!= null AND Partner_Role__c='Distributor' and  Account__c IN (select Account__c from Opportunity_Partner__c where Opportunity__c in: setOppty AND Partner_Type__c ='Distributor')] ){
                mapDistrbutorPI.put(objPI.Account__c,objPI);
            }
            system.debug('mapDistrbutorPI...'+mapDistrbutorPI);
            for(SBQQ__Quote__C objQuote : listNewQLs){
                if(objQuote.SBQQ__ExpirationDate__c == null){
        objQuote.SBQQ__ExpirationDate__c = Date.today().addDays(30);
                }
                if(objQuote.SBQQ__MasterContract__C!=null && objQuote.SBQQ__opportunity2__c!=null && mapIdToOpportunity.containsKey(objQuote.SBQQ__opportunity2__c) && objQuote.Opportunity_Record_Type__c != SB_CONSTANTS.OPP_RECORD_TYPE){
                    Opportunity objOppty = mapIdToOpportunity.get(objQuote.SBQQ__opportunity2__c);
                    objQuote.Proposal_Name__c = String.isNotBlank(objQuote.Proposal_Name__c) ? objQuote.Proposal_Name__c : objOppty.Name;
                    //objQuote.SBQQ__Partner__c = objOppty.SBQQ__AmendedContract__r.Partner__c;
                    objQuote.SBQQ__Partner__C = objOppty.Primary_Reseller_Partner__c;objQuote.SBQQ__BillingFrequency__c = objOppty.SBQQ__AmendedContract__r.Billing_Frequency__c;objQuote.Price_List__c = objOppty.Opp_Price_List__c;
                    //objQuote.OwnerId = objOppty.OwnerId;
                    system.debug(objOppty.Opportunity_Partners__r.size());
                    if(objOppty.Opportunity_Partners__r!=null && objOppty.Opportunity_Partners__r.size()>0){
                        Opportunity_Partner__c objPartner = new Opportunity_Partner__c();
                        for(Opportunity_Partner__c objOpptyPartner : objOppty.Opportunity_Partners__r){
                            if(objOpptyPartner.Partner_Type__c == SB_CONSTANTS.PARTNER_TYPE_DISTRIBUTOR){
                                objQuote.Bill_to__c = objOpptyPartner.Account__c;objQuote.SBQQ__Distributor__c = objOpptyPartner.Account__c;objquote.SBQQ__BillingName__c = objOpptyPartner.Account__r.Name;objQuote.SBQQ__PaymentTerms__c = objOpptyPartner.Account__r.Payment_Terms__c;objQuote.SBQQ__BillingFrequency__c = objOpptyPartner.Account__r.Billing_Frequency__c;
                                if(!mapDistrbutorPI.isEmpty() && mapDistrbutorPI.containsKey(objQuote.Bill_to__c)){
                                    objQuote.Distributor_Disc__c  = mapDistrbutorPI.get(objQuote.Bill_to__c).Distributor__c;
                                }
                            }else{
                                objQuote.Partner_Incentive__c = objOpptyPartner.Partner_Incentive__c;objQuote.Partner_Program__c = objOpptyPartner.Partner_Program__c;objQuote.SBQQ__BillingFrequency__c = objOpptyPartner.Account__r.Billing_Frequency__c;objPartner = objOpptyPartner;
                            }
                        }
                        if(objQuote.Bill_to__c == null ){
                            objQuote.Bill_to__c = objPartner.Account__c;objQuote.SBQQ__Distributor__c = objPartner.Account__c;objquote.SBQQ__BillingName__c = objPartner.Account__r.Name;objQuote.SBQQ__PaymentTerms__c = objPartner.Account__r.Payment_Terms__c;objQuote.SBQQ__BillingFrequency__c = objPartner.Account__r.Billing_Frequency__c;objQuote.Partner_Incentive__c = objPartner.Partner_Incentive__c;objQuote.Partner_Program__c = objPartner.Partner_Program__c;
                        }
                    }
                    system.debug('objQuote...'+objQuote);
                }else if(objQuote.Opportunity_Record_Type__c == SB_CONSTANTS.OPP_RECORD_TYPE){
                    Opportunity objOppty = mapIdToOpportunity.get(objQuote.SBQQ__opportunity2__c);
                    if(objQuote.Early_Renewal__c == FALSE && objQuote.SBQQ__Type__c ==SB_CONSTANTS.RENEWAL){
                        objQuote.Auto_Generated_Quote__c =TRUE;
                        //IBA-1700 Start
                        if(objOppty.SBQQ__RenewedContract__r.Cloud_Type__c!=null)
                        objQuote.Cloud_Type__c=objOppty.SBQQ__RenewedContract__r.Cloud_Type__c;
                            //IBA-1700 End
                    }else{
                        
                        objQuote.Renewable_ACV__c = objOppty.Renewable_ACV__c;
                    }
                    system.debug('@@@'+objOppty.CloseDate.addDays(1));
                    objQuote.SBQQ__StartDate__c = objOppty.CloseDate.addDays(1);
                    objQuote.Proposal_Name__c = String.isNotBlank(objQuote.Proposal_Name__c) ? objQuote.Proposal_Name__c : objOppty.Name;
                    
                    //objQuote.OwnerId = objOppty.OwnerId;
                    if(objOppty.SBQQ__RenewedContract__C!=null){
                        //objQuote.Bill_to__c = objOppty.SBQQ__RenewedContract__r.Bill_to__c; commented for summit distribution by Rakshitha
                        objQuote.SBQQ__SubscriptionTerm__c = objOppty.SBQQ__RenewedContract__r.SBQQ__RenewalTerm__c;                    
                    }
                    system.debug('objQuote.SBQQ__EndDate__c'+objQuote.SBQQ__EndDate__c);
                    system.debug('objQuote.SBQQ__StartDate__c'+objQuote.SBQQ__StartDate__c);
                    if(objQuote.Price_List__c!=null && objQuote.Price_List__c.contains('Federal')){
                        objQuote.SBQQ__SubscriptionTerm__c = 12;objQuote.SBQQ__EndDate__c = objQuote.SBQQ__EndDate__c !=null && objQuote.SBQQ__EndDate__c>objQuote.SBQQ__StartDate__c?objQuote.SBQQ__EndDate__c:objQuote.SBQQ__StartDate__c.addMonths(12).addDays(-1);
                    }else{
                        objQuote.SBQQ__SubscriptionTerm__c =  36;
                        objQuote.SBQQ__EndDate__c = objQuote.SBQQ__EndDate__c!=null&&objQuote.SBQQ__EndDate__c>objQuote.SBQQ__StartDate__c?objQuote.SBQQ__EndDate__c:objQuote.SBQQ__StartDate__c.addMonths(36).addDays(-1);
                    }
                    system.debug(objOppty.Opportunity_Partners__r);
                    system.debug(objQuote.Early_Renewal__c);
                    if(objOppty.Opportunity_Partners__r!=null && objOppty.Opportunity_Partners__r.size()>0 && (objQuote.Early_Renewal__c || objQuote.Auto_Generated_Quote__c || objQuote.SBQQ__MasterContract__C!=null)){
                        /*Opportunity_Partner__c objOpptyPartner = objOppty.Opportunity_Partners__r[0];
objQuote.Partner_Incentive__c = objOpptyPartner.Partner_Incentive__c;
objQuote.Partner_Program__c = objOpptyPartner.Partner_Program__c;*/
                        
                        //Opportunity_Partner__c objPartner = new Opportunity_Partner__c();
                        
                        for(Opportunity_Partner__c objOpptyPartner : objOppty.Opportunity_Partners__r){                           
                            system.debug('objOpptyPartner.Partner_Type__c'+objOpptyPartner.Partner_Type__c);
                            if(objOpptyPartner.Partner_Type__c ==SB_CONSTANTS.PARTNER_TYPE_DISTRIBUTOR){
                                system.debug('Inside if statement');
                                objQuote.Bill_to__c = objOpptyPartner.Account__c;
                                objQuote.SBQQ__Distributor__c = objOpptyPartner.Account__c;
                                objquote.SBQQ__BillingName__c = objOpptyPartner.Account__r.Name;
                                objQuote.SBQQ__PaymentTerms__c = objOpptyPartner.Account__r.Payment_Terms__c;
                                objQuote.SBQQ__BillingFrequency__c = objOpptyPartner.Account__r.Billing_Frequency__c;
                                System.debug('@@@objQuote.SBQQ__PaymentTerms__c'+objQuote.SBQQ__PaymentTerms__c);
                                
                                if(!mapDistrbutorPI.isEmpty() && mapDistrbutorPI.containsKey(objQuote.Bill_to__c)){objQuote.Distributor_Disc__c  = mapDistrbutorPI.get(objQuote.Bill_to__c).Distributor__c;}
                            }else{
                                system.debug('Inside else statement');
                               // objPartner = objOpptyPartner;
                                objQuote.SBQQ__Partner__c = objOppty.Primary_Reseller_Partner__c;
                                objQuote.Partner_Incentive__c = objOpptyPartner.Partner_Incentive__c;objQuote.Partner_Program__c = objOpptyPartner.Partner_Program__c;objQuote.SBQQ__BillingFrequency__c = objOpptyPartner.Account__r.Billing_Frequency__c;
                                objQuote.Bill_to__c = objOpptyPartner.Account__c;objQuote.SBQQ__Distributor__c = objOpptyPartner.Account__c;objquote.SBQQ__BillingName__c = objOpptyPartner.Account__r.Name;objQuote.SBQQ__PaymentTerms__c = objOpptyPartner.Account__r.Payment_Terms__c;objQuote.SBQQ__BillingFrequency__c = objOpptyPartner.Account__r.Billing_Frequency__c;objQuote.Partner_Incentive__c = objOpptyPartner.Partner_Incentive__c;objQuote.Partner_Program__c = objOpptyPartner.Partner_Program__c;
                                }
                            }
                        }
                } 
            }
        }
    }
}

/*********************************************************************************
** Method Name: updateRepCompImpactedOnQuote
**
** Description: Thid methood is used to update Rep Comp Impacted Field on Quote
**
** @Param : List<SBQQ__Quote__c>
** @return : void
*********************************************************************************/  
public static void updateRepCompImpactedOnQuote(List<SBQQ__Quote__c> newList){
    if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        List<String> priceList = new List<String>();
        For(Price_List_Setting__mdt  showCartSettingRec : [SELECT DeveloperName,Price_List__c FROM Price_List_Setting__mdt Where DeveloperName IN('Volume_Tier','Commercial')]){
            priceList.addAll(showCartSettingRec.Price_List__c.split(';'));
        }
        for(SBQQ__Quote__c objQuote : newList){
            objQuote.Rep_Comp_Impacted__c = 'No';
            
            if(objQuote.Opportunity_Record_Type__c == 'New Business' || objQuote.Opportunity_Record_Type__c == 'New Business Close'){
                if(objQuote.Price_List__c == 'FY20 Pricelist' /* && objQuote.ACV_New__c >= 250000 */){ //objQuote.ACV_New__c >= 250000 is commented part of IBA-2201
                    if(objQuote.Partner_Program__c == APTS_CONSTANTS.P_PARTNERPRG_LEGACY && objQuote.Total_Discount_Without_Support__c >= 65){
                        objQuote.Rep_Comp_Impacted__c = 'Yes';
                    }      
                }
                
                // The below if block is commented part of IBA-2201
                /*if(objQuote.Partner_Program__c == System.Label.Partner_Program_Traditional || objQuote.Partner_Program__c == System.Label.Partner_Program_Summit_Discount){                     
                    if(priceList.contains(objQuote.Price_List__c) && objQuote.Net_Variance_Weighted_Avg_Approval__c >= 20 && objQuote.ACV_New__c >= 100000){
                        objQuote.Rep_Comp_Impacted__c = 'Yes';
                    }              
                }*/
                
                 if(objQuote.Partner_Program__c == System.Label.Partner_Program_Summit_Federal){
                    if(objQuote.Net_Variance_Weighted_Avg_Approval__c >= 25){
                        objQuote.Rep_Comp_Impacted__c = 'Yes';
                    }    
                } 
             
            }
            
            //The below if block's are added part of IBA-2201
            if((objQuote.Partner_Program__c == System.Label.Partner_Program_Traditional || objQuote.Partner_Program__c == System.Label.Partner_Program_Summit_Discount)
                 && priceList.contains(objQuote.Price_List__c) && objQuote.Net_Variance_Weighted_Avg_Approval__c >= 20
            ){
                if(objQuote.Opportunity_Record_Type__c != SB_CONSTANTS.OPP_RECORD_TYPE || 
                    (objQuote.Opportunity_Record_Type__c == SB_CONSTANTS.OPP_RECORD_TYPE && objQuote.Previous_MRR_Approval__c != Null && objQuote.Previous_MRR_Approval__c != 0 
                    && ((objQuote.Current_Quote_MRR__c/objQuote.Previous_MRR_Approval__c)-1) > Decimal.valueOf(System.Label.MRR_Comparison_Value))
                ){
                    objQuote.Rep_Comp_Impacted__c = 'Yes';
                    
                }
            }
        }   
    }
}


public static void setRenewableACV(Map<Id,SBQQ__Quote__c> mapQuoteNew, Map<Id,SBQQ__Quote__c> mapQuoteOld){
    Set<Id> SetRenewalQuotes = new Set<Id>();
    for(SBQQ__Quote__c objQuote: mapQuoteNew.values()){
        if(objQuote.Auto_Generated_Quote__c == TRUE && objQuote.Opportunity_Record_Type__c.contains(SB_CONSTANTS.RENEWAL) && objQuote.Renewable_ACV__c==null && objQuote.SBQQ__LineItemCount__c>0){
            SetRenewalQuotes.add(objQuote.id);       
        }
    }
    
    //Comment this section if Uncommenting Logic for CR# 3263 below
    if(!SetRenewalQuotes.isEmpty()){
        Map<Id,Decimal> mapQuoteIdToRenewACV = new Map<id,Decimal>();
        for(SBQQ__QuoteLine__c objQuoteLine: [SELECT ID,Expiring_MRR1__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RenewedSubscription__c!=NULL AND SBQQ__Quote__c IN: SetRenewalQuotes]){
            Decimal decARR = objQuoteLine.Expiring_MRR1__c!=null ? objQuoteLine.Expiring_MRR1__c* 12 : 0;Decimal decQuoteACV = mapQuoteIdToRenewACV.containsKey(objQuoteLine.SBQQ__Quote__c) ? mapQuoteIdToRenewACV.get(objQuoteLine.SBQQ__Quote__c) + decARR : decARR;mapQuoteIdToRenewACV.put(objQuoteLine.SBQQ__Quote__c,decQuoteACV);
        }
        if(!mapQuoteIdToRenewACV.isEmpty()){
            for(id idQuote: mapQuoteIdToRenewACV.keyset()){
                mapQuoteNew.get(idQuote).Renewable_ACV__c = mapQuoteIdToRenewACV.get(idQuote);
            }
        }     
    }
    //Comment above section if Uncommenting Logic for CR# 3263 below

    //Logic for CR# 3263 - ACV/TCV Line level Splits - Begin
    /*
    if(!SetRenewalQuotes.isEmpty()){
        Map<Id,Decimal> mapQuoteIdToRenewACV = new Map<id,Decimal>();
        Map<Id,Id> mapQLToRenewedSubs = new Map<Id,Id>();
        Map<Id,ID> mapRenewedSubsToQuote = new Map<Id,Id>();
        
        for(SBQQ__QuoteLine__c objQuoteLine: [SELECT ID,Expiring_MRR1__c,SBQQ__Quote__c,SBQQ__RenewedSubscription__c,SBQQ__RenewedSubscription__r.Short_Term_Upsell_Line__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RenewedSubscription__c!=NULL AND SBQQ__Quote__c IN: SetRenewalQuotes]){
            if(objQuoteLine.SBQQ__RenewedSubscription__r.Short_Term_Upsell_Line__c == TRUE){
                mapQLToRenewedSubs.put(objQuoteLine.id,objQuoteLine.SBQQ__RenewedSubscription__c);mapRenewedSubsToQuote.put(objQuoteLine.SBQQ__RenewedSubscription__c,objQuoteLine.SBQQ__Quote__c);
            }else{
            Decimal decARR = objQuoteLine.Expiring_MRR1__c!=null ? objQuoteLine.Expiring_MRR1__c * 12 : 0;Decimal decQuoteACV = mapQuoteIdToRenewACV.containsKey(objQuoteLine.SBQQ__Quote__c) ? mapQuoteIdToRenewACV.get(objQuoteLine.SBQQ__Quote__c) + decARR : decARR;mapQuoteIdToRenewACV.put(objQuoteLine.SBQQ__Quote__c,decQuoteACV);
        }
        }
        if(!mapQuoteIdToRenewACV.isEmpty() || !mapQLToRenewedSubs.isEmpty()){
            Map<Id,Decimal> mapShortTermRenewACV = new Map<Id,Decimal>();                    
            if(!mapQLToRenewedSubs.isEmpty()){
                for(SBQQ__Subscription__c objSub: [SELECT ID,Finance_MRR__c,SBQQ__RevisedSubscription__c FROM SBQQ__Subscription__C WHERE SBQQ__TerminatedDate__c=null AND ( Id IN: mapQLToRenewedSubs.values() OR (Short_Term_Upsell_Line__c=FALSE AND  SBQQ__RevisedSubscription__c IN: mapQLToRenewedSubs.values() ))]){
                    Id srcLineID = objSub.SBQQ__RevisedSubscription__c!=null? objSub.SBQQ__RevisedSubscription__c : objSub.id;Id idQuote = mapRenewedSubsToQuote!=null && mapRenewedSubsToQuote.containsKey(srcLineID) ? mapRenewedSubsToQuote.get(srcLineID) : null;Decimal decARR =  mapShortTermRenewACV!=null && mapShortTermRenewACV.containskey(idQuote) ? mapShortTermRenewACV.get(idQuote) : 0;decARR += objSub.Finance_MRR__c * 12;mapShortTermRenewACV.put(idQuote,decARR);
                }
            }
            
            for(id idQuote: mapQuoteNew.keyset()){
                system.debug('idQuote..'+idQuote);
                if(!mapShortTermRenewACV.isEmpty() && mapShortTermRenewACV.containsKey(idQuote)){
                    mapQuoteNew.get(idQuote).Renewable_ACV__c = mapShortTermRenewACV.get(idQuote);mapQuoteNew.get(idQuote).Non_Standard_Renewal__c = TRUE;
                    If(!mapQuoteIdToRenewACV.isEmpty() && mapQuoteIdToRenewACV.containskey(idQuote)){
                        Decimal decRACV = mapQuoteNew.get(idQuote).Renewable_ACV__c + mapQuoteIdToRenewACV.get(idQuote);
                        mapQuoteNew.get(idQuote).Renewable_ACV__c = decRACV;
                    }
                }else if(!mapQuoteIdToRenewACV.isEmpty() && mapQuoteIdToRenewACV.containskey(idQuote)){
                mapQuoteNew.get(idQuote).Renewable_ACV__c = mapQuoteIdToRenewACV.get(idQuote);
                    //mapQuoteNew.get(idQuote).Non_Standard_Renewal__c = FALSE;
                }
            }
        }     
    }*/
    //Logic for CR# 3263 - ACV/TCV Line level Splits - End
}

public static void updatePreviousRecordTypeName(List<SBQQ__Quote__c> newList){
    
    if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
        for(SBQQ__Quote__c objQuote : newList){
            if(objQuote.Record_Type_Name__c =='New Business' || objQuote.Record_Type_Name__c =='Amendment' || objQuote.Record_Type_Name__c == SB_CONSTANTS.RENEWAL){
                objQuote.Previous_Record_Type_Name_Text__c = objQuote.Record_Type_Name__c;
            }
        }
    }   
}

public static void setQuoteACV(List<SBQQ__Quote__c> newList){
    for(SBQQ__Quote__c objQuote : newList){
        if(objQuote.ACV__c!=null && objQuote.ACV__c!=0 && (objQuote.ACV_New__c ==0 || objQuote.ACV_New__c == null)){objQuote.ACV_New__c =  objQuote.ACV__c;}
    }
}

/*public static void updateQuoteEndDateOnEarlyRenewal(List<SBQQ__Quote__c> newList){
    for(SBQQ__Quote__c objQuote : newList){
        if(objQuote.SBQQ__MasterContract__c !=null && objQuote.Opportunity_Record_Type__c == 'Renewal Opportunity' && objQuote.Early_Renewal__c){
            if(objQuote.Partner_Program__c == 'Summit - Federal'){
                Date EndDate = objQuote.SBQQ__StartDate__c.addMonths(12);objQuote.SBQQ__EndDate__c = EndDate.addDays(-1);
            }else{
                Date EndDate = objQuote.SBQQ__StartDate__c.addMonths(36);
                objQuote.SBQQ__EndDate__c = EndDate.addDays(-1);
            }
            //Date EndDate = objQuote.SBQQ__MasterContract__r.EndDate;
        }
    }
}*/

public static void shareQuoteToOppTeam(List<SBQQ__Quote__c> newList){
    Set<Id> oppIds = new Set<Id>();
    for(SBQQ__Quote__c quoteRec : newList){
        oppIds.add(quoteRec.SBQQ__Opportunity2__c);
    }
    List<OpportunityTeamMember> oppTeamMembers = [Select Id, UserId, OpportunityId from OpportunityTeamMember Where OpportunityId IN: oppIds];
    Map<Id, List<OpportunityTeamMember>> oppTeamMembersMap = new Map<Id, List<OpportunityTeamMember>>();
    for(OpportunityTeamMember teamMemberRec : oppTeamMembers){
        if(oppTeamMembersMap.get(teamMemberRec.OpportunityId) == null){
            List<OpportunityTeamMember> tempList = new List<OpportunityTeamMember>();
            tempList.add(teamMemberRec);
            oppTeamMembersMap.put(teamMemberRec.OpportunityId, tempList);
        }
        else{
            List<OpportunityTeamMember> tempList = oppTeamMembersMap.get(teamMemberRec.OpportunityId);tempList.add(teamMemberRec);oppTeamMembersMap.put(teamMemberRec.OpportunityId, tempList);
        }
    }
    List<SBQQ__Quote__Share> quoteSharesToInsert = new List<SBQQ__Quote__Share>();
    for(SBQQ__Quote__c quoteRec : newList){
        if(oppTeamMembersMap.get(quoteRec.SBQQ__Opportunity2__c) != null){
            for(OpportunityTeamMember oppTeamRec : oppTeamMembersMap.get(quoteRec.SBQQ__Opportunity2__c)){
                SBQQ__Quote__Share quoteShareRec = new SBQQ__Quote__Share();
                quoteShareRec.ParentId = quoteRec.id;
                quoteShareRec.AccessLevel = 'EDIT';
                quoteShareRec.UserOrGroupId = oppTeamRec.UserId;
                quoteSharesToInsert.add(quoteShareRec);
            }
        }
    }
    if(!quoteSharesToInsert.isEmpty()){
        Database.insert(quoteSharesToInsert, false);
    }
}

/**
* @description 
* @author Rakshitha | 09-27-2021 |CR#3310
* @param newList 
* @param oldQuoteMap 
**/
public static void setNetSuiteInternalId(List<SBQQ__Quote__c> newList,Map<Id,SBQQ__Quote__c> oldQuoteMap){
    Set<Id> billToId = new Set<Id>();
    for(SBQQ__Quote__c objQuote : newList){
        if(objQuote.Partner_Involved__c && (oldQuoteMap==null  ||
            (oldQuoteMap!=null && oldQuoteMap.get(objQuote.Id).Bill_to__c != objQuote.Bill_to__c))){
                billToId.add(objQuote.Bill_to__c);
        }
    }
                
    Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,NetSuite_Internal_id__c FROM Account WHERE Id IN:billToId]);
    for(SBQQ__Quote__c objQuote : newList){
        if(objQuote.Partner_Involved__c && accountMap.containsKey(objQuote.Bill_to__c)){
                objQuote.NetSuite_Internal_Id__c =accountMap.get(objQuote.Bill_to__c).NetSuite_Internal_id__c;
        }else if(!objQuote.Partner_Involved__c){objQuote.NetSuite_Internal_Id__c =null;}
    }
}  

/**
* @description 
* @author Rakshitha | 10-13-2021 |CR#3406
* @param newList 
**/
public static void setPartner(List<SBQQ__Quote__c> quoteRecord){
        Set<Id> incentiveIds= new Set<Id>();
        for(SBQQ__Quote__c quoteRec : quoteRecord){
        incentiveIds.add(quoteRec.Partner_Incentive__c);
        }
        
        Map<Id,Partner_Incentive__c> partnerIncentive =new Map<Id,Partner_Incentive__c>([SELECT Id,Account__c FROM Partner_Incentive__c Where Id In:incentiveIds]); 
        for(SBQQ__Quote__c quoteRec : quoteRecord){
            if(partnerIncentive.containsKey(quoteRec.Partner_Incentive__c)&& (quoteRec.SBQQ__Partner__c != partnerIncentive.get(quoteRec.Partner_Incentive__c).Account__c)){
                quoteRec.SBQQ__Partner__c =partnerIncentive.get(quoteRec.Partner_Incentive__c).Account__c;
            }
        }
}

//This method creates the Opportunity Split records
//Logic for CR# 3263 - ACV/TCV Line level Splits - Begin
/*
public static void createSplitRecords(Map<Id,SBQQ__Quote__c> mapNewQuote, Map<Id, SBQQ__Quote__c> oldMap){
    Map<Id,Id> mapQuoteToOpportunityId = new Map<Id,Id>();
    for(SBQQ__Quote__c objQuote: mapNewQuote.values()){
        if(objQuote.SBQQ__Primary__C==TRUE && objQuote.Opportunity_Record_Type__c.contains('Renewal')){
            mapQuoteToOpportunityId.put(objQuote.Id,objQuote.SBQQ__opportunity2__c);
        }
    }
    system.debug('mapQuoteToOpportunity..'+mapQuoteToOpportunityId);
    if(mapQuoteToOpportunityId!=null && mapQuoteToOpportunityId.size()>0 && !System.isFuture() && !blnRunOnce){
        blnRunOnce = false;
        createSplitRecordsFuture(mapQuoteToOpportunityId);
    }
}

@future
public static void createSplitRecordsFuture(Map<Id,Id> mapQuoteToOpportunityId){
    Map<String,OpportunitySplit> mapKeyToSplit = new Map<String,OpportunitySplit>();
    //Map<Id,OpportunitySplit> mapIdToOpportunitySplit = new Map<Id,OpportunitySplit>([SELECT ID,OpportunityId,Split,SplitOwnerId,SplitPercentage, SplitTypeId,SplitAmount,Split_Type__c FROM OpportunitySplit WHERE OpportunityId In: mapQuoteToOpportunityId.values()]);
    Map<Id,Opportunity> mapIdToOppty = new Map<Id,Opportunity>([select id,account.ownerid,ownerid,(select ID,OpportunityId,Split,SplitOwnerId,SplitPercentage, SplitTypeId,SplitAmount,Split_Type__c from opportunitysplits) from opportunity where Id In: mapQuoteToOpportunityId.values()]);
    List<OpportunitySplit> listOSToUpsert = new List<OpportunitySplit>();
    Map<String,OpportunitySplit> mapUserToSplit = new Map<String,OpportunitySplit>();
    for(Opportunity ObjOpp: mapIdToOppty.values()){
        for(OpportunitySplit objOS: ObjOpp.OpportunitySplits){
            String strKey = ObjOpp.Id + '-' + objOS.Split_Type__c;
            mapKeyToSplit.put(strKey,objOS);
            mapUserToSplit.put(objOS.SplitOwnerId,ObjOS);
        }
    } 
    Map<Id,SBQQ__Quote__C> mapNewQuote = new Map<Id,SBQQ__Quote__C>([SELECT ID,Renewal_ACV__c,SBQQ__opportunity2__c,Upsell_ACV__c,ACV_New__c FROM SBQQ__Quote__C WHERE ID IN: mapQuoteToOpportunityId.Keyset()]);           
    for(Id objId: mapQuoteToOpportunityId.keyset()){
        SBQQ__Quote__c objQuote = mapNewQuote.get(objId);
        Opportunity objOpp = mapIdToOppty.get(objQuote.SBQQ__opportunity2__c);
        String strKey1 = objOpp.Id + '-Upsell';
        String strKey2 = objOpp.Id + '-Renewal';
        Decimal decUpsellSplit = 0;
        if(mapUserToSplit.ContainsKey(objOpp.Account.OwnerId)){
            OpportunitySplit objOSUpsell = mapUserToSplit.get(objOpp.Account.OwnerId);
            objOSUpsell.SplitPercentage= (objQuote.Upsell_ACV__c!=null && objQuote.ACV_New__c!=null ) ? (objQuote.Upsell_ACV__c / objQuote.ACV_New__c ) * 100 : 0;
            objOSUpsell.Split_Type__c='Upsell';
            decUpsellSplit  = objOSUpsell.SplitPercentage  ;
            listOSToUpsert.add(objOSUpsell);
        }else{
            OpportunitySplit objOSUpsell = (!mapKeyToSplit.isEmpty() && mapKeyToSplit.containsKey(strKey1)) ? mapKeyToSplit.get(strKey1) : new OpportunitySplit(OpportunityId = objQuote.SBQQ__Opportunity2__c, Split_Type__c='Upsell',SplitOwnerId = objOpp.Account.OwnerId);
            objOSUpsell.SplitPercentage= (objQuote.Upsell_ACV__c!=null && objQuote.ACV_New__c!=null ) ? (objQuote.Upsell_ACV__c / objQuote.ACV_New__c ) * 100 : 0;
            objOSUpsell.Split_Type__c='Upsell';
            decUpsellSplit  = objOSUpsell.SplitPercentage ;
            listOSToUpsert.add(objOSUpsell);
        }
        if(mapUserToSplit.ContainsKey(objOpp.OwnerId)){
            OpportunitySplit objOSRenewal = mapUserToSplit.get(objOpp.OwnerId);
            //objOSRenewal.SplitPercentage = objQuote.Renewal_ACV__c / objQuote.ACV_New__c;
            objOSRenewal.SplitPercentage = 100 - decUpsellSplit  ;
            objOSRenewal.Split_Type__c='Renewal';
            listOSToUpsert.add(objOSRenewal);
        }else{
            OpportunitySplit objOSRenewal = (!mapKeyToSplit.isEmpty() && mapKeyToSplit.containsKey(strKey1)) ? mapKeyToSplit.get(strKey1) : new OpportunitySplit(OpportunityId = objQuote.SBQQ__Opportunity2__c, Split_Type__c='Renewal',SplitOwnerId = objOpp.OwnerId);
            //objOSRenewal.SplitPercentage = objQuote.Renewal_ACV__c / objQuote.ACV_New__c;
            objOSRenewal.SplitPercentage = 100 - decUpsellSplit  ;
            objOSRenewal.Split_Type__c='Renewal';                
            listOSToUpsert.add(objOSRenewal);
        }
    }
    if(!listOSToUpsert.isEmpty()){
        if(!Test.isRunningTest()){
            upsert listOSToUpsert;
        }
    }
}
*/
//Logic for CR# 3263 - ACV/TCV Line level Splits - End

/**
* @description 
* @author Ritesh | 30-Nov-2021
* @param newQuoteList,oldQuoteMap
**/
public static void setQuoteFields(List<SBQQ__Quote__c> newQuoteList, Map<Id,SBQQ__Quote__c> oldQuoteMap) {
    
    for (SBQQ__Quote__c quote : newQuoteList) {
        if(quote.Upsell_ACV__c != null){
            quote.UpsellACV__c = quote.Upsell_ACV__c;
        }
        //CR# 3465 -  Added by Hari
        if(quote.Opportunity_Record_Type__c == SB_CONSTANTS.OPP_RECORD_TYPE && trigger.isInsert && quote.Geo_Opportunity__c!='Public sector'){// Added GeopportunityCheck for IBA-1521 By Ajith)
            quote.Show_Discount__c = false;
        }
        // if(quote.SBQQ__LineItemCount__c > 0){
        //     if((quote.SBQQ__SubscriptionTerm__c != null && quote.SBQQ__SubscriptionTerm__c != oldQuoteMap?.get(quote.Id).SBQQ__SubscriptionTerm__c) ||
        //         (quote.SBQQ__StartDate__c != null && quote.SBQQ__StartDate__c != oldQuoteMap?.get(quote.Id).SBQQ__StartDate__c) ||
        //         (quote.SBQQ__EndDate__c != null && quote.SBQQ__EndDate__c != oldQuoteMap?.get(quote.Id).SBQQ__EndDate__c)){
        //             annualBreakdownQuoteSet.add(quote.Id);
        //     }
        // }
    }

    // if(!annualBreakdownQuoteSet.isEmpty()){system.enqueuejob(new AnnualBreakdownUtilQueueable(annualBreakdownQuoteSet));}
}
/**
* @description 
* @author Rakshitha | 28-Jan-2022
* @param newQuoteList,partnerAccountMap
**/
public static void setDocumentTypeFields(List<SBQQ__Quote__c> newQuoteList,Map<Id,SBQQ__Quote__C> oldQuoteMap) {
    List<String> templateSpecificAccount = System.Label.AnnualBreakAccounts.split(';');
    
    Set<Id> accountIds= new Set<Id>(); 
    for (SBQQ__Quote__c quote : newQuoteList) {
        accountIds.add(quote.SBQQ__Partner__c);
    }
    Map<Id,Account> partnerAccountMap = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE Id In :accountIds]);
    for (SBQQ__Quote__c quote : newQuoteList) {
        if(oldQuoteMap ==null && partnerAccountMap.containsKey(quote.SBQQ__Partner__c) && templateSpecificAccount.contains(partnerAccountMap.get(quote.SBQQ__Partner__c).Name)){
            if(String.isBlank(quote.Document_Type__c)){
                quote.Document_Type__c = 'Annual breakdown;';
                //quote.Generate_Year_Wise_Split__c = false;
            }  
        } 
        //CR# 4269 - Added by Ritesh - Start
        else if(quote.SBQQ__BillingFrequency__c !='Annual' || quote.SBQQ__SubscriptionTerm__c < 12){
            quote.Document_Type__c = '';
        } else if(String.isBlank(quote.Document_Type__c)){
            quote.Document_Type__c = 'Year wise Split;';
        }
        //CR# 4269 - Added by Ritesh - End
        
        /* if(oldQuoteMap!=null && (String.isBlank(oldQuoteMap.get(quote.Id).Document_Type__c) || !oldQuoteMap.get(quote.Id).Document_Type__c.Contains('Annual breakdown') ) &&  
            (!String.isBlank(quote.Document_Type__c) && quote.Document_Type__c.contains('Annual breakdown'))){
            System.debug( quote.Generate_Year_Wise_Split__c);
            quote.Generate_Year_Wise_Split__c = false;
        }else if(oldQuoteMap!=null && !oldQuoteMap.get(quote.Id).Generate_Year_Wise_Split__c && quote.Generate_Year_Wise_Split__c){
            quote.Document_Type__c = '';
        } */
    }
}
/**
* @description 
* @author Rakshitha | 05-April-2022-CR# 3465 
* @param newQuoteList,partnerAccountMap
**/
public static void setRenewalQuoteFields(List<SBQQ__Quote__c> newQuoteList) {
    for(SBQQ__Quote__c quoteList :newQuoteList){
        if(quoteList.Opportunity_Record_Type__c.equalsIgnoreCase(SB_CONSTANTS.OPP_RECORD_TYPE)){
            quoteList.Show_Discount__c = false;
        }
    }
}
/**
* @description 
* @author Madhusudan | 21-April-2022-CR# 4619 
* @param newQuoteList
**/
public static void setCloudTypeField(List<SBQQ__Quote__c> newQuoteList) {
    set<Id> conIds = new set<Id>();
    for(SBQQ__Quote__c newQuote :newQuoteList){
        if(newQuote.SBQQ__MasterContract__c != NULL && newQuote.Cloud_Type__c == NULL){
            conIds.add(newQuote.SBQQ__MasterContract__c);
        }
    }
    Map<Id, Contract> conMap = new Map<Id, Contract>([SELECT ID, Cloud_Type__c FROM Contract WHERE ID IN : conIds]);
    for(SBQQ__Quote__c newQuote :newQuoteList){
        if(conMap.containsKey(newQuote.SBQQ__MasterContract__c)){
            newQuote.cloud_type__c = conMap.get(newQuote.SBQQ__MasterContract__c).cloud_type__c;
        }
    }
}

/**
* @description 
* @author rakshitha | 11-June-2022 JIRA-IBA-1279
* @param newQuoteList
**/
    public static void upgradeProduct(List<SBQQ__Quote__c> newQuoteList,Map<Id,SBQQ__Quote__c> oldQuoteMap) {
    List<String> priceList = new List<String>();
    Map<String,String> quotePriceListMap = new Map<String,String>();

    for(SBQQ__Quote__c newQuote :newQuoteList){
        if(newQuote.Price_List__c != NULL && oldQuoteMap!=null && oldQuoteMap.get(newQuote.Id).Price_List__c != newQuote.Price_List__c && newQuote.Opportunity_Record_Type__c==SB_CONSTANTS.OPP_RECORD_TYPE){
            quotePriceListMap.put(newQuote.Id,newQuote.Price_List__c);
            priceList.add(newQuote.Price_List__c);
        }
    }

    List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,SBQQ__Product__c,SBQQ__ProductCode__c,SBQQ__ProductOption__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:quotePriceListMap.keySet() AND SBQQ__ProductCode__c!=null WITH SECURITY_ENFORCED];
    set<Id> productId = new Set<Id>();
    for(SBQQ__QuoteLine__c qline : quoteLineList){
        productId.add(qline.SBQQ__Product__c);
    }
    
    List<SBQQ__Quoteline__c> quoteLineUpdateList= QuoteLineTriggerServices.upgradeFunctionProcess(priceList,quotePriceListMap,productId,quoteLineList);
    if(!quoteLineUpdateList.isEmpty()){
    try{
    SBQQ.TriggerControl.disable();
    TriggerUtility.createAnnualBreakdownLinesExecuted();
    if(SBQQ__QuoteLine__c.sObjectType.getDescribe().isUpdateable()){
        Database.update(quoteLineUpdateList, false);
    }
    }finally{
        SBQQ.TriggerControl.enable(); 
    }
    }
}
    /* IBA-5540 This method primary quotes and perform the Annual Brakdown & yearwiseSplits*/
        public static void afterUpdate(List<SBQQ__Quote__c> quoteList, Map<Id,SBQQ__Quote__c> oldQuoteMap){
        //QuoteLineTriggerServices services = new QuoteLineTriggerServices(Trigger.new,Trigger.newMap,Trigger.oldMap);
             Set<Id> quoteIds = new Set<Id>();
             for(SBQQ__Quote__c quote: quoteList){
                if(quote.SBQQ__Primary__c != oldQuoteMap.get(quote.Id).SBQQ__Primary__c && quote.SBQQ__Primary__c==True){
                    quoteIds.add(quote.Id);
                }
                if(!quoteIds.isEmpty() && quoteIds != null && TriggerUtility.quoteTriggerforAnnualBreakDown==false){
                    TriggerUtility.quoteTriggerforAnnualBreakDown = True;
                    system.enqueuejob(new AnnualBreakdownYWSUtilQueueable(quoteIDs));
                   
                }
            }
      }      
}