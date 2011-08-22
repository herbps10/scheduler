$(document).ready(function() {

	var $currentCourse  = null;
	var $currentSec = null;
	var $lastCourse = null;
	var $lastDept = null;

   $("ul li ul").hide(); 


   $(".department, .course").click(function(){
      var $subCourse = $(this).children('.courses'); 
      var $subSec = $(this).children('.sections'); 

      if ($subCourse.css("display") == "none")
      {

    	//Hide last course when new dept is clicked
		if ($currentCourse  != null)
            $currentCourse.animate({ marginLeft: 'hide' });

        //Hide last section when new dept is clicked
        if($currentSec != null)
            $currentSec.animate({ marginLeft: 'hide' });

		//Show courses when new dept is clicked
   		$subCourse.animate({ marginLeft: 'show' });
   		
   		$currentCourse = $subCourse;
   		//$(this).addClass("selected_depart");
      }

      if ($subSec.css("display") == "none")
      {
		//Hide previous section
        if ($currentSec != null)
    		$currentSec.animate({ marginLeft: 'hide' });
    		
   		//Show new section	
   		$subSec.animate({ marginLeft: 'show' });
		$currentSec = $subSec;

      }
      else
      {
        //$subSec.animate({ marginLeft: 'hide' });
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

	listFilter("#departments-search", ".departments", 'department-title');
	listFilter(".courses-search", ".courses", 'course-title');
});
