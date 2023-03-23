import { LightningElement, wire,track,api } from 'lwc';
import getExistingSKUsOfPG from '@salesforce/apex/AddSkuForProvisioningController.getExistingSKUsOfPG';
import getALLPlatformSKUforTable from '@salesforce/apex/ChangeSkuForProvisioningController.getALLPlatformSKUforTable';
import getPOVProductList from '@salesforce/apex/ChangeSkuForProvisioningController.getPOVProductList';
import getExistingSKU from '@salesforce/apex/ChangeSkuForProvisioningController.getExistingSKU';
import getExistingPGFields from '@salesforce/apex/ChangeSkuForProvisioningController.getExistingPGFields';
import replaceProvisioningRecords from '@salesforce/apex/ChangeSkuForProvisioningController.replaceProvisioningRecords';
import { NavigationMixin } from 'lightning/navigation';
import getRequiredContacts from '@salesforce/apex/ProvisioningGroupController.getRequiredContacts';
import searchAndCreateContactRecord from '@salesforce/apex/ProvisioningGroupController.searchAndCreateContactRecord';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SE_NAME from '@salesforce/schema/Opportunity.SE_Name__c';

const DELAY = 300;

const columns = [
    { label: 'Product', fieldName: 'Name'},
    { label: 'Product Line', fieldName: 'Product_Line__c'},
    { label: 'SKU', fieldName: 'ProductCode'},
];

const addOnColumns = [
    { label: 'Product', fieldName: 'Name'},
    { label: 'Product Line', fieldName: 'Product_Line__c'},
    { label: 'SKU', fieldName: 'ProductCode'},
    { label: 'Auto Provisioning Status', fieldName: 'Auto_Provisioning_Status__c'},
];

const createdPGColumns = [
    { label: 'Provisioning Group Name', fieldName: 'pgUrl', type:'url',
        typeAttributes: {
            label: { 
                fieldName: 'Name' 
            },
            target : '_blank'
        }
    },
    { label: 'Product Line', fieldName: 'Product_Line__c'},
    { label: 'Provisioning Type', fieldName: 'Provisioning_Type__c'},
    { label: 'Status', fieldName: 'Status__c'},
    { label: 'Approval Status', fieldName: 'Approval_Status__c'}
];


export default class ChangeSKUForProvisioning extends NavigationMixin(LightningElement)  {
    @track selectedSKUProductLine =[];
    @api recordId;
    @track productColumns = columns;
    @track addOnProductColumns = addOnColumns;
    @track prodList =[];
    @track selectedPlatformSkus =[];
    @track selectedAddOns =[];
    @api finalAddOnList =[];
    @api platformListCopy =[];
    @track filteredPovProdList=[];
    @track existingPlatformSKUs = [];
    @track currentStep = "1";
    @track finalProvisioningWrapper = {};
    @track credList = [];
    @track defaultcontact=[];
    @track contactscreenError=false;
    @track contactlistnotselected=[];
    @track provisioningGroup = [];
    @track createdProvisioningGroup = createdPGColumns;

    isDisabled=true;
    domain;
    additionalDomain;
    comments;
    startdate;
    @api opportunityId;
    accountId;
    endDate;      
    pgRecordTypeID;
    associatedZIACloud;
    preferredCloud; 
    provisioningRequest;
    zscalerCloudId;
    sendInitialCredsTo;
    seManager;
    pgRequestType;
    productLine;
    showAssociateSEButton=true;

    //initial Index 
    index = 0;

    //lookUp componnet
    fields = ["Name","Email","Phone"];
    displayFields = 'Name, Email, Phone';
    @track selectedProductCode = [];

