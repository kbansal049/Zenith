import { LightningElement, api, track, wire } from 'lwc';
import search from '@salesforce/apex/SearchController.search';
import searchBasedOnID from '@salesforce/apex/SearchController.searchBasedOnID';
const DELAY = 300;

export default class GenericSearchComponent extends LightningElement {
    
    @api valueId;
    @api valueName;
    @api objName = 'Account';
    @api iconName = 'standard:account';
    @api labelName;
    @api readOnly = false;
    @api currentRecordId;
    @api placeholder = 'Search';
    @api createRecord;
    @api fields = ['Name'];
    @api displayFields = 'Name, Rating, AccountNumber';
    @api sourceId = '';
    @api filter;


    @track error;

    searchTerm;
    delayTimeout;

    searchRecords;
    selectedRecord;
    objectLabel;
    isLoading = false;

    field;
    field1;
    field2;

    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';
    

    connectedCallback(){

        let icons           = this.iconName.split(':');
        this.ICON_URL       = this.ICON_URL.replace('{0}',icons[0]);
        this.ICON_URL       = this.ICON_URL.replace('{1}',icons[1]);
        if(this.objName.includes('__c')){
            let obj = this.objName.substring(0, this.objName.length-3);
            this.objectLabel = obj.replaceAll('_',' ');
        }else{
            this.objectLabel = this.objName;
        }
        this.objectLabel    = this.titleCase(this.objectLabel);
        let fieldList;
        if( !Array.isArray(this.displayFields)){
            fieldList       = this.displayFields.split(',');
        }else{
            fieldList       = this.displayFields;
        }
        
        if(fieldList.length > 1){
            this.field  = fieldList[0].trim();
            this.field1 = fieldList[1].trim();
        }
        if(fieldList.length > 2){
            this.field2 = fieldList[2].trim();
        }
        let combinedFields = [];
        fieldList.forEach(field => {
            if( !this.fields.includes(field.trim()) ){
                combinedFields.push( field.trim() );
            }
        });

        this.fields = combinedFields.concat( JSON.parse(JSON.stringify(this.fields)) );

        this.handlePreSelectedValue();
        
    }

    @api
    triggerChange(valueId){
        console.log('triggerChange:valueId:',valueId);
        this.valueId = valueId;
        this.connectedCallback();
    }

    async handlePreSelectedValue(){
        if(this.valueId){
            await this.handleSearchID(this.valueId);
            this.handlePreRecordSelect(this.valueId);
        }
    }

    handlePreRecordSelect(recordId){
        console.log('--handlePreRecordSelect-called--');
        console.log('--handlePreRecordSelect-searchRecords--',this.searchRecords);
        let selectRecord = this.searchRecords.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;
        this.selectedRecord = selectRecord;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {  
                data : {
                    record          : selectRecord,
                    recordId        : recordId,
                    currentRecordId : this.currentRecordId,
                    sourceId : this.sourceId
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }


    handleInputChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
       
        this.delayTimeout = setTimeout(()  => {
            if(searchKey.length >= 2){
                this.isLoading = true;
                this.handleSearchValue(searchKey);
            }
        }, DELAY);
    }


    async handleSearchID(searchKey){
        console.log('--handleSearchValue-called--');
        console.log('--handleSearchValue-searchKey--',searchKey);
        await searchBasedOnID({ 
            objectName : this.objName,
            fields     : this.fields,
            searchTerm : searchKey 
        })
        .then(result => {
            let stringResult = JSON.stringify(result);
            let allResult    = JSON.parse(stringResult);
            allResult.forEach( record => {
                record.FIELD1 = record[this.field];
                record.FIELD2 = record[this.field1];
                if( this.field2 ){
                    record.FIELD3 = record[this.field2];
                }else{
                    record.FIELD3 = '';
                }
            });
            this.searchRecords = allResult;
        })
        .catch(error => {
            console.error('Error:', error);
        })
        .finally( ()=>{
            this.isLoading = false; 
        });
    }


    async handleSearchValue(searchKey){
        console.log('--handleSearchValue-called--'+searchKey);
        await search({ 
            objectName : this.objName,
            fields     : this.fields,
            searchTerm : searchKey,
            filter     : this.filter
        })
        .then(result => {
            let stringResult = JSON.stringify(result);
            let allResult    = JSON.parse(stringResult);
            allResult.forEach( record => {
                record.FIELD1 = record[this.field];
                record.FIELD2 = record[this.field1];
                if( this.field2 ){
                    record.FIELD3 = record[this.field2];
                }else{
                    record.FIELD3 = '';
                }
            });
            this.searchRecords = allResult;
        })
        .catch(error => {
            console.error('Error:', error);
        })
        .finally( ()=>{
            this.isLoading = false; 
        });
    }


    handleSelect(event){
        console.log('---handleSelect--called---');
        let recordId = event.currentTarget.dataset.recordId;
        let selectRecord = this.searchRecords.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {  
                data : {
                    record          : selectRecord,
                    recordId        : recordId,
                    currentRecordId : this.currentRecordId,
                    sourceId : this.sourceId
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }


  

    @api handleClose(event){
        console.log('---handleClose--called---');
        let recordId = undefined;
        this.selectedRecord = undefined;
        this.searchRecords  = undefined;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {  
                 data : {
                    record          ,
                    recordId        ,
                    currentRecordId : this.currentRecordId,
                    sourceId : this.sourceId
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    titleCase(string) {
        var sentence = string.toLowerCase().split(" ");
        for(var i = 0; i< sentence.length; i++){
            sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
        }
        return sentence;
    }
}