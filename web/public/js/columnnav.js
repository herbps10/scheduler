/**
 *  Based off of:
 *  
 *      jQuery Column Navigation Plugin
 *      version 1.1.0
 *	
 *      Written by Sam Clark
 *      http://sam.clark.name
 *	
 *  Changes were made to allow <ul> to be styled independantly.
 *  The only stlying handled by this plugin is related to positioning 
 *  of the containers. Rather than applying CSS rules, this plugin simply
 *  adds and removed the "selected" class.
 *  
 *  
 *  !!! NOTICE !!!
 *  This library and related library requires jQuery 1.2.6 or higher
 *	http://www.jquery.com
 *	This library requires the ScrollTo plugin for jQuery by Flesler
 *	http://plugins.jquery.com/project/ScrollTo
 *  
 **/

(function($){
	$.fn.columnNavigation = function( configuration )
	{
		// Check for incoming ul or ol element
		if( $(this).get(0).tagName != "UL" && $(this).get(0).tagName != "OL" )
		{
			alert( "FATAL ERROR: columnNavigation requires an UL or OL element\nYou supplied a : " + $(this).get(0).tagName );
			return false;
		}
				
		// Setup the selectors
		if( $(this).get(0).tagName == "UL" )
		{
			var selectorName = "ul";
		}
		else if( $(this).get(0).tagName == "OL" )
		{
			var selectorName = "ol";
		}
		
		// Wrap the submitted element in a new div
		$(this).wrap( document.createElement("div") );
		
		var wrapper = $(this).parent();
        wrapper.addClass('wrapper');
		
		
		// Setup the column navigation object with configuration settings
		// Overright existing settings where applicable
		configuration = $.extend({
			containerPosition:"absolute",
			containerWidth:"400px",
			containerHeight:"288px", //multiple of 36 for height of each item
			columnWidth:255,
			columnScrollVelocity:200,
			callBackFunction:null
		}, configuration);
		
		// check callback is a function if set
		if( configuration.callBackFunction != null && jQuery.isFunction( configuration.callBackFunction ) == false )
		{
			alert( 'FATAL ERROR: columnNavigation.callBackFunction() is not a function!' );
			return false;
		}
				
		// Setup the container space using the settings
		$(wrapper).css({
			position:configuration.containerPosition,
			width:configuration.containerWidth,
			height:configuration.containerHeight,
			overflowX:"hidden",
			overflowY:"hidden"
		});
		
		// LI element deselect state
		var liDeselect = {
			backgroundColor:configuration.columnDeselectBackgroundColor,
			backgroundRepeat:configuration.columnDeselectBackgroundRepeat,
			backgroundPosition:configuration.columnDeselectBackgroundPosition
		};
		
		// LI element select state
		var liSelect = {
			backgroundColor:configuration.columnSelectBackgroundColor,
			backgroundRepeat:configuration.columnSelectBackgroundRepeat,
			backgroundPosition:configuration.columnSelectBackgroundPosition			
		};
		
		// A element deselect state
		var aDeselect = {
			color:configuration.columnDeselectColor,
			fontFamily:configuration.columnFontFamily,
			fontSize:configuration.columnFontSize,
			textDecoration:"none",
			fontWeight:"normal",
			outline:"none",
			display:"block"
		};
		
		// A element select state
		var aSelect = {
			color:configuration.columnSelectColor,
		};
		
		// Discover the real container position
		var containerPosition = $(wrapper).find("ul:first").offset();
		var containerSize = $(wrapper).width();
				
		// Setup the column width as a string (for CSS)
		var columnWidth = configuration.columnWidth + "px";
		
		var myself = $(wrapper);

		// Hide and layout children beneath the first level
		$(wrapper).find(selectorName+":first").find("ul").css({
			left:columnWidth,
			top:"0px",
			position:"absolute"
		}).hide();

		// Style the columns
		$(wrapper).find(selectorName).css({
			position:"absolute",
			width:columnWidth,
			height:"100%",
			borderRight:configuration.columnSeperatorStyle,
			padding:"0",
			margin:"0"
		});
		
		// Create the additional required divs
		$(wrapper).find(selectorName).wrapInner(document.createElement("div"));
		
		// Ensure each level can scroll within the container
		$(wrapper).find(" div").css({
			height:"100%",
			overflowX:"visible",
			overflowY:"scroll"
		});
				
		// Style the internals
		$(wrapper).find(selectorName+" li").css({
			listStyle:"none",
			padding:configuration.columnItemPadding,
			backgroundColor:configuration.columnDeselectBackgroundColor,
			backgroundRepeat:configuration.columnDeselectBackgroundRepeat,
			backgroundPosition:configuration.columnDeselectBackgroundPosition
		});
		
		// Style the unselected links (this overrides specific CSS styles on the page)
		$(wrapper).find(selectorName+" a").css(
			aDeselect
			);		
		
		// Setup the onclick function for each link within the tree
		$(wrapper).find(selectorName+" a").click( function(){
			
			// Discover where this element is on the page
			var licoords = $(this).parent().offset();			// li position
			
			// Hide lower levels
			$(this).parent().siblings().find(selectorName).hide();
			
			// Deselect other levels
			$(this).parent().siblings().css( liDeselect );
			$(this).parent().siblings().removeClass( "selected" )

			// Deselect other levels children
			$(this).parent().siblings().find("li").css( liDeselect );
            $(this).parent().siblings().find("li").removeClass( "selected" );

			
			// Deselect other a links
			$(this).parent().siblings().find("a").css( aDeselect );
            $(this).parent().siblings().find("a").removeClass( "selected" )
			
			// Show child menu
			$(this).parent().find(selectorName+":first").show();
            $('#courses-search').show();
            $('.courses-search').show();

			
			// Select this level
			$(this).parent().css( liSelect );
            $(this).parent().addClass( "selected" );

			
			// Highlight the text if required
			$(this).css( aSelect );
			
			return false;
		});
	}
})
(jQuery);