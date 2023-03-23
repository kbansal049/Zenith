global class updateChannelManagersBatchSch implements Schedulable
{
    global updateChannelManagersBatchSch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        if(!Test.isRunningTest()){
            Database.executeBatch(new updateChannelManagersBatch('SELECT Id, Sales_Territory__c, RecordType.Name, Status__c,Partner_Account__c  FROM Deal_Reg__c WHERE Sales_Territory__c != null AND Channel_Manager__c = null and Partner_Type__c !=\'Technology Partner\' '),200);
        }
     }
 }