({
    calculatePopoverPosition: function(component) {
        var popoverEl 				= component.find('popover').getElement();
        var popoverBoundingBox 		= popoverEl.getBoundingClientRect();
        var popoverWidth 			= Math.ceil(popoverBoundingBox.width);
        var popoverHeight 			= popoverBoundingBox.height;

        var containerEl 			= component.find('popoverContainer').getElement();
        var containerBoundingBox 	= containerEl.getBoundingClientRect();
        var containerWidth 			= containerBoundingBox.width;
        var containerHeight 		= containerBoundingBox.height;
        var containerLeft 			= containerBoundingBox.left;
        var containerRight 			= containerBoundingBox.right;

        var variant 				= component.get('v.variant');
        var placement 				= component.get('v.placement');
        var popoverAdjustment;
        var adjustment;
        var popAdjustment;
        if(placement.startsWith('auto ')) {
            placement               = placement.replace('auto ', '');
            var windowBoundingBox = {
                top 	: 0,
                right 	: window.innerWidth,
                bottom 	: window.innerHeight,
                left 	: 0
            };
            if(placement === 'top' && (containerBoundingBox.top - popoverBoundingBox.height) < windowBoundingBox.top) {
                placement           = 'bottom';
            } else if(placement === 'right' && (containerBoundingBox.right + popoverBoundingBox.width) > windowBoundingBox.right) {
                placement           = 'left';
            } else if(placement === 'bottom' && (containerBoundingBox.bottom + popoverBoundingBox.height) > windowBoundingBox.bottom) {
                placement           = 'top';
            } else if(placement === 'left' && (containerBoundingBox.left - popoverBoundingBox.width) < windowBoundingBox.left) {
                placement           = 'right';
            }
            this.calculatePlacement(component, placement);
        }

        var popoverYPos, popoverXPos;
        var popPadding              = 14;
        var popoverStyle            = component.find('popoverStyle').getElement();

        if (placement === 'right') {
            popoverXPos             = containerWidth + popPadding;

            if (variant === 'panels') {
                popoverYPos         = -25;
            } else {
                popoverYPos         = (containerHeight - popoverHeight) / 2;
            }
            if (popoverHeight > window.innerHeight) {
                popoverAdjustment   = 10 - containerBoundingBox.top;
                popAdjustment       = (popoverYPos - popoverAdjustment);
                popoverStyle.innerHTML = '.st-popover_container .slds-nubbin--left:before { transform: translateY(' + popAdjustment + 'px) rotate(45deg); } .st-popover_container .slds-nubbin--left:after { transform: translateY(' + popAdjustment + 'px) rotate(45deg); }';
                popoverYPos         = popoverAdjustment;
            } else {
                popoverStyle.innerHTML = '';
            }
        } else if (placement === 'bottom') {
            popoverXPos             = (containerWidth - popoverWidth) / 2;
            popoverYPos             = containerHeight + popPadding;
            
            if ((containerLeft + popoverXPos) < 4) {
                adjustment          = Math.abs(containerLeft + popoverXPos) + 4;

                popoverXPos         += adjustment;
                popoverStyle.innerHTML = '.st-popover_container .slds-nubbin--top:before { transform: translateX(' + -adjustment + 'px) rotate(45deg); } .st-popover_container .slds-nubbin--top:after { transform: translateX(' + -adjustment + 'px) rotate(45deg); }';
            } else if ((containerRight + Math.abs(popoverXPos)) > (window.innerWidth - 4)) {
                adjustment          = (containerRight + Math.abs(popoverXPos)) - (window.innerWidth - 4);
                popoverXPos -= adjustment;
                popoverStyle.innerHTML = '.st-popover_container .slds-nubbin--top:before { transform: translateX(' + adjustment + 'px) rotate(45deg); } .st-popover_container .slds-nubbin--top:after { transform: translateX(' + adjustment + 'px) rotate(45deg); }';
            }
        } else if (placement === 'left') {
            popoverXPos = -popoverWidth - popPadding;

            if (variant === 'panels') {
                popoverYPos         = -25;
            } else {
                popoverYPos         = (containerHeight - popoverHeight) / 2;
            }
            if (popoverHeight > window.innerHeight) {
                popoverAdjustment   = 10 - containerBoundingBox.top;
                popAdjustment       = (popoverYPos - popoverAdjustment);
                popoverStyle.innerHTML = '.st-popover_container .slds-nubbin--right:before { transform: translateY(' + popAdjustment + 'px) rotate(45deg); } .st-popover_container .slds-nubbin--right:after { transform: translateY(' + popAdjustment + 'px) rotate(45deg); }';
                popoverYPos         = popoverAdjustment;
            } else {
                popoverStyle.innerHTML = '';
            }
        } else { // Top
            popoverXPos             = (containerWidth - popoverWidth) / 2;
            popoverYPos             = -popoverHeight - popPadding;

            if ((containerLeft + popoverXPos) < 4) {
                adjustment          = Math.abs(containerLeft + popoverXPos) + 4;

                popoverXPos += adjustment;
                popoverStyle.innerHTML = '.st-popover_container .slds-nubbin--bottom:before { transform: translateX(' + -adjustment + 'px) rotate(45deg); } .st-popover_container .slds-nubbin--bottom:after { transform: translateX(' + -adjustment + 'px) rotate(45deg); }';
            } else if ((containerRight + Math.abs(popoverXPos)) > (window.innerWidth - 4)) {
                adjustment          = (containerRight + Math.abs(popoverXPos)) - (window.innerWidth - 4);

                popoverXPos -= adjustment;
                popoverStyle.innerHTML = '.st-popover_container .slds-nubbin--bottom:before { transform: translateX(' + adjustment + 'px) rotate(45deg); } .st-popover_container .slds-nubbin--bottom:after { transform: translateX(' + adjustment + 'px) rotate(45deg); }';
            }
        }
        return {
            popoverXPos : popoverXPos,
            popoverYPos : popoverYPos,
            width : popoverWidth
        }
    },    
    calculatePlacement : function(component, placement){
        if(!placement) {
            placement   = component.get('v.placement');
        }
        placement       = placement.replace('auto ', '');
        var variant     = component.get('v.variant');
        var popPlacement;
        switch (placement){
            case 'top'      : popPlacement = 'slds-nubbin--bottom'; break;
            case 'bottom'   : popPlacement = 'slds-nubbin--top'; break;
            case 'left'     : popPlacement = 'slds-nubbin--right'; break;
            case 'right'    : popPlacement = 'slds-nubbin--left'; break;
            default         : popPlacement = 'slds-nubbin--bottom';
        }
        if (variant === 'panels' && (placement === 'left' || placement === 'right')) {
            popPlacement += '-top';
        }
        component.set('v.popPlacement', popPlacement);
    },
    forceHide: function(component, event, helper) {
        component.set('v.preventHide', false);
        helper.setHide(component, event, helper);
    },
    hidePopover: function(component, event, helper) {
        if (component.get('v.withClose') !== true) {
            component.set('v.preventHide', false);
            helper.setHide(component, event, helper);
        }
    },
    setIconValue: function(component, event, helper) {
        var theme                       = component.get('v.theme');
        var shouldInvertIcon            = !(theme === 'default' || theme === 'warning');
        component.set('v.shouldInvertIcon', shouldInvertIcon);
    },
    showPopover: function(component, event, helper) {
        var popoverStyleOptions         = helper.calculatePopoverPosition(component);
        var popoverStyle                = 'position: absolute; left: ' + popoverStyleOptions.popoverXPos + 'px; top: ' + popoverStyleOptions.popoverYPos + 'px;';
        component.set('v.popoverStyle', popoverStyle);
        component.set('v.showPopover', true);
    },
    setHide: function(component, event, helper) {
        window.setTimeout($A.getCallback(function() {
            if (!component.get('v.preventHide')) {
                var popoverStyle        = component.find('popoverStyle').getElement();
                popoverStyle.innerHTML  = '';
                component.set('v.showPopover', false);
                component.set('v.popoverStyle', '');
            }
        }), 100);
    }
})