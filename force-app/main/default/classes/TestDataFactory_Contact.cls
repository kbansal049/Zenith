/*****************************************************************************************
Name: TestDataFactory_Contact
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Contact.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Ayush Kangar       25/01/2023      IBA-6050      
******************************************************************************************/
@isTest
public class TestDataFactory_Contact {
    public static list<Contact> insertContact(Integer count, Boolean performDml,string accountId){        
        List<Contact> contactList = new List<Contact>();
        for(Integer loopVar = 0; loopVar < count; loopVar++)
        {
            Contact con = new Contact(); 
            con.LastName = 'ZS Test Contact '+loopVar;
            con.accountId = accountId;
            contactList.add(con);
        }
        if(performDml)
        {
            insert contactList;
        }
        return contactList;
    }  
}