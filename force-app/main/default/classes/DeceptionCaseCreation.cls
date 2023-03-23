public class DeceptionCaseCreation {
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
    
    @InvocableMethod(label='CreateDeceptionCase')
    public static void createDeceptionCase(List<Id> recIds){
        Contract_Detail__c cd = [SELECT Id, Opportunity__c,Opportunity__r.StageName,Opportunity__r.Name, Sales_Order__c, Sales_Order_Name__c FROM Contract_Detail__c WHERE Id =: recIds[0]];
        
        if(cd.Sales_Order__c !=null){
            List<Case> cslst = new List<Case>();
            String  OpportunityId ;
            String  oppStage ;
            String  OppName ;
            System.debug('cd.Opportunity__c=='+cd.Opportunity__c);
            if(cd.Opportunity__c != NULL && cd.Opportunity__r.StageName !=null){
                OpportunityId = cd.Opportunity__c ; 
                oppStage = cd.Opportunity__r.StageName;
                OppName = cd.Opportunity__r.name;
            }
            else if(cd.Sales_Order_Name__c != NULL){
                // Find the right opportunity based on SalesOrde
                Opportunity opp = [SELECT Id,stageName,name FROM Opportunity WHERE Netsuite_Sales_Order_Number__c =: cd.Sales_Order_Name__c]; 
                if(opp !=null){
                    OpportunityId =opp.id;
                    oppStage = opp.StageName;
                    OppName = opp.name;
                }
                
                
            }
            System.debug(' OpportunityId=='+ OpportunityId);
             Map<Id,Case> mapOptywithExistingCase = new Map<Id,case>();
             List<Contract_Detail__c> lstcd =[select id,name,Product_SKU__c,Opportunity__c,Sales_Order_Name__c,Quantity__c,Sales_Order__c,Sales_Order__r.name, Sales_Order__r.Opportunity.Netsuite_Sales_Order_Link__c, Sales_Order__r.Opportunity.Netsuite_Sales_Order_Number__c from Contract_Detail__c where Sales_Order__c=:cd.Sales_Order__c ];
             List<Case> caseList = [select id,Deception_Type__c,Opportunity_Name__c from Case where Deception_Type__c !=null and origin='Integration' 
                                           and Opportunity_Name__c =:OpportunityId];
            System.debug('caseList==='+caseList);
                    
                    if(!caseList.isEmpty()){
                        for(Case csobj:caseList){
                            mapOptywithExistingCase.put(csobj.Opportunity_Name__c,csObj);
                        }
                        
                    }
            if(lstcd !=null && ! lstcd.isEmpty()){
                System.debug('here '+lstcd);
                List<String> deceptionProdsList = new List<String>();
                Boolean isAdvancedDeception = false;
                for(Contract_Detail__c cdObj : lstcd){
                    System.debug('.label.==>'+System.label.Deception_SKU_List);
                    System.debug('product sku==>'+cdObj.Product_SKU__c);
                    //Chnages added for MVP2 provisioning
                    if((System.label.Deception_SKU_List.contains(cdObj.Product_SKU__c) || System.label.Deception_Standard_SKU_List.contains(cdObj.Product_SKU__c)) && oppStage !=null &&
                       ! mapOptywithExistingCase.containskey(cdObj.Opportunity__c)){
                       isAdvancedDeception = System.label.Deception_SKU_List.contains(cdObj.Product_SKU__c) ? true : false;
                       deceptionProdsList.add(cdObj.Product_SKU__c + ': ' + cdObj.Quantity__c);
                    }
                }
                
                if(!deceptionProdsList.isEmpty()) {
                        System.debug('here ==>');
                        if(oppStage==System.label.Stage_0_Initial_Prospecting || oppStage == System.label.Stage_0_Pipeline_Generation || oppStage == System.label.Stage_1_Alignment ||
                           oppStage==System.label.Stage_2_Qualified_Budgeted || oppStage == System.label.Stage_3_Value_Impact_Validation || oppStage == System.label.Stage_4_Economic_Buyer_Signoff
                           || oppStage == System.label.Stage_5_Procurement){
                               Case cs = createCase(OpportunityId,lstcd[0], 'A new POC has been Requested for deception for ' +OppName ,'POV', deceptionProdsList, isAdvancedDeception); 
                               if(cs != null){
                                   cslst.add(cs);
                                        System.debug('cs'+cs);
                               }
                           }
                        
                        
                        else if (oppStage ==System.label.Stage_5A_Opportunity || oppStage== System.label.Stage_5B_Opportunity || oppStage == System.label.Stage_5C_Opportunity
                                 || oppStage == System.label.Stage_5D_Opportunity || oppStage == System.label.Stage_5_Contracts_Complete || oppStage== System.label.Stage_6_Closed_Won
                                 || oppStage == System.label.Stage_7_Closed_Lost){
                                     Case cs = createCase(OpportunityId,lstcd[0], 'A purchase order is received for deception for ' +OppName ,'Order', deceptionProdsList, isAdvancedDeception); 
                                    System.debug('cs'+cs);
                                     if(cs != null){
                                         cslst.add(cs);
                                     }
                                     
                                 }
                        
                      
                    
                }
                  if(!cslst.isEmpty()){
                       TriggerUtility.SkipCaseTriggerExecuted();
                            insert cslst;
                            System.debug('here saving case'+cslst);
                        }
                        
            } 
        }
        
    }
    
    
    public static Case createCase(String opportunityId, Contract_Detail__c cd, String sub,String deceptionType, List<String> deceptionProdsList, Boolean isAdvancedDeception){
        // system.debug('pr '+pr);
        system.debug('sub '+sub);
        Map<String, DefaultData__c> ddmap = DefaultData__c.getAll();
        if(ddmap != null && !ddmap.isEmpty() && ddmap.containsKey('PRCaseCreationDefault')){
            DefaultData__c dd = ddmap.get('PRCaseCreationDefault');
            List<Contact> conlist= new List<Contact>();
            Opportunity opp =[select id , SE_Name__c,SE_Name__r.FirstName,SE_Name__r.LastName,SE_Name__r.Email from Opportunity where id=:opportunityId];
           if(opp.SE_Name__r.Email !=null)
                conlist=[Select id,email from Contact where email=:opp.SE_Name__r.Email and Accountid=:dd.Account_Id__c];
            Case cs = new Case(RecordTypeId = caseSupportRT);
            //cs.Provisioning_Request__c = pr.Id;
            cs.Opportunity_Name__c = opportunityId;
           cs.Case_Type__c = dd.Type__c;
            cs.Deception_Type__c=deceptionType;
            
            cs.Case_Category__c = 'Deployment/Configuration';
            cs.Subject = sub;
            cs.Status = dd.Stage_Status__c;
            cs.Priority = dd.Priority__c;
            cs.AccountId = dd.Provisioning_Account_Id__c;
             cs.Product_New__c = 'Zscaler Deception';
            cs.Description = 'SalesOrder No. '+cd.Sales_Order__r.name + ' ' +cd.Sales_Order__r.Opportunity.Netsuite_Sales_Order_Link__c + '/\n ';
            for(String dProd :deceptionProdsList) {
                cs.Description += dProd + '/\n ';
            }
            if(isAdvancedDeception) {
                cs.Description += 'Standard/Advanced Deception: Advanced';
            } else {
                cs.Description += 'Standard/Advanced Deception: Standard';
            }
            
            if(!conlist.isempty()){
                cs.ContactId=conlist[0].id;
            }
            else{
                Contact con; con= new Contact(LastName=opp.SE_Name__r.LastName,FirstName=opp.SE_Name__r.FirstName,AccountId=dd.Account_Id__c,Project_Role__c='Other',LeadSource='Zscaler Employee',Email=opp.SE_Name__r.email);
                TriggerUtility.SkipContactTriggerExecuted();
                insert con;
                cs.ContactId = con.id;
             }
             cs.OwnerId = System.label.Zscaler_Deception_Queue_Id;//ownerid;
            cs.Origin='Integration';
            
            return cs;
        }
        return null;
    }
    
    
    
}