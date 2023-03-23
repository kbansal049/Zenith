public class TestUtility {
  static Integer s_num = 1;

   public static String getFakeId(Schema.SObjectType sot)
   {
      String result = String.valueOf(s_num++);
      return sot.getDescribe().getKeyPrefix() + 
         '0'.repeat(12-result.length()) + result;
   }

   public static User createUser(String profileName,String lastname) {
      User user = getUser(profileName,lastname);
      insert user;
      return user;
   }

   public static User getUser(String profileName,String lastname) {
      Profile profile = getProfile(profileName);

      User user = new user();
      user.LastName = lastname;
      user.Email = 'Test.gsfcd@test.com';
      user.Alias = 'Tcode';
      user.Username = 'Test.gsfcd@test.com';
      user.CommunityNickname = 'test1211';
      user.LocaleSidKey = 'en_US';
      user.TimeZoneSidKey = 'GMT';
      user.ProfileID = profile.id;
      user.LanguageLocaleKey = 'en_US';
      user.EmailEncodingKey = 'UTF-8';

      return user;
   }

   private static Profile getProfile(String profileName) {
      return [SELECT Id FROM Profile WHERE Name = :profileName Limit 1];
   }
}