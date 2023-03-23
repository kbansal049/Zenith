/////This class  will sync commercial to Fed four Account fields. 
@RestResource(urlMapping='/DEALREGSYNC/*')
global without sharing class DEALREGSYNCTOFED{
    global static Boolean avoidtriggers = false;
    
    /////This method will sync commercial to Fed all deal reg fields. 
    @HttpGet
    global static Map<String, String> doGet() {
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();
        List<Deal_Reg__c> listDeals = [SELECT Renewal_Opportunity_Owner__c,  Sales_Territory__c, Renewal_Opportunity__c, Customer_Role_And_Title__c, GEO_VP__c,   Area_Director__c, GEO__c,Partner_Contact_Last_Name__c, Channel_Manager__c, Channel_Manager_2__c,Channel_Manager_3__c,Channel_Manager_4__c,Channel_Manager_5__c,End_Customer_Contact_Name__c, End_Customer_Contact_Last_Name__c,Expiration_Requested_By__c, Id, Partner_Account_Owner_Email__c, Partner_Account_Program__c, Partner_Account_SE_Email__c,Account_Manager__c, Partner_Account_Id__c,Partner_Account__c,Partner_Alternate_Email_1__c,Partner_Alternate_Email_2__c, Partner_Alternate_Email_3__c, Partner_Category__c,Partner_Contact_Email__c,Partner_Contact_Name__c,Partner_Country__c, Partner_Domain__c, Partner_Phone__c,Partner_State__c,Partner_Type__c,Expiration_Requested_Date__c, Reason_for_Expiration__c, Product_Areas__c, End_Customer_Postal_Code__c, POV_Partner_Intent__c, Area__c,Channel_Manager_Phone__c,Security_ISA_Email__c,Security_ISA_Name__c,Send_to_FedRAMP__c,Send_to_FedRAMP_Date__c, Sub_Region__c, Source__c,Tech_Partner_Geo_Email__c, Territory_Name__c, Territory_Type__c,End_Customer_City__c,End_Customer_Street_Address__c, End_Customer_TC_Street_Address__c ,Learn_how_to_Convert_Deal_Registration__c,Partner_Company_Name__c, Number_of_Users__c,Market_Segment__c,Estimated_Amount__c, End_Customer_State__c,End_Customer_Phone__c, End_Customer_Name__c,End_Customer_Email__c, End_Customer_Domain__c, End_Customer_Country__c, Deal_Description__c, Account_Manager_Phone__c, Comments__c, DS_Review_Status__c, Name,Expected_Close_Date__c,Deal_Reg_Expiration_Date__c,Deal_Reg_Type__c,Expiration_Date__c,Status__c,Discovery_Meeting_Date__c,NBM_Meeting_Date__c,IsDeleted,Record_Type_Name__c , RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate from Deal_Reg__c where Send_to_FedRAMP_Date__c = null and Federal_Deal_Approved_OP__c = true and status__c = 'Pending Review'];
        List<Deal_Reg__c> deallst = new List<Deal_Reg__c>();
        		for(Deal_Reg__c deal: listDeals){
                    deallst.add(deal);
                }
                system.debug(deallst);
                if(!deallst.isEmpty()){
                    result.put('dealresults', JSON.serialize(deallst));
                }
        System.debug('result: '+ result);
        List<Deal_Reg__c> listReg = [SELECT Id, Name, Status__c, IsDeleted, Record_Type_Name__c,  RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate from Deal_Reg__c where Send_to_FedRAMP_Date__c = null];
        return result;
    }
    
    
     /////This method will sync Fed deal reg to comme  for status and dates 
    @HttpPost
    global static String doPost(List<String> listName, Map<String, String> mapNameStatus , Map<String, String> mapNameDealType, Map<String, DateTime> mapNameDealExpire, Map<String, String> mapNameDealApprovalStatus, List<String> TargetCommDeal , List<String> TargetCommDealStatus  ){
        
        String status = 'Pass';
        System.debug('listName' +  listName );
        System.debug('mapNameStatus' +  mapNameStatus );
        System.debug('mapNameDealType' +  mapNameDealType );
        System.debug('mapNameDealExpire' +  mapNameDealExpire );
        System.debug('mapNameDealApprovalStatus' +  mapNameDealApprovalStatus );

        List<String> successListNames = new List<String>();
        List<String> errorListNames = new List<String>();    
        try{
            if (mapNameStatus != null){
            List<Deal_Reg__c> listDealStatusUp = [SELECT Approval_Status__c, Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c, Name, Send_to_FedRAMP_Date__c, Status__c, IsDeleted, Record_Type_Name__c,  RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate from Deal_Reg__c where Name in :mapNameStatus.keySet()];
            System.debug('listDealStatusUp' +  listDealStatusUp );
            // Added 'Approved' to add one extra status to the deal reg status//
            for (Deal_Reg__c dealUpdate : listDealStatusUp){
                if (mapNameStatus.get(dealUpdate.Name) == 'Converted' || mapNameStatus.get(dealUpdate.Name) == 'Rejected' ||  mapNameStatus.get(dealUpdate.Name) == 'Approved' ){
                	dealUpdate.Status__c = mapNameStatus.get(dealUpdate.Name);
                    }
                }
                for (Deal_Reg__c dealUpdate : listDealStatusUp){
                    if (mapNameStatus.get(dealUpdate.Name) != 'Converted'){
                        dealUpdate.Deal_Reg_Type__c = mapNameDealType.get(dealUpdate.Name);
                        dealUpdate.Deal_Reg_Expiration_Date__c = mapNameDealExpire.get(dealUpdate.Name);
                        dealUpdate.Approval_Status__c = mapNameDealApprovalStatus.get(dealUpdate.Name);

                    }
                }
           System.debug('listDealStatusUp' +  listDealStatusUp );
           List<String> accerrorlst = new List<String>();
           List<String> accsuccesslst = new List<String>();
           Database.SaveResult[] acctSRList = database.update(listDealStatusUp,false);  
                        System.debug('acctSRList->' + acctSRList);

                        for (Database.SaveResult accountSaveResult : acctSRList) {
                            if (accountSaveResult.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                accsuccesslst.add(accountSaveResult.getId());
                            }                    
                            else {
                                for(Database.Error err : accountSaveResult.getErrors()){
                                    String s = '';
                                    if(acctSRList.indexOf(accountSaveResult) != -1 && !listDealStatusUp.isEmpty() && listDealStatusUp.size() > acctSRList.indexOf(accountSaveResult) && listDealStatusUp[acctSRList.indexOf(accountSaveResult)] != null){
                                        s = listDealStatusUp[acctSRList.indexOf(accountSaveResult)].Id;
                                    }
                                    accerrorlst.add(s + ' - ' + err.getMessage());
                                }
                            }   
                          
                            
                        }
                    List<Deal_Reg__c> nowlistDealStatusUp = [SELECT Deal_Reg_Type__c, Deal_Reg_Expiration_Date__c, Name, Send_to_FedRAMP_Date__c, Status__c, IsDeleted, Record_Type_Name__c,  RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate from Deal_Reg__c where Name in :mapNameStatus.keySet()];
                    System.debug('nowlistDealStatusUp->' + nowlistDealStatusUp);
                    System.debug('accsuccesslst->' + accsuccesslst);
                    System.debug('accerrorlst->' + accerrorlst);            

           }
         }catch(Exception e){
                System.debug('in catch :' + e.getStackTraceString() + e.getMessage());
          }
        try{
            List<Deal_Reg__c> listDealUpdates = [SELECT Name, Send_to_FedRAMP_Date__c, Status__c, IsDeleted, Record_Type_Name__c,  RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate from Deal_Reg__c where Name in :listName];
            System.debug('listDealUpdates->' + listDealUpdates);  
            for(Deal_Reg__c opp: listDealUpdates){
                if(mapNameStatus.get(opp.Name) == 'Sales Ops Pending Review'){
                    opp.Send_to_FedRAMP_Date__c = Datetime.now();
                    opp.Send_to_FedRAMP__c = 'Done';
                    successListNames.add(opp.Name);
                    System.debug('Date updated->' + Datetime.now());  
                    System.debug('Date updated->' + opp.Send_to_FedRAMP_Date__c); 
                }
            }
            List<Deal_Reg__c> listDealError = [SELECT Name, Status__c, IsDeleted, Record_Type_Name__c,  RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate from Deal_Reg__c where Send_to_FedRAMP_Date__c = null];
            for(Deal_Reg__c opp: listDealError){
                    errorListNames.add(opp.Name);
                }    
                List<String> accerrorlst = new List<String>();
                List<String> accsuccesslst = new List<String>();
            System.debug('listDealUpdates->' + listDealUpdates);
            try{            
                if (listDealUpdates!=null){
                    Database.SaveResult[] acctSRList = database.update(listDealUpdates,false);  
                    System.debug('acctSRList->' + acctSRList);
                    
                    for (Database.SaveResult accountSaveResult : acctSRList) {
                            if (accountSaveResult.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                accsuccesslst.add(accountSaveResult.getId());
                            }                    
                      /* else {
                                for(Database.Error err : accountSaveResult.getErrors()){
                                    String s = '';
                                    if(acctSRList.indexOf(accountSaveResult) != -1 && !listDealUpdates.isEmpty() && listDealUpdates.size() > acctSRList.indexOf(accountSaveResult) && listDealUpdates[acctSRList.indexOf(accountSaveResult)] != null){
                                        s = listDealUpdates[acctSRList.indexOf(accountSaveResult)].Id;
                                    }
                                    accerrorlst.add(s + ' - ' + err.getMessage());
                                }
                            }                    
                      */                
                    }
                }
                List<Deal_Reg__c> nowlistDealUpdates = [SELECT Name, Send_to_FedRAMP_Date__c, Status__c, IsDeleted, Record_Type_Name__c,  RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate from Deal_Reg__c where Name in :listName];
                System.debug('nowlistDealUpdates->' + nowlistDealUpdates);
                System.debug('accsuccesslst->' + accsuccesslst);
                System.debug('accerrorlst->' + accerrorlst);            
            }
            catch(Exception e){
                System.debug('in catch listDealUpdates:='+ e.getMessage()+ e.getStackTraceString());
            }       
            System.debug('successListNames'+successListNames);
            System.debug('errorListNames'+errorListNames);
            
           
            //Update the Approval flow in Comm-SFDC.com
            try{
                if (!TargetCommDealStatus.isEmpty()){
                    if (TargetCommDealStatus[0]=='Approved' || TargetCommDealStatus[0]=='Rejected' ){
                        System.debug('TargetCommDeal:=' +  TargetCommDeal);
                        System.debug('TargetCommDealStatus:=' +  TargetCommDealStatus);
                        approveRejectRecord(TargetCommDeal[0], TargetCommDealStatus[0]);
                    }
                }
            }
            catch(Exception e){
                System.debug('in catch approval flow not updated'+ e.getMessage()+ e.getStackTraceString());
            }
            //Update the Approval flow in Comm
            
            
            /*
            try{
                //send email with results
                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
                if(errorListNames.size()>0){
                    mail1.setSubject(' Deal Reg  Pushed to Fed success result');
                    mail1.setPlainTextBody('The following deals have sent to Fed. \n\n  Deals Pushed:\n' + successListNames);
                }else{
                    mail1.setSubject('Deal Reg  Pushed to Fed Failure result');
                    mail1.setPlainTextBody('The following deals could not been sent to Fed. \n\n  Deals could not being Pushed:\n' + accerrorlst);
                }
                messageList.add(mail1);
                Messaging.sendEmail(messageList); 
            }
            catch(Exception e){
                System.debug('in catch :='+ e.getMessage()+ e.getStackTraceString());
            }
           */
                for(Deal_Reg__c opp: listDealUpdates){
                    System.debug('opp.Send_to_FedRAMP_Date__c:='+opp.Send_to_FedRAMP_Date__c );
                }  
                System.debug('listDealUpdates: '+ listDealUpdates);
            }
            catch(Exception e){
                status = null;
                System.debug('in catch :='+ e.getMessage()+ e.getStackTraceString());
            }
            return status ;
        }
    
    
   public static void approveRejectRecord(String CommDealId, String TargetCommDealStatus)
    {
        System.debug('CommDealId: '+ CommDealId);
        System.debug('TargetCommDealStatus: '+ TargetCommDealStatus);


        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        if (TargetCommDealStatus == 'Approved'){
            req.setComments('Deal Reg Approved in SFDC.gov');
            req.setAction('Approve');
        }
        if (TargetCommDealStatus == 'Rejected'){
            req.setComments('Deal Reg Rejected in SFDC.gov');
            req.setAction('Reject');
        }
       
        Deal_Reg__c deal = [select Id , name from Deal_Reg__c where id =:CommDealId limit 1];
        Id workItemId = getWorkItemId(deal.Id);
        req.setWorkitemId(workItemId);
        Approval.ProcessResult result =  Approval.process(req);

    }

    public static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =:targetObjectId])
        {
            retVal  =  workItem.Id;
        }
        return retVal;
    }

}