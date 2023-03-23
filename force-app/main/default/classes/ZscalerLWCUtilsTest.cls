@isTest
public class ZscalerLWCUtilsTest {
    
    @istest
    public static void getFieldSetDetailsTest()
    {
       system.assertNotEquals(0,ZscalerLWCUtils.getFieldSetDetails('StudentCreationFormLWC','skilljar__Student__c').size());
        
    }
      
}