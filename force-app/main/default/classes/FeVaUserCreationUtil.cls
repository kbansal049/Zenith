Public class FeVaUserCreationUtil{
    
    //added by Raghu for CR#181
    public static Map<string, string> userNameMapNew = new Map<string, string>();
    
    //method added by Raghu for CR#181
    public static void createUsersNew(Provisioning_Request__c pr){        
        
        string cookieString = getAuthenticationCookieNew();
        string password = generateRandomString(8);
        system.debug('# cookieString : '+cookieString);
        
        boolean isAdminUserCreated = false;
        boolean isNormalUserCreated = false;
        boolean isRestrictedUserCreated = false;
        //create admin user
        isAdminUserCreated = adminUserNew(pr,cookieString,password);
        if(isAdminUserCreated){
            isNormalUserCreated = internetUserNew(pr,cookieString,password);
            if(isNormalUserCreated){
                 isRestrictedUserCreated = restrictedInternetUserNew(pr,cookieString,password);
            }
        }
       
        if(isAdminUserCreated && isNormalUserCreated && isRestrictedUserCreated){
            senduserEmailAndUpadteProvisioningRequest(pr,password);
        }
    }
    
    
    //method added by Raghu for CR# 181
    public static boolean adminUserNew(Provisioning_Request__c pr, String cookieString, String password)
    {
        boolean isSuccess = false;
        String prName = pr.name;
        FeVa_Cloud_Login__c loginCredential = getFeVaCredential();
        //2164 - admin role
        //Admin Payload
        //String adminPayload = '{'+
        //    '\"loginName\": \"admin-eval-'+prName.substringAfter('-')+'\",'+
        //    '\"userName \": \"admin-eval-'+prName.substringAfter('-')+'\",'+
        //    '\"email \": \"admin-eval-'+prName.substringAfter('-')+'\",'+
        //    '\"role\": {'+
        //    '\"id\": 2164'+
        //    '},'+
        //    '\"password\": \"AeQ9E5w8B$\",'+
        //    '\"rank\": 7,'+
        //    '\"name\": \"Customer Admin\",'+
        //    '\"logsLimit\": \"UNRESTRICTED\",'+
        //    '\"roleType\": \"ORG_ADMIN\"'+
        //    '}';
        
        
        RoleInfo adminRole =  new RoleInfo();
        adminRole.id = 2164;
        AdminUserNew admUsr = new AdminUserNew();
        admUsr.loginName = 'admin-eval-'+prName.substringAfter('-')+'@acmemodern.com';
        admUsr.userName = 'admin-eval-'+prName.substringAfter('-')+'@acmemodern.com';
        admUsr.email =  'admin-eval-'+prName.substringAfter('-')+'@acmemodern.com';
        admUsr.role = adminRole;
        admUsr.password = password;
        admUsr.rank = 7;
        admUsr.name = 'Customer Admin';
        admUsr.logsLimit = 'UNRESTRICTED';
        admUsr.roleType = 'ORG_ADMIN';
        String jsonReqStr = JSON.serializePretty(admUsr);
        
        userNameMapNew.put('Admin', admUsr.loginName);
        
        //System.debug('adminUserNew--adminPayload--'+adminPayload);
        System.debug('adminUserNew--jsonReqStr--'+jsonReqStr);
        
        String createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/adminUsers'; 
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        req.setEndpoint(createPOCEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', cookieString);
        req.setBody(jsonReqStr);
        HttpResponse res = new HttpResponse();
        if(!Test.isRunningTest()){
            res = h.send(req);
        }else{
            res.setStatusCode(200);
            res.setBody('');
        }
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || Test.isRunningTest() ){
            system.debug('adminUserNew--resbody--'+res.getBody());
            
            Boolean confActivated = activateConfigurationChanges(pr, cookieString);
            if(confActivated){
                isSuccess = true;
            }else{
                isSuccess = false;
            }
        }else{
            UpdateProvReq(pr, 'Admin User - '+res.getbody());
        }
        return isSuccess;
    }
    
    
    //method added by Raghu for CR# 181
    public static boolean internetUserNew(Provisioning_Request__c pr, String cookieString, String password)
    {
        boolean isSuccess = false;
        String prName = pr.name;
        system.debug('restrictedInternetUserNew# cookieString : '+cookieString);
        FeVa_Cloud_Login__c loginCredential = getFeVaCredential();
        string createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/users'; 
        
        userInfo usr = new userInfo();
        
        //Set Department
        department dpt = new department();
        dpt.id = 22611425;
        dpt.name = 'Employees';
        //Set Group
        list<groupInfo> groupList = new list<groupInfo>();
        groupInfo gInfo = new groupInfo();
        gInfo.id = 22605988;
        gInfo.name = 'Internet_Users';
        groupList.add(gInfo);
        
        usr.name = 'Internet User';
        usr.password = password;
        usr.email = 'normal-eval-'+prName.substringAfter('-')+'@acmemodern.com';
        usr.department = dpt;
        usr.groups = groupList;
        
        String jsonReqStr = JSON.serializePretty(usr);
        System.debug('internetUserNew--jsonReqStr--'+jsonReqStr);
        
        userNameMapNew.put('Normal', usr.email);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(createPOCEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', cookieString);
        req.setBody(jsonReqStr);
        
        HttpResponse res =  new HttpResponse();
        if(!Test.isRunningTest()){
            res = h.send(req);
        }else{
            res.setStatusCode(200);
            res.setBody('');
        }
        
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || Test.isRunningTest() ){
            system.debug('internetUserNew--'+res.getBody());
            Boolean confActivated = activateConfigurationChanges(pr, cookieString);
            if(confActivated){
                isSuccess = true;
            }else{
                isSuccess = false;
            }
        }else{
            UpdateProvReq(pr, 'Normal User - '+res.getbody());
        }
        return isSuccess;
    }
    
    //method added by Raghu for CR# 181
    public static boolean restrictedInternetUserNew(Provisioning_Request__c pr, String cookieString, String password)
    {
        boolean isSuccess = false;
        String prName = pr.name;
        system.debug('restrictedInternetUserNew# cookieString : '+cookieString);
        FeVa_Cloud_Login__c loginCredential = getFeVaCredential();
        string createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/users'; 
        
        userInfo usr = new userInfo();
        
        //Set Department
        department dpt = new department();
        dpt.id = 22611425;
        dpt.name = 'Employees';
        //Set Group
        list<groupInfo> groupList = new list<groupInfo>();
        groupInfo gInfo = new groupInfo();
        gInfo.id = 22605994;
        gInfo.name = 'Restricted_Internet_Users';
        groupList.add(gInfo);
        
        usr.name = 'Internet User';
        usr.password = password;
        usr.email = 'restricted-eval-'+prName.substringAfter('-')+ '@acmemodern.com';
        usr.department = dpt;
        usr.groups = groupList;
        
        String jsonReqStr = JSON.serializePretty(usr);
        System.debug('restrictedInternetUserNew--jsonReqStr--'+jsonReqStr);
        
        userNameMapNew.put('Restricted', usr.email);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(createPOCEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', cookieString);
        req.setBody(jsonReqStr);
        
        HttpResponse res =  new HttpResponse();
        if(!Test.isRunningTest()){
            res = h.send(req);
        }else{
            res.setStatusCode(200);
            res.setBody('');
        }
        
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || Test.isRunningTest() ){
            system.debug('restrictedInternetUserNew--'+res.getBody());
            Boolean confActivated = activateConfigurationChanges(pr, cookieString);
            if(confActivated){
                isSuccess = true;
            }else{
                isSuccess = false;
            }
        }else{
            UpdateProvReq(pr, 'Restricted User - '+res.getbody());
        }
        return isSuccess;
    }


	//method added by Raghu for CR# 181
    public Static boolean activateConfigurationChanges(Provisioning_Request__c pr, String cookieString){
        System.debug('-activateConfigurationChanges--called');
        Boolean isSuccess= false;
        FeVa_Cloud_Login__c loginCredential = getFeVaCredential();
        String createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/status/activate'; 
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(createPOCEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', cookieString);
        req.setBody('');
        HttpResponse res =  new HttpResponse();
        if(!Test.isRunningTest()){
            res = h.send(req);
        }else{
            res.setStatusCode(200);
            res.setBody('');
        }
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || Test.isRunningTest() ){
            system.debug('restrictedInternetUserNew--'+res.getBody());
            isSuccess = true;
        }else{
            UpdateProvReq(pr, 'Ativate Configuration - '+res.getbody());
        }
        return isSuccess;
    }
   

    
    //method added by Raghu for CR# 181
    public Static void senduserEmailAndUpadteProvisioningRequest(Provisioning_Request__c pr, String password)
    {
        System.debug('-senduserEmailAndUpadteProvisioningRequest--called');
        try
        {
            List<EmailTemplate> tems = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName = 'Feva_User_Credential_Email_New' limit 1];
            
            if(tems.size() > 0){
                String emailBody = String.isBlank(tems[0].HtmlValue) ? '' : tems[0].HtmlValue;
                String emailSubject = tems[0].Subject;
                
                System.debug('--userNameMapNew-'+userNameMapNew);
               
                emailBody = emailBody.replace('{!username}', userNameMapNew.get('Admin'))
                    .replace('{!normalusername}',  userNameMapNew.get('Normal'))
                    .replace('{!restrictedusername}',  userNameMapNew.get('Restricted'))
                    .replace('{!password}', password);
                
                String textBody = String.isBlank(tems[0].Body) ? '' : tems[0].Body;
                textBody = textBody.replace('{!username}', userNameMapNew.get('Admin'))
                    .replace('{!normalusername}',  userNameMapNew.get('Normal'))
                    .replace('{!restrictedusername}',  userNameMapNew.get('Restricted'))
                    .replace('{!password}', password);
                
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //Set list of people who should get the email
                List<String> sendTo = new List<String>();
                Task actHistory = new Task(Subject='Email: ' + emailSubject, WhatId=pr.Id, Status='Completed', ActivityDate=Date.today(), Description=textBody);
                actHistory.WhoId = null;
                for(string str : pr.Send_Initial_l__c.split(';')){
                    if(str == 'Customer'){
                        sendTo.add(pr.Primary_Eval_Contact__r.Email);
                    }
                    else if(str == 'Partner'){
                        sendTo.add(pr.Partner_Contact__r.Email);
                    }
                    else if(str == 'SE'){
                        sendTo.add(pr.SE__r.Email);
                    }
                }
                mail.setToAddresses(sendTo);
                mail.setReplyTo('CustomerSuccess@zscaler.com');
                mail.setSenderDisplayName('zscaler');
                mail.setSubject(emailSubject);
                mail.setHtmlBody(emailBody);
                mail.setPlainTextBody(textBody);
                mails.add(mail);
                
                System.debug('--emailBody-'+emailBody);
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(mails);  
                }
                
                insert actHistory;
                Provisioning_Request__c updatePr = new Provisioning_Request__c(id= pr.Id,  Provisioning_Status__c = 'Provisioned', Provisioning_Date__c = system.today(), FailedReason__c='');
                update updatePr;
            }
        }catch(exception e ){
            System.debug('exception getCause::'+e.getCause());
            System.debug('exception getMessage::'+e.getMessage());
            System.debug('exception getLineNumber::'+e.getLineNumber());
            UpdateProvReq(pr, 'Exeption - ['+e.getMessage()+'] Line Number -['+e.getLineNumber()+']');
        }
    }
    
    
     
    //method added by Raghu for CR# 181
    public static string getAuthenticationCookieNew(){
        string cookieStr ='';
        FeVa_Cloud_Login__c loginCredential = new FeVa_Cloud_Login__c();
        loginCredential = getFeVaCredential();
        
        System.debug('--loginCredential--'+JSON.serializePretty(loginCredential));
        
        list<String> keyCharList = new list<String>();
        for(integer i=0; i< loginCredential.API_Key__c.length();i++ ){
            keyCharList.add(loginCredential.API_Key__c.Substring(i, i + 1));
        }
        
        string timestamp = ''+(DateTime.now().getTime() - DateTime.now().millisecond() );
        string high = timestamp.right(6);
        
        string low = ''+(integer.valueOf(high) >> 1);
        while(low.Length() < 6){
            low = '0'+low;
        }
        string apiKey = '';
        
        for( integer i = 0; i < high.length(); i++){
            apiKey += keyCharList.get(integer.valueOf((high.substring(i,i+1))));
        }
        for(integer j =0;  j< low.length(); j++){
            apiKey += keyCharList.get(integer.valueOf((low.substring(j,j+1)))+2);
        }
        authentication auth = new authentication();
        auth.apiKey = apiKey;
        auth.username = loginCredential.User_name__c;
        auth.password = loginCredential.Password__c;
        auth.timestamp = timestamp;
        String payLoad = JSON.serializePretty(auth);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String loginEndpoint = loginCredential.Endpoint_URL__c + '/api/v1/authenticatedSession';
        req.setEndpoint(loginEndpoint);
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(payLoad);
        HttpResponse res = new HttpResponse();
        if(!Test.isRunningTest())
            res = h.send(req);
        System.debug('-res status--'+res.getStatusCode());
        System.debug('-res body--'+res.getBody());
        cookieStr += res.getHeader('Set-Cookie');
        return cookieStr;
    }
    
    
    
    
    //previous Methods
    public static void createUsers(Provisioning_Request__c pr){
        string cookieString = getAuthenticationCookie();
        system.debug('# cookieString : '+cookieString);
        FeVa_Cloud_Login__c loginCredential = new FeVa_Cloud_Login__c();
        loginCredential = getFeVaCredential();
        map<string, AdminRole> adminRoleMap = new map<string, AdminRole>();
        adminRoleMap = getAdminRoles(cookieString, loginCredential);
        map<string, groupInfo> groupInfoMap = new map<string, groupInfo>();
        groupInfoMap = getGroupInformation(cookieString, loginCredential);
        map<string, department> deptInfoMap = new map<string, department>(); 
        deptInfoMap = getDepartmentInformation(cookieString, loginCredential);
        list<groupInfo>  groupList = new list<groupInfo>();
        Map<string, string> userNameMap = new Map<string, string>();
        string jsonReqStr = '';
        string password ='';
        password = generateRandomString(8);
        userInfo usr = new userInfo();
        string createPOCEndpoint = '';
        string resBodyStr = '';
        string AccName = '';
        AccName += pr.Name.toLowerCase();
        
        if(adminRoleMap.keyset().contains('Customer (user names visible)') || Test.isRunningTest()){
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            
            RoleInfo role = new RoleInfo();
            if(!Test.isRunningTest()){
                role.Id = adminRoleMap.get('Customer (user names visible)').Id;
                role.Name = adminRoleMap.get('Customer (user names visible)').Name;
            }
            AdminUser admUsr = new AdminUser();
            
            admUsr.auditor = false;
            admUsr.loginName = 'admin-'+AccName.replace(' ','-')+ '@acmemodern.com';
            userNameMap.put('Admin', admUsr.loginName);
            admUsr.userName = 'Admin';
            admUsr.role = role;
            admUsr.password = password;
            admUsr.passwordPresent = true;
            admUsr.adminScopeType = 'ORGANIZATION';
            admUsr.email =  'admin-'+AccName.replace(' ','-')+ '@acmemodern.com';
            admUsr.isNonEditable = false;
            jsonReqStr = JSON.serializePretty(admUsr);
            
            createPOCEndpoint = loginCredential.Endpoint_url__c + '/zsapi/v1/adminUsers'; 
            //createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/adminUsers'; 
            req.setEndpoint(createPOCEndpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cookie', cookieString);
            req.setBody(jsonReqStr);
            HttpResponse res = new HttpResponse();
            if(!Test.isRunningTest())
                res = h.send(req);
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || Test.isRunningTest() ){
                jsonReqStr = '';
                groupList = new list<groupInfo>();
                usr.name = 'Sales user';
                usr.password = password;
                groupList.add(groupInfoMap.get('Employees'));
                groupList.add(groupInfoMap.get('Sales'));
                usr.email = 'sales-'+AccName.replace(' ','-')+ '@acmemodern.com';
                usr.groups = groupList;
                usr.department = deptInfoMap.get('Sales');
                usr.adminUser = false;
                jsonReqStr = JSON.serializePretty(usr);
                userNameMap.put('Sales', usr.email);
                HttpRequest usersreq = new HttpRequest();
                h = new Http();
                createPOCEndpoint = '';
                createPOCEndpoint = loginCredential.Endpoint_url__c + '/zsapi/v1/users'; 
                //createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/users'; 
                usersreq.setEndpoint(createPOCEndpoint);
                usersreq.setMethod('POST');
                usersreq.setHeader('Content-Type', 'application/json');
                usersreq.setHeader('Cookie', cookieString);
                usersreq.setBody(jsonReqStr);
                HttpResponse salesUsrRes =  new HttpResponse();
                if(!Test.isRunningTest())
                    salesUsrRes = h.send(usersreq);
                if(salesUsrRes.getStatusCode() == 200 || salesUsrRes.getStatusCode() == 201 || Test.isRunningTest()){
                    jsonReqStr = '';
                    usr = new userInfo();
                    groupList = new list<groupInfo>();
                    usr.name = 'Exec user';
                    usr.password = password;
                    groupList.add(groupInfoMap.get('Employees'));
                    groupList.add(groupInfoMap.get('Executive'));
                    usr.email = 'exec-'+AccName.replace(' ','-')+ '@acmemodern.com';
                    usr.groups = groupList;
                    usr.department = deptInfoMap.get('Executives');
                    usr.adminUser = false;
                    jsonReqStr = JSON.serializePretty(usr);
                    userNameMap.put('Exec', usr.email);
                    HttpRequest execreq = new HttpRequest();
                    h = new Http();
                    createPOCEndpoint = '';
                    createPOCEndpoint = loginCredential.Endpoint_url__c + '/zsapi/v1/users'; 
                    //createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/users'; 
                    execreq.setEndpoint(createPOCEndpoint);
                    execreq.setMethod('POST');
                    execreq.setHeader('Content-Type', 'application/json');
                    execreq.setHeader('Cookie', cookieString);
                    execreq.setBody(jsonReqStr);
                    HttpResponse execUsrRes = new HttpResponse();
                    if(!Test.isRunningTest())
                        execUsrRes = h.send(execreq);
                    if(execUsrRes.getStatusCode() == 200 || execUsrRes.getStatusCode() == 201 || Test.isRunningTest()){
                        jsonReqStr = '';
                        usr = new userInfo();
                        groupList = new list<groupInfo>();
                        usr.name = 'Contractor User';
                        usr.password = password;
                        groupList.add(groupInfoMap.get('Contractors'));
                        usr.email = 'contractor-'+AccName.replace(' ','-')+ '@acmemodern.com';
                        usr.groups = groupList;
                        usr.department = deptInfoMap.get('Contractors');
                        usr.adminUser = false;
                        jsonReqStr = JSON.serializePretty(usr);
                        userNameMap.put('Contractor', usr.email);
                        HttpRequest contractorreq = new HttpRequest();
                        h = new Http();
                        createPOCEndpoint = '';
                        //createPOCEndpoint = loginCredential.Endpoint_url__c + '/zsapi/v1/users'; 
                        createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/users'; 
                        contractorreq.setEndpoint(createPOCEndpoint);
                        contractorreq.setMethod('POST');
                        contractorreq.setHeader('Content-Type', 'application/json');
                        contractorreq.setHeader('Cookie', cookieString);
                        contractorreq.setBody(jsonReqStr);
                        HttpResponse contractorUsrRes =  new HttpResponse();
                        if(!Test.isRunningTest())
                            contractorUsrRes = h.send(contractorreq);
                        if(contractorUsrRes.getStatusCode() == 200 || contractorUsrRes.getStatusCode() == 201 || Test.isRunningTest()){
                            h = new Http();
                            HttpRequest activateReq = new HttpRequest();
                            HttpResponse activateRes =  new HttpResponse();
                            createPOCEndpoint = '';
                            createPOCEndpoint = loginCredential.Endpoint_url__c + '/zsapi/v1/orgAdminStatus/activate'; 
                            //createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/orgAdminStatus/activate'; 
                            activateReq.setEndpoint(createPOCEndpoint);
                            activateReq.setMethod('PUT');
                            activateReq.setHeader('Content-Type', 'application/json');
                            activateReq.setHeader('Cookie', cookieString);
                            if(!Test.isRunningTest())
                                activateRes = h.send(activateReq);
                            
                            if(activateRes.getStatusCode() == 200 || activateRes.getStatusCode() == 201 || Test.isRunningTest()){
                                //Send Email
                                
                                List<EmailTemplate> tems = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName = 'Feva_User_Credential_Email' limit 1];
                                system.debug('# tems.size() : '+tems.size());
                                if(tems.size() > 0){
                                    String emailBody = String.isBlank(tems[0].HtmlValue) ? '' : tems[0].HtmlValue;
                                    String emailSubject = tems[0].Subject;
                                    emailBody = emailBody.replace('{!username}', userNameMap.get('Admin')).replace('{!salesusername}',  userNameMap.get('Sales')).replace('{!execusername}',  userNameMap.get('Exec')).replace('{!contractusername}',  userNameMap.get('Contractor')).replace('{!password}', password);
                                    String textBody = String.isBlank(tems[0].Body) ? '' : tems[0].Body;
                                    textBody = textBody.replace('{!username}', userNameMap.get('Admin')).replace('{!salesusername}',  userNameMap.get('Sales')).replace('{!execusername}',  userNameMap.get('Exec')).replace('{!contractusername}',  userNameMap.get('Contractor')).replace('{!password}', password);
                                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    //Set list of people who should get the email
                                    List<String> sendTo = new List<String>();
                                    Task actHistory = new Task(Subject='Email: ' + emailSubject, WhatId=pr.Id, Status='Completed', ActivityDate=Date.today(), Description=textBody);
                                    actHistory.WhoId = null;
                                    for(string str : pr.Send_Initial_l__c.split(';')){
                                        if(str == 'Customer'){
                                            sendTo.add(pr.Primary_Eval_Contact__r.Email);
                                        }
                                        else if(str == 'Partner'){
                                            sendTo.add(pr.Partner_Contact__r.Email);
                                        }
                                        else if(str == 'SE'){
                                            sendTo.add(pr.SE__r.Email);
                                        }
                                    }
                                    
                                    /*
if(pr.Send_Initial_l__c == 'Customer'){
sendTo.add(pr.Primary_Eval_Contact__r.Email);
actHistory.WhoId = pr.Primary_Eval_Contact__c;
}
else if(pr.Send_Initial_l__c == 'Partner'){
sendTo.add(pr.Partner_Contact__r.Email);
actHistory.WhoId = pr.Partner_Contact__c;
}
else if(pr.Send_Initial_l__c == 'SE'){
sendTo.add(pr.SE__r.Email);
actHistory.WhoId = null;
}
*/
                                    mail.setToAddresses(sendTo);
                                    mail.setReplyTo('CustomerSuccess@zscaler.com');
                                    mail.setSenderDisplayName('zscaler');
                                    mail.setSubject(emailSubject);
                                    mail.setHtmlBody(emailBody);
                                    mail.setPlainTextBody(textBody);
                                    mails.add(mail);
                                    try
                                    {
                                        Messaging.sendEmail(mails);
                                        insert actHistory;
                                        Provisioning_Request__c updatePr = new Provisioning_Request__c(id= pr.Id,  Provisioning_Status__c = 'Provisioned', Provisioning_Date__c = system.today(), FailedReason__c='');
                                        update updatePr;
                                    }catch(exception e ){}
                                }
                                
                            }else{
                                UpdateProvReq(pr, 'Contractor - '+contractorUsrRes.getbody());
                            }
                            
                        }else{
                            UpdateProvReq(pr, 'Contractor - '+contractorUsrRes.getbody());
                        }
                    }else{
                        UpdateProvReq(pr, 'Exec - '+execUsrRes.getbody());
                    }
                }else{
                    UpdateProvReq(pr, 'Sales - '+salesUsrRes.getbody());
                }
            }else{
                UpdateProvReq(pr, 'Admin - '+res.getbody());
            }
        }
        
    }
    
    
    public static map<string, groupInfo> getGroupInformation(string cookieString, FeVa_Cloud_Login__c loginCredential){
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        String createPOCEndpoint = loginCredential.Endpoint_url__c + '/zsapi/v1/groups'; 
        //String createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/groups'; 
        req.setEndpoint(createPOCEndpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', cookieString);
        HttpResponse res = new HttpResponse();
        if(!Test.isRunningTest())
            res = h.send(req);
        string reqBodyStr = '';
        reqBodyStr = res.getbody();
        
        list<groupInfo> repons = new list<groupInfo>();
        if(!Test.isRunningTest())
            repons = (list<groupInfo>)JSON.deserialize(reqBodyStr, list<groupInfo>.class);
        map<string, groupInfo> groupNameDetailMap = new map<string, groupInfo>();
        
        for(groupInfo grpInfo : repons){
            groupNameDetailMap.put(grpInfo.Name, grpInfo);
        }
        return groupNameDetailMap;
    }
    
    public static map<string, department> getDepartmentInformation(string cookieString, FeVa_Cloud_Login__c loginCredential){
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        String createPOCEndpoint = loginCredential.Endpoint_url__c + '/zsapi/v1/departments'; 
        //String createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/departments'; 
        req.setEndpoint(createPOCEndpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', cookieString);
        HttpResponse res = new HttpResponse();
        if(!Test.isRunningTest())
            res = h.send(req);
        string reqBodyStr = '';
        reqBodyStr = res.getbody();
        
        list<department> repons = new list<department>();
        if(!Test.isRunningTest())
            repons = (list<department>)JSON.deserialize(reqBodyStr, list<department>.class);
        map<string, department> depNameDetailMap = new map<string, department>();
        
        for(department depInfo : repons){
            depNameDetailMap.put(depInfo.Name, depInfo);
        }
        return depNameDetailMap;
    }
    
    
    public static map<string, AdminRole> getAdminRoles(string cookieString, FeVa_Cloud_Login__c loginCredential){
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        String createPOCEndpoint = loginCredential.Endpoint_url__c + '/zsapi/v1/adminRoles';
        //String createPOCEndpoint = loginCredential.Endpoint_url__c + '/api/v1/adminRoles/adminRoles/lite';
        req.setEndpoint(createPOCEndpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', cookieString);
        HttpResponse res = new HttpResponse();
        if(!Test.isRunningTest())
            res = h.send(req);
        string reqBodyStr = '';
        
        list<AdminRole> repons = new list<AdminRole>();
        if(!Test.isRunningTest()){
            reqBodyStr = res.getbody();
            repons = (list<AdminRole>)JSON.deserialize(reqBodyStr, list<AdminRole>.class);
        }   
        map<string, AdminRole> adminRoleNameDetailMap = new map<string, AdminRole>();
        for(AdminRole admRole : repons){
            adminRoleNameDetailMap.put(admRole.Name, admRole);
        }
        return adminRoleNameDetailMap;
    }
    
    
    
    public static void UpdateProvReq(Provisioning_Request__c pr, string error){
        Provisioning_Request__c updatePr = new Provisioning_Request__c(id= pr.Id, FailedReason__c = error, Provisioning_Status__c = 'Failed');
        update updatePr;
    }
    
    
    
    public static String generateRandomString(Integer len){
        len = len-3;
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String pwd = key.substring(0,len);
        return ('Z'+pwd+'1!'); 
    }
    
    
    public static string getAuthenticationCookie(){
        string cookieStr ='';
        FeVa_Cloud_Login__c loginCredential = new FeVa_Cloud_Login__c();
        loginCredential = getFeVaCredential();
        
        System.debug('--loginCredential--'+JSON.serializePretty(loginCredential));
        
        list<String> keyCharList = new list<String>();
        for(integer i=0; i< loginCredential.API_Key__c.length();i++ ){
            keyCharList.add(loginCredential.API_Key__c.Substring(i, i + 1));
        }
        
        string timestamp = ''+(DateTime.now().getTime() - DateTime.now().millisecond() );
        string high = timestamp.right(6);
        
        string low = ''+(integer.valueOf(high) >> 1);
        while(low.Length() < 6){
            low = '0'+low;
        }
        string apiKey = '';
        
        for( integer i = 0; i < high.length(); i++){
            apiKey += keyCharList.get(integer.valueOf((high.substring(i,i+1))));
        }
        for(integer j =0;  j< low.length(); j++){
            apiKey += keyCharList.get(integer.valueOf((low.substring(j,j+1)))+2);
        }
        authentication auth = new authentication();
        auth.apiKey = apiKey;
        auth.username = loginCredential.User_name__c;
        auth.password = loginCredential.Password__c;
        auth.timestamp = timestamp;
        String payLoad = JSON.serializePretty(auth);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //String loginEndpoint = loginCredential.Endpoint_URL__c + '/api/v1/authenticatedSession';
        String loginEndpoint = loginCredential.Endpoint_URL__c + '/zsapi/v1/authenticatedSession';
        req.setEndpoint(loginEndpoint);
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(payLoad);
        HttpResponse res = new HttpResponse();
        if(!Test.isRunningTest())
            res = h.send(req);
        System.debug('-res status--'+res.getStatusCode());
        System.debug('-res body--'+res.getBody());
        cookieStr += res.getHeader('Set-Cookie');
        return cookieStr;
    }
    
    
    public static FeVa_Cloud_Login__c getFeVaCredential() {
        boolean isSandbox =  [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(!isSandbox)
            return FeVa_Cloud_Login__c.getInstance('Production');
        else
            return FeVa_Cloud_Login__c.getInstance('Sandbox');
    }
    
    
    public class userInfo{
        Public String name;
        public boolean adminUser;
        Public String comments;
        Public String password;
        Public String email;
        Public list<groupInfo> groups;
        Public department department;
    }
    public class AdminUser{
        Public String comments;
        Public Boolean auditor;
        Public String loginName;
        Public String userName;
        Public RoleInfo role;
        Public String password;
        Public Boolean passwordPresent;
        Public String adminScopeType;
        Public String email;
        public boolean isNonEditable;
    }
    public class RoleInfo{
        public Integer id;
        public String name;
    }
    public class AdminRole {
        public Integer id;
        public Integer rank;
        public String name;
        public String policyAccess;
        public String dashboardAccess;
        public String reportAccess;
        public String analysisAccess;
        public String usernameAccess;
        public String adminAcctAccess;
        public boolean auditor;
        public list<string> permissions;
        public boolean isNonEditable;
        public String logsLimit;
    }
    
    public class department{
        public integer id;
        public string name;
    }
    public class groupInfo{
        public integer id;
        public string name;
    }
    
    public class authentication{
        public string apiKey;
        public string username;
        public string password;
        public string timestamp;
    }
    
    
    //Changes related to CR#181
    public class AdminUserNew{
        
        Public String loginName;
        Public String userName;
        Public String email;
        Public RoleInfo role;
        Public String password;
        Public String name;
        Public integer rank;
        Public string policyAccess;
        Public string dashboardAccess;
        Public string reportAccess;
        Public string analysisAccess;
        Public string usernameAccess;
        Public string adminAcctAccess;
        Public String logsLimit;
        Public String roleType;
    }
}