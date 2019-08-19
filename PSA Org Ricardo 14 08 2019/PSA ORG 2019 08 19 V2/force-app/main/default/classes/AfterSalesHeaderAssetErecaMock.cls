/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		HttpCalloutMock to ERECA WS.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-07-31		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
global class AfterSalesHeaderAssetErecaMock implements HttpCalloutMock{
	
	global Integer intStatusCode;
	
	global AfterSalesHeaderAssetErecaMock( Integer intStatusCode ){
		this.intStatusCode						= intStatusCode;
	}

	global HTTPResponse respond( HTTPRequest req ) {
		
		HTTPResponse res						= new HTTPResponse();
		res.setStatusCode( intStatusCode != null ? intStatusCode : 200 );
		res.setStatus( 'OK' ); 
		
		if( intStatusCode != null ){
			res.setBody( '[{"codeCampagne": "TSS","libelle": "Test Test","typeCampagne": "TST","status": "NR","dateLancement": "13/07/2018","pointRattrape": 15},{"codeCampagne": "TSS","libelle": "Test Test","typeCampagne": "TST","status": "RA","dateLancement": "13/07/2018","pointRattrape": 15},{"codeCampagne": "TSS","libelle": "Test Test","typeCampagne": "TST","status": "EX","dateLancement": "13/07/2018","pointRattrape": 15},{"codeCampagne": "TSS","libelle": "Test Test","typeCampagne": "TST","status": "NJ","dateLancement": "13/07/2018","pointRattrape": 15}]' );
		
		}else{
			res.setBody( '{ "exception": "exception" }' );
		}
		
		return res;
	}
}