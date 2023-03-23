({
	// Your renderer method overrides go here
	afterRender: function(component, helper){
    	this.superAfterRender();
        var imgUrl = $A.get('$Resource.zScalarResources') + '/zScalarResources/images/HomeBanner1.jpg';
        console.log('urllllll ----> ', imgUrl);
        console.log("columnDiv: ", component.find("columnDiv").getElements()[0]);
        component.find('columnDiv').getElements()[0].style.background= 'url('+imgUrl+')';
        component.find('columnDiv').getElements()[0].style.height= '330px';
        component.find('columnDiv').getElements()[0].style.width= 'auto';
        //component.find('columnDiv').getElements()[0].style.backgroundRepeat= 'round';
	}
})