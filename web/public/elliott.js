$(document).ready(function() {

	var $currentCourse  = null;
	var $currentSec = null;
	var $lastCourse = $(this);
	var $lastDept = $(this).children('.courses');

   $('#courses-search, #back_button').hide();

    
    	$("#myTree").columnNavigation({
 		containerBackgroundColor        : "rgb(255,255,255)",
 		columnFontFamily                : "Arial,sans-serif",
 		columnScrollVelocity            : 600,
        containerWidth                  : "750px",
        containerMargin                 : "20px auto auto auto",
 	});

	var courseList = [];

	$('.section').live('click', function() {
		if(courseList.length == 0) {
			$(".delete-all").show();
		}

		$(this).toggleClass('listed');

		var text = $(this).children('.section_text').children('.crn').text().trim();

		if(courseList.indexOf(text) == -1) {
			courseList.push(text);
		}
		else {
			courseList = $.grep(courseList, function(data) {
				return data != text;
			});
		}

		$.unique(courseList)

		$('#course_list').html('');
		$(courseList).each(function(i) {
			var section_element = $('.section[rel=' + courseList[i] + ']');

			var title = section_element.parent().parent().parent().siblings('.course-title').text();
			var time = section_element.children('.time').text();
			var days = section_element.children('.days').text();

			$('#course_list').append("<li rel='" + courseList[i] + "'><span class='list_course-title'>" + title + "</span><br/><span class='list_days'>" + days + "</span> <span class='list_time'>" + time + "</span><br/><a href='#' class='delete'>remove</a></li>");
		});
	});

	$('.delete').live('click', function() {
		var crn = $(this).parent().attr('rel');

		courseList = $.grep(courseList, function(data) {
			return crn != data;
		});

		if(courseList.length == 0) {
			$(".delete-all").hide();
		}

		$('.section[rel=' + crn + ']').removeClass('listed');

		$(this).parent().remove();
	});

	$('.delete-all').click(function() {
		courseList = [];
		$("#course_list").html('');
		$(".listed").removeClass('listed');

		$(this).hide();
	});

	$("#generate_button").click(function() {
		$.get("/schedules", {
			'crns[]': courseList
		}, function(data) {
			$("#schedules").html(data);
		});

        	$('#sliders, #searchboxes').hide(); 
        	$('#back_button').show();
        	$('#schedules').show();
	});

	// from: http://kilianvalkhof.com/2010/javascript/how-to-build-a-fast-simple-list-filter-with-jquery/
	jQuery.expr[':'].Contains = function(a,i,m){
		    return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase())>=0;
	};

	function listFilter(inputs, list, cls) {
		$(inputs).change(function() {
			var filter = $(this).val();

			if(filter) {
				$(list).find("a." + cls + ":Contains(" + filter + ")").parent().show();
				$(list).find("a." + cls + ":not(:Contains(" + filter + "))").parent().hide();
			}
			else {
				$(list).children('li').show();
			}
		}).keyup(function() {
			$(this).change();
		});
	}

    $('#courses-search').focus(function() {

    })
    
    $('#departments-search').focus(function() {

    })

    $('#back_button').click(function() {
        $('#schedules').hide();
        $('#sliders').show();
        $('#back_button').hide();
    });

	listFilter("#departments-search", ".departments", 'department-title');
	listFilter("#courses-search", ".courses", 'course-title');
});

