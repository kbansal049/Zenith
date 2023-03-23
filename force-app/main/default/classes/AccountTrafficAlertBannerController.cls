public class AccountTrafficAlertBannerController {
    @AuraEnabled
    public static DatesWrapper getAsyncApexJobDates(){
        Map<Integer,String> monthMap = new Map<Integer,String>{1=>'January',2=>'February',3=>'March',
            4=>'April',5=>'May',6=>'June',7=>'July',
            8=>'August',9=>'September',10=>'October',11=>'November',12=>'December'};
        DatesWrapper datawrprObj = new DatesWrapper();
        List<AsyncApexJob> jobList = new List<AsyncApexJob>();
        jobList = [SELECT ApexClass.Id,CompletedDate FROM AsyncApexJob 
                   WHERE (CompletedDate != NULL AND ApexClass.Name = 'CustomerSummaryBatch') 
                   ORDER BY CompletedDate desc LIMIT 1];
        for(AsyncApexJob job : jobList){
            DateTime completedDate = job.CompletedDate.addMonths(-1);
            datawrprObj.lastMonth = monthMap.get(completedDate.month())+'-'+completedDate.year();
            completedDate = completedDate.addMonths(-1);
            datawrprObj.prevMonth = monthMap.get(completedDate.month())+'-'+completedDate.year();
            completedDate = completedDate.addMonths(-4);
            datawrprObj.last6Month = monthMap.get(completedDate.month())+'-'+completedDate.year();
            completedDate = completedDate.addMonths(-6);
            datawrprObj.last12Month = monthMap.get(completedDate.month())+'-'+completedDate.year();
        }
        return datawrprObj;
    }
    
    public Class DatesWrapper{
        @AuraEnabled public String lastMonth;
        @AuraEnabled public String prevMonth;
        @AuraEnabled public String last6Month;
        @AuraEnabled public String last12Month;
    }
}