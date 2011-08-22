$(document).ready(function() {

	var $currentCourse  = null;
	var $currentSec = null;
	var $lastCourse = $(this);
	var $lastDept = $(this).children('.courses');

   $("ul li ul").hide(); 


   $(".department, .course").click(function(){
      var $subCourse = $(this).children('.courses'); 
      var $subSec = $(this).children('.sections'); 

      if ($subCourse.css("display") == "none")
      {
        var $currentDept = $(this);
        $lastDept.removeClass("selected_depart");
        $lastDept = $currentDept;

    	//Hide last course when new dept is clicked
		if ($currentCourse  != null)
            $currentCourse.animate({ marginLeft: 'hide' });
            

        //Hide last section when new dept is clicked
        if($currentSec != null)
            $currentSec.animate({ marginLeft: 'hide' });

		//Show courses when new dept is clicked
   		$subCourse.animate({ marginLeft: 'show' });
   		$currentCourse = $subCourse;
        
        $currentDept.addClass("selected_depart");
        $lastCourse.removeClass("selected_course");
      }

      if ($subSec.css("display") == "none")
      {
		//Hide previous section when new courses is clicked
        if ($currentSec != null)
    		$currentSec.animate({ marginLeft: 'hide' });
    		
   		//Show new sections when new course is clicked
   		$subSec.animate({ marginLeft: 'show' });
		$currentSec = $subSec;
        
        $lastCourse.removeClass("selected_course");
        $lastCourse = $(this);
        $(this).addClass("selected_course");
      }
   });


	var courseList = [];

	$('.section').live('click', function() {
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
			$('#course_list').append("<li>" + courseList[i] + "</li>");
		});
	});

	$(".generate-list").click(function() {
		$.get("/schedules", {
			'crns[]': courseList
		}, function(data) {
			$("#schedules").html(data);
		});
	});

	// from: http://kilianvalkhof.com/2010/javascript/how-to-build-a-fast-simple-list-filter-with-jquery/
	jQuery.expr[':'].Contains = function(a,i,m){
		    return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase())>=0;
	};

	function listFilter(inputs, list, cls) {
		$(inputs).change(function() {
			var filter = $(this).val();

			if(filter) {
				$(this).parent().find("a." + cls + ":Contains(" + filter + ")").parent().show();
				$(this).parent().find("a." + cls + ":not(:Contains(" + filter + "))").parent().hide();
			}
			else {
				$(this).parent().children('li').show();
			}
		}).keyup(function() {
			$(this).change();
		});
	}
    
    $('.courses-search').focus(function() {
        if ($currentSec != null)
    		$currentSec.animate({ marginLeft: 'hide' });
        
        $lastCourse.removeClass("selected_course");
    })
    
    $('#departments-search').focus(function() {
        $lastDept.removeClass("selected_depart");

		if ($currentCourse  != null)
            $currentCourse.animate({ marginLeft: 'hide' });
            
        if($currentSec != null)
            $currentSec.animate({ marginLeft: 'hide' });
        
        $lastCourse.removeClass("selected_course");
    })

	listFilter("#departments-search", ".departments", 'department-title');
	listFilter(".courses-search", ".courses", 'course-title');
});
