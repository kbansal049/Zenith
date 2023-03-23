public class AutomaticStrike {
@InvocableMethod(label='callAutomaticStrikeBatch')
public static void callAutomaticStrikeBatch(){
    Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
    Integer Strike1value=Integer.valueOf(System.Label.Strike1);
    Integer Strike2value=Integer.valueOf(System.Label.Strike2);
    Integer Strike3value=Integer.valueOf(System.Label.Strike3);
    AutomaticStrikeBatch batch=new AutomaticStrikeBatch('SELECT id,OwnerId,Owner.ProfileId,Status,Pending_Customer_Timestamp__c,X3_Strike_Policy__c,Contact.Email,Case_Type__c,Pending_Customer_Time_Difference__c,Customer_CC_List__c,Internal_CC_List__c,Owner.Email FROM Case WHERE Status=\'Pending Customer\' and X3_Strike_Policy__c=false and Pending_Customer_Timestamp__c!=null and Case_Type__c IN (\'Problem\',\'Question\') and (Pending_Customer_Time_Difference__c=: Strike1value OR Pending_Customer_Time_Difference__c=: Strike2value OR Pending_Customer_Time_Difference__c=: Strike3value) and RecordTypeId=\'0120g0000009ujLAAQ\'');
    Database.executeBatch(batch,5);
}
}