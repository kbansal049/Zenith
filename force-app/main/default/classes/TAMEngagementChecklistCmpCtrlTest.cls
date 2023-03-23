/**
 * Name : TAMEngagementChecklistCmpCtrlTest
 * Description : Test Class of TAMEngagementChecklistCmpCtrl
 */

@isTest
public class TAMEngagementChecklistCmpCtrlTest {
    
    @TestSetup
    static void dataSetup(){
        Account a = new Account(Name = 'Test');
        insert a;
        List<GCS_Project__c> gcsProjects = new List<GCS_Project__c>();
        gcsProjects.add(new GCS_Project__c(Account__c = a.id,
                                               Project_Type__c = 'Best Practice',
                                               Project_Sub_Type__c = 'Configuration Audit',
                                               Project_Status__c = 'New'));
        gcsProjects.add(new GCS_Project__c(Account__c = a.id,
                                               Project_Type__c = 'Best Practice',
                                               Project_Sub_Type__c = 'Configuration Audit',
                                               Project_Status__c = 'Completed'));
        insert gcsProjects;
        ContentVersion cv=new Contentversion();
        cv.title='test';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.firstPublishLocationId = a.id;
        cv.Project_Product_Type_fileupload__c = 'ZIA';
        cv.Document_Type_fileupload__c = 'BCP';
        insert cv;
        TAM_Engagement__c eng = new TAM_Engagement__c(Account__c = a.id, Stage__c = 'STAGE 1: Onboarding', product__c = 'ZIA', tam_engagement_Status__c = 'Work in Progress');
        insert eng;
        TAM_Engagement__c eng2 = new TAM_Engagement__c(Account__c = a.id, Stage__c = 'STAGE 1: Onboarding', product__c = 'ZPA', tam_engagement_Status__c = 'Work in Progress');
        insert eng2;
        TAM_Engagement__c eng3 = new TAM_Engagement__c(Account__c = a.id, Stage__c = 'STAGE 1: Onboarding', product__c = 'ZDX', tam_engagement_Status__c = 'Work in Progress');
        insert eng3;
    }

    @isTest
    static void checkDocs_Test() {
        List<TAM_Engagement__c> engs = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c];
        TAMEngagementChecklistCmpCtrl.checkDocs(engs.get(0).id,'BCP');
        TAMEngagementChecklistCmpCtrl.checkDocs(engs.get(1).id,'BCP');
        TAMEngagementChecklistCmpCtrl.checkDocs(engs.get(2).id,'BCP');
    }

    @isTest
    static void checkAdoptionPercentage_Test() {
        List<TAM_Engagement__c> engs = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c];
        TAMEngagementChecklistCmpCtrl.checkAdoptionPercentage(engs.get(0).id,50);
        TAMEngagementChecklistCmpCtrl.checkAdoptionPercentage(engs.get(1).id,50);
        TAMEngagementChecklistCmpCtrl.checkAdoptionPercentage(engs.get(2).id,50);
    }

    @isTest
    static void checkWeeklyMeetings_Test() {
        List<TAM_Engagement__c> engs = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c];
        TAMEngagementChecklistCmpCtrl.checkWeeklyMeetings(engs.get(0).id);
        TAMEngagementChecklistCmpCtrl.getTAMMeetingDetails(engs.get(0).id);
        TAMEngagementChecklistCmpCtrl.checkWeeklyMeetings(engs.get(1).id);
        TAMEngagementChecklistCmpCtrl.getTAMMeetingDetails(engs.get(1).id);
        TAMEngagementChecklistCmpCtrl.checkWeeklyMeetings(engs.get(2).id);
        TAMEngagementChecklistCmpCtrl.getTAMMeetingDetails(engs.get(2).id);
    }

    @isTest
    static void checkTAMProjectStatus_Test() {
        List<TAM_Engagement__c> engs = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c];
        TAMEngagementChecklistCmpCtrl.checkTAMProjectStatus(engs.get(0).id);
        TAMEngagementChecklistCmpCtrl.checkTAMProjectStatus(engs.get(1).id);
        TAMEngagementChecklistCmpCtrl.checkTAMProjectStatus(engs.get(2).id);
    }
     
    @isTest
    static void calculateReductionInCases_Test() {
        List<TAM_Engagement__c> engs = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c];
        TAMEngagementChecklistCmpCtrl.calculateReductionInCases(engs.get(0).id);
        TAMEngagementChecklistCmpCtrl.calculateReductionInCases(engs.get(1).id);
        TAMEngagementChecklistCmpCtrl.calculateReductionInCases(engs.get(2).id);
    }

    @isTest
    static void getCustomerSentiment_Test() {
        List<TAM_Engagement__c> engs = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c];
        TAMEngagementChecklistCmpCtrl.getCustomerSentiment(engs.get(0).id);
        TAMEngagementChecklistCmpCtrl.getCustomerSentiment(engs.get(1).id);
        TAMEngagementChecklistCmpCtrl.getCustomerSentiment(engs.get(2).id);
    }

    @isTest
    static void getAdoptionRates_Test() {
        List<TAM_Engagement__c> engs = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c];
        TAMEngagementChecklistCmpCtrl.getAdoptionRates(engs.get(0).id);
        TAMEngagementChecklistCmpCtrl.getAdoptionRates(engs.get(1).id);
        TAMEngagementChecklistCmpCtrl.getAdoptionRates(engs.get(2).id);
    }
}