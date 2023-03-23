public class BR_Trigger_Handler{
    
    
    public static void onbeforeInsert(List<Event_Expenditure_Request__c> newlist){
        //CR# 496
        fillUserManagerManager(newlist);
    }
    
    
    public static void onbeforeupdate(List<Event_Expenditure_Request__c> newlist, Map<Id, Event_Expenditure_Request__c> oldmap){
        Map<Id, Event_Expenditure_Request__c> brneedssignature = new Map<Id, Event_Expenditure_Request__c>();
        if(!TriggerUtility.isBRAttachmentValidationExecuted()){
            for(Event_Expenditure_Request__c br: newlist){
                if(br.Does_this_contract_require_signature__c == 'Yes'){
                    brneedssignature.put(br.Id, br);
                }
            }
            checkAttachmentforBRrequiringSignature(brneedssignature);
        }
        
        //CR# 496
       	fillUserManagerManager(newlist);    
    }
    
    public static void checkAttachmentforBRrequiringSignature(Map<Id, Event_Expenditure_Request__c> brneedssignature){
        for(Attachment att: [Select Id, ParentId from Attachment where ParentId in :brneedssignature.keyset()]){
            brneedssignature.remove(att.ParentId);
        }
        
        for(Event_Expenditure_Request__c br: brneedssignature.values()){
            br.addError('Please attach a document as this contract needs Signature.');
        }
        TriggerUtility.BRAttachmentValidationExecuted();
    
    }
    
    
    //CR# 496 Fill User Manager Manager Field
    public static void fillUserManagerManager(List<Event_Expenditure_Request__c> newlist){
        
        String userMangerManager = null;
        User current_user = [SELECT Id,managerid FROM User WHERE  Id= :UserInfo.getUserId()];
        System.debug('--current_user--'+current_user);
        if(current_user.managerid != null){
            User manager = [SELECT Id,managerid FROM User WHERE  Id= :current_user.managerid];
            System.debug('--manager--'+manager);
            if(manager.managerid != null){
                userMangerManager = manager.managerid;
            }
        }
        
        MAP<ID,ID> erOwnerMAP = new MAP<ID,ID>();
        for(Event_Expenditure_Request__c br: newlist){
            erOwnerMAP.put(br.id,br.OwnerId);
        }
        MAP<ID,ID> ownerManagerMAP = new MAP<ID,ID>();
        List<User> ownerList = [SELECT Id,managerid FROM User WHERE  Id in :erOwnerMAP.values()];
        for(User usr: ownerList){
            if(usr.managerid != null){
                ownerManagerMAP.put(usr.id,usr.managerid);
            }
        }
        MAP<ID,ID> managerManagerMAP = new MAP<ID,ID>();
        List<User> managerList = [SELECT Id,managerid FROM User WHERE  Id in :ownerManagerMAP.values()];
        for(User usr: managerList){
            if(usr.managerid != null){
                managerManagerMAP.put(usr.id,usr.managerid);
            }
        }
        
        for(Event_Expenditure_Request__c br: newlist){
            if(erOwnerMAP.containskey(br.id) && ownerManagerMAP.containskey(br.ownerid)){
                id ownerManagerID = ownerManagerMAP.get(br.ownerid);
                if(managerManagerMAP.containskey(ownerManagerID) && managerManagerMAP.get(ownerManagerID) != null){
                    br.User_Managers_Manager__c = managerManagerMAP.get(ownerManagerID);
                }else{
                    br.User_Managers_Manager__c = null;
                }
            }else{
                br.User_Managers_Manager__c = null;
            }
        }
    }

}