    @track custOptionAvilable = [
        {label: 'Select', value: null },
        {label:'Sales Engineer' , value:'SALES_ENGINEER'},
        {label:'BUSINESS (PRIMARY)' , value :'BUSINESS_PRIMARY'},
        {label:'BILLING (PRIMARY)' , value:'BILLING_PRIMARY'},
        {label:'TECHNICAL (PRIMARY)' , value:'TECHNICAL_PRIMARY'},
        {label:'BUSINESS (SECONDARY)' , value:'BUSINESS_SECONDARY'},
        {label: 'BILLING (SECONDARY)' ,value:'BILLING_SECONDARY'},
        {label: 'TECHNICAL (SECONDARY)' , value:'TECHNICAL_SECONDARY'},
        {label: 'ZDX CONTACT' , value:'ZDX_CONTACT'},
        {label:'EC CONTACT'  , value: 'EC_CONTACT'},
        {label:'CSPM CONTACT' , value: 'CSPM_CONTACT'}
    ];

    @track platformProducts;

    connectedCallback(){
        console.log('In connected call back function....');
        getALLPlatformSKUforTable({pgId: this.recordId})
        .then((result) => {
            if(result){
                this.platformProducts=result;
            }
        }).catch((error) => {
            this.error = error;
            // This way you are not to going to see [object Object]
            console.log('fetch error getALLPlatformSKUforTable ',error);
        });;

        getExistingSKU({pgId: this.recordId})
            .then((result) => {
                for(var i=0;i<result.length;i++){
                    if(result[i].Product__r.Provisioning_Product_Family__c=='Bundles'){
                        this.selectedPlatformSkus.push({Id : result[i].Product__c});
                        this.existingPlatformSKUs.push(result[i].Product__c);
                        this.platformListCopy.push({
                            Name: result[i].Product_Name__c,
                            ProductCode: result[i].SKU__c,
                            Product_Line__c: result[i].Product_Line__c,
                            Id:result[i].Product__c,
                            Quantity__c:result[i].Quantity__c,
                            Provisioning_Broker_Eligible__c:result[i].Provisioning_Broker_Eligible__c,
                            Provisioning_Sub_Product_Line__c:result[i].Provisioning_Sub_Product_Line__c,
                        })
                    }
                    else{
                        this.selectedAddOns.push(result[i].Product__c);
                    }
                    
                    this.finalAddOnList.push({
                        Name: result[i].Product_Name__c,
                        ProductCode: result[i].SKU__c,
                        Product_Line__c: result[i].Product_Line__c,
                        Id:result[i].Product__c,
                        Quantity__c:result[i].Quantity__c,
                        Provisioning_Broker_Eligible__c:result[i].Provisioning_Broker_Eligible__c,
                        Provisioning_Sub_Product_Line__c:result[i].Provisioning_Sub_Product_Line__c,
                    })
                }
            })
            .catch((error) => {
                console.log('In connected call back error....');
                this.error = error;
                // This way you are not to going to see [object Object]
                console.log('fetch error connected call back error ',error);
            });
    }

    renderedCallback(){
        if(this.selectedPlatformSkus && this.template.querySelector('[data-id="datarow"]')!=null){ 
            let productList = [];
            this.selectedPlatformSkus.forEach(currentItem => {
                productList.push(currentItem.Id);
            });
            this.template.querySelector('[data-id="datarow"]').selectedRows = productList;
        }
        if(this.selectedAddOns && this.template.querySelector('[data-id="addonProductData"]')!=null){
            this.template.querySelector('[data-id="addonProductData"]').selectedRows = this.selectedAddOns;
        }  
    }

    @wire(getRecord, { recordId: '$opportunityId', fields: [SE_NAME] })
    oppt;

