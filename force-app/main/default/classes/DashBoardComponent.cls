public without sharing class DashBoardComponent 
{
    //PO Pending with Sales
    @AuraEnabled
    public static Map<String,Object> getTotalResponedToRepData()
    {
        Map<String,Object> response = new Map<String,Object>();
        Integer totalOrderTrackerRecords;
        Map<string,Object> totalSumListMainMap = new Map<string,Object>();
        try
        {
            totalSumListMainMap = getTotalSum('PO Pending with Sales');
            response.put('totalSum',totalSumListMainMap);
            totalOrderTrackerRecords=[SELECT Count() From Order_Tracker__c Where Status__c = 'PO Pending with Sales'];    
            response.put('Count',totalOrderTrackerRecords);
            if(totalOrderTrackerRecords < 15)
            {
                response.put('respondedToRepList',getNextResponedToRepData(0,totalOrderTrackerRecords,'',''));
            }
            else
            {
                response.put('respondedToRepList',getNextResponedToRepData(0,10,'',''));    
            }
        }
        catch(Exception ex)
        {
            System.debug('Error message'+ex.getMessage());
        }
        return response;
    }
    
    //PO Pending with Sales for pagination 
    @AuraEnabled
    public static List<Order_Tracker__c> getNextResponedToRepData(Integer pageNumber,Integer pageLimit,String sortedBy,String sortDirection)
    {
        integer off = pageNumber * pageLimit;
        String query='SELECT Id,Ticket__c,End_User__c,Proposal_for_initiating_QC__c,PO__c, SO__c, New_Upsell_ACV__c, Opportunity__r.Reason_for_5C__c, Renewal_ACV__c, ACV__c, Live_Status_Change_Time_Difference__c , Opened_Since__c, TCV__c ';
        query+='FROM Order_Tracker__c Where Status__c = \'PO Pending with Sales\' ORDER BY ';
        if(sortedBy != NULL && sortedBy !='' && sortDirection!='')
        {
            if(sortDirection == 'desc')
            {
                query=query+sortedBy+' '+sortDirection+' nulls last ';
            }
            else
            {
            	query=query+sortedBy+' '+sortDirection+' ';    
            }
            
        }
        else
        {
            query+='ACV__c DESC ' + 'nulls last ';
        }
        query+='LIMIT :pageLimit OFFSET :off';
        List<Order_Tracker__c> ResponedToRepOrderTrackerList =  Database.query(query);
        return ResponedToRepOrderTrackerList;
    }
    
    
    
    //PO Pending for QR data 
    @AuraEnabled
    public static Map<String,Object> getTotalOrdersPendingQR()
    {
        Map<String,Object> response = new Map<String,Object>();
        Integer totalOrderTrackerRecords;
        Map<string,Object> totalSumListMainMap = new Map<string,Object>();
        try
        {
            totalSumListMainMap = getTotalSum('PO Pending for QR');
            response.put('totalSum',totalSumListMainMap);
            totalOrderTrackerRecords=[SELECT Count() From Order_Tracker__c  Where Status__c = 'PO Pending for QR' ];    
            response.put('Count',totalOrderTrackerRecords);
            if(totalOrderTrackerRecords < 15)
            {
                response.put('OrdersPendingQRList',getNextOrdersPendingQRData(0,totalOrderTrackerRecords,'',''));
            }
            else
            {
                response.put('OrdersPendingQRList',getNextOrdersPendingQRData(0,10,'',''));    
            }
        }
        catch(Exception ex)
        {
            System.debug('Error message'+ex.getMessage());
        }
        return response;
    }
    
    //PO Pending for QR data for pagination
    @AuraEnabled
    public static List<Order_Tracker__c> getNextOrdersPendingQRData(Integer pageNumber,Integer pageLimit,String sortedBy,String sortDirection)
    {
        integer off = pageNumber * pageLimit;
         String query='SELECT Id,Ticket__c,End_User__c,Proposal_for_initiating_QC__c,PO__c, SO__c, New_Upsell_ACV__c, Renewal_ACV__c, ACV__c, TCV__c, Opportunity__r.Reason_for_5C__c, Live_Status_Change_Time_Difference__c , Opened_Since__c ';
        query+='FROM Order_Tracker__c Where Status__c = \'PO Pending for QR\' ORDER BY ';
        if(sortedBy != NULL && sortedBy !='' && sortDirection!='')
        {
            if(sortDirection == 'desc')
            {
                query=query+sortedBy+' '+sortDirection+' nulls last ';
            }
            else
            {
            	query=query+sortedBy+' '+sortDirection+' ';    
            }
            
        }
        else
        {
            query+='ACV__c DESC ' + 'nulls last ';
        }
        query+='LIMIT :pageLimit OFFSET :off';
        List<Order_Tracker__c> OrdersPendingQROrderTrackerList =  Database.query(query);
        return OrdersPendingQROrderTrackerList;
    }
    
    
    //PO Pending for Booking
    @AuraEnabled
    public static Map<String,Object> getTotalApprovedForProcessingData()
    {
        Map<String,Object> response = new Map<String,Object>();
        Integer totalOrderTrackerRecords;
        Map<string,Object> totalSumListMainMap = new Map<string,Object>();
        try
        {
            totalSumListMainMap = getTotalSum('PO Pending for Booking');
            response.put('totalSum',totalSumListMainMap);
            totalOrderTrackerRecords=[SELECT Count() From Order_Tracker__c  Where Status__c = 'PO Pending for Booking' ];    
            response.put('Count',totalOrderTrackerRecords);
            if(totalOrderTrackerRecords < 15)
            {
                response.put('ApprovedForProcessingList',getNextApprovedForProcessingData(0,totalOrderTrackerRecords,'',''));
            }
            else
            {
                response.put('ApprovedForProcessingList',getNextApprovedForProcessingData(0,10,'',''));    
            }
        }
        catch(Exception ex)
        {
            System.debug('Error message'+ex.getMessage());
        }
        return response;
    }
    
    //PO Pending for Booking for pagination
    @AuraEnabled
    public static List<Order_Tracker__c> getNextApprovedForProcessingData(Integer pageNumber,Integer pageLimit,String sortedBy,String sortDirection)
    {
        integer off = pageNumber * pageLimit;
         String query='SELECT Id,End_User__c,Ticket__c,Proposal_for_initiating_QC__c,PO__c, SO__c, New_Upsell_ACV__c, Renewal_ACV__c, ACV__c, TCV__c,  Opportunity__r.Reason_for_5C__c, Live_Status_Change_Time_Difference__c , Opened_Since__c ';
        query+='FROM Order_Tracker__c Where Status__c = \'PO Pending for Booking\' ORDER BY ';
        if(sortedBy != NULL && sortedBy !='' && sortDirection!='')
        {
            if(sortDirection == 'desc')
            {
                query=query+sortedBy+' '+sortDirection+' nulls last ';
            }
            else
            {
            	query=query+sortedBy+' '+sortDirection+' ';    
            }
            
        }
        else
        {
            query+='ACV__c DESC ' + 'nulls last ';
        }
        query+='LIMIT :pageLimit OFFSET :off';
        List<Order_Tracker__c> ApprovedForProcessingOrderTrackerList =Database.query(query);
        return ApprovedForProcessingOrderTrackerList;
    }
    
    
    //PO Pending for QC 
    @AuraEnabled
    public static Map<String,Object> getTotalPOPendingForQCData()
    {
        Map<String,Object> response = new Map<String,Object>();
        Integer totalOrderTrackerRecords;
        Map<string,Object> totalSumListMainMap = new Map<string,Object>();
        try
        {
            totalSumListMainMap = getTotalSum('PO Pending for QC');
            response.put('totalSum',totalSumListMainMap);
            totalOrderTrackerRecords=[SELECT Count() From Order_Tracker__c Where Status__c = 'PO Pending for QC'];    
            response.put('Count',totalOrderTrackerRecords);
            if(totalOrderTrackerRecords < 15)
            {
                response.put('POPendingForQCList',getNextPOPendingForQCData(0,totalOrderTrackerRecords,'',''));
            }
            else
            {
                response.put('POPendingForQCList',getNextPOPendingForQCData(0,10,'',''));    
            }
        }
        catch(Exception ex)
        {
            System.debug('Error message'+ex.getMessage());
        }
        return response;
    }
    
    //PO Pending for QC for pagination
    @AuraEnabled
    public static List<Order_Tracker__c> getNextPOPendingForQCData(Integer pageNumber,Integer pageLimit,String sortedBy,String sortDirection)
    {
        integer off = pageNumber * pageLimit;
        String query='SELECT Id,End_User__c,Ticket__c,Proposal_for_initiating_QC__c,PO__c, SO__c, New_Upsell_ACV__c, Renewal_ACV__c, ACV__c, TCV__c, Opportunity__r.Reason_for_5C__c, Live_Status_Change_Time_Difference__c, Opened_Since__c ';
        query+='FROM Order_Tracker__c Where Status__c = \'PO Pending for QC\' ORDER BY ';
        if(sortedBy != NULL && sortedBy !='' && sortDirection!='')
        {
            if(sortDirection == 'desc')
            {
                query=query+sortedBy+' '+sortDirection+' nulls last ';
            }
            else
            {
            	query=query+sortedBy+' '+sortDirection+' ';    
            }
            
        }
        else
        {
            query+='ACV__c DESC ' + 'nulls last ';
        }
        query+='LIMIT :pageLimit OFFSET :off';
        List<Order_Tracker__c> POPendingForQCOrderTrackerList = Database.query(query);
        return POPendingForQCOrderTrackerList;
    }
        //PO Pending for re-qr
        @AuraEnabled
        public static Map<String,Object> getTotalPOPendingForReQRData()
        {
            Map<String,Object> response = new Map<String,Object>();
            Integer totalOrderTrackerRecords;
            Map<string,Object> totalSumListMainMap = new Map<string,Object>();
            try
            {
                totalSumListMainMap = getTotalSum('PO pending Re-QR');
                response.put('totalSum',totalSumListMainMap);
                totalOrderTrackerRecords=[SELECT Count() From Order_Tracker__c Where Status__c = 'PO pending Re-QR'];    
                response.put('Count',totalOrderTrackerRecords);
                if(totalOrderTrackerRecords < 15)
                {
                    response.put('respondedToRepList',getNextPOPendingForReQRData(0,totalOrderTrackerRecords,'',''));
                }
                else
                {
                    response.put('respondedToRepList',getNextPOPendingForReQRData(0,10,'',''));    
                }
            }
            catch(Exception ex)
            {
                System.debug('Error message'+ex.getMessage());
            }
            return response;
        }
        
        //PO Pending for re-qr for pagination 
        @AuraEnabled
        public static List<Order_Tracker__c> getNextPOPendingForReQRData(Integer pageNumber,Integer pageLimit,String sortedBy,String sortDirection)
        {
            integer off = pageNumber * pageLimit;
            String query='SELECT Id,Ticket__c,End_User__c,Proposal_for_initiating_QC__c,PO__c, SO__c, New_Upsell_ACV__c, Opportunity__r.Reason_for_5C__c, Renewal_ACV__c, ACV__c, Opened_Since__c, TCV__c,Live_Status_Change_Time_Difference__c ';
            query+='FROM Order_Tracker__c Where Status__c = \'PO pending Re-QR\' ORDER BY ';
            if(sortedBy != NULL && sortedBy !='' && sortDirection!='')
            {
                if(sortDirection == 'desc')
                {
                    query=query+sortedBy+' '+sortDirection+' nulls last ';
                }
                else
                {
                    query=query+sortedBy+' '+sortDirection+' ';    
                }
                
            }
            else
            {
                query+='ACV__c DESC ' + 'nulls last ';
            }
            query+='LIMIT :pageLimit OFFSET :off';
            List<Order_Tracker__c> POPendingForReQrOrderTrackerList =  Database.query(query);
            return POPendingForReQrOrderTrackerList;
        }
    
    
    // Get Data by Query for Exporting CSV files
    @AuraEnabled
    public static List<Order_Tracker__c> getDataForExporting(string statusVal){
        List<Order_Tracker__c> exportingData = [SELECT Id,End_User__c,Region__c,Proposal_for_initiating_QC__c, SO__c, 
                                                New_Upsell_ACV__c, Renewal_ACV__c, ACV__c, TCV__c, Opportunity__r.Reason_for_5C__c,
                                                Ticket__c, Live_Status_Change_Time_Difference__c, Opened_Since__c 
                                                    FROM Order_Tracker__c 
                                                    WHERE Status__c =: statusVal
                                                    ORDER BY ACV__c DESC Nulls last];
        return exportingData;
    }
    
    // Get total amount row in datatable
    public static Map<string,Object> getTotalSum(string status){
        Map<string,Object> totalSumMap = new Map<string,Object>();
        AggregateResult sumOfNewUpsell = [SELECT SUM(New_Upsell_ACV__c) FROM Order_Tracker__c Where Status__c =: status];
        AggregateResult sumOfRenewal = [SELECT SUM(Renewal_ACV__c) FROM Order_Tracker__c Where Status__c =: status];
        AggregateResult sumOfAcv = [SELECT SUM(ACV__c) FROM Order_Tracker__c Where Status__c =: status];
        AggregateResult sumOfTcv = [SELECT SUM(TCV__c) FROM Order_Tracker__c Where Status__c =: status];
        totalSumMap.put('upsell',(sumOfNewUpsell.get('expr0') ==null) ? 0 : sumOfNewUpsell.get('expr0'));
        totalSumMap.put('renewal',(sumOfRenewal.get('expr0') ==null) ? 0 : sumOfRenewal.get('expr0'));
        totalSumMap.put('acv',(sumOfAcv.get('expr0') ==null) ? 0 : sumOfAcv.get('expr0'));
        totalSumMap.put('tcv',(sumOfTcv.get('expr0') ==null) ? 0 : sumOfTcv.get('expr0'));
        return totalSumMap;
    }
    
    // Get Data for Exporting CSV files 
    @AuraEnabled
    public static Map<String,Object> getDataForExportingAll(){
        Map<String,Object> mainExportingAllMap = new Map<String,Object>();
        List<Order_Tracker__c> respondExportList = getDataForExporting('PO Pending with Sales');
        mainExportingAllMap.put('totalSumRespond',getTotalSum('PO Pending with Sales'));
        mainExportingAllMap.put('respond',respondExportList);
        List<Order_Tracker__c> orderPendingExportList = getDataForExporting('PO Pending for QR');
        mainExportingAllMap.put('totalSumOrdersPending',getTotalSum('PO Pending for QR'));
        mainExportingAllMap.put('QRpending',orderPendingExportList);
        List<Order_Tracker__c> approvedExportList = getDataForExporting('PO Pending for Booking');
        mainExportingAllMap.put('totalSumApproved',getTotalSum('PO Pending for Booking'));
        mainExportingAllMap.put('Approved',approvedExportList);
        List<Order_Tracker__c> poPendingExportList = getDataForExporting('PO Pending for QC');
        mainExportingAllMap.put('totalSumPoPending',getTotalSum('PO Pending for QC'));
        mainExportingAllMap.put('POpending',poPendingExportList);

        List<Order_Tracker__c> poReqrList = getDataForExporting('PO pending Re-QR');
        mainExportingAllMap.put('totalSumReqr',getTotalSum('PO pending Re-QR'));
        mainExportingAllMap.put('pendingReqr',poReqrList);
        
        return mainExportingAllMap;
    }
    @AuraEnabled
    public static String updateOpportunity(String json){
        List<fields> fieldList = parse(json);
        system.debug(fieldList);
        List<Opportunity> listOfOppty = new List<Opportunity>();
        for(fields fd : fieldList){
            Opportunity oppty = new Opportunity();
            oppty.Id = fd.Id;
            oppty.Reason_for_5C__c = fd.REASON;
            listOfOppty.add(oppty);
        }
        try{
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update listOfOppty;
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
            return 'success';
        }
        catch(Exception ex ){
            return ex.getMessage();
        } 
    }


        public class Fields {
           @AuraEnabled public String Id;
           @AuraEnabled public String REASON;
        }
    
        @AuraEnabled public Fields fields;
            
        @AuraEnabled
        public static List<Fields> parse(String json) {
            return (List<Fields>) System.JSON.deserialize(json, List<Fields>.class);
        }
}