/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CustomOrderTriggerHandler
* @description    This is the Custom Order Trigger handler class called synchronously from CustomOrderTrigger.
* 					should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Viral
* @modifiedBy     Viral
* @maintainedBy   Viral
* @version        1.0
* @created        2022-03-08
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Viral  - Populate Region, location ID based on the Proposal/Quote Account
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public without sharing class CustomOrderTriggerHandler extends TriggerHandler {
    
    public static Boolean prePopulationDone = false;
    
    
    
    public override void beforeInsert() {
        prePopulateDetailsBeforeSave((List<Custom_order__c>) trigger.new);
    }
    
    public override void beforeUpdate() {    
        prePopulateDetailsBeforeSave((List<Custom_order__c>) trigger.new);
    }
    
    
    @testVisible
    private static void prePopulateDetailsBeforeSave(List<Custom_order__c> custOrderList){
			
		//Call only Once
		if(prePopulationDone){
			return;
		}else{
			prePopulationDone = true;
		}
		
        system.debug('--prePopulateDetailsBeforeSave--called---');
        
        
        
        //populate Country Code, State Code, NS Location Id
        
        Set<Id> accIDSet = new Set<ID>();
        set<ID> oppIds = new Set<ID>();
        for(Custom_order__c co: custOrderList){
            if(co.Bill_To_Account__c != null){
                accIDSet.add(co.Bill_To_Account__c);
            }
            if(co.Proposal_Account__c != null){
                accIDSet.add(co.Proposal_Account__c);
            }
            if(co.Proposal_Opportunity__c != null){
                oppIds.add(co.Proposal_Opportunity__c);
            }
        }
        
        MAP<ID,Account> accMAP = new MAP<ID,Account>([Select ID,Name,BillingCountry,BillingState from  Account where id in : accIDSet]);
        
        for(Custom_order__c co : custOrderList){
            
            //Ship to Details
            if(co.Proposal_Account__c != null){
                Account propAccount = accMAP.get(co.Proposal_Account__c);
                String country  = propAccount.BillingCountry;
                String BillingState = propAccount.BillingState;
                
                //Prepopulate Location ID
                String usaBillingStateLocationCode = null;
                if(country == 'USA' || country == 'United States' || country == 'US'){
                    usaBillingStateLocationCode = getLocationIDFromUSAState(BillingState);
                }
                
                String countryLocationCode =  getLocationIDFromCountry(country);
                String x2DigitISOCode = getLocationIDFrom2xDigitISOCountry(country);
                String x3DigitISOCode = getLocationIDFrom3xDigitISOCountry(country);
                
                if(usaBillingStateLocationCode != null){
                    co.NS_Location_Id__c = usaBillingStateLocationCode;
                }else if(countryLocationCode != null){
                    co.NS_Location_Id__c = countryLocationCode;
                }else if(x2DigitISOCode != null){
                    co.NS_Location_Id__c = x2DigitISOCode;
                }else if(x3DigitISOCode != null){
                    co.NS_Location_Id__c = x3DigitISOCode;
                }
                
                
                //Prepopulate Region
                
                String usaBillingStateRegion = null;
                if(country == 'USA' || country == 'United States' || country == 'US'){
                    usaBillingStateRegion = getRegionFromUSAState(BillingState);
                }
                
                String countryRegion =  getRegionFromCountry(country);
                String x2DigitRegionCode = getRegionFrom2xDigitISOCountry(country);
                String x3DigitRegionCode = getRegionFrom3xDigitISOCountry(country);
                
                if(usaBillingStateRegion != null){
                    co.NS_ShipTo_Region_ID__c = usaBillingStateRegion;
                }else if(countryRegion != null){
                    co.NS_ShipTo_Region_ID__c = countryRegion;
                }else if(x2DigitRegionCode != null){
                    co.NS_ShipTo_Region_ID__c = x2DigitRegionCode;
                }else if(x3DigitRegionCode != null){
                    co.NS_ShipTo_Region_ID__c  = x3DigitRegionCode;
                }
                
                
                //Prepopulate NS_ShipTo_Country__c
                String nsCountryCode = getNSCountryCodeFromCountry(country);
                String x2DigitCountryCode = getNSCountryCodeFrom2xDigitISOCountry(country);
                String x3DigitCountryCode = getNSCountryCodeFrom3xDigitISOCountry(country);
                
                if(nsCountryCode != null){
                    co.NS_ShipTo_Country__c = nsCountryCode;
                }else if(x2DigitCountryCode != null){
                    co.NS_ShipTo_Country__c = x2DigitCountryCode;
                }else if(x3DigitCountryCode != null){
                    co.NS_ShipTo_Country__c = x3DigitCountryCode;
                }
                
                //Prepopulate NS_ShipTo_State__c
                String nsStateCode = getNSSateCodeFromCountry(BillingState);
                co.NS_ShipTo_State__c = nsStateCode  != null ? nsStateCode : BillingState;
            }
            
            
            //Bill to Details
            if(co.Bill_To_Account__c != null){
                Account BilltoAccount = accMAP.get(co.Bill_To_Account__c);
                String country  = BilltoAccount.BillingCountry;
                String BillingState = BilltoAccount.BillingState;
                
                
                //Prepopulate NS_Region_ID__c
                String usaBillingStateRegion = null;
                if(country == 'USA' || country == 'United States' || country == 'US'){
                    usaBillingStateRegion = getRegionFromUSAState(BillingState);
                }
                
                String countryRegion =  getRegionFromCountry(country);
                String x2DigitRegionCode = getRegionFrom2xDigitISOCountry(country);
                String x3DigitRegionCode = getRegionFrom3xDigitISOCountry(country);
                
                if(usaBillingStateRegion != null){
                    co.NS_Region_ID__c = usaBillingStateRegion;
                }else if(countryRegion != null){
                    co.NS_Region_ID__c = countryRegion;
                }else if(x2DigitRegionCode != null){
                    co.NS_Region_ID__c = x2DigitRegionCode;
                }else if(x3DigitRegionCode != null){
                    co.NS_Region_ID__c = x3DigitRegionCode;
                }
                
                //Prepopulate NS_BillTo_Country__c
                String nsCountryCode = getNSCountryCodeFromCountry(country);
                String x2DigitCountryCode = getNSCountryCodeFrom2xDigitISOCountry(country);
                String x3DigitCountryCode = getNSCountryCodeFrom3xDigitISOCountry(country);
                
                if(nsCountryCode != null){
                    co.NS_BillTo_Country__c = nsCountryCode;
                }else if(x2DigitCountryCode != null){
                    co.NS_BillTo_Country__c = x2DigitCountryCode;
                }else if(x3DigitCountryCode != null){
                    co.NS_BillTo_Country__c = x3DigitCountryCode;
                }
                
                //Prepopulate NS_BillTo_State__c                
                String nsStateCode = getNSSateCodeFromCountry(BillingState);
                co.NS_BillTo_State__c = nsStateCode  != null ? nsStateCode : BillingState;
            }
        }
        
        
        
        
        
        //Populate NS Department ID
        MAP<ID, Opportunity> oppmap = new map<ID, opportunity>([Select id,name,Type,Number_Of_Upsell_Split_Lines__c,
                                                                Renewal_Rep_ZNumber__c,Opportunity_Owner_zNumber__c,Account_Channel_Rep_ZNumber__c 
                                                                from opportunity where id in : oppIds]);
        
        Set<String> repIDSet = new Set<String>();
        
        for(opportunity opp : oppmap.values()){
            if(opp.Opportunity_Owner_zNumber__c != null){
                repIDSet.add(opp.Opportunity_Owner_zNumber__c);
            }
            if(opp.Account_Channel_Rep_ZNumber__c != null){
                repIDSet.add(opp.Account_Channel_Rep_ZNumber__c);
            }
            if(opp.Renewal_Rep_ZNumber__c != null){
                repIDSet.add(opp.Renewal_Rep_ZNumber__c);
            }
        }
        
        MAP<String,User> userEmpMAP = new MAP<String,User>();
        for(User usr : [Select ID,EmployeeNumber,NS_Finance_Department_Code__c from  User where EmployeeNumber in : repIDSet and EmployeeNumber != null]){
            userEmpMAP.put(usr.EmployeeNumber, usr);
        }
        
        for(Custom_order__c co : custOrderList){  
            
            if(co.Proposal_Opportunity__c != null && oppmap.containskey(co.Proposal_Opportunity__c)){
                
                Opportunity oppRecord = oppmap.get(co.Proposal_Opportunity__c);
                
                String channelRep = oppRecord.Account_Channel_Rep_ZNumber__c != null ? oppRecord.Account_Channel_Rep_ZNumber__c : 'Z12060'; 
                String renewalRep = oppRecord.Renewal_Rep_ZNumber__c != null ? oppRecord.Renewal_Rep_ZNumber__c : 'Z12060'; 
                String salesRep = oppRecord.Opportunity_Owner_zNumber__c != null ? oppRecord.Opportunity_Owner_zNumber__c : 'Z12060'; 
                
                String department = null;
                
                if(oppRecord.Type.equalsIgnoreCase('New Business') 
                   || oppRecord.Type.equalsIgnoreCase('NFR (Not For Resale)') 
                   ||  oppRecord.Type.equalsIgnoreCase('Existing Customer (Add On)'))
                {
                    department = salesRep;
                }else if(oppRecord.Type.equalsIgnoreCase('Existing Customer (Renewal)')){
                    Double f = oppRecord.Number_Of_Upsell_Split_Lines__c != null ? oppRecord.Number_Of_Upsell_Split_Lines__c : 0;
                    if(f == 0){
                        department = renewalRep;
                    }else{
                        department = salesRep;                   
                    }
                }
                if(department != null && userEmpMAP.containskey(department)){
                    co.NS_Department_ID__c = userEmpMAP.get(department).NS_Finance_Department_Code__c;
                }
            } 
            
        }
        
        
    }
    
    
    //get List of all Location Mapping
    public static List<NS_Billing_Country_and_Area_Mapping__mdt> BillingAreaMap {
        get{
            if(BillingAreaMap == null){
                BillingAreaMap = [Select X2_Digit_ISO_Code__c,X3_Digit_Code__c,Country__c,Location_ID__c,Region__c,State__c,State_Full_Name__c from NS_Billing_Country_and_Area_Mapping__mdt];
            }
            return BillingAreaMap;
        }
        set;
    }
    
    
    //get List of all County Mapping
    public static List<NS_Country_Code__mdt> CountryCodeMap {
        get{
            if(CountryCodeMap == null){
                CountryCodeMap = [Select X2_Digit_ISO_Code__c,X3_Digit_Code__c,Country__c,NS_Code__c from NS_Country_Code__mdt];
            }
            return CountryCodeMap;
        }
        set;
    }
    
    
    //get List of all State Mapping
    public static List<NS_State_Code__mdt> StateCodeMap {
        get{
            if(StateCodeMap == null){
                StateCodeMap = [Select State_Code__c,State_Name__c from NS_State_Code__mdt];
            }
            return StateCodeMap;
        }
        set;
    }
    
    
    //Ger LoactionID From the NS_Billing_Country_and_Area_Mapping__mdt
    
    @testvisible
    private static String getLocationIDFromCountry(String Country){
        return countryLocationMAp.containsKey(Country) ?  countryLocationMAp.get(Country) : null;
    }
    
    @testvisible
    private static String getLocationIDFromUSAState(String BillingState){
        return usaStateLocationMAp.containsKey(BillingState) ?  usaStateLocationMAp.get(BillingState) : null;
    }
    
    @testvisible
    private static String getLocationIDFrom3xDigitISOCountry(String Country){
        return x3DigitCountryISOLocationMAP.containsKey(Country) ?  x3DigitCountryISOLocationMAP.get(Country) : null;
    }
    
    @testvisible
    private static String getLocationIDFrom2xDigitISOCountry(String Country){
        return x2DigitCountryISOLocationMAP.containsKey(Country) ?  x2DigitCountryISOLocationMAP.get(Country) : null;
    }
    
    public static MAP<String, String> usaStateLocationMAp{
        get {
            if(usaStateLocationMAp == null){
                usaStateLocationMAp = new MAP<String, String>();
                
                for(NS_Billing_Country_and_Area_Mapping__mdt nsMap : BillingAreaMap){
                    if(nsMap.Country__c == 'United States'){
                        usaStateLocationMAp.put(nsMap.State_Full_Name__c, nsMap.Location_ID__c);
                        usaStateLocationMAp.put(nsMap.State__c, nsMap.Location_ID__c);
                    }
                }
            }
            return usaStateLocationMAp;
        }
        set;
    }

    public static MAP<String, String> countryLocationMAp{
        get {
            if(countryLocationMAp == null){
                countryLocationMAp = new MAP<String, String>();
                
                for(NS_Billing_Country_and_Area_Mapping__mdt nsMap : BillingAreaMap){
                    if(nsMap.Country__c != null && nsMap.Location_ID__c != null){
                        countryLocationMAp.put(nsMap.Country__c, nsMap.Location_ID__c);
                    }
                }
            }
            return countryLocationMAp;
        }
        set;
    }
    
    public static MAP<String, String> x3DigitCountryISOLocationMAP{
        get {
            if(x3DigitCountryISOLocationMAP == null){
                x3DigitCountryISOLocationMAP = new MAP<String, String>();
                
                for(NS_Billing_Country_and_Area_Mapping__mdt nsMap : BillingAreaMap){
                    if(nsMap.X3_Digit_Code__c != null){
                        x3DigitCountryISOLocationMAP.put(nsMap.X3_Digit_Code__c, nsMap.Location_ID__c);
                    }
                }
            }
            return x3DigitCountryISOLocationMAP;
        }
        set;
    }
    
    public static MAP<String, String> x2DigitCountryISOLocationMAP{
        get {
            if(x2DigitCountryISOLocationMAP == null){
                x2DigitCountryISOLocationMAP = new MAP<String, String>();
                
                for(NS_Billing_Country_and_Area_Mapping__mdt nsMap : BillingAreaMap){
                    if(nsMap.X2_Digit_ISO_Code__c != null){
                        x2DigitCountryISOLocationMAP.put(nsMap.X2_Digit_ISO_Code__c, nsMap.Location_ID__c);
                    }
                }
            }
            return x2DigitCountryISOLocationMAP;
        }
        set;
    }
    
    
    
    
    //Get Region From the NS_Billing_Country_and_Area_Mapping__mdt
    
    @testvisible
    private static String getRegionFromCountry(String Country){
        return countryRegionMap.containsKey(Country) ?  countryRegionMap.get(Country) : null;
    }
    
    @testvisible
    private static String getRegionFromUSAState(String BillingState){
        return usaStateRegionMap.containsKey(BillingState) ?  usaStateRegionMap.get(BillingState) : null;
    }
    
    @testvisible
    private static String getRegionFrom3xDigitISOCountry(String Country){
        return x3ISOCountryRegionMAP.containsKey(Country) ?  x3ISOCountryRegionMAP.get(Country) : null;
    }
    
    @testvisible
    private static String getRegionFrom2xDigitISOCountry(String Country){
        return x2ISOCountryRegionMAP.containsKey(Country) ?  x2ISOCountryRegionMAP.get(Country) : null;
    }
    
    
    public static MAP<String, String> usaStateRegionMap{
        get {
            if(usaStateRegionMap == null){
                usaStateRegionMap = new MAP<String, String>();
                for(NS_Billing_Country_and_Area_Mapping__mdt nsMap : BillingAreaMap){
                    if(nsMap.Country__c == 'United States' && nsMap.Region__c != null){
                        usaStateRegionMap.put(nsMap.State_Full_Name__c, nsMap.Location_ID__c);
                        usaStateRegionMap.put(nsMap.State__c, nsMap.Location_ID__c);
                    }
                }
            }
            return usaStateRegionMap;
        }
        set;
    }
    
    public static MAP<String, String> countryRegionMap{
        get {
            if(countryRegionMap == null){
                countryRegionMap = new MAP<String, String>();
                for(NS_Billing_Country_and_Area_Mapping__mdt nsMap : BillingAreaMap){
                    if(nsMap.Country__c != null && nsMap.Location_ID__c != null){
                        countryRegionMap.put(nsMap.Country__c, nsMap.Location_ID__c);
                    }
                }
            }
            return countryRegionMap;
        }
        set;
    }
    
    public static MAP<String, String> x3ISOCountryRegionMAP{
        get {
            if(x3ISOCountryRegionMAP == null){
                x3ISOCountryRegionMAP = new MAP<String, String>();
                for(NS_Billing_Country_and_Area_Mapping__mdt nsMap : BillingAreaMap){
                    if(nsMap.X3_Digit_Code__c != null && nsMap.Location_ID__c != null){
                        x3ISOCountryRegionMAP.put(nsMap.X3_Digit_Code__c, nsMap.Location_ID__c);
                    }
                }
            }
            return x3ISOCountryRegionMAP;
        }
        set;
    }
    
    public static MAP<String, String> x2ISOCountryRegionMAP{
        get {
            if(x2ISOCountryRegionMAP == null){
                x2ISOCountryRegionMAP = new MAP<String, String>();
                for(NS_Billing_Country_and_Area_Mapping__mdt nsMap : BillingAreaMap){
                    if(nsMap.X2_Digit_ISO_Code__c != null && nsMap.Location_ID__c != null){
                        x2ISOCountryRegionMAP.put(nsMap.X2_Digit_ISO_Code__c, nsMap.Location_ID__c);
                    }
                }
            }
            return x2ISOCountryRegionMAP;
        }
        set;
    }
    
    
    //Get NSCountryCode From the NS_Country_Code__mdt
    
    @testvisible
    private static String getNSCountryCodeFrom3xDigitISOCountry(String Country){
        return x3ISOCountryMAP.containsKey(Country) ?  x3ISOCountryMAP.get(Country) : null;
    }
    
    @testvisible
    private static String getNSCountryCodeFrom2xDigitISOCountry(String Country){
        return x2ISOCountryMAP.containsKey(Country) ?  x2ISOCountryRegionMAP.get(Country) : null;
    }
    
    @testvisible
    private static String getNSCountryCodeFromCountry(String Country){
        return nsCountryCodeMap.containsKey(Country) ?  nsCountryCodeMap.get(Country) : null;
    }
    
    
    public static MAP<String, String> nsCountryCodeMap{
        get {
            if(nsCountryCodeMap == null){
                nsCountryCodeMap = new MAP<String, String>();
                for(NS_Country_Code__mdt nsMap : CountryCodeMap){
                    if(nsMap.Country__c != null && nsMap.NS_Code__c != null){
                        nsCountryCodeMap.put(nsMap.Country__c, nsMap.NS_Code__c);
                    }
                }
            }
            return nsCountryCodeMap;
        }
        set;
    }
    
    
    public static MAP<String, String> x3ISOCountryMAP{
        get {
            if(x3ISOCountryMAP == null){
                x3ISOCountryMAP = new MAP<String, String>();
                for(NS_Country_Code__mdt nsMap : CountryCodeMap){
                    if(nsMap.X3_Digit_Code__c != null && nsMap.NS_Code__c != null){
                        x3ISOCountryMAP.put(nsMap.X3_Digit_Code__c, nsMap.NS_Code__c);
                    }
                }
            }
            return x3ISOCountryMAP;
        }
        set;
    }
    
    public static MAP<String, String> x2ISOCountryMAP{
        get {
            if(x2ISOCountryMAP == null){
                x2ISOCountryMAP = new MAP<String, String>();
                for(NS_Country_Code__mdt nsMap : CountryCodeMap){
                    if(nsMap.X2_Digit_ISO_Code__c != null && nsMap.NS_Code__c != null){
                        x2ISOCountryMAP.put(nsMap.X2_Digit_ISO_Code__c, nsMap.NS_Code__c);
                    }
                }
            }
            return x2ISOCountryMAP;
        }
        set;
    }
    
    
    //Get StateCode From the NS_State_Code__mdt
    
    @testvisible
    private static String getNSSateCodeFromCountry(String state){
        return nsStateCodeMap.containsKey(state) ?  nsStateCodeMap.get(state) : null;
    }
    
    public static MAP<String, String> nsStateCodeMap{
        get {
            if(nsStateCodeMap == null){
                nsStateCodeMap = new MAP<String, String>();
                for(NS_State_Code__mdt nsMap : StateCodeMap){
                    if(nsMap.State_Name__c != null && nsMap.State_Code__c != null){
                        nsStateCodeMap.put(nsMap.State_Name__c, nsMap.State_Code__c);
                    }
                }
            }
            return nsStateCodeMap;
        }
        set;
    }
}