public class OpportunityNOTRAHandler {
    //public static Set<String> ForeCastCategorySet = new Set<String>{'Most Likely','Commit','Closed'};
    public Static void beforeUpdate(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap){
        
        quarterDetailsInner currentQuarterDetails = getQuarter(system.today().month(), system.today().year());
        
        for(Opportunity oppRec : newOpportunitiesMap.values()){
            if(oppRec.CloseDate != null && oppRec.Contract_End_Date_New__c != null  && (oppRec.CloseDate != oldOpportunitiesMap.get(oppRec.Id).CloseDate || oppRec.Contract_End_Date_New__c != oldOpportunitiesMap.get(oppRec.Id).Contract_End_Date_New__c)){ // && oppRec.Type == 'Existing Customer (Renewal)'
               // if(!String.isBlank(oppRec.CRO_Forecast_Category__c)){
                 //   if(ForeCastCategorySet.contains(oppRec.CRO_Forecast_Category__c)){
                        quarterDetailsInner closeDateQuarterDetails = getQuarter(oppRec.CloseDate.month(), oppRec.CloseDate.year());
                        quarterDetailsInner contractEndDateQuarterDetails = getQuarter(oppRec.Contract_End_Date_New__c.month(), oppRec.Contract_End_Date_New__c.year());
                        
                        system.debug('the currentQuarterDetails details here' + currentQuarterDetails);
                        system.debug('the currentQuarterDetails details here' + closeDateQuarterDetails);
                        system.debug('the currentQuarterDetails details here' + contractEndDateQuarterDetails);
                        // Removed "oppRec.Renewal_VP_In_my_Number__c" by Swathi CR:731
                        if(closeDateQuarterDetails.quarterYear == contractEndDateQuarterDetails.quarterYear){
                            if(closeDateQuarterDetails.quarterNumber == contractEndDateQuarterDetails.quarterNumber){
                                //if(closeDateQuarterDetails.quarterNumber == currentQuarterDetails.quarterNumber && closeDateQuarterDetails.quarterYear == currentQuarterDetails.quarterYear){
                                    oppRec.NOTRA__c = 'On Time';
                                //}
                            } 
                            else if(closeDateQuarterDetails.quarterNumber < contractEndDateQuarterDetails.quarterNumber){
                                if(closeDateQuarterDetails.quarterNumber == currentQuarterDetails.quarterNumber){
                                    //if(oppRec.Renewal_VP_In_my_Number__c)  { commented by Swathi CR:731
                                    	oppRec.NOTRA__c = 'Future';
                                        oppRec.Prior_Early__c = True;
                                }
                                
                            }
                            // Removed "oppRec.Renewal_VP_In_my_Number__c" by Swathi CR:731
                            else if(closeDateQuarterDetails.quarterNumber > contractEndDateQuarterDetails.quarterNumber){
                            	oppRec.NOTRA__c = 'Late';
                                
                            }
                        }
                        else{
                            if(contractEndDateQuarterDetails.quarterYear > closeDateQuarterDetails.quarterYear){
                                if(closeDateQuarterDetails.quarterNumber == currentQuarterDetails.quarterNumber){
                                    //if(oppRec.Renewal_VP_In_my_Number__c)  { commented by Swathi CR:731
                                    oppRec.NOTRA__c = 'Future';
                                    oppRec.Prior_Early__c = True;   
                                }
                            }
                            // Removed "oppRec.Renewal_VP_In_my_Number__c" by Swathi CR:731
                            else if(contractEndDateQuarterDetails.quarterYear < closeDateQuarterDetails.quarterYear){
                                oppRec.NOTRA__c = 'Late';
                            }
                            
                        }
                   // }   
                //}
            }
        }
        
    }
    
    public static quarterDetailsInner getQuarter(Integer month, Integer year){
        
        quarterDetailsInner quarterDetails = new quarterDetailsInner();
        
        if(month == 11 || month == 12 || month == 1){
            if(month == 11 || month == 12){
                quarterDetails.quarterNumber = 2;
                quarterDetails.quarterYear = year + 1;
                return quarterDetails;
            }
            else{
                quarterDetails.quarterNumber = 2;
                quarterDetails.quarterYear = year;
                return quarterDetails;
            }
        }
        else if(month == 2 || month == 3 || month == 4){
            quarterDetails.quarterNumber = 3;
            quarterDetails.quarterYear = year;
            return quarterDetails;
        }
        else if(month == 5 || month == 6 || month == 7){
            quarterDetails.quarterNumber = 4;
            quarterDetails.quarterYear = year;
            return quarterDetails;  
        }
        else if(month == 8 || month == 9 || month == 10){
            quarterDetails.quarterNumber = 1;
            quarterDetails.quarterYear = year + 1;
            return quarterDetails;
        }
        return quarterDetails;
    }
    
    public class quarterDetailsInner{
        public integer quarterNumber;
        public integer quarterYear;
    }
}