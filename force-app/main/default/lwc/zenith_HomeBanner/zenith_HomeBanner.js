import { LightningElement, api } from 'lwc';
import zenithResources from '@salesforce/resourceUrl/zScalarResources';
export default class Zenith_HomeBanner extends LightningElement {


    @api bannerText = 'This is to test the banner made in community for announcement purpose';
    @api backgroundColor;
    @api TextColor;
    @api readmore;
    @api showBanner = false;
    @api showBannerIcon=false;
    otherURL='';
    announcementIcon = zenithResources + '/zScalarResources/images/Group.png';



    renderedCallback(){
        this.template.querySelector('.banner').style.background = this.backgroundColor;
        this.template.querySelector('.TextColor').style.color = this.TextColor;
        this.template.querySelector('.readmoreurl').style.color = this.TextColor;
       if(!this.readmore.includes('http') || !this.readmore.includes('https')){
           this.otherURL='https://'+this.readmore;
       }
       else{
           this.otherURL=this.readmore;
       }
    }

    navigateToSite(event){
       
         window.open(this.otherURL)
       
    }

}