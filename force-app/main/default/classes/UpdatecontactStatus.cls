public class UpdatecontactStatus{
    @InvocableMethod
    public static void updateContactStatus(List<Id> ldIds){
        
    if(OnOffSwitch__c.getInstance('updateContactStatus').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('updateContactStatus').Deactivate_Component__c==False){
      system.debug('run the code ');      
      Set<String> setldIds = new Set<String>();
        
      for(String i: (List<String>) ldIds){
        setldIds.add(String.valueOf(i).substring(0,15));
      }
      system.debug('++++'+setldIds);
      Map<Id,Lead> maplds = new map<Id,Lead>([Select Id, Status from Lead where Id in :ldIds]);
      Map<Id,Contact> mapleadidcontacts = new Map<Id,contact>();
      for(Contact con: [Select Id, Converted_Lead_Id__c, Contact_Lead_Status__c from contact where Converted_Lead_Id__c in :setldIds]){
        mapleadidcontacts.put(con.Converted_Lead_Id__c,con);
      }
      for(Id ldId: mapleadidcontacts.keyset()){
         if(mapleadidcontacts.get(ldId) != null && maplds.containskey(ldId) && maplds.get(ldId) != null){
           mapleadidcontacts.get(ldId).Contact_Lead_Status__c = maplds.get(ldId).Status;
           system.debug('+++++++++'+maplds.get(ldId).Status);
         } 
         
      }
      
      system.debug('+++++++++'+mapleadidcontacts.values());
      update mapleadidcontacts.values();
  
    }else{
      system.debug('do not run the code as updateContactStatus is deactivated');
    }       
    } 

    public static void updateContactCampaignID(List<Id> leadIds){
        
      List<Contact> update_contacts = new List<Contact>();

      Map<Id,Lead> mapleadidLeads = new map<Id,Lead>([Select Id, Linkedin_Campaign_ID__c, ConvertedContactid from Lead where Id in :leadIds AND Linkedin_Campaign_ID__c != null AND ConvertedContactid != null]);
     
      Map<Id,Lead> mapcontactIdLeads = new Map<Id,Lead>();
      for(Lead lead : mapleadidLeads.values()){
        mapcontactIdLeads.put( lead.ConvertedContactid,lead);
      }

      for(Contact cont : [Select Id, Linkedin_Campaign_ID__c from Contact where Id in :mapcontactIdLeads.keySet() AND Linkedin_Campaign_ID__c = null]){
        if(mapcontactIdLeads.get(cont.id) != null){
          cont.Linkedin_Campaign_ID__c = mapcontactIdLeads.get(cont.id).Linkedin_Campaign_ID__c;
          update_contacts.add(cont);
        }
      }
      
      if(!update_contacts.isEmpty()){
          update update_contacts;
      }
    }

}