    //getter Methods
    get showFirstStep() {
        return this.currentStep && this.currentStep === "1" ? true : false;
    }
    get showSecondStep() {
        return this.currentStep && this.currentStep === "2" ? true : false;
    }
    get showThirdStep() {
        return this.currentStep && this.currentStep === "3" ? true : false;
    }

    
    @wire(getExistingPGFields ,{pgId:'$recordId'})exisitingPGfields({data, error}){
        if(data){
            this.domain = data[0].Organization_Domain__c;
            this.additionalDomain = data[0].Additional_Organization_domains__c;
            this.comments = data[0].Comments__c;
            this.startdate = data[0].Start_Date__c;
            this.accountId = data[0].Account__c;
            this.endDate = data[0].End_Date__c;
            this.pgRecordTypeID = data[0].RecordTypeId;
            this.associatedZIACloud = data[0].Associated_ZIA_Zscaler_Cloud__c;
            this.preferredCloud = data[0].Preferred_Cloud__c;
            this.productLine = data[0].Product_Line__c;
            this.seManager = data[0].SE_Manager_Email__c;
            this.provisioningRequest = data[0].Provisioning_Request__c;
            this.zscalerCloudId = data[0].Zscaler_Cloud_ID__c;
            this.sendInitialCredsTo = data[0].Send_Initial_Login_Credentials_To__c;
            this.provContacts = data[0].Provisioning_Contacts__r;
            this.pgRequestType =data[0].PG_Request_Type__c;
        }
        if(error){
            console.log('fetch error '+ error);
        }
    }
    
    handlePlatformSelection(event){
        this.isDisabled=false;
        console.log('this event detail'+event.detail);
        console.log('this event detail'+JSON.stringify(event.detail));
        this.finalAddOnList=event.detail.selectedRows;
        this.platformListCopy=event.detail.selectedRows;
        this.selectedPlatformSkus=event.detail.selectedRows;
        console.log('this.selectedPlatformSkus handlePlatformSelection',this.selectedPlatformSkus);
        this.selectedAddOns=[];
    }

    handleSelectedPOCProducts(event){
		this.finalAddOnList=[...this.platformListCopy];
		
        // List of selected items from the data table event.
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selectedAddOns);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();

