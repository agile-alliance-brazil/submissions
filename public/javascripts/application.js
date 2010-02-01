function disableOptionsExcept(selectSelector, optionValue) {
  $(selectSelector).find('option').each(function() {
    if ($(this).val() === optionValue) {
      $(this).removeAttr('disabled').attr('selected', 'selected');
    } else {
      $(this).attr('disabled', 'disabled').removeAttr('selected');
    }
  });
}

function enableOptions(selectSelector) {
  $(selectSelector).find('option').each(function() {
    $(this).removeAttr('disabled')
  })
}