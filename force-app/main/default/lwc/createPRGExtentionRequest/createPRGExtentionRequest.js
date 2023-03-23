import { LightningElement,track , wire ,api } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import extendPGMethod from '@salesforce/apex/ManageProvisioningController.extendPGMethod';
import getEndDateAndApprovalStatusForPG from '@salesforce/apex/ManageProvisioningController.getEndDateAndApprovalStatusForPG';
import getPRGStatus  from '@salesforce/apex/ManageProvisioningController.getPRGStatus';
import { CloseActionScreenEvent } from 'lightning/actions';



export default class CreatePRGExtentionRequest extends LightningElement {
    @api recordId;
    @track extensionReason = '';
    @track endDateValue;
    @track isPrExtBtnDisabled = true;
    @track pgid;
    @track prginApproval;
    @track prgisprovisioned;


 @wire(CurrentPageReference)
getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
        this.pgid=this.recordId;
        console.log('record id--->'+this.recordId);
        if(this.recordId!=null){
            this.checkifPRGisProvisioned(this.recordId);
            this.checkPGEndDate(this.recordId);
        }
    }
}
closeAction(){
  this.dispatchEvent(new CloseActionScreenEvent());
}

checkifPRGisProvisioned(pgId){
    getPRGStatus({pgId:pgId}).then(result=>{
        if(result==true){
            this.prgisprovisioned=true;
        }else{
            this.prgisprovisioned=false;
        }
    })
}
    

 checkPGEndDate(pgId){
        let ApprovalStatus='';
        getEndDateAndApprovalStatusForPG({pgId:pgId})
            .then(result=>{
                console.log('getEndDateAndApprovalStatusForPG',result);
                for (let value of Object.keys(result)) {
                    this.endDateValue = value;
                }
                for (let value of Object.values(result)) {
                    ApprovalStatus =value;
                }
                if(ApprovalStatus=='Submitted'){
                   // this.showToastMessage('error',('Extension Request is pending for Approval'));
                    this.prginApproval=true;
                    this.error=true;
                    return;
                }else{
                    this.prginApproval=false;
                  

                }
                return  this.endDateValue;
            }).catch(error => {
                this.error = error;
                this.hasError = true;
               // this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
            });
    }

       showToastMessage(type, errMsg) {
        this.template.querySelector('c-custom-toast-component').showToast(type, errMsg);
    }


 handleExtensionReason(event){
        this.extensionReason = event.detail.value;
        if(this.extensionReason === null || this.extensionReason === '' || this.extensionReason.length === 0){
            this.isPrExtBtnDisabled = true;
        }else{
            this.isPrExtBtnDisabled = false;
        }   
    }

     @track isPrExtSpinnerLoading = false;
    saveExtension(){
        if(this.extensionReason == null || this.extensionReason == ''){
            this.showToastMessage('error', ('Please provide extension reason.'));
            this.error = true;
            return;
        }else{
            this.isPrExtSpinnerLoading = true;
            extendPGMethod({pgId: this.pgid, extensionReason: this.extensionReason})
                .then(result => {
                    if(result == true){
                       this.showToastMessage('success', ('Provisioning Group extended successfully.'));
                       setTimeout(() => {this.closeAction();
                    }, 2000);
                    setTimeout(() => { location.reload();
                    }, 3000);

                    

                        
                    }else{
                        this.showToastMessage('info', ('Provisioning Group submitted for extension.'));
                        setTimeout(() => {this.closeAction();}, 2000);
                        setTimeout(() => { location.reload();
                        }, 3000);

                       

                       
                    }
                    this.isPrExtSpinnerLoading = false;
                }).catch(error => {
                    this.error = error;
                    this.hasError = true;
                    this.isPrExtSpinnerLoading = false;
                   // this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
                });
        }
    }

   

}