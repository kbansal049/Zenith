public without sharing class PODetailTriggerUtility {
    
    public static void autoPopulateBOTMail(List<PO_Detail__c> poList){
        //before Insert || before Update
        if(poList != null && poList.size()>0){          
            for(PO_Detail__c pod : poList){
                if(pod.BOT_Email__c == null){
                    pod.BOT_Email__c = Label.Orders_Mail_Box;
                }
            }
        } 
    }
    
    
    //For Each PO record Auto Populate the Opportunity record based on the Proposal #
    public static void autoPopulateOpportunityBasedOnQuoteNumber(List<PO_Detail__c> poList, MAP<Id, PO_Detail__c> oldMAP){
        
        //before Insert || before Update
        if(poList != null && poList.size()>0){
            Set<String> quoteNames = new Set<String>();
            for(PO_Detail__c pod : poList){
                if(pod.Proposal_Quote_Number__c != null){
                    //Is Insert
                    if(oldMAP == null){   
                        quoteNames.add(pod.Proposal_Quote_Number__c); 
                    }
                    //Is Update
                    else if(pod.Id != null && pod.Proposal_Quote_Number__c != oldMAP.get(pod.Id).Proposal_Quote_Number__c){
                        quoteNames.add(pod.Proposal_Quote_Number__c); 
                    }
                }
            }
            System.debug('---quoteNames---'+quoteNames);
            
            if(quoteNames.size()>0){
                
                MAP<String, ID> quoteOppMAP = new MAP<String, ID>();

                //Fill CPQ Quotes
                for(SBQQ__Quote__c cpqQuote :  getALLDataCPQ(quoteNames)){
                    quoteOppMAP.put(cpqQuote.name.toLowerCase() , cpqQuote.SBQQ__Opportunity2__c);
                }
                
                System.debug('---quoteOppMAP---'+quoteOppMAP);
                
                
                MAP<Id, Opportunity> oppMAP = new MAP<ID,Opportunity>([Select iD,Name,PO_Source__c,Owner.email,Business_Champion_Contact__c,
                                                                       Business_Champion_Contact__r.email from opportunity where id in : quoteOppMAP.values()]);
                
                System.debug('---oppMAP---'+oppMAP); 
                for(PO_Detail__c pod : poList){
                    //Fill opportunity Id based on the QuoteNumber
                    if(pod.Proposal_Quote_Number__c != null && quoteOppMAP.containskey(pod.Proposal_Quote_Number__c.tolowercase())){
                        pod.Opportunity__c = quoteOppMAP.get(pod.Proposal_Quote_Number__c.tolowercase());
                    }
                    
                    //Fill Opportunity details on PO
                    if(pod.Opportunity__c != null && oppMAP.containskey(pod.Opportunity__c)){
                        Opportunity opRecord = oppMAP.get(pod.Opportunity__c);
                        pod.Opportunity_Owner_Email__c = opRecord.Owner.email;
                        pod.Opportunity_Sales_Rep_Email__c = opRecord.Business_Champion_Contact__r != null ? opRecord.Business_Champion_Contact__r.email  : null;
                    }
                }
            }
        }   
    }
    
    
    public static void autoPopulateTrackerRecord(List<PO_Detail__c> poList){
        List<Po_Detail__c> lstPo = new List<Po_Detail__c>();
        Set<String> accountNameSet = new Set<String>(); 
        Set<String> poIdsSet = new Set<String>();
        Set<String> poIds = new Set<String>();
        if(poList != null && poList.size()>0){
            for(PO_Detail__c pod : poList){
                if(pod.Order_Tracker__c == NULL){
                    if(pod.Client_Name__c != NULL && pod.PO_Number__c != NULL){
                        accountNameSet.add(pod.Client_Name__c);
                        poIds.add(pod.PO_Number__c);
                        poIdsSet.add(pod.Id);
                    }
                }
            }
            //MAP<Id, Order_Tracker__c> opportunityOrdrTrackerMap = getOrderTrcakerMAP(oppIds);
            if(poIds != NULL && poIds.size() >0 && accountNameSet != NULL && accountNameSet.size() >0){
                lstPo = [SELECT Id,PO_Number__c,Opportunity__c,Version_Number__c, Status__c,End_Client_Name__c, Proposal_Quote_Number__c, Order_Tracker_Thread_ID__c,Name,Order_Tracker__c FROM PO_Detail__c
                         WHERE PO_Number__c IN : poIds AND Client_Name__c IN :accountNameSet AND ID NOT IN : poIdsSet 
                         ORDER BY Version_Number__c Desc  NULLS Last LIMIT 1] ;
            }
            MAP<ID, PO_Detail__c> updatePoMAP = new MAP<ID, PO_Detail__c>();
            
            List<PO_Detail__c> createTrackerRecord = new List<PO_Detail__c>();
            for(PO_Detail__c pod : poList){
                //if alredy Tracker Record Exist with the client name and po number
                if(pod.Order_Tracker__c == NULL 
                   && lstPo != NULL && lstPo.size() > 0
                   && pod.PO_Number__c.equalsignoreCase( lstPo[0].PO_Number__c))
                {
                    PO_Detail__c podnew = new PO_Detail__c();
                    podnew.Id= pod.id;
                    podnew.PO_Number__c = pod.PO_Number__c;	
                    podnew.Opportunity__c = pod.Opportunity__c;
                    podnew.Order_Tracker__c = lstPo[0].Order_Tracker__c;
                    podnew.Client_Name__c = pod.Client_Name__c;
                    updatePoMAP.put(pod.Id, podnew);
                }   
                //if No Tracker Record Exist with the client name and po number
                else if(pod.Order_Tracker__c == null){
                    createTrackerRecord.add(pod);
                }
            }
            
            System.debug('-----updatePoMAP---'+updatePoMAP.values());
            
            //Createorder Tracker Record in Case of not avilable
            if(createTrackerRecord.size()>0){
                createOrderTrackerRecordForPO(createTrackerRecord, updatePoMAP);
            }
            
            update updatePoMAP.values();
            // since a new version will be created everytime, change the OT with the new po
            updateOrderTrackerWithNewPo(updatePoMAP);
            // update new version on the po record	
            updatePoDetailVersion(updatePoMAP);
        }
        
    }
    
    public static void sendEmail(List<PO_Detail__c> updatedPo, MAP<ID, PO_Detail__c> updatePoMAP){
        List<Id> opportunityList = new List<Id>();
        Map<Id,OpportunitySplit> mapOfOpptyWithOpptySplit= new Map<Id,OpportunitySplit>();
        Map<Id,Set<String>> mapOfOpptyWithSplitTeamEmail = new Map<Id,Set<String>>();
        
        for(PO_Detail__c pod : updatedPo){ 
            //send email only for current record in context
            if(pod.Opportunity__c != NULL && updatePoMAP.get(pod.Id) != NULL){
                opportunityList.add(pod.Opportunity__c);
            }
        }
        Map<Id,Opportunity> mapOfOpportunity = new Map<Id,Opportunity>([Select id,Account.Name,Amount,owner.email,Account.Owner.Email,Opportunity_Channel_Manager__r.Email from opportunity where id IN : opportunityList]);
        List<OpportunitySplit> oppTeammemeberList = [Select id,OpportunityId,SplitOwnerID,SplitOwner.Email,SplitOwner.Manager.Email from OpportunitySplit where OpportunityId IN : opportunityList];
        //Set CC
        for(OpportunitySplit oppMem : oppTeammemeberList){
            if(oppMem.OpportunityId != NULL) {
                if(mapOfOpptyWithSplitTeamEmail.get(oppMem.OpportunityId) != NULL){
                    mapOfOpptyWithSplitTeamEmail.get(oppMem.OpportunityId).add(oppMem.SplitOwner.Email);
                }
                else{
                    mapOfOpptyWithSplitTeamEmail.put(oppMem.OpportunityId, new Set<String>());
                    mapOfOpptyWithSplitTeamEmail.get(oppMem.OpportunityId).add(oppMem.SplitOwner.Email);
                }
            }
        }
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<String> toEmailList;
        for(PO_Detail__c pod : updatedPo){
            if(updatePoMAP.get(pod.Id) != NULL && pod.Version_Number__c != NULL && pod.Version_Number__c > 1 && pod.Status__c == 'New') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                set<String> toEmailSet = new set<String>();
                User us = [SELECT Id, FirstName, Email, LastName FROM USER WHERE Name= 'RPA Integration' LIMIT 1];
                if(us != NULL){
                    toEmailSet.add(us.Email);
                }
                if(mapOfOpptyWithSplitTeamEmail.get(pod.Opportunity__c) != NULL){
                    toEmailSet.addAll(mapOfOpptyWithSplitTeamEmail.get(pod.Opportunity__c));
                }
                if(mapOfOpportunity.get(pod.Opportunity__c) != NULL) {
                    toEmailSet.add(mapOfOpportunity.get(pod.Opportunity__c)?.owner?.email);
                    toEmailSet.add(mapOfOpportunity.get(pod.Opportunity__c)?.Account?.Owner.Email);
                    
                }
                if(toEmailSet != NULL)
                    toEmailList = new List<String>(toEmailSet);
                
                if(toEmailList != NULL && toEmailList.size()>0){
                    mail.setToAddresses(toEmailList);
                    String subject;
                    String body;
                    String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pod.Id;
                    subject = 'Updated PO has been received - ' + pod.PO_Number__c + ' ' + pod.End_Client_Name__c;
                    body = ' Updated PO has been received for PO# <a href="' + Recordlink + '">' + pod.PO_Number__c + '</a> <br>BOT Re QC Required for PO Details update. <br>';
                    body = body + 'PO Detail Name = ' + pod.Name +'<br>';
                    body = body + 'Thread Id = ' + pod.Order_Tracker_Thread_ID__c +'<br>';
                    body = body + 'Quote Number = ' + pod.Proposal_Quote_Number__c +'<br>';
                    
                    mail.setHtmlBody(body);
                    mail.setSubject(subject);
                    
                    mailList.add(mail);
                }
            }
        }        
        
        if(mailList != NULL && mailList.size()>0){
            Messaging.sendEmail(mailList); 
        }
        
    }
    
    public static void updateOrderTrackerWithNewPo(MAP<ID, PO_Detail__c> updatePoMAP){
        Set<Id> orderTrackerRecord = new Set<Id>();
        MAP<Id,Id> mapOfOrderIdAndPoId = new MAP<Id,Id>();
        List<Order_Tracker__c> orderTrackerToUpdate = new List<Order_Tracker__c>();
        for(PO_Detail__c pod : updatePoMAP.values()){ 
            orderTrackerRecord.add(pod.Order_Tracker__c);
            mapOfOrderIdAndPoId.put(pod.Order_Tracker__c,pod.Id);
        }
        List<Order_Tracker__c> otList  = [SELECT Id,Po_Detail__c,Po_Detail__r.Proposal_Quote_Number__c from Order_Tracker__c WHERE Id=:orderTrackerRecord];
        if( otList != NULL && otList.size()>0){
            for(Order_Tracker__c ot : otList){
                Order_Tracker__c otInstance = new Order_Tracker__c();
                otInstance.Id = ot.Id;
                otInstance.Po_Detail__c = mapOfOrderIdAndPoId.get(ot.Id);
                otInstance.Status__c = 'PO Pending for QC';
                //otInstance.Proposal_for_initiating_QC__c  = ot.Po_Detail__r.Proposal_Quote_Number__c;
                orderTrackerToUpdate.add(otInstance);
            }     
        }
        if(orderTrackerToUpdate != NULL && orderTrackerToUpdate.size()>0)
            update orderTrackerToUpdate;        
    }
    
    public static void updatePoDetailVersion(MAP<ID, PO_Detail__c> updatePoMAP){
        List<String> poNumberList = new List<String>();
        List<Id> opportunityList = new List<Id>();
        Set<String> uniqueKeySet = new Set<String>();
        Set<String> accountNameList = new Set<String>();
        Map<String,Decimal> poDetailVersionMap = new Map<String,Decimal>();
        Map<String,PO_Detail__c> poDetailExistingMap = new Map<String,PO_Detail__c>();
        List<PO_Detail__c> existingPoUpdateList = new List<PO_Detail__c>();
        for(PO_Detail__c pod : updatePoMAP.values()){ 
            if(pod.PO_Number__c != NULL && pod.Client_Name__c != NULL){
                poNumberList.add(pod.PO_Number__c);
                //opportunityList.add(pod.Opportunity__c);
                accountNameList.add(pod.Client_Name__c);
                uniqueKeySet.add(pod.PO_Number__c + pod.Client_Name__c);
            }
        }
        
        Set<String> latestPOKeySet = new Set<String>();
        for(PO_Detail__c po : updatePoMAP.values()){
            String sKey = po.PO_Number__c + po.Client_Name__c;
            latestPOKeySet.add(sKey);
        }
        
        Map<Id,PO_Detail__c> existingPoDetailList = new Map<Id,PO_Detail__c>([SELECT Id,PO_Number__c,Opportunity__c,Version_Number__c, Status__c,End_Client_Name__c, Proposal_Quote_Number__c, Order_Tracker_Thread_ID__c,Name,Client_Name__c FROM PO_Detail__c
                                                                              WHERE PO_Number__c IN : poNumberList AND Client_Name__c IN :accountNameList 
                                                                              ORDER BY Client_Name__c,PO_Number__c,Version_Number__c]);        
        if(existingPoDetailList != NULL && existingPoDetailList.size()>0){
            for(PO_Detail__c po : existingPoDetailList.values()){
                String sKey = po.PO_Number__c + po.Client_Name__c;
                if(uniqueKeySet.contains(sKey)){
                    poDetailVersionMap.put(sKey, po.Version_Number__c);
                    poDetailExistingMap.put(sKey, po);
                }
            }
            for(PO_Detail__c po : existingPoDetailList.values()){
                String sKey = po.PO_Number__c + po.Client_Name__c;
                if(po.Status__c != 'Archived' && latestPOKeySet.contains(sKey)){
                    if(updatePoMAP.get(po.Id) == null) {
                        po.Status__c = 'Archived';
                        if(poDetailVersionMap.get(sKey) == NULL){
                            po.Version_Number__c =  1;
                        }
                    } 
                    else {
                        if(poDetailVersionMap.get(sKey) != NULL){
                            po.Version_Number__c = poDetailVersionMap.get(sKey) + 1;
                        }
                        else if(poDetailVersionMap.get(sKey) == NULL && poDetailExistingMap.size() == 2 ){
                            po.Version_Number__c =  2;
                        }
                        else{
                            po.Version_Number__c =  1;
                        }
                    } 
                    existingPoUpdateList.add(po);
                }
            }
            
            if(existingPoUpdateList != NULL && existingPoUpdateList.size()>0){
                update existingPoUpdateList;
                sendEmail(existingPoUpdateList, updatePoMAP);
            }
        }
    }
    
    
    
    
    //For Each PO record with Source = EDI, Mark opportunity PO Source as EDI
    public static void updateOpportunityPOSourceToEDI(List<PO_Detail__c> poList){
        //Update Opportunity PO Source
        
        Set<ID> oppIdsNew = new Set<ID>();
        for(PO_Detail__c pod : poList){
            if(pod.Opportunity__c != null){
                oppIdsNew.add(pod.Opportunity__c); 
            }
        }
        System.debug('---oppIdsNew---'+oppIdsNew);
        
        MAP<Id, Opportunity> oppMAP = new MAP<ID,Opportunity>([Select iD,Name,PO_Source__c,Owner.email,Business_Champion_Contact__c,Business_Champion_Contact__r.email 
                                                               from opportunity where id in :oppIdsNew]);
        
        MAP<ID,Opportunity> updateOppRecordMAP = new MAP<ID,Opportunity>();
        for(PO_Detail__c pod : poList){
            if(pod.Opportunity__c != null && oppMAP.containskey(pod.Opportunity__c)){
                Opportunity opRecord = oppMAP.get(pod.Opportunity__c);
                if(pod.Source__c=='EDI' && (opRecord.PO_Source__c== null || String.isBlank(opRecord.PO_Source__c))){
                    opRecord.PO_Attached__c = true;
                    opRecord.PO_Source__c = 'EDI';
                    //opRecord.Sales_Declaration_Done__c = true;
                    updateOppRecordMAP.put(opRecord.Id, opRecord);
                }
            }
        }
        System.debug('---updateOppRecordMAP---'+updateOppRecordMAP);
        
        if(updateOppRecordMAP.size() > 0){
            Triggerhandler.bypass('OpportunityTriggerHandler');
            System.debug('---updateOppRecordMAP values---'+updateOppRecordMAP.values());
            update updateOppRecordMAP.values();
        }
    }
    
    
    
    //Mark Order Trcaker As Po pending for QC if sttaus gets updated to NEW
    public static void updateOrderTrackerStatusAsPendingforQC(List<PO_Detail__c> poList, MAP<ID, PO_Detail__c> oldMAP){
        //Update Opportunity PO Source
        MAP<ID,Order_Tracker__c> ottMAP = new MAP<ID,Order_Tracker__c>();
        for(PO_Detail__c pod : poList){
            PO_Detail__c oldPOD = oldMAP.get(pod.id);
            if(pod.Order_Tracker__c != null && pod.Status__c == 'New' ){
                ottMAP.put(pod.Order_Tracker__c, new Order_Tracker__c(id = pod.Order_Tracker__c,Proposal_for_initiating_QC__c  = pod.Proposal_Quote_Number__c));
            }   
        }
        
        if(ottMAP.size() > 0){
            System.debug('---updateOrderTrackerStatusAsPendingforQC ottMAP---'+ottMAP.values());
            update ottMAP.values();
        }
    }
    
    
    
    //IF PO is parked as PO Approved --> then create Sales order
    public static void createSalesOrder(List<PO_Detail__c> poList, MAP<ID, PO_Detail__c> oldMAP){
        //Update Opportunity PO Source
        Set<ID> poDetailIdsSet = new Set<ID>();
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(PO_Detail__c pod : poList){
            PO_Detail__c oldPOD = oldMAP.get(pod.id);
            if(pod.Order_Tracker__c != null && pod.Opportunity__c != null 
               && pod.PO_Validation_Status__c == 'PO Approved' 
               && pod.PO_Validation_Status__c != oldPOD.PO_Validation_Status__c
               && (pod.SO_Status__c != 'Success'  || pod.SO_Status__c != 'In Progress')
               && (pod.SO_Number__c == null || pod.SO_Number__c == ''))
            {
                poDetailIdsSet.add(pod.ID); 
                oppList.add(new opportunity (ID=pod.Opportunity__c,Partner_PO_Number__c =pod.PO_Number__c,Sales_Declaration_Done__c = true));
            }   
        }
        
        if(oppList.size()>0){
            //Bypass Opportunity trigger
            Triggerhandler.bypass('OpportunityTriggerHandler');
            update oppList;
        }
        
        System.debug('--createSalesOrder--poDetailIdsSet--'+poDetailIdsSet);
        if(poDetailIdsSet.size()>0){
            System.enqueueJob(new PODetailCreateSalesOrderQueue(poDetailIdsSet));
        }
    }
    
    
    @testVisible
    private Static void createOrderTrackerRecordForPO(List<PO_Detail__c> createTrackerRecord, MAP<Id, PO_Detail__c> updatePoMAP){
        System.debug('-----createOrderTrackerRecordForPO called---');
        MAP<String, PO_Detail__c> poNumMap = new MAP<String, PO_Detail__c>();
        for(PO_Detail__c pd : createTrackerRecord){
            poNumMap.put(pd.PO_Number__c,pd);
        }
        
        MAP<String, Order_Tracker__c> poOrderTrackerMap = new MAP<String, Order_Tracker__c>();
        for(PO_Detail__c pd : createTrackerRecord){
            poOrderTrackerMap.put(pd.PO_Number__c, prepareOrderTrackerRecordFromPO(pd));
        }
        
        database.insert(poOrderTrackerMap.values());
        
        for(String poNum : poOrderTrackerMap.keyset()){
            Order_Tracker__c ott = poOrderTrackerMap.get(poNum);
            if(ott != null && poNumMap.containskey(poNum)){    
                PO_Detail__c pd = poNumMap.get(poNum);
                PO_Detail__c podnew = new PO_Detail__c();
                podnew.Id= pd.id;
                podnew.Order_Tracker__c = ott.id;
                podnew.PO_Number__c = pd.PO_Number__c;	
                podnew.Opportunity__c = pd.Opportunity__c;
                podnew.Client_Name__c = pd.Client_Name__c;
                updatePoMAP.put(pd.id, podnew);
            }
        }
        
        System.debug('-----updatePoMAP---'+updatePoMAP.values());
    }
    
    
    
    @testVisible
    private Static MAP<Id, Order_Tracker__c> getOrderTrcakerMAP(Set<Id> oppIds){
        MAP<Id, Order_Tracker__c> opportunityOrdrTrackerMap = new MAP<ID, Order_Tracker__c>();
        if(oppIds.size()>0){
            for(Order_Tracker__c ot : [Select id,PO_Detail__c,
                                       Opportunity__c,PO__c,
                                       Proposal_for_initiating_QC__c 
                                       from Order_Tracker__c 
                                       where Opportunity__c != null 
                                       and Opportunity__c in :oppIds 
                                       and Status__c not in ('Duplicate','Processed/Billed')
                                       and PO__c != null
                                       order by createddate])
            {
                opportunityOrdrTrackerMap.put(ot.Opportunity__c, ot);
            }
        }
        
        System.debug('---opportunityOrdrTrackerMap---'+opportunityOrdrTrackerMap);
        return opportunityOrdrTrackerMap;
    }
    
    
    
    @testVisible
    private static Order_Tracker__c prepareOrderTrackerRecordFromPO(PO_Detail__c pd){
        Order_Tracker__c ottRecord  = new Order_Tracker__c();
        ottRecord.Opportunity__c = pd.Opportunity__c;
        ottRecord.PO__c = pd.PO_Number__c;
        ottRecord.Proposal_for_initiating_QC__c = pd.Proposal_Quote_Number__c;
        ottRecord.From__c = userinfo.getUserEmail();
        ottRecord.Email_Subject__c = 'Automated PO Submission -'+ pd.PO_Number__c + '-'+pd.End_Client_Name__c;
        ottRecord.body__c = '';
        ottRecord.isNewFlag__c = true;
        ottRecord.Status__c = 'PO Pending for QR';
        ottRecord.Source__c = 'EDI';
        ottRecord.Mail_Forwarded__c = 'Yes';
        ottRecord.PO_Detail__c = pd.id;
        return ottRecord;
    }
    
   
    //get quote CPQ.
    @testvisible
    private static List<SBQQ__Quote__c> getALLDataCPQ(Set<String> quoteNumberList){
        List<SBQQ__Quote__c> relatedQuotes = new list<SBQQ__Quote__c>();
        relatedQuotes = [SELECT Id, Name, 
                         RecordType.Name,
                         SBQQ__Opportunity2__c
                         From SBQQ__Quote__c
                         Where Name in :quoteNumberList];
        return relatedQuotes;
    }
    
}