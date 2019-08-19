global with sharing class ChatterPostMessageInvocable {
	
	private static final String FEED_ITEM_KEY_PREFIX 	= FeedItem.sObjectType.getDescribe().getKeyPrefix();
    private static final String TEMPLATE_DEVNAME_LEAD   = 'LeadChangeOwnerPostMessage';
    private static final String TEMPLATE_DEVNAME_OPP    = 'OpportunityOrderCreatedPostMessage';
    private static final String GROUP_ITEM_KEY_PREFIX 	= Group.sObjectType.getDescribe().getKeyPrefix();
    private static final String OPPTY_ITEM_KEY_PREFIX   = Opportunity.sObjectType.getDescribe().getKeyPrefix();
    private static final String LEAD_ITEM_KEY_PREFIX    = Lead.sObjectType.getDescribe().getKeyPrefix();
    private static final String NETWORK_STATUS          = 'Live';
    //private static Contact DUMMY_CONTACT                = new Contact(FirstName='Test', LastName ='Test',Salutation='Dr',Phone='123456789',email='no-reply@mpsa.com',NationalId__c='ID1234567',TECH_DummyContact__c=true);
    private static Map<Id,Id> mapNetworkMembers;

   @InvocableMethod(
        label       = 'PB: Post Message'
        description = 'Posts a Chatter message as specified user.'
    )
    global static void postMessage( List<PostRequest> requests ) {

        System.debug( 'ChatterPostMessageInvocable.postMessage START: ' + requests.size() );
        
        Set<Id> setUsers 	            = new Set<Id>();
        List<Id> lstRecords	            = new List<Id>();
        List<Lead> lstLeadRecords       = new List<Lead>();
        List<Network> aux 	            = new List<Network>([SELECT Id,Name,Status FROM Network WHERE Status =:NETWORK_STATUS]);
        Map<Id,PostRequest> mapFull		= new Map<Id,PostRequest>();
 		Map<String, Id> mapTemplates 	= new Map<String,Id>();
        Id networkId                    = Network.getNetworkId();
        //setDummyContact();
        String sKey                     = '';
        Boolean bIsLead                 = true;
     	for(PostRequest r : requests){
            if(sKey==''){
                if(String.valueOf(r.recordId).left(3) == OPPTY_ITEM_KEY_PREFIX){
                    bIsLead = false;
                    sKey    = TEMPLATE_DEVNAME_OPP;
                }else{
                    sKey    = TEMPLATE_DEVNAME_LEAD;
                }
                //sKey = (String.valueOf(r.recordId).left(3) == OPPTY_ITEM_KEY_PREFIX)?TEMPLATE_DEVNAME_OPP:TEMPLATE_DEVNAME_LEAD;
            }
            System.debug( 'ChatterPostMessageInvocable.postMessage: sKey ' + sKey );
     		setUsers.add(r.toId);
     	}
        for(EmailTemplate template : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName Like : sKey+ '%'] ) {
            mapTemplates.put(template.developerName, template.id );
        }
     	setCommunityMap(setUsers);
     	Map<Id,User> mapUser            = new Map<Id,User>([Select Id,ContactId, ProfileId, Country__c, Brand__c, LanguageLocaleKey From User Where Id IN : setUsers]);
     	
        for(PostRequest r : requests){
     		
     		String subjectKeyPrefix = String.valueOf(r.toId).left(3);
     		if(subjectKeyPrefix!=GROUP_ITEM_KEY_PREFIX){
	     		if( mapUser.get(r.toId)==null || mapUser.get(r.toId).LanguageLocaleKey==null){
	     			sKey = sKey + 'EN';
	     		}else{
                    String sLanguage = mapUser.get(r.toId).LanguageLocaleKey;
                    if(!mapTemplates.containsKey(sKey + sLanguage.left(2).toUpperCase())){
                        sKey = sKey + 'EN';
                    }else{
                        sKey = sKey + sLanguage.left(2).toUpperCase();
                    }
	     		}
                // Post into the record
	     		//postChatterMessage( mapNetworkMembers.get(r.toId), r.fromId ,r.toId, getMailTemplate(r.recordId,mapTemplates.get(sKey))) ;
                Id sId;
                if(!bIsLead){
                    sId = (mapUser.get(r.toId).ContactId !=null)?mapUser.get(r.toId).ContactId:r.toId;
                }else {
                    sId = r.recordId;
                }
                System.debug( 'ChatterPostMessageInvocable.postMessage: sKey: ' + sKey);

                postChatterMessage( mapNetworkMembers.get(r.toId), r.toId ,r.toId, getMailTemplate(sId,mapTemplates.get(sKey),r.recordId));
     		}
     	}
        //delDummyContact();
    }
    // -----------------------------------------------------------------
    // INVOCABLE CLASS: PARAMS
    // -----------------------------------------------------------------
    global class PostRequest {

        @InvocableVariable(
            label           = 'Author User ID'
            description     = 'Who the Chatter post will be shown as created by.'
            required        = true
        )
        global String fromId;

        @InvocableVariable(
            label           = 'User, Group, or Record ID'
            description     = 'Where the Chatter post will be made.'
            required        = true
        )
        global String toId;

        @InvocableVariable(
            label           = 'Record ID (Template Merge Fields)'
            description     = 'Identifies a record such as an Account or Contact that will be read and used in merge field processing of the email template.'
        )
        global String recordId;

    }

    private static void postChatterMessage( ID networkId, ID fromId, ID toId, String message ) {

        System.debug( 'posting chatter message: networkId=' + networkId + ', authorId=' + fromId + ', subjectId=' + toId + ', message=' + message );

        // if message uses Flow or Process Builder @mention syntax @[user_or_group_id]
        // unfortunately the ConnectApi doesn't support that. It won't error, but won't
        // resolve to an expected @mention. So we need to translate that syntax into
        // the syntax expected by ConnectApi, which is simply {user_or_group_id}.
        if(!String.isEmpty(message)){
            Matcher mentionMatcher = Pattern.compile( '(@\\[([a-zA-Z0-9]+)\\])' ).matcher( message );
            while ( mentionMatcher.find() ) {
                message = mentionMatcher.replaceAll( '{$2}' );
            }

            //String subjectKeyPrefix = String.valueOf( toId ).left( 3 );
            //if ( subjectKeyPrefix == FEED_ITEM_KEY_PREFIX ) {
            //    postFeedComment( networkId, fromId, toId, message );
            //} else {
                postFeedItem( networkId, fromId, toId, message );
            //}
        }
    }

    /**
     * Posts a new message related to given subject.
     * SubjectId must not be another FeedItem or FeedComment but rather
     * a User ID, Chatter Group ID, or other record ID like an Account, Contact, etc.
     */
    private static void postFeedItem( ID networkId, ID authorId, ID subjectId, String message ) {

        System.debug( 'posting feed item: networkId=' + networkId + ', authorId=' + authorId + ', subjectId=' + subjectId + ', message=' + message );

        // we use a mix of FeedItem DML and ConnectApi for our requirements:
        // 1. Post Chatter Message as any user (FeedItem DML)
        // 2. Post Rich-Text content with @mentions (ConnectApi)

        // setting the createdById only works if the context user of this email service
        // has the system permission "Insert System Field Values for Chatter Feeds"

        // even though rich-text is supported with FeedItem DML,
        // all @mention links are converted to plain text.
        // workaround is that after inserting the FeedItem we use ConnectApi
        // to update the element with the same rich-text but @mentions will be preserved.

        FeedItem fi = new FeedItem(
            parentId 	= subjectId,    // where post is being made: user, group, record
            createdById = authorId,     // who is posting the message
            body 		= message,      // rich-text, but @mentions not supported
            isRichText	= true,          // we support rich-text and @mentions
            NetworkScope= networkId
        );

         try {
            insert fi;

            System.debug( fi );

            // after creating the shell of the feed item, retrieve the record back in Chatter for Apex
            ConnectApi.FeedElement fe = ConnectApi.ChatterFeeds.getFeedElement( networkId, fi.id );

            // parse the rich-text message and create new message input
            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            messageInput.messageSegments = ConnectApiHelper.getMessageSegmentInputs( message );

            // define an updated feed element using the rich-text message
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.body = messageInput;

            // replace the content of the chatter post
            fe = ConnectApi.ChatterFeeds.updateFeedElement( networkId, fe.id, input );
            System.debug( fe );
        } catch(Exception e) {
            system.debug('## postFeedItem --> ERROR : ' + e);
        }

    }

    /**
     * Posts a comment to an existing feed item.
     * SubjectId must be ID of a FeedItem record.
     */
    //private static void postFeedComment( ID networkId, ID authorId, ID subjectId, String message ) {

    //    System.debug( 'posting feed comment: networkId=' + networkId + ', authorId=' + authorId + ', subjectId=' + subjectId + ', message=' + message );

    //    // we use a mix of FeedComment DML and ConnectApi for our requirements:
    //    // 1. Post Chatter Message as any user (FeedComment DML)
    //    // 2. Post Rich-Text content with @mentions (ConnectApi)

    //    // setting the createdById only works if the context user of this email service
    //    // has the system permission "Insert System Field Values for Chatter Feeds"

    //    // even though rich-text is supported with FeedComment DML,
    //    // all @mention links are converted to plain text.
    //    // workaround is that after inserting the FeedComment we use ConnectApi
    //    // to update the element with the same rich-text but @mentions will be preserved.

    //    FeedComment fc = new FeedComment(
    //        feedItemId 	= subjectId,    // where post is being made: user, group, record
    //        createdById = authorId,     // who is posting the message
    //        commentBody = message,      // rich-text, but @mentions not supported
    //        isRichText 	= true          // we support rich-text and @mentions
    //    );
    //    try {
    //        insert fc;

    //        System.debug( fc );

    //        // after creating the shell of the feed comment, retrieve the record back in Chatter for Apex
    //        ConnectApi.Comment comment = ConnectApi.ChatterFeeds.getComment( networkId, fc.id );

    //        // parse the rich-text message and create new message input
    //        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    //        messageInput.messageSegments = ConnectApiHelper.getMessageSegmentInputs( message );

    //        // define an updated feed element using the rich-text message
    //        ConnectApi.CommentInput input = new ConnectApi.CommentInput();
    //        input.body = messageInput;

    //        // replace the content of the chatter post
    //        comment = ConnectApi.ChatterFeeds.updateComment( networkId, comment.id, input );
    //        System.debug( comment );
    //    } catch(Exception e) {
    //        system.debug('## postFeedItem --> ERROR : ' + e);
    //    }

        

    //}
    /**
     * Get email body.
     * IdTargetObjectId must be ID of a FeedItem record.
     * IdTemplate must be the ID of a template record.
     */
    private static String getMailTemplate(Id IdTargetObject, Id IdTemplate, Id IdRecord) {
        if(IdTargetObject!=null && IdTemplate!=null ){
            Messaging.SingleEmailMessage mail 	= new Messaging.SingleEmailMessage();
            //String[] toAddresses 				= new String[] {'dummymail@example.com'};
            //mail.setToAddresses(toAddresses);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            mail.setSenderDisplayName('Dummy');
            mail.setTargetObjectId(IdTargetObject);
            //mail.setTargetObjectId(DUMMY_CONTACT.Id);
            //mail.setWhatId(IdRecord);
            mail.setTemplateId(IdTemplate);
            Savepoint sp = Database.setSavepoint();
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                Database.rollback(sp);
            }catch(Exception e){
                system.debug('## getMailTemplate --> ERROR : ' + e);
                //Database.rollback(sp);
            }
            //
            return mail.getPlainTextBody();
        }else{
            return null;
        }
    }
/*
    private static Void setDummyContact(){
        try{
            insert DUMMY_CONTACT;
            system.debug('## DUMMY_CONTACT --> Id : ' + DUMMY_CONTACT.Id);
        }catch(Exception e) {
            system.debug('## setDummyContact --> ERROR : ' + e);
        }
    }
    private static Void delDummyContact(){
        try{
            if(DUMMY_CONTACT!=null){
                delete DUMMY_CONTACT;
            }
        }catch(Exception e) {
            system.debug('## delDummyContact --> ERROR : ' + e);
        }
    }
*/
    /**
    * Get email body.
    * IdTargetObjectId must be ID of a FeedItem record.
    * IdTemplate must be the ID of a template record.
    */
    private static void setCommunityMap(Set<Id> lstUserId) {

		mapNetworkMembers = new Map<Id,Id>();
     	for(NetworkMember objNetworkMember: [SELECT MemberId, NetworkId FROM NetworkMember WHERE MemberId IN :lstUserId AND Network.Status = 'Live']) {
        	mapNetworkMembers.put(objNetworkMember.MemberId, objNetworkMember.NetworkId);
    	}
	}


}