        this.filteredPovProdList.map((ele) => {
            console.log('--filteredPovProdList ele--',ele);
            loadedItemsSet.add(ele.Id);
        });
        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                console.log('--selectedRows ele--',ele);
                updatedItemsSet.add(ele.Id);
            });
            // Add any new items to the selection list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });        
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });
        this.selectedAddOns = [...selectedItemsSet];
        console.log('---selectedAddOns---'+JSON.stringify(this.selectedAddOns));
        this.addtoFinalAddonList();
	}
	
	addtoFinalAddonList(){
        if(this.selectedAddOns){
            this.finalAddOnList = [...this.platformListCopy];
            this.selectedAddOns.forEach((prID) => {
                this.prodList.map((ele) => {
                    console.log('--filteredPovProdList ele--',ele);
                    if(ele.Id == prID ){
                        this.finalAddOnList.push(ele);
                    }
                });
            });
        }
        console.log('this.finalAddOnList---'+JSON.stringify(this.finalAddOnList));
    }

    removeItemFromSelectedList(event){
        const rows = this.template.querySelector('lightning-datatable').getSelectedRows().filter(ele => ele.Id !== event.target.value).map(ele => ele.Id);
        this.selectedAddOns = rows;
        const selectedrows = this.finalAddOnList.filter(ele => ele.Id !== event.target.value);
        this.finalAddOnList = selectedrows;
    }
    removeAllItemsFromSelectedList(event){
        this.selectedAddOns=[];
        this.finalAddOnList=[];
        this.selectedPlatformSkus=[];
    }

    @wire(getPOVProductList,{prodLine: '$productLine'})
        processPOVProductList({error,data}){
        if(data){
            if(data.length>0){
                this.prodList = data;
                this.filteredPovProdList =data;
            }
        }
        if(error){
            console.log('fetch error '+ error);
        }
    }

    handleCancelNavigate() {
        var compDefinition = {
                componentDef: "c:manageProvisioning",
                attributes: {
                    recordId: this.opportunityId,
                }
            };
            // Base64 encode the compDefinition JS object
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/one/one.app#' + encodedCompDef
                }
            });
    }

    removeDuplicates(originalArray, prop) {
        var newArray = [];
        var lookupObject  = {};
        for(var i in originalArray) {
            lookupObject[originalArray[i][prop]] = originalArray[i];
        }

        for(i in lookupObject) {
            newArray.push(lookupObject[i]);
        }
        return newArray;
    }

    handleKeyChange(event) {
        const sKey = event.target.value;
        this.searchKey = sKey;
        if(sKey){
            this.delayTimeout = setTimeout(() => {
               this.filteredPovProdList = this.prodList.filter(rec => JSON.stringify(rec).toLowerCase().includes(this.searchKey.toLowerCase()));
            }, DELAY);
        }else{
            this.filteredPovProdList = this.prodList;
        }
    }

    handleContactScreen(){
        var throwError=false;
        if(this.finalAddOnList){
            this.finalAddOnList.forEach(ele => {
                if(this.existingPlatformSKUs.includes(ele.Id)){
                    throwError=true
                    return;
                }
            })
            if(throwError==true){
                this.showToastMessage('error',('Platform SKU should be changed to proceed ahead'));
                    this.error=true;
                    return;
            }
        }
        
        let provisioningWrapper ={};
        provisioningWrapper.domain=this.domain;
        provisioningWrapper.additionalDomain=this.additionalDomain;
        provisioningWrapper.comments=this.comments;
        provisioningWrapper.startDate=this.startdate;
        provisioningWrapper.opportunityId=this.opportunityId;
        provisioningWrapper.accountId=this.accountId;
        provisioningWrapper.recordTypeID =this.pgRecordTypeID;
        provisioningWrapper.associatedZIACloud=this.associatedZIACloud;
        provisioningWrapper.preferredCloud=this.preferredCloud;
        provisioningWrapper.productLine=this.productLine;
        provisioningWrapper.seManager=this.seManager;
        provisioningWrapper.provisioningRequest=this.provisioningRequest;  
        provisioningWrapper.zscalerCloudId=this.zscalerCloudId;      
        provisioningWrapper.sendInitialCredsTo =this.sendInitialCredsTo; 
        provisioningWrapper.endDate=this.endDate;
        provisioningWrapper.provProdWrapper = [];
        provisioningWrapper.provContactWrapper = [];
        provisioningWrapper.oldPGId = this.recordId;
        provisioningWrapper.pgRequestType = 'Replace';
        
        if(this.finalAddOnList){
            this.finalAddOnList.forEach(ele => {
                let provisioningAddOnProductWrapper={};
                provisioningAddOnProductWrapper.productName=ele.Name;
                provisioningAddOnProductWrapper.productCode=ele.ProductCode;
                provisioningAddOnProductWrapper.prodline=ele.Product_Line__c;
                provisioningAddOnProductWrapper.productAddonnID=ele.Id;
                provisioningAddOnProductWrapper.isBrokerEligible=ele.Provisioning_Broker_Eligible__c;
                provisioningAddOnProductWrapper.zscalerCloudId=this.zscalerCloudId;
                provisioningAddOnProductWrapper.endDate=this.endDate;
                if(!this.selectedProductCode.includes(ele.ProductCode)){
                    this.selectedProductCode.push(ele.ProductCode);
                }
                provisioningAddOnProductWrapper.isCBI = this.checkIFProductISCBI(ele.Provisioning_Sub_Product_Line__c); 
                provisioningAddOnProductWrapper.isDeception = this.checkIFProductIsDeception(ele.Provisioning_Sub_Product_Line__c); 
                provisioningWrapper['provProdWrapper'].push(provisioningAddOnProductWrapper);
            })
        } 
        
        this.finalProvisioningWrapper = provisioningWrapper;
        //let dataToSend = JSON.stringify(provisioningWrapper);

        //console.log('finalProvisioningWrapper'+this.finalProvisioningWrapper);

        this.assignedTo = 'SALES_ENGINEER';
        console.log('selectedProductCode for contact selection'+this.selectedProductCode);
        if(this.initContactsOnce){
            console.log('boolean'+this.initContactsOnce);
            this.initContactsOnce = false;
            if(this.credList.length==0)
                this.sendProductDetails(this.selectedProductCode);
        }
        this.currentStep="2";
    }

    get pocProductDatatableHeight(){
        return this.productColumns && this.productColumns.length > 4 ? "height:250px;" : "height:200px;"
    }

    checkIFProductISCBI(provisioningSubPrdLine){
        return provisioningSubPrdLine && provisioningSubPrdLine == 'CBI' ? true : false;
    }

    checkIFProductIsDeception(provisioningSubPrdLine){
        return provisioningSubPrdLine &&  provisioningSubPrdLine == 'Deception' ? true : false;
    }

    initContactsOnce = true;

    sendProductDetails(selectedProducts){
        console.log('inside selected product line*****'+selectedProducts);
        getRequiredContacts({selectedProduct:selectedProducts})
            .then(result=>{
                console.log('selected products------->'+result);

                var sepresent = false;
                this.loading = false;
                console.log('credlist------>'+this.credList);
                console.log('this.defaultcontact before------>'+this.defaultcontact);
                this.defaultcontact = result;
                console.log('this.defaultcontact after------>'+this.defaultcontact);
                this.defaultcontact.forEach(item=>{
                    console.log('inside for item'+item);
                    if(item == 'SALES_ENGINEER'){
                        sepresent = true;
                        this.showAssociateSEButton=true;
                    }
                    console.log('inside for item2'+item);
                    this.credList.push({
                        Label:this.getCustomOptionLabel(item),
                        Type:item,
                        Index:this.index,
                        RecID:item == 'SALES_ENGINEER' ? this.seUserId : '',
                        IsUser:true,
                        unfinished:false,
                        typeOptionList:this.custtypeoptions,
                        showCopyContact:item == 'SALES_ENGINEER' ? true : false,
                        showSeleectContact:true,
                        
                    })
                    console.log('inside for item111');
                    this.index++;
                    console.log('inside for item112');
                    if(item == 'SALES_ENGINEER'){
                        this.showAssociateSEButton=true;
                    }
                    console.log('SE---->'+this.seUserId);
                    console.log('type-->'+item);
                })
                if(!sepresent){
                    this.credList.push({
                        Label:this.getCustomOptionLabel('SALES_ENGINEER'),
                        Type:'SALES_ENGINEER',
                        Index:this.index,
                        RecID:this.seUserId,
                        IsUser:true,
                        unfinished:false,
                        typeOptionList:this.custtypeoptions,
                        showCopyContact:true,
                        record: this.serecord,
                        showSeleectContact:true
                    })
                    console.log('SE2---->'+this.seUserId);
                    //console.log('type2-->'+item);
                    this.index++;
                    this.showAssociateSEButton=true;
                    console.log('index---->'+this.index);
                    console.log(' '+this.showAssociateSEButton);
                }
            })
            .catch(error=>{
                console.log('Error Occured sendProductDetails',error);
                this.error = error;
            });
    }

    @track iscopyinProgress=false;
    searchAndCreateContact(){
        this.iscopyinProgress=true;
        searchAndCreateContactRecord({seUserId:this.seUserId,accId:this.accountId})
            .then(result=>{
                var credlist2 = [];
                console.log('contactid--->'+result);
                this.credList.forEach(item=>{
                    item.RecID = item.Type == 'SALES_ENGINEER'?this.seUserId:result.Id;
                    var name = result.FirstName + ' ' + result.LastName;
                    var rec = {...result};
                    rec.Name = name;
                    item.record = rec;
                    item.unfinished = false;
                    credlist2.push(item);
                })
                this.credList = credlist2;
                var searchComp = this.template.querySelectorAll('c-generic-search-component');
                for(var i = 0; i<searchComp.length; i++){
                    if(searchComp[i].objName == 'contact'){
                        searchComp[i].triggerChange(result.Id);
                    }
                }
                this.iscopyinProgress=false;
            })
            .catch(error=>{
                console.log('Error Occured'+this.error);
                this.error = error;
            });
    }

    @track showWarning;
    validateShowSubmitForProvisioningButton(){
        console.log('---validateShowSubmitForProvisioningButton called--');
        this.showWarning = false;
        let showcontactmissingerror = false;
        //const pgprocoms = this.template.querySelectorAll('c-p-g-product-selection-component');
        //console.log('---validateShowSubmitForProvisioningButton--pgprocoms--', pgprocoms);
        

        this.credList.forEach(cred => {
            if( cred.Type===undefined || cred.Type == null || cred.Type==''){
                this.showToastMessage('error', ('Please Select Contact Type'));
                showcontactmissingerror=true;
                //return;
            }
            if(cred.record ===undefined|| cred.record  == null || cred.record ==''){
                this.showToastMessage('error', ('Please Select Contact'));
                showcontactmissingerror=true;
                //return;
            }
            if(showcontactmissingerror){
                return;
            }
        });

        
        if(this.assignedTo === undefined || this.assignedTo == null || this.assignedTo == '' ){
            this.showToastMessage('error', ('Please Select Credentials Assigned To'));
            return;
        }
        
        var stopexec = this.checkContactSelection();
        if(stopexec){
            return;
        }
       
        if(!showcontactmissingerror){
            this.handleSaveRecord();
        }
    }

    @track isSaveinProcess = false;
    async handleSaveRecord() {
        console.log('**** inside handleSaveRecord() ***');
        //Set Spinner
        this.isSaveinProcess = true;
        for(var i = 0; i < this.credentialList.length; i++) {
            let provisioningContacts = {};
            if(this.credentialList[i].IsUser){
                 provisioningContacts.userId = this.credentialList[i].RecID;
            }else{
                 provisioningContacts.contactId = this.credentialList[i].RecID;
            }
            provisioningContacts.contactType = this.credentialList[i].Type;
            provisioningContacts.email = this.credentialList[i].record?.Email;
            console.log('provisioningContacts.contactType---> ', provisioningContacts.contactType);
            this.finalProvisioningWrapper.provContactWrapper.push(provisioningContacts);
        }
        
        let dataToSend = JSON.stringify(this.finalProvisioningWrapper);
        console.log('dataToSend json val is---> ', dataToSend);

        await replaceProvisioningRecords({
            jsonStr: dataToSend
        }).then(result => {
            //this.handleCancelNavigate();
            //this.loading = false;
            this.provisioningGroup = result;
            let baseUrl = 'https://' + location.host + '/';
            result.forEach(pgRec => {
                pgRec.pgUrl = baseUrl + pgRec.Id;
                console.log('pgRec.pgUrl---> ', pgRec.pgUrl);
            });
            this.currentStep = "3";
            this.loading = false;
        }).catch(error => {
            this.error = error;
            this.loading = false;
        });

        
    }

    checkContactSelection(){
        let addedcontType = [];
        let tempContactlistnotselected = [];
        let iscontactRecordAdded = true;
        
        console.log('checklist-->'+this.defaultcontact);
        console.log('added contacts'+ this.credentialList);
        
        for(var i = 0; i < this.credentialList.length; i++) {
            console.log('this.credentialList[i].RecID'+this.credentialList[i].RecID);
            if(this.credentialList[i].RecID==''||this.credentialList[i].RecID===undefined){
                console.log('cred record---->'+this.credentialList[i].RecID);
                iscontactRecordAdded=false;
            }
            addedcontType.push(this.credentialList[i].Type)
        }
        console.log('Printing selected contact type'+addedcontType);
        this.defaultcontact.forEach(defaultlistitem=>{
            if(!addedcontType.includes(defaultlistitem)){
                tempContactlistnotselected.push(defaultlistitem);
            }
        })
        this.contactlistnotselected = tempContactlistnotselected;
        console.log('tempContactlistnotselected->'+tempContactlistnotselected);
        if(tempContactlistnotselected.length>0){
            console.log('setting contactscreenError as true');
            this.contactscreenError=true;
        }else{
            console.log('setting contactscreenError as false');
            this.contactscreenError=false;
        }
       /* if(!iscontactRecordAdded){
            console.log('showing Error');
            this.showToastMessage('error',('Please select the required Contact'));
            return true;
        }*/
        if(this.contactscreenError){
            this.showToastMessage('error',('Please select following Mandatory contact Types ' + this.contactlistnotselected));
            return true;
        }
    }

    get credentialList(){
        let credL = this.credList;
        let acclIst = [];
        acclIst.push(this.accountId);
        if(credL){
            for (var i = 0; i < credL.length; i++) {
                console.log('In credentialList(), credL[i].Type *********--> ', credL[i].Type);
                console.log('In credentialList(), credL[i].record *********--> ', credL[i].record);
                switch(credL[i].Type) {
                    case 'SALES_ENGINEER':
                        credL[i].IsUser = true;
                        credL[i].filterClause = 'where Profile.UserLicense.name =' + '\'' +'Salesforce' + '\'' + ' OR '+'Profile.UserLicense.name ='+ '\''+ 'Salesforce Platform'+ '\''  ;
                        console.log('printing filter clause->'+credL[i].filterClause);
                    break;
                    default:
                        credL[i].IsUser = false;
                        credL[i].filterClause =  'where accountid in ' + this.generateInQuery(acclIst);
                }
            }
        }
        console.log('In credentialList(), credentialList *********--> '+JSON.stringify(credL));
        return credL;
    }

    addInitialRow(){
        this.credList.push ({
            Label:'',
            Type: '',
            Index : this.index,
            RecID : '',
            IsUser : true,
            unfinished : true,
            typeOptionList : this.custtypeoptions,
            filterClause : '',
            isFirst : true
        });
        this.index++;
    }

    get custtypeoptions() {
        let options = [];
        this.custOptionAvilable.forEach(element=>{
            let chk = this.checkIfCredExists(element);
            if(!chk){
                options.push(element); 
            }
        });
        return options;
    }

    getCustomOptionLabel(type){
        let label = type;
        this.custOptionAvilable.forEach(currentItem => {
            if( currentItem.value == type){
                label = currentItem.label;
            }
        });
        console.log('getCustomOptionLabel'+label);
        return label;
    }

    generateInQuery(accList){
        let inQuery = '('
		if(accList){
            accList.forEach(currentItem => {
                inQuery+= '\''+currentItem+'\' ,';
            });
		}
        inQuery = inQuery.slice(0, -1);
        inQuery = inQuery + ')';
        return inQuery;
	}

    checkIfCredExists(ele){
        let ret = false;
        if(this.credentialList && this.credentialList.length > 0){
            for (var i = 0; i < this.credentialList.length; i++) {
               if(this.credentialList[i].Type == ele.value){
                    ret = true;
                    break;
                }
            }
        }
        return ret;
    }

    @track updatesSeUser;
    get seUserId(){
        if(this.updatesSeUser){
            console.log('this.updatesSeUser'+this.updatesSeUser);
            return this.updatesSeUser;
        } else {
          console.log('getFieldValue(this.oppt.data, SE_NAME)'+getFieldValue(this.oppt.data, SE_NAME));
          return getFieldValue(this.oppt.data, SE_NAME);
        }
    }

    handleLookup(event){
        console.log('--handleLookup called----',event.detail.data);
       if(event.detail.data && event.detail.data.sourceId !==  undefined){
           console.log('--lookup Selecteion----',event.detail.data);
           for (var i = 0; i < this.credList.length; i++) {
               if(i === event.detail.data.sourceId){
                   this.credList[i].RecID = event.detail.data.recordId ? event.detail.data.recordId : '';
                   this.credList[i].record = event.detail.data.record;
                   this.credList[i].unfinished = false;
                   if(this.credList[i].Type == 'SALES_ENGINEER' ){
                       this.updatesSeUser = event.detail.data.recordId ? event.detail.data.recordId : '';
                   }
               }
           }
       }
   }

    @track showProductsScreen = false;
    handleAssignedToCredChange(event){
        this.assignedTo=event.detail.value;
        if(this.businessPrimaryAdded){
            this.showProductsScreen = true;
        }
        console.log('--showProductsScreen--', this.showProductsScreen);
    }

    @track businessPrimaryAdded = false;
    get isBusinessPrimaryAdded(){
        let added = false;
        this.credList?.forEach(cred => {
            if(cred.Type && cred.Type == 'BUSINESS_PRIMARY'){
               added = true;
            }
        });
        this.businessPrimaryAdded = added;
        return added;
    }

    validateCredDetails(){
        let notValid = 0;
        if(this.credList && this.credList.length > 0){
            for (var i = 0; i < this.credList.length; i++) {
                if(this.credList[i].Type == '' ||  this.credList[i].Type == undefined || this.credList[i].RecID == '' || this.credList[i].RecID == undefined){
                    this.credList[i].unfinished = true;
                    notValid++;
                }else{
                    this.credList[i].unfinished = false;
                }
                this.credList[i].isFirst = i == 0 ? true : false;
            }
            return notValid>0 ? true : false;
        }else{
            return true;
        }
    }

    get assignCredTo(){
        //197
        let optionAvilable = [];
        this.credList?.forEach(cred => {
            if(cred.Type && cred.Label && cred.RecID){
                optionAvilable.push({label:cred.Label , value:cred.Type});
            }
        });
        return optionAvilable;
    }

    addRow(){
        this.credList.push ({
            Label:'',
            Type: '',
            Index : this.index,
            RecID : '',
            IsUser : true,
            unfinished : true,
            typeOptionList : this.custtypeoptions,
            showCopyContact:false
        });
        this.index++;
        this.validateCredDetails();
    }

    removeRow(event){
        let ind = event.currentTarget.dataset.id;
        let selectedcredList=[];
        console.log('inisde remove row');
        if(ind){
            if(this.credList.length>0){
                this.credList.splice(ind, 1);
            }
            //Reset the index for the splice
            this.index = 0
            for (var i = 0; i < this.credList.length; i++) {
                this.credList[i].Index = this.index;
                console.log('finding nemo'+this.credList);
                this.index++;
                selectedcredList.push(this.credList[i].Label);
                console.log('printing contcat type->'+this.credList[i].Label);                   
                   
            }
            if(!selectedcredList.includes('Sales Engineer')){
                this.showAssociateSEButton=false;
            }
        }
    }

    handleTypeChange(event){
        if(event.detail.value){
          
            console.log('contact type'+event.detail.value);
            for (var i = 0; i < this.credList.length; i++) {
                if(i == event.target.dataset.id){
                    this.credList[i].Type = event.detail.value;
                    this.credList[i].Label = this.getCustomOptionLabel(event.detail.value);
                    this.credList[i].RecID =  undefined;
                    this.credList[i].record = undefined;
                    if(this.credList[i].Type!=null || this.credList[i].Type!=''){
                        this.credList[i].showSeleectContact=true;
                    }else{
                        this.credList[i].showSeleectContact=false;
                    }
                    if(this.credList[i].Type=='SALES_ENGINEER'){
                        console.log('setting the record id'+this.seUserId);
                        this.credList[i].RecID=this.seUserId;
                        this.credList[i].showCopyContact=true;
                        this.credList[i].showSeleectContact=true;
                        this.showAssociateSEButton=true;
                    }
                }
            }
        }else{
            
            this.credList[event.target.dataset.id].Type = null;
            this.credList[event.target.dataset.id].showSeleectContact=false;
        }
    }

    handleKeyChange(event) {
        this.searching = true;
        console.log('this.searching handleKeyChange enter' + this.searching);
        const sKey = event.target.value;
        this.searchKey = sKey;
        if (sKey) {
            this.delayTimeout = setTimeout(() => {
                this.filteredPovProdList = this.prodList.filter(rec => JSON.stringify(rec).toLowerCase().includes(this.searchKey.toLowerCase()));
            }, DELAY);
        } else {
            this.filteredPovProdList = this.prodList;
        }
        console.log('this.searching handleKeyChange end' + this.searching);
    }

    showToastMessage(type, errMsg) {
        this.template.querySelector('c-custom-toast-component').showToast(type, errMsg);
    }

    handleBackToProductScreen(){
        this.currentStep="1";
    }

    handleBacktoOppButton() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opportunityId,
                actionName: 'view'
            }
        });
    }
}