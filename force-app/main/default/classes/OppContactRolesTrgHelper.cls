public class OppContactRolesTrgHelper {
    public static void process(List<OpportunityContactRole> triggerNew){       
        Id renewalRecordTypeId;//Added By Sarjan
        List<Recordtype> recordtypelist = new list<Recordtype>();
        recordtypelist = [SELECT Id FROM RecordType WHERE DeveloperName = 'Renewal_Opportunity' AND sObjectType = 'Opportunity'];
        if(recordtypelist.size() > 0) {
            renewalRecordTypeId = recordtypelist[0].Id;
        } 
        Set<Id> conIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Opportunity> oppToUpdateMap = new Map<Id,Opportunity>();
        Map<Id,Contact> conToUpdateMap = new Map<Id,Contact>();//Added by Anup : CR#1122
        for(OpportunityContactRole ocr : triggerNew){
            conIds.add(ocr.ContactId);
            oppIds.add(ocr.OpportunityId);
        }
        Map<Id,Opportunity> oppMap = getOppMap(oppIds);
        Map<Id,Contact> conMap = getContactMap(conIds);
        
        for(OpportunityContactRole ocr : triggerNew){
            if(ocr.IsPrimary && oppMap.containsKey(ocr.OpportunityId) && conMap.containsKey(ocr.ContactId)&&oppMap.get(ocr.OpportunityId).RecordtypeId!=renewalRecordTypeId){
                Opportunity opp = new Opportunity(
                    Id = ocr.OpportunityId,
                    //Commented by Anup : CR#1122
                    /*Qualification_Notes__c = conMap.get(ocr.ContactId).Qualification_Notes__c ,
                    Qualified_Date__c = conMap.get(ocr.ContactId).Qualified_Date__c,
                    LDR_Name__c = conMap.get(ocr.ContactId).Qualifying_SDR__c*/
                    //Added By Anup : CR#1122 - Start
                    Qualification_Notes__c = oppMap.get(ocr.OpportunityId).Qualification_Notes__c != null ? oppMap.get(ocr.OpportunityId).Qualification_Notes__c:conMap.get(ocr.ContactId).Qualification_Notes__c,
                    Qualified_Date__c = oppMap.get(ocr.OpportunityId).Qualified_Date__c != null ? oppMap.get(ocr.OpportunityId).Qualified_Date__c:conMap.get(ocr.ContactId).Qualified_Date__c,
                    LDR_Name__c = oppMap.get(ocr.OpportunityId).LDR_Name__c != null ? oppMap.get(ocr.OpportunityId).LDR_Name__c:conMap.get(ocr.ContactId).Qualifying_SDR__c,
                    Qualifier_Role__c = oppMap.get(ocr.OpportunityId).LDR_Name__c != null ? oppMap.get(ocr.OpportunityId).LDR_Name__r.UserRole.Name : conMap.get(ocr.ContactId).Qualifying_SDR__c != null ? conMap.get(ocr.ContactId).Qualifying_SDR__r.UserRole.Name:null
                	//Added By Anup : CR#1122 - End
                );
                oppToUpdateMap.put(opp.Id,opp);
                
                //Added by Anup : CR#1122 - Start
                if(!conToUpdateMap.containsKey(ocr.ContactId)){
                	Contact con = new Contact(
                        Id = ocr.ContactId,
                        //commenting out the qualification notes as per CR #4571 by Karthik
                        //Qualification_Notes__c = null,
                        Qualification_Status__c = null,
                        Qualified_Date__c = null,
                        Qualifying_SDR__c = null,
                        Latest_Opportunity_Date__c = System.today()
                    );
                    conToUpdateMap.put(con.Id, con); 
                }
                //Added by Anup : CR#1122 - End
            }
        }
        Database.update(oppToUpdateMap.values(),false);
        //Added by Anup : CR#1122 - Start
        if(!conToUpdateMap.isEmpty()){
            TriggerUtility.contaskFieldUpdateReset();//Added By Swathi : CR#1416 - End
            Database.update(conToUpdateMap.values(), false);
        }
        //Added By Anup : CR#1122 - End
        
    }
    @TestVisible
    private static Map<Id,Opportunity> getOppMap(Set<Id> oppIds){
        return new Map<Id,Opportunity>([SELECT ID, Qualification_Notes__c ,Qualified_Date__c ,LDR_Name__c,LDR_Name__r.UserRole.Name,RecordtypeId  FROM Opportunity WHERE ID IN:oppIds]);
        
    }
    @TestVisible
    private static Map<Id,Contact> getContactMap(Set<Id> conIds){
        return new Map<Id,Contact>([SELECT ID, Qualification_Notes__c ,Qualified_Date__c ,Qualifying_SDR__c,Qualifying_SDR__r.UserRole.Name FROM Contact WHERE ID IN:conIds]);
    }
}