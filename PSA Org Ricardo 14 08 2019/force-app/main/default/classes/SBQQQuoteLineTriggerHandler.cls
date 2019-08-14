/*
*   @Class : SBQQQuoteLineTriggerHandler.cls
*
*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
*   @Created        :   02 08 2018
*   @Description    :   To manage SBQQ__QuoteLine__c trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Ruben Moreno			02 08 2018				 Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
*/

public with sharing class SBQQQuoteLineTriggerHandler {
    
    private static boolean runtrigger = true;
    
    
    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   To get the flag that indicate if the trigger should run or not
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public	static	boolean	shouldRunTrigger() {
		return runtrigger;
	}
    
    
    
    /*
     * @Method          :   dontRunTrigger
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   To indicate that the trigger should not run
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public	static	void	dontRunTrigger() {
		runtrigger = false;
	}
	



    /*
     * @Method          :   beforeInsert
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   Call the actions that handle the before insert trigger.
     * @Params          :   List<SBQQ__QuoteLine__c> records before the changes.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	
    public static void beforeInsert(List<SBQQ__QuoteLine__c> lNewQuoteLines) {
    	//CheckProductReservation.checkAvailability(lNewQuoteLines); --> 3/9/2018 Provisional, reunion con Laura Godoy y Borja.
	}




    /*
     * @Method          :   beforeUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   Call the actions that handle the before update trigger.
     * @Params          :   List<SBQQ__QuoteLine__c> records after the changes, Map<Id, SBQQ__QuoteLine__c> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    
	public static void beforeUpdate(List<SBQQ__QuoteLine__c> lNewQuoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {         
	}

    /*
     * @Method          :   beforeUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   Call the actions that handle the before update trigger.
     * @Params          :   List<SBQQ__QuoteLine__c> records before the changes.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void beforeDelete(List<SBQQ__QuoteLine__c> lOldQuoteLines) {
        //CheckProductReservation.blockEditionElimination(lOldQuoteLines);
	}
    

    /*
     * @Method          :   afterInsert
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   05 feb 2018
     * @Description     :   Call the actions that handle the after insert trigger
     * @Params          :   List<SBQQ__QuoteLine__c> records after the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void afterInsert(List<SBQQ__QuoteLine__c> lNewQuoteLines) {
        PopulateQuoteInformation.mainProcess(lNewQuoteLines);
        
	}

    
    
    /*
     * @Method          :   afterUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   Call the actions that handle the after update trigger.
     * @Params          :   List<SBQQ__QuoteLine__c> records after the changes, Map<Id, SBQQ__QuoteLine__c> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	
    
    public static void afterUpdate(List<SBQQ__QuoteLine__c> lNewQuoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {

	}
    
    
    /*
     * @Method          :   afterUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   Call the actions that handle the after update trigger.
     * @Params          :   List<SBQQ__QuoteLine__c> records after the changes, Map<Id, SBQQ__QuoteLine__c> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void afterDelete(List<SBQQ__QuoteLine__c> lOldQuoteLines) {
		PopulateQuoteInformation.mainProcess(lOldQuoteLines);
	}
    
    
    

}