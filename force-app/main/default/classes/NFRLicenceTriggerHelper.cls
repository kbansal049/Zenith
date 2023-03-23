public class NFRLicenceTriggerHelper {
    
    public static map<id,string> getAccountOwnerEmails(set<id> accountOwnerIds){
        map<id,string>AccountOwnerEmailsMap = new map<id,string>();
        for(user userRecord:[Select id,Email From User Where id In:accountOwnerIds]){
            if(userRecord.Email != null){
                AccountOwnerEmailsMap.put(userRecord.Id,userRecord.Email);
            }
        }
        return AccountOwnerEmailsMap;
    }
    
    public static list<string> getSpecificUserEMails(){
        list<string> userEmails = new list<string>();
        list<string> userNames = new list<string>{'Charan Kumar','Ben Teague'};
         for(user userRecord:[Select id,Email From User Where Name In:userNames]){
            if(userRecord.Email != null){
                userEmails.add(userRecord.Email);
            }
        }
        return userEmails;
    }
    
    //CR# 3535 Code change - Start
    private List<Provisioning_Request__c> prList;
    public void setPrList(List<Provisioning_Request__c> prList) {
        this.prList = prList;
    }
    
    private Provisioning_Request__c provReq;
    public void setProvReq(Provisioning_Request__c provReq) {
        this.provReq = provReq;
    }
    public Provisioning_Request__c getProvReq() {
        return provReq;
    }
    
    private Map<String, List<String>> cloudPOCProductMap;
    public void setCloudPOCProductMap(Map<String, List<String>> cloudPOCProductMap) {
        this.cloudPOCProductMap = cloudPOCProductMap;
    }

    private Map<String, Product2> skuIdProductMap;
    private void setSkuIdProductMap(Map<String, Product2> skuIdProductMap) {
        this.skuIdProductMap = skuIdProductMap;
    }

    public void generateSkuProductMap(Set<String> productSKUSet) {
        Map<String, Product2> skuIdProductMap = new Map<String, Product2> ();
        
        for (Product2 product : [SELECT Id, Product_SKU_External_ID__c FROM product2 WHERE Product_SKU_External_ID__c IN :productSkuSet]) {
            skuIdProductMap.put(product.Product_SKU_External_ID__c, product);
        }
        setSkuIdProductMap(skuIdProductMap);
    }
    
    public List<POC_Product__c> preparePOCProductListUpdated1(){
        List<POC_Product__c> pocProductList = new List<POC_Product__c>();
        Set<String> productSkuSet = new Set<String> ();
        
        
        List<String> skuIdProductList = new List<String> ();

        if (cloudPOCProductMap.containsKey(provReq.Product_Line_for_PR__c)) {
            skuIdProductList = cloudPOCProductMap.get(provReq.Product_Line_for_PR__c);

            provReq.Products__c = String.join(skuIdProductList, ';');

        }

        setProvReq(provReq);

        productSkuSet.addAll(skuIdProductList);
        for (String productSkuCode : productSkuSet) {

            POC_Product__c POCRecord = new POC_Product__c();
            If(skuIdProductMap.get(productSkuCode)!=null)
                POCRecord.Product__c = skuIdProductMap.get(productSkuCode).Id;
            POCRecord.Provisioning_Request__c = provReq.Id;
            pocProductList.add(POCRecord);
        }

        return pocProductList;
    }
    
    
   
    
    private static NFRLicenceTriggerHelper instance;
    public static NFRLicenceTriggerHelper getInstance() {
        if (instance == NULL) {
            instance = new NFRLicenceTriggerHelper();
        }
        
        return instance;
    }
    
    //CR# 3535 Code change - End
    
}