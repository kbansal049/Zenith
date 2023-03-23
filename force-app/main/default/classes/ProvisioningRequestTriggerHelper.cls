/*****************************************************************************************
Name: ProvisioningRequestTriggerHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Helper class to have all the business logic used in Provisioning Request Trigger
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     17-Oct-2016    Initial Development
******************************************************************************************/
public class ProvisioningRequestTriggerHelper {
    /**
* Method to 'Active Screen' the accounts associated with POCs upon Provisioning_Request__c creation 
* @param lstNewProvisioningRequests List of newly created Provisioning_Request__c
*/
    public static Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
    public static Id inline2RecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud Details').getRecordTypeId();
    public static Id fevaRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
    public static Id ZPAInteractiveRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('ZPA Interactive').getRecordTypeId();
    public static Id NFRRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('NFR Licence').getRecordTypeId();
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
    public static Id cbiRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Cloud Browser Isolation (C.B.I)').getRecordTypeId();
    
    
    public static boolean skipTrigger = false;
    
    public static void afterInsert(List < Provisioning_Request__c > newList) {
        if(!TriggerUtility.isCaseCreationInsertPRExecuted()){
            createCasefromPRonInsert(newList);
        }
        
        System.debug('TriggerUtility2.isPRNFRFieldUpdateExecuted()'+!TriggerUtility2.isPRNFRFieldUpdateExecuted());
        //CR# 1920 Start
        if(!TriggerUtility2.isPRNFRFieldInsertExecuted()){
            updateNFRLinks(newList);
        }
        //CR# 1920 End
        
        
        
        TriggerUtility.PRafterInsertExecuted();
    }
    
    public static void afterUpdate(List < Provisioning_Request__c > newList, Map<Id, Provisioning_Request__c> oldmap) {
        if(!TriggerUtility.isCaseCreationUpdatePRExecuted()){
            createCasefromPRonUpdate(newList, oldmap);
          
        }
        //CR# 1920 Start
        System.debug('Inside after update');
        System.debug('TriggerUtility2.isPRNFRFieldUpdateExecuted()'+TriggerUtility2.isPRNFRFieldUpdateExecuted());
        if(!TriggerUtility2.isPRNFRFieldUpdateExecuted()){
            updateNFRFields(newList,oldmap);
            
            //updateCaseDescription(oldmap.keySet());
        }
        //CR# 1920 END
        
        
        
          createDeceptionCaseOnPRonUpdate(newList, oldmap);
        TriggerUtility.PRafterUpdateExecuted();
    }
    
    public static void createDeceptionCaseOnPRonUpdate(List < Provisioning_Request__c > newList, Map<Id, Provisioning_Request__c> oldmap){
        Set<id>pridSet = new set<id>();
        for (Provisioning_Request__c pr : newList){
            System.debug(pr.Provisioning_Status__c+'=====pr.Provisioning_Status__c===='+oldmap.get(pr.id).Provisioning_Status__c);
            if(pr.Provisioning_Status__c =='Provisioned' && pr.Provisioning_Status__c !=oldmap.get(pr.id).Provisioning_Status__c ){
                pridSet.add(pr.id);
            }
        }
        if(pridSet !=null && pridSet.size()>0){
            Map<Id, Provisioning_Request__c> prmap =new map<Id,Provisioning_Request__c>([select id,name,Provisioning_Status__c,Opportunity__c,(select id,SKU__c,Provisioning_Request__c,Opportunity_Stage__c,Opportunity_Name__c,
                                                                                                                                               Provisioning_Request__r.Opportunity__c from POC_Products__r)
                                                                                         from Provisioning_Request__c where id In:pridSet]);
            
            Map<Id,Case> mapPRwithCase = new Map<Id,Case>();
            Set<id>optyIdSet = new Set<Id>();
            //Map<Id,Id> mapPRwithCase
            if(!prmap.isEmpty()){
                for(Provisioning_Request__c probj: prmap.values()){
                    if(probj.Opportunity__c !=null){
                        optyIdSet.add(probj.Opportunity__c);
                    }
                }
                
                Map<Id,Case> mapOptywithExistingCase = new Map<Id,case>();
                // get the existing case of deception type
                List<Case> caseList = [select id,Deception_Type__c,Opportunity_Name__c from Case where Deception_Type__c !=null and origin='Integration' 
                                       and Opportunity_Name__c In:optyIdSet];
                System.debug('caseList==='+caseList);
                if(!caseList.isEmpty()){
                    for(Case csobj:caseList){
                        mapOptywithExistingCase.put(csobj.Opportunity_Name__c,csObj);
                    }
                    
                }
                
                for(Provisioning_Request__c probj :prmap.values()){
                    if(!probj.POC_Products__r.isEmpty()){
                        for(POC_Product__c pc :probj.POC_Products__r){
                            //&& mapOptywithExistingCase.get(pc.Provisioning_Request__r.Opportunity__c) !=null
                            System.debug('==='+mapOptywithExistingCase.containskey(pc.Provisioning_Request__r.Opportunity__c));
                            if(System.label.Deception_SKU_List.contains(pc.SKU__c) && ! mapOptywithExistingCase.containskey(pc.Provisioning_Request__r.Opportunity__c) ){
                                System.debug('here in 107');
                                if(pc.Opportunity_Stage__c==System.label.Stage_0_Initial_Prospecting || pc.Opportunity_Stage__c == System.label.Stage_0_Pipeline_Generation || pc.Opportunity_Stage__c == System.label.Stage_1_Alignment ||
                                   pc.Opportunity_Stage__c==System.label.Stage_2_Qualified_Budgeted || pc.Opportunity_Stage__c == System.label.Stage_3_Value_Impact_Validation || pc.Opportunity_Stage__c == System.label.Stage_4_Economic_Buyer_Signoff  || pc.Opportunity_Stage__c == System.label.Stage_5_Procurement){
                                       Case cs = prepareDeceptionCase(prObj, 'A new POC has been Requested for deception for ' + pc.Opportunity_Name__c,'POV'); 
                                       if(cs != null){
                                           mapPRwithCase.put(pc.Provisioning_Request__c,cs);
                                           //break; 
                                       }
                                   }
                                else if (pc.Opportunity_Stage__c ==System.label.Stage_5A_Opportunity || pc.Opportunity_Stage__c== System.label.Stage_5B_Opportunity || pc.Opportunity_Stage__c == System.label.Stage_5C_Opportunity
                                         || pc.Opportunity_Stage__c == System.label.Stage_5D_Opportunity || pc.Opportunity_Stage__c == System.label.Stage_5_Contracts_Complete || pc.Opportunity_Stage__c== System.label.Stage_6_Closed_Won
                                         || pc.Opportunity_Stage__c == System.label.Stage_7_Closed_Lost){
                                             
                                             Case cs = prepareDeceptionCase(prObj, 'A purchase order is received for deception for ' + pc.Opportunity_Name__c,'Order'); 
                                             if(cs != null){
                                                 mapPRwithCase.put(pc.Provisioning_Request__c,cs);
                                                 
                                             }
                                             
                                         }
                            }
                            
                        }
                        
                    }
                }
                
                try{
                if(!mapPRwithCase.isEmpty() && mapPRwithCase !=null){
                    System.debug('mapPRwithCase='+mapPRwithCase);
                    
                    TriggerUtility.SkipCaseTriggerExecuted();
                    insert mapPRwithCase.values();
                    
                }
                }catch(Exception ex){
                     ProvisioningErrorHandler.exceptionHandler('ProvisioningRequestTriggerHelper','createDeceptionCaseOnPRonUpdate',ex);

                }
            }
            
            
        }
        
    }
    
