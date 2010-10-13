$(document).ready(function(){
  $("form.infield label").inFieldLabels();

  $(".valid").validate();

  // validate signup form on keyup and submit
	$("#person").validate({
		rules: {
			email: {
				required: true,
				email: true
			},
			name: {
			required: true,
			},
			password: {
				required: true,
				minlength: 5,
				equalTo: "#confirm_password"
			},
			confirm_password: {
				required: true,
				minlength: 5
			}
		},
		messages: {
			email: 
			{
			required:"Please enter a valid email address."	
			},
			name: {
			required:"Please enter your name."	
			},
			password: {
				required: "Please provide a password.",
				minlength: "Your password must be at least 5 characters long."
			},
			confirm_password: {
				required: "Please provide a password.",
				minlength: "Your password must be at least 5 characters long.",
				equalTo: "Your entered passwords did not match."
			}
		}
	});

	
	$( "#date" ).datepicker();


  $('input.closed').change(function () {
    if ($(this).attr("checked")) {
		$(this).parent('td').siblings('td.time').children('input').attr('readonly', true);
        $(this).parent('td').siblings('td.time').children('input').val('Closed');
		$(this).parent('td').siblings('td.price').children('p').children('input').val('');
		$(this).parent('td').siblings('td.price').children('p').children('input').attr('disabled', true);
		$(this).parent('td').siblings('td.cover').children('input').attr('disabled', true);
		return;
    }
      $(this).parent('td').siblings('td.time').children('input').attr('readonly', false);
      $(this).parent('td').siblings('td.time').children('input').val('');
	  $(this).parent('td').siblings('td.price').children('p').children('input').attr('disabled', false);
	  $(this).parent('td').siblings('td.cover').children('input').attr('disabled', false);
  });

  $('input.cover').change(function () {
    if ($(this).attr("checked")) {
		$(this).parent('td').siblings('td.price').children('p').show()
		return;
    }
	  $(this).parent('td').siblings('td.price').children('p').children('input').attr('disabled', false);
      $(this).parent('td').siblings('td.price').children('p').hide();
  });

});

function confirmDelete(url) {
  if (confirm("Are you sure you want to delete? This cannot be undone.")) {
    window.location.replace(url);
  }
}