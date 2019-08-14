( {
	init : function( cmp, event, helper ) {
		var steps = [
			{
				"title"     : $A.get( "$Label.c.AfterSalesBVVInvoicesSection" ),
				"class"     : "path_layer slds-path__item slds-is-incomplete",
				"disabled"  : true,
				"pId"       : null
			},
			{
				"title"     : $A.get( "$Label.c.AfterSalesBVVInterventionsSection" ),
				"class"     : "path_layer slds-path__item slds-is-incomplete",
				"disabled"  : true,
				"pId"       : null
			},
			{
				"title"     : $A.get( "$Label.c.AfterSalesBVVPartsOperations" ),
				"class"     : "path_layer slds-path__item slds-is-incomplete",
				"disabled"  : true,
				"pId"       : null
			}
		];

		cmp.set( "v.path_setting", steps );
		helper.updatePath( cmp );

		cmp.set( "v.columns", helper.getColumns() );
	},

	handleOnStepClick : function( component, event, helper ) {
		var step = component.get( "v.step" );
		var target_step = event.currentTarget.dataset.step_id;

		if ( target_step < step ) {
			component.set( "v.step", target_step );
			helper.updatePath( component );

			if ( target_step == 1 ){
				helper.createInterventionsTable(
					component,
					component.get( "v.data.dossiers" )[component.get( "v.path_setting[1].pId" )]
				);
				return;
			}

			helper.createInvoicesTable( component );
		}
	},

	handleSectionClick : function( component, event, helper ) {
		var e = component.find( event.currentTarget.id );
		$A.util.toggleClass( e, 'slds-is-open' );
	},

	handleRowAction : function ( cmp, event, helper ) {
		var action = event.getParam( 'action' );
		var row = event.getParam( 'row' );

		switch ( action.name ) {
			case 'view_interventions':
				helper.createInterventionsTable(
					cmp,
					cmp.get( "v.data.dossiers" )[row.dossierId_bkp]
				);
				cmp.set( "v.step", "1" );
				cmp.set( "v.path_setting[1].pId",row.dossierId_bkp );
				helper.updatePath( cmp );
				break;

			case 'view_parts':
				cmp.set( "v.step", "2" );
				helper.updatePath( cmp );
	
				helper.createPiecesTable( cmp, row );
				break;
	
			default : break;
		}
	},

	handleRecordUpdated : function( component, event, helper ) {
		var change_type = event.getParams().changeType;
		switch ( change_type ) {
			case 'LOADED':
				helper.fetchInterventions( component, event );
				default : break
		}
	}
} )