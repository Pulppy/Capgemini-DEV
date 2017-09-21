public class Communitymainheader {
  @AuraEnabled
  public static User getUserName() {
    Id userId = UserInfo.getUserId();
    return [SELECT Id, Name, Address, Email, MobilePhone FROM User WHERE Id = :userId].get(0);
  }
}