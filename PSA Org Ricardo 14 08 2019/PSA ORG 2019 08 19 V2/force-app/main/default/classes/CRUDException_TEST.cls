/*
-- - Name         : CRUDException_TEST
-- - Author       : Ricardo Pereira
-- - Date         : 06/03/2019
-- - Description  : Test class for CRUDException.
*/
@isTest
private class CRUDException_TEST {

    @isTest
    private static void throwException() {
    
        try{
            throw new CRUDException('No read access of PSARangeDescription__c');
        }catch(CRUDException exc){
            System.assertEquals('No read access of PSARangeDescription__c', exc.getMessage());
        }
    }
}