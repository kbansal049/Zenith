public class FevaProductAdditionController {
        
        public string provReqId {get; set;}
        public list<Product2> addedProductList{get; set;}
        public list<Product2> allProductList{get; set;} 
        public id productId {get; set;}
        public set<id> addedProdSet{get; set;}
        public Boolean isZPAProductIncluded {get; set;}
        public Boolean isOpportunityVZENApproved {get; set;}
        public Boolean isMandatoryFieldsFilled {get; set;}
        public Boolean isError {get; set;}
        public Boolean isErroronVZEN {get; set;}
        public Boolean isErroronApproval {get; set;}
        public Boolean ErrorMessage {get; set;}
        public string recordTypeId {get; set;}
        public FevaProductAdditionController(){
            provReqId  =  ApexPages.currentPage().getParameters().get('reqId');
            set<id> productIdSet = new set<Id>(); 
            addedProdSet = new set<Id>();
            isError = false;
            isErroronVZEN = false;
            ErrorMessage = false;
            isErroronApproval = False;//Added by Swathi: CR 2138
            isMandatoryFieldsFilled = true;
            boolean isPartnerOrInternalUser = false;
            string priceListId = '';
            string cpqPriceListId = '';//Added by Swathi: CR 3232
            isZPAProductIncluded = true;
            if(provReqId != null && provReqId != ''){
                Provisioning_Request__c provReq = [SELECT Id, Opportunity__r.ZPA__c, Opportunity__r.Approved_Equipment_Request_VZEN__c, Internal_user__c, Account__c, Account__r.Type, Customer_Plans_To_Use_ZPA__c, Price_List_Id__c, RecordTypeId,Approval_Status__c,Opportunity__r.Opp_Price_List__c FROM Provisioning_Request__c WHERE Id = :provReqId LIMIT 1];
                isZPAProductIncluded = (provReq != null && provReq.Opportunity__r.ZPA__c > 0) ? true : false;
                isOpportunityVZENApproved = provReq.Opportunity__r.Approved_Equipment_Request_VZEN__c; 
                //Commenting as part of CR# 4351 Start
                //priceListId = (provReq != null && provReq.Price_List_Id__c != null) ? provReq.Price_List_Id__c : '';
                //cpqPriceListId = (provReq != null && provReq.Opportunity__r.Opp_Price_List__c != null) ? provReq.Opportunity__r.Opp_Price_List__c : '';//Added by Swathi: CR 3232
                //Commenting as part of CR# 4351 Start
                cpqPriceListId = (provReq != null && provReq.Price_List_Id__c != null) ? provReq.Price_List_Id__c : '';//Modified as part of CR#4351
                recordTypeId = (provReq != null && provReq.RecordTypeId != null) ? provReq.RecordTypeId : '';
                system.debug('recordTypeId ' + recordTypeId);
                system.debug('isZPAProductIncluded '+isZPAProductIncluded);
                system.debug('isOpportunityVZENApproved '+isOpportunityVZENApproved);
                system.debug('priceListId '+priceListId);
                /*if(provReq.Customer_Plans_To_Use_ZPA__c != null) {
                    isMandatoryFieldsFilled = true;
                } else {
                    isMandatoryFieldsFilled = false;
                }*/
                //Added by Swathi: CR 2138 start
                if ( provReq.Approval_Status__c=='Pending Approval'){
                    isErroronApproval = True;
                }
                //Added by Swathi: CR 2138 End
                System.debug('isErroronApproval'+isErroronApproval);
                    
                if(provReq != null && provReq.Account__c != null &&  provReq.Account__r.Type == 'Customer'){
                    isZPAProductIncluded = true;
                }
                
                system.debug('isZPAProductIncluded '+isZPAProductIncluded);
                
                if(!isPartnerOrInternalUser){
                    isPartnerOrInternalUser = (provReq != null && provReq.Account__c != null &&  (provReq.Account__r.Type == 'Partner' || provReq.Account__r.Type == 'Technology Partner')) ? true : false;
                    if(isPartnerOrInternalUser){
                        system.debug('enters       ');
                        isMandatoryFieldsFilled = true;
                        isZPAProductIncluded = true;
                    }
                }
                if(!isPartnerOrInternalUser){
                    isPartnerOrInternalUser = (provReq != null && provReq.Internal_user__c) ? true : false;
                    if(isPartnerOrInternalUser){
                        system.debug('enters       ');
                        isMandatoryFieldsFilled = true;
                        isZPAProductIncluded = true;
                    }
                }
                
                provReq = null;

                for(POC_Product__c pocProduct : [Select id, Product__c,Provisioning_Request__c from POC_Product__c where Provisioning_Request__c =: provReqId]){
                    if(pocProduct.Product__c != null){
                        system.debug('product is not null    ');
                        productIdSet.add(pocProduct.Product__c);
                        addedProdSet.add(pocProduct.Product__c);
                    }   
                }
            }
            addedProductList = new list<Product2>();
            allProductList = new list<Product2>();
            set<Id> priceListProductIdSet = new set<Id>();
            //Commenting as part of CR# 4351 Start
            /*if(priceListId != '' && priceListId != null){
                if(recordTypeId != '' && recordTypeId == Label.C_B_I_Record_Type_Id){
                    for(Apttus_Config2__PriceListItem__c priceListItem : [Select id, Apttus_Config2__ProductId__c from Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c =: priceListId AND Apttus_Config2__ProductId__r.IsActive =: true AND Apttus_Config2__ProductId__r.Finance_Product_Line__c =: 'ZIA Isolation']){
                        priceListProductIdSet.add(priceListItem.Apttus_Config2__ProductId__c);
                    }
                }else{
                    for(Apttus_Config2__PriceListItem__c priceListItem : [Select id, Apttus_Config2__ProductId__c from Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c =: priceListId AND Apttus_Config2__ProductId__r.IsActive =: true AND Apttus_Config2__ProductId__r.Finance_Product_Line__c !=: 'ZIA Isolation']){
                        priceListProductIdSet.add(priceListItem.Apttus_Config2__ProductId__c);
                    }
                }
            }*/
            //Commenting as part of CR# 4351 End
            //Added by Swathi: CR 3232 Start
            if(cpqPriceListId != '' && cpqPriceListId != null){
                if(recordTypeId != '' && recordTypeId == Label.C_B_I_Record_Type_Id){
                    for(SBQQ__LookupData__c priceListItem : [Select id, SBQQ__Product__c from SBQQ__LookupData__c Where Price_List__c =: cpqPriceListId AND SBQQ__Product__r.IsActive =: true AND SBQQ__Product__r.Finance_Product_Line__c =: 'ZIA Isolation']){
                        priceListProductIdSet.add(priceListItem.SBQQ__Product__c);
                    }
                }else{
                    for(SBQQ__LookupData__c priceListItem : [Select id, SBQQ__Product__c from SBQQ__LookupData__c Where Price_List__c =: cpqPriceListId AND SBQQ__Product__r.IsActive =: true AND SBQQ__Product__r.Finance_Product_Line__c !=: 'ZIA Isolation']){
                        priceListProductIdSet.add(priceListItem.SBQQ__Product__c);
                    }
                }
            }
            //Added by Swathi: CR 3232 End
            system.debug('priceListProductIdSet.size   '+priceListProductIdSet.size());
            system.debug('priceListProductIdSet   '+priceListProductIdSet);
            if(!productIdSet.isEmpty()){
                system.debug('productIdSet is not null    ');
                for(Product2 prod : [Select Id, Name,ProductCode,POC_Products__c, Product_Category__c, VZen__c from Product2 where ID IN: productIdSet]){
                    system.debug('prod  '+prod);
                    addedProductList.add(prod);
                }
            }else{
                system.debug('productIdSet is  null    ');
                for(Product2 prod : [Select Id, Name,ProductCode,POC_Products__c, Product_Category__c, VZen__c  from Product2 where POC_Products__c =: 'Popular' AND Id IN: priceListProductIdSet]){
                    system.debug('prod  '+prod);
                    addedProductList.add(prod);
                    productIdSet.add(prod.Id);
                }
            }
            system.debug('productIdSet '+productIdSet);
            for(Product2 prod : [Select Id, Name,ProductCode,POC_Products__c, Product_Category__c, VZen__c, Finance_Product_Line__c from Product2 where POC_Products__c != '' AND ID NOT IN: productIdSet AND Id IN: priceListProductIdSet]){
                system.debug('prod  '+prod);
                if(recordTypeId == Label.C_B_I_Record_Type_Id && prod.Finance_Product_Line__c == 'ZIA Browser Isolation'){
                    allProductList.add(prod);
                }else if(prod.Finance_Product_Line__c != 'ZIA Browser Isolation'){
                    allProductList.add(prod);
                }
            }
            system.debug('allProductList '+allProductList);
            
        }

        public PageReference addProduct(){
            integer i = -1;
            Product2 tempProd = new Product2();
            boolean prodFound = false;
            isError = false;
            isErroronVZEN = false;
            ErrorMessage = false;
            system.debug('allProductList.size   '+allProductList.size());
            system.debug('allProductList    '+allProductList);
            for(Product2 prod : allProductList){
                i++;            
                if(prod.Id == productId){
                    prodFound = true;
                    tempProd = prod;
                    break;
                }
            }
            if(prodFound){
                system.debug('prodFound is true ');
                /**if (tempProd.ProductCode.contains('ZPA') && !isZPAProductIncluded) {
                        system.debug('first if is true  ');
                    isError = true;
                    return null;
                } else if (!isMandatoryFieldsFilled && tempProd.ProductCode.contains('ZPA')) {
                        system.debug('first else if is true ');
                    isError = true;
                    return null;
                }else**/ 
                if(tempProd.VZen__c && !isOpportunityVZENApproved){
                    system.debug('Second else if is true    ');
                    isError = true;
                    isErroronVZEN = true;
                    return null;
                }

                allProductList.remove(i);
                addedProductList.add(tempProd);
                system.debug('allProductList    '+allProductList);
                system.debug('addedProductList  '+addedProductList);
            }   
            return null;
        }
        
        public PageReference removeProduct(){
            integer i = -1;
            Product2 tempProd = new Product2();
            boolean prodFound = false;
            isError = false;
            ErrorMessage = false;
            system.debug('addedProductList  '+addedProductList);
            for(Product2 prod : addedProductList){
                i++;            
                if(prod.Id == productId){
                    prodFound = true;
                    tempProd = prod;
                    break;
                }
            }
            system.debug('prodFound '+prodFound);
            if(prodFound){
                addedProductList.remove(i);
                allProductList.add(tempProd);
                system.debug('allProductList    '+allProductList);
                system.debug('addedProductList  '+addedProductList);
            }   
            return null;
        }
        
        public PageReference saveProduct(){
            list<POC_Product__c> insertPOCProdList = new list<POC_Product__c>();
            list<POC_Product__c> deletePOCProdList = new list<POC_Product__c>();
            set<id> newProdSet = new set<Id>();
            set<id> allProdSet = new set<Id>();
            
            system.debug('addedProductList.size()       '+addedProductList.size());
            system.debug('addedProductList      '+addedProductList);
            system.debug('addedProdSet      '+addedProdSet);
            
            for(Product2 prod : addedProductList){
                allProdSet.add(prod.id);
                if(!addedProdSet.contains(prod.id)){
                    newProdSet.add(prod.id);                
                }
            }
            system.debug('allProdSet        '+allProdSet);
            system.debug('newProdSet        '+newProdSet);
            for(Id prodId : newProdSet){
                POC_Product__c tempPocProd = new POC_Product__c();
                tempPocProd.Product__c = prodId;
                tempPocProd.Provisioning_Request__c = provReqId;
                insertPOCProdList.add(tempPocProd);         
            }
            
            set<Id> prodDelSet = new set<Id>();
            for(Id prodId : addedProdSet){
                system.debug('prodId    '+prodId);
                if(!allProdSet.contains(prodid)){
                    system.debug('allProdSet not contains '+prodId);
                    prodDelSet.add(prodid);
                }
                
            }
            system.debug('prodDelSet        '+prodDelSet);
            /* for(Id prodId : addedProdSet){
                system.debug('prodId    '+prodId);
                for(Product2 prod : addedProductList){
                    system.debug('prod.id   '+prod.Id);
                    if(prod.Id != prodId && !newProdSet.contains(prod.id)){
                        prodDelSet.add(prod.Id);
                    }
                }
            } */
            
            deletePOCProdList = [Select id,Product__c from POC_Product__c where Product__c IN:prodDelSet AND Provisioning_Request__c =: provReqId];
            system.debug('deletePOCProdList size    '+deletePOCProdList.size());
            system.debug('deletePOCProdList '+deletePOCProdList);
            system.debug('insertPOCProdList '+insertPOCProdList);
            try{
                if(!deletePOCProdList.isEmpty()){
                    delete deletePOCProdList;
                }
                Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
                Id cbiRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Cloud Browser Isolation (C.B.I)').getRecordTypeId();
                if(!insertPOCProdList.isEmpty()){
                    insert insertPOCProdList;
                    //Added by Swathi: CR 2138 start
                    for(Provisioning_Request__c PR: [Select id,RecordTypeId,Approval_Status__c,SE_Manager__c,CreatedByID,CreatedBy.ProfileId,Area__c,GEO__c from Provisioning_Request__c where ID =: provReqId]){
                        //System.debug('PR.SE_Manager__c ' + PR.SE_Manager__c);
                        if((PR.RecordTypeId == inlineRecordTypeId || PR.RecordTypeId == cbiRecordTypeId) 
                           && PR.Approval_Status__c!='Approved' && PR.SE_Manager__c!=Null 
                           && (!System.Label.Finance_V2_Profile_ID.contains(PR.CreatedBy.ProfileId) && PR.CreatedByID!=System.Label.PRUserIdToExcludeFromApproval)
                           && PR.GEO__c!='WW Commercial'){
                            Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
                            newApprovalRequest.setComments('Submit for Manager\'s approval');
                            newApprovalRequest.setObjectId(PR.Id);
                            newApprovalRequest.setSubmitterId(PR.CreatedByID);
                            Approval.ProcessResult result = Approval.process(newApprovalRequest);
                        }
                    }
                    //Added by Swathi: CR 2138 End
                }                   
                PageReference pageRef = new PageReference('/'+provReqId);
                return pageRef;
            }catch(Exception ex){
                System.debug('Error occurred while closing the opportunity. Error: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
                ErrorMessage = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,ex.getMessage()));
                return null;

            }
         
        }
    }