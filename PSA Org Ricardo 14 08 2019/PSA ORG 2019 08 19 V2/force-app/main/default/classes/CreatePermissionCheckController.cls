public class CreatePermissionCheckController {
    
    @AuraEnabled
    public static boolean isRecInsertable() {
        Id userId = UserInfo.getUserId();
        User u = [SELECT Country__c FROM User WHERE Id = :userId];
        
        if (null != u && u.Country__c == 'PL') {
            return false;
        }
        
        return true;
    }    

}