import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductsForSelectedBundle from '@salesforce/apex/renewalScenariosController.getProductsForSelectedBundle';
import QuoteLineProducts_list from '@salesforce/apex/renewalScenariosController.QuoteLineProduct_List';
import getBundlesValuesForPicklist from '@salesforce/apex/renewalScenariosController.getBundlesValuesForPicklist';
import saveRenewalLinesToQuote from '@salesforce/apex/renewalScenariosController.saveRenewalLinesToQuote';
import Like_for_Like_OBS_renewal_rules from '@salesforce/label/c.Like_for_Like_OBS_renewal_rules';
import Contract_Number from '@salesforce/label/c.Contract_Number';
import Upgrade_OBS_renewal_rules from '@salesforce/label/c.Upgrade_OBS_renewal_rules';
import Fedramp_Certified_Pricelists from '@salesforce/label/c.Fedramp_Certified_Pricelists';
import { getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//import CLOUD_TYPE from '@salesforce/schema/SBQQ__Quote__c.Cloud_Type__c';


const FIELDS = ['SBQQ__Quote__c.Contract_Number__c','SBQQ__Quote__c.Opportunity_Record_Type__c','SBQQ__Quote__c.Price_List__c','SBQQ__Quote__c.RecordTypeId']
const CLOUD_TYPE=['SBQQ__Quote__c.Cloud_Type__c'];
const columns = [
    { label: 'Upgrade to', fieldName: 'description',wrapText : true},
    { label: 'Upgrade Path', fieldName: 'nameRenewedTo'},
    {
        label: 'Action',
        type:'button-icon',
        typeAttributes: {
            title: "Select",
            alternativeText: "Select",
            iconName: 'utility:new',
           
        }, cellAttributes: {class:{ fieldName: 'cssClass' },iconPosition: 'left'}
    },
];

export default class RenewalScenario extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showTable = true;
    @track selectedTab;
    @track selectedInstallBase;
    @track data =[];
    @track selectedRows;
    @track renewalData = [];
    @track renewalDataWithDate=[];
    @track dataCopy =[];
    @track dataForPicklist =[];
    @track isShowSpinner = false;
    @track proposalName;
    @track quoteName;
    @track idArray=[];
    @track uniqueInstallBase = [];
    columns = columns;
    @track openModal = false;
    @track msgForNoProducts = false;
    @track installBaseSelectedKey;
    @track error;
    @track finalDataToApexOnSelect =[];
    mapOfInstallBaseVsSubId = new Map();
    earlierVisitedTab = new Map();
    @track pickListAndData=[];
    renewalMessage = false;
    likeToLikeMessage;
    //@track upgradeTable=[];
    label = {
        Like_for_Like_OBS_renewal_rules,
        Contract_Number,
        Upgrade_OBS_renewal_rules,
        Fedramp_Certified_Pricelists
    };
    showCloudType = false;
    recordTypeId;
    cloudTypePicklistList;
    selectedCloudType;
    @track installBaseId =new Map();//IBA-3548
    selectedInstallBaseProductcode="ZIA/ZPA" ;//IBA-3548
    QuoteLineProductList=false;
    UpgradedPathValidation = false;
    QuoteLineProductList_string=[];
    PriceList ;
   
    get options() {
        var returnOptions = [];
        let pickListData =[];
     
        pickListData = this.dataForPicklist;
        if(pickListData !==null && pickListData !==undefined){
            pickListData.forEach(element => {
                returnOptions.push({label:element.SBQQ__Product__r.Name,value:element.SBQQ__Product__r.Name + '_' +element.Id + '_'+this.selectedTab});
                this.installBaseId.set(element.SBQQ__Product__r.Name + '_' +element.Id + '_'+this.selectedTab,element.SBQQ__Product__r.ProductCode);//IBA-3548
            });
            console.log(this.installBaseId);
            return returnOptions;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields:FIELDS })
    quoteContractNumber({ error, data }) {
        if(data){
            if(data.fields.Contract_Number__c.value !==null  && data.fields.Opportunity_Record_Type__c.value ==='Renewal Opportunity' && Contract_Number.split(',').includes(data.fields.Contract_Number__c.value)){
                this.renewalMessage =true;
            }
            if(this.label.Fedramp_Certified_Pricelists.split(';').includes(data.fields.Price_List__c.value)){
                this.showCloudType = true;
            }
            this.recordTypeId = data.fields.RecordTypeId.value;
            console.log(this.recordTypeId);
        }else if(error){
            console.log('error'+JSON.stringify(error))
        }
    }

    @wire(getPicklistValues,{recordTypeId: '$recordTypeId',fieldApiName: CLOUD_TYPE}) cloudTypePicklistValues({data,error}){
        if(data){
            console.log(data.values);
            this.cloudTypePicklistList = data.values;
        }else if(error){
            console.log(error);
        }
    }
    tabselect(evt) {
        this.data = [];
        this.selectedTab = evt.target.name;
        if(this.earlierVisitedTab.has(evt.target.name)){
            this.data = this.pickListAndData[this.earlierVisitedTab.get(evt.target.name)];
            //this.renewalData = this.upgradeTable[this.earlierVisitedTab.get(evt.target.name)];
            console.log('this.data::',this.data);
        }else{
           
            getBundlesValuesForPicklist({quoteId :this.recordId})
            .then(results => {
                console.log('results::',results);
                if(results.picklistValues ==undefined){
                    this.dataForPicklist =[];
                    this.msgForNoProducts = true;
                }
                if(results.quoteObj !==null){
                    this.proposalName = results.quoteObj.Proposal_Name__c;
                    this.quoteName = results.quoteObj.Name;
                }
                if(results.picklistValues!==undefined && results.picklistValues!==null){
                    console.log(results.picklistValues);
                    this.dataForPicklist = results.picklistValues;
                }
                console.log('this.dataForPicklist ::',this.dataForPicklist );
            })
            .catch(error =>{
                this.error = error;
                console.log('error::',JSON.stringify(this.error));
                this.showToastInfo(JSON.stringify(this.error));
            })
        }
    }
    handlePicklistChange(event){
        this.showTable = true;
        this.isShowSpinner = true;
        if(this.QuoteLineProductList==false){
           
        QuoteLineProducts_list({quoteId:this.recordId})
        .then(results => {
            console.log('on QuoteLine List ::',results);
            let dataCopyForJSON =[];
            let QuoteLineProductList_string =[];
            dataCopyForJSON = results;
            for(let i=0;i<dataCopyForJSON.length;i++){
                console.log('dataCopyForJSON ::', dataCopyForJSON[i].SBQQ__ProductCode__c);
                this.QuoteLineProductList_string.push(dataCopyForJSON[i].SBQQ__ProductCode__c.toString());
            }
            if(this.QuoteLineProductList_string!=null){
                this.QuoteLineProductList=true;
            }
            this.PriceList = dataCopyForJSON[0].SBQQ__Quote__r.Price_List__c.toString();
            console.log('QuoteLineProductList_string ::', this.QuoteLineProductList_string);
            console.log('this.PriceList ::', this.PriceList);
})
       

        console.log('QuoteLineProducts ::',this.QuoteLineProductList);

        }
        console.log('event.target.value::',event.target.value);
        console.log(this.installBaseId.has(event.target.value));
        console.log(this.installBaseId.get(event.target.value));
      //  this.selectedInstallBaseProductcode = this.installBaseId.get(event.target.value);//IBA-3548
        var installBaseVal = event.target.value;
        this.installBaseSelectedKey = installBaseVal;
        this.mapOfInstallBaseVsSubId.set(installBaseVal.split('_')[0],installBaseVal.split('_')[1]);
        this.selectedInstallBase = installBaseVal.split('_')[0];
        console.log('handlePicklistChangethis.recordId...'+this.recordId);
        getProductsForSelectedBundle({installBase:this.selectedInstallBase,type:this.selectedTab,quoteId:this.recordId})
        .then(results => {
            console.log('on picklist select::',results);
            let dataCopyForJSON =[];
            let childQuoteLines =[];
            dataCopyForJSON = results;
            for(let i=0;i<dataCopyForJSON.length;i++){
                for(let j=0;j<dataCopyForJSON[i].lstQuoteLine.length;j++){
                    if(dataCopyForJSON[i].lstQuoteLine[j].SBQQ__RequiredBy__c !== undefined){
                        childQuoteLines.push({description:dataCopyForJSON[i].lstQuoteLine[j].SBQQ__ProductName__c,installBase:'',nameRenewedTo:'',cssClass:'slds-hidden'});
                    }
                }
                dataCopyForJSON[i].lstQuoteLine = childQuoteLines;
                childQuoteLines =[];
            }
            for(let i=0;i<dataCopyForJSON.length;i++){
                dataCopyForJSON[i]._children = dataCopyForJSON[i].lstQuoteLine;
                delete dataCopyForJSON[i].lstQuoteLine;
            }
            childQuoteLines=[];
            this.data= dataCopyForJSON;
            this.isShowSpinner = false;
            if(this.earlierVisitedTab.has(this.selectedTab) ){
                this.earlierVisitedTab.delete(this.selectedTab);
                this.earlierVisitedTab.set(this.selectedTab,this.installBaseSelectedKey);
                this.pickListAndData[this.installBaseSelectedKey] = this.data;
                //this.upgradeTable[this.installBaseSelectedKey] = this.renewalData;
               
                console.log('pickListData::',this.pickListAndData);
            }else{
                this.earlierVisitedTab.set(this.selectedTab,this.installBaseSelectedKey);
                this.pickListAndData[this.installBaseSelectedKey] = this.data;
                //this.upgradeTable[this.installBaseSelectedKey] = this.renewalData;
                console.log('pickListData in else::',this.pickListAndData);
            }
})
.catch(error =>{
            this.error = error;
            this.showToastInfo(JSON.stringify(this.error));
        })
       
       
    }
    handleSelect(event){
        this.selectedInstallBaseProductcode="ZIA/ZPA" ;
        var UpgradedPathValidation = this.UpgradedPathValidation;
        let dataToUpgrade =[];
        var indexValue;
        var idIndex;
        console.log(event.detail.row.Id);
        if(event.detail.row.description == "ZIA BIZ Edition" ){
            this.selectedInstallBaseProductcode="ZIA-BIZ-EDITION";
        }
        if(event.detail.row.description == "ZIA Unlimited Edition"){
            this.selectedInstallBaseProductcode="ZIA-UNLTD-EDITION";
        }
        if(event.detail.row.description == "ZIA Transformation Edition"){
            this.selectedInstallBaseProductcode="ZIA-TFORM-EDITION"
        }
        if(event.detail.row.description == "ZIA Essentials Edition"){
            this.selectedInstallBaseProductcode="ZIA-ESS-EDITION"
        }
        if(event.detail.row.description == "ZIA Business Edition"){
            this.selectedInstallBaseProductcode="ZIA-BIZ-EDITION"
        }
        if(event.detail.row.description == "ZIA TFORM Edition"){
            this.selectedInstallBaseProductcode="ZIA-TFORM-EDITION"
        }
        if(event.detail.row.description == "ZPA TFORM Edition"){
            this.selectedInstallBaseProductcode="ZPA-TFORM-EDITION"
        }
        if(event.detail.row.description == "ZPA BIZ Edition" ){
            this.selectedInstallBaseProductcode="ZPA-BIZ-EDITION";
        }
        if(event.detail.row.description == "ZPA Business Edition"){
            this.selectedInstallBaseProductcode="ZPA-BIZ-EDITION"
        }
        if(event.detail.row.description == "ZPA Transformation Edition"){
            this.selectedInstallBaseProductcode="ZPA-TFORM-EDITION"
        }

        var ProductCode =this.selectedInstallBaseProductcode.toString();
        console.log('In handle select',this.QuoteLineProductList_string);
        console.log('QuoteLineProductList.length : ',this.QuoteLineProductList_string.length);
        console.log('ProductCode : ',ProductCode);
        for(let i = 0; i<this.QuoteLineProductList_string.length;i++){
            if(this.QuoteLineProductList_string[i]==ProductCode){
                UpgradedPathValidation=true;
                break;
            }
            console.log('Product : ', this.QuoteLineProductList_string[i]);
           
        }
        console.log('UpgradedPathValidation : ', UpgradedPathValidation);
        if(UpgradedPathValidation && this.selectedInstallBaseProductcode!="ZIA/ZPA"){
            const toastEvent=new ShowToastEvent({
                title:"Upgraded Path selection Failed..!!",
                message: "You cannot select this product for Upgrade.Please select other Product for Upgrade.",
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
        }

       
        else{
            dataToUpgrade.push({Id:event.detail.row.Id,originalQuoteId:event.detail.row.originalQuoteId,
                nameRenewedTo:event.detail.row.nameRenewedTo,installBase:event.detail.row.installBase,
                description:event.detail.row.description,
                subscriptionId:this.mapOfInstallBaseVsSubId.get(event.detail.row.installBase),selectedTab:this.selectedTab,productFamily:event.detail.row.zscalerProductFamily});
                for(let i=0;i<dataToUpgrade.length;i++){
                    // idArray - donot allow more than 1 selection for 1 record
                    // uniqueInstallBase - one unique value per installbase
                    if(!this.idArray.includes(dataToUpgrade[i].Id) && !this.uniqueInstallBase.includes(dataToUpgrade[i].installBase)){
                        this.renewalData.push(dataToUpgrade[i]);
                         this.idArray.push(dataToUpgrade[i].Id);
                        this.uniqueInstallBase.push(dataToUpgrade[i].installBase);
                    }else if(!this.idArray.includes(dataToUpgrade[i].Id) && this.uniqueInstallBase.includes(dataToUpgrade[i].installBase)){
                           this.renewalData.forEach(element => {
                            if(element.installBase == dataToUpgrade[i].installBase){
                                indexValue = this.renewalData.indexOf(element);
                                this.renewalData.splice(indexValue,1);
                                idIndex = this.idArray.indexOf(element.Id);
                                this.idArray.splice(idIndex,1);
                                this.renewalData.push(dataToUpgrade[i]);
                                }
                             });
                    }
                }
            dataToUpgrade=[];
             }
       
    }

    handleCancel(){
let link = '/apex/sbqq__sb?id=' +this.recordId
+ '#quote/le?qId=' + this.recordId;
this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: link
        },
}, true);
        this.renewalData =[];
        this.data = [];
    }

    handleModalCancel(){
        this.openModal = false;
    }

    handleEffectiveDate(event){
        this.renewalData.forEach(element => {
            if(element.Id === event.target.name){
                element['effectiveDate'] = event.target.value;
                this.renewalDataWithDate.push(element);
            }
        });
    }

    deleterows(event){
        let dataBuffer =[];
        var indexOfElement;
        var indexForInstallBase;
        this.renewalData.forEach(element => {
            if(element.Id !== event.target.name){
                dataBuffer.push(element);
            }else if(element.Id === event.target.name){
                if(this.uniqueInstallBase.includes(element.installBase)){
                    indexForInstallBase = this.uniqueInstallBase.indexOf(element.installBase);
                    this.uniqueInstallBase.splice(indexForInstallBase,1);
                }
            }
        });
        this.renewalData = dataBuffer;
        if(this.idArray.includes(event.target.name)){
            indexOfElement = this.idArray.indexOf(event.target.name);
            this.idArray.splice(indexOfElement,1);
        }
    }

    handleFooterSelect(){
        this.openModal = true;
    }
    saveQuoteLines(){
        this.isShowSpinner = true;
        this.openModal = false;
        console.log('this.renewalData:: on saveQuoteLines',this.renewalData);
        saveRenewalLinesToQuote({destQuoteId :this.recordId,cloudType:this.selectedCloudType,selectedRowsForRenewal:JSON.stringify(this.renewalData),selectedInstallBase:this.uniqueInstallBase})
        .then(results => {
            if(results === 'success'){
                window.location.assign('/one/one.app#/alohaRedirect/apex/sbqq__sb?id=' + this.recordId);
                this.isShowSpinner = false;
            }
        })
        .catch(error =>{
            this.isShowSpinner = false;
            this.error = error;
            console.log('error : ' + JSON.stringify(error));
            this.showToastInfo(JSON.stringify(this.error));
        })
    }
    closeModal() {
        this.openModal = false;
    }
    showToastInfo(msg){
        const toastEvnt = new  ShowToastEvent( {
            title: 'Error!',
            message: msg,
            variant: 'error',
            mode: "sticky"
        });
        this.dispatchEvent (toastEvnt);
    }
    handleChange(event){
        this.selectedCloudType = event.detail.value;
    }
}