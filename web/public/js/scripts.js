$(document).ready(function() {

	// 
	// Login button event handler
	//
	$("#small-login #login input[type=submit]").click(function() {
		$.post("/user/authenticate.json", {
			email: $("input[name=email]").val(),
			password: $("input[name=password]").val()
		}, function(data) {
			data = JSON.parse(data);

			console.log(data);
			if(data.success == true){
				window.location = "/dashboard";
			}
			else
			{
				$("#small-login #message").text("Username or password didn't work -- try again?");

				$("#small-login #message").animate({
					opacity: 0.25
				}, 250, function() {
					$("#small-login #message").animate({
						opacity: 1
					}, 250);
				});
			}
		});

		return false;
	});

	$("#user-actions a.user-login").click(function() {
		$("#user-actions-wrapper").fadeIn();
	});

	$("#user-actions-wrapper .close").click(function() {
		$("#user-actions-wrapper").fadeOut();
	});
});
