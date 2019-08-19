/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Test class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-10-24		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
@isTest 
public class FieldLabelsControllerTest {
	
	@isTest static void testMethod1(){
		FieldLabelsController.getFieldLabel( '["Account.Name","Account.Phone","Contact.AccountId"]' );
	}
}