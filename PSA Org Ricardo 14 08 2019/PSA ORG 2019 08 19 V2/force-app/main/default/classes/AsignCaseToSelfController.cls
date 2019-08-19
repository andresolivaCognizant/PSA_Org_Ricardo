public class AsignCaseToSelfController {
    public static final User current_user;

    static {
        current_user = [
            SELECT Id, Brand__c, Country__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ].get(0);
    }

    @AuraEnabled
    public static boolean asignCaseToSelf(String caseId){
        String userId = UserInfo.getUserId();
        List<Case> lstCas = new List<Case>([
            SELECT Id, Status, OwnerId, Country__c, Brand__c
            FROM Case
            WHERE Id = :caseId
        ]);

        String ownId = lstCas[0].OwnerId;
        if (
            ownId.StartsWith('00G') &&
            lstCas[0].Status == '1' &&
            current_user.Country__c == lstCas[0].Country__c &&
            (
                current_user.Brand__c == 'All' ||
                current_user.Brand__c == lstCas[0].Brand__c
            )
        ){
            Case cas = new Case(
                Id      = caseId,
                OwnerId = userId,
                Status  = '2'
            );
            update cas;
            return true;
        }
        else{
            return false;
        }
    }
}