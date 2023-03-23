/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ProjectExtensionComponentController
* @description    This class is the controller class for ProjectExtensionComponent. It is used 
* 					in the VF email template.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2022-02-09
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class ProjectExtensionComponentController {
    
    private static ProjectExtensionComponentController instance;
    public static ProjectExtensionComponentController getInstance() {
        
        if (instance == NULL) {
            instance = new ProjectExtensionComponentController();
        }
        
        return instance;
    }
    
    public Id projectExtId { get; set; }
    
    public List<PS_Extension__c> getProjectExtList() {
        
        return [
            SELECT
            Id,
            Name,
            CreatedBy.Name,
            Project__r.Name,
            Project__r.Id,
            Amount_paid_for_Deployment__c,
            Approval_Status__c,
            Opportunity_ACV__c,
            Opportunity_Date_Closed__c,
            Project__c, 
            PS_Contract_Expiration_Date__c,
            PS_Package_Sold__c,
            ZPA_Deployment__c,
            ZIA_Deployment__c,
            Deployment_Start_Date__c,
            No_of_Platform_Seats_ZIA__c,
            ZIA_L31D__c,
            ZIA_L31D_Status__c,
            ZPA_L31D__c,
            ZPA_L31D_Status__c,
            CSM_Name__r.Name,
            Reason_for_Delay__c,
            //Reason_for_Delay_Text__c,
            Reason_for_Delay_LongText__c,
            TAM_Name__r.Name,
            No_of_Platform_Seats_ZPA__c,
            Document_task_extension__c, 
            Project__r.Opportunity__r.Amount,
            Project__r.inspire1__Account__r.Name,
            Project__r.inspire1__Account__r.CSM_Name_New__r.Name,
            Project__r.inspire1__Account__r.TAM_Name_New__r.Name,
            Project__r.inspire1__Account__r.No_of_Employees_Users__c,
            Professional_Service_Project__r.Id,
            Professional_Service_Project__r.Name,
            Number_of_users_XYZ_Deployment_Target__c,
            Professional_Service_Project__r.Account__r.Name,
            Deployment_Expiration_Date__c
            FROM
            PS_Extension__c
            WHERE
            Id = :projectExtId
        ];
    }
    
}