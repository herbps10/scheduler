$(document).ready(function(){
	$("td.title").live('click', function(e){
		switch(e.target.id){
			case "first":
				$("#first").addClass("active");
				$("#second").removeClass("active");
				$("#third").removeClass("active");
						console.log("heelo");
			break;
			case "second":
				$("#first").removeClass("active");
				$("#second").addClass("active");
				$("#third").removeClass("active");
			break;
			case "third":
				$("#first").removeClass("active");
				$("#second").removeClass("active");
				$("#third").addClass("active");
			break;
		}
		console.log($(this));
	});
});