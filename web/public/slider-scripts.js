$(document).ready(function() {

	var $currentCourse  = null;
	var $currentSec = null;
	var $lastCourse = $(this);
	var $lastDept = $(this).children('.courses');

   	$('#courses-search, #section-search').hide();
   	$('.back_button').hide();

    	$("#departments").columnNavigation({
 		containerBackgroundColor        : "rgb(255,255,255)",
 		columnFontFamily                : "Arial,sans-serif",
        containerWidth                  : "750px",
        containerMargin                 : "auto auto auto auto",
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

			var title = section_element.parent().parent().siblings('.course-title').text();
			var time = section_element.parent('.time').text();
			var days = section_element.parent('.days').text();

			$('#course_list').append("<tr rel='" + courseList[i] + "'><td><a href='#' class='delete'><img src='images/delete.png' alt='delete'></a></td><td><span class='list_course-title'>" + title + "</span></td><td><span class='list_days'>" + days + "</span></td><td><span class='list_time'>" + time + "</span></td></tr>");
		});
	});

	$('.delete').live('click', function() {
		var crn = $(this).parent().parent().attr('rel');

		courseList = $.grep(courseList, function(data) {
			return crn != data;
		});

		if(courseList.length == 0) {
			$(".delete-all").hide();
		}

		$('.section[rel=' + crn + ']').removeClass('listed');

		$(this).parent().parent().remove();
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
            $('#list').hide();
            $('#generate_button').hide();
        	$('.back_button').show();
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

	$('.back_button').click(function() {
		$('#schedules').hide();
		$('#sliders').show();
		$('#list').show();
		$('#generate_button').show();
		$('.back_button').hide();
		$('#searchboxes').show();
	});
	    
	$('#course_list').animate({
		height: 'toggle',
		opacity: 'toggle'
	});
	    
    	$('.list_toggle').click(function() {
		$('#course_list').animate({
		    height: 'toggle',
		    opacity: 'toggle'
		});
		console.log(document.getElementById('toggle_button').src);
		if(document.getElementById('toggle_button').src=="http://scheduler.pricemysemester.com/images/toggle1.png"){
		    document.getElementById('toggle_button').src = "http://scheduler.pricemysemester.com/images/toggle2.png"
		}
		else{ 
		    document.getElementById('toggle_button').src = "http://scheduler.pricemysemester.com/images/toggle1.png"
		}
    	});

	listFilter("#departments-search", "#departments", 'department-title');
	listFilter("#courses-search", "#courses", 'course-title');
	listFilter("#sections-search", "#sections", 'section_text');

	// When a user clicks on a section on the schedules page,
	// it gets highlighted
	// only one section from a class can be selected at one time
	$(".schedule tr.section").live('click', function() {
		$(this).siblings("tr").removeClass("selected");
		$(this).addClass("selected");

		var crns = "";
		$(this).parent().parent().parent().find('tr.section.selected').each(function() {
			crns += $(this).children('.crn').text() + " ";
		});

		$(this).parent().parent().parent().siblings(".copyable-crns").text(crns);

		return false;
	});
});

