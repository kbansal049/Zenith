import { LightningElement, api } from 'lwc';

export default class MeetingDurationSelectComponentLWC extends LightningElement {
    @api selectedDuration='60';
    times = ['120','90','60', '45','30'];
    
    handleClick(event){
        let currTarget = event.currentTarget.dataset.id;
        for(var i=0; i<this.times.length; i++){
            let target = this.template.querySelector(`[data-id="${this.times[i]}"]`);
            if(currTarget == this.times[i]){
                target.classList.add('slds-theme_success');
                target.classList.remove('slds-theme_alert-texture');
                target.classList.remove('.slds-theme_shade');
            }
            else{
                target.classList.remove('slds-theme_success');
                target.classList.add('slds-theme_alert-texture');
                target.classList.remove('.slds-theme_shade');
            }
        }
        this.selectedDuration = currTarget;
        console.log('Selected Duration-->'+this.selectedDuration);

    }

    handleHover(event){
        let currTarget = event.currentTarget.dataset.id;
        let target = this.template.querySelector(`[data-id="${currTarget}"]`);
        target.classList.add('.slds-theme_shade');
        target.classList.remove('slds-theme_alert-texture');
        target.classList.remove('slds-theme_success');
    }

    handleMouseOut(event){
        let currTarget = event.currentTarget.dataset.id;
        let target = this.template.querySelector(`[data-id="${currTarget}"]`);
        if(this.selectedDuration == currTarget){
            target.classList.add('slds-theme_success');
            target.classList.remove('slds-theme_alert-texture');
            target.classList.remove('.slds-theme_shade');
        }else{
            target.classList.remove('slds-theme_success');
            target.classList.add('slds-theme_alert-texture');
            target.classList.remove('.slds-theme_shade');
        }
    }

}