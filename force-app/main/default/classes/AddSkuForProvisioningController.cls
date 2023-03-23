/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-05-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class AddSkuForProvisioningController {
    
    public Static Id PGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();

    @AuraEnabled(Cacheable=true)
    public static List<Provisioning_Product__c> getExistingSKUsOfPG(Id pgId){
        System.debug('inside getExistingSKUsOfPG '+ pgId);
       return [select Id, Product_Line__c, Product__c, Provisioning_Group__c,
                    SKU__c, Product_Name__c,Quantity__c,Provisioning_Broker_Eligible__c,Provisioning_Sub_Product_Line__c 
                    from Provisioning_Product__c 
                    where Provisioning_Group__c = :pgId
                    and Product__r.isActive=true and Product__r.Is_Applicable_for_POC__c=true 
                    and Product__r.Provisioning_Product_Family__c='Bundles' 
                    and (NOT Product__r.ProductCode like '%FED%')];
                  
    }

    @AuraEnabled(Cacheable=true)
    public static List<Provisioning_Product__c> getExistingAddOnsOfPG(Id pgId){
        System.debug('inside getExistingAddOnsOfPG '+ pgId);
        return [select Id,  Product_Line__c, Product__c, Provisioning_Group__c,
                    SKU__c, Product_Name__c,Quantity__c,Provisioning_Broker_Eligible__c,Provisioning_Sub_Product_Line__c 
                    from Provisioning_Product__c 
                    where Provisioning_Group__c = :pgId
                    and Product__r.isActive=true 
                    and Product__r.Is_Applicable_for_POC__c=true 
                    and (Product__r.Provisioning_Product_Family__c='Addon' OR Product__r.Provisioning_Product_Family__c='Package')
                    and ( NOT Product__r.ProductCode like '%FED%')];
    }


    @AuraEnabled(cacheable=true)
    public static List<Product2> getPOVProductList(String prodLine){
       return [Select id , Name , Product_Line__c, 
                isActive, ProductCode,SKU_Category__c,SKU_Type__c,
                Provisioning_Broker_Eligible__c,Provisioning_Sub_Product_Line__c,Auto_Provisioning_Status__c 
                from Product2 
                where isActive=true 
                and Is_Applicable_for_POC__c=true 
                and (Provisioning_Product_Family__c='Addon' OR Provisioning_Product_Family__c='Package') 
                and Product_Line__c =:prodLine];
    }
    @AuraEnabled(cacheable=true)
    public static List<Product2> getFeatureProductforTenant(String prodLine){
        System.debug('getFeatureProductforTenant-->'+prodLine);
       List<Product2> featureProdList= [Select id , Name , Product_Line__c, 
                isActive, ProductCode,SKU_Category__c,SKU_Type__c,Is_Provisioning_Feature__c,
                Provisioning_Broker_Eligible__c,Provisioning_Sub_Product_Line__c,Auto_Provisioning_Status__c 
                from Product2 
                where
                Is_Applicable_for_POC__c=true 
                and Provisioning_Product_Family__c='Addon' and
                Is_Provisioning_Feature__c =true 
                and Product_Line__c =:prodLine];
        System.debug('featureProdList------->'+featureProdList);
        return featureProdList;
    }



    @AuraEnabled(Cacheable=true)
    public static List<Provisioning_Group__c> getExistingPGFields(Id pgId){
        System.debug('inside getExistingPGFields '+ pgId);
        return [select Id, RecordTypeId,  Associated_ZIA_Zscaler_Cloud__c, Comments__c, 
                    End_Date__c, Opportunity__c, Organization_Domain__c, Preferred_Cloud__c, SE_Manager_Email__c,
                    Product_Line__c,  Provisioning_Request__c, Start_Date__c, Zscaler_Cloud_ID__c, 
                    Additional_Organization_domains__c, Send_Initial_Login_Credentials_To__c,Account__c,PG_Request_Type__c,
                    (select id,Contact__c, Email__c, Type__c, User__c,User_Name__c,User__r.phone,User__r.title from Provisioning_Contacts__r) 
                    from Provisioning_Group__c 
                    where Id = :pgId];
    }

    @AuraEnabled 
    
    public static List<Provisioning_Group__c> addFeatureProductstoPRG(string jsonStr){
        System.debug('Printing JSON'+jsonStr);
        List<Provisioning_Group__c> pgCreated = new List<Provisioning_Group__c>(); 
        List<Provisioning_Product__c> procProdListToUpdate = new List<Provisioning_Product__c>();
        List<Provisioning_Product__c> procCBIProdListToUpdate = new List<Provisioning_Product__c>();
        List<Provisioning_Product__c> procDeceptionProdListToUpdate = new List<Provisioning_Product__c>();
        List<Provisioning_Product__c> finalProvisioningProductList = new List<Provisioning_Product__c>();
        List<Provisioning_Contact__c> provContactListToUpdate = new List<Provisioning_Contact__c>();
        Map<String,Provisioning_Group__c> prodLineVsProvGroup = new Map<String,Provisioning_Group__c>();
        Boolean isZPA=false;
        ProvisioningDetailsWrapper provWrapper = (ProvisioningDetailsWrapper)JSON.deserialize(jsonStr,ProvisioningDetailsWrapper.class);
        Provisioning_Group__c newPG= new Provisioning_Group__c();
        System.debug(provWrapper);
        if(provWrapper!=null){
            
            if(provWrapper.domain!=null){
                newPG.Organization_Domain__c=provWrapper.domain;
            }
            if(provWrapper.additionalDomain!=null){
                newPG.Additional_Organization_domains__c=provWrapper.additionalDomain;
            }
            if(provWrapper.startDate!=null){
                newPG.Start_Date__c=Date.valueOf(provWrapper.startDate);
    
                //ZSCM end date should include start date value as well. So the ZSCM end date should be 365 days for leap year (or) 364 days for non leap year including start date
                if(Date.isLeapYear(newPG.Start_Date__c.year())){
                    newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(365);
                }else{
                    newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(364);
                }
            }
            if(provWrapper.endDate!=null){
                newPG.End_Date__c=Date.valueOf(provWrapper.endDate);
            }
            
            if(provWrapper.comments!=null){
                newPG.Comments__c=provWrapper.comments;
            }
            if(provWrapper.opportunityId!=null){
                newPG.Opportunity__c=provWrapper.opportunityId;
            }
            if(provWrapper.accountId!=null){
                newPG.Account__c=provWrapper.accountId;
            }

            if(provWrapper.recordTypeID!=null){
                newPG.RecordTypeId=provWrapper.recordTypeID;
            }
            if(provWrapper.associatedZIACloud!=null){
                newPG.Associated_ZIA_Zscaler_Cloud__c=provWrapper.associatedZIACloud;
            }
            if(provWrapper.preferredCloud!=null){
                newPG.Preferred_Cloud__c=provWrapper.preferredCloud;
            }
            if(provWrapper.productLine!=null){
                newPG.Product_Line__c=provWrapper.productLine;
            }
            if(provWrapper.provisioningRequest!=null){
                newPG.Provisioning_Request__c=provWrapper.provisioningRequest;
            }
            if(provWrapper.zscalerCloudId!=null){
                newPG.Zscaler_Cloud_ID__c=provWrapper.zscalerCloudId;
            }
            if(provWrapper.seManager!=null){
                newPG.SE_Manager_Email__c=provWrapper.seManager;
            }
            if(provWrapper.sendInitialCredsTo!=null){
                newPG.Send_Initial_Login_Credentials_To__c=provWrapper.sendInitialCredsTo;
            }
            
            newPG.Approval_Status__c='Approved';
            newPG.Provisioning_Process__c='Add Feature';
            newPG.Status__c='Requested';
            newPG.PG_Request_Type__c=provWrapper.pgRequestType;
            if(provWrapper.oldPGId!=null){
                newPG.Renewed_From_Provisioning_Group__c=provWrapper.oldPGId;
            }

            MAP<String, List<ProvisioningProducts>> productCatMAP = categrorizeProducts(provWrapper.provProdWrapper);
            System.debug('productCatMAP'+productCatMAP);

            for(ProvisioningProducts provProd :provWrapper.provProdWrapper ){
                if(provProd.isCBI == false && provProd.isDeception == false){
                    Provisioning_Product__c product = new Provisioning_Product__c();
                    product.Name=provProd.productName;
                    product.Status__c= 'Trial';
                    if(provProd.productSKUId!=null){
                        product.Product__c=provProd.productSKUId;
                    }
                    if(provProd.productAddonnID!=null){
                        product.Product__c=provProd.productAddonnID;
                    }
                    if(provWrapper.zscalerCloudId!=null){
                        product.Zscaler_Cloud_ID__c=provWrapper.zscalerCloudId;
                    }
                    if(provProd.quantity!=null && Decimal.valueOf(provProd.quantity)!=0){
                        product.Quantity__c = Decimal.valueOf(provProd.quantity);
                    }else{
                        product.Quantity__c = 100;
                    }
                    if(provProd.isBrokerEligible==false){
                        System.debug('provProd.isBrokerEligible'+provProd.isBrokerEligible);
                        newPG.Provisioning_Broker_Eligible__c=false;
                       newPG.Provisioning_Type__c='Auto';
                        //newPG.Manually_Processed__c=true;
                    }
                    if(provProd.prodline=='ZPA'){
                        newPG.Provisioning_Broker_Eligible__c=false;
                        newPG.Approval_Status__c='Approved';
                        newPG.Status__c='Provisioned';
                        isZPA=true;
                    }
                    if(provProd.productName.contains('NSS')){
                        newPG.Approval_Status__c='Not Submitted';
                        newPG.Status__c='Initiated';
                    }
                    if(provWrapper.startDate!=null){
                        product.Start_Date__c=Date.valueOf(provWrapper.startDate);
                    }
                    if(provWrapper.endDate!=null){
                        product.End_Date__c=Date.valueOf(provWrapper.endDate);
                    }
                    procProdListToUpdate.add(product);
                }
            }

            /***************************Insertion of New PG and archival of old PG ********************/
            if(newPG!=null){
                insert newPG;
                pgCreated.add(newPG);
                Provisioning_Group__c oldPG =[Select id, status__c from Provisioning_Group__c  where Id = : provWrapper.oldPGId]; 
                if(oldPG!=null){
                    oldPG.status__c='Pending Archival';
                    if(isZPA==true){
                        oldPG.status__c='Archived';
                        oldPG.End_Date__c = System.today();
                    }
                    update oldPG;
                }
            }
            
            String prodLine = newPG.Product_Line__c;
            prodLineVsProvGroup.put(prodLine, newPG);

            /************************CBI***************************************/
            for(String prLine : productCatMAP.keyset()){
				List<ProvisioningProducts> ppList = productCatMAP.get(prLine);
				
				Boolean checkIFCBIProductExist = checkifCBIProductExist(ppList);
                Boolean checkifDeceptionProductExist = checkifDeceptionProductExist(ppList);

				if(checkIFCBiProductExist){
					Provisioning_Group__c assciatedPG = prodLineVsProvGroup.get(prLine);
					Provisioning_Group__c cbiPG = prepareSpecialCasePGRecord(provWrapper, assciatedPG, 'CBI');
                    
					insert cbiPG;
                    if(cbiPG!=null){
                        pgCreated.add(cbiPG);
                    }
       				/*********************************Creating Provisioning Product for CBI********************************************/
					for(ProvisioningProducts provProd : ppList ){
                        System.debug('--provProd.isCBI---'+provProd.isCBI);
						if(provProd.isCBI != null && provProd.isCBI == true){
							Provisioning_Product__c product = new Provisioning_Product__c();
                            product.Status__c= 'Trial';
							product.Quantity__c = 100;
							if(provWrapper.startDate!=null){
                                product.Start_Date__c=Date.valueOf(provWrapper.startDate);
                            }
                            if(provWrapper.endDate!=null){
                                product.End_Date__c=Date.valueOf(provWrapper.endDate);
                            }
							product.Name = provProd.productName;
                            product.Provisioning_Group__c=cbiPG.Id;    
							if(provProd.productSKUId!=null){
								product.Product__c=provProd.productSKUId;
                            }
							if(provProd.productAddonnID!=null){
								product.Product__c=provProd.productAddonnID;
                            }
							procCBIProdListToUpdate.add(product);
						}
					}
                    
                    /*********************************Creating Provisioning Contact for CBI********************************************/
                    if(provWrapper.provContactWrapper!=null){
                        System.debug('--provContactWrapper---'+provWrapper.provContactWrapper);
                        for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                            Provisioning_Contact__c pcontact = new Provisioning_Contact__c();
                            pcontact.User__c = provCont.userId;
                            pcontact.Contact__c = provCont.contactId;
                            pcontact.type__c= provCont.contactType;
                            pcontact.Provisioning_Group__c=cbiPG.Id;
                            provContactListToUpdate.add(pcontact);
                        }
                    }
				}

                /****************************************Deception******************************************** */
                if(checkifDeceptionProductExist){
                    System.debug('--inside checkifDeceptionPductExist---');
                    Provisioning_Group__c assciatedPG = prodLineVsProvGroup.get(prLine);
                    Provisioning_Group__c deceptionPG = new Provisioning_Group__c();
                    List<Provisioning_Group__c> pgToInsert = new List<Provisioning_Group__c>(); 
                    deceptionPG = prepareSpecialCasePGRecord(provWrapper, assciatedPG,'Deception');

                    if(deceptionPG != null){
                        pgCreated.add(deceptionPG);
                        pgToInsert.add(deceptionPG);
                    }
                    
                    if(!pgToInsert.isEmpty() && pgToInsert!=null){
                        insert pgToInsert;
                    }
                    
                    /*********************************Creating Provisioning Product for Deception********************************************/
                    for(ProvisioningProducts provProd : ppList ){
                        if(provProd.isDeception != null &&  provProd.isDeception==true){
                            System.debug('--inside if provProd.isCBI---'+provProd.isCBI);
                            Provisioning_Product__c product = new Provisioning_Product__c();
                            product.Quantity__c = 100;
                            product.Status__c= 'Trial';
                            if(provWrapper.startDate!=null){
                                product.Start_Date__c=Date.valueOf(provWrapper.startDate);
                            }
                            if(provWrapper.endDate!=null){
                                product.End_Date__c=Date.valueOf(provWrapper.endDate);
                            }
                            product.Name = provProd.productName;
                            product.Provisioning_Group__c=deceptionPG.Id;
                            if(provProd.productSKUId!=null){
                                product.Product__c=provProd.productSKUId;
                            }
                            if(provProd.productAddonnID!=null){
                                product.Product__c=provProd.productAddonnID;
                            }
                            procDeceptionProdListToUpdate.add(product);
                        }
                    }

                    /*********************************Creating Provisioning Contact for Deception********************************************/
                    if(provWrapper.provContactWrapper!=null){
                        System.debug('--provContactWrapper---'+provWrapper.provContactWrapper);
                        for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                            Provisioning_Contact__c pcontact = new Provisioning_Contact__c();
                            pcontact.User__c = provCont.userId;
                            pcontact.Contact__c = provCont.contactId;
                            pcontact.type__c= provCont.contactType;
                            if(deceptionPG!=null){
                                pcontact.Provisioning_Group__c=deceptionPG.Id;
                            }
                            provContactListToUpdate.add(pcontact);
                        }
                    }
                }
			}

            for(Provisioning_Product__c pp:procProdListToUpdate){
                pp.Provisioning_Group__c=newPg.id;
                finalProvisioningProductList.add(pp);
            }
            
            if(!procCBIProdListToUpdate.isEmpty()){
                finalProvisioningProductList.addall(procCBIProdListToUpdate);
            }
            if(!procDeceptionProdListToUpdate.isEmpty()){
                finalProvisioningProductList.addall(procDeceptionProdListToUpdate);
            }


            for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                Provisioning_Contact__c contact = new Provisioning_Contact__c();
                contact.Type__c=provCont.contactType;
                if(provCont.contactId!=null)
                contact.Contact__c=provCont.contactId;
                if(provCont.userId!=null)
                contact.User__c=provCont.userId;
                contact.Provisioning_Group__c=newPG.Id;
                if(provWrapper.zscalerCloudId!=null){
                    contact.Zscaler_Cloud_ID__c=provWrapper.zscalerCloudId;
                }     
                provContactListToUpdate.add(contact);
            }
            if(!provContactListToUpdate.isEmpty()){
                System.debug(provContactListToUpdate);
                insert provContactListToUpdate;
            }
            if(!finalProvisioningProductList.isEmpty()){
                System.debug(finalProvisioningProductList);
                insert finalProvisioningProductList;
            }
        }
        System.debug('newPG'+newPG);
        List<Provisioning_Group__c> pgToreturn = new List<Provisioning_Group__c>([SELECT Id, Name, Product_Line__c, Provisioning_Type__c, Status__c, Approval_Status__c FROM Provisioning_Group__c WHERE Id IN :pgCreated]);

        return pgToreturn;
    }    

    @AuraEnabled
    public static List<Provisioning_Group__c> replaceProvisioningRecords(string jsonStr){
        System.debug('Printing JSON'+jsonStr);
        List<Provisioning_Group__c> pgCreated = new List<Provisioning_Group__c>(); 
        List<Provisioning_Product__c> procProdListToUpdate = new List<Provisioning_Product__c>();
        List<Provisioning_Product__c> procCBIProdListToUpdate = new List<Provisioning_Product__c>();
        List<Provisioning_Product__c> procDeceptionProdListToUpdate = new List<Provisioning_Product__c>();
        List<Provisioning_Product__c> finalProvisioningProductList = new List<Provisioning_Product__c>();
        List<Provisioning_Contact__c> provContactListToUpdate = new List<Provisioning_Contact__c>();
        Map<String,Provisioning_Group__c> prodLineVsProvGroup = new Map<String,Provisioning_Group__c>();
        Boolean isZPA=false;
        ProvisioningDetailsWrapper provWrapper = (ProvisioningDetailsWrapper)JSON.deserialize(jsonStr,ProvisioningDetailsWrapper.class);
        Provisioning_Group__c newPG= new Provisioning_Group__c();
        System.debug(provWrapper);
        if(provWrapper!=null){
            
            if(provWrapper.domain!=null){
                newPG.Organization_Domain__c=provWrapper.domain;
            }
            if(provWrapper.additionalDomain!=null){
                newPG.Additional_Organization_domains__c=provWrapper.additionalDomain;
            }
            if(provWrapper.startDate!=null){
                newPG.Start_Date__c=Date.valueOf(provWrapper.startDate);
    
                //ZSCM end date should include start date value as well. So the ZSCM end date should be 365 days for leap year (or) 364 days for non leap year including start date
                if(Date.isLeapYear(newPG.Start_Date__c.year())){
                    newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(365);
                }else{
                    newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(364);
                }
            }
            if(provWrapper.endDate!=null){
                newPG.End_Date__c=Date.valueOf(provWrapper.endDate);
            }
            
            if(provWrapper.comments!=null){
                newPG.Comments__c=provWrapper.comments;
            }
            if(provWrapper.opportunityId!=null){
                newPG.Opportunity__c=provWrapper.opportunityId;
            }
            if(provWrapper.accountId!=null){
                newPG.Account__c=provWrapper.accountId;
            }

            if(provWrapper.recordTypeID!=null){
                newPG.RecordTypeId=provWrapper.recordTypeID;
            }
            if(provWrapper.associatedZIACloud!=null){
                newPG.Associated_ZIA_Zscaler_Cloud__c=provWrapper.associatedZIACloud;
            }
            if(provWrapper.preferredCloud!=null){
                newPG.Preferred_Cloud__c=provWrapper.preferredCloud;
            }
            if(provWrapper.productLine!=null){
                newPG.Product_Line__c=provWrapper.productLine;
            }
            if(provWrapper.provisioningRequest!=null){
                newPG.Provisioning_Request__c=provWrapper.provisioningRequest;
            }
            if(provWrapper.zscalerCloudId!=null){
                newPG.Zscaler_Cloud_ID__c=provWrapper.zscalerCloudId;
            }
            if(provWrapper.seManager!=null){
                newPG.SE_Manager_Email__c=provWrapper.seManager;
            }
            if(provWrapper.sendInitialCredsTo!=null){
                newPG.Send_Initial_Login_Credentials_To__c=provWrapper.sendInitialCredsTo;
            }
            
            newPG.Approval_Status__c='Approved';
            newPG.Provisioning_Process__c='Add SKU';
            newPG.Status__c='Requested';
            newPG.PG_Request_Type__c=provWrapper.pgRequestType;
            if(provWrapper.oldPGId!=null){
                newPG.Renewed_From_Provisioning_Group__c=provWrapper.oldPGId;
            }

            MAP<String, List<ProvisioningProducts>> productCatMAP = categrorizeProducts(provWrapper.provProdWrapper);
            System.debug('productCatMAP'+productCatMAP);

            for(ProvisioningProducts provProd :provWrapper.provProdWrapper ){
                if(provProd.isCBI == false && provProd.isDeception == false){
                    Provisioning_Product__c product = new Provisioning_Product__c();
                    product.Name=provProd.productName;
                    product.Status__c= 'Trial';
                    if(provProd.productSKUId!=null){
                        product.Product__c=provProd.productSKUId;
                    }
                    if(provProd.productAddonnID!=null){
                        product.Product__c=provProd.productAddonnID;
                    }
                    if(provWrapper.zscalerCloudId!=null){
                        product.Zscaler_Cloud_ID__c=provWrapper.zscalerCloudId;
                    }
                    if(provProd.quantity!=null && Decimal.valueOf(provProd.quantity)!=0){
                        product.Quantity__c = Decimal.valueOf(provProd.quantity);
                    }else{
                        product.Quantity__c = 100;
                    }
                    if(provProd.isBrokerEligible==false){
                        System.debug('provProd.isBrokerEligible'+provProd.isBrokerEligible);
                        newPG.Provisioning_Broker_Eligible__c=false;
                        newPG.Provisioning_Type__c='Manual';
                        newPG.Manually_Processed__c=true;
                    }
                    if(provProd.prodline=='ZPA'){
                        newPG.Provisioning_Broker_Eligible__c=false;
                        newPG.Approval_Status__c='Approved';
                        newPG.Status__c='Provisioned';
                        isZPA=true;
                    }
                    if(provProd.productName.contains('NSS')){
                        newPG.Approval_Status__c='Not Submitted';
                        newPG.Status__c='Initiated';
                    }
                    if(provWrapper.startDate!=null){
                        product.Start_Date__c=Date.valueOf(provWrapper.startDate);
                    }
                    if(provWrapper.endDate!=null){
                        product.End_Date__c=Date.valueOf(provWrapper.endDate);
                    }
                    procProdListToUpdate.add(product);
                }
            }

            /***************************Insertion of New PG and archival of old PG ********************/
            if(newPG!=null){
                insert newPG;
                pgCreated.add(newPG);
                Provisioning_Group__c oldPG =[Select id, status__c from Provisioning_Group__c  where Id = : provWrapper.oldPGId]; 
                if(oldPG!=null){
                    oldPG.status__c='Pending Archival';
                    if(isZPA==true){
                        oldPG.status__c='Archived';
                        oldPG.End_Date__c = System.today();
                    }
                    update oldPG;
                }
            }
            
            String prodLine = newPG.Product_Line__c;
            prodLineVsProvGroup.put(prodLine, newPG);

            /************************CBI***************************************/
            for(String prLine : productCatMAP.keyset()){
				List<ProvisioningProducts> ppList = productCatMAP.get(prLine);
				
				Boolean checkIFCBIProductExist = checkifCBIProductExist(ppList);
                Boolean checkifDeceptionProductExist = checkifDeceptionProductExist(ppList);

				if(checkIFCBiProductExist){
					Provisioning_Group__c assciatedPG = prodLineVsProvGroup.get(prLine);
					Provisioning_Group__c cbiPG = prepareSpecialCasePGRecord(provWrapper, assciatedPG, 'CBI');
                    
					insert cbiPG;
                    if(cbiPG!=null){
                        pgCreated.add(cbiPG);
                    }
       				/*********************************Creating Provisioning Product for CBI********************************************/
					for(ProvisioningProducts provProd : ppList ){
                        System.debug('--provProd.isCBI---'+provProd.isCBI);
						if(provProd.isCBI != null && provProd.isCBI == true){
							Provisioning_Product__c product = new Provisioning_Product__c();
                            product.Status__c= 'Trial';
							product.Quantity__c = 100;
							if(provWrapper.startDate!=null){
                                product.Start_Date__c=Date.valueOf(provWrapper.startDate);
                            }
                            if(provWrapper.endDate!=null){
                                product.End_Date__c=Date.valueOf(provWrapper.endDate);
                            }
							product.Name = provProd.productName;
                            product.Provisioning_Group__c=cbiPG.Id;    
							if(provProd.productSKUId!=null){
								product.Product__c=provProd.productSKUId;
                            }
							if(provProd.productAddonnID!=null){
								product.Product__c=provProd.productAddonnID;
                            }
							procCBIProdListToUpdate.add(product);
						}
					}
                    
                    /*********************************Creating Provisioning Contact for CBI********************************************/
                    if(provWrapper.provContactWrapper!=null){
                        System.debug('--provContactWrapper---'+provWrapper.provContactWrapper);
                        for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                            Provisioning_Contact__c pcontact = new Provisioning_Contact__c();
                            pcontact.User__c = provCont.userId;
                            pcontact.Contact__c = provCont.contactId;
                            pcontact.type__c= provCont.contactType;
                            pcontact.Provisioning_Group__c=cbiPG.Id;
                            provContactListToUpdate.add(pcontact);
                        }
                    }
				}

                /****************************************Deception******************************************** */
                if(checkifDeceptionProductExist){
                    System.debug('--inside checkifDeceptionPductExist---');
                    Provisioning_Group__c assciatedPG = prodLineVsProvGroup.get(prLine);
                    Provisioning_Group__c deceptionPG = new Provisioning_Group__c();
                    List<Provisioning_Group__c> pgToInsert = new List<Provisioning_Group__c>(); 
                    deceptionPG = prepareSpecialCasePGRecord(provWrapper, assciatedPG,'Deception');

                    if(deceptionPG != null){
                        pgCreated.add(deceptionPG);
                        pgToInsert.add(deceptionPG);
                    }
                    
                    if(!pgToInsert.isEmpty() && pgToInsert!=null){
                        insert pgToInsert;
                    }
                    
                    /*********************************Creating Provisioning Product for Deception********************************************/
                    for(ProvisioningProducts provProd : ppList ){
                        if(provProd.isDeception != null &&  provProd.isDeception==true){
                            System.debug('--inside if provProd.isCBI---'+provProd.isCBI);
                            Provisioning_Product__c product = new Provisioning_Product__c();
                            product.Quantity__c = 100;
                            product.Status__c= 'Trial';
                            if(provWrapper.startDate!=null){
                                product.Start_Date__c=Date.valueOf(provWrapper.startDate);
                            }
                            if(provWrapper.endDate!=null){
                                product.End_Date__c=Date.valueOf(provWrapper.endDate);
                            }
                            product.Name = provProd.productName;
                            product.Provisioning_Group__c=deceptionPG.Id;
                            if(provProd.productSKUId!=null){
                                product.Product__c=provProd.productSKUId;
                            }
                            if(provProd.productAddonnID!=null){
                                product.Product__c=provProd.productAddonnID;
                            }
                            procDeceptionProdListToUpdate.add(product);
                        }
                    }

                    /*********************************Creating Provisioning Contact for Deception********************************************/
                    if(provWrapper.provContactWrapper!=null){
                        System.debug('--provContactWrapper---'+provWrapper.provContactWrapper);
                        for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                            Provisioning_Contact__c pcontact = new Provisioning_Contact__c();
                            pcontact.User__c = provCont.userId;
                            pcontact.Contact__c = provCont.contactId;
                            pcontact.type__c= provCont.contactType;
                            if(deceptionPG!=null){
                                pcontact.Provisioning_Group__c=deceptionPG.Id;
                            }
                            provContactListToUpdate.add(pcontact);
                        }
                    }
                }
			}

            for(Provisioning_Product__c pp:procProdListToUpdate){
                pp.Provisioning_Group__c=newPg.id;
                finalProvisioningProductList.add(pp);
            }
            
            if(!procCBIProdListToUpdate.isEmpty()){
                finalProvisioningProductList.addall(procCBIProdListToUpdate);
            }
            if(!procDeceptionProdListToUpdate.isEmpty()){
                finalProvisioningProductList.addall(procDeceptionProdListToUpdate);
            }


            for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                Provisioning_Contact__c contact = new Provisioning_Contact__c();
                contact.Type__c=provCont.contactType;
                if(provCont.contactId!=null)
                contact.Contact__c=provCont.contactId;
                if(provCont.userId!=null)
                contact.User__c=provCont.userId;
                contact.Provisioning_Group__c=newPG.Id;
                if(provWrapper.zscalerCloudId!=null){
                    contact.Zscaler_Cloud_ID__c=provWrapper.zscalerCloudId;
                }     
                provContactListToUpdate.add(contact);
            }
            if(!provContactListToUpdate.isEmpty()){
                System.debug(provContactListToUpdate);
                insert provContactListToUpdate;
            }
            if(!finalProvisioningProductList.isEmpty()){
                System.debug(finalProvisioningProductList);
                insert finalProvisioningProductList;
            }
        }
        System.debug('newPG'+newPG);
        List<Provisioning_Group__c> pgToreturn = new List<Provisioning_Group__c>([SELECT Id, Name, Product_Line__c, Provisioning_Type__c, Status__c, Approval_Status__c FROM Provisioning_Group__c WHERE Id IN :pgCreated]);

        return pgToreturn;
    }

    //ZIA--> List<ProvisioningProducts>, ZPA->List<ProvisioningProducts> ...
    public static MAP<String, List<ProvisioningProducts>> categrorizeProducts(List<ProvisioningProducts> provProds){
        System.debug('inside categrorizeProducts---->'+provProds);
        MAP<String, List<ProvisioningProducts>> returnMAP = new MAP<String, List<ProvisioningProducts>>();
        for(ProvisioningProducts provProd : provProds){
            List<ProvisioningProducts>  ppList = returnMAP.containsKey(provProd.prodline) 
                                                    ? returnMAP.get(provProd.prodline)
                                                    : new List<ProvisioningProducts>();
            ppList.add(provProd);
            returnMAP.put(provProd.prodline, ppList);
        }
        return returnMAP;
    }

    public static Boolean checkifCBIProductExist(List<ProvisioningProducts> provProds){
        Boolean ifCBiExist = false;
        if(provProds!=null){
            for(ProvisioningProducts provProd : provProds ){
                if(provProd.isCBI != null && provProd.isCBI == true){
                    ifCBiExist = true;
                    break;
                }				
            }
        }
        return ifCBiExist;
    }

    public static Provisioning_Group__c prepareSpecialCasePGRecord(ProvisioningDetailsWrapper provWrapper, Provisioning_Group__c assciatedPG , String prodlineforPG){
        System.debug('inside preparePGCBIRecord '+assciatedPG+' '+provWrapper);
        Provisioning_Group__c newPG = new Provisioning_Group__c();
        newPG.recordtypeId = PGRecordTypeId;
        newPG.Provisioning_Type__c = 'Manual';
        newPG.status__c='Provisioning In Progress';
        newPG.PG_Request_Type__c = 'Create';
        newPG.Approval_Status__c = 'Approved';
        newPG.Provisioning_Process__c = 'Add SKU';
        if(assciatedPG!=null)
        newPG.Associated_Provisioning_Group__c = assciatedPG.Id;
        newPG.Opportunity__c = provWrapper.opportunityId;
        newPG.Account__c = provWrapper.accountId;
        newPG.Product_Line__c = prodlineforPG;
        newPG.Organization_Domain__c=provWrapper.domain;
        if(provWrapper.zscalerCloudId!=null){
            newPG.Associated_ZIA_Zscaler_Cloud__c=provWrapper.zscalerCloudId;
        }
        newPG.Send_Initial_Login_Credentials_To__c =provWrapper.sendInitialCredsTo;
        
        if(provWrapper.additionalDomain!=null){
            newPG.Additional_Organization_domains__c=provWrapper.additionalDomain;
        }

        if(provWrapper.comments!=null){
            newPG.Comments__c=provWrapper.comments;
        }
        
        if(provWrapper.preferredCloud!=null){
            newPG.Preferred_Cloud__c=provWrapper.preferredCloud;
        }
        
        if(provWrapper.associatedZIACloud!=null && provWrapper.associatedZIACloud!='Request New ZIA Tenant'){
            newPG.Associated_ZIA_Zscaler_Cloud__c = provWrapper.associatedZIACloud;
        }
        
        if(provWrapper.startDate!=null){
            newPG.Start_Date__c=Date.valueOf(provWrapper.startDate);
        }else{
            newPG.Start_Date__c=System.today();
        }

        if(provWrapper.endDate!=null){
            newPG.End_Date__c=Date.valueOf(provWrapper.endDate);
        }

        //ZSCM end date should include start date value as well. So the ZSCM end date should be 365 days for leap year (or) 364 days for non leap year including start date
        if(Date.isLeapYear(newPG.Start_Date__c.year())){
            newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(365);
        }else{
            newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(364);
        }
         
        System.debug('newPG@@@2 '+newPG);
        return newPG;
    }

    public static Boolean checkifDeceptionProductExist(List<ProvisioningProducts> provProds){
        Boolean ifDeceptionExist = false;
        if(provProds!=null){
            for(ProvisioningProducts provProd : provProds ){
                if(provProd.isDeception != null && provProd.isDeception == true){
                    ifDeceptionExist = true;
                    break;
                }               
            }
        }
        return ifDeceptionExist;
    }
    
    public class ProvisioningDetailsWrapper{
        @AuraEnabled
        public String domain;
        @AuraEnabled
        public String additionalDomain;
        @AuraEnabled
        public String comments;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String opportunityId;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String endDate;
        
        @AuraEnabled
        public String recordTypeID;
        @AuraEnabled
        public String associatedZIACloud;
        @AuraEnabled
        public String preferredCloud;
        @AuraEnabled
        public String productLine;
        @AuraEnabled
        public String provisioningRequest;
        @AuraEnabled
        public String zscalerCloudId;
        @AuraEnabled
        public String sendInitialCredsTo;
        @AuraEnabled
        public String oldPGId;
        @AuraEnabled
        public String seManager;
        @AuraEnabled
        public String pgRequestType;

        List<ProvisioningProducts> provProdWrapper;
        List<ProvisioningContacts> provContactWrapper;
    }

    public class ProvisioningProducts{
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String productCode;
        @AuraEnabled
        public String prodline;
        @AuraEnabled
        public String productAddonnID;
        @AuraEnabled
        public String productSKUId;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String quantity;
        @AuraEnabled
        public String zscalerCloudId;
        @AuraEnabled
        public Boolean isBrokerEligible;
        @AuraEnabled
        public Boolean isCBI;
        @AuraEnabled
        public Boolean isDeception;
    }
    
    public class ProvisioningContacts {
        @AuraEnabled
        public String contactType;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String altPhone;
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String userId;
    }
}