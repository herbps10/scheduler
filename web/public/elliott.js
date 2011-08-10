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


	$('.section').live('click', function() {
		$(this).toggleClass('scratch_list');
	});
	
});
