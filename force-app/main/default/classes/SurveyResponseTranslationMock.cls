/*****************************************************************************************
Name: SurveyResponseTranslationController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex Controller for making a Google Translate API Callout to translate survey responses to English.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR                   DATE            DETAIL              
1.0                Adarsh Pidaparthy        07/21/2022      CR#5100    Translate survey responses to user's native language
******************************************************************************************/ 
@isTest
global class SurveyResponseTranslationMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{ "data": { "translations": [ { "translatedText": "tell us the reason for your score" }, { "translatedText": "reason for your score" }, { "translatedText": "please tell us" }, { "translatedText": "of your score" }, { "translatedText": "additional feedback, such as the performance of the engineer(s), what we did well or where we can improve" } ] } }');
        response.setStatusCode(200);
        return response; 
    }

}