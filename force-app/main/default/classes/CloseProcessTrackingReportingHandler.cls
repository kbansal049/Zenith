/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CloseProcessTrackingReportingHandler
* @description    Used for updating the Target Customer field in Deal_Reg__c
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-04-29
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* Ver   Date         Author        Modification
* 2.0   30-03-2022   Mahesh T      Fixed Issue CR#4548
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public with sharing class CloseProcessTrackingReportingHandler {
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Lazy initialization. 
    * This ensures that the singleton instance only consumes system resources when it is absolutely necessary.
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   CloseProcessTrackingReportingHandler    Instance of the class
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

    private static CloseProcessTrackingReportingHandler instance;
    public static CloseProcessTrackingReportingHandler getInstance() {
        if (instance == NULL) {
            instance = new CloseProcessTrackingReportingHandler();
        }

        return instance;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Setter method for dealRegList. 
    * This variables stores list of Deal_Reg__c records coming from Trigger.new
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    dealRegList    List of Deal_Reg__c records
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

    private List<Deal_Reg__c> dealRegList;
    private void setDealRegList(List<Deal_Reg__c> dealRegList) {

        List<Deal_Reg__c> dealRegFilteredList = new List<Deal_Reg__c>();

        for (Deal_Reg__c dealReg : dealRegList) {
          //  if (dealReg.Status__c == 'Submitted') {  //4548
                dealRegFilteredList.add(dealReg);
         //   }   
        }

        this.dealRegList = dealRegFilteredList;
    }
    
    private final Map<String, Schema.RecordTypeInfo> RECORD_TYPE_INFO_MAP = Schema.SObjectType.Account.getRecordTypeInfosByName();
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Setting up the record types for Partner Accounts
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

    private Set<Id> partnerRecordTypeIds;
    private void setPartnerRecordTypeIds() {
        
        partnerRecordTypeIds = new Set<Id>();
        partnerRecordTypeIds.add(RECORD_TYPE_INFO_MAP.get('Partner').getRecordTypeId());
        partnerRecordTypeIds.add(RECORD_TYPE_INFO_MAP.get('Partner DS Reviewed').getRecordTypeId());

    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Setting up the record types for Customer Accounts
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    
    private Set<Id> customerRecordTypeIds;
    private void setCustomerRecordTypeIds() {
        customerRecordTypeIds = new Set<Id>();
        customerRecordTypeIds.add(RECORD_TYPE_INFO_MAP.get('End User').getRecordTypeId());
        customerRecordTypeIds.add(RECORD_TYPE_INFO_MAP.get('End User - Prospect DS Reviewed').getRecordTypeId());
        customerRecordTypeIds.add(RECORD_TYPE_INFO_MAP.get('End User - Customer DS Reviewed').getRecordTypeId());
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Setting up the record types for both Partner and Customer Accounts
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    
    private void setupRecordTypes() {
        setPartnerRecordTypeIds();
        setCustomerRecordTypeIds();
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Setter method for partner record ids
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

	private Set<Id> partnerRecordIds;
	private void setPartnerRecordIds(Set<Id> partnerRecordIds) {
		this.partnerRecordIds = partnerRecordIds;
	}

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Setter method for dealRegDomainMap. This map stores the Deal_Reg__c record Id with the Domain.
    * This value will be used in other methods.
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    dealRegDomainMap    Map of Deal_Reg__c record id and domain
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

	private Map<Id, String> dealRegDomainMap;
	private void setDealregDomainMap(Map<Id, String> dealRegDomainMap) {
		this.dealRegDomainMap = dealRegDomainMap;
	}

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to generate and set the dealRegDomainMap. We are finding the domain from 
    * the End Customer Email if End Customer Domain is empty.
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

	private void generateDealRegDomainMap() {
		Set<Id> partnerRecordIds = new Set<Id>();
		Map<Id, String> dealRegDomainMap = new Map<Id, String>();

		for (Deal_Reg__c dealReg : dealRegList) {
            partnerRecordIds.add(dealReg.Partner_Account__c);
            
            String emailDomain = dealReg.End_Customer_Domain__c;

            if (String.isBlank(emailDomain)) {
                emailDomain = dealReg.End_Customer_Email__c;
            } 

            if (String.isBlank(emailDomain)) {
                continue;
            }

            emailDomain = emailDomain.subString(  (emailDomain.indexOf('@') + 1), emailDomain.length());  

            dealRegDomainMap.put(dealReg.Id, emailDomain);
        }
		setDealregDomainMap(dealRegDomainMap);
		setPartnerRecordIds(partnerRecordIds);
	}

	private Map<Id, Target_Customer__c> partnerAccountTargetCustomerMap;
	private void setPartnerAccountTargetCustomerMap(Map<Id, Target_Customer__c> partnerAccountTargetCustomerMap) {
		this.partnerAccountTargetCustomerMap = partnerAccountTargetCustomerMap;
	}

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to generate and set the setPartnerAccountTargetCustomerMap. We are finding 
    * Customer Accounts and Target Customers then creating a map of partner account id and 
    * target customer
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

	private void generatePartnerAccountTargetCustomerMap() {

        /** Finding the customer accounts having the related record type ids and Domain */
		List<Account> customerAccountList = [
            SELECT 
            	Id,
	            Name
            FROM
            	Account
            WHERE 
            	RecordTypeId IN :customerRecordTypeIds
            AND
            	Domain__c IN :dealRegDomainMap.values()
            ORDER BY 
                LastModifiedDate DESC
            LIMIT 50000	
        ];
        
        
        Map<Id, Target_Customer__c> partnerAccountTargetCustomerMap = new Map<Id, Target_Customer__c> ();
        
        for (Target_Customer__c targetCustomer : [
                                                    SELECT
                                                        Id,
                                                        Customer__c,
                                                        Partner__c
                                                    FROM
                                                        Target_Customer__c
                                                    WHERE
                                                        Customer__c IN :customerAccountList
                                                    AND
                                                        Partner__c IN :partnerRecordIds
                                                    LIMIT 1
                                                ]) {
            partnerAccountTargetCustomerMap.put(targetCustomer.Partner__c, targetCustomer);
        }
		setPartnerAccountTargetCustomerMap(partnerAccountTargetCustomerMap);
	}

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to update the Target_Customer__c according the filter criteria.
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

	private void updateTargetCustomer() {
		for (Deal_Reg__c dealReg : (List<Deal_Reg__c>) Trigger.new) {
            
			dealReg.Target_Customer__c = NULL;

			Boolean isPartnerAvailable = String.isNotBlank(String.valueOf(dealReg.Partner_Account__c));
			Boolean mapContainsKey = (partnerAccountTargetCustomerMap != NULL) 
				&& (!partnerAccountTargetCustomerMap.isEmpty())
				&& partnerAccountTargetCustomerMap.containsKey(dealReg.Partner_Account__c);

			if (isPartnerAvailable && mapContainsKey) {
				dealReg.Target_Customer__c = partnerAccountTargetCustomerMap.get(dealReg.Partner_Account__c).Id;
			}
			
        }
	}

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * This is the method called from trigger to associate a Target Customer to the Deal Registration.
    * The logic is to find the domain from the Deal Registration record and retrieve the latest
    * Target Customer record of an Account of Type Customer/Prospect whose Domain == Deal Registration Domain.
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    
    public void associateTargetCustomer() {
        setDealRegList((List<Deal_Reg__c>) Trigger.new);
        setupRecordTypes();
        generateDealRegDomainMap();
        generatePartnerAccountTargetCustomerMap();
        updateTargetCustomer();
        
    }

}