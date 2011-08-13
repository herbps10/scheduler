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
		if ($currentCourse  != null)
            $currentCourse.animate({ marginLeft: 'hide' });

        
        if($currentSec != null)
            $currentSec.animate({ marginLeft: 'hide' });

   		$subCourse.animate({ marginLeft: 'show' });
   		$currentCourse = $subCourse;
   		//$(this).addClass("selected_depart");


      }else
      {
		$subSec.animate({ marginLeft: 'hide' });

				
		if ($currentCourse  != null)
            $currentCourse.animate({ marginLeft: 'show' });
			//$(this).addClass("selected_depart");
        
      }

      if ($subSec.css("display") == "none")
      {
         if ($currentSec != null)
            $currentSec.animate({ marginLeft: 'hide' });
    
   			
   		$subSec.animate({ marginLeft: 'show' });
		$currentSec = $subSec;

      }
      else
      {
        $subSec.animate({ marginLeft: 'hide' });
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
