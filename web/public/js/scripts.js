$(document).ready(function() {

	var $currentCourse  = null;
	var $currentSec = null;
	var $lastCourse = $(this);
	var $lastDept = $(this).children('.courses');

    $('.back_button, #slider_wrapper').hide();

    $("#departments").columnNavigation({
 		containerBackgroundColor        : "rgb(255,255,255)",
 		columnFontFamily                : "Arial,sans-serif",
        containerWidth                  : "750px",
        containerMargin                 : "auto auto auto auto",
 	});

	var courseList = [];

    $('#begin').live('click', function() {
        $('#landing, #beta').delay(100).fadeOut();
        $('#slider_wrapper').delay(800).fadeIn();
    });

	$('.section').live('click', function() {
		if(courseList.length == 0) {
			$(".delete-all").fadeIn();
            $('#list').delay(0).animate({
                    bottom: '0px'
            });
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
			$(".delete-all").fadeOut();
		}

		$('.section[rel=' + crn + ']').removeClass('listed');

		$(this).parent().parent().remove();
	});

	$('.delete-all').click(function() {
		courseList = [];
		$("#course_list").html('');
		$(".listed").removeClass('listed');

		$(this).fadeOut();
	});

	$("#generate_button").click(function() {
		$.get("/schedules", {
			'crns[]': courseList
		}, function(data) {
			$("#schedules").html(data);
		});
        
        $('#slider_wrapper').delay(400).fadeOut(); 
        $('#list').delay(0).animate({
            bottom: '-260px'
        });

        $('.back_button').delay(1000).fadeIn();
        $('#schedules').delay(1000).fadeIn();
	});

	// from: http://kilianvalkhof.com/2010/javascript/how-to-build-a-fast-simple-list-filter-with-jquery/
	jQuery.expr[':'].Contains = function(a,i,m){
		    return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase())>=0;
	};

	function listFilter(inputs, list, cls) {
		$(inputs).live('change', function() {
			console.log($(this).val());

			var filter = $(this).val();

			if(filter) {
				$(list).find("a." + cls + ":Contains(" + filter + ")").parent().fadeIn();
				$(list).find("a." + cls + ":not(:Contains(" + filter + "))").parent().fadeOut();
			}
			else {
				$(list).children('div').children('li').fadeIn();
			}
		}).live('keyup', function() {
			$(this).change();
		});
	}

	$('.back_button').click(function() {
		$('#schedules').delay(100).fadeOut();
		$('.back_button').delay(100).fadeOut();
        
		$('#slider_wrapper').delay(1000).fadeIn();
		if(courseList.length != 0) {
                $('#list').delay(2000).animate({
                    bottom: '-200px'
                });
        }
        $('.copyable-crns').text("");
	});
	    
    $('.list_toggle').click(function() {
        if($('#list').css('bottom') == '-200px') {
            $('#list').animate({
                bottom: '0px',
            });
            document.getElementById('toggle_button').src = "http://scheduler.pricemysemester.com/images/toggle1.png"
        }
        if($('#list').css('bottom') == '0px') {
            document.getElementById('toggle_button').src = "http://scheduler.pricemysemester.com/images/toggle2.png"
            $('#list').animate({
                bottom: '-200px',
            });
        }
    });

	listFilter("#departments-search", "#departments", 'department-title');
	listFilter("#courses-search", ".courses", 'course-title');
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

