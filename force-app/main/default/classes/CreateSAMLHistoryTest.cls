@isTest
public class CreateSAMLHistoryTest {
    private static testMethod void test() {
        Map<String, String> req = new Map<String, String>();
        req.put('ziaOrgId','ygtfhsdgfsh');
        req.put('ziaUserName','abc@twestmail.com');
        CreateSAMLHistory.createSSOsamlhistory(req, 'Test', '','test@testmail.com', '200-Success', 'TestAccount', 'ZIA');
    }
    
    private static testMethod void test1() {
        Map<String, String> req = new Map<String, String>();
        req.put('ziaOrgId','ygtfhsdgfsh');
        req.put('ziaUserName','abc@twestmail.com');
        //Added by Anup - IBA-34 - Start
        req.put('ziaLoginCountry', 'Japan');
        req.put('ziaLoginState', 'JapanState');
        //Added by Anup - IBA-34 - End
        CreateSAMLHistory.createSSOsamlhistoryWithPortalDetails(req, 'Test', '','test@testmail.com',null, 'TestAccount', 'ZIA','ygtfhsdgfsh','abc@twestmail.com');
    }
}