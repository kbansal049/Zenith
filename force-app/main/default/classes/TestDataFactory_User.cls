/*****************************************************************************************
Name: TestDataFactory_User
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test User.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Ayush Kangar       25/01/2023      IBA-6050      
******************************************************************************************/
@isTest
public class TestDataFactory_User {
    public static List<User> createUsers(Integer count, Boolean performDml, String profileName,
                                         String firstName, String lastName, String email)
    {
        List<User> users = new List<User>();
        Profile p = [SELECT ID FROM Profile WHERE Name = :profileName];
        for(Integer loopVar = 0; loopVar < count; loopVar++) {
            User u = new User();
            u.FirstName = firstName;
            u.LastName = lastName;
            u.ProfileId = p.Id;
            u.Email = email;
            u.Alias = 'ZSUsr'+loopVar;
            u.Username = removeAllWhitespace(firstName)+removeAllWhitespace(lastName)+loopVar+'@test.com';
            u.CommunityNickname = 'ZSUsr'+lastName+loopVar;
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            users.add(u);
        }
        if(performDml)
        {
            insert users;
        }
        return users;
    }
    
    public static String removeAllWhitespace(String s)
    {
        if(String.isNotBlank(s))
        {
            return s.replaceAll('(\\s+)', '');
        }
        return s;
    }
}