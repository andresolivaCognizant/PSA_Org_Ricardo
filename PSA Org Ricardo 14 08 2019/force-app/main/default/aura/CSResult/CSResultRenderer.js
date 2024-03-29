({
	    afterRender : function( component, helper ) {

        this.superAfterRender();

        // this is done in renderer because we don't get
        // access to the window element in the helper js.

        var didScroll = false;

        window.onscroll = function() {
            didScroll = true;
        };

        // periodically attach the scroll event listener
        // so that we aren't taking action for all events
        var scrollCheckIntervalId = setInterval( $A.getCallback( function() {

            // since this function is called asynchronously outside the component's lifecycle
            // we need to check if the component still exists before trying to do anything else
            if ( didScroll && component.isValid() ) {

                didScroll = false;

                // adapted from stackoverflow to detect when user has scrolled sufficiently to end of document
                // http://stackoverflow.com/questions/4841585/alternatives-to-jquery-endless-scrolling
                if ( window['scrollY'] >= document.body['scrollHeight'] - window['outerHeight'] - 30 ) {
                    helper.getNextPage( component );
                }

            }

        }), 1000 );

        component.set( 'v.scrollCheckIntervalId', scrollCheckIntervalId );

    },

    unrender : function( component, helper ) {

        this.superUnrender();

        var scrollCheckIntervalId = component.get( 'v.scrollCheckIntervalId' );

        if ( !$A.util.isUndefinedOrNull( scrollCheckIntervalId ) ) {
            window.clearInterval( scrollCheckIntervalId );
        }
    }
})