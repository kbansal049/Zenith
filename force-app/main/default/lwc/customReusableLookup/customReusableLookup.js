import searchRecords from '@salesforce/apex/OrderTrackerHelper.SearchRecords';
import { api, LightningElement, track, wire } from 'lwc';


export default class CustomReusableLookup extends LightningElement {

    @api objName;
    @api iconName;
    @api filter = '';
    @api isMultiselect = false;
    @api searchPlaceholder = 'Search';
    @track selectedName;
    @track records;
    @track isValueSelected = false;
    @track blurTimeout;
    searchTerm;
    self;
    isFirstTime = false;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    
    @wire(searchRecords, {searchTerm : '$searchTerm', objectName : '$objName', filter : '$filter'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
 
    connectedCallback() {

    }

    handleEnter(event) {
        console.log(event.keyCode);
        if(event.keyCode === 13) {
            let selectedId = this.searchTerm;
            let selectedName = this.searchTerm;
            console.log(selectedId,selectedName)
            if(this.isMultiselect){
                console.log('In the multisleect')
                var obj = new Object();
                obj.Id = selectedId;
                obj.Name = selectedName;
                const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  {...obj} });
                this.dispatchEvent(valueSelectedEvent);
                this.isValueSelected = false;
                this.searchTerm = '';
            }
            else{
                var obj = new Object();
    
                const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  {...obj} });
                this.dispatchEvent(valueSelectedEvent);
                this.isValueSelected = false;
                this.selectedName = selectedName;
                this.searchTerm = '';
            }
            if(this.blurTimeout) {
                clearTimeout(this.blurTimeout);
            }
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        }
    }

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        console.log(selectedId,selectedName)
        if(this.isMultiselect){
            console.log('In the multisleect')
            var obj = new Object();
            obj.Id = selectedId;
            obj.Name = selectedName;
            const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  {...obj} });
            this.dispatchEvent(valueSelectedEvent);
            this.isValueSelected = false;
        }
        else{
            var obj = new Object();

            const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  {...obj} });
            this.dispatchEvent(valueSelectedEvent);
            this.isValueSelected = false;
            this.selectedName = selectedName;
        }
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;
        var obj = new Object();
        obj.Id = undefined;
        obj.Name = undefined;
        obj.isCalledFromRemovePill = true;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  {...obj} });
        this.dispatchEvent(valueSelectedEvent);
    
    }

    onChange(event) {
        this.searchTerm = event.target.value;

    }
}