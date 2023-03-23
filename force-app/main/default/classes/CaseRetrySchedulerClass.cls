global class CaseRetrySchedulerClass Implements Schedulable{
    List<case> caseInsertList = new List<case>();
    Integer retryCount;
    string caseType;
    global void execute(SchedulableContext sc){
        try{
            List<CronTrigger> JOBIDLIST = [SELECT id,CronJobDetailId,CronJobDetail.name,CreatedDate from CronTrigger where PreviousFireTime != NULL and CronJobDetail.name like 'Case retry Job Started%'];
			for(CronTrigger job:JOBIDLIST ){
   				System.abortJob(job.id);
			}
        	insert caseInsertList;
        }
        catch(Exception ex){
            if(Integer.valueof(system.label.case_retry_count.left(1)) > retryCount){
                retryCount++;
            	CaseRetrySchedulerClass cs = new CaseRetrySchedulerClass(caseInsertList,retryCount,caseType);
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().minute() + Integer.valueof(system.label.case_retry_count.right(1)));
                if(Integer.valueof(min) > 60){
                    hour = String.valueOf(Integer.valueof(hour)+1);
                	min = string.valueOf(Integer.valueof(min)-60);     
                }
				String ss = String.valueOf(Datetime.now().second());
                string num = caseType +' '+ ss + ' ' + min + ' ' + hour+ ''+retryCount;
				String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                System.schedule('Case retry Job Started '+num, nextFireTime,cs);
            }
            else{
            	ProvisioningErrorHandler.exceptionHandler('CaseRetrySchedulerClass','execute',ex);    
            }   
        }
    }
    
    public CaseRetrySchedulerClass(List<case> caseList, integer retryNumber, string casename){
    	caseInsertList = caseList;
        retryCount = retryNumber;
        caseType = casename;
    }
}