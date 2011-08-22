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
		var text = $(this).children('a').text().trim();

		if(!(text in list)) {
			list.push(text);
		}

		$.unique(list)

		$("#course_list").html('');

		$(list).each(function(i) {
			$('#course_list').append("<li>" + list[i] + "</li>");
		});
	});

	$(".generate-list").click(function() {
		console.log(list);
		$.get("/schedules", {
			'crns[]': list
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
				$(this).parent().find('li').show();
			}
		}).keyup(function() {
			$(this).change();
		});
	}

	listFilter("#departments-search", ".departments", 'department-title');
	listFilter(".courses-search", ".courses", 'course-title');
});
