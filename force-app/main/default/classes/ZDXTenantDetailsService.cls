/**
 * Copyright © Zscaler
 * Name : ZDXTenantDetailsService
 * Purpose : RESTful Service Class to provide Tenant Details for ZDX customers
 * Test Class: ZDXTenantDetailsServiceTest
 * Author : Ankit Bhatnagar
 * 
 */

@RestResource(urlMapping = '/getZDXTenantDetails/*')
global without sharing class ZDXTenantDetailsService {
    global static final String TENANT_ID_NOT_FOUND = 'Tenant ID not Found';
    global static final String ACCOUNT_ID_NOT_FOUND = 'Account ID not present on this Tenant';
    global static final String REQUEST_PARAM_MISSING = 'Request Parameter(Tenant ID) is missing';
    global static final String DATA_FOUND = 'Data found successfully';
    global static final String TAMs_NOT_PRESENT = 'TAMs not present on the Account';
    //get Tenant Details on the basis of ZDX Tenant ID
    @HttpGet
    global static ResponseStructure getTenantDetails(){
        String accountId ='';
        String accountName ='';
        String tenantId = '';
        String primaryTAM ='';
        String secondaryTAM ='';
        String thirdTAM = '';
        String status = '';
        RestRequest request = RestContext.request;
        if(request.params!=null && request.params.containsKey('tenantId') && String.isNotBlank(request.params.get('tenantId'))){
            List<Zscaler_Cloud_ID__c> zScalerCloudList = new List<Zscaler_Cloud_ID__c> ([SELECT Id, Name,Org_Name__c,Account__c 
                                                                                        FROM Zscaler_Cloud_ID__c 
                                                                                        WHERE Name = : request.params.get('tenantId') LIMIT 1]);
            if(!zScalerCloudList.isEmpty()) {
                if(String.isNotBlank(zScalerCloudList.get(0).Account__c)) {
                    accountId = zScalerCloudList.get(0).Account__c;
                    tenantId = zScalerCloudList.get(0).Name;
                    Account a = [SELECT id,Name,TAM_Name_New__c,TAM_Name_New__r.Name, Secondary_TAM_Name__c,Secondary_TAM_Name__r.Name,X3rd_TAM_Name__c, X3rd_TAM_Name__r.Name 
                                FROM Account WHERE id = :accountId ];
                    accountName = a.Name;
                    List<AccountTeamMember> teamMembers =  new List<AccountTeamMember>([SELECT id,AccountId,UserId,TeamMemberRole 
                                                                                        FROM AccountTeamMember 
                                                                                        WHERE AccountId = : accountId AND TeamMemberRole = 'Technical Account Manager']);
                    if(!teamMembers.isEmpty()) {
                        Set<String> amtIds = new Set<String>();
                        for(AccountTeamMember atm : teamMembers ) {
                            amtIds.add(atm.UserId);
                        }
                        if(String.isNotBlank(a.TAM_Name_New__c) && amtIds.contains(a.TAM_Name_New__c)) {
                            primaryTAM = a.TAM_Name_New__r.Name;
                        }
                        if(String.isNotBlank(a.Secondary_TAM_Name__c) && amtIds.contains(a.Secondary_TAM_Name__c)) {
                            secondaryTAM = a.Secondary_TAM_Name__r.Name;
                        }
                        if(String.isNotBlank(a.X3rd_TAM_Name__c) && amtIds.contains(a.X3rd_TAM_Name__c)) {
                            thirdTAM = a.X3rd_TAM_Name__r.Name;
                        }
                        status = DATA_FOUND;
                    }
                    else {
                        status = TAMs_NOT_PRESENT;
                    }
                }
                else {
                    status = ACCOUNT_ID_NOT_FOUND;
                }
            }
            else {
                status = TENANT_ID_NOT_FOUND;
            }
        }
        else {
            status = REQUEST_PARAM_MISSING;
        }
        ResponseStructure res = new ResponseStructure(accountId, accountName, tenantId, primaryTAM, secondaryTAM, thirdTAM, status);           
        return res;
    }

    //Response Structure.
    global class ResponseStructure{
        String accountId;
        String accountName;
        String tenantId;
        String primaryTAM;
        String secondaryTAM;
        String thirdTAM;
        String status;


        global ResponseStructure(String accountId, String accountName, String tenantId, String primaryTAM, String secondaryTAM, String thirdTAM, String status) {
            this.accountId = accountId;
            this.accountName = accountName;
            this.tenantId = tenantId;
            this.primaryTAM = primaryTAM;
            this.secondaryTAM = secondaryTAM;
            this.thirdTAM = thirdTAM;
            this.status = status;
        }
    }
}