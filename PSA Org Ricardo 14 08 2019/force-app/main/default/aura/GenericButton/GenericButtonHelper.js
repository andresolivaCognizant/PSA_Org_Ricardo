({
    callGenMashUp : function(component, mUpName) {
        
        var recId = component.get("v.recordId");	
        var isCommunity = component.get("v.isCommunity");
        var isFlow = false;
        var isButton = true;
        
        var sParam = 'Hola';		
        var p = window.location.pathname;
        var sPageURL = decodeURIComponent(p);
        var	sURLVariables = sPageURL.split('/');
        var objName;
        var i;
         
        for (i = 0; i < sURLVariables.length; i++) { 
            if (i === 3) {
                objName = undefined ? null : sURLVariables[3];
            }
        }
        if (isCommunity === false){
            if (mUpName === "OPV Menu Access") {
                var navEvt = $A.get("e.force:navigateToURL");
                
                navEvt.setParams({
                    "url": "/one/one.app#/n/OPV_Menu_Access"
                });
            } else {
                var navEvt = $A.get("e.force:navigateToComponent");
            
                navEvt.setParams({
                    componentDef : 'c:GenericMashUp',
                    componentAttributes : {
                        "recId"		: recId,
                        "mUpName"	: mUpName,
                        "objName"	: objName,
                        "isCommunity" : isCommunity,
                        "isFlow"	: false,
                        "isButton"  : true
                    }
                });
            }
        } else if (isCommunity === true){
            if (mUpName === "OPV Menu Access") {
                var address = '/opv-menu-access';
            } else {
                var address = '/genericmashup?';
               /*Parameter Number	Parameter Name
                p1					mUpName
                p2					isCommunity
                p3					isFlow
                p4					isButton
                p5					dealerId
                p6					salesAgentId
                p7					localeId
                p8					brand
                p9					slCustomerId
                p10					slDriverId
                p11					slLessorId
                p12					slContactPersonId
                p13					slOpportunityId
                p14					slCustomerType
                p15					slQuoteId
                p16					recId
                p17					objName
                p18					slOrderId
                p19 				slContractId
                */
                
                // Now We send all parameters, in GenericMashUp component they will be evaluated and catched for every MashUp
                // New parameters must be maped and added at end, taking into account FlowRedirectComponent has 2 parameters recId and objName				
                // This Param ORDER must be respected in GenericMashUp Component retrieving parameters from URL
                address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p16=' + recId + '&p17=' + objName;
            }
            
            console.log('address :' +address);
        
            var navEvt = $A.get("e.force:navigateToURL");
            
            navEvt.setParams({
              "url": address
            });
        }
        
        navEvt.fire();
        
    },
        
    getCountryType: function(component) {
        component.set("v.swhide",false);
        
        var action = component.get("c.getCountryType");
            
        action.setParams({ 
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
                
            console.log('setTransferRecords.state : ' + state);
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse === true) {
                    component.set("v.swhide",false);
                } else {
                    component.set("v.swhide",true);
                }

            }else if (state === "ERROR") {
                component.set("v.swhide",true);
                var errors = response.getError();
                
                var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "type": "error",
                    "duration": 5000,
                    "message": errors[0].message
                });

                toastEvent.fire();
            }
            
            this.hideBtt(component);
        });
    
        $A.enqueueAction(action);
    
    },
    
    hideBtt: function(component){
        var mUpName1 = component.get("v.mUpName1");
        var mUpName2 = component.get("v.mUpName2");
        var mUpName3 = component.get("v.mUpName3");
        var mUpName4 = component.get("v.mUpName4");
        var swhide = component.get("v.swhide");
        
        var hide = '';
        
        var detroyComp = true;
                
        if (mUpName1 !== '' && swhide === false){
            component.set("v.hide1", hide);
            
            detroyComp = false;
        }
        
        if (mUpName2 !== '' && swhide === false){
            component.set("v.hide2", hide);
            
            detroyComp = false;
        }
        
        if (mUpName3 !== '' && swhide === false){
            component.set("v.hide3", hide);
            
            detroyComp = false;
        }
        
        if (mUpName4 !== '' && swhide === false){
            component.set("v.hide4", hide);
            
            detroyComp = false;
        }
        
        if (detroyComp === true){
            component.destroy();
        }
    },
    
    /* BEGIN - Manuel Medina - New logic to allow Custom Labels as a design:attribute - 19102018 */
    manageButtonLabels : function( component ){
        var labelName1						= component.get( "v.name1" );
        var labelName2						= component.get( "v.name2" );
        var labelName3						= component.get( "v.name3" );
        var labelName4						= component.get( "v.name4" );
        var labelName_tmp					= "";
        
        try{
            if( labelName1 != undefined && labelName1 != "" ){
                labelName_tmp				= labelName1;
                component.set( "v.name1", ( this.isCustomLabel( labelName1 ) ? $A.getReference( labelName1 ) : labelName1 ) );
            }
            
            if( labelName2 != undefined && labelName2 != "" ){
                labelName_tmp				= labelName2;
                component.set( "v.name2", ( this.isCustomLabel( labelName2 ) ? $A.getReference( labelName2 ) : labelName2 ) );
            }
            
            if( labelName3 != undefined && labelName3 != "" ){
                labelName_tmp				= labelName3;
                component.set( "v.name3", ( this.isCustomLabel( labelName3 ) ? $A.getReference( labelName3 ) : labelName3 ) );
            }
            
            if( labelName4 != undefined && labelName4 != "" ){
                labelName_tmp				= labelName4;
                component.set( "v.name4", ( this.isCustomLabel( labelName4 ) ? $A.getReference( labelName4 ) : labelName4 ) );
            }
            
        }catch( error ){
            console.log( error );
            console.log( "The " + labelName_tmp + " custom label given doesn't exist." );
        }
    },
    
    isCustomLabel : function( labelName ){
        var regex							= /\$[Ll][Aa][Bb][Ee][Ll][.][c][.]\w{0,}/m;
        var patt							= new RegExp( regex );
        
        return patt.test( labelName );
    }
    /* END - Manuel Medina - 19102018 */
})