import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case_Object from '@salesforce/schema/Case';

import callComplaintPatch from '@salesforce/apex/CaseIntegrationHandler.callComplaintPatchForSiemens';

const casefieldstoQuery = ['Case.RecordTypeId'];

export default class CaseStatusUpdateComponent extends LightningElement {
@api recordId;
@track showCaseDetails;
@track loading = false;
@track objectInfo;
@track showcommentmandatorymessage = false;
@track errmsg = '';
@track recordTypeId;
@track loadData = false;
saveClicked = false;
@track showClosureNotes=false;
@track closureNotes ='';

@wire(getObjectInfo, { objectApiName: Case_Object })
objectInfo;

/*get recordTypeId() {
    // Returns a map of record type Ids 
    if (this.objectInfo && this.objectInfo.data && this.objectInfo.data.recordTypeInfos) {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Support');
    }
}*/

@wire(getRecord, { recordId: '$recordId', fields: casefieldstoQuery })
wirecontact({ error, data }) {
    if (error) {
        console.log(error);
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading Case Details',
                message,
                variant: 'error',
            }),
        );
    } else if (data) {
        console.log(data);
        if (data.fields.RecordTypeId.value) {
            this.recordTypeId = data.fields.RecordTypeId.value;
            this.loadData = true;
            console.log(this.loadData);
        }
    }
}

handleload(event) {
    if (!this.saveClicked && !this.showClosureNotes) {
        console.log('inside handleload');
        this.cancelCase();
    }
}

savecase(event) {
    this.saveClicked = true;
    console.log('inside save case');
    this.errmsg = '';
    if (!this.template.querySelector('.Customer_Temperature__c').value) {
        this.errmsg += 'Customer Temperature'
    }
    if (!this.template.querySelector('.Escalation_Stage__c').value) {
        if (this.errmsg) {
            this.errmsg += ', ';
        }
        this.errmsg += 'Escalation Stage'
    }
    if (!this.template.querySelector('.Escalation_Resolution_Notes__c').value) {
        if (this.errmsg) {
            this.errmsg += ', ';
        }
        this.errmsg += 'Escalation Progress Notes'
    }
    if(this.showClosureNotes){
        if (!this.template.querySelector('.Escalation_Closure_Notes__c').value || this.template.querySelector('.Escalation_Closure_Notes__c').value.replace( /(<([^>]+)>)/ig, '').trim() =='') {
            if (this.errmsg) {
                this.errmsg += ', ';
            }
            this.errmsg += 'Escalation Closure Notes'
        }
    }

    if (this.errmsg) {
        this.errmsg = 'Please fill the following fields: ' + this.errmsg;
        this.showcommentmandatorymessage = true;
        return;
    }
    this.showcommentmandatorymessage = false;
    this.errmsg = '';
    this.loading = true;
    this.template.querySelector('lightning-record-edit-form').submit();

}

handleSuccess(event) {
    console.log('inside handle success');
    const updatedRecord = event.detail.id;
    this.showtoast('Save is Successful');
    this.cancelCase();
    this.handleCaseIntegrationPatch();
}
showtoast(mes) {
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Save Successful!',
            mes,
            variant: 'success',
        }),
    );
}


handleCaseIntegrationPatch() {
    callComplaintPatch({ recId: this.recordId })
        .then(result => {
        })
        .catch(error => {
            this.errmsg = 'Error occurred while calling the Patch for Siemens: ' + error;
        });
}


cancelCase() {
    this.loading = false;
    this.errmsg = '';
    this.showcommentmandatorymessage = false;
    console.log('inside cancel case new ');
    const esstage = this.template.querySelectorAll(
        '.Escalation_Stage__c'
    );
    if (esstage) {
        esstage.forEach(field => {
            field.value = '';
        });
    }
    const custtemp = this.template.querySelectorAll(
        '.Customer_Temperature__c'
    );
    if (custtemp) {
        custtemp.forEach(field => {
            field.value = '';
        });
    }
    const resol = this.template.querySelectorAll(
        '.Escalation_Resolution_Notes__c'
    );
    if (resol) {
        resol.forEach(field => {
            field.value = '';
        });
    }

    const reason = this.template.querySelectorAll(
        '.Escalation_Reason_New_n__c'
    );
    if (reason) {
        reason.forEach(field => {
            field.value = '';
        });
    }

}
statuschange(event) {
    if (event.detail.value == 'Closed') {
        console.log('Inside Close change');
        this.showClosureNotes = true;
    } else {
        this.showClosureNotes = false;
    }
    this.errmsg='';
    this.showcommentmandatorymessage=false;
}
}