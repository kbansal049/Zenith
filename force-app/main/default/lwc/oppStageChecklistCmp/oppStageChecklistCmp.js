import { LightningElement, track, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getRecordNotifyChange, updateRecord,getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import fetchOpp from '@salesforce/apex/OppStageChecklistController.fetchDetails';
import updateStage from '@salesforce/apex/OppStageChecklistController.updateOpportunityStage';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';
const FIELDS = ['Opportunity.Name', 'Opportunity.StageName'];

export default class OppStageChecklistCmp extends NavigationMixin(LightningElement) {
  @api recordId;
  @track requiredFields = [];
  @track optionalFields = [];
  @track error;
  @track hasError;
  @track loading = false;
  @track allowPermissionOverride;
  @track prevStageValue;
  @track nextStageValue;
  @track displayRegress = false;
  @track isLoading = true;
  @track disabledFlag = true;
  @track recordTypeId;
  @track fieldName;
  @track modalWindow;
  @track fieldLabel;
  @track fieldType;
  @track isRequiredFulfilled = false;
  @track stageDescription;
  @track actorsInvolved;
  @track lastChangedDate;
  @track ownerName;
  @track createdByName;
  @track forecastCategory;
  @track daysinCurrentStage;
  @track importantLinks;
  @track fileName;
  @track fileId;
  @track fieldVal;
  @track allowedValues;
  @track errMsg;
  @track dependentFieldNames;
  @track allowStageUpdates;
  @track hideClosedLost = false;
  @track stageVal;
  @track disableClosed = true;
  @track disablePrevious = true;
  @track editWindow = false;
  wiredData;opportunity;
  
  @track headerInfo;
  
  activeTab = '1';

  @wire(getRecord, {
      recordId: "$recordId",
      fields: [STAGE_FIELD]
  })
  opportunity;

  @wire(getRecord, {
      recordId: '$recordId',
      fields: FIELDS,
      modes: ['View', 'Edit', 'Create']
  })

  wiredRecord({
      error,
      data
  }) {
      if (error) {
      }
      else if (data) {
          this.isLoading = true;
          refreshApex(this.wiredData);
      }
  }

  updateRecordView(recordId) {
      updateRecord({
          fields: {
              Id: recordId
          }
      });
  }


  handleRemove(event) {
      var index = event.currentTarget.dataset.id;
      //this.loadedFiles.splice(index, 1);
  }

  @wire(fetchOpp, {
      opportunityId: '$recordId'
  })
  getDetails(wireResult) {
      this.isLoading = true;
      const {
          data,
          error
      } = wireResult;
      this.wiredData = wireResult;
      if (data) {

          this.requiredFields = data.requiredFields;
          this.optionalFields = data.optionalFields;
          this.isRequiredFulfilled = data.isRequiredFulfilled;
          console.log('--this.isRequiredFulfilled--' + this.isRequiredFulfilled);
          this.stageDescription = data.stageDescription;
          this.actorsInvolved = data.actorsInvolved;
          if (data.allowPermissionOverride == true)
              this.disabledFlag = false;
          else
              this.disabledFlag = true;
          this.nextStageValue = data.nextStageValue;
          this.headerInfo = data.headerInfo;
          if (this.isRequiredFulfilled == true) {
              //this.headerInfo = this.headerInfo.replace("one step closer", "now ready to move");
          }
          this.prevStageValue = data.prevStageValue;
          this.opp = data.opp;
          this.createdByName = data.createdByName;
          this.ownerName = data.ownerName;
          this.importantLinks = data.importantLinks;
          this.forecastCategory = data.forecastCategory;
          this.daysinCurrentStage = data.daysinCurrentStage;
          this.lastChangedDate = data.lastChangedDate;
          this.recordTypeId = data.recordTypeId;
          if (data.prevStageValue != null && data.prevStageValue != '') {
              this.displayRegress = true;
          }
          else {
              this.displayRegress = false;
          }
          this.isLoading = false;
          this.allowStageUpdates = data.allowStageUpdates;

          if(data.allowStageUpdates == false && data.allowPermissionOverride == false){
              this.disabledFlag = true;
              this.disablePrevious = true;
          }else if((data.allowStageUpdates == true && this.isRequiredFulfilled) || data.allowPermissionOverride){
            this.disabledFlag = false;
            this.disablePrevious = false;
          }else if(data.allowStageUpdates){
              this.disablePrevious = false;
          }
          
          if(data.allowClosure || data.allowPermissionOverride){
              console.log('data--->',data);
              console.log('data.loggedInProfile.Name--->',data.loggedInProfile.Name);
            if(data.loggedInProfile.Name == 'Core Sales - Federal'){
                if(data.ownerName == data.loginUserDetails.Name){
                  this.disableClosed = false;
                }else if(data.oppTeamMembers.length > 0){
                    let isDisable = true;
                    data.oppTeamMembers.forEach(function(elem){
                        if(elem.Name == data.loginUserDetails.Name){
                            if(elem.OpportunityAccessLevel == 'All' || elem.OpportunityAccessLevel == 'Edit'){
                                isDisable = false;
                            }
                        }
                    });
                  this.disableClosed = isDisable;
                }else{
                    this.disableClosed = true;
                }
                
            }else{
                this.disableClosed = false;
            }
          }else{
            this.disableClosed = true;
          }

          
          console.log('--this.allowStageUpdates--', this.allowStageUpdates);
          console.log('--data.allowPermissionOverride--', data.allowPermissionOverride);
          console.log('--disableClosed--', this.disableClosed);
          console.log('--disabledFlag--', this.disabledFlag);
      }
      else if (error) {
          this.error = error;
          this.hasError = true;
          this.loading = false;
          console.log('error', error);
          if (error.body.message) {
              const event = new ShowToastEvent({
                  title: 'Some unexpected error',
                  message: error.body.message,
                  variant: 'error',
                  mode: 'dismissable'
              });
              this.dispatchEvent(event);
          }
          this.isLoading = false;
      }
  }


  get requiredFieldsCustom(){
      let reqFields = []
      if(this.requiredFields){
        this.requiredFields.forEach(ci => {
          let cuItem = {...ci}; 
          if(ci.fieldType == 'CURRENCY'){
            cuItem.isNumberType = true;
          }else{
            cuItem.isNumberType = false;
          }
          reqFields.push(cuItem);
        });
      }
      return reqFields;
  }


  get ShowClosedLostButton() {
      this.stageVal = getFieldValue(this.opportunity.data, STAGE_FIELD);
      console.log('--stageVal--' + this.stageVal);
      return this.stageVal != undefined && this.stageVal.includes('Closed') == true ? false : true;
  }

  // JS functions start 
  handleActive(event) {
      this.activeTab = event.target.value;
  }

  previewFile(event) {
      let filerecordID = event.target.dataset.id;
      console.log('--filerecordID' + filerecordID);
      this[NavigationMixin.Navigate]({
          type: 'standard__namedPage',
          attributes: {
              pageName: 'filePreview'
          },
          state: {
              
              selectedRecordId: filerecordID
          }
      });
  }

  progressStage(event) {
      this.isLoading = true;
      updateStage({
              opportunityId: this.recordId,
              stageValue: this.nextStageValue
          })
          .then((result) => {

              this.allowPermissionOverride = false;
              const event = new ShowToastEvent({
                  title: 'Opportunity moved to next stage',
                  message: 'Opportunity is moved to next stage',
                  variant: 'success',
                  mode: 'dismissable'
              });
              this.dispatchEvent(event);
              //eval("$A.get('e.force:refreshView').fire();");
              refreshApex(this.wiredData);
              this.updateRecordView(this.recordId);


          })
          .catch((error) => {
              this.error = error;
              this.hasError = true;
              this.loading = false;
              console.log('error', error);
              const event = new ShowToastEvent({
                  title: 'Some unexpected error',
                  message: error,
                  variant: 'error',
                  mode: 'dismissable'
              });
              this.dispatchEvent(event);
              this.isLoading = false;
          });

  }

  regressStage(event) {
      this.isLoading = true;
      updateStage({
              opportunityId: this.recordId,
              stageValue: this.prevStageValue
          })
          .then((result) => {
              this.allowPermissionOverride = false;
              const event = new ShowToastEvent({
                  title: 'Opportunity moved to Prev stage',
                  message: 'Opportunity is moved to Prev stage',
                  variant: 'success',
                  mode: 'dismissable'
              });
              this.dispatchEvent(event);
              //eval("$A.get('e.force:refreshView').fire();");
              refreshApex(this.wiredData);
              this.updateRecordView(this.recordId);

          })
          .catch((error) => {
              this.error = error;
              this.hasError = true;
              this.loading = false;
              console.log('error', error);
              const event = new ShowToastEvent({
                  title: 'Some unexpected error',
                  message: error,
                  variant: 'error',
                  mode: 'dismissable'
              });
              this.dispatchEvent(event);
              this.isLoading = false;
          });

  }

  redirectToRecord(event) {
      let objectAPIName = event.currentTarget.dataset.name;;
      let recordID = event.currentTarget.dataset.id;;
      console.log('--objectAPIName--' + objectAPIName);
      if (objectAPIName && recordID && objectAPIName != 'Object') {
          this[NavigationMixin.Navigate]({
              type: "standard__recordPage",
              attributes: {
                  recordId: recordID,
                  objectApiName: objectAPIName,
                  actionName: 'view'
              }
          });
      }
      else if (recordID) {
          const config = {
              type: 'standard__webPage',
              attributes: {
                  url: recordID
              }
          };
          this[NavigationMixin.Navigate](config);

      }
      else if (objectAPIName && objectAPIName != 'Object') {
          this[NavigationMixin.Navigate]({
              type: "standard__objectPage",
              attributes: {
                  objectApiName: objectAPIName,
                  actionName: "new"
              },
          });
      }
  }

  handleChildMessage(event) {
      this.modalWindow = false;
      this.isLoading = true;
      this.editWindow = false;
      refreshApex(this.wiredData);

  }

  handleChildClose(event) {
      this.modalWindow = false;
      this.editWindow = false;
      this.updateRecordView(this.recordId);
     
  }

  openModal(event) {
      this.fieldName = event.currentTarget.dataset.name;
      this.fieldLabel = event.currentTarget.dataset.id;
      this.fieldType = event.currentTarget.dataset.label;
      this.fileName = event.currentTarget.dataset.fileName;
      this.fileId = event.currentTarget.dataset.fileId;
      this.fieldVal = event.currentTarget.dataset.value;
      this.errMsg = event.currentTarget.dataset.errMsg;
      this.allowedValues = event.currentTarget.dataset.allowedValues;
      this.dependentFieldNames = event.currentTarget.dataset.dependentFields;

      console.log(JSON.stringify(event.currentTarget.dataset));
      this.isLoading = false;
      this.modalWindow = true;
      console.log('this.fieldName' + this.fieldName);
      console.log('this.fieldLabel' + this.fieldLabel);
  }

  openEditModal(event) {
   
    this.isLoading = false;
    this.editWindow = true;
   
}

}