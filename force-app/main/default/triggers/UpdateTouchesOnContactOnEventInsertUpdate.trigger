trigger UpdateTouchesOnContactOnEventInsertUpdate on Event (after insert, after update){
    List<Id> contact_ids = new List<Id>();
    for(Event t : trigger.new){
        //if the whoid is a contact and the status is completed
        //system.debug('event '+t);
        if(t.WhoId != null && String.Valueof(t.WhoId).substring(0,3) == '003'){//  && t.Status == 'Completed'  && t.StartDateTime  >= SYstem.today() 
            //system.debug('in if condition');
            contact_ids.add(t.WhoId);
           
        }
    }
    system.debug('contact_ids '+contact_ids);
    
    //if the id list is not empty
    if(!contact_ids.isEmpty()){
        UpdateTouchesHandler up = new UpdateTouchesHandler();
        up.updateTouchesTaskEvent(contact_ids);
       
    }
    
}