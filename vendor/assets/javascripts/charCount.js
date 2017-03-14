/*
 *  Character Count Plugin - jQuery plugin
 *  Dynamic character count for text areas and input fields
 *  written by Alen Grakalic
 *  http://cssglobe.com/post/7161/jquery-plugin-simplest-twitterlike-dynamic-character-count-for-textareas
 *
 *  Copyright (c) 2009 Alen Grakalic (http://cssglobe.com)
 *  Dual licensed under the MIT (MIT-LICENSE.txt)
 *  and GPL (GPL-LICENSE.txt) licenses.
 *
 *  Built for jQuery library
 *  http://jquery.com
 *
 */
(function($) {
  $.fn.charCount = function(options){
    // default configuration properties
    var defaults = {
      allowed: 140,
      warning: 0,
      css: 'counter',
      counterElement: 'span',
      cssWarning: 'warning',
      cssExceeded: 'exceeded',
      counterText: '',
      separator: '',
      setMaxLength: true
    };

    var options = $.extend(defaults, options);

    function calculate(obj, target, separator){
      var count = obj.val().split(separator).length;
      var available = options.allowed - count;

      if(available <= options.warning && available >= 0){
        target.addClass(options.cssWarning);
      } else {
        target.removeClass(options.cssWarning);
      }
      if(available < 0){
        target.addClass(options.cssExceeded);
      } else {
        target.removeClass(options.cssExceeded);
      }
      target.html(available);

      return available
    }

    this.each(function() {
      $(this).before('<'+ options.counterElement +' class="' + options.css + '">'+ options.counterText +'</'+ options.counterElement +'>');
      var target = $(this).parent().find(options.counterElement+'.'+options.css);
      calculate($(this), target, options.separator);
      var updateCount = function(e) {
        var available = calculate($(this), target, options.separator);
        if (options.setMaxLength && available <= 0) {
          var key = e.keyCode || e.charCode;
          var isShift = !!e.shiftKey;

          if(key === 8 || key === 46 || isShift || (key >= 37 && key <= 40)) {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      };
      $(this).keydown(updateCount);
      $(this).keyup(updateCount);
      $(this).change(updateCount);
    });
  };
})(jQuery);