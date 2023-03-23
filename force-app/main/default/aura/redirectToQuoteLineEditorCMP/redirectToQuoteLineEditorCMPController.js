({    
    invoke : function(component, event, helper) {

        const recId = component.get("v.recordId");        
        //IBA-6578 - start
        let link =  '/apex/sbqq__sb?id=' + recId;
        
        let pageReference = {
            type: 'standard__webPage',
            attributes: { url: link }
        };
        
        console.log(pageReference);
        
        let navService = component.find("navService");
        navService.navigate(pageReference);
        //IBA-6578 - end
    }
})