    public static Case prepareDeceptionCase(Provisioning_Request__c pr, String sub,String deceptionType){
        system.debug('pr '+pr);
        system.debug('sub '+sub);
        try{
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' +pr.id;
  
        Map<String, DefaultData__c> ddmap = DefaultData__c.getAll();
        if(ddmap != null && !ddmap.isEmpty() && ddmap.containsKey('PRCaseCreationDefault')){
            DefaultData__c dd = ddmap.get('PRCaseCreationDefault');
            List<Contact> conlist= new List<Contact>();
             Opportunity opp =[select id , SE_Name__c,SE_Name__r.FirstName,SE_Name__r.LastName,SE_Name__r.Email from Opportunity where id=:pr.Opportunity__c];
           if(opp.SE_Name__r.Email !=null)
             	conlist=[Select id,email from Contact where email=:opp.SE_Name__r.Email and Accountid=:dd.Account_Id__c];
            List<POC_Product__c> pocList= [Select id , name , SKU__c,Product__c,Provisioning_Request__c from POC_Product__c  where Provisioning_Request__c=:pr.Id];
            List<String> deceptionProdsList =new List<String>();
            for(POC_Product__c prodSku : pocList){
                deceptionProdsList.add(prodSku.SKU__c);
            }
            System.debug('Deception product list'+deceptionProdsList);
            Boolean isAdvancedDeception = false;

            for(POC_Product__c pocprod : pocList){
                System.debug('inside deception for');
                if((System.label.Deception_SKU_List.contains(pocprod.SKU__c) || 
                    System.label.Deception_Standard_SKU_List.contains(pocprod.SKU__c))){
                        isAdvancedDeception = System.label.Deception_SKU_List.contains(pocprod.SKU__c) ? true : false;

                    }

            }
            System.debug('isAdvancedDeception'+isAdvancedDeception);


            Case cs = new Case(RecordTypeId = caseSupportRT);
            //cs.Provisioning_Request__c = pr.Id;
            cs.Opportunity_Name__c = pr.Opportunity__c;
            cs.Subject = sub;
            cs.Case_Type__c = dd.Type__c;
            cs.Case_Category__c = 'Deployment/Configuration';
            cs.Status = dd.Stage_Status__c;
            cs.Priority = dd.Priority__c;
            cs.AccountId = dd.Account_Id__c;
            cs.Description ='PR No. : '+pr.Name + ' ' +fullFileURL+'\n ';
            for(String dProd :deceptionProdsList) {
                cs.Description += dProd + '\n ';
            }
            if(isAdvancedDeception) {
                cs.Description += 'Standard/Advanced Deception: Advanced';
            } else {
                cs.Description += 'Standard/Advanced Deception: Standard';
            }
            System.debug('Printing description'+cs.Description);
            cs.Product_New__c = 'Zscaler Deception';// Zscaler Deception Support Queue
            cs.Deception_Type__c=deceptionType;
            if(!conlist.isempty()){
                cs.ContactId=conlist[0].id;
            }
            else{
                System.debug(opp.SE_Name__r.LastName+'===='+opp.SE_Name__r.FirstName);
                Contact con; con= new Contact(LastName=opp.SE_Name__r.LastName,FirstName=opp.SE_Name__r.FirstName,AccountId=dd.Account_Id__c,Project_Role__c='Other',LeadSource='Zscaler Employee',Email=opp.SE_Name__r.email);
                TriggerUtility.SkipContactTriggerExecuted();
                insert con;
                cs.ContactId = con.id;
            }
            cs.OwnerId = System.label.Zscaler_Deception_Queue_Id;//ownerid;
            cs.Origin='Integration';
          //  cs.Description ='PR No. : '+pr.Name;
            return cs;
        }
        }catch(Exception ex){
            ProvisioningErrorHandler.exceptionHandler('ProvisioningRequestTriggerHelper','prepareDeceptionCase',ex);
			
        }
        return null;
    }
    
    
    public static void createCasefromPRonInsert(List < Provisioning_Request__c > newList) {
        List<Case> cslst = new List<Case>();
        boolean IsPurgeCase=false; //Added by Gurjinder as part of CR# 296 
        boolean IsDecommissionCase=false; //Added by Gurjinder as part of CR# 330 
        boolean IsApprovalCase=false;//Added by Swathi as part of CR# 2699
        try{
        for(Provisioning_Request__c pr: newList){
            system.debug('pr   '+pr);
            //5a, 5b, 5c
            if((pr.RecordTypeId == NFRRecordTypeId && pr.Provisioning_Status__c == 'Requested' && pr.Internal_user__c == false) || 
               //Added as part of CR# 3822
               (pr.RecordTypeId == inlineRecordTypeId && pr.Provisioning_Status__c == 'Requested' && 
                (pr.Opportunity_Stage__c != Label.Stage_5A_Opportunity && pr.Opportunity_Stage__c != Label.Stage_5B_Opportunity && pr.Opportunity_Stage__c != Label.Stage_5C_Opportunity && pr.Opportunity_Stage__c != Label.Stage_5D_Opportunity && pr.Opportunity_Stage__c != Label.Stage_6_Closed_Won) &&
                pr.GEO__c=='WW Commercial') ||
               //(System.Label.Finance_V2_Profile_ID.contains(userInfo.getProfileId()) || System.Label.Profile_System_Administrator.contains(userInfo.getProfileId())) ||
               ((((pr.RecordTypeId == inlineRecordTypeId || pr.RecordTypeId == cbiRecordTypeId) && pr.Approval_Status__c == 'Approved') ||
                 ((pr.RecordTypeId == inlineRecordTypeId || pr.RecordTypeId == cbiRecordTypeId) && (System.Label.Finance_V2_Profile_ID.contains(userInfo.getProfileId()) || userInfo.getUserId()==System.Label.PRUserIdToExcludeFromApproval || pr.GEO__c=='WW Commercial'))) 
                && pr.Provisioning_Status__c == 'Requested' && ((pr.Opportunity_Stage__c != Label.Stage_5A_Opportunity && pr.Opportunity_Stage__c != Label.Stage_5B_Opportunity && pr.Opportunity_Stage__c != Label.Stage_5C_Opportunity && pr.Opportunity_Stage__c != Label.Stage_6_Closed_Won) || pr.Account_Type__c != 'Customer'))){
                    Case cs = createCase(pr, 'A new POC has been Requested for ' + pr.Account_Name__c +' '+ pr.Name,IsPurgeCase,IsDecommissionCase,IsApprovalCase); //Added IsDecommissionCase by Gurjinder as part of CR# 330
                    if(cs != null){
                        cslst.add(cs);
                    }
                }
            
            
        }
        if(!cslst.isEmpty()){
            insert cslst;
            TriggerUtility.CaseCreationInsertPRExecuted();
        }
        }catch(Exception ex){
            ProvisioningErrorHandler.exceptionHandler('ProvisioningRequestTriggerHelper','createCasefromPRonInsert',ex);
        }
        
    }
    
    
    
