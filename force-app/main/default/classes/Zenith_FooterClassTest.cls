@isTest
public class Zenith_FooterClassTest {
    @testSetup 
    static  void FetchFooterLabels(){
        Test.startTest();
        
        Zenith_Footer__c zenithFooter = new Zenith_Footer__c();
        zenithFooter.Footer_Label__c = 'Support';
        zenithFooter.Order__c = 2;
        insert zenithFooter;
        
        Zenith_Footer__c footerObj = new Zenith_Footer__c();
        footerObj.Footer_Label__c = 'Tech Support';
        footerObj.Order__c = 1;
        footerObj.Parent__c = zenithFooter.Id;
        insert footerObj;
        
        Zenith_Footer__c footerObj2 = new Zenith_Footer__c();
        footerObj2.Footer_Label__c = 'Tech Support';
        footerObj2.Order__c = 1;
        footerObj2.Parent__c = zenithFooter.Id;
        insert footerObj2;
        
        Zenith_Footer__c footerObj3 = new Zenith_Footer__c();
        footerObj3.Footer_Label__c = 'Tech Support';
        footerObj3.Order__c = 1;
        insert footerObj3;
        
      //  Integer Order = 2;
        
        Zenith_FooterClass.getProfileName();
        Zenith_FooterClass.FetchFooterLabels();
        Zenith_FooterClass.wrapperParent wrap = new Zenith_FooterClass.wrapperParent();
        wrap.Order = 1;
        Test.stopTest();
        
        System.assert(footerObj3.Footer_Label__c == 'Tech Support');
        System.assertEquals(1, footerObj3.Order__c);
    }
    
    public static Testmethod void getFooterLabels(){
        Test.startTest();
        
        Zenith_Footer__c zenithFooter = new Zenith_Footer__c();
        zenithFooter.Footer_Label__c = 'Support';
        insert zenithFooter; 
        
        Zenith_Footer__c footerObj1 = new Zenith_Footer__c();
        footerObj1.Footer_Label__c = 'Support';
        footerObj1.Parent__c = null;
        footerObj1.Order__c = 3;
        
        insert footerObj1;
        
        Zenith_Footer__c footerObj2 = new Zenith_Footer__c();
        footerObj2.Footer_Label__c = 'Tech Support';
        footerObj2.Order__c = 3;
        footerObj2.Parent__c = null;
        insert footerObj2;
        
        Zenith_Footer__c footerObj3 = new Zenith_Footer__c();
        footerObj3.Footer_Label__c = 'Tech Support';
        footerObj3.Order__c = 3;
        
        insert footerObj3;
        
     //   Integer Order = 2;  
        
        Zenith_FooterClass.getProfileName();
        Zenith_FooterClass.FetchFooterLabels();
        Zenith_FooterClass.wrapperParent wrap = new Zenith_FooterClass.wrapperParent();
        wrap.Order = 3; 
        Test.stopTest();
        
        System.assert(footerObj3.Footer_Label__c == 'Tech Support');
        System.assertEquals(3, footerObj3.Order__c);
        System.assertEquals(null,footerObj2.Parent__c);
    } 

}