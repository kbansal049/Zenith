({

	doInit : function(component,event,helper)
	{
		   if( $A.get("$SObjectType.CurrentUser.Id") != undefined)
	{
		component.set("v.guestUser",false);
	}
	else
	{
		component.set("v.guestUser",true);

	}  
	  
	},

	clickLogin : function(component, event, helper) {
        
         var url ='/s/login';
        var action = $A.get('e.force:navigateToURL');
        action.setParams({
            'url': url
        });
        action.fire();
		
	},
    clickHome : function(component, event, helper) {
        
         var url ='/s';
        var action = $A.get('e.force:navigateToURL');
        action.setParams({
            'url': url
        });
        action.fire();
		
	},
    
    clickSignup : function(component, event, helper) {
                 var url ='/s/CommunitiesSelfRegister';
        var action = $A.get('e.force:navigateToURL');
        action.setParams({
            'url': url
        });
        action.fire();
		
	}
 
})