    public static void createCasefromPRonUpdate(List < Provisioning_Request__c > newList, Map<Id, Provisioning_Request__c> oldmap) {
        List<Case> cslst = new List<Case>();
        boolean IsPurgeCase=false; //Added by Gurjinder as part of CR# 296 
        boolean IsDecommissionCase=false; //Added by Gurjinder as part of CR# 330 
        boolean IsApprovalCase=false;//Added by Swathi as part of CR# 2699
        try{
        for(Provisioning_Request__c pr: newList){
            system.debug('pr in createCasefromPRonUpdate  '+pr);
            system.debug('pr name  '+pr.Name);
            if(pr.Provisioning_Status__c == 'To be Purged' && pr.Provisioning_Status__c != oldmap.get(pr.Id).Provisioning_Status__c){
                system.debug('inside To be purged condition  ');
                IsPurgeCase=true;
                Case cs = createCase(pr, 'Purge has been requested for ' + pr.Name +  pr.Account_Name__c+ ' : ' + pr.Preferred_Cloud__c + '-' + pr.Org_ID_with_cloud__c,IsPurgeCase,IsDecommissionCase,IsApprovalCase); //Added IsDecommissionCase by Gurjinder as part of CR# 330
                if(cs != null){
                    cslst.add(cs);
                }
            }
            
            if(pr.Provisioning_Status__c == 'Purge Stopped' && pr.Provisioning_Status__c != oldmap.get(pr.Id).Provisioning_Status__c){
                system.debug('inside Purge Stopped condition  ');
                Case cs = createCase(pr, 'Stop Purge has been requested for ' + pr.Name +  pr.Account_Name__c+ ' : ' + pr.Preferred_Cloud__c + '-' + pr.Org_ID_with_cloud__c,IsPurgeCase,IsDecommissionCase,IsApprovalCase); //Added IsDecommissionCase by Gurjinder as part of CR# 330
                if(cs != null){
                    cslst.add(cs);
                }
            }
            if((pr.RecordTypeId != ZPAInteractiveRecordTypeId   && pr.Provisioning_Status__c == 'Request Decommission' && pr.Provisioning_Status__c != oldmap.get(pr.Id).Provisioning_Status__c)||(pr.Provisioning_Status__c=='Decommissioned' && pr.Provisioning_Status__c != oldmap.get(pr.Id).Provisioning_Status__c && oldmap.get(pr.Id).Provisioning_Status__c!='Request Decommission') ){
                IsDecommissionCase=true;
                Case cs = createCase(pr, ' Decommission Request for ' + pr.Name,IsPurgeCase,IsDecommissionCase,IsApprovalCase); //Added IsDecommissionCase by Gurjinder as part of CR# 330
                if(cs != null){
                    cslst.add(cs);
                }
            }
            //5a, 5b, 5c
            if((pr.RecordTypeId != oldmap.get(pr.Id).RecordTypeId || pr.Provisioning_Status__c != oldmap.get(pr.Id).Provisioning_Status__c|| pr.Approval_Status__c!= oldmap.get(pr.Id).Approval_Status__c) && (((pr.RecordTypeId == inlineRecordTypeId || pr.RecordTypeId == cbiRecordTypeId) && pr.Approval_Status__c == 'Approved') ||
                                                                                                                                                                                                               ((pr.RecordTypeId == inlineRecordTypeId || pr.RecordTypeId == cbiRecordTypeId) && (System.Label.Finance_V2_Profile_ID.contains(userInfo.getProfileId()) || userInfo.getUserId()==System.Label.PRUserIdToExcludeFromApproval || pr.GEO__c=='WW Commercial'))) && pr.Provisioning_Status__c == 'Requested' && 
               ((pr.Opportunity_Stage__c != Label.Stage_5A_Opportunity && pr.Opportunity_Stage__c != Label.Stage_5B_Opportunity && pr.Opportunity_Stage__c != Label.Stage_5C_Opportunity && pr.Opportunity_Stage__c != Label.Stage_6_Closed_Won) || pr.Account_Type__c != 'Customer')){
                   IsDecommissionCase=false;
                   IsApprovalCase=True;
                   Case cs = createCase(pr, 'A new POC has been Requested for ' + pr.Opportunity_Name__c +'  '+ pr.Name,IsPurgeCase,IsDecommissionCase,IsApprovalCase); //Added IsDecommissionCase by Gurjinder as part of CR# 330
                   if(cs != null){
                       cslst.add(cs);
                   }
               }
        }
        if(!cslst.isEmpty()){           
            insert cslst;
            TriggerUtility.CaseCreationUpdatePRExecuted();
        }
        }
        catch(Exception ex){
            ProvisioningErrorHandler.exceptionHandler('ProvisioningRequestTriggerHelper','createCasefromPRonUpdate',ex);
        }
        
        
    }
    //Changes by Gurjinder : CR# 296 : Added boolean as a parameter in Method
    //Changes by Swathi : CR# 2699 : Added boolean as a parameter in Method
    public static Case createCase(Provisioning_Request__c pr, String sub,boolean IsPurgeCase,boolean IsDecommissionCase,boolean IsApprovalCase){
        system.debug('pr '+pr);
        system.debug('sub '+sub);
        system.debug('IsPurgeCase '+IsPurgeCase);
        try{
        Map<String, DefaultData__c> ddmap = DefaultData__c.getAll();
        if(ddmap != null && !ddmap.isEmpty() && ddmap.containsKey('PRCaseCreationDefault')){
            DefaultData__c dd = ddmap.get('PRCaseCreationDefault');
            List<Contact> conlist= new List<Contact>();
            //Changes added by Gurjinder : CR# 296 :Start
            //Added IsDecommissionCase by Gurjinder as part of CR# 330
            //Added IsApprovalCase by Swathi as part of CR# CR# 2699
            if(IsDecommissionCase){
                system.debug('inside IsDecommissionCase condition');
            }
            else if((IsPurgeCase && pr.SE__c!=null) || (IsApprovalCase && pr.SE__c!=null && pr.Approval_Status__c == 'Approved') || (((pr.RecordTypeId == NFRRecordTypeId)||(pr.RecordTypeId == cbiRecordTypeId))  && pr.Product_Line_for_PR__c!=null )){
                conlist=[Select id,email from Contact where email=:pr.SE_s_Email__c and Accountid=:dd.Account_Id__c];
            }else{
                conlist=[Select id,email from Contact where email=:UserInfo.getUserEmail() and Accountid=:dd.Account_Id__c];
            }
            //Changes added by Gurjinder : CR# 296 :End
            system.debug('conlist '+conlist);
            Case cs = new Case(RecordTypeId = caseSupportRT);
            cs.Provisioning_Request__c = pr.Id;
            //cs.Product_New__c = dd.Product__c;
            if(pr.Product_Line_for_PR__c!=null && pr.Product_Line_for_PR__c=='ZPA'){
                cs.Product_New__c='ZPA';
            }
            else{
                cs.Product_New__c ='ZIA';
            }
            cs.Case_Type__c = dd.Type__c;
            cs.Case_Category__c = dd.Category__c;
            cs.Subject = sub;
            cs.Status = dd.Stage_Status__c;
            cs.Priority = dd.Priority__c;
            cs.AccountId = dd.Account_Id__c;
            String products = pr.Products__c!=null?pr.Products__c:' ';
            String comments = pr.Eval_Comments__c!=null?pr.Eval_Comments__c:' ';
            String existingTenant = pr.ZIA_Org_ID_to_be_used_for_Zapp__r.name!=null?pr.ZIA_Org_ID_to_be_used_for_Zapp__r.name:' ';
            cs.Description = 'Organisation Domain: '+pr.Organization_Domain__c+'\n'+'Preferred Cloud: '+pr.Preferred_Cloud__c
                +'\n'+'Billing Address: '+pr.Billing_Address_Country__c
                +'\n'+'Comments for provisioning team: '+comments+ '\n' +'Existing tenant id: '+existingTenant;
            
            if(!conlist.isempty()){
                cs.ContactId=conlist[0].id;
            }
            else{
                //Changes added by Gurjinder : CR# 296 :Start
                if(IsDecommissionCase){  //Added IsDecommissionCase by Gurjinder as part of CR# 330
                    String DefaultPRDecommisionContact= ZscalerCustomSetting__c.getInstance('DefaultPRDecommisionContact')!=null && ZscalerCustomSetting__c.getInstance('DefaultPRDecommisionContact').Value__c!=null ? ZscalerCustomSetting__c.getInstance('DefaultPRDecommisionContact').Value__c:'';
                    system.debug('DefaultPRDecommisionContact '+DefaultPRDecommisionContact);
                    cs.ContactId=id.valueof(DefaultPRDecommisionContact);
                }
                else if(IsPurgeCase){
                    Contact con; con= new Contact(LastName=pr.SE_Name__c,AccountId=dd.Account_Id__c,Project_Role__c='Other',LeadSource='Zscaler Employee',Email=pr.SE_s_Email__c);
                    TriggerUtility.SkipContactTriggerExecuted();
                    insert con;
                    cs.ContactId = con.id;
                }else{
                    Contact con; con= new Contact(LastName=UserInfo.getLastName(),FirstName=UserInfo.getFirstName(),AccountId=dd.Account_Id__c,Project_Role__c='Other',LeadSource='Zscaler Employee',Email=UserInfo.getUserEmail());
                    TriggerUtility.SkipContactTriggerExecuted();
                    insert con;
                    cs.ContactId = con.id;
                    //Changes added by Gurjinder : CR# 296 :End 
                }     
                
            }
            cs.Opportunity_Name__c = pr.Opportunity__c;
            return cs;
        }
        }
        catch(Exception ex){
            ProvisioningErrorHandler.exceptionHandler('ProvisioningRequestTriggerHelper','createCase',ex);
        }
        return null;
    }
    
