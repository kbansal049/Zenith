import { api, LightningElement } from 'lwc';
import zenith_banner from '@salesforce/resourceUrl/zScalarResources';
import { NavigationMixin } from 'lightning/navigation';
import baseUrl from '@salesforce/label/c.Community_Base_Url';
export default class Zenith_SearchCompnentLWC extends NavigationMixin(LightningElement) {   
    
    image=zenith_banner+'/zScalarResources/images/zenith_Banner.png';

    updateImageBanner=zenith_banner+'/zScalarResources/images/HomeBanner1.jpg';

    searchTerm = '';
    renderedCallback(){
    //    this.template.querySelector('.container').style.background='url('+this.image+')';
        this.template.querySelector('.container').style.background='url('+this.updateImageBanner+')';
    }


    searchOnChangeHandler(event){
        console.log('input box text ---> ', event.target.value);
        this.searchTerm = event.target.value;
    }

    buttonClickHandler(){
        console.log('Search Button clicked');
        this.navigateToSearch();
    }

    navigateToSearch(){
        console.log('Inside Navigation');
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Search',
                // url : baseUrl + 'global-search/' + this.searchTerm
                // url : '/global-search/' + this.searchTerm
            },
            state: {
                term : this.searchTerm
            }
        })
    }
        
}