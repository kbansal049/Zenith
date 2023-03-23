/**
 * Name : CAPRequestMilestoneCmpCtrl
 * Description : Controller class for CAPRequestMilestone LWC
 * Test Class : CAPRequestMilestoneCmpCtrlTest
 * Initial Author : Ankit Bhatnagar
 */
public with sharing class CAPRequestMilestoneCmpCtrl {
    public CAPRequestMilestoneCmpCtrl() {}

    @AuraEnabled
    public static MilestoneWrapper getMilestoneRecords(String recordId) {
        MilestoneWrapper milestoneWrapper = new MilestoneWrapper();
        if(String.isNotBlank(recordId)) {
            for(Milestone__c m :  [ SELECT id,CAP_Request__c,Completion_Datetime__c,is_Completed__c,
                                    is_Violated__c,Milestone_Type__c,Start_Datetime__c,Target_Datetime__c 
                                    FROM Milestone__c WHERE CAP_Request__c =: recordId order by CreatedDate desc]) {
                
                Long start =  m.Start_Datetime__c.getTime();
                Long endtime =  m.Target_Datetime__c.getTime();
                Long current = System.now().getTime();
                Long numDiff = (current-start)/60000;
                Long denDiff = (endTime - start)/60000;
                System.debug((numDiff*100/denDiff));
                
                MilestoneObjectWrapper milestone = new MilestoneObjectWrapper(m,(numDiff*100/denDiff));

                if(m.is_Violated__c) {
                    milestoneWrapper.violatedMilestones.add(milestone);
                }
                else if(m.is_Completed__c) {
                    milestoneWrapper.completedMilestones.add(milestone);
                }
                else if(!m.is_Violated__c && !m.is_Completed__c) {
                    milestoneWrapper.ongoingMilestones.add(milestone);
                }
            }
            return milestoneWrapper;
        }
        else return null;
    }

    public class MilestoneWrapper {
        @AuraEnabled public List<MilestoneObjectWrapper> completedMilestones;
        @AuraEnabled public List<MilestoneObjectWrapper> violatedMilestones;
        @AuraEnabled public List<MilestoneObjectWrapper> ongoingMilestones;

        public MilestoneWrapper() {
            this.completedMilestones = new List<MilestoneObjectWrapper>();
            this.violatedMilestones = new List<MilestoneObjectWrapper>();
            this.ongoingMilestones = new List<MilestoneObjectWrapper>();
        }
    }

    private class MilestoneObjectWrapper {
        @AuraEnabled public String milestoneType {get; set;}
        @AuraEnabled public DateTime startTime {get; set;}
        @AuraEnabled public DateTime completedTime {get; set;}
        @AuraEnabled public DateTime targetTime {get; set;}
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public Boolean isCompleted {get; set;}
        @AuraEnabled public Boolean isViolated {get; set;}
        @AuraEnabled public Long progressPercent {get; set;}
        
        private MilestoneObjectWrapper(Milestone__c milestone, Long progressPercent) {
            this.milestoneType = milestone.Milestone_Type__c;
            this.startTime = milestone.Start_Datetime__c;
            this.completedTime = milestone.Completion_Datetime__c;
            this.targetTime = milestone.Target_Datetime__c;
            this.isCompleted = milestone.is_Completed__c;
            this.isViolated = milestone.is_Violated__c;
            this.progressPercent = progressPercent;
            this.id = milestone.Id;
        }
    }
}