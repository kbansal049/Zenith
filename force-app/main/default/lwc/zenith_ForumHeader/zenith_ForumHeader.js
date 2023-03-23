import { LightningElement ,api, track} from 'lwc';
import zsResources from '@salesforce/resourceUrl/zScalarResources';
export default class Zenith_ForumHeader extends LightningElement {
    @api backgroundImageUrl;



    connectedCallback(){
       setTimeout(()=>{
        this.backgroundImageUrl =zsResources+this.backgroundImageUrl;
        console.log('test',this.backgroundImageUrl);
        let backgroundproperty = this.template.querySelector(".header");
        console.log('test',backgroundproperty);
       if(backgroundproperty){
        backgroundproperty.style.background = "url('" + this.backgroundImageUrl + "')"
       }
    }
    ,100)
    }
}