    //Changed by Nathan : CR# 196: AmberRoad Fixes : Start
    /*public static void screenAccounts(List < Provisioning_Request__c > lstNewProvisioningRequests) {
List < Id > accountIdsToBeScreenedList = new List < Id > ();
List < Id > opportunityIdsList = new List < Id > ();
List < Account > accountsToBeScreenedList = new List < Account > ();

for (Provisioning_Request__c provisioningRequest: lstNewProvisioningRequests) {
if (null != provisioningRequest.Account__c) {
accountIdsToBeScreenedList.add(provisioningRequest.Account__c);
} 
else if (null != provisioningRequest.Opportunity__c) {
opportunityIdsList.add(provisioningRequest.Opportunity__c);
}
}

if (opportunityIdsList.size() > 0) {
for (Opportunity oppty: [SELECT Id, AccountId FROM Opportunity WHERE Id IN: opportunityIdsList]) {
accountIdsToBeScreenedList.add(oppty.AccountId);
}
}

if (!System.isFuture() && accountIdsToBeScreenedList.size() > 0) {
for (Account accountToBeScreened: [SELECT Id, Amber_Road_Status__c, BillingPostalCode, BillingState,
BillingCity, BillingCountry, BillingStreet, Fax, Name, Phone,type
FROM Account
WHERE Id IN: accountIdsToBeScreenedList
]) {
if (!Test.isRunningTest()) {
AmberRoadService.screenAccountFuture(JSON.serialize(accountToBeScreened), false, true);
}
}
}

}*/
    //Changed by Nathan : CR# 196: AmberRoad Fixes : End
    
