import { LightningElement } from 'lwc';
import getMoreRecords from '@salesforce/apex/Zenith_CategoryController.getMoreRecords'
import checkAccess from '@salesforce/apex/Zenith_CategoryController.checkAccess';
import { NavigationMixin } from 'lightning/navigation';
export default class Zenith_CategoryLWC extends NavigationMixin(LightningElement) {

    categorySubCategoryData;
    showMoreRecords = true;
    totalRecords = 0;
    offsetLimit = 0;


    connectedCallback() {
        this.queryApexData();
    }



    queryApexData() {
        getMoreRecords({ offsetVal: this.offsetLimit }).then((result) => {

            this.totalRecords = result[0].totalRecords;
            this.categorySubCategoryData = result;

        }).catch((error) => {
            console.log('error in queyr apex data more', error)
        })
    }



    handleMoreCategories() {
        this.offsetLimit = this.offsetLimit + 3;
        getMoreRecords({ offsetVal: this.offsetLimit }).then((result) => {
            if (result.length > 0) {
                this.categorySubCategoryData = [...this.categorySubCategoryData, ...result];

                if (this.categorySubCategoryData.length >= this.totalRecords) {
                    this.showMoreRecords = false;
                }

            }
            else {

                this.template.querySelector('[data-name="viewMore"]').classList.add('hide')
            }
        }).catch((error) => {
            console.log('error in handle more', error)
        })
    }


    handleSubCategoryClick(event) {

        console.log('Id from child ', event.currentTarget.dataset.id);
        let currentSubCategoryId = event.currentTarget.dataset.id;
        checkAccess({ subCategoryId: currentSubCategoryId }).then((result) => {
            console.log('Result coming from subCategoryclick ', result)
            // If Result is true, redirect to no access page
            //Else if result is false, redirect to standard page
        })
            .catch((error) => {
                console.log('Error in sub category access ', error);
            })

    }


    handleSeeAll(event) {

        console.log('data id ', event.currentTarget.dataset.id)
        console.log('data name ', event.currentTarget.dataset.name)
        let currentGroupId = event.currentTarget.dataset.id;
        let currentGroupName = event.currentTarget.dataset.name;
        let category = {
            id: currentGroupId,
            name: currentGroupName
        };

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: category.id,
                actionName: 'view'
            },
            state: {
                category: JSON.stringify(category)
            }
        });

    }

}