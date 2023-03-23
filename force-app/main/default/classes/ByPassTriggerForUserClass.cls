public with sharing class ByPassTriggerForUserClass 
{
    public static  Map<String, By_Pass_Trigger_For_User__mdt> triggersMap= new Map<String, By_Pass_Trigger_For_User__mdt>();
    //Retieve Custom Settings to store name of trigger,object name,By Pass status
    public static List <By_Pass_Trigger_For_User__mdt> bypasstrigger = By_Pass_Trigger_For_User__mdt.getAll().values();
    
    public static Boolean userCustomMap(String objectName)
    {        
        Boolean flag = FALSE;
        String bypassForAllObjectsStr = 'All';//Using 'All' we can bypass trigger for all objects
        if(triggersMap.size() == 0)
        {
            for (By_Pass_Trigger_For_User__mdt objbypass: bypasstrigger) {
                // To accommodate bypass for mulit users 
                triggersMap.put(objbypass.Object_Name__c + objbypass.User_Name__c ,objbypass);
            }
        }        
        if(triggersMap != null)
        {
            if(triggersMap.containsKey(objectName+UserInfo.getUserName()))
            {
                By_Pass_Trigger_For_User__mdt checkByPass = triggersMap.get(objectname+UserInfo.getUserName());
                if(checkByPass.User_Name__c == UserInfo.getUserName() && checkByPass.Deactivate_Components__c == TRUE)
                {
                    flag = TRUE;
                }
            }
            //Using 'All' we can bypass trigger for all objects, bypassForAllObjectsStr
            if(triggersMap.containsKey(bypassForAllObjectsStr+UserInfo.getUserName()))
            {
                By_Pass_Trigger_For_User__mdt checkByPass = triggersMap.get(bypassForAllObjectsStr+UserInfo.getUserName());
                if(checkByPass.User_Name__c == UserInfo.getUserName() && checkByPass.Deactivate_Components__c == TRUE)
                {
                    flag = TRUE;
                }
            }
        }
        return flag;
    }    
}