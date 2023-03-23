import { LightningElement, track, api, wire } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';
import getPathCategoryMapping from '@salesforce/apex/CustomPathController.getPathCategoryMapping';
import getAllCategories from '@salesforce/apex/CustomPathController.getAllMainCategories';
import { CurrentPageReference } from 'lightning/navigation';

export default class CustomPathLWC extends LightningElement {
    @api category;
    @api isOnlyCategory;
    @api recordId;
    @api recordTypeId;
    @api opportunityId;
    @api projectId;

    @track currentRecordId;
    @track currentRecordTypeId;
    
    @track styleForWidth;
    @track listOfPath;
    @track listOfCategories;
    @track currentSubCategory;
    @track currentCategory;
    @track showSubCategory = true;
    

    @track mapOfIdAndFieldSet = [];
    @track listOfSubCategories = [];

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        if(typeof this.recordId === 'undefined'){
            this.currentRecordId = '';
        }else{
            this.currentRecordId = this.recordId;
        }
        if(typeof this.recordTypeId === 'undefined'){
            this.currentRecordTypeId = '';
        }else{
            this.currentRecordTypeId = this.recordTypeId;
        }
        console.log('Custom Path LWC---> OpportunityId--->'+this.opportunityId);
        console.log('Custom Path LWC---> ProjectId--->'+this.projectId);
        if(this.isOnlyCategory == 'true'){
            console.log('Registering event---->'+this.isOnlyCategory);
            registerListener('categoryChangeFromSubCategory', this.handleCatChangeFromSubCat, this);
        }
    }

    handleCatChangeFromSubCat(message) {
        if(this.isOnlyCategory == 'true'){
            //console.log('this is the best part of lwc :'+JSON.stringify(message));
            this.template.querySelector('[data-id='+message.currentCategory+']').className='slds-path__item slds-is-complete';
            this.template.querySelector('[data-id='+message.targetCategory+']').className='slds-path__item slds-is-current slds-is-active';
            this.currentCategory = message.targetCategory;
        }
        
    }

    handleValueChange(value){
        console.log('This is handle value change callledd--->>>'+value);
    }

    @wire(getAllCategories, {recordId: '$currentRecordId', recordTypeId: '$currentRecordTypeId'})
    fetchCategories(result){
        console.log('Fetching Categories function called');
        console.log('Type of recordId :'+typeof this.recordId);
        console.log('Type of recordTypeId :'+typeof this.recordTypeId);
        if(result.data){
            this.listOfCategories = result.data;
            console.log('listOfCategories---->'+this.listOfCategories);
        }
    }

    @wire(getPathCategoryMapping, {category:'$category', isCategory: '$isOnlyCategory', recordId: '$currentRecordId', recordTypeId: '$currentRecordTypeId'})
    pathMapping(result) {
        console.log('getPathCategoryMapping method called New :'+result);
        if (result.data) {
            if(this.isOnlyCategory == 'true'){
                this.showSubCategory = false;
            }
            console.log('showSubCategory :'+this.showSubCategory);
            this.listOfPath = result.data;
            if(result.data[0]){
                if(this.isOnlyCategory == 'true'){
                    this.currentCategory = result.data[0].subCatId;
                }else{
                    this.currentSubCategory = result.data[0].subCatId;
                }
                
            }
        }
        else{
            console.log('Error in retrieving Mapping');
        }
    }

    handleCategoryChange(event){
        this.spinnerLoad(true);
        let targetId = event.currentTarget.dataset.id;
        var currentCategoryClass = this.template.querySelector('[data-id='+this.currentCategory+']').className;
        var targetCategoryClass = this.template.querySelector('[data-id='+targetId+']').className;
        console.log('currentCategoryClass Main-->'+currentCategoryClass);
        console.log('targetCategoryClass Main--->'+targetCategoryClass);
        if(currentCategoryClass.includes('slds-is-complete')){
            this.template.querySelector('[data-id='+this.currentCategory+']').className='slds-path__item slds-is-complete';
        }else{
            this.template.querySelector('[data-id='+this.currentCategory+']').className='slds-path__item slds-is-incomplete';
        }

        if(targetCategoryClass.includes('slds-is-complete')){
            this.template.querySelector('[data-id='+targetId+']').className='slds-path__item slds-is-complete slds-is-current slds-is-active';
        }else{
            this.template.querySelector('[data-id='+targetId+']').className='slds-path__item slds-is-current slds-is-active';
        }
        //this.template.querySelector('[data-id='+this.currentCategory+']').className='slds-path__item slds-is-incomplete';
        //this.template.querySelector('[data-id='+targetId+']').className='slds-path__item slds-is-current slds-is-active';
        //Event - Start
        console.log('Questinnaire Id before assignment '+ this.recordId);
        const custEvent = new CustomEvent(
            'callhandlecategorychange', {
                detail : {
                    currentCategory: this.currentCategory,
                    targetCategory: targetId,
                    questionnaireId: this.recordId

                }
            });
        this.dispatchEvent(custEvent);
        this.currentCategory = targetId;
        //Event - End
    }

    subCategoryChangeFunction(currentSubCat, targetSubCat, currTemplate, isSave){
        var currentCategoryClass = this.template.querySelector('[data-id='+currentSubCat+']').className;
        var targetCategoryClass = this.template.querySelector('[data-id='+targetSubCat+']').className;
        console.log('currentCategoryClass-->'+currentCategoryClass);
        console.log('targetCategoryClass--->'+targetCategoryClass);
        if(isSave == true){
            this.template.querySelector('[data-id='+currentSubCat+']').className='slds-path__item slds-is-complete';
            this.template.querySelector('[data-id='+targetSubCat+']').className='slds-path__item slds-is-current slds-is-active';
        }
        else{
            if(currentCategoryClass.includes('slds-is-complete')){
                this.template.querySelector('[data-id='+currentSubCat+']').className='slds-path__item slds-is-complete';
            }else{
                this.template.querySelector('[data-id='+currentSubCat+']').className='slds-path__item slds-is-incomplete';
            }

            if(targetCategoryClass.includes('slds-is-complete')){
                this.template.querySelector('[data-id='+targetSubCat+']').className='slds-path__item slds-is-complete slds-is-current slds-is-active';
            }else{
                this.template.querySelector('[data-id='+targetSubCat+']').className='slds-path__item slds-is-current slds-is-active';
            }
            
        }
        
    
        this.listOfPath.forEach(function(currData){
            if(currData.subCatId === currentSubCat){
                currTemplate.querySelector('[data-id='+currData.fieldSetName+']').className= 'slds-hide';
            }
            if(currData.subCatId === targetSubCat){
                currTemplate.querySelector('[data-id='+currData.fieldSetName+']').className= 'slds-show';
            }
        });

        this.currentSubCategory = targetSubCat;
        this.spinnerLoad(false);
    }
    handleSubCategoryChange(event){
        console.log('Sub Category is been changed');
        this.spinnerLoad(true);
        let targetId = event.currentTarget.dataset.id;
        let currSubCat = this.currentSubCategory;
        let currTemplate = this.template;
        this.subCategoryChangeFunction(currSubCat, targetId, currTemplate, false);
    }

    spinnerLoad(loadSpinner){
        //Event - Start
        console.log('Firing event for Spinner from Custom path lwc -->'+loadSpinner);
        const custEvent = new CustomEvent(
            'callhandlespinner', {
                detail: loadSpinner,
                bubbles : true,
                composed : true
            });
        this.dispatchEvent(custEvent);
        //Event - End 
    }

    handleFormLoaded(event){
        //console.log('Event handled from Parent Component');
    }

    handleFormSubmitSuccess(event){
        console.log('Form Submit function called from Parent--->'+this.currentSubCategory);
        console.log('Record id from the event--->'+event.detail);
        //Change by Chetan-Start
       //if(this.currentRecordId == null){
        this.recordId=event.detail;
        //this.currentRecordId = event.detail;
       // }
        //Change by Chetan-End
        console.log('Record Id from the event'+ this.currentRecordId);
        var listOfSubCategories=[];
        var currentSubCat = this.currentSubCategory;
        //Change by Chetan-Start
        var rId=this.recordId;
        //Change by Chetan-End
        var currIndex = 0; 
        let currTemplate = this.template;
        if(this.isOnlyCategory != 'true'){
            if(this.listOfPath.length > 0){
                for(let i=0; i<this.listOfPath.length; i++){
                    if(this.listOfPath[i].subCatId === currentSubCat){
                        currIndex = i;
                        break;
                    }
                }
                let targetSubCategory;
                if(currIndex+1 < this.listOfPath.length){
                    targetSubCategory = this.listOfPath[currIndex+1].subCatId;
                    this.subCategoryChangeFunction(currentSubCat, targetSubCategory, currTemplate, true);
                }else{
                    let currentCategory = this.category;
                    let currentCategoryId;
                    var currCatIndex = 0;
                    for(let i=0; i<this.listOfCategories.length; i++){
                        if(this.listOfCategories[i].cat === currentCategory){
                            currCatIndex = i;
                            currentCategoryId = this.listOfCategories[i].catId;
                        }
                    }
                    if(currCatIndex+1 < this.listOfCategories.length){
                        let targetCategory = this.listOfCategories[currCatIndex+1].catId;
                        //Event - Start
                        console.log(currentCategoryId+'------>targetCategory------>'+targetCategory);
                        let message = {
                            "currentCategory" : currentCategoryId,
                            "targetCategory"  : targetCategory
                        }
                        fireEvent(this.pageRef, 'categoryChangeFromSubCategory', message);
                        const custEvent = new CustomEvent(
                            'callhandlecategorychangeonsubmit', {
                                detail : {
                                    currentCategory: currentCategoryId,
                                    targetCategory: targetCategory,
                                    //Change by Chetan-Start
                                    rId: this.recordId
                                    //Change by Chetan-End
                                }
                            });
                        this.dispatchEvent(custEvent);
                        //Event - End

                    }
                }

                
            }
        }
        this.spinnerLoad(false);
    }
}