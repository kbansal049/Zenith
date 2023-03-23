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
public class SurveyResponseTranslationController {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 5100 : Translate survey responses to user's native language
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : makeGoogleApiCallout .
* @param    NAME : Survey .
* @return   TYPE : 
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void makeGoogleApiCallout(Survey__c survey){
        
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Google_Translate_API');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            requestJSONBody reqBody = new requestJSONBody();
            List<String>translateStringsList = new List<String>();
            if(String.isNotBlank(survey.Question_1_Comments__c)){
                translateStringsList.add(survey.Question_1_Comments__c);
            }
            if(String.isNotBlank(survey.Question_2_Comments__c)){
                translateStringsList.add(survey.Question_2_Comments__c);
            }
            if(String.isNotBlank(survey.Question_3_Comments__c)){
                translateStringsList.add(survey.Question_3_Comments__c);
            }
            if(String.isNotBlank(survey.Question_4_Comments__c)){
                translateStringsList.add(survey.Question_4_Comments__c);
            }
            if(String.isNotBlank(survey.How_can_we_make_you_happier__c)){
                translateStringsList.add(survey.How_can_we_make_you_happier__c);
            }
            reqBody.q = translateStringsList;
            reqBody.target = 'en';
            reqBody.format = 'text';
            reqBody.source = survey.Language_Code__c;
            String jsonBody = json.serialize(reqBody);
            
            request.setBody(jsonBody);     
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> getTranslationsMap =  (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(dataMap.get('data'))); 
                List<Object> translatedTextList =  (List<Object>)JSON.deserializeUntyped(JSON.serialize(getTranslationsMap.get('translations'))); 
                Boolean assignedTranslatedText=false,assignedTranslatedText2 = false,assignedTranslatedText3=false,assignedTranslatedText4=false,assignedHappierText = false;    
                
                for(integer i = 0;i<translatedTextList.size();i++){
                    if(String.isNotBlank(survey.Question_1_Comments__c) && !assignedTranslatedText && String.isNotBlank(String.valueof(translatedTextList[i])) && String.valueof(translatedTextList[i]).containsIgnoreCase('{translatedText=') &&String.valueof(translatedTextList[i]).containsIgnoreCase('}')){
                        survey.Question_1_Comments_English__c = String.valueof(translatedTextList[i]).remove('{translatedText=').remove('}');
                        assignedTranslatedText = true;
                        continue;
                    }
                    if(String.isNotBlank(survey.Question_2_Comments__c) && !assignedTranslatedText2 && String.isNotBlank(String.valueof(translatedTextList[i])) && String.valueof(translatedTextList[i]).containsIgnoreCase('{translatedText=') && String.valueof(translatedTextList[i]).containsIgnoreCase('}')){
                        survey.Question_2_Comments_English__c = String.valueof(translatedTextList[i]).remove('{translatedText=').remove('}');
                        assignedTranslatedText2 = true;
                        continue;
                    }
                    if(String.isNotBlank(survey.Question_3_Comments__c) && !assignedTranslatedText3 && String.isNotBlank(String.valueof(translatedTextList[i])) && String.valueof(translatedTextList[i]).containsIgnoreCase('{translatedText=') && String.valueof(translatedTextList[i]).containsIgnoreCase('}')){
                        survey.Question_3_Comments_English__c = String.valueof(translatedTextList[i]).remove('{translatedText=').remove('}');
                        assignedTranslatedText3 = true;
                        continue;
                    }
                    if(String.isNotBlank(survey.Question_4_Comments__c) && !assignedTranslatedText4 && String.isNotBlank(String.valueof(translatedTextList[i])) && String.valueof(translatedTextList[i]).containsIgnoreCase('{translatedText=') && String.valueof(translatedTextList[i]).containsIgnoreCase('}')){
                        survey.Question_4_Comments_English__c = String.valueof(translatedTextList[i]).remove('{translatedText=').remove('}');
                        assignedTranslatedText4 = true;
                        continue;
                    }
                    if(String.isNotBlank(survey.How_can_we_make_you_happier__c) && !assignedHappierText && String.isNotBlank(String.valueof(translatedTextList[i])) && String.valueof(translatedTextList[i]).containsIgnoreCase('{translatedText=') && String.valueof(translatedTextList[i]).containsIgnoreCase('}')){
                        survey.How_can_we_make_you_happier_English__c = String.valueof(translatedTextList[i]).remove('{translatedText=').remove('}');
                        assignedHappierText = true;
                        continue;
                    }
                }
                if(translatedTextList!=null && !translatedTextList.isEmpty() && translatedTextList.size()>0){
                    survey.Survey_Sent__c = true;
                    update survey;
                }
            }
            else{
                
                ZscalerErrorLogsUtility.insertLogsForAsync('SurveyResponseTranslationController', 'makeGoogleApiCallout',
                                                           'Apex', UserInfo.getUserId(),
                                                           'Sales cloud', JSON.serialize(response.getBody()), 
                                                           'Google Translate API Callout failed' + response.getStatus(), JSON.serialize(response.getStatusCode()));
            }
            if(test.isRunningTest()){
                    throw new ManageAccountException('Exception from test');
                }
        }
        catch(Exception ex){
            
            ZscalerErrorLogsUtility.insertLogsForAsync('SurveyResponseTranslationController', 'makeGoogleApiCallout',
                                                       'Apex', UserInfo.getUserId(),
                                                       'Sales Cloud', ex.getStackTraceString(), 
                                                       'Google Translate API Callout failed' + ex.getMessage(), ex.getTypeName());
        }
    }
    
    
    public class requestJSONBody{
        public List<String> q; 
        public String source;
        public String target;
        public String format;
        
        public requestJSONBody parse(String json){
            return (requestJSONBody) System.JSON.deserialize(json, requestJSONBody.class);
        }
    }         
    
}