    public static void sendProvisioningRequesttoZPA(Provisioning_Request__c zpaProvisioningRequest) {
        callOutZPAInteractive(zpaProvisioningRequest.Id);
    }
    
    @future(callout = true)
    public static void callOutZPAInteractive(Id requestId) {
        Provisioning_Request__c pr = [select id, name, Integration_Status__c from Provisioning_Request__c where id = : requestId limit 1];
        /*String endpoint = 'https://test.connect.boomi.com/ws/rest/zpa/provisioning/ZPAInteractive/';
Blob headerValue = Blob.valueOf('UserName' +':' +'Token');
String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);*/
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('requestId', requestId);
        gen.writeStringField('sourceSystem', 'salesforce');
        gen.writeStringField('sobject', 'Provisioning Request');
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        HttpRequest req = new HttpRequest();
        //req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        //req.setEndpoint(endpoint);
        req.setEndpoint('callout:ZPA_Interactive');
        req.setMethod('POST');
        req.setBody(jsonString);
        req.setTimeout(60000);
        try {
            Http http = new Http();
            if (!Test.isRunningTest()) {
                HttpResponse response = http.send(req);
                if (response.getStatusCode() == 200) {
                    pr.Integration_Status__c = 'Success';
                } 
                else {
                    pr.Integration_Status__c = 'Failed';
                    pr.FailedReason__c = response.getBody();
                }
            }
        
        update pr;
       } 
        catch (Exception e) {
            pr.Integration_Status__c = 'Failed';
            pr.FailedReason__c = e.getMessage();
            ProvisioningErrorHandler.exceptionHandler('ProvisioningRequestTriggerHelper','callOutZPAInteractive',e);

        }
    }
    public static void WorkflowOptimization(List<Provisioning_Request__c> lstNewProvisioningRequests,Map<id,Provisioning_Request__c> TriggerOLDmap,Boolean isInsert,Boolean Isupdate){
        Set<String> OppStage= new Set<String>();
        OppStage.add(label.Stage_6_Closed_Won);
        //5b
        OppStage.add(label.Stage_5B_Opportunity);
        Set<id> AccountidSet= new Set<id>();
        Set<id> OppidSet= new Set<id>();
        Set<id> PROwneridSet= new Set<id>();
        Set<id> UserIdSet = new Set<id>();//Added by Swathi :CR 2138
        Set<String> RecordTypeIdSet= new Set<String>();                
        String PRRecordTypeIdString= ZscalerCustomSetting__c.getInstance('PRRecordTypeIdString')!=null && ZscalerCustomSetting__c.getInstance('PRRecordTypeIdString').Value__c!=null ? ZscalerCustomSetting__c.getInstance('PRRecordTypeIdString').Value__c:'0120g000000grUCAAY,0120g000000N3X1AAK';
        RecordTypeIdSet.addall(PRRecordTypeIdString.split(','));
        
        for(Provisioning_Request__c pr : lstNewProvisioningRequests){
            //if(pr.Account__c!=null){
            AccountidSet.add(pr.Account__c);
            OppidSet.add(pr.Opportunity__c);
            PROwneridSet.add(pr.ownerid);
            UserIdSet.add(pr.SE__c);//Added by Swathi :CR 2138
            //}         
        }
        System.debug('UserIdSet '+UserIdSet);
        Map<id,Account>  AccountMap= new Map<id,Account>([Select id,CSM_Name_New__c,Customer_Advocate__c,Geo__c,Sales_Territory__r.Renewal_Director__c from Account where id IN:AccountidSet]);
        Map<id,Opportunity>  OppMap= new Map<id,Opportunity>([Select id,StageName,Validation_Plan__c,Opportunity.Patch__r.PatchTeam__r.Theater__c/*Added for CR1003 - Varun - Start*/,Geo_Account__c,Region_Account__c,Area__c/*Added for CR1003 - Varun - End*//*,SE_Name__c,SE_Name__r.managerid*/  from Opportunity where id IN:OppidSet]);
        Map<id,User> UserMap= new Map<id,User>([Select ManagerId,Manager.Manager.Email,Manager.ManagerId from User where id IN:UserIdSet]); //Added by Swathi :CR 2138
        //if(AccountMap!=null){
        for(Provisioning_Request__c pr : lstNewProvisioningRequests){
            //Changes to update CSM and Renewal Manager:Start
            if(pr.Account__c!=null){
                pr.Renewal__c=AccountMap.get(pr.Account__c).Customer_Advocate__c;
                pr.CSM__c=AccountMap.get(pr.Account__c).CSM_Name_New__c;
                pr.Renewal_Director__c=AccountMap.get(pr.Account__c).Sales_Territory__r.Renewal_Director__c;
            }
            //Changes to update CSM and Renewal Manager:End
            if(isInsert){
                pr.Do_not_Send_Alerts_when_Approval_Pending__c=true;
            }   
            if(Isupdate && pr.Provisioning_Status__c=='Provisioned' && TriggerOLDmap.get(pr.Id).Provisioning_Status__c!='Provisioned'){
                pr.Do_not_Send_Alerts_when_Approval_Pending__c=false;
            }       
            
            //1.Update Deployed To Production Date  :Start
            if(Isupdate && pr.Provisioning_Status__c=='Production' && TriggerOLDmap.get(pr.Id).Provisioning_Status__c!='Production'){
                pr.Deployed_To_Production_Date__c=system.today();
            }       
            //1.Update Deployed To Production Date  :End
            
            
            if(pr.Opportunity__c!=null){
                //2.Identify provisioning request created by Finance :Start
                if(isInsert && OppStage.contains(OppMap.get(pr.Opportunity__c).StageName)){
                    pr.Created_by_Finance__c=true;
                }
                //2.Identify provisioning request created by Finance :End
                
                //3.Update Tech Val Plan:Start
                if(OppMap.get(pr.Opportunity__c).Validation_Plan__c!=''){
                    pr.Technical_Validation_Plan__c=OppMap.get(pr.Opportunity__c).Validation_Plan__c;
                }
                //3.Update Tech Val Plan:End
                
                //4.Update SE director and Email in PR:Start
                //Added by Varun - CR1003  - Start 
                if(OppMap.get(pr.Opportunity__c).Geo_Account__c!=null && OppMap.get(pr.Opportunity__c).Geo_Account__c=='Americas'){
                    pr.GEO_SE_Director_Email__c= ZscalerCustomSetting__c.getInstance('GeoAmericasDirectorEmail')!=null 
                        && ZscalerCustomSetting__c.getInstance('GeoAmericasDirectorEmail').Value__c!=null ?
                        ZscalerCustomSetting__c.getInstance('GeoAmericasDirectorEmail').Value__c:'dgood@zscaler.com';
                    
                    pr.GEO_SE_Director__c= ZscalerCustomSetting__c.getInstance('GeoAmericasDirectorId')!=null 
                        && ZscalerCustomSetting__c.getInstance('GeoAmericasDirectorId').Value__c!=null ?
                        ZscalerCustomSetting__c.getInstance('GeoAmericasDirectorId').Value__c:'0050g000005dSUqAAM';
                }else if(OppMap.get(pr.Opportunity__c).Geo_Account__c!=null && OppMap.get(pr.Opportunity__c).Geo_Account__c=='Public Sector'){
                    pr.GEO_SE_Director_Email__c= ZscalerCustomSetting__c.getInstance('GeoPublicSectorDirectorEmail')!=null 
                        && ZscalerCustomSetting__c.getInstance('GeoPublicSectorDirectorEmail').Value__c!=null ?
                        ZscalerCustomSetting__c.getInstance('GeoPublicSectorDirectorEmail').Value__c:'jpadin@zscaler.com';
                    
                    pr.GEO_SE_Director__c= ZscalerCustomSetting__c.getInstance('GeoPublicSectorDirectorId')!=null 
                        && ZscalerCustomSetting__c.getInstance('GeoPublicSectorDirectorId').Value__c!=null ?
                        ZscalerCustomSetting__c.getInstance('GeoPublicSectorDirectorId').Value__c:'0050g0000066IlVAAU';
                }else if((OppMap.get(pr.Opportunity__c).Region_Account__c!=null && OppMap.get(pr.Opportunity__c).Region_Account__c.containsIgnoreCase('EMEA')) ||
                         (OppMap.get(pr.Opportunity__c).Area__c!=null && OppMap.get(pr.Opportunity__c).Area__c.containsIgnoreCase('EMEA')) ){
                             pr.GEO_SE_Director_Email__c= ZscalerCustomSetting__c.getInstance('GeoAreaEmeaDirectorEmail')!=null 
                                 && ZscalerCustomSetting__c.getInstance('GeoAreaEmeaDirectorEmail').Value__c!=null ?
                                 ZscalerCustomSetting__c.getInstance('GeoAreaEmeaDirectorEmail').Value__c:'dphillips@zscaler.com';
                             
                             pr.GEO_SE_Director__c= ZscalerCustomSetting__c.getInstance('GeoAreaEmeaDirectorId')!=null 
                                 && ZscalerCustomSetting__c.getInstance('GeoAreaEmeaDirectorId').Value__c!=null ?
                                 ZscalerCustomSetting__c.getInstance('GeoAreaEmeaDirectorId').Value__c:'0050g000005dMKQAA2';
                         }else if((OppMap.get(pr.Opportunity__c).Region_Account__c!=null && OppMap.get(pr.Opportunity__c).Region_Account__c.containsIgnoreCase('APJ')) ||
                                  (OppMap.get(pr.Opportunity__c).Area__c!=null && OppMap.get(pr.Opportunity__c).Area__c.containsIgnoreCase('APJ')) ){
                                      pr.GEO_SE_Director_Email__c= ZscalerCustomSetting__c.getInstance('GeoAreaApjDirectorEmail')!=null 
                                          && ZscalerCustomSetting__c.getInstance('GeoAreaApjDirectorEmail').Value__c!=null ?
                                          ZscalerCustomSetting__c.getInstance('GeoAreaApjDirectorEmail').Value__c:'echan@zscaler.com';
                                      
                                      pr.GEO_SE_Director__c= ZscalerCustomSetting__c.getInstance('GeoAreaApjDirectorId')!=null 
                                          && ZscalerCustomSetting__c.getInstance('GeoAreaApjDirectorId').Value__c!=null ?
                                          ZscalerCustomSetting__c.getInstance('GeoAreaApjDirectorId').Value__c:'0054u000006bwACAAY';
                                  }//Added by Varun - CR1003  - End
                else{
                    pr.GEO_SE_Director_Email__c=null;
                }
                //}
                
                //4.Update SE director email in PR:End
                /**system.debug('pr.Opp_SE_Manager__c  '+pr.Opp_SE_Manager__c);
if(OppMap.get(pr.Opportunity__c).SE_Name__c!=null){
pr.Opp_SE__c=OppMap.get(pr.Opportunity__c).SE_Name__c;
pr.Opp_SE_Manager__c=OppMap.get(pr.Opportunity__c).SE_Name__r.managerid;
}
system.debug('pr.Opp_SE_Manager__c  '+pr.Opp_SE_Manager__c);**/
            }
            
            //6 .Update decomm date:Start
            if(pr.Provisioning_Status__c=='Decommissioned' && TriggerOLDmap.get(pr.Id).Provisioning_Status__c!='Decommissioned'){
                pr.Decomm_Req_date__c=system.today();
            }   
            //6 .Update decomm date:End
            
            //7 .Set detailed record type:Start
            //if((pr.Provisioning_Status__c=='Provisioned' || pr.Provisioning_Status__c=='In Progress')  && pr.RecordTypeid=='01270000000QB3aAAG' /* && RecordType.DeveloperName=='New_Eval' */){
            //pr.RecordType='Zscaler Cloud Details';
            //pr.RecordTypeid=' 01270000000EABCAA4';  //Zscaler Cloud Details 
            //pr.RecordTypeid='01270000000QB3aAAG';
            //}
            //7 .Set detailed record type:End
            
            //8.Update GEO SE Leadership Alias  :Start
            if(AccountMap!=null && AccountMap.containskey(pr.Account__c) && AccountMap.get(pr.Account__c).Geo__c!=null && AccountMap.get(pr.Account__c).Geo__c=='AMERICAS'){
                pr.GEO_SE_Leadership_Alias__c='sales-na-poc-notifications@zscaler.com';
            }
            //8.Update GEO SE Leadership Alias  :End
            
            system.debug('pr.RecordTypeid   '+pr.RecordTypeid);
            system.debug('inside provisioning date'+pr.Provisioning_Date__c);
            if(Isupdate && pr.Provisioning_Status__c=='Provisioned' && TriggerOLDmap.get(pr.Id).Provisioning_Status__c!='Provisioned' && pr.Number_of_Extensions__c<2 && !RecordTypeIdSet.contains(String.valueof(pr.RecordTypeid))){
                pr.Provisioning_Date__c=system.today();
            }  
            
            //9.Update PR Expiry date   :Start
            system.debug('inside provisioning date'+pr.Provisioning_Date__c);
            if(Isupdate && pr.Provisioning_Date__c != null && pr.Provisioning_Date__c != TriggerOLDmap.get(pr.Id).Provisioning_Date__c && pr.Preferred_Cloud__c!='Zscalerbeta.net' && pr.Account_Type__c!='Partner'){
                system.debug('inside provisioning date');
                pr.Provisioning_Request_Expiry_Date__c=pr.Provisioning_Date__c+30;
            }
            //9.Update PR Expiry date   :End
            
            if(Isupdate && pr.Confirmation_from_Customer_to_Purge_Data__c==true && TriggerOLDmap.get(pr.Id).Confirmation_from_Customer_to_Purge_Data__c==false){
                pr.Provisioning_Status__c='To be Purged';
                pr.Approval_for_Purge_Status__c='Submitted for Purge Approval';
            }
            //Added by Swathi :CR 2138 Start
            if((isInsert && pr.SE__c!=Null) || (Isupdate && pr.SE__c!=TriggerOLDmap.get(pr.Id).SE__c && UserMap.containsKey(pr.SE__c))){
                pr.SE_Manager__c=UserMap.get(pr.SE__c).ManagerId;
                pr.Sales_Engineering_Director__c= UserMap.get(pr.SE__c).Manager.ManagerId;
            }
            //Added by Swathi :CR 2138 End
            
        }           
        
        //}
        
    }
    //CR# 1920 Start
    public static void updateNFRLinks(List < Provisioning_Request__c > newList) {
        List<NFR__c> NFRList = new List<NFR__c>();
        Map<Id, List<Provisioning_Request__c>> NFRIdPRMap = new Map<Id, List<Provisioning_Request__c>>();
        try{
        for(Provisioning_Request__c pr : newList){
            if(pr.RecordTypeId == NFRRecordTypeId || (pr.RecordTypeId == cbiRecordTypeId && pr.Product_Line_for_PR__c == 'CBI')){
                if(!NFRIdPRMap.containsKey(pr.NFR_Form_Link__c)){
                    NFRIdPRMap.put(pr.NFR_Form_Link__c, new List<Provisioning_Request__c>());
                }
                NFRIdPRMap.get(pr.NFR_Form_Link__c).add(pr);
            }
            System.debug('NFRIdPRMap'+NFRIdPRMap);
        }
        for(NFR__c nfr : [Select Id,ZIA_PR__c,ZPA_PR__c,ZDX_PR__c,Z_CBI_PR__c from NFR__c where id IN : NFRIdPRMap.keyset()]){
            for(Provisioning_Request__c pr: NFRIdPRMap.get(nfr.id)){
                System.debug('pr.ID'+pr.ID);
                if(pr.Product_Line_for_PR__c=='ZIA'){
                    nfr.ZIA_PR__c=pr.ID;
                }
                if(pr.Product_Line_for_PR__c=='ZPA'){
                    nfr.ZPA_PR__c=pr.ID;
                }
                if(pr.Product_Line_for_PR__c=='ZDX'){
                    nfr.ZDX_PR__c=pr.ID;
                }
                if(pr.Product_Line_for_PR__c=='CBI'){
                    nfr.Z_CBI_PR__c=pr.ID;
                }
            }
            NFRList.add(nfr);
        }
        if(!NFRList.isEmpty()){
            update NFRList; 
        }
        TriggerUtility2.PRNFRFieldInsertExecuted();
        }catch(Exception ex){
            ProvisioningErrorHandler.exceptionHandler('ProvisioningRequestTriggerHelper','updateNFRLinks',ex);
        }
    }
    
