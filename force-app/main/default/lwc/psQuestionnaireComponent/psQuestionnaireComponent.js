import { api, LightningElement, track, wire } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';


export default class PsQuestionnaireComponent extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api questionnaireId;
    @api recordTypeId;
    @api opportunityId;
    @api projectId;

    @track showSpinner = true;
    
    @track currentMainCategory;
    @track targetMainCategory;

    //Category render property - Start
    @track customerInfo = true;
    @track showCustomerInfra;
    @track showTrafficForwarding;
    @track showAuthentication;
    @track showPolicies;
    @track showLogging;
    @track showQuestionnaireStatus;
    @track showZpaPoc;
    //Category render property - End

    
    hideSpinner(){
        this.showSpinner = false;
    }

    handleFormLoaded(event){
        //console.log('Handle form loaded called from grand parents --->'+event.detail);
        this.showSpinner = event.detail;
    }
    handleRecordId(event)
    {
        console.log('handleRecordId Questionnaire id before assignment '+ event.detail);
        this.questionnaireId=event.detail;
    }
    handleMainCategoryChange(event){
        console.log('currentCategory Parent --->'+event.detail.currentCategory);
        console.log('targetCategory Parent--->'+event.detail.targetCategory);
        //console.log('Record Id from event'+event.detail.rId);
        
        //this.showSpinner = true;
        console.log('Questionnaire Id'+this.questionnaireId);
        let currentCategory = event.detail.currentCategory;
        let targetCategory = event.detail.targetCategory;
        if(currentCategory == 'customer-info'){
            this.customerInfo = false;
        }
        else if(currentCategory == 'customer-infra'){
            this.showCustomerInfra = false;
        }
        else if(currentCategory == 'traffic-forward'){
            this.showTrafficForwarding = false;
        }
        else if(currentCategory == 'authentication'){
            this.showAuthentication = false;
        }
        else if(currentCategory == 'zpa-poc'){
            this.showZpaPoc = false;
        }
        else if(currentCategory == 'policies'){
            this.showPolicies = false;
        }
        else if(currentCategory == 'logging'){
            this.showLogging = false;
        }
        else if(currentCategory == 'status'){
            this.showQuestionnaireStatus = false;
        }

        if(targetCategory == 'customer-info'){
            this.customerInfo = true;
        }
        else if(targetCategory == 'customer-infra'){
            this.showCustomerInfra = true;
        }
        else if(targetCategory == 'traffic-forward'){
            this.showTrafficForwarding = true;
        }
        else if(targetCategory == 'authentication'){
            this.showAuthentication = true;
        }
        else if(targetCategory == 'zpa-poc'){
            this.showZpaPoc = true;
        }
        else if(targetCategory == 'policies'){
            this.showPolicies = true;
        }
        else if(targetCategory == 'logging'){
            this.showLogging = true;
        }
        else if(targetCategory == 'status'){
            this.showQuestionnaireStatus = true;
        }
        this.showSpinner = false;
        this.currentMainCategory = currentCategory
        this.targetMainCategory = targetCategory;
        //Change by Chetan-Start
        this.questionnaireId=event.detail.questionnaireId;
        console.log('QuestionnaireId after assignment'+ this.questionnaireId);
        //Change by Chetan-End
    }

    handleSubmit(event){
        this.showSpinner = true;
    }
    handleSuccess(event){
        this.showSpinner = false;
        if(this.questionnaireId){
            window.open("/"+this.questionnaireId,'_top');
        }
        else if(this.projectId){
            window.open("/"+this.projectId,'_top');
        }
        else if(this.opportunityId){
            window.open("/"+this.opportunityId,'_top');
        }
    }

    handleExit(event){
        if(this.questionnaireId){
            window.open("/"+this.questionnaireId,'_top');
        }
        else if(this.projectId){
            window.open("/"+this.projectId,'_top');
        }
        else if(this.opportunityId){
            window.open("/"+this.opportunityId,'_top');
        }
    }
}