trigger UpdateTouchesOnContactOnTaskInsertUpdate on Task  (after insert,after update){
    List<Id> contact_ids = new List<Id>();

    for(Task t : trigger.new){
        //if the whoid is a contact and the status is completed
        //system.debug('task  '+t);
        if(trigger.isinsert){
            //system.debug('in insert ');
            if(t.WhoId != null && String.Valueof(t.WhoId).substring(0,3) == '003' && t.Status == 'Completed'){
            //system.debug('task  inside if  '+t);
            contact_ids.add(t.WhoId);       
            }
        }      
        else if(trigger.isupdate){      
            //system.debug('in update ');
            if(t.WhoId != null && String.Valueof(t.WhoId).substring(0,3) == '003' && t.Status == 'Completed' && t.Status!=trigger.oldmap.get(t.id).Status){contact_ids.add(t.WhoId);       
            }
        }
    }
    //if the id list is not empty
    if(!contact_ids.isEmpty()){
        UpdateTouchesHandler up = new UpdateTouchesHandler();
        up.updateTouchesTaskEvent(contact_ids);
        
    }
    
}