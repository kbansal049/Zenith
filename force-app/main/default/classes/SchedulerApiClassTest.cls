@isTest
public class SchedulerApiClassTest {
	@isTest
    public static void schedulerApiClassTest(){
		OperatingHours oh = new OperatingHours();
        oh.name = 'Test oh';
        oh.TimeZone = 'America/Los_Angeles';
        insert oh;

		ServiceTerritory st = new ServiceTerritory();
        st.Name = 'Test st';
        st.IsActive = true;
        st.OperatingHoursId = oh.id;
        insert st;
		
		WorkType wt = new WorkType();
		wt.name = 'Test wt';
		wt.EstimatedDuration = 60;
		wt.DurationType = 'Minutes';
		insert wt;
        
        Skill premiumPlusSkill = [Select Id from Skill where DeveloperName='Premium_Plus' limit 1];
        
        SkillRequirement skr = new SkillRequirement();
        skr.RelatedRecordId	 = wt.Id;
        skr.SkillId = premiumPlusSkill.Id;
        insert skr;

		WorkTypeGroup wtg = new WorkTypeGroup();
		wtg.Name = 'Test wtg';
		wtg.IsActive = True;
		insert wtg;

		WorkTypeGroupMember wtgm = new WorkTypeGroupMember();
		wtgm.WorkTypeId = wt.id;
		wtgm.WorkTypeGroupId = wtg.id;
		insert wtgm;

		ServiceTerritoryWorkType stwt = new ServiceTerritoryWorkType();
		stwt.ServiceTerritoryId = st.id;
		stwt.WorkTypeId = wt.id;
		insert stwt;
		
        ServiceResource sr = TestDatafactory_Zscaler.insertServiceResource('Test', UserInfo.getUserId(), 1, 5, 0, 0, 0, 'Frontline');
        sr.isActive = true;
        sr.IsPrimary = true;
        update sr;
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = sr.Id;
        stm.ServiceTerritoryId = st.Id;
        stm.EffectiveStartDate = DateTime.now().addHours(-3);
        insert stm;
        
        ServiceResourceSkill srSkill = new ServiceResourceSkill();
        srSkill.ServiceResourceId = sr.Id;
        srSkill.SkillId = premiumPlusSkill.Id;
        srSkill.EffectiveStartDate = DateTime.now().addHours(-2);
        insert srSkill;
        
        Shift resourceShift = new Shift();
        resourceShift.StartTime = DateTime.now().addHours(3);
        resourceShift.EndTime = DateTime.now().addHours(12);
        resourceShift.ServiceResourceId = sr.Id;
        resourceShift.ServiceTerritoryId = st.Id;
        resourceShift.TimeSlotType = 'Normal';
        resourceShift.Shift_Type__c = 'Support Meeting';
        
        Test.startTest();        
            SchedulerApiClass.payloadIn pl = new SchedulerApiClass.payloadIn();
            pl.workTypeGroupId = wtg.id;
            pl.serviceTerritoryId = st.id;
            pl.schedulingPolicyId = System.Label.Scheduler_Scheduling_Policy_Id;
            pl.accountId = '';
            pl.startDateTime = Datetime.now().addhours(4);
            pl.endDateTime = Datetime.now().addhours(5);
            List<SchedulerApiClass.PayloadIn> payload = new List<SchedulerApiClass.PayloadIn>();
            payload.add(pl);
            SchedulerApiClass.scheduleIt(payload);
            SchedulerApiClass.scheduleIt(null);
        Test.stopTest();
	}
}