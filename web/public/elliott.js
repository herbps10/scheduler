$(document).ready(function() {

	var $current = null;
	var $currentSec = null;


   $("ul li ul").hide(); 

   $("ul li a").click(function(){
      var $sub = $(this).next('.courses'); 
      var $subSec = $(this).next('.sections'); 

      if ($sub.css("display") == "none")
      {
		if ($current != null)
            $current.animate({ marginLeft: 'hide' }); 
        
        if($currentSec != null)
            $currentSec.animate({ marginLeft: 'hide' }); 
			
   			
   		$sub.animate({ marginLeft: 'show'  });
   		$current = $sub;

      }
      else
      {
         $sub.animate({ marginLeft: 'hide'  });


      }

      if ($subSec.css("display") == "none")
      {
         if ($currentSec != null)
            $currentSec.animate({ marginLeft: 'hide' }); 
   			
   			$subSec.animate({ marginLeft: 'show'  });
			$currentSec = $subSec;

      }
      else
      {
         $subSec.animate({ marginLeft: 'hide'  });
         $currentSec = null;
      }
   });


	var list = [];

	$('.section').live('click', function() {
		$(this).toggleClass('listed');
		var text = $(this).text()
		if(text in list) {
			list.splice($.inArray(text, list), 5);
		}
		else{
			list.push("<li>"+text+"</li>");
		}
		$.unique(list)
		$('#course_list').append("<li>"+list+"</li>");
	});
	
	
});
