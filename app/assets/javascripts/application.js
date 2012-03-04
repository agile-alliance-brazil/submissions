/*
*= require jquery
*= require jquery_ujs
*= require jquery.ui.autocomplete
*= require_self
*= require_tree .
*/

jQuery.fn.bindSelectUpdated = function() {
  return this.each(function() {
    $(this).change(function() {$(this).trigger('updated')});
    $(this).keyup(function() {$(this).trigger('updated')});
  })
}

jQuery.fn.filterOn = function(field, options_to_hide) {
  return this.each(function() {
    var select = this;
    var options = [];
    $(select).find('option').each(function() {
      options.push($(this));
    });
    $(select).data('options', options);
    $(select).data('selected', $(select).val());
    $(field).bind('updated', function() {
      var options = $(select).empty().data('options');
      var hide_options = [];
      if (options_to_hide.hasOwnProperty($(this).val())) {
        hide_options = options_to_hide[$(this).val()];
      }
      $.each(options, function() {
        var option = $(this);
        if($.inArray(option.val(), hide_options) === -1) {
          $(select).append(option);
        }
      });
      $(select).val($(select).data('selected')).trigger('updated');
    });
  });
};