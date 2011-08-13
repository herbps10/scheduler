$(document).ready(function() {

	var $currentCourse  = null;
	var $currentSec = null;
	var $lastCourse = null;
	var $lastDept = null;

   $("ul li ul").hide(); 


   $(".department,.course").click(function(){
      var $subCourse = $(this).next('.courses'); 
      var $subSec = $(this).next('.sections'); 


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
		$current = null;
		var thisText = "<li>"+$(this).text()+"<li>";
		var realArray = $.makeArray( courseList );
		$(this).toggleClass('listed');
		console.log(courseList);
		courseList = $.map( realArray, function(n){
			return n == thisText ? null : (n, thisText.push(courseList));
		});
		courseList = realArray;
		console.log(courseList);

		$('#course_list').append($(courseList).text());
		
		
	});
	
	
});
