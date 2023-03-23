/*****************************************************************************************
Name: CreateDealRegistration
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to create Deal Registrations from Partner Portal
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     15-May-2020    Initial Development
******************************************************************************************/

@RestResource(urlMapping='/CreateDealRegistration/*')
global class CreateDealRegistration {

    global static final String SUCCESS_MESSAGE = 'Thank you for registering the following deal. We will review your request and contact you shortly. Please note your deal registration request number - [DealRegNumber]. You can check the status of your deal by clicking the \"Check Deal Status\" button';
    global static final String FAILURE_MESSAGE = 'Thank you for registering the following deal. We will review your request and contact you shortly.';
    global static final String INVALID_BULK_REQUEST_INPUT = 'Invalid request. At most one parameter (Partner Domain or Partner Email) is required';
    global static final String INVALID_SINGLE_REQUEST_INPUT = 'Invalid request. Deal Reg Id and Partner Email are mandatory';
    global static final String INVALID_DEAL_REG_ID = 'Invalid request. Deal Reg Id is not valid';
    global static final String INVALID_PARTNER_EMAIL = 'Invalid request. Partner Email is not valid';
    global static final String NO_DATA_FOUND = 'No matching deal registrations found';

    
    /**
     * Implemenation to handle HTTP POST action that creates a new deal registration
     * Sample request:
     * {"customerCompanyName":"GE", "customerContactCountry":"India", "customerContactEmail":"vijay@ge.com", 
     * "customerContactFirstName":"Vijay", "customerContactLastName":"Prakash", "customerContactPhone":"9876543456", 
     * "customerContactAddress":"1001 Rosewood Ave", "customerContactCity":"San Jose", "customerContactPostalCode":"10010",
     * "customerContactState":"Karnataka", "customerRoleAndTitle":"Test Title", "dealDescription":"Test Description", 
     * "dealRegId":"null", "dealSource":"Zscaler Website", "estimatedAmount":"20000.00", "expectedCloseDate":"2016-10-19", 
     * "numberOfSeats":"2000", "partnerAlternateEmail1":"partner1@zscaler.com", "partnerAlternateEmail2":"partner2@zscaler.com", 
     * "partnerAlternateEmail3":"partner3@zscaler.com", "partnerCompanyName":"Zscaler Partner", 
     * "partnerContactEmail":"naresh.kumar@zscaler.com", "partnerContactFirstName":"Naresh", "partnerContactLastName":"Rana", 
     * "partnerContactName":"null", "partnerPhone":"09876456784", "productAreas":"VZen, PZen", "status":"Submitted"}    
     *          
     * Sample response:
     *     {"status_message":"Thank you for registering the following deal. We will review your request and contact you shortly.\\n\\n
     *     Please note your deal registration request number - ZDR-00670\\n\\nYou can check the status of your deal by clicking the 
     *     \\\"Check Deal Status\\\" button","status_code":"1","dealRegId":"ZDR-00670"}
     *     
     * @param  request Deal registration model request
     * @return         Returns the ID (Deal_Reg__c.Name) of the created record and status
     */
    @HttpPost
    global static void registerNewDeal() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        DealRegistrationResponseModel response = new DealRegistrationResponseModel();
        System.debug(restReq.requestBody.toString());
        DealRegistrationPortalModel request = (DealRegistrationPortalModel)JSON.deserialize(restReq.requestBody.toString(), DealRegistrationPortalModel.class);
        System.debug(request);
        String dealRegId, dealRegName, excep;

        if(request.customerCompanyName == null || 
            request.customerCompanyName == '' ||
            request.partnerAccountId == null || 
            request.partnerAccountId == '' || 
            request.partnerContactId == null || 
            request.partnerContactId == '' ||
            request.customerContactEmail == null || 
            request.customerContactEmail == ''){
                response.dealRegId = null;
                response.status_message = 'Partner Contact, Account, Customer Name and Email are mandatory to create Deal Registration.';
                response.status_code = '-1';
                restRes.responseBody = Blob.valueOf(JSON.serialize(response));
                restRes.statusCode = 400;
        }else{
            Deal_Reg__c dealReg = new Deal_Reg__c(
                                End_Customer_Name__c = request.customerCompanyName,
                                End_Customer_Contact_Name__c = request.customerContactFirstName,
                                End_Customer_Contact_Last_Name__c = request.customerContactLastName,
                                End_Customer_Phone__c = request.customerContactPhone,
                                End_Customer_Email__c = request.customerContactEmail,
                                End_Customer_Street_Address__c = request.customerContactAddress,
                                End_Customer_City__c = request.customerContactCity,
                                End_Customer_Postal_Code__c = request.customerContactPostalCode,
                                End_Customer_State__c = request.customerContactState,
                                End_Customer_Country__c = request.customerContactCountry,
                                End_Customer_TC_Name__c = request.technicalContactFirstName,
                                End_Customer_TC_Last_Name__c = request.technicalContactLastName,
                                End_Customer_TC_Phone__c = request.technicalContactPhone,
                                End_Customer_TC_Email__c = request.technicalContactEmail,
                                Technical_Contact_Role_and_Title__c = request.technicalRoleAndTitle,
                                /*End_Customer_TC_Street_Address__c = request.customerContactAddress,
                                End_Customer_TC_City__c = request.customerContactCity,
                                End_Customer_TC_Postal_Code__c = request.customerContactPostalCode,
                                End_Customer_TC_State__c = request.customerContactState,
                                End_Customer_TC_Country__c = request.customerContactCountry,*/
                                Number_Of_Users__c = request.numberOfSeats,
                                Deal_Reg_Type__c = request.dealRegType,
                                Partner_Company_Name__c = request.partnerCompanyName,
                                Partner_Contact_Email__c = request.partnerContactEmail,
                                Partner_Contact_Name__c = request.partnerContactFirstName,
                                Partner_Contact_Last_Name__c = request.partnerContactLastName,
                                Partner_Phone__c = request.partnerPhone,
                                Expected_Close_Date__c = request.expectedCloseDate,
                                Estimated_Amount__c = request.estimatedAmount,
                                Deal_Description__c = request.dealDescription,
                                Customer_Role_And_Title__c = request.customerRoleAndTitle,
                                Product_Areas__c = request.productAreas,
                                Partner_Alternate_Email_1__c = request.partnerAlternateEmail1,
                                Partner_Alternate_Email_2__c = request.partnerAlternateEmail2,
                                Security_ISA_Name__c = request.partnerISAName,
                                Security_ISA_Email__c = request.partnerISAEmail,
                                Partner_Contact__c = request.partnerContactId,
                                Partner_Account__c = request.partnerAccountId,
                                AW_Partner_Intent__c = request.partnerIntendtoAW,
                                POV_Partner_Intent__c = request.partnerIntendtoPOV,
                                Source__c = 'Zscaler Website'
                            );
            try {
                //Create the new deal registration record
                //Creation / assignment of contact / lead has been taken care of in the trigger
                insert dealReg;

                List<Deal_Reg__c> drlst = [SELECT Id, Name FROM Deal_Reg__c WHERE Id = :dealReg.Id LIMIT 1];
                
                if(!drlst.isEmpty()){
                    dealRegId = drlst[0].Id;
                    dealRegName = drlst[0].Name;
                }

                //Set the response parameters
                response.dealRegId = dealRegId;
                response.status_message = SUCCESS_MESSAGE.replace('[DealRegNumber]', dealRegName);
                response.status_code = '1';
                restRes.responseBody = Blob.valueOf(JSON.serialize(response));
            } catch (Exception ex) {
                System.debug('Deal Registration Service Error: ' + ex.getMessage() + '\nStack trace: ' + ex.getStackTraceString());
                excep = ex.getMessage();
                //Set the response parameters
                response.dealRegId = null;
                response.status_message = FAILURE_MESSAGE;
                response.status_code = '-1';
                restRes.responseBody = Blob.valueOf(JSON.serialize(response));
                restRes.statusCode = 400;
            }
        }
        
        CreateIntegrationLogs.createLogs(dealRegId, 'POST', '', '', restReq.requestBody.toString(), restRes.responseBody.toString(), string.valueOf(restRes.statusCode), restRes.statusCode == 200 ? 'Success': 'Failure', excep, 'CreateDealRegistration', request.partnerContactId);
    }

    /**
     * Wrapper class to send in the POST response body
     */
    global class DealRegistrationResponseModel {
        public String dealRegId;
        public String status_message;
        public String status_code;
    }

    global class DealRegistrationPortalModel {

        public String customerCompanyName;
        public String customerContactFirstName;
        public String customerContactLastName;
        public String customerContactEmail;
        public String customerContactAddress;
        public String customerContactCity;
        public String customerContactPostalCode;
        public String customerContactCountry;
        public String customerContactState;
        public String customerContactPhone;
        public String customerRoleAndTitle;
        public String partnerCompanyName;
        public String partnerContactFirstName;
        public String partnerContactLastName;
        public String partnerContactEmail;
        public String partnerPhone;
        public String partnerAlternateEmail1;
        public String partnerAlternateEmail2;
        public String partnerISAName;
        public String partnerISAEmail;
        public Integer numberOfSeats;
        public String dealDescription;
        public Decimal estimatedAmount;
        public Date expectedCloseDate;
        public String productAreas;
        public String technicalContactFirstName;
        public String technicalContactLastName;
        public String technicalContactPhone;
        public String technicalContactEmail;
        public String technicalRoleAndTitle;
        public String dealRegType;
        public String partnerContactId;
        public String partnerAccountId;
        public String partnerIntendtoAW;
        public String partnerIntendtoPOV;
    
    }

    public class DealRegistrationException extends Exception {

    }
}