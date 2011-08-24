$(document).ready(function() {

	var $currentCourse  = null;
	var $currentSec = null;
	var $lastCourse = $(this);
	var $lastDept = $(this).children('.courses');

   $('ul li ul').hide(); 
   $('#courses-search, #back_button').hide();

   $(".department, .course").click(function(){
      var $subCourse = $(this).children('.courses'); 
      var $subSec = $(this).children('.sections'); 

      if ($subCourse.css("display") == "none")
      {
        var $currentDept = $(this);
        $lastDept.removeClass("selected_depart");
        $lastDept = $currentDept;

    	//Hide last course when new dept is clicked
		if ($currentCourse  != null){
            $currentCourse.animate({ left: 'hide' });
        }

        //Hide last section when new dept is clicked
        if($currentSec != null){
            $currentSec.animate({ left: 'hide' });
        }

		//Show courses when new dept is clicked
   		$subCourse.animate({ left: 'show' });
   		$currentCourse = $subCourse;
        $('#courses-search').show();
                        
        $currentDept.addClass("selected_depart");
        $lastCourse.removeClass("selected_course");
      }

      if ($subSec.css("display") == "none")
      {
		//Hide previous section when new courses is clicked
        if ($currentSec != null){
    		$currentSec.animate({ left: 'hide' });

        }
    		
   		//Show new sections when new course is clicked
   		$subSec.animate({ left: 'show' });
		$currentSec = $subSec;
        
        $lastCourse.removeClass("selected_course");
        $lastCourse = $(this);
        $(this).addClass("selected_course");
      }
   });

	var courseList = [];

	$('.section').live('click', function() {
		if(courseList.length == 0) {
			$(".delete-all").show();
		}

		$(this).toggleClass('listed');

		var text = $(this).children('a').text().trim();

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

			var title = section_element.parent('.sections').siblings('.course-title').text();
			var time = section_element.children('.time').text();
			var days = section_element.children('.days').text();

			$('#course_list').append("<li rel='" + courseList[i] + "'><span class='course-title'>" + title + "</span><br/><span class='days'>" + days + "</span> <span class='time'>" + time + "</span> <a href='#' class='delete'>delete</a></li>");
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

        	$('#sliders').hide(); 
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
        if ($currentSec != null)
    		$currentSec.animate({ left: 'hide' });
        
        $lastCourse.removeClass("selected_course");
    })
    
    $('#departments-search').focus(function() {
        $lastDept.removeClass("selected_depart");

		if ($currentCourse  != null)
            $currentCourse.animate({ left: 'hide' });
            
        if($currentSec != null)
            $currentSec.animate({ left: 'hide' });
        
        $lastCourse.removeClass("selected_course");
    })
    
    $('#back_button').click(function() {
        $('#schedules').hide();
        $('#sliders').show();
        $('#back_button').hide();
    });

	listFilter("#departments-search", ".departments", 'department-title');
	listFilter("#courses-search", ".courses", 'course-title');
});
