/**
* Salesforce
* @author 			Ruben Fernandez
* Project:			
* Description:		QuotesPDF controller.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-##-##		Ruben Fernandez (RF)	Initial definition.
* @version	2.0		2019-06-03		Manuel Medina (MM)		Method getResources() updated to allow SObjects
*															based on Generic Settings Attributes.
*********************************************************************************************************/
public with sharing class PDFReader {
	
	/**
	* @Method: 		getCalloutResponseContents
	* @param: 		String sRecordId
	* @Description:	Returns a PDF content to an specific record id.
	* @author 		Ruben Fernandez - ####2019
	*/
	@AuraEnabled
	public static String getCalloutResponseContents( String sRecordId ){

		UtilSetting__mdt mdtQuoteToPDF							= new UtilSetting__mdt();
		mdtQuoteToPDF											= [SELECT Id,DeveloperName,Value__c,Value2__c
																	FROM UtilSetting__mdt
																	WHERE DeveloperName =: 'QuoteToPDF'
																	LIMIT 1
																];

		String sLocale											= PAD.uCurrentUserName.LanguageLocaleKey;
		String sXLocale											= sLocale.left(2) + '_' + PAD.sUserCountry + '_' + PAD.sUserBrand;
		String sFileId											= getResources( sRecordId );

		Http h													= new Http();
		HttpRequest req											= new HttpRequest();
		req.setEndpoint( sFileId );
		req.setHeader( 'Authorization', 'Basic ' + mdtQuoteToPDF.Value2__c );
		req.setHeader( 'X-Locale', sXLocale );
		req.setHeader( 'accept', 'application/pdf' );
		req.setMethod( 'GET' );
		
		HttpResponse res;

		if( String.isNotBlank( sFileId ) ){
			res													= h.send( req );
		}

		String pdfContent										= System.Label.PDFReaderMessageError;
		String sBody											= res != null && res.getBodyAsBlob() != null ? EncodingUtil.base64Encode( res.getBodyAsBlob() ) : EncodingUtil.base64Encode( blob.toPDF( pdfContent ) );

		return sBody;
	}

	/**
	* @Method: 		getResources
	* @param: 		Id idRecord
	* @Description:	Returns the web service URL.
	* @author 		Ruben Fernandez - ####2019
	*/
	private static String getResources( Id idRecord ){
		String sResult											= '';
		String strSObject										= String.valueOf( idRecord.getSobjectType() );
		
		Map<String, Map<String, Object>> mapFieldBySObject		= new Map<String, Map<String, Object>>(
																	GlobalSettingsUtil.getGlobalSettingAttributes(
																		new Set<String>{ 'PDFReader' },
																		new Set<String>{ strSObject }
																	)
																);

		if( !mapFieldBySObject.isEmpty() && mapFieldBySObject.get( 'PDFReader' ).containsKey( strSObject ) ){
			String strURLField									= String.valueOf( mapFieldBySObject.get( 'PDFReader' ).get( strSObject ) );
			String strSOQL										= 'SELECT Id, ' + strURLField + ' FROM ' + strSObject + ' WHERE Id = \'' + idRecord + '\'';

			Map<Id, SObject> mapRecordById						= new Map<Id, SObject>( Database.query( strSOQL ) );

			return mapRecordById.get( idRecord ).get( strURLField ) != null ? String.valueOf( mapRecordById.get( idRecord ).get( strURLField ) ) : '';
		}
 
		return '';
	}
}