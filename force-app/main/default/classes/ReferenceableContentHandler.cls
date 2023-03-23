//Added by Ayush Kangar as part of CR#4238 - Start
public class ReferenceableContentHandler extends TriggerHandler{
    public override void beforeInsert(){
        List<crwd__Evidence__c> newReferenceableList = new List<crwd__Evidence__c>();
        
        for (SObject ref: Trigger.new) {            
            crwd__Evidence__c newReferenceable = (crwd__Evidence__c) ref;
            newReferenceableList.add(newReferenceable);
        }
        UpdateFieldsFromAccounts(newReferenceableList);
    }
    public override void beforeUpdate(){
        List<crwd__Evidence__c> listToUpdate = new List<crwd__Evidence__c>();
        List<crwd__Evidence__c> newReferenceableList = new List<crwd__Evidence__c>();
        Map<Id, crwd__Evidence__c> newRefMap = new Map<Id,crwd__Evidence__c>();
        Map<Id, crwd__Evidence__c> oldRefMap = new Map<Id,crwd__Evidence__c>();
        for (SObject ref: Trigger.new) {            
            crwd__Evidence__c newReferenceable = (crwd__Evidence__c) ref;
            newReferenceableList.add(newReferenceable);
            crwd__Evidence__c oldReferenceable = (crwd__Evidence__c) Trigger.oldMap.get(newReferenceable.Id);
            newRefMap.put(newReferenceable.Id, newReferenceable);
            oldRefMap.put(oldReferenceable.Id, oldReferenceable);  
            if(newRefMap.get(ref.Id).crwd__EvidenceAccount__c !=null && oldRefMap.get(ref.Id).crwd__EvidenceAccount__c!=newRefMap.get(ref.Id).crwd__EvidenceAccount__c){
                listToUpdate.add(newRefMap.get(ref.Id));
            }
        }
        if(!listToUpdate.isEmpty()){
            UpdateFieldsFromAccounts(listToUpdate);
        }
    }
    public void UpdateFieldsFromAccounts(List<crwd__Evidence__c> newReferenceableList){
        List<ID> accIdList = new List<ID>();
        String zia_competitor='';
        String zpa_competitor='';
        Map<ID,Account> accIdMap = new Map<ID,Account>();
        Map<ID,String> accIdZiaCompetitorMap = new Map<ID,String>();
        Map<ID,String> accIdZpaCompetitorMap = new Map<ID,String>();
        for(crwd__Evidence__c ref: newReferenceableList){
            accIdList.add(ref.crwd__EvidenceAccount__c);
        }
        for(Account acc: [select id,
                          Name,Industry,DL_VC__NumberofLocations__c,
                          geo__c,No_Of_ZDX_Platform_Users__c,No_of_Platform_Seats__c,
                          Users_ZPA_Platform__c,CSM_Name_New__r.Name,Account_Manager__r.Name,Area__c,
                          Platform_deployed__c,Number_Of_Entitled_ZPA_Connectors__c,
                          First_ZCP_Contract_Date__c,Territory_Type__c,NumberOfEmployees,
                          (select id,Competitors__c,ZPA_Competitor__c from Opportunities where StageName =: label.Stage_6_Closed_Won limit 50000)
                          from Account
                          where id in: accIdList]){
                              for (Opportunity opp:acc.Opportunities){
                                  if(opp.Competitors__c!='' && opp.Competitors__c!=null){
                                      if(String.isBlank(zia_competitor)){
                                          zia_competitor = opp.Competitors__c;
                                      }else{
                                          zia_competitor = zia_competitor + ';' +opp.Competitors__c;
                                      }
                                  }
                                  if(opp.ZPA_Competitor__c!='' && opp.ZPA_Competitor__c!=null){
                                      if(String.isBlank(zpa_competitor)){
                                          zpa_competitor = opp.ZPA_Competitor__c;
                                      }else{
                                          zpa_competitor = zpa_competitor + ';' + opp.ZPA_Competitor__c;
                                      }
                                  }
                              }
                              accIdZiaCompetitorMap.put(acc.id,zia_competitor);
                              accIdZpaCompetitorMap.put(acc.id,zpa_competitor);
                              zia_competitor = '';
                              zpa_competitor = '';
                              accIdMap.put(acc.id,acc);
                          }
        for(crwd__Evidence__c ref: newReferenceableList){
            ref.geo__c=accIdMap.get(ref.crwd__EvidenceAccount__c).geo__c;
            ref.Industry__c=accIdMap.get(ref.crwd__EvidenceAccount__c).Industry;
            ref.CSM_Name_New__c=accIdMap.get(ref.crwd__EvidenceAccount__c).CSM_Name_New__r.Name;
            ref.Area__c=accIdMap.get(ref.crwd__EvidenceAccount__c).Area__c;
            ref.Account_Manager__c=accIdMap.get(ref.crwd__EvidenceAccount__c).Account_Manager__r.Name;
            ref.Account_Name__c=accIdMap.get(ref.crwd__EvidenceAccount__c).Name;
            ref.Platform_deployed__c=accIdMap.get(ref.crwd__EvidenceAccount__c).Platform_deployed__c;
            ref.First_ZCP_Contract_Date__c=accIdMap.get(ref.crwd__EvidenceAccount__c).First_ZCP_Contract_Date__c;
            ref.Number_Of_Entitled_ZPA_Connectors__c=accIdMap.get(ref.crwd__EvidenceAccount__c).Number_Of_Entitled_ZPA_Connectors__c;
            ref.Territory_Type__c=accIdMap.get(ref.crwd__EvidenceAccount__c).Territory_Type__c;
            ref.NumberOfEmployees__c=accIdMap.get(ref.crwd__EvidenceAccount__c).NumberOfEmployees;
            ref.No_Of_ZDX_Platform_Users__c=accIdMap.get(ref.crwd__EvidenceAccount__c).No_Of_ZDX_Platform_Users__c;
            ref.No_of_Platform_Seats__c=accIdMap.get(ref.crwd__EvidenceAccount__c).No_of_Platform_Seats__c;
            ref.Users_ZPA_Platform__c=accIdMap.get(ref.crwd__EvidenceAccount__c).Users_ZPA_Platform__c;
            ref.DL_VC_NumberofLocations__c=accIdMap.get(ref.crwd__EvidenceAccount__c).DL_VC__NumberofLocations__c;  
            ref.Competitors__c=accIdZiaCompetitorMap.get(ref.crwd__EvidenceAccount__c);
            ref.ZPA_Competitor__c=accIdZpaCompetitorMap.get(ref.crwd__EvidenceAccount__c);
        }        
    }
}
//Added by Ayush Kangar as part of CR#4238 - End