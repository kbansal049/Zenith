public class CaseStatusUpdateController {
@AuraEnabled
public static void associateCaseWithKnowledge(String CaseId, String knowledgeId, String category, String subcategory, String caseProduct){
    if(!String.isBlank(CaseId) && !String.isBlank(knowledgeId)){
        CaseArticle csa = new CaseArticle();
        csa.CaseId = CaseId;
        String knowledgeArticleId = [select KnowledgeArticleId from KB__kav where Id=:knowledgeId].KnowledgeArticleId;
        csa.KnowledgeArticleId = knowledgeArticleId;
        insert csa;
        
        String associatingDataCategory;
        if(!String.isBlank(subcategory)){
            associatingDataCategory = subcategory;
        }else if(!String.isBlank(category)){
            associatingDataCategory = category;
        }else if(!String.isBlank(caseProduct)){
            associatingDataCategory = caseProduct;
        }
        
        if(!String.isBlank(associatingDataCategory)){
            String categoryName;
            categoryName = associateDataCategory(knowledgeId, associatingDataCategory);
            system.debug('Category Name New-->'+categoryName);
            if(!String.isBlank(categoryName)){
                KB__DataCategorySelection kbd = new KB__DataCategorySelection();
                kbd.DataCategoryGroupName = 'Zscaler';
                kbd.DataCategoryName = categoryName;
                kbd.ParentId = knowledgeId;
                insert kbd;
            }  
        }
        
    }
}

public static String associateDataCategory(String knowledgeId, String subCategory){
    List<DescribeDataCategoryGroupResult> describeCategoryResult;
    List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
    List<String> objType = new List<String>();
    objType.add('KnowledgeArticleVersion');
    describeCategoryResult = Schema.describeDataCategoryGroups(objType);
    //system.debug(describeCategoryResult);
    List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
    for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
        DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
        if(singleResult.getName() == 'Zscaler'){
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            system.debug('this is p--->'+p);
            pairs.add(p);
        }
        
    }
                
    describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
    Map<String, List<String>> mapOfCatAndChild = new Map<String, List<String>>();
    Map<String, String> mapOflabelAndName = new Map<String, String>();
    String catApiName = '';
    for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
        DataCategory [] toplevelCategories = singleResult.getTopCategories();
        
        List<DataCategory> allCategories = getAllCategories(toplevelCategories);
        
        for(DataCategory category : allCategories) {
            DataCategory [] childCategories = category.getChildCategories();
            List<String> listOfChild = new List<String>();
            for(DataCategory cat:childCategories){
                listOfChild.add(cat.getLabel());
                if(cat.getLabel() == subcategory){
                    catApiName = cat.getName();
                    return catApiName;
                }
            }
        }
    }
    return catApiName;
}

private static DataCategory[] getAllCategories(DataCategory [] categories){
    if(categories.isEmpty()){
        return new DataCategory[]{};
    } else {
        DataCategory [] categoriesClone = categories.clone();
        DataCategory category = categoriesClone[0];
        DataCategory[] allCategories = new DataCategory[]{category};
        categoriesClone.remove(0);
        categoriesClone.addAll(category.getChildCategories());
        allCategories.addAll(getAllCategories(categoriesClone));
        return allCategories;
    }
}

@AuraEnabled
public static boolean isKnowledgeArticleAttached(String CaseId){
    List<CaseArticle> listCaseArticles=[Select Id,CaseId from CaseArticle where CaseId = :CaseId];
    if(listCaseArticles.size()>0){
        return true;
    }
    else {
        return false;
    }
}
}