    public static void updateNFRFields(List < Provisioning_Request__c > newList, Map<Id, Provisioning_Request__c> oldmap) {
        
        List<NFR__c> NFRList = new List<NFR__c>();
        
        
        Map<Id, NFR__c> mapOfPRAndDetails =  new Map<Id, NFR__c>();
        
        Set<ID> NFRIdSet = new Set<ID>();
        
        try{
        for(Provisioning_Request__c pr : newList){
            
            
            NFR__c NFRRecord =  mapOfPRAndDetails.containsKey(pr.NFR_Form_Link__c) ? mapOfPRAndDetails.get(pr.NFR_Form_Link__c) : new NFR__c();
            
            if(pr.RecordTypeId == NFRRecordTypeId || (pr.RecordTypeId == cbiRecordTypeId && pr.Product_Line_for_PR__c!=Null &&  pr.Product_Line_for_PR__c=='CBI' && pr.NFR_Form_Link__c!=null)){
                //NFR__c NFRRecord = new NFR__c();
                NFRRecord.Id = pr.NFR_Form_Link__c;
                if(oldmap!=Null && pr.ZIA_Org_ID__c!=Null && pr.ZIA_Org_ID__c!=oldmap.get(pr.Id).ZIA_Org_ID__c && (pr.Provisioning_Status__c!=Null && pr.Provisioning_Status__c=='Provisioned')){
                    NFRRecord.ZIA_Org_ID__c=pr.ZIA_Org_ID__c;
                }
                if(oldmap!=Null && pr.ZPA_Org_ID__c!=Null && pr.ZPA_Org_ID__c!=oldmap.get(pr.Id).ZPA_Org_ID__c && (pr.Provisioning_Status__c!=Null && pr.Provisioning_Status__c=='Provisioned')){
                    NFRRecord.ZPA_Org_ID__c=pr.ZPA_Org_ID__c;
                }
                if(pr.Additional_Organization_domains__c!=Null && pr.Additional_Organization_domains__c!=oldmap.get(pr.Id).Additional_Organization_domains__c){
                    NFRRecord.Additional_Organisation_Domain__c=pr.Additional_Organization_domains__c;
                }
                if(pr.Account__c!=Null && pr.Account__c!=oldmap.get(pr.Id).Account__c){
                    NFRRecord.Account_Name__c=pr.Account__c;
                }
                if(pr.NFR_SE_Email_PR__c!=Null && pr.NFR_SE_Email_PR__c!=oldmap.get(pr.Id).NFR_SE_Email_PR__c){
                    NFRRecord.NFR_SE_Email__c=pr.NFR_SE_Email_PR__c;
                }
                if(pr.Number_of_Users__c!=Null && pr.Number_of_Users__c!=oldmap.get(pr.Id).Number_of_Users__c){
                    NFRRecord.Number_of_Users__c=pr.Number_of_Users__c;
                }
                if(pr.Organization_Domain__c!=Null && pr.Organization_Domain__c!=oldmap.get(pr.Id).Organization_Domain__c){
                    NFRRecord.Organisation_Domain__c=pr.Organization_Domain__c;
                }
                if(pr.Partner_Contact__c!=Null && pr.Partner_Contact__c!=oldmap.get(pr.Id).Partner_Contact__c){
                    NFRRecord.Partner_Contact__c=pr.Partner_Contact__r.Id;
                }
                if(pr.Preferred_Cloud__c!=Null && pr.Preferred_Cloud__c!=oldmap.get(pr.Id).Preferred_Cloud__c){
                    NFRRecord.Preferred_Cloud__c=pr.Preferred_Cloud__c;
                }
                if(pr.SE__c!=Null && pr.SE__c!=oldmap.get(pr.Id).SE__c){
                    NFRRecord.NFR_Sales_Engineer__c=pr.SE__c;
                    NFRRecord.NFR_SE_Email__c=pr.SE_s_Email__c;
                }
                if(pr.Eval_Comments__c!=Null && pr.Eval_Comments__c!=oldmap.get(pr.Id).Eval_Comments__c){
                    NFRRecord.Comments__c=pr.Eval_Comments__c;
                }
                if(pr.Send_Initial_l__c!=Null && pr.Send_Initial_l__c!=oldmap.get(pr.Id).Send_Initial_l__c){
                    NFRRecord.Send_Initial_Credentials_To__c=pr.Send_Initial_l__c;
                }
                if(pr.User_Authentication_Domains__c!=Null && pr.User_Authentication_Domains__c!=oldmap.get(pr.Id).User_Authentication_Domains__c){
                    NFRRecord.User_Authentication_Domains__c=pr.User_Authentication_Domains__c;
                }
                if(pr.Is_Customer_Using_ZIA__c!=Null && pr.Is_Customer_Using_ZIA__c!=oldmap.get(pr.Id).Is_Customer_Using_ZIA__c){
                    NFRRecord.Is_Customer_Using_ZIA__c=pr.Is_Customer_Using_ZIA__c;
                }
                if(pr.Is_Zapp_used__c!=Null && pr.Is_Zapp_used__c!=oldmap.get(pr.Id).Is_Zapp_used__c){
                    NFRRecord.Is_Zapp_used__c=pr.Is_Zapp_used__c;
                }
                if(pr.Provisioning_Status__c!=Null && pr.Provisioning_Status__c=='Provisioned' && pr.Provisioning_Status__c!=oldmap.get(pr.Id).Provisioning_Status__c && pr.Product_Line_for_PR__c!=Null && pr.Product_Line_for_PR__c=='CBI'){
                    NFRRecord.Z_CBI_Provisioned__c=True;
                }
                if(pr.Provisioning_Status__c!=Null && pr.Provisioning_Status__c=='Provisioned' && pr.Provisioning_Status__c!=oldmap.get(pr.Id).Provisioning_Status__c && pr.Product_Line_for_PR__c!=Null && pr.Product_Line_for_PR__c=='ZDX'){
                    NFRRecord.ZDX_Provisioned__c=True;
                }
                NFRList.add(NFRRecord);
                
                
                mapOfPRAndDetails.put(pr.NFR_Form_Link__c, NFRRecord);  
            }
            
            
        }
        if(!NFRList.isEmpty()){
            //update NFRList; 
            
            UPDATE mapOfPRAndDetails.values();
        }
        TriggerUtility2.PRNFRFieldUpdateExecuted();
        }catch(Exception ex){
            ProvisioningErrorHandler.exceptionHandler('ProvisioningRequestTriggerHelper','updateNFRFields',ex);
        }
    }
    //CR# 1920 END
    
