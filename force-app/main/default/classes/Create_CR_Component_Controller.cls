public class Create_CR_Component_Controller {
	@AuraEnabled
    public static String checkIfCrExists(String caseId){
        List<Tracker_Change_request__c> listofCase = new List<Tracker_Change_request__c>();
        listOfCase = [select id, Name from Tracker_Change_request__c where Case__c=:caseId];
        system.debug('listOfCase :'+listOfCase);
        if(!listOfCase.isEmpty()){
            return listOfCase[0].Name;
        }
        return null;
    }
}