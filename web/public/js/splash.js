$(document).ready(function() {

	$('#features_button').live('click', function() {
	    $('.landing_text').delay(400).slideUp();
	    $('.thanks').delay(0).fadeOut();
	    $('#feature_wrapper').delay(1000).slideDown();
	    $('#features_button').replaceWith('<div id="back_to_landing" class="button hover_green">Back</div>');
	});

	$('#back_to_landing').live('click', function() {
	    $('#feature_wrapper').delay(100).slideUp();
	    $('.landing_text').delay(800).slideDown();
	    $('.thanks').delay(1400).fadeIn();
	    $('#back_to_landing').replaceWith('<div id="features_button" class="button hover_green">See Features</div>');
	});
	
	$('#signup').live('click', function() {
		$('#signedup').fadeIn();
	});
});