$(document).ready(function(){
  $("form.infield label").inFieldLabels();

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