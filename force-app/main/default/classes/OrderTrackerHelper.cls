public without sharing class OrderTrackerHelper
{
    public static boolean bypassOrderTrackerTrigger = false;
    
    public static Map<String,RegionMapping__c> regionSetting = RegionMapping__c.getAll();
    
    //function to update order tracker on insert operation
    public static void getOppAndProposalFieldsForInsert(List<Order_Tracker__c> newOrderTracker)
    {
        List<String> quoteNumberList = new List<String>();
        
        //Get latest Customer Number
        List<Customers__c> customers = getCustomerIdNumber();
        Integer LatestNumber=(Integer)customers[0].Latest_Number__c; 
        
        
        for(Order_Tracker__c orderTracker:newOrderTracker){
            
            if(orderTracker.Order_Type__c == 'New'){
                LatestNumber+= 1;
                orderTracker.Customer_Id__c = customers[0].Key__c+LatestNumber;
            }
            
            if(orderTracker.Status__c == 'PO Pending for QR'){
                orderTracker.QC_Check_Date__c=system.now();
            }
            else if(orderTracker.Status__c == 'PO Pending for Booking'){
                orderTracker.Order_Approval_Date__c=system.now();
            }
            else if(orderTracker.Status__c == 'Processed/Billed'){
                orderTracker.Billing_Date__c=system.now();
            }
            if(orderTracker.Proposal_for_initiating_QC__c != null){
                quoteNumberList.add(orderTracker.Proposal_for_initiating_QC__c);
            }            
            if(String.isNotBlank(orderTracker.status__c))
                orderTracker.Current_Status_Update_Time__c = system.now();
        }
        
        //Update Customer Number
        customers[0].Latest_Number__c = LatestNumber;
        upsert customers;
        
        System.debug('--quoteNumberList--'+quoteNumberList);
                
        List<SBQQ__Quote__c> relatedQuotesCPQ = new List<SBQQ__Quote__c>();
        Map<Id,List<OpportunitySplit>> opportunitySplitMapCPQ = new  Map<Id,List<OpportunitySplit>>();
        if(quoteNumberList.size()>0){
            relatedQuotesCPQ= getALLDataCPQ(quoteNumberList);
            opportunitySplitMapCPQ = getOpportunitySplits(getAllOpportunityIdsCPQ(relatedQuotesCPQ));
        }
        
        map<String,SBQQ__Quote__c> poNumberToQuoteMapCPQ = new map<String,SBQQ__Quote__c>();
        if(relatedQuotesCPQ.size()>0){
            for(SBQQ__Quote__c quotee:relatedQuotesCPQ){
                poNumberToQuoteMapCPQ.put(quotee.Name, quotee);
            }
        }
        
        
        for(Order_Tracker__c orderTracker:newOrderTracker){
            //CPQ Quote
            	if(poNumberToQuoteMapCPQ.containskey(orderTracker.Proposal_for_initiating_QC__c)){
                SBQQ__Quote__c relatedQuote = poNumberToQuoteMapCPQ.get(orderTracker.Proposal_for_initiating_QC__c);
                fillOrderTrackerFromCPQQuote(orderTracker, relatedQuote,  opportunitySplitMapCPQ);
            }
        }
    }
    
    
    //Pre fill PO detail Record if PO_Detail__c is null
    public static void fillPODetailLookUpBasedOnthePO(List<Order_Tracker__c> newOrderTracker){
       
        MAP<String,Order_Tracker__c> poQuoteMAP = new MAP<String,Order_Tracker__c>();
        for(Order_Tracker__c ott : newOrderTracker){
            if(ott.Status__c != 'Duplicate' && ott.PO_Detail__c == null && ott.PO__c != null && ott.Proposal_for_initiating_QC__c != null){
                poQuoteMAP.put(ott.PO__c, ott); 
            }
        }
        if(poQuoteMAP.size()>0){
            MAP<String, PO_Detail__c> poQuoteKeyMap = new MAP<String,PO_Detail__c>();
            for(PO_Detail__c pod : [Select id,PO_Number__c,Proposal_Quote_Number__c from PO_Detail__c where PO_Number__c != null and Proposal_Quote_Number__c != null and PO_Number__c in :poQuoteMAP.keyset() and Status__c != 'Archived']){
                poQuoteKeyMap.put(pod.PO_Number__c + '#'+ pod.Proposal_Quote_Number__c, pod);
            }
            
            for(Order_Tracker__c ott : poQuoteMAP.values()){
                if(poQuoteKeyMap.containskey(ott.PO__c+'#'+ott.Proposal_for_initiating_QC__c)){
                    ott.PO_Detail__c = poQuoteKeyMap.get(ott.PO__c+'#'+ott.Proposal_for_initiating_QC__c).Id;
                }
            }
        }
    }
    
    private static void fillOrderTrackerFromCPQQuote(Order_Tracker__c orderTracker, SBQQ__Quote__c relatedQuote,  Map<Id,List<OpportunitySplit>> opportunitySplitMap){
        if(relatedQuote != null){
            
            //Set X1st_Billing_Amount_USD__c
            if(relatedQuote.SBQQ__BillingFrequency__c =='Custom Schedule'){
                if(!relatedQuote.Billing_Schedules__r.isEmpty()){
                    if(relatedQuote.Billing_Schedules__r[0].Amount__c!=Null)
                        orderTracker.X1st_Billing_Amount_USD__c=relatedQuote.Billing_Schedules__r[0].Amount__c.setScale(2); 
                }
            }else if(relatedQuote.Year_1_Subtotal__c!=NULL){
                orderTracker.X1st_Billing_Amount_USD__c=relatedQuote.Year_1_Subtotal__c.setScale(2);  
            }
            
            
            if(relatedQuote.SBQQ__Opportunity2__r.Type=='New Business' || relatedQuote.SBQQ__Opportunity2__r.Type=='Existing Customer (Add On)' )
            {
                if(relatedQuote.SBQQ__Opportunity2__r.Amount!=Null)
                    orderTracker.New_Upsell_ACV__c=relatedQuote.SBQQ__Opportunity2__r.Amount.setScale(2); 
            }
            else if(relatedQuote.SBQQ__Opportunity2__r.Type=='Existing Customer (Renewal)'){
                orderTracker=setopportunitySplitsValue(orderTracker,opportunitySplitMap.get(relatedQuote.SBQQ__Opportunity2__c));
            }
            
            if(relatedQuote.SBQQ__Opportunity2__r.Area__c!=NULL && (regionSetting.containsKey(relatedQuote.SBQQ__Opportunity2__r.Area__c.toLowerCase())))
                orderTracker.Region__c=(regionSetting.get(relatedQuote.SBQQ__Opportunity2__r.Area__c.toLowerCase())).Region__c;
            
            
            if(relatedQuote.SBQQ__Opportunity2__r.TCV__c!=Null){
                orderTracker.TCV__c=relatedQuote.SBQQ__Opportunity2__r.TCV__c.setScale(2);
                orderTracker.PO_Amount__c=relatedQuote.SBQQ__Opportunity2__r.TCV__c.setScale(2);
            }
            
            if(relatedQuote.SBQQ__Opportunity2__r.Amount!=Null)
                orderTracker.ACV__c=relatedQuote.SBQQ__Opportunity2__r.Amount.setScale(2);
            
            orderTracker.Partner__c=relatedQuote.Bill_to__r.name; 
            orderTracker.Opportunity__c=relatedQuote.SBQQ__Opportunity2__r.Id;
            orderTracker.NS_Integration_Status__c=relatedQuote.SBQQ__Opportunity2__r.NS_Integration_Status__c;
            orderTracker.SO__c=relatedQuote.SBQQ__Opportunity2__r.Netsuite_Sales_Order_Number__c;
            orderTracker.Netsuite_Sales_Order_Number__c=relatedQuote.SBQQ__Opportunity2__r.Netsuite_Sales_Order_Number__c;
            orderTracker.Billing_Frequency__c=relatedQuote.SBQQ__BillingFrequency__c;
            
            if(orderTracker.End_User__c=='' || orderTracker.End_User__c==NULL)
                orderTracker.End_User__c=relatedQuote.SBQQ__Account__r.Name;  
        }
    }
    
    
    
    //function to update order tracker on update operation
    public static void getOppAndProposalFieldsForUpdate(List<Order_Tracker__c> newOrderTracker, Map<ID,Order_Tracker__c> oldOrderTrackerMap){
        
        List<String> quoteNumberList = new List<String>();
        
        //Get latest Customer Number
        List<Customers__c> customers = getCustomerIdNumber();
        Integer LatestNumber=(Integer)customers[0].Latest_Number__c; 
        
        system.debug('--getOppAndProposalFieldsForUpdate--LatestNumber---'+LatestNumber);
        
        
        for(Order_Tracker__c orderTracker : newOrderTracker){ 
            Order_Tracker__c oldOrderTracker = oldOrderTrackerMap.get(orderTracker.Id);
            
            //If Order_Type__c get changed reset the customer id
            if(orderTracker.Order_Type__c!=oldOrderTracker.Order_Type__c){
                if(orderTracker.Order_Type__c == 'New' ){                
                    LatestNumber+= 1;
                    orderTracker.Customer_Id__c = customers[0].Key__c+LatestNumber;
                }else{
                    orderTracker.Customer_Id__c = Null;
                }
            }
                        
            //If Status__c get changed
            if(orderTracker.Status__c != oldOrderTracker.Status__c){
                //CR # 4707 Start
                if(oldOrderTracker.Status__c == 'PO Pending for QR'){
                    orderTracker.QC_Check_Date__c=system.now();
                }
                //CR # 4707 End
                else if(orderTracker.Status__c == 'PO Pending for Booking'){
                    orderTracker.Order_Approval_Date__c=system.now();
                }
                else if(orderTracker.Status__c == 'Processed/Billed'){
                    orderTracker.Billing_Date__c=system.now();
                }

               if(oldOrderTracker.Current_Status_Update_Time__c != NULL){
                Datetime dtWorking = oldOrderTracker.Current_Status_Update_Time__c;
                Integer diff =    dtWorking.date().daysBetween(Date.today());
                dtWorking = dtWorking.addDays(diff);
                Decimal hrs = (Datetime.now().getTime() - dtWorking.getTime())/1000/60/60 ;
                orderTracker.Status_Change_Time_Difference__c = String.valueOf(diff) + ' Day(s) ' + String.valueof(hrs) + ' Hour(s) ';
                // Populate for Individual Status Change

                Long dt1Long = system.now().getTime();
                  if(oldOrderTracker.Status__c == 'PO Pending With Sales'){
                        Long dt2Long = oldOrderTracker.Current_Status_Update_Time__c.getTime();
                        Long milliseconds = dt1Long - dt2Long;
                        decimal seconds = decimal.valueof(milliseconds / 1000);
                        decimal minutes = seconds / 60;
                        decimal hours = ((minutes / 60)).setScale(2);
                        if(orderTracker.Time_In_PendingWithSales__c != NULL){
                            decimal totalTime = orderTracker.Time_In_PendingWithSales__c + hours;
                            orderTracker.Time_In_PendingWithSales__c = totalTime;
                        }
                        else{
                            orderTracker.Time_In_PendingWithSales__c = hours;
                        }
                    }
                    if(oldOrderTracker.Status__c == 'PO Pending For QR'){
                        Long dt2Long = oldOrderTracker.Current_Status_Update_Time__c.getTime();
                        Long milliseconds = dt1Long - dt2Long;
                        decimal seconds = decimal.valueof(milliseconds / 1000);
                        decimal minutes = seconds / 60;
                        decimal hours = ((minutes / 60)).setScale(2);
                        if(orderTracker.Time_In_PendingWithQR__c != NULL){
                            decimal totalTime = orderTracker.Time_In_PendingWithQR__c + hours;
                            orderTracker.Time_In_PendingWithQR__c = totalTime;
                        }
                        else{
                            orderTracker.Time_In_PendingWithQR__c = hours ;
                        }
                        
                    }
                    if(oldOrderTracker.Status__c == 'PO Pending For Booking'){
                        Long dt2Long = oldOrderTracker.Current_Status_Update_Time__c.getTime();
                        Long milliseconds = dt1Long - dt2Long;
                        Decimal seconds = decimal.valueof(milliseconds / 1000);
                        Decimal minutes = seconds / 60;
                        decimal hours = ((minutes / 60)).setScale(2);
                        if(orderTracker.Time_In_PendingForBooking__c != NULL){
                            Decimal totalTime = orderTracker.Time_In_PendingForBooking__c + hours;
                            orderTracker.Time_In_PendingForBooking__c = totalTime;
                        }
                        else{
                            orderTracker.Time_In_PendingForBooking__c = hours;
                        } 
                    }
                    if(oldOrderTracker.Status__c == 'PO Pending For QC'){
                        Long dt2Long = oldOrderTracker.Current_Status_Update_Time__c.getTime();
                        Long milliseconds = dt1Long - dt2Long;
                        Decimal seconds = decimal.valueof(milliseconds / 1000);
                        Decimal minutes = seconds / 60;
                        decimal hours = ((minutes / 60)).setScale(2);
                        if(orderTracker.Time_In_PendingForQC__c != NULL){
                            Decimal totalTime = orderTracker.Time_In_PendingForQC__c + hours;
                            orderTracker.Time_In_PendingForQC__c = totalTime;
                        }
                        else{
                            orderTracker.Time_In_PendingForQC__c = hours;  
                        }   
                    } 
                } 
                orderTracker.Current_Status_Update_Time__c = system.now();
            }
            if(orderTracker.Proposal_for_initiating_QC__c != null){
                quoteNumberList.add(orderTracker.Proposal_for_initiating_QC__c);
            }
            
            //orderTracker.BOT_Re_QC_Required__c get changed to Yes from No
            if(orderTracker.BOT_Re_QC_Required__c == 'Yes' && oldOrderTracker.BOT_Re_QC_Required__c == 'No'){
                OrderTrackerHelper.sendEmailToBot(orderTracker);
            }
            
            //Set TCV as PO AMount Every Time
            orderTracker.TCV__c = orderTracker.PO_Amount__c;  
    }
        System.debug('--quoteNumberList--'+quoteNumberList.size());
        
        if(!quoteNumberList.isEmpty()){
             
            List<SBQQ__Quote__c> relatedQuotesCPQ = new List<SBQQ__Quote__c>();
            Map<Id,List<OpportunitySplit>> opportunitySplitMapCPQ = new  Map<Id,List<OpportunitySplit>>();
            relatedQuotesCPQ= getALLDataCPQ(quoteNumberList);
            opportunitySplitMapCPQ = getOpportunitySplits(getAllOpportunityIdsCPQ(relatedQuotesCPQ));
                                   
            map<String,SBQQ__Quote__c> poNumberToQuoteMapCPQ = new map<String,SBQQ__Quote__c>();
            if(relatedQuotesCPQ.size()>0){
                for(SBQQ__Quote__c quotee:relatedQuotesCPQ){
                    poNumberToQuoteMapCPQ.put(quotee.Name, quotee);
                }
            }
            
            System.debug('--poNumberToQuoteMapCPQ size--'+poNumberToQuoteMapCPQ.size());
            
            
            //Pre fill Details if not provided
            for(Order_Tracker__c orderTracker: newOrderTracker){
                Order_Tracker__c oldOrderTracker = oldOrderTrackerMap.get(orderTracker.Id);

                //if CPQ Quote
                if(poNumberToQuoteMapCPQ.containskey(orderTracker.Proposal_for_initiating_QC__c)){
                    SBQQ__Quote__c relatedQuote = poNumberToQuoteMapCPQ.get(orderTracker.Proposal_for_initiating_QC__c);
                    fillOrderTrackerFromCPQQuoteUpdate(orderTracker, oldOrderTracker, relatedQuote, opportunitySplitMapCPQ, customers, LatestNumber);
                }
            } 
        }
        
        if(customers[0].Latest_Number__c != LatestNumber){
            customers[0].Latest_Number__c = LatestNumber;
            upsert customers;
        }
    }
    
    
    //function to update PO_Detail on update operation of OrderTracker Status
    public static void updatePoDetailOrderTrackerStatusChange(List<Order_Tracker__c> newOrderTracker, Map<ID,Order_Tracker__c> oldOrderTrackerMap){
        
        MAP<Id,PO_Detail__c> poDetailMAP = new MAP<Id,PO_Detail__c>();
        
        for(Order_Tracker__c orderTracker : newOrderTracker){ 
            Order_Tracker__c oldOrderTracker = oldOrderTrackerMap.get(orderTracker.Id);
            //CR# 4919 Start
            if (orderTracker.PO_Detail__c != null && orderTracker.NS_Integration_Status__c != oldOrderTracker.NS_Integration_Status__c &&
                orderTracker.NS_Integration_Status__c == 'Success')
            {
                poDetailMAP.put(orderTracker.PO_Detail__c , new PO_Detail__c(Id = orderTracker.PO_Detail__c, Status__c = 'Processed'));
            }
           //CR# 4919 End
            if(orderTracker.PO_Detail__c != null && orderTracker.Status__c != oldOrderTracker.Status__c){
                if(orderTracker.Status__c == 'Processed/Billed'){
                    poDetailMAP.put(orderTracker.PO_Detail__c , new PO_Detail__c(Id = orderTracker.PO_Detail__c, Status__c = 'Processed'));
                }
                else if(orderTracker.Status__c == 'PO Pending for Booking'){
                    poDetailMAP.put(orderTracker.PO_Detail__c , new PO_Detail__c(Id = orderTracker.PO_Detail__c, Status__c = 'Acknowledged'));
                }
            }   

            //IBA-3253
            if(orderTracker.PO_Detail__c != null && String.isNotBlank(orderTracker.Proposal_for_initiating_QC__c) && orderTracker.Proposal_for_initiating_QC__c != oldOrderTracker.Proposal_for_initiating_QC__c){
                if(poDetailMAP.containsKey(orderTracker.PO_Detail__c)){
                    poDetailMAP.get(orderTracker.PO_Detail__c).Proposal_Quote_Number__c = orderTracker.Proposal_for_initiating_QC__c;
                }else{
                    poDetailMAP.put(orderTracker.PO_Detail__c , new PO_Detail__c(Id = orderTracker.PO_Detail__c, Proposal_Quote_Number__c = orderTracker.Proposal_for_initiating_QC__c));
                }
            }
        }
                
        if(!poDetailMAP.isEmpty()){
            update poDetailMAP.values();
        }
        
    }

    private static void fillOrderTrackerFromCPQQuoteUpdate(Order_Tracker__c orderTracker, Order_Tracker__c oldOrderTracker, 
                                                           SBQQ__Quote__c relatedQuote,  Map<Id,List<OpportunitySplit>> opportunitySplitMap,
                                                           List<Customers__c> customers, Integer LatestNumber)
    {
        if(relatedQuote != null){
            
            Boolean check = (orderTracker.Proposal_for_initiating_QC__c != oldOrderTracker.Proposal_for_initiating_QC__c ? true : false);
         	System.debug('Check this -->' + check);
            
            orderTracker.Region__c = 
                check 
                && 
                (
                    relatedQuote.SBQQ__Opportunity2__r.Area__c != NULL &&
                    regionSetting.containsKey(relatedQuote.SBQQ__Opportunity2__r.Area__c.toLowerCase())
                ) 
                ?
                (regionSetting.get(relatedQuote.SBQQ__Opportunity2__r.Area__c.toLowerCase())).Region__c 
                :
            orderTracker.Region__c;
            
            
            orderTracker.Opportunity__c=relatedQuote.SBQQ__Opportunity2__r.Id;
            orderTracker.NS_Integration_Status__c=relatedQuote.SBQQ__Opportunity2__r.NS_Integration_Status__c;
            orderTracker.Netsuite_Sales_Order_Number__c=relatedQuote.SBQQ__Opportunity2__r.Netsuite_Sales_Order_Number__c;
            
            if(relatedQuote.SBQQ__Opportunity2__r.Type=='New Business' || relatedQuote.SBQQ__Opportunity2__r.Type=='Existing Customer (Add On)'){
                orderTracker.Renewal_ACV__c=0;
                orderTracker.New_Upsell_ACV__c=0;
                orderTracker.New_Upsell_ACV__c=relatedQuote.SBQQ__Opportunity2__r.Amount != null ? relatedQuote.SBQQ__Opportunity2__r.Amount.setScale(2) : 0; 
            }else if(relatedQuote.SBQQ__Opportunity2__r.Type=='Existing Customer (Renewal)'){
                orderTracker = setopportunitySplitsValue(orderTracker,opportunitySplitMap.get(relatedQuote.SBQQ__Opportunity2__c));
            }
            
            orderTracker.Partner__c = (orderTracker.Partner__c == '' || orderTracker.Partner__c == Null || check) ? relatedQuote.Bill_to__r.name : orderTracker.Partner__c;    
            orderTracker.End_User__c = (orderTracker.End_User__c == '' || orderTracker.End_User__c == Null || check) ?  relatedQuote.SBQQ__Account__r.Name : orderTracker.End_User__c;
            orderTracker.ACV__c = (orderTracker.ACV__c == null || orderTracker.ACV__c == 0 || check) ?  relatedQuote.SBQQ__Opportunity2__r.Amount.setScale(2) : orderTracker.ACV__c;
            orderTracker.SO__c = (orderTracker.SO__c == '' || orderTracker.SO__c == Null || check) ? relatedQuote.SBQQ__Opportunity2__r.Netsuite_Sales_Order_Number__c : orderTracker.SO__c;    
            orderTracker.PO_Amount__c = 
                (orderTracker.PO_Amount__c == null || orderTracker.PO_Amount__c == 0 || check) 
                ? (relatedQuote.SBQQ__Opportunity2__r.TCV__c!=Null ? relatedQuote.SBQQ__Opportunity2__r.TCV__c.setScale(2)  :  0) 
                : orderTracker.PO_Amount__c;    
            
            orderTracker.Billing_Frequency__c= (orderTracker.Billing_Frequency__c == '' || orderTracker.Billing_Frequency__c == Null || check) ? relatedQuote.SBQQ__BillingFrequency__c : orderTracker.Billing_Frequency__c;
            
            //set X1st_Billing_Amount_USD__c amount
            if(orderTracker.X1st_Billing_Amount_USD__c == 0 || String.valueOf(orderTracker.X1st_Billing_Amount_USD__c) == null || check){
                if(relatedQuote.SBQQ__BillingFrequency__c=='Custom Schedule'){
                    if(!relatedQuote.Billing_Schedules__r.isEmpty() && relatedQuote.Billing_Schedules__r[0].Amount__c!=Null){
                        orderTracker.X1st_Billing_Amount_USD__c=relatedQuote.Billing_Schedules__r[0].Amount__c.setScale(2); 
                    }
                }else if(relatedQuote.Year_1_Subtotal__c != NULL){
                    orderTracker.X1st_Billing_Amount_USD__c=relatedQuote.Year_1_Subtotal__c.setScale(2);  
                }
            }
            
            //this need to be changed
            if(check){
                if(relatedQuote.RecordType.Name=='New Business'){
                    orderTracker.Order_Type__c ='New';
                    if(orderTracker.Order_Type__c != oldOrderTracker.Order_Type__c){                
                        LatestNumber+= 1;
                        orderTracker.Customer_Id__c = customers[0].Key__c+LatestNumber;
                    }
                }
                else if(relatedQuote.RecordType.Name=='Renewal'){
                    orderTracker.Order_Type__c ='Renewal';
                    orderTracker.Customer_Id__c=Null;
                }
                else if(relatedQuote.RecordType.Name=='Upsell'){
                    orderTracker.Order_Type__c ='Upsell';
                    orderTracker.Customer_Id__c=Null;
                }
            }            
        }
    }
    
    
    
    //function to send email to BOT
    public static void sendEmailToBot(Order_Tracker__c newOrderTracker)
    {
        if(Label.Orders_Mail_Box == Null || Label.Orders_Mail_Box == '')
            return;
        String emailBody = 'BOT Re QC Required \nThread Id = ' + newOrderTracker.Thread_ID__c;
        if(newOrderTracker.Proposal_for_initiating_QC__c !=Null || newOrderTracker.Proposal_for_initiating_QC__c!='')
            emailBody+='\nQuote Number = '+newOrderTracker.Proposal_for_initiating_QC__c ;
        Mail_Chain__c relatedMailChain = [SELECT Id, Name from Mail_Chain__c where Order_Tracker__c = :newOrderTracker.id order by CreatedDate ASC LIMIT 1];
        system.debug('relatedMailChain gs1'+relatedMailChain);
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId=:relatedMailChain.Id];
        Set<String> contentDocId = new Set<String>();
        for (ContentDocumentLink cdl : cdls) {
            contentDocId.add(cdl.ContentDocumentId);
        }
        List<ContentVersion> relatedDocumentList= [SELECT Id, Title, PathOnClient, VersionData, FirstPublishLocationId FROM ContentVersion where ContentDocumentId IN:contentDocId order by CreatedDate];
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        system.debug('relatedDocumentList gs2 '+relatedDocumentList);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Id> contentVersionIds = new List<Id>();
        
        if(!relatedDocumentList.isEmpty()){ 
            for(ContentVersion cv:relatedDocumentList){
                contentVersionIds.add(cv.id); 
            }
        }
        
        if(!contentVersionIds.isEmpty())       
            mail.setEntityAttachments(contentVersionIds);
        String[] toEmails=new String[] { Label.Orders_Mail_Box};
            if(!toEmails.isEmpty())
            mail.setToAddresses(toEmails);
        mail.setSubject('BOT Re QC Required');
        mail.setPlainTextBody(emailBody);
        
        //sending email
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        
    }
    
    //function to get latest customer Id number
    public static List<Customers__c> getCustomerIdNumber()
    {
        List<Customers__c> customers = new  List<Customers__c>();
        customers = [select Latest_Number__c,Key__c from Customers__c LIMIT 1];
        if(Test.isRunningTest() && customers.isEmpty()){
            Customers__c customer=new Customers__c(Name='Customer Number', Key__c='P', Latest_Number__c=110725);
            customers.add(customer);
        }
        return customers;
    }
    
    //get opportunity quote and opportunity splits data.
    public static List<SBQQ__Quote__c> getALLDataCPQ(List<String> quoteNumberList)
    {
        List<SBQQ__Quote__c> relatedQuotes = new list<SBQQ__Quote__c>();
        relatedQuotes = [SELECT Id, Name, 
                         RecordType.Name,
                         SBQQ__Opportunity2__c,
                         ACV__c,
                         Billing_Frequency__c,
                         SBQQ__BillingFrequency__c,
                         TCV__c,
                         Year_1_Subtotal__c,
                         Region_Account__c,
                         
                         SBQQ__Opportunity2__r.Id,
                         SBQQ__Opportunity2__r.Amount,
                         SBQQ__Opportunity2__r.Area__c, 
                         SBQQ__Opportunity2__r.NS_Integration_Status__c,
                         SBQQ__Opportunity2__r.Netsuite_Sales_Order_Number__c,
                         SBQQ__Opportunity2__r.Type,
                         SBQQ__Opportunity2__r.APTSCU_New_ACV__c,
                         SBQQ__Opportunity2__r.Renewal_ACV__c,
                         SBQQ__Opportunity2__r.TCV__c,
                         
                         SBQQ__Account__c,
                         SBQQ__Account__r.Name,
                         
                         Bill_to__c,
                         Bill_to__r.name,
                         
                         (SELECT Id, Name, Amount__c,Billing_Date__c FROM Billing_Schedules__r Order By Billing_Date__c LIMIT 1) 
                         From SBQQ__Quote__c 
                         
                         Where Name in :quoteNumberList];
        
        return relatedQuotes;
    }
    
    
    public static set<Id> getAllOpportunityIdsCPQ(List<SBQQ__Quote__c> relatedQuotes){
        Set<Id> oppIdset=new Set<Id>();
        for(SBQQ__Quote__c quote:relatedQuotes){
            if(quote.SBQQ__Opportunity2__r.Type=='Existing Customer (Renewal)')
                oppIdset.add(quote.SBQQ__Opportunity2__c);
        }
        return oppIdset;
    }
    
    public static Map<Id,List<OpportunitySplit>> getOpportunitySplits(Set<Id> oppIdSet){
        Map<Id,List<OpportunitySplit>> opportunitySplitMap=new Map<Id,List<OpportunitySplit>>();
        List<OpportunitySplit> oppSplit=new List<OpportunitySplit>();
        oppSplit=[SELECT Id, Split_Type__c, Amount__c, OpportunityId FROM OpportunitySplit WHERE OpportunityId IN:oppIdset];
        for(OpportunitySplit ops:oppSplit){
            if(opportunitySplitMap.containsKey(ops.OpportunityId)){
                opportunitySplitMap.get(ops.OpportunityId).add(ops);
            }else{
                opportunitySplitMap.put(ops.OpportunityId,new List<OpportunitySplit>{(ops)}); 
            }
        }
        return opportunitySplitMap;
    }
    
    
    
    public static Order_Tracker__c setopportunitySplitsValue(Order_Tracker__c orderTracker,List<OpportunitySplit> oppSplits)
    {
        if(!oppSplits.isEmpty()){
            orderTracker.New_Upsell_ACV__c=0;
            orderTracker.Renewal_ACV__c=0;
            for(OpportunitySplit ops:oppSplits){
                SYstem.debug('--Opportunity Split---'+ ops);
                if(ops.Split_Type__c=='Renewal' || ops.Split_Type__c=='Comp' ){
                    orderTracker.Renewal_ACV__c+= ops.Amount__c.setScale(2);
                }else if(ops.Split_Type__c=='Upsell'){
                    orderTracker.New_Upsell_ACV__c+= ops.Amount__c.setScale(2); 
                }
            }
        }
        System.debug('orderTracker.New_Upsell_ACV__c' +  orderTracker.New_Upsell_ACV__c);
        System.debug('orderTracker.Renewal_ACV__c' +   orderTracker.Renewal_ACV__c);
        return orderTracker;
    }
    
    //setorder tracker data from opportunity update
    public static void setOrderTrackersData(Set<Id> oppIdset,Map<Id, opportunity> oppMap) 
    {
        TriggerUtility2.oppOrderTracakerCalledExecuted();
        List<Order_Tracker__c> orderTrackerList=[SELECT Id, Opportunity__c FROM Order_Tracker__c WHERE Opportunity__c IN:oppIdset];
        Map<Id,List<OpportunitySplit>> opportunitySplitMap=OrderTrackerHelper.getOpportunitySplits(oppIdSet);
        for(Order_Tracker__c orderTracker:orderTrackerList)
        {
            Opportunity opp=oppMap.get(orderTracker.Opportunity__c);
            if(opp.Type=='New Business' || opp.Type=='Existing Customer (Add On)'){
                if(opp.Amount!=Null)
                    orderTracker.New_Upsell_ACV__c=opp.Amount.setScale(2); 
                orderTracker.Renewal_ACV__c=0;
            }else if(opp.Type=='Existing Customer (Renewal)'){
                orderTracker.New_Upsell_ACV__c=0;
                orderTracker=setopportunitySplitsValue(orderTracker,opportunitySplitMap.get(orderTracker.Opportunity__c));
            }
        }
        
        if(!orderTrackerList.isEmpty())
            Update orderTrackerList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> SearchRecords(String searchTerm,String objectName,String filter) {
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchTerm + '%';
        string sQuery = 'Select Id,Name,Email From ' + objectName + ' Where Email Like : sWildCardText OR Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
}