    /**
private static void updateCaseDescription(Set < Id > provIdSet) {
List<Case> caseListToUpdate = new List<Case>();

for (Case cs : [SELECT Id, Description, Provisioning_Request__r.Organization_Domain__c,
Provisioning_Request__r.Preferred_Cloud__c,
Provisioning_Request__r.Products__c,
Provisioning_Request__r.Billing_Address_Country__c,
Provisioning_Request__r.Eval_Comments__c,
Provisioning_Request__r.ZIA_Org_ID_to_be_used_for_Zapp__r.name
FROM Case WHERE Provisioning_Request__c IN :provIdSet]) {

cs.Description = 'Organisation Domain: '+cs.Provisioning_Request__r.Organization_Domain__c+'\n'+'Preferred Cloud: '+cs.Provisioning_Request__r.Preferred_Cloud__c
+'\n'+'Product/SKU: '+cs.Provisioning_Request__r.Products__c+'\n'+'Billing Address: '+cs.Provisioning_Request__r.Billing_Address_Country__c
+'\n'+'Comments for provisioning team: '+cs.Provisioning_Request__r.Eval_Comments__c+ '\n' +'Existing tenant id: '+cs.Provisioning_Request__r.ZIA_Org_ID_to_be_used_for_Zapp__r.name;


caseListToUpdate.add(cs);

}

UPDATE caseListToUpdate;
}*/
    
    //Set Auto Genrated Password - IBA-1753
    Public static void autoGeneratePassword(List<Provisioning_Request__c> newlist){
        for(Provisioning_Request__c pdir : newlist){
            if(pdir.password__c == null){
                pdir.password__c = autoGenerate(10);
            }
        }
    }
    
    public static String autoGenerate(Integer getLength){
        String charString = '@#nopqrstuvwABCDPQRSTUVWXYZ0123456789abcdefghijkEFGHIJKLMNOlmxyz';
        String randomNew = '';
        while (randomNew .length() < getLength){
            Integer changeInt = Math.mod(Math.abs(Crypto.getRandomInteger()), charString.length());
            randomNew += charString.substring(changeInt , changeInt +1);
        }
        return randomNew;
    }
}