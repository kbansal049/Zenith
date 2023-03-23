import { LightningElement, api, track , wire} from 'lwc';
import { NavigationMixin} from 'lightning/navigation';
import getQuoteDetails from '@salesforce/apex/premSupportLWCController.getQuoteDetails';

import sendPSApproval from '@salesforce/apex/premSupportLWCController.sendPSApproval';
import deleteYWS from '@salesforce/apex/premSupportLWCController.deleteYWS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Id';
import CountryLanguageApiName from '@salesforce/schema/SBQQ__QuoteLine__c.Country_Language__c';
import SUPPORT_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Support_Type__c';
import TAM_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.TAM_Coverage__c';
import MIN_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Minimum_Support_Type_ACV__c';
import SUPPORT_TYPE_PRODUCT_CODE_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Support_Type_Product_Code__c';
import SELECTION_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Support_Selection__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
import EQUIP_OBJECT from '@salesforce/schema/Equipment_Request__c';


const columns = [
    { label: 'Product Name', fieldName: 'name'},
    { label: 'Description', fieldName: 'description' },
    
    {
        label: 'P&S Request',
        type: "button",
        typeAttributes: {
            label: {fieldName : 'buttonNamePS'},
            name: 'Create PS',
            title: 'Create PS',
            disabled: { fieldName: 'isDisabledPS'},
            value: 'Create PS',
            iconPosition : 'left',
        }
    },
    {
        label: 'Country/Language', fieldName: 'CountryLanguage', type: 'picklistColumn', editable: true, wraptext : true,
        typeAttributes: {
            placeholder: 'Choose Type', 
            options: {fieldName:'pickListOptions'},
            value:{fieldName:'CountryLanguage'},
            context: { fieldName: 'Id' } // binding Opportunity Id with context variable to be returned back
        }
    },

    {
        label: 'Action',
        type: "button",
        typeAttributes: {
            label: {fieldName : 'buttonName'},
            name: 'Use this SKU',
            title: 'Use this SKU',
            variant : { fieldName: 'cssClass'},
            disabled: { fieldName: 'isDisabled'},
            value: 'Use this SKU',
            iconPosition : 'left',
        }
    }
];
export default class PremSupportLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track quoteName;
    @track columns = columns;
    @track Country_Language ;
    @track dataTable = [];
    @track showDataTable = false;
    @track quoteLine;
    @track isLoaded = true;
    @track isModalOpen = false;
    @track oppId;
    @track prodId;
    @track disabledField = true;
    @api objectApiName;
    @track oppData;
    @track objectInfo;
    @track pickListOptions ;
    @track draftValues = [];
    lastSavedData = [];
    @wire(getObjectInfo, { objectApiName: EQUIP_OBJECT })
    objectInfo;
    rowName;
    productCode;
    invalidInput;
    get recordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Restricted SKU\'s');
    }


    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.pickListOptions));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
 
        //write changes back to original data
        this.pickListOptions = [...copyData];
    }
 
    handleCellChange(event) {
        
       console.log('event.detail.draftValues::',JSON.parse(JSON.stringify(event.detail.draftValues)));
       if(event.detail.draftValues){
            this.Country_Language = event.detail.draftValues[0].CountryLanguage;
            
        }
        
    }

    results;
    psRequestId;
    temp=[];
    connectedCallback() {
        this.getPremData();
    }
    getPremData(){
        getQuoteDetails({QuoteId:this.recordId}) 
        .then(results => {
            console.log('results::',results);
            console.log('premsrecords', results.premRecords);
            //console.log('GlobalPickList::',results.premRecords[5].globalPicklistValue[0]);
            let options=[];
            this.results = results;
            this.quoteName = results.quoteObj.Name;
            this.oppId = results.quoteObj.SBQQ__Opportunity2__c;
            console.log('oppId++',this.oppId);
           
            
            if(results.quoteObj.SBQQ__LineItems__r && results.quoteObj.SBQQ__LineItems__r.length >= 1){
                console.log('Check');
                this.showDataTable = true;
                this.quoteLine = results.quoteObj.SBQQ__LineItems__r[0];
                this.dataTable = results.premRecords;
                
              
            }
            let inCountry = this.dataTable.filter((prem)=>
                prem.productCode === 'ZCES-SUP-PREM-IN-CTRY'
            )

            if(inCountry.length>0){
            this.Country_Language = inCountry[0].globalPicklistValue[0];

            for(let j = 0;j<inCountry[0].globalPicklistValue.length;j++){
                options.push({label: inCountry[0].globalPicklistValue[j],value: inCountry[0].globalPicklistValue[j]});
            }}
            
            this.dataTable = this.dataTable.map((rec)=>{
                return {
                    ...rec,
                  pickListOptions:options
                }
            })
            console.log(this.dataTable)
            
        })
        .catch(error => {
            this.error = error;
            console.log('error::'+JSON.stringify(this.error));
            this.showToastInfo(JSON.stringify(this.error));
        });
    }
  
    showToastInfo(msg){
        const toastEvnt = new  ShowToastEvent( {
            title: 'Error!',
            message: msg,
            variant: 'error',
            mode: "dismissable"
        });
        this.dispatchEvent (toastEvnt);
    }
    onBack(){
        //window.location.assign('/one/one.app#/alohaRedirect/apex/sbqq__sb?id=' + this.recordId);
        let link = '/apex/sbqq__sb?id=' +this.recordId
					+ '#quote/le?qId=' + this.recordId;
		this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: link
        },
		}, true);
    }  

    handleRowAction(event){
        let action = event.detail.action;
        let row = event.detail.row;
        console.log('row',row);
        

        this.rowName = row.name;
        switch (action.name) {
            case 'Use this SKU':
                console.log('qlId1',this.quoteLine);
                if(this.quoteLine.Id && row.cssClass!= 'brand'){
                    this.toggle();
                    console.log('row',row.Product_Code__c);
                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = this.quoteLine.Id;
                    fields[CountryLanguageApiName.fieldApiName] = this.Country_Language;
                    fields[SUPPORT_FIELD.fieldApiName] = row.supportType;
                    fields[TAM_FIELD.fieldApiName] = row.tamCoverage;
                    fields[MIN_FIELD.fieldApiName] = row.miniRange;
                    fields[SUPPORT_TYPE_PRODUCT_CODE_FIELD.fieldApiName] = row.Product_Code__c;
                    fields[SELECTION_FIELD.fieldApiName] = 'Manual';   
                   /*if(row.supportType == 'Premium Support Plus' ){
                        fields[SELECTION_FIELD.fieldApiName] = 'Manual';    
                    }
                    else{
                        fields[SELECTION_FIELD.fieldApiName] = 'Automated';
                    }*/
                    
            const recordInput = { fields };
            console.log(recordInput);            
            updateRecord(recordInput)
                .then(() => {
                    this.toggle();
                    console.log('inside',JSON.stringify(this.dataTable));
                    this.temp = [];
                    this.dataTable.forEach(rows=>{
                        if(rows.cssClass === 'brand'){
                            rows.cssClass ='Neutral';
                            rows.buttonName ='Use this support type';
                        }
                        if(row.name === rows.name){
                            rows.cssClass ='brand';
                            rows.buttonName ='Applied support type';
                        }
                        this.temp.push(rows);
                    })
                    this.dataTable = this.temp;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Premium support type is updated',
                            variant: 'success'
                        })
                    );
                    deleteYWS({QuoteId:this.recordId}).then(results => {
                        console.log('results::');
                    })
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while updating the premium support',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.toggle();
                });
                }
                break;
                case 'Create PS':
                    if( row.productCode !== 'ZCES-SUP-PREM-IN-CTRY'){
                       this.Country_Language = undefined
                    }
                    this.productCode = row.productCode;
                    this.prodId = row.productId;
                    this.isModalOpen = true;
                break;

        }
    }
   
    toggle() {
        this.isLoaded = !this.isLoaded;
    }
    closeModal(){
        this.isModalOpen = false;
    }
    submitDetails(event){
        event.preventDefault();
        this.isLoaded = true;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.name ==='countryLanguage' && ((this.productCode === 'ZCES-SUP-PREM-IN-CTRY' && (field.value === undefined ||field.value === "" || field.value ===null )) ||(this.productCode !== 'ZCES-SUP-PREM-IN-CTRY' && (field.value !== undefined && field.value !== "" && field.value !==null)))){
                    console.log('inside')
                    this.invalidInput =true;
                    this.isLoaded = false;
                }else if(field.name ==='countryLanguage'){
                    this.invalidInput =false;
                }
            });
        }
        this.template.querySelector('lightning-record-edit-form').submit();
        this.toggle();
        
        
    }
    handleSuccess(event) {
        this.psRequestId = event.detail.id;
        sendPSApproval({PsRecordId:this.psRequestId}) 
        .then(results => {
                this.temp = [];
                this.dataTable.forEach(rows=>{
                    if(this.rowName === rows.name){
                        rows.isDisabledPS = true;
                        rows.buttonNamePS ='Pending Approval';
                    }
                    this.temp.push(rows);
                })
                this.dataTable = this.temp;
                this.isModalOpen = false;
                this.toggle();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'P&S Request has been Submitted for Approval',
                        variant: 'success'
                    })
                );
        })
        .catch(error => {
            this.isModalOpen = false;
            this.toggle();
            this.showToastInfo(JSON.stringify(error));
        })
        
    }
}