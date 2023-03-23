public class OpportunityContactTriggerHandler {
    public static void updateContact(List<Contact> listOfCon){
        List<Contact> contList = new List<Contact>();
        Set<Id> setOfId = new Set<Id>();
        Set<Id> setOfId2 = new Set<Id>();
        Set<Id> Fullcntctidset = new Set<Id>();
        for (Contact con :listOfCon ){
            system.debug('con '+con);       
            Fullcntctidset.add(con.id);
            for (OpportunityContactRole oppContactRole : con.OpportunityContactRoles ){
                system.debug('oppContactRole '+oppContactRole);
                Opportunity opp = oppContactRole.Opportunity;
                Contact c = new Contact(Id = oppContactRole.ContactId);
                if(opp.StageName != Label.Stage_6_Closed_Won && opp.StageName != Label.Stage_7_Closed_Lost) {
                    system.debug('in if part,  opp stage is not closed won/lost');
                        //c.Contact_Lead_Status__c = 'Actively Engaged';                        
                        setOfId.add(c.id);                      
                        if(!oppContactRole.IsPrimary){
                            system.debug('inside if opp contact is not primary');
                            setOfId2.add(c.id);
                        }
                }else{
                    system.debug('in else part');
                    //setOfId.add(c.id);
                }
                
                
            }
            
        }
        
        system.debug('setOfId   '+setOfId);
        system.debug('setOfId2  '+setOfId2);
        
        for (Contact con :listOfCon ){
                Contact c = new Contact(Id = con.Id);
                if(setOfId.contains(con.Id)){   
                    system.debug('in if part');
                    c.Involved_in_Active_Oppty__c = true;
                }else{
                    system.debug('in else part');
                    c.Involved_in_Active_Oppty__c = false;
                }
                
                if(setOfId2.contains(con.Id)){  //if Opp Contact Role is not primary on Active Opportunities
                    system.debug('in if part of setOfId2 ');
                    c.Contact_Lead_Status__c = 'Actively Engaged';  
                }               
                contList.add(c);
        }
        
        if(!contList.isEmpty()) update contList;
        
    }
    
}