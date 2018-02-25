/*
 *= require vendor_libs
 *= require highcharts
 *= require_tree .
 *= require actions
 *= require jquery-ui/widgets/tabs
 *= require jquery-ui/widgets/datepicker
 *= require jqcloud
 */

(function($) {
  $.fn.bindSelectUpdated = function() {
    return this.each(function() {
      $(this).change(function() {$(this).trigger('updated')});
      $(this).keyup(function() {$(this).trigger('updated')});
    })
  }

  $.fn.filterOn = function(field, options_to_hide) {
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

  $(document).ready(function() {
    $("#session_second_author_username,#session_filter_username").autocomplete({
      source: $("#session_second_author_username,#session_filter_username").data("autocomplete-url")
    });
    function split(val) {
      return val.split(/,\s*/);
    }
    function extractLast(term) {
      return split(term).pop();
    }

    $("#session_keyword_list,#session_filter_tags")
    // don't navigate away from the field on tab when selecting an item
        .bind( "keydown", function( event ) {
          if ( event.keyCode === $.ui.keyCode.TAB && $(this).data("autocomplete").menu.active ) {
            event.preventDefault();
          }
        })
        .autocomplete({
          source: function(request, response) {
            $.getJSON($("#session_keyword_list,#session_filter_tags").data("autocomplete-url"), {
              term: extractLast(request.term)
            }, response);
          },
          focus: function() {
            // prevent value inserted on focus
            return false;
          },
          select: function(event, ui) {
            var terms = split(this.value);
            // remove the current input
            terms.pop();
            // add the selected item
            terms.push(ui.item.value);
            // add placeholder to get the comma-and-space at the end
            terms.push("");
            this.value = terms.join(", ");
            return false;
          }
        });
    var year = $('#container').data('conference-year');
    if ($('.tagcloud').length > 0 && year) {
      $.ajax({
        url: '/api/'+year+'/tags',
      }).done(function(data) {
        if (data.len > 0) {
          $('.tagcloud').jQCloud(data);
        }
      });
    }
  });
})(jQuery);
