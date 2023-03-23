/**
 * @description       : This class will contains over loaded selector methods Knowledge Article Feedback
 * @author            : Ram Sangati
 * @last modified on  : 01-11-2023
 * @last modified by  : Ram Sangati
**/
public without sharing class KnowledgeArticleSelector {
    /**
     * This method will return a single Knowledge Article based on given input
     * @param  kaId      kknowledge article id
     * @param  kaUrlName knowledge article UrlName
     * @return           Knowledge Article / null
     */
    public static KB__kav getKB(String kaId, String kaUrlName){
        if(String.isNotBlank(kaId)){
            return [SELECT Id, Title, UrlName, Author__c, Author__r.Name, Author__r.Email, OwnerId, Owner.Name, Owner.Email, Technical_Reviewer__c, Technical_Reviewer__r.Name, Technical_Reviewer__r.Email FROM KB__kav WHERE Id = :kaId LIMIT 1];
        }else if(String.isNotBlank(kaUrlName)){
            return [SELECT Id, Title, UrlName, Author__c, Author__r.Name, Author__r.Email, OwnerId, Owner.Name, Owner.Email, Technical_Reviewer__c, Technical_Reviewer__r.Name, Technical_Reviewer__r.Email FROM KB__kav WHERE UrlName = :kaUrlName LIMIT 1];
        }else{
            return null;
        }
    }

    /**
     * This method will return List of Knowledge Articles based on given input
     * @param  fields        fields
     * @param  whereClause   whereClause
     * @param  orderByClause orderByClause
     * @param  limitClause   limitClause
     * @return               List of Knowledge Articles / null
     */
    public static List<KB__kav> getKBs(String fields, String whereClause, String orderByClause, Integer limitClause){
        List<KB__kav> kbsList = null;
        if(String.isNotBlank(fields)){
            String soql = 'SELECT ' + fields + ' FROM KB__kav';

            if(String.isNotBlank(whereClause)){
                soql += ' WHERE ' + whereClause;
            }

            if(String.isNotBlank(orderByClause)){
                soql += ' ORDER BY ' + orderByClause;
            }

            if(limitClause <= 0){
                soql += ' LIMIT 1';
            }else if(limitClause > 0 && limitClause <= 50000){
                soql += ' LIMIT ' + limitClause;
            }else{
                soql += ' LIMIT 50000';
            }

            kbsList = Database.query(soql);
        }
        return kbsList;
    }
}