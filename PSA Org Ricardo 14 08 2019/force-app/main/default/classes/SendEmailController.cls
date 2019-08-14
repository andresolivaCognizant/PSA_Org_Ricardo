/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			Sales & B2B
* Description:		SendEmail controller class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-04-17		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public without sharing class SendEmailController {
	
	public static Map<String, Object> mapResponse								= new Map<String, Object>{
																					'hasError'		=> false,
																					'ERROR'			=> '',
																					'REQUEST'		=> ''
																				};
	
	public static String strWhoId;

	/**
	* @Method: 		getInitData
	* @param: 		String strRequest
	* @Description:	Returns useful data to component.
	* @author 		Manuel Medina - 24042019
	*/
	@AuraEnabled
	public static Map<String, Object> getInitData( String strRequest ){
		Map<String, Object> mapRequest											= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		mapResponse.put( 'REQUEST', mapRequest );

		try{
			Id idRecord															= Id.valueOf( String.valueOf( mapRequest.get( 'strRecordId' ) ) );

			Map<String, Map<String, Object>> mapAttributesByName				= new Map<String, Map<String, Object>>(
																					GlobalSettingsUtil.getGlobalSettingAttributes(
																						new Set<String>{ 'SendEmail' },
																						new Set<String>()
																					)
																				);

			OrgWideEmailAddress eWideEmailAddres								= new OrgWideEmailAddress();
			eWideEmailAddres													= [SELECT Id,
																						Address,
																						DisplayName
																					FROM OrgWideEmailAddress
																					WHERE Address =: String.valueOf( mapAttributesByName.get( 'SendEmail' ).get( 'OWEmailAddress' ) )
																					LIMIT 1
																				];

			mapResponse.put(
				'userInfo',
				new Map<String, String>{
					'email'		=> System.UserInfo.getUserEmail(),
					'name'		=> System.UserInfo.getFirstName() + ' ' + System.UserInfo.getLastName()
				}
			);

			mapResponse.put(
				'owEmailAddress',
				new Map<String, Object>{
					'email'		=> eWideEmailAddres.Address,
					'name'		=> eWideEmailAddres.DisplayName
				}
			);

			mapResponse.put(
				'accountField',
				mapAttributesByName.get( 'SendEmail' ).get( String.valueOf( idRecord.getSobjectType() ) )
			);

			return mapResponse;

		}catch( Exception e ){
			manageException( e );
			
			return mapResponse;
		}
	}

	/**
	* @Method: 		getPDF
	* @param: 		String strRecordId
	* @Description:	Returns a PDF as blob for a given record id.
	* @author 		Manuel Medina - 17042019
	*/
	@AuraEnabled
	public static String getPDF( String strRecordId ){
		return PDFReader.getCalloutResponseContents( strRecordId );
	}

	/**
	* @Method: 		getMergedTemplate
	* @param: 		String strRequest
	* @Description:	Returns a email template merged based on given WhoId and WhatId.
	* @author 		Manuel Medina - 23042019
	*/
	@AuraEnabled
	public static Map<String, Object> getMergedTemplate( String strRequest ){
		Map<String, Object> mapRequest											= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		mapResponse.put( 'REQUEST', mapRequest );
		
		try{
			Messaging.SingleEmailMessage msgMergedTemplate						= Messaging.renderStoredEmailTemplate(
																					String.valueOf( mapRequest.get( 'strTemplateId' ) ),
																					null,
																					String.valueOf( mapRequest.get( 'strWhatId' ) )
																				);

			mapResponse.put(
				'template',
				new Map<String, Object>{
					'subject'		=> msgMergedTemplate.subject,
					'htmlBody'		=> msgMergedTemplate.htmlBody,
					'plainTextBody'	=> msgMergedTemplate.plainTextBody
				}
			);

			return mapResponse;

		}catch( Exception e ){
			manageException( e );
			
			return mapResponse;
		}
	}

	/**
	* @Method: 		sendEmail
	* @param: 		String strRequest
	* @Description:	Sends an email with all details defined in the form.
	* @author 		Manuel Medina - 23042019
	*/
	@AuraEnabled
	public static Map<String, Object> sendEmail( String strRequest ){
		Map<String, Object> mapRequest											= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		mapResponse.put( 'REQUEST', mapRequest );

		String strTemlateId														= String.valueOf( mapRequest.get( 'strTemplateId' ) );
		String strWhatId														= String.valueOf( mapRequest.get( 'strWhatId' ) );
		String strFrom															= String.valueOf( mapRequest.get( 'strFrom' ) );
		String strSubject														= String.valueOf( mapRequest.get( 'strSubject' ) );
		String strBody															= String.valueOf( mapRequest.get( 'strBody' ) );
		
		try{
			Messaging.EmailFileAttachment attQuotePDF							= new Messaging.EmailFileAttachment();
			attQuotePDF.contenttype												= 'application/pdf';
			attQuotePDF.filename												= String.valueOf( mapRequest.get( 'strPDFName' ) ) + '.pdf';
			attQuotePDF.body													= EncodingUtil.base64Decode( String.valueOf( mapRequest.get( 'strPDFData' ) ) );

			Messaging.SingleEmailMessage msgFile								= new Messaging.SingleEmailMessage();

			if( !strFrom.equals( System.UserInfo.getUserEmail() ) ){
				OrgWideEmailAddress eWideEmailAddres							= [SELECT Id
																					FROM OrgWideEmailAddress
																					WHERE Address =: String.valueOf( GlobalSettingsUtil.getGlobalSettingAttributes( new Set<String>{ 'SendEmail' }, new Set<String>{ 'OWEmailAddress' } ).get( 'SendEmail' ).get( 'OWEmailAddress' ) )
																					LIMIT 1
																				];
			
				msgFile.setOrgWideEmailAddressId( eWideEmailAddres.Id );
			}
			
			msgFile.setSubject( strSubject );
			msgFile.setHtmlBody( strBody );
			msgFile.setFileAttachments( new List<Messaging.EmailFileAttachment>{ attQuotePDF } );
			msgFile.setToAddresses( getToAddresses( ( Set<String> ) JSON.deserialize( String.valueOf( mapRequest.get( 'strRecipients' ) ), Set<String>.class ) ) );
			msgFile.setWhatId( strWhatId );
			msgFile.setTargetObjectId( strWhoId );
			msgFile.setTreatTargetObjectAsRecipient( true );
			msgFile.setSaveAsActivity( true );
			
			Messaging.sendEmail( new Messaging.SingleEmailMessage[] { msgFile } );

			return mapResponse;

		}catch( Exception e ){
			manageException( e );
			
			return mapResponse;
		}
	}

	/**
	* @Method: 		getToAddresses
	* @param: 		Set<String> setRecipientIds
	* @Description:	Returns a list with all email addresses based on selected recipients.
	* @author 		Manuel Medina - 24042019
	*/
	public static List<String> getToAddresses( Set<String> setRecipientIds ){
		List<String> lstToAddresses												= new List<String>();
		List<Contact> lstContacts												= new List<Contact>( [
																					SELECT Id,
																						Email,
																						PersonalEmail__c
																					FROM Contact
																					WHERE Id IN: setRecipientIds
																				] );

		for( Contact objContact : lstContacts ){
			lstToAddresses.add( String.isNotBlank( objContact.Email ) ? objContact.Email : objContact.PersonalEmail__c );

			if( String.isBlank( strWhoId ) && String.isNotBlank( objContact.Email ) ){
				strWhoId														= objContact.Id;
			}
		}

		return lstToAddresses;
	}

	/**
	* @Method: 		manageException
	* @param: 		Exception e
	* @Description:	Updates mapResponse with error details.
	* @author 		Manuel Medina - 23042019
	*/
	public static void manageException( Exception e ){
		System.debug( '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			
		mapResponse.put( 'hasError', true );
		mapResponse.put(
			'ERROR',
			new Map<String, Object>{
				'cause'				=> e.getCause(),
				'lineNumber'		=> e.getLineNumber(),
				'message'			=> e.getMessage(),
				'stackTraceString'	=> e.getStackTraceString(),
				'typeName'			=> e.getTypeName()
			}
		);
	}
}