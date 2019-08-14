public without sharing class LeadManualAssignment {

    @AuraEnabled 
    public static Map<String, Object> getUserData(){
        Map<String, Object> res = new Map<String, Object>();

        List<User> lst = [
            SELECT Id, Profile.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        res.put('payload', lst);

        return res;
    }
}