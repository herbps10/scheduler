$(document).ready(function(){
	$(".title").live('click', function(e){
		$(".title").removeClass('active');
		$(this).addClass('active');
	});

	$("form.subscribe input[type=checkbox]").click(function() {
		var crn = $(this).attr('rel');
		
		if($(this).is(":checked")) {
			// Subscribe

			$.get("/user/subscriptions/add", {
				crn: crn
			});
		}
		else {
			// Unsubscribe
			$.get("/user/subscriptions/remove", {
				crn: crn
			});
		}
	});	
});
