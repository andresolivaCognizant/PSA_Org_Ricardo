({
    unrender : function( component ) {

        this.superUnrender();

        var CheckIntervalId = component.get( 'v.CheckIntervalId' );
        if ( !$A.util.isUndefinedOrNull( CheckIntervalId ) ) {
            window.clearInterval( CheckIntervalId );
        }
    }	
})