import { LightningElement ,wire,api} from 'lwc';
import getFeaturedList from '@salesforce/apex/zenith_FeaturedContentClass.getFeaturedList'
import zenithResources from '@salesforce/resourceUrl/zScalarResources';

export default class Zenith_FeaturedContentLWC extends LightningElement {
    recordData = []; 
    imgurl;
    announcementIcon = zenithResources + '/zScalarResources/images/HomeBanner1.jpg';
    iconright = zenithResources + '/zScalarResources/images/featurePRe.png';
    iconleft = zenithResources + '/zScalarResources/images/featureNext.png';

    @wire(getFeaturedList)
    wiredRecords({ error, data }) {
        if (data) {
            console.log('featured content',data);
            this.recordData=data;           
        } else if (error) {
            console.error(error);
            this.recordData=null;
        }
        console.log('featured content12',this.recordData2);
    }
  
  //Carasouel Controls
  handleNextNew() {
    console.log('next');
    this.template.querySelector(`[data-name="containerrecod"]`).scrollLeft += 280;
  }
  handlePrevNew(){
     console.log('pre');
    this.template.querySelector(`[data-name="containerrecod"]`).scrollLeft -= 280;
  }
  handleClick(event){
    if(event.target.dataset.id)
    this.imgurl=event.target.dataset.id;
     if(!this.imgurl.includes('http') || !this.imgurl.includes('https')){
           this.imgurl='https://'+this.imgurl;
       }
       else{
           this.imgurl=this.imgurl;
       }
        window.open(this.imgurl)
  }
}