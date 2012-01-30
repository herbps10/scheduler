$(document).ready(function() {
	$.get("/schedules.json", {
			crns: ['55374', '50608', '54582', '50371']
	}, function(data) {
		console.log